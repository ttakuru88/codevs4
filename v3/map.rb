class Map < Cell
  attr_accessor :map, :expected_enemy_castle_positions, :many_attacker_near_enemy_castle, :inverse, :groups, :resources, :unknown_cells

  def turn_init
    self.enemies = [enemy_castle].compact

    units.each do |unit|
      unit.die = true
      unit.update_prev_position
      unit.action = :none
    end

    resources.each do |resource|
      self.map[resource.y][resource.x].resource = resource
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
    self.unknown_cells = []
    100.times do |i|
      self.map[i] = []
      100.times do |j|
        self.unknown_cells << self.map[i][j] = Cell.new(i, j)
      end
    end

    self.expected_enemy_castle_positions = []
    self.many_attacker_near_enemy_castle = false
    self.inverse = false
    self.groups = GroupList.new(self)
    self.resources = []
  end

  def at(y, x)
    map[y][x]
  end

  def nearest_unknown_cell(from, random = false)
    min_dist = 101 + 101
    group_unknown_cells = []
    group_unknown_cells[min_dist] = []

    unknown_cells.each do |cell|
      dist = (cell.y - from.y).abs + (cell.x - from.x).abs

      group_unknown_cells[dist] ||= []
      group_unknown_cells[dist] << cell
      if dist < min_dist
        min_dist = dist
      end
    end

    [group_unknown_cells[min_dist].sample, min_dist]
  end

  def benefit_resources
    resources.reduce(10) do |sum, resource|
      sum += at(resource.y, resource.x).workers.size
    end
  end

  def enemy_castle_safety?
    enemy_castle && sight?(enemy_castle.y, enemy_castle.x) && !exists_enemy_battler?(enemy_castle)
  end

  def sight_near_enemy?(y, x, sight = 4)
    sight_count = 0

    (-sight).upto(sight) do |dy|
      (-sight).upto(sight) do |dx|
        px = x + dx
        py = y + dy
        next if px < 0 || py < 0 || px > 99 || py > 99

        if sight?(py, px)
          sight_count += 1
          return true if at(py, px).enemies.size > 0
        end
      end
    end

    sight_count <= 0
  end

  def near_enemy_battlers(y, x)
    list = []
    sight_count = 1

    (-1).upto(1) do |dy|
      (-1).upto(1) do |dx|
        next if dy.abs + dx.abs >= 2

        py = y + dy
        px = x + dx
        next if py > 99 || px > 99 || py < 0 || px < 0
        next unless sight?(py, px)

        list += at(py, px).enemy_battlers
        sight_count += 1 if at(py, px).enemy_battlers.size > 0
      end
    end

    [list, sight_count]
  end

  def exists_enemy_battler?(target)
    at(target.y, target.x).enemies.any?(&:battler?)
  end

  def create_group(type, primary, units, points, parent = nil)
    groups.create(type, primary, units, points, parent = nil)
  end

  def bottom_right_worker(target)
    worker = 1
  end

  def near_units(units, target, dist = 2)
    units.select do |unit|
      (target.y - unit.y).abs + (target.x - unit.x).abs <= dist
    end
  end

  def near_enemies(target, dist = 2)
    near_units(enemies, target, dist)
  end

  def calc_k(unit)
    k = 0
    if unit.enemy
      (-unit.attack_range).upto(unit.attack_range) do |dy|
         (-(unit.attack_range - dy.abs)).upto(unit.attack_range - dy.abs) do |dx|
           y = unit.y + dy
           x = unit.x + dx
           k += [at(y, x).units.size, 10].min if y >= 0 && x >= 0 && y < 100 && x < 100
         end
      end
    end

    k
  end

  def viewable_unknown_cells(py, px, sight)
    unknown_cells.select do |cell|
      dist = (cell.y - py).abs + (cell.x - px).abs
      dist <= sight
    end
  end

  def nearest_enemy_resource(group)
    nearest_resource = nil
    min_dist = 101 + 101

    resources.each do |resource|
      next if (resource.exists_unit && !resource.exists_enemy) || groups.resource_guardian_groups_to(at(resource.y, resource.x)).size > 0
      next if group.prev_point && resource.y == group.prev_point[:y] && resource.x == group.prev_point[:x]

      dist = (group.y - resource.y).abs + (group.x - resource.x).abs
      if min_dist > dist
        nearest_resource = resource
        min_dist = dist
      end
    end

    nearest_resource
  end

  def nearest_neet_worker_factory(y, x)
    factory = castle
    min_dist = (castle.y - y).abs + (castle.x - x).abs

    villages.each do |village|
      next unless village.free?

      dist = (village.y - y).abs + (village.x - x).abs
      if dist < min_dist
        min_dist = dist
        factory = village
      end
    end

    factory
  end

  def nearest_worker_factory(y, x)
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

  def near_castle_battlers
    unit_list = []
    battlers.each do |battler|
      dist = (castle.y - battler.group.y).abs + (castle.x - battler.group.x).abs
      if dist <= 2
        unit_list << battler
      end
    end

    unit_list
  end

  def nearest_worker(target)
    min_dist = 101 + 101
    nearest_worker = nil

    workers.each do |worker|
      dist = (target.y - worker.y).abs + (target.x - worker.x).abs
      if dist < min_dist
        min_dist = dist
        nearest_worker = worker
      end
    end

    [nearest_worker, min_dist]
  end

  def nearest_active_worker(target)
    min_dist = 101 + 101
    nearest_worker = nil

    workers.each do |worker|
      next unless worker.group

      dist = (target.y - worker.y).abs + (target.x - worker.x).abs
      if dist < min_dist
        min_dist = dist
        nearest_worker = worker
      end
    end

    [nearest_worker, min_dist]
  end

  def nearest_neet_battler_factory(y, x)
    factory = nil
    min_dist = 101 + 101

    bases.each do |base|
      next unless base.free?

      dist = (base.y - y).abs + (base.x - x).abs
      if dist < min_dist
        min_dist = dist
        factory = base
      end
    end

    factory
  end

  def nearest_battler_factory(y, x)
    factory = nil
    min_dist = 101 + 101

    bases.each do |base|
      dist = (base.y - y).abs + (base.x - x).abs
      if dist < min_dist
        min_dist = dist
        factory = base
      end
    end

    factory
  end

  def nearest_base(target)
    min_dist = 101 + 101
    nearest_base = nil

    bases.each do |base|
      dist = (target.y - base.y).abs + (target.x - base.x).abs
      if dist < min_dist
        min_dist = dist
        nearest_base = base
      end
    end

    [nearest_base, min_dist]
  end

  def expect_enemy_castle_position
    return enemy_castle if enemy_castle

    if expected_enemy_castle_positions.size > 0
      position = {y: 0, x: 0}
      expected_enemy_castle_positions.each do |pos|
        position[:y] += pos[:y]
        position[:x] += pos[:x]
      end
      position[:y] /= expected_enemy_castle_positions.size
      position[:x] /= expected_enemy_castle_positions.size

      range = 5
      (position[:y]+range).downto(position[:y]-range) do |py|
        (position[:x]+range).downto(position[:x]-range) do |px|
          next if py + px < 158 || py > 99 || px > 99

          cell = at(py, px)
          return cell unless cell.known
        end
      end
    end

    99.downto(60) do |py|
      99.downto(60) do |px|
        next if py + px < 158

        cell = at(py, px)
        return cell unless cell.known
      end
    end

    STDERR.puts "nil??????"
    return at((rand * 40).floor + 60, (rand * 40).floor + 60) # FIXME
  end

  def update_unknown_cells
    self.unknown_cells = unknown_cells.reject(&:known)
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
      Base.inc_count if unit.base?
    end

    cell = at(unit.y, unit.x)
    cell.units << unit

    show(unit, true)

    unit
  end

  def show(unit, update_known, update_unknown_list = false)
    (-unit.sight).upto(unit.sight) do |dy|
       (-(unit.sight - dy.abs)).upto(unit.sight - dy.abs) do |dx|
         y = unit.y + dy
         x = unit.x + dx
         at(y, x).known = true if update_known && y >= 0 && x >= 0 && y < 100 && x < 100

         self.unknown_cells.delete(at(y, x)) if update_unknown_list
       end
    end
  end

  def danger_castle?
    enemies.any? do |enemy|
      dist = (enemy.y - castle.y).abs + (enemy.x - castle.x).abs

      dist <= 1
    end
  end

  def add_enemy(unit)
    self.enemies << unit unless unit.castle? && enemy_castle
    self.map[unit.y][unit.x].enemies << unit

    unit
  end

  def near_villages(y, x, range = 10)
    villages.select { |v| (v.y-y).abs + (v.x-x).abs < range }
  end

  def near_resources(y, x, range = 30)
    resources.select { |v| (v.y-y).abs + (v.x-x).abs < range }
  end

  def nearest_unexists_enemy_resource(from)
    nearest_resource = nil
    min_dist = 101 + 101

    resources.each do |resource|
      cell = at(resource.y, resource.x)
      next if resource.exists_enemy

      dist = (from.x - resource.x).abs + (from.y - resource.y).abs
      if min_dist > dist
        min_dist = dist
        nearest_resource = resource
      end
    end

    [nearest_resource, min_dist]
  end

  def enemy_resources
    resources.select { |r| r.exists_enemy }
  end

  def nearest_exists_enemy_resource(from)
    nearest_resource = nil
    min_dist = 101 + 101

    resources.each do |resource|
      cell = at(resource.y, resource.x)
      next if !resource.exists_enemy && resource.exists_unit

      dist = (from.x - resource.x).abs + (from.y - resource.y).abs
      if min_dist > dist
        min_dist = dist
        nearest_resource = resource
      end
    end

    nearest_resource
  end

  def sight?(y, x)
    units.any? do |unit|
      unit.sight?(y, x)
    end
  end

  def farest_worker
    max_dist = 0
    worker = nil
    workers.each do |w|
      dist = w.x + w.y
      if dist > max_dist
        worker = w
        max_dist = dist
      end
    end

    worker
  end

  def free_worker_wishes
    return [] if workers.size >= 100 || resources.size >= 20

    max_x = 0
    max_y = 0
    max_x_village = nil
    max_y_village = nil
    wishes = []

    villages.each do |village|
      if village.x > max_x
        max_x = village.x
        max_x_village = village
      end

      if village.y > max_y
        max_y = village.y
        max_y_village = village
      end
    end

    wishes << Wish.new(:create_worker, Worker::RESOURCE, max_x_village.y, max_x_village.x, 9, max_x_village) if max_x_village
    wishes << Wish.new(:create_worker, Worker::RESOURCE, max_y_village.y, max_y_village.x, 9, max_y_village) if max_y_village

    wishes
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

    groups.clean(dead_units)
    groups.clean_destroyed_group
  end

  def add_resource(resource)
    cell = at(resource.y, resource.x)
    return false if cell.resource

    self.resources << resource
    at(resource.y, resource.x).resource = resource
    resource
  end
end
