class Worker < Unit
  RESOURCE = 40.freeze

  def think(map, work_manager)
    unless work_id
      work = work_manager.primary_work
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
            finish_work(work_manager)
          end
        end
      elsif task[:type] == :create_village
        near_village = nil
        map.villages.each do |village|
          if (x - village.x).abs + (y - village.y).abs < 25
            near_village = village
            break
          end
        end

        if near_village
          unless map.at(y, x).villages.include?(near_village)
            map.at(y, x).resources.each do |resource|
              resource.require_worker = 5
            end
          end

          finish_work(work_manager) if finish_task
        else
          self.action = :create_village
        end
      elsif task[:type] == :wait
        # wait
      end
    end
  end

  def create_base(map)
    if map.at(y, x).bases.size <= 0
      self.action = :create_base
    end
  end
end
