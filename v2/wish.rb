class Wish
  attr_accessor :type, :cost, :y, :x, :primary, :unit

  def initialize(type, cost, y, x, primary, unit = nil)
    self.type = type
    self.cost = cost
    self.y = y
    self.x = x
    self.primary = primary
    self.unit = unit
  end

  def realize(map)
    send(type.to_s, map)
  end

  private

  def create_worker(map)
    near_worker_factory = map.near_worker_factory(y, x)
    if near_worker_factory
      near_worker_factory.create_worker
      unit.creating_worker += 1
      true
    else
      false
    end
  end

  def create_knight(map)
    near_factory = map.near_battler_factory(y, x)
    if near_factory
      near_factory.create_knight
      unit.creating_knight += 1
      true
    else
      false
    end
  end

  def create_fighter(map)
    near_factory = map.near_battler_factory(y, x)
    if near_factory
      near_factory.create_fighter
      unit.creating_fighter += 1
      true
    else
      false
    end
  end

  def create_assassin(map)
    near_factory = map.near_battler_factory(y, x)
    if near_factory
      near_factory.create_assassin
      unit.creating_assassin += 1
      true
    else
      false
    end
  end

  def create_village(map)
    unit.create_village
  end

  def create_base(map)
    unit.create_base
  end
end
