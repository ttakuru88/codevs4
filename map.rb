class Map < Cell
  attr_accessor :map

  def turn_init
    self.units = []
    self.enemies = []

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

  def at(y, x)
    map[y][x]
  end

  def add_unit(unit)
    if unit.enemy?
      self.enemies << unit
      self.map[unit.y][unit.x].enemies << unit
    else
      self.units << unit
      self.map[unit.y][unit.x].units << unit
    end
  end

  def add_resource(resource)
    return if self.at(resource.y, resource.x).resources.size > 0

    self.resources << resource
    self.map[resource.y][resource.x].resources << resource
  end
end
