class GroupList
  attr_accessor :groups, :next_id, :attacker_count

  def initialize
    self.groups = []
    self.next_id = 0
    self.attacker_count = 0
  end

  def create(primary, units, points, parent = nil)
    group = Group.new(primary, units, points, next_id, parent)
    self.groups << group

    self.next_id += 1

    self.attacker_count += 1 if group.attacker?

    group
  end

  def attach(unit, map)
    group = nearest_unfull_group(unit, map)
    if group
      unit.group = group
      group.units << unit
    end
  end

  def all
    groups
  end

  def battler_groups
    groups.select { |g| g.include_battler? }
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

  def resource_groups
    groups.select(&:in_resource?)
  end

  def nearest_unfull_group(unit, map)
    near_group = nil
    min_dist = 101 + 101

    groups.each do |group|
      next if group.full_units?(unit)
      next if group.in_resource? && map.at(group.y, group.x).resources[0].exists_enemy

      dist = (group.y - unit.y).abs + (group.x - unit.x).abs
      if dist < min_dist
        near_group = group
        min_dist = dist
      end
    end

    near_group
  end

  def move(map)
    groups.each { |g| g.move(map) }
  end

  def clean(units)
    groups.each { |g| g.clean(units) }
  end

  def wishes
    wish_list = []

    unfinished_groups.each do |group|
      wish_list += group.wishes
    end

    wish_list
  end

  def unfinished_groups
    groups.select { |g| !g.finished? }
  end
end
