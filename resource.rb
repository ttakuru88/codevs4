class Resource
  attr_accessor :y, :x, :exists_enemy, :guardian

  def self.load(input)
    data = input.split(' ').map(&:to_i)

    new(data)
  end

  def initialize(data)
    self.y = data[0]
    self.x = data[1]
    self.exists_enemy = false
    self.guardian = false
  end
end
