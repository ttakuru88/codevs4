class Worker < Unit
  RESOURCE = 40.freeze

  def think
    self.action = :right
  end
end
