class Battler < Unit
  attr_accessor :capturer

  def initialize(data, enemy)
    super

    self.capturer = rand < 0.1
  end

  def think(map, work_manager)
    if capturer
      cell = map.at(y, x)
      if cell.resources.size > 0 && cell.battlers.size <= 10
        return
      end

      target_resource = map.near_exists_enemy_resource
      if target_resource
        move_to(target_resource.y, target_resource.x)
      end

      return
    end

    enemy_castle = map.enemy_castle

    if enemy_castle
      move_to(enemy_castle.y, enemy_castle.x)
    else
      cell = map.expect_enemy_castle_cell

      if cell
        move_to(cell.y, cell.x)
      else
        move_to(60 + (rand * 40).to_i, 60 + (rand * 40).to_i)
      end
    end
  end
end
