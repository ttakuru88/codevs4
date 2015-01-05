class Battler < Unit
  def initialize(data)
    super

    self.capturer = rand < 0.3
  end
end
