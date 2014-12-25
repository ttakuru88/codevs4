class Cell
  attr_accessor :units, :enemies, :resources

  def initialize
    self.units = []
    self.enemies = []
    self.resources = []
  end

  def workers
    units.select { |u| u.instance_of?(Worker) }
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

  def bases
    units.select { |u| u.instance_of?(Base) }
  end
end
