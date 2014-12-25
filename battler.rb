class Battler < Unit
  def think(map)
    enemy_castle = map.enemy_castle

    if enemy_castle
      move_to(enemy_castle.y, enemy_castle.x)
    else
      move_to(60 + (rand * 40).to_i, 60 + (rand * 40).to_i)
    end
  end
end
