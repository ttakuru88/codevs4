class Unit
  attr_accessor :id, :y, :x, :hp, :enemy, :action, :die, :work_id, :tasks, :capturer, :group, :dx, :dy, :prev_hp, :prev_y, :prev_x, :prev

  # 0: worker
  # 1: knight
  # 2: fighter
  # 3: assassin
  # 4: castle
  # 5: village
  # 6: base
  UNITS = %w(Worker Knight Fighter Assassin Castle Village Base).freeze
  SIGHT = 4.freeze
  ATTACK_RANGE = 2.freeze
  RESOURCE = nil.freeze
  ACTIONS = {none: -1, up: 'U', down: 'D', left: 'L', right: 'R', create_worker: 0, create_knight: 1, create_fighter: 2, create_assassin: 3, create_village: 5, create_base: 6}.freeze

  DAMAGES = [
    [ 100,  100,  100, 100, 100, 100, 100],
    [ 100,  500,  200, 200, 200, 200, 200],
    [ 500, 1600,  500, 200, 200, 200, 200],
    [1000,  500, 1000, 500, 200, 200, 200],
    [ 100,  100,  100, 100, 100, 100, 100],
    [ 100,  100,  100, 100, 100, 100, 100],
    [ 100,  100,  100, 100, 100, 100, 100],
  ]

  def self.load(input)
    unit = load(input)
    unit.enemy = false
    unit
  end

  def self.load_enemy(input)
    unit = load(input)
    unit.enemy = true
    unit
  end

  def free?
    action == :none
  end

  def damage(map, units)
    dmg = 0
    units.each do |unit|
      unit_damage = DAMAGES[UNITS.index(unit.class.to_s)][UNITS.index(self.class.to_s)]
      k = map.calc_k(unit)
      dmg += (unit_damage / k.to_f).floor if k > 0
    end

    dmg
  end

  def to_sym
    self.class.to_s.downcase.to_sym
  end

  def sight?(target_y, target_x)
    (x - target_x).abs + (y - target_y).abs <= sight
  end

  def self.load(input)
    data = input.split(' ').map(&:to_i)

    instance_eval(UNITS[data[4]]).new(data)
  end

  def initialize(data)
    self.id = data[0]
    self.y  = data[1]
    self.x  = data[2]
    self.hp = data[3]
    self.dx = nil
    self.dy = nil
    self.action = :none
    self.die = false
    self.tasks = []
    self.capturer = false
    self.prev_hp = nil
    self.prev = false
  end

  def fixed_position?
    !dx.nil? && !dy.nil?
  end

  def dead
    # on dead
  end

  def action_number(map)
    if map.inverse
      if action == :up
        self.action = :down
      elsif action == :down
        self.action = :up
      elsif action == :right
        self.action = :left
      elsif action == :left
        self.action = :right
      end
    end

    ACTIONS[action]
  end

  def create_worker
    return if action != :none

    self.action = :create_worker
  end

  def create_village
    self.action = :create_village
  end

  def create_base
    self.action = :create_base
  end

  def create_fighter
    return if action != :none

    self.action = :create_fighter
  end

  def create_knight
    return if action != :none

    self.action = :create_knight
  end

  def create_assassin
    return if action != :none

    self.action = :create_assassin
  end

  def move_to(to_y, to_x, map = nil)
    if y < to_y
      self.action = :down
    elsif y > to_y
      self.action = :up
    elsif x < to_x
      self.action = :right
    elsif x > to_x
      self.action = :left
    else
      return true
    end

    return false
  end

  ESCAPE_DIST = 1

  def update_prev_position
    self.prev_y = y
    self.prev_x = x

    if action == :up
      self.prev_y += ESCAPE_DIST
    elsif action == :down
      self.prev_y -= ESCAPE_DIST
    elsif action == :right
      self.prev_x -= ESCAPE_DIST
    elsif action == :left
      self.prev_x += ESCAPE_DIST
    end
  end

  def move_to!(to_y, to_x, map = nil)
    to_y += dy.to_i
    to_x += dx.to_i

    ret = move_to(to_y, to_x, map)

    if action == :down
      self.y += 1
    elsif action == :up
      self.y -= 1
    elsif action == :right
      self.x += 1
    elsif action == :left
      self.x -= 1
    end

    ret
  end

  def sight
    SIGHT
  end

  def attack_range
    ATTACK_RANGE
  end

  def waiting?
    task = tasks[0]
    task && task[:type] == :wait
  end

  def inverse
    self.x = (x - 99).abs
    self.y = (y - 99).abs
  end

  def enemy?
    !!enemy
  end

  def castle?
    self.instance_of?(Castle)
  end

  def worker?
    self.instance_of?(Worker)
  end

  def fighter?
    self.instance_of?(Fighter)
  end

  def knight?
    self.instance_of?(Knight)
  end

  def assassin?
    self.instance_of?(Assassin)
  end

  def base?
    self.instance_of?(Base)
  end

  def battler?
    fighter? || knight? || assassin?
  end

  def finish_work(work_manager)
    work_manager.find(work_id).done!
    self.work_id = nil
  end

  def finish_task
    self.tasks.shift

    tasks.length <= 0
  end
end
