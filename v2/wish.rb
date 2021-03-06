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

  def realize(map, resources_rest, turn)
    send(type.to_s, map, resources_rest, turn)
  end

  private

  def create_worker(map, resources_rest, turn)
    return if map.bases.size > 0

    near_worker_factory = map.near_worker_factory(y, x)
    if near_worker_factory
      if unit.in_resource? && map.at(unit.y, unit.x).resources[0].exists_enemy
        false
      else
        near_worker_factory.create_worker
        true
      end
    else
      false
    end
  end

  def create_knight(map, resources_rest, turn)
    near_factory = map.near_battler_factory(y, x)
    if near_factory
      near_factory.create_knight
      true
    else
      false
    end
  end

  def create_fighter(map, resources_rest, turn)
    near_factory = map.near_battler_factory(y, x)
    if near_factory
      near_factory.create_fighter
      true
    else
      false
    end
  end

  def create_assassin(map, resources_rest, turn)
    near_factory = map.near_battler_factory(y, x)
    if near_factory
      near_factory.create_assassin
      true
    else
      false
    end
  end

  def create_village(map, resources_rest, turn)
    unit.create_village
  end

  def create_base(map, resources_rest, turn)
    unit.create_base
  end
end
