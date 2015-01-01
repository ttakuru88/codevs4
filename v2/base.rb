class Base < Unit
  RESOURCE = 500.freeze

  def self.wishes(map, resources_rest, turn)
    return [] if map.bases.size >= 2 && resources_rest < RESOURCE

    wish_list = []

    worker, min_dist = map.nearest_worker(map.expect_enemy_castle_position)
    if worker && min_dist <= 40
      nearest_base, base_dist = map.nearest_base(map.castle)

      if nearest_base && base_dist >= 100 && turn > 200
        worker, min_dist = map.nearest_worker(map.castle)
        if worker
          wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 6, worker)
        else
          wish_list << Wish.new(:create_worker, Worker::RESOURCE, map.castle.y, map.castle.x, 6, map.castle)
        end
      elsif min_dist >= 10
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
