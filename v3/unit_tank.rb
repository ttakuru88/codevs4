class UnitTank
  attr_accessor :units, :enemies, :x, :y

  def initialize(y, x)
    self.units = []
    self.enemies = []
    self.y = y
    self.x = x
  end

  def workers
    units.select { |u| u.instance_of?(Worker) }
  end

  def fighters
    units.select { |u| u.instance_of?(Fighter) }
  end

  def knights
    units.select { |u| u.instance_of?(Knight) }
  end

  def assassins
    units.select { |u| u.instance_of?(Assassin) }
  end

  def standalones
    units.select { |u| (u.knight? || u.fighter? || u.assassin?) && !u.group }
  end

  def battlers
    units.select { |u| u.instance_of?(Fighter) || u.instance_of?(Knight) || u.instance_of?(Assassin) }
  end

  def enemy_battlers
    enemies.select { |u| u.instance_of?(Fighter) || u.instance_of?(Knight) || u.instance_of?(Assassin) }
  end

  def castle
    @castle ||= units.find { |u| u.instance_of?(Castle) }
  end

  def enemy_castle
    @enemy_castle ||= enemies.find { |u| u.instance_of?(Castle) }
  end

  def villages
    units.select { |u| u.instance_of?(Village) }
  end

  def worker_factories
    [castle] + villages
  end

  def active_units
    units.select { |u| u.id && u.action != :none }
  end

  def bases
    units.select { |u| u.instance_of?(Base) }
  end

  def defenser_bases
    bases.select { |base| base.y + base.x < 50 }
  end

  def attacker_bases
    bases.select { |base| base.y + base.x > 50 }
  end
end
