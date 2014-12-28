class Wish
  attr_accessor :type, :cost, :y, :x, :primary

  def initialize(type, cost, y, x, primary)
    self.type = type
    self.cost = cost
    self.y = y
    self.x = x
    self.primary = primary
  end

  def realize(map)
    send(type.to_s, map)
  end

  private

  def create_worker(map)
    near_worker_factory = map.near_worker_factory(y, x)

    if near_worker_factory
      near_worker_factory.create_worker
      true
    else
      false
    end
  end
end