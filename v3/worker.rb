class Worker < Unit
  RESOURCE = 40.freeze

  def build_village?(map)
    near_resources = map.near_resources(y, x)
    return false if near_resources.size <= 0

    near_resources.all? do |resource|
      map.near_villages(resource.y, resource.x).size <= 0 && map.near_villages(y, x).size <= 0
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
