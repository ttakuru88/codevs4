class Battler < Unit
  attr_accessor :capturer

  def initialize(data, enemy)
    super

    self.capturer = rand < 0.3
  end

  def think(map, battler_work)
    if capturer
      unless work_id
        work = battler_work.primary_work

        if work
          work.do = true
          self.work_id = work.id
          self.tasks = work.tasks.clone
        end
      end

      if work_id
        task = tasks[0]
        if task[:type] == :move
          if move_to(task[:y], task[:x])
            if finish_task
              finish_work(battler_work)
            end
          end
        else task[:type] == :wait
          # wait
        end

        return
      end
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
