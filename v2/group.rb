class Group < UnitTank
  attr_accessor :require_units, :points, :next_point_index, :primary, :creating_worker

  def initialize(primary, require_units, points)
    super(points[0][:y], points[0][:x])

    self.require_units    = require_units
    self.points           = points
    self.next_point_index = 0
    self.primary          = primary
    self.creating_worker  = 0
  end

  def finished?
    !next_point
  end

  def move(map)
    if required_units?(map) && !finished?
      if move_to(next_point[:y], next_point[:x])
        self.next_point_index += 1
      end
    end

    units.each do |unit|
      unit.move_to(y, x)
    end
  end

  def full_units?
    require_units.all? do |unit_type, require_data|
      if unit_type == :worker
        require_data.max <= workers.size
      end
    end
  end

  def required_units?(map)
    cell = map.at(y, x)
    require_units.all? do |unit_type, require_data|
      if unit_type == :worker
        require_data.min <= (workers & cell.workers).size
      end
    end
  end

  def next_point
    points[next_point_index]
  end

  def clean(clean_units)
    self.units -= clean_units
  end

  def wishes
    wish_list = []

    require_units.each do |unit_type, require_data|
      if unit_type == :worker
        if require_data.max > workers.size
          wish_list << Wish.new(:create_worker, Worker::RESOURCE, y, x, primary, self)
        end
      end
    end

    wish_list
  end

  private

  def move_to(to_y, to_x)
    if y < to_y
      self.y += 1
    elsif y > to_y
      self.y -= 1
    elsif x < to_x
      self.x += 1
    elsif x > to_x
      self.x -= 1
    else
      return !next_point[:wait]
    end

    return false
  end
end
