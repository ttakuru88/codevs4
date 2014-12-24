class Village < Unit
  SIGHT = 10.freeze
  RESOURCE = 100.freeze

  def think(map)
    if map.at(y, x).workers.size < 5
      self.action = :create_worker
    end
  end
end
