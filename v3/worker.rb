class Worker < Unit
  RESOURCE = 40.freeze

  def think(map, turn, resources_rest)
    if turn < 10
      to_x = id % 4 <= 1 ? 0 : 99
      to_y = id % 4 % 2 == 0 ? 0 : 99
      move_to(to_y, to_x, map)
    else
      cell = map.nearest_unknown_cell(self)
      if cell
        move_to!(cell.y, cell.x, map)
      end
    end
  end

  def move_to(to_y, to_x, map = nil)
    dy = nil
    dx = nil

    action_y = [:down, :up]
    action_x = [:right, :left]

    if y < to_y
      dy = 1
    elsif y > to_y
      dy = -1
    end

    if x < to_x
      dx = 1
    elsif x > to_x
      dx = -1
    end

    if dy.nil? && dx.nil?
      return true
    end

    if dy.nil?
      self.action = action_x[dx > 0 ? 0 : 1]
    elsif dx.nil?
      self.action = action_y[dy > 0 ? 0 : 1]
    else
      y_enemies = 0
      x_enemies = 0

      1.upto(4) do |i|
        my = y + i * dy
        y_enemies += map.at(my, x).enemies.size if my >= 0 && my < 100

        mx = x + i * dx
        x_enemies += map.at(y, mx).enemies.size if mx >= 0 && mx < 100
      end

      if y_enemies > x_enemies
        self.action = action_x[dx > 0 ? 0 : 1]
      elsif x_enemies > y_enemies
        self.action = action_y[dy > 0 ? 0 : 1]
      else
        if rand < 0.5
          self.action = action_x[dx > 0 ? 0 : 1]
        else
          self.action = action_y[dy > 0 ? 0 : 1]
        end
      end
    end

    return false
  end
end
