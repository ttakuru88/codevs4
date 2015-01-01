class Base < Unit
  RESOURCE = 500.freeze

  def self.wishes(map, resources_rest)
    return [] if map.bases.size >= 2 && resources_rest < RESOURCE

    wish_list = []

    if map.bases.size == 1
      worker, min_dist = map.nearest_worker(map.castle)
      if worker
        wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 8, worker)
      end
    else
      worker, min_dist = map.nearest_worker(map.expect_enemy_castle_position)
      if worker && min_dist < 20
        wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 8, worker)
      end
    end

    wish_list
  end

  def think(map, resources)
    unit = [Assassin, Fighter, Knight].sample
    if unit::RESOURCE <= resources
      self.action = "create_#{unit.to_s.downcase}".to_sym
    end
  end
end
