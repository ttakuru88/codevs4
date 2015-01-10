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
    group = nearest_unfull_group(unit)
    if group
      unit.group = group
      group.units << unit

      if group.units.size == 1 && group.next_point[:wait_charge]
        group.y = unit.y
        group.x = unit.x
      end
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

  def nearest_unfull_group(unit)
    near_group = nil
    min_dist = 101 + 101

    groups.shuffle.each do |group|
      next if group.full_units?(unit)
      next if near_group && group.primary > near_group.primary

      dist = (group.y - unit.y).abs + (group.x - unit.x).abs
      if dist < min_dist || group.primary < near_group.primary
        near_group = group
        min_dist = dist
      end
    end

    near_group
  end

  def move
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
