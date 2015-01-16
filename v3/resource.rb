class Resource
  attr_accessor :y, :x, :exists_enemy, :exists_enemy_battler, :exists_unit

  def self.load(input)
    data = input.split(' ').map(&:to_i)

    new(data)
  end

  def initialize(data)
    self.y = data[0]
    self.x = data[1]
    self.exists_enemy = false
    self.exists_enemy_battler = false
    self.exists_unit  = false
  end

  def inverse
    self.x = (x - 99).abs
    self.y = (y - 99).abs
  end
end
