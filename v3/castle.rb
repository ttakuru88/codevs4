class Castle < Unit
  SIGHT = 10.freeze
  ATTACK_RANGE = 10.freeze

  def wishes(map, turn, resources_rest)
    wish_lists = []

    if turn < 100 && map.workers.size < 100
      wish_lists << Wish.new(:create_worker, Worker::RESOURCE, y, x, 8, self)
    end

    wish_lists
  end
end
