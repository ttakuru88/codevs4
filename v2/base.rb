class Base < Unit
  RESOURCE = 500.freeze

  def self.wishes(map)
    return [] if map.bases.size >= 1

    wish_list = []

    worker, min_dist = map.nearest_enemy_castle_worker
    STDERR.puts min_dist
    if worker && min_dist < 20
      wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 9, worker)
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
