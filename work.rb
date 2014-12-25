class Work
  attr_accessor :id, :do, :done, :tasks, :primary

  def initialize(id, primary, tasks)
    self.id      = id
    self.tasks   = tasks
    self.primary = primary
    self.do      = false
    self.done    = false
  end

  def done!
    self.do = false
    self.done = true
  end
end
