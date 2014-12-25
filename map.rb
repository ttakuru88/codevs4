class Map < Cell
  attr_accessor :map

  def turn_init
    self.enemies = []

    self.units.each do |unit|
      unit.die = true
      unit.action = :none
    end

    self.map = []
    100.times do |i|
      self.map[i] = []
      100.times do |j|
        self.map[i][j] = Cell.new
      end
    end

    self.resources.each do |resource|
      self.map[resource.y][resource.x].resources << resource
    end
  end

  def initialize
    super

    turn_init
  end

  def active_units
    units.select { |u| u.action != :none }
  end

  def at(y, x)
    map[y][x]
  end

  def add_unit(unit)
    if unit.enemy?
      self.enemies << unit
      self.map[unit.y][unit.x].enemies << unit
    else
      cur_unit = find_unit(unit.id)
      if cur_unit
        cur_unit.die = false
        cur_unit.hp = unit.hp
        cur_unit.y = unit.y
        cur_unit.x = unit.x

        unit = cur_unit
      else
        self.units << unit
      end

      self.map[unit.y][unit.x].units << unit
    end
  end

  def find_unit(unit_id)
    units.find { |u| u.id == unit_id }
  end

  def clean_units!
    self.units = units.reject(&:die)
  end

  def add_resource(resource)
    return false if self.at(resource.y, resource.x).resources.size > 0

    self.resources << resource
    self.map[resource.y][resource.x].resources << resource
    resource
  end
end
