class Cell < UnitTank
  attr_accessor :resources, :known

  def initialize(y, x)
    super

    self.resources = []
    self.known = false
  end

  def turn_init
    self.units = []
    self.enemies = []
  end

  def noguard_resources
    resources.select { |r| !r.guardian }
  end
end
