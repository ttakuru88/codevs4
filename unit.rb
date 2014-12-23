class Unit
  attr_accessor :id, :y, :x, :hp, :enemy

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
  end

  def sight
    SIGHT
  end
end
