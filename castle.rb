class Castle < Unit
  SIGHT = 10.freeze

  def think(map, work_manager)
    if work_manager.primary_work
      self.action = :create_worker
    else
      self.action = :create_base
    end
  end
end
