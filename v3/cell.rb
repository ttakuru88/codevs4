class Cell < UnitTank
  attr_accessor :resource, :known

  def initialize(y, x)
    super

    self.resource = nil
    self.known    = false
  end

  def turn_init
    self.units = []
    self.enemies = []
  end
end
