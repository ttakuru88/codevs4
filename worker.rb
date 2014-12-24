class Worker < Unit
  RESOURCE = 40.freeze

  def think(map, index)
    if index < 12
      to_x = 100
      to_y = index % 12 * 9

      move_to(to_y, to_x)
    else
      target_resource = map.resources[index - 12]

      if target_resource
        if move_to(target_resource.y, target_resource.x)
          if map.at(y, x).villages.size <= 0
            self.action = :create_village
          elsif map.at(y, x).bases.size <= 0
            self.action = :create_base
          end
        end
      end
    end
  end

  def move_to(to_y, to_x)
    if y < to_y
      self.action = :down
    elsif y > to_y
      self.action = :up
    elsif x < to_x
      self.action = :right
    elsif x > to_x
      self.action = :left
    else
      return true
    end

    return false
  end
end
