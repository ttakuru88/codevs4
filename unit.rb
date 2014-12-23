class Unit
  attr_accessor :id, :y, :x, :hp, :enemy, :action

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

  def self.load(input, enemy = false)
    data = input.split(' ').map(&:to_i)

    instance_eval(UNITS[data[4]]).new(data, enemy)
  end

  def initialize(data, enemy)
    self.id = data[0]
    self.y  = data[1]
    self.x  = data[2]
    self.hp = data[3]
    self.enemy = enemy
    self.action = :none
  end

  def action_number
    ACTIONS[action]
  end

  def think
  end

  def sight
    SIGHT
  end

  def enemy?
    !!enemy
  end
end
