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
      if task[:type] == 'move'
        if move_to(task[:y], task[:x])
          if finish_task
            finish_work(work_manager)
          end
        end
      elsif task[:type] == 'create_village'
        self.action = :create_village
        finish_work(work_manager) if finish_task
      end
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
