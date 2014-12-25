class Castle < Unit
  SIGHT = 10.freeze

  def castle?
    true
  end

  def think(map, work_manager, all_resouces)
    if work_manager.primary_work && all_resouces >= Worker::RESOURCE
      self.action = :create_worker
    end
  end
end
