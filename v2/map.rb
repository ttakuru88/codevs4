class Map < Cell
  attr_accessor :map

  def turn_init
    self.enemies = [enemy_castle]

    self.units.each do |unit|
      unit.die = true
      unit.action = :none
    end

    self.resources.each do |resource|
      self.map[resource.y][resource.x].resources << resource
    end

    map.each do |line|
      line.each do |cell|
        cell.turn_init
      end
    end
  end

  def initialize
    super(0, 0)

    self.map = []
    100.times do |i|
      self.map[i] = []
      100.times do |j|
        self.map[i][j] = Cell.new(i, j)
      end
    end
  end

  def at(y, x)
    map[y][x]
  end

  def near_worker_factory(y, x)
    factory = castle
    min_dist = (castle.y - y).abs + (castle.x - x).abs

    villages.each do |village|
      dist = (village.y - y).abs + (village.x - x).abs
      if dist < min_dist
        min_dist = dist
        factory = village
      end
    end

    factory
  end

  def expect_enemy_castle_cell
    60.upto(99) do |y|
      60.upto(99) do |x|
        next if y + x < 160

        cell = at(y, x)
        return at(y, x) unless cell.known
      end
    end
  end

  def add_unit(unit)
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

    cell = at(unit.y, unit.x)
    cell.units << unit

    (-unit.sight).upto(unit.sight) do |dy|
       (-(unit.sight - dy.abs)).upto(unit.sight - dy.abs) do |dx|
         y = unit.y + dy
         x = unit.x + dx
         at(y, x).known = true if y >= 0 && x >= 0 && y < 100 && x < 100
       end
    end

    unit
  end

  def add_enemy(unit)
    self.enemies << unit unless unit.castle? && enemy_castle
    self.map[unit.y][unit.x].enemies << unit

    unit
  end

  def near_villages(y, x, range = 30)
    villages.select { |v| (v.y-y).abs + (v.x-x).abs < range }
  end

  def near_resources(y, x, range = 30)
    resources.select { |v| (v.y-y).abs + (v.x-x).abs < range }
  end

  def near_exists_enemy_resource
    max = 0
    resource = nil
    resources.each do |r|
      if r.exists_enemy && max < r.x + r.y
        max = r.x + r.y
        resource = r
      end
    end

    resource
  end

  def find_unit(unit_id)
    units.find { |u| u.id == unit_id }
  end

  def clean_dead_units
    dead_units = []

    self.units = units.reject do |unit|
      if unit.die
        unit.dead
        dead_units << unit
      end

      unit.die
    end

    dead_units
  end

  def die_tmp_villages
    villages.each do |village|
      village.die = true if village.id == nil
    end
  end

  def add_resource(resource)
    cell = at(resource.y, resource.x)
    return false if cell.resources.size > 0

    self.resources << resource
    at(resource.y, resource.x).resources << resource
    resource
  end
end
