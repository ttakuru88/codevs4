class Worker < Unit
  RESOURCE = 40.freeze

  def think(map, index)
    to_x = 100
    to_y = index % 12 * 9

    if y < to_y
      self.action = :down
    elsif y > to_y
      self.action = :up
    elsif x < to_x
      self.action = :right
    elsif x > to_x
      self.action = :left
    end
  end
end
