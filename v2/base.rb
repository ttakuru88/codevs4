class Base < Unit
  RESOURCE = 500.freeze

  def self.wishes(map, resources_rest, turn)
    return [] if map.bases.size >= 2 && resources_rest < RESOURCE

    wish_list = []

    if map.bases.size == 1
      if turn > 250
        worker, min_dist = map.nearest_worker(map.at(50, 50))
        if worker
          wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 7, worker)
        end
      end
    else
      worker, min_dist = map.nearest_worker(map.expect_enemy_castle_position)
      if worker && min_dist <= 40
        wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 7, worker)
      end
    end

    wish_list
  end
end
