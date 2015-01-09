class Cell < UnitTank
  attr_accessor :resources, :known, :groups

  def initialize(y, x)
    super

    self.resources = []
    self.known     = false
    self.groups    = []
  end

  def turn_init
    self.units = []
    self.enemies = []
    self.groups = []
  end

  def noguard_resources
    resources.select { |r| !r.guardian }
  end

  def battler_groups
    groups.select { |g| g.include_battler? }
  end
end
