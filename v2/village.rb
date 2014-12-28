class Village < Unit
  SIGHT = 10.freeze
  RESOURCE = 100.freeze

  def self.wishes(map)
    wish_list = []
    map.workers.each do |worker|
      if worker.build_village?(map)
        wish_list << Wish.new(:create_village, Village::RESOURCE, worker.y, worker.x, 8, worker)
        map.units << Village.new([nil, worker.y, worker.x, 1])
      end
    end

    wish_list
  end

  def think(map, all_resources)
    if map.at(y, x).workers.size < 5 && all_resources >= Worker::RESOURCE
      self.action = :create_worker
    end
  end
end
