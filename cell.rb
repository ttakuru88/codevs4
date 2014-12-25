class Cell
  attr_accessor :units, :enemies, :resources

  def initialize
    self.units = []
    self.enemies = []
    self.resources = []
  end

  def workers
    self.units.select { |u| u.instance_of?(Worker) }
  end

  def neet_workers
    workers.select { |u| !u.work_id }
  end

  def castle
    self.units.find { |u| u.instance_of?(Castle) }
  end

  def villages
    self.units.select { |u| u.instance_of?(Village) }
  end

  def bases
    self.units.select { |u| u.instance_of?(Base) }
  end
end
