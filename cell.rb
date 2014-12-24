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

  def castle
    self.units.find { |u| u.instance_of?(Castle) }
  end
end
