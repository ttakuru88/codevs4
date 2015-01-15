class Castle < Unit
  SIGHT = 10.freeze
  ATTACK_RANGE = 10.freeze

  def wishes(map, turn, resources_rest)
    wish_lists = []

    if map.villages.size <= 0
      wish_lists << Wish.new(:create_worker, Worker::RESOURCE, y, x, 9, self)
    end

    wish_lists
  end
end
