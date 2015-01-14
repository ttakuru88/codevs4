class UnitTank
  attr_accessor :units, :enemies, :x, :y

  def initialize(y, x)
    self.units = []
    self.enemies = []
    self.y = y
    self.x = x
  end

  def workers
    units.select(&:worker?)
  end

  def standalone_workers
    units.select { |u| u.worker? && u.standalone? }
  end

  def fighters
    units.select(&:fighter?)
  end

  def knights
    units.select(&:knight?)
  end

  def assassins
    units.select(&:assassin?)
  end

  def standalones
    units.select { |u| (u.worker? || u.knight? || u.fighter? || u.assassin?) && u.standalone? }
  end

  def battlers
    units.select { |u| u.fighter? || u.knight? || u.assassin? }
  end

  def enemy_battlers
    enemies.select { |u| u.fighter? || u.knight? || u.assassin? }
  end

  def castle
    @castle ||= units.find(&:castle?)
  end

  def enemy_castle
    @enemy_castle ||= enemies.find(&:castle?)
  end

  def villages
    units.select(&:village?)
  end

  def worker_factories
    [castle] + villages
  end

  def active_units
    units.select { |u| u.id && u.action != :none }
  end

  def bases
    units.select(&:base?)
  end

  def defenser_bases
    bases.select { |base| base.y + base.x < 50 }
  end

  def attacker_bases
    bases.select { |base| base.y + base.x > 50 }
  end
end
