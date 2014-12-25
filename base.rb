class Base < Unit
  RESOURCE = 500.freeze

  def think(map, resources)
    if map.at(y, x).units.size < 16
      unit = [Assassin, Fighter, Knight].sample
      if unit::RESOURCE <= resources
        self.action = "create_#{unit.to_s.downcase}".to_sym
      end
    end
  end
end
