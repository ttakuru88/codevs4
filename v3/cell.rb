class Cell < UnitTank
  attr_accessor :resource, :known, :groups

  def initialize(y, x)
    super

    self.resource = nil
    self.known    = false
    self.groups   = []
  end

  def turn_init
    self.units = []
    self.enemies = []
    self.groups = []
  end

  def battler_groups
    groups.select { |g| g.include_battler? }
  end
end
