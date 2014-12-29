class Group < UnitTank
  attr_accessor :require_units, :points, :next_point_index, :primary, :active

  def initialize(primary, require_units, points)
    super(points[0][:y], points[0][:x])

    self.require_units     = require_units
    self.points            = points
    self.next_point_index  = 0
    self.primary           = primary
    self.active            = false
  end

  def finished?
    !next_point
  end

  def include_battler?
    require_units.include?(:fighter) || require_units.include?(:knight) || require_units.include?(:assassin)
  end

  def move(map)
    if required_units?(map) && !finished?
      to_x = to_y = nil
      if next_point[:enemy_castle]
        enemy_castle = map.expect_enemy_castle_position
        to_y = enemy_castle.y
        to_x = enemy_castle.x
      else
        to_y = next_point[:y]
        to_x = next_point[:x]
      end

      self.active = true
      if move_to(to_y, to_x)
        self.next_point_index += 1
      end
    end

    units.each do |unit|
      unit.move_to(y, x)
    end
  end

  def full_units?(unit)
    require_unit = require_units.find { |unit_type, data| unit_type == unit.to_sym }
    return true unless require_unit

    require_unit[1].max <= send("#{unit.to_sym}s").size
  end

  def required_units?(map)
    cell = map.at(y, x)
    require_units.all? do |unit_type, require_data|
      units_method = "#{unit_type}s"
      require_data.min <= (send(units_method) & cell.send(units_method)).size
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
      units_method = "#{unit_type}s"
      cost = instance_eval("#{unit_type.to_s[0].upcase}#{unit_type.to_s[1..-1]}")::RESOURCE
      if require_data.max > send(units_method).size
        wish_list << Wish.new("create_#{unit_type}".to_sym, cost, y, x, primary, self)
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
