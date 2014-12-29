class Base < Unit
  RESOURCE = 500.freeze

  def self.wishes(map)
    return [] if map.bases.size >= 2

    wish_list = []

    worker = map.farest_worker
    if worker && worker.y + worker.x > 160
      wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 9 + map.bases.size * 2, worker)
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
