class Village < Unit
  SIGHT = 10.freeze
  RESOURCE = 100.freeze

  def think(map, all_resources)
    if map.at(y, x).workers.size < 5 && all_resources >= Worker::RESOURCE
      self.action = :create_worker
    end
  end
end
