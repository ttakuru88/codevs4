class Cell
  attr_accessor :units, :enemies, :resources, :known, :x, :y

  def initialize(y, x)
    self.units = []
    self.enemies = []
    self.resources = []
    self.known = false
    self.y = y
    self.x = x
  end

  def turn_init
    self.units = []
    self.enemies = []
  end

  def noguard_resources
    resources.select { |r| !r.guardian }
  end

  def workers
    units.select { |u| u.instance_of?(Worker) }
  end

  def waiting_capturers
    units.select { |u| u.waiting? && u.capturer }
  end

  def neet_workers
    workers.select { |u| !u.work_id }
  end

  def battlers
    units.select { |u| u.instance_of?(Fighter) || u.instance_of?(Knight) || u.instance_of?(Assassin) }
  end

  def castle
    units.find { |u| u.instance_of?(Castle) }
  end

  def enemy_castle
    enemies.find { |u| u.instance_of?(Castle) }
  end

  def villages
    units.select { |u| u.instance_of?(Village) }
  end

  def active_units
    units.select { |u| u.action != :none }
  end

  def bases
    units.select { |u| u.instance_of?(Base) }
  end
end
