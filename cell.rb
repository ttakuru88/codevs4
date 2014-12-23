class Cell
  attr_accessor :units, :enemies, :resources

  def initialize
    self.units = []
    self.enemies = []
    self.resources = []
  end
end
