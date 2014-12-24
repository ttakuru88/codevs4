class Castle < Unit
  SIGHT = 10.freeze

  def think(map)
    if map.workers.size < 30
      self.action = :create_worker
    end
  end
end
