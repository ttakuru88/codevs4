class GroupList
  attr_accessor :groups, :next_id, :map

  def initialize(map)
    self.groups = []
    self.next_id = 0
    self.map = map
  end

  def create(type, primary, units, points, parent = nil)
    group = Group.new(type, primary, units, points, next_id, parent)
    self.groups << group

    self.next_id += 1

    group
  end

  def attach(unit)
    group, dist = nearest_unfull_group(unit)
    if group && group.next_point && (unit.worker? || dist < 10)
      unit.group = group
      group.units << unit

      if group.units.size == 1 && group.next_point[:wait_charge]
        group.y = unit.y
        group.x = unit.x
      end
    end
  end

  def clean_tmp_units
    groups.each do |group|
      group.units = group.units.select(&:id)
    end
  end

  def resource_guardians_at(y, x)
    groups.select do |group|
      group.resource_guardian? && group.y == y && group.x == x
    end
  end

  def enemy_castle_attackers_at(y, x)
    groups.select do |group|
      group.enemy_castle_attacker? && group.y == y && group.x == x
    end
  end

  def resource_worker_groups_to(cell)
    groups.select do |group|
      group.resource_worker? && group.to?(cell)
    end
  end

  def resource_guardian_groups_to(cell)
    groups.select do |group|
      group.resource_guardian? && group.to?(cell)
    end
  end

  def free_resource_guardians
    groups.select do |group|
      group.resource_guardian? && (!group.next_point || group.next_point[:free])
    end
  end

  def resource_guardians
    groups.select(&:resource_guardian?)
  end

  def all
    groups
  end

  def battler_groups
    groups.select(&:include_battler?)
  end

  def clean_destroyed_group
    self.groups = groups.reject do |g|
      if g.active && g.units.size <= 0
        g.parent.dead_groups_count += 1 if g.parent
        true
      else
        false
      end
    end
  end

  def destroy(destroy_groups)
    destroy_groups.each do |g|
      g.units.each { |u| u.group = nil }
      self.groups.delete(g)
    end
  end

  def nearest_unfull_group(unit)
    near_group = nil
    min_dist = 101 + 101

    group_list = groups.group_by(&:type).values.map do |groups|
      groups.reject { |group| group.full_units?(unit) }
    end

    groups = group_list.sample
    return [nil, min_dist] unless groups

    groups.each do |group|
      next if group.full_units?(unit)
      next if near_group && group.primary > near_group.primary

      dist = (group.y - unit.y).abs + (group.x - unit.x).abs
      if dist < min_dist || group.primary < near_group.primary
        near_group = group
        min_dist = dist
      end
    end

    [near_group, min_dist]
  end

  def move
    groups.each { |g| g.move(map) }
  end

  def clean(units)
    groups.each { |g| g.clean(units) }
  end

  def wishes
    wish_list = []

    groups.reject(&:active).select(&:include_battler?).each do |group|
      wish_list += group.wishes
    end

    groups.reject(&:include_battler?).each do |group|
      wish_list += group.wishes
    end

    wish_list
  end

  def inactive_groups
    groups.reject(&:active)
  end
end
