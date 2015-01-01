class Base < Unit
  RESOURCE = 500.freeze

  def self.wishes(map, resources_rest, turn)
    return [] if map.bases.size >= 1 && resources_rest < RESOURCE

    wish_list = []

    worker, min_dist = map.nearest_worker(map.expect_enemy_castle_position)
    if worker && min_dist <= 40
      nearest_base, base_dist = map.nearest_base(map.castle)

      if min_dist >= 12
        wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 7, worker)
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
