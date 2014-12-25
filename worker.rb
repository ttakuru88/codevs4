class Worker < Unit
  RESOURCE = 40.freeze

  attr_accessor :work_id, :tasks

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
        if map.at(y, x).villages.size > 0
          finish_work(work_manager) if finish_task
        else
          self.action = :create_village
        end
      end
    end
  end

  def create_base(map)
    if map.at(y, x).bases.size <= 0
      self.action = :create_base
    end
  end

  def finish_work(work_manager)
    work_manager.find(work_id).done!
    self.work_id = nil
  end

  def finish_task
    self.tasks.shift

    tasks.length <= 0
  end
end
