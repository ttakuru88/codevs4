class Base < Unit
  RESOURCE = 500.freeze

  def think(map)
    if map.at(y, x).units.size < 16
      self.action = [:create_assassin, :create_fighter, :create_knight].sample
    end
  end
end
