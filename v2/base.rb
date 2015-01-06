class Base < Unit
  RESOURCE = 500.freeze

  def self.wishes(map, resources_rest, turn)
    return [] if map.bases.size >= 2 && resources_rest < RESOURCE
    return [] if map.bases.size >= 3

    wish_list = []

    if map.bases.size == 1
      worker, min_dist = map.nearest_worker(map.at(99, 99))
      if worker
        wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 7, worker)
      end
    elsif map.bases.size == 2
      worker, min_dist = map.nearest_worker(map.at(50, 50))
      if worker
        wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 7, worker)
      end
    else
      worker, min_dist = map.nearest_worker(map.expect_enemy_castle_position)
      if worker && (min_dist <= 30 || map.expected_enemy_castle_positions.size > 0)
        wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 7, worker)
      end
    end

    wish_list
  end
end
