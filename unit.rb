class Unit
  attr_accessor :id, :y, :x, :hp

  # 0: worker
  # 1: knight
  # 2: fighter
  # 3: assassin
  # 4: castle
  # 5: village
  # 6: base
  UNITS = %w(Worker Knight Fighter Assassin Castle Village Base).freeze

  def self.load(input)
    data = input.split(' ').map(&:to_i)

    instance_eval(UNITS[data[4]]).new(data)
  end

  def initialize(data)
    self.id = data[0]
    self.y  = data[1]
    self.x  = data[2]
    self.hp = data[3]
  end
end
