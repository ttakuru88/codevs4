class Resource
  attr_accessor :y, :x, :exists_enemy, :guardian, :require_worker, :reserved_worker, :exists_unit, :exists_guardian

  def self.load(input)
    data = input.split(' ').map(&:to_i)

    new(data)
  end

  def initialize(data)
    self.y = data[0]
    self.x = data[1]
    self.exists_enemy = false
    self.exists_unit  = false
    self.exists_guardian = false
    self.guardian = false
    self.require_worker = 0
    self.reserved_worker = 0
  end

  def inverse
    self.x = (x - 99).abs
    self.y = (y - 99).abs
  end
end
