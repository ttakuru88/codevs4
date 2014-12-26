class Work
  attr_accessor :id, :do, :done, :tasks, :primary, :typical_x, :typical_y

  def initialize(id, primary, tasks)
    self.id      = id
    self.tasks   = tasks
    self.primary = primary
    self.do      = false
    self.done    = false

    tasks.each do |task|
      if task[:type] == :move
        self.typical_x = task[:x]
        self.typical_y = task[:y]
      end
    end
  end

  def done!
    self.do = false
    self.done = true
  end
end
