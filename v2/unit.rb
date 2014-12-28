class Unit
  attr_accessor :id, :y, :x, :hp, :enemy, :action, :die, :work_id, :tasks, :capturer, :group

  # 0: worker
  # 1: knight
  # 2: fighter
  # 3: assassin
  # 4: castle
  # 5: village
  # 6: base
  UNITS = %w(Worker Knight Fighter Assassin Castle Village Base).freeze
  SIGHT = 4.freeze
  RESOURCE = nil.freeze
  ACTIONS = {none: -1, up: 'U', down: 'D', left: 'L', right: 'R', create_worker: 0, create_knight: 1, create_fighter: 2, create_assassin: 3, create_village: 5, create_base: 6}

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

  def self.load(input)
    data = input.split(' ').map(&:to_i)

    instance_eval(UNITS[data[4]]).new(data)
  end

  def initialize(data)
    self.id = data[0]
    self.y  = data[1]
    self.x  = data[2]
    self.hp = data[3]
    self.action = :none
    self.die = false
    self.tasks = []
    self.capturer = false
  end

  def dead
    # on dead
  end

  def action_number
    ACTIONS[action]
  end

  def think(map)
  end

  def create_worker
    self.action = :create_worker
  end

  def create_village
    self.action = :create_village
  end

  def create_base
    self.action = :create_base
  end

  def create_fighter
    self.action = :create_fighter
  end

  def create_knight
    self.action = :create_knight
  end

  def create_assassin
    self.action = :create_assassin
  end

  def move_to(to_y, to_x)
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

  def sight
    SIGHT
  end

  def waiting?
    task = tasks[0]
    task && task[:type] == :wait
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

  def finish_work(work_manager)
    work_manager.find(work_id).done!
    self.work_id = nil
  end

  def finish_task
    self.tasks.shift

    tasks.length <= 0
  end
end
