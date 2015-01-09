class Map < Cell
  attr_accessor :map, :expected_enemy_castle_positions, :many_attacker_near_enemy_castle, :inverse, :groups

  def turn_init
    self.enemies = [enemy_castle].compact

    self.units.each do |unit|
      unit.die = true
      unit.update_prev_position
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

    self.expected_enemy_castle_positions = []
    self.many_attacker_near_enemy_castle = false
    self.inverse = false
    self.groups = GroupList.new
  end

  def at(y, x)
    map[y][x]
  end

  def benefit_resources
    resources.reduce(10) do |sum, resource|
      sum += at(resource.y, resource.x).workers.size
    end
  end

  def enemy_castle_safety?
    enemy_castle && sight?(enemy_castle.y, enemy_castle.x) && !exists_enemy_battler?(enemy_castle)
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

  def set_groups
    groups.groups.each do |group|
      map[group.y][group.x].groups << group
    end
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

  def near_battler_factory(y, x)
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

    (-unit.sight).upto(unit.sight) do |dy|
       (-(unit.sight - dy.abs)).upto(unit.sight - dy.abs) do |dx|
         y = unit.y + dy
         x = unit.x + dx
         at(y, x).known = true if y >= 0 && x >= 0 && y < 100 && x < 100
       end
    end

    unit
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

  def near_villages(y, x, range = 50)
    villages.select { |v| (v.y-y).abs + (v.x-x).abs < range }
  end

  def near_resources(y, x, range = 30)
    resources.select { |v| (v.y-y).abs + (v.x-x).abs < range }
  end

  def nearest_unguard_resource(from)
    nearest_resource = nil
    min_dist = 101 + 101

    unguard_resources.each do |resource|
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

  def unguard_resources
    resources.reject(&:exists_guardian)
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
