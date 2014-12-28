class GroupList
  attr_accessor :groups

  def initialize
    self.groups = []
  end

  def create(primary, units, points)
    group = Group.new(primary, units, points)
    self.groups << group

    group
  end

  def attach(unit)
    group = nearest_unfull_group(unit)
    if group
      unit.group = group
      group.units << unit
      group.creating_worker -= 1
    end
  end

  def nearest_unfull_group(unit)
    near_group = nil
    min_dist = 101 + 101

    groups.each do |group|
      if unit.worker? && group.creating_worker > 0
        next if group.full_units?

        dist = (group.y - unit.y).abs + (group.x - unit.x).abs
        if dist < min_dist
          near_group = group
          min_dist = dist
        end
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
