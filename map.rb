class Map
  attr_accessor :units, :enemies, :resources, :map

  def initialize
    self.units = []
    self.enemies = []
    self.resources = []

    self.map = []
    100.times do |i|
      self.map[i] = []
      100.times do |j|
        self.map[i][j] = Cell.new
      end
    end
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
    self.resources << resource
    self.map[resource.y][resource.x].resources << resource
  end
end
