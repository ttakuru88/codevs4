class Map < Cell
  attr_accessor :map, :visible_map

  def turn_init
    self.enemies = [enemy_castle]

    self.units.each do |unit|
      unit.die = true
      unit.action = :none
    end

    self.map = []
    100.times do |i|
      self.map[i] = []
      100.times do |j|
        self.map[i][j] = Cell.new(i, j)
      end
    end

    self.resources.each do |resource|
      self.map[resource.y][resource.x].resources << resource
    end
  end

  def initialize
    super(0, 0)

    turn_init

    self.visible_map = []
    100.times do |i|
      self.visible_map[i] = []
      100.times do |j|
        self.visible_map[i][j] = false
      end
    end
  end

  def active_units
    units.select { |u| u.action != :none }
  end

  def at(y, x)
    cell = map[y][x]
    cell.visible = visible_map[y][x]
    cell
  end

  def expect_enemy_castle_cell
    60.upto(99) do |y|
      60.upto(99) do |x|
        next if y + x < 160

        cell = at(y, x)
        unless cell.visible
          return at(y, x)
        end
      end
    end
  end

  def add_unit(unit)
    if unit.enemy?
      self.enemies << unit unless unit.castle? && enemy_castle
      self.map[unit.y][unit.x].enemies << unit

      self.map[unit.y][unit.x].resources.each { |r| r.exists_enemy = true }
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

      unless visible_map[unit.y][unit.x]
        (unit.y - 4).upto(unit.y + 4) do |to_y|
          self.visible_map[to_y][unit.x] = true if to_y < 100 && to_y > 0
        end
        (unit.x - 4).upto(unit.x + 4) do |to_x|
          self.visible_map[unit.y][to_x] = true if to_x < 100 && to_x > 0
        end
      end
    end

    unit
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

  def clean_units!
    self.units = units.reject(&:die)
  end

  def add_resource(resource)
    cell = at(resource.y, resource.x)
    return false if cell.resources.size > 0

    self.resources << resource
    self.map[resource.y][resource.x].resources << resource
    resource
  end
end
