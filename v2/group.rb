class Group < UnitTank
  attr_accessor :id, :require_units, :points, :next_point_index, :primary, :active

  def initialize(primary, require_units, points, id)
    super(points[0][:y], points[0][:x])

    self.require_units     = require_units
    self.points            = points
    self.next_point_index  = 0
    self.primary           = primary
    self.active            = false
    self.id                = id
  end

  def finished?
    !next_point
  end

  def attacker?
    include_battler? && x + y > 100
  end

  def include_battler?
    require_units.include?(:fighter) || require_units.include?(:knight) || require_units.include?(:assassin)
  end

  DP = [
    {x: -6, y: -6},
    {x:  6, y: -6},
    {x: -6, y:  6},
    {x:  6, y:  6}
  ]

  MDP = [
#    {x: -1, y: -1},
    {x:  0, y: -1},
#    {x:  1, y: -1},
    {x: -1, y:  0},
    {x:  0, y:  0},
    {x:  1, y:  0},
#    {x: -1, y:  1},
    {x:  0, y:  1},
#    {x:  1, y:  1},
  ]

  DDP = [
    {x:  0, y:  0},
    {x: -1, y:  0},
    {x:  1, y:  0},
    {x:  0, y: -1},
    {x: -1, y: -1},
    {x:  1, y: -1},
    {x:  0, y:  1},
    {x: -1, y:  1},
    {x:  1, y:  1},
  ]

  def move(map)
    if (active || required_units?) && next_point
      to_x = to_y = nil
      if next_point[:enemy_resource]
        resource = map.nearest_unguard_resource(self)
        if resource
          points.insert(next_point_index, {x: resource.x, y: resource.y, wait: true})
          resource.exists_guardian = true
        else
          points.insert(next_point_index, {enemy_castle: true})
        end
      end

      if next_point[:enemy_castle]
        enemy_castle = map.expect_enemy_castle_position
        to_y = enemy_castle.y
        to_x = enemy_castle.x
      elsif next_point[:near_castle]
        to_y = map.castle.y + MDP[id % MDP.size][:y]
        to_x = map.castle.x + MDP[id % MDP.size][:x]
      elsif next_point[:near_enemy_castle]
        enemy_castle = map.expect_enemy_castle_position
        if enemy_castle
          to_y = enemy_castle.y + DP[id % DP.size][:x]
          to_x = enemy_castle.x + DP[id % DP.size][:y]
        else
          to_y = y
          to_x = x
        end
      else
        to_y = next_point[:y]
        to_x = next_point[:x]
      end

      self.active = true

      to_y = 99 if to_y > 99
      to_x = 99 if to_x > 99
      to_y = 0 if to_y < 0
      to_x = 0 if to_x < 0
      if move_to(to_y, to_x, map)
        self.next_point_index += 1
      end
    end

    units.each do |unit|
      if !unit.fixed_position?
        dp = DDP.find do |dp|
          dx = x + dp[:x]
          dy = y + dp[:y]
          dx < 100 && dy < 100 && dx >= 0 && dy >= 0 && at_units(dy, dx).size < 10
        end

        dp ||= DDP[0]

        unit.dx = dp[:x]
        unit.dy = dp[:y]
      end

      unit.move_to!(y, x, map)
    end
  end

  def at_units(on_y, on_x)
    units.select do |unit|
      unit.y == on_y && unit.x == on_x
    end
  end

  def full_units?(unit)
    require_unit = require_units.find { |unit_type, data| unit_type == unit.to_sym }
    return true unless require_unit

    require_unit[1] <= send("#{unit.to_sym}s").size
  end

  def required_units?
    require_units.all? do |unit_type, require_data|
      units_method = "#{unit_type}s"
      require_data <= send(units_method).size
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
      if require_data > send(units_method).size
        wish_list << Wish.new("create_#{unit_type}".to_sym, cost, y, x, primary, self)
      end
    end

    wish_list
  end

  def in_resource?
    !!(next_point && next_point[:resource])
  end

  private

  def move_to(to_y, to_x, map)
    dy = nil
    dx = nil

    if y < to_y
      dy = 1
    elsif y > to_y
      dy = -1
    end

    if x < to_x
      dx = 1
    elsif x > to_x
      dx = -1
    end

    if dy.nil? && dx.nil?
      return !next_point[:wait]
    end

    if dy.nil?
      self.x += dx
    elsif dx.nil?
      self.y += dy
    else
      y_enemies = 0
      x_enemies = 0

      1.upto(4) do |i|
        my = y + i * dy
        y_enemies += map.at(my, x).enemies.size if my >= 0 && my < 100

        mx = x + i * dx
        x_enemies += map.at(y, mx).enemies.size if mx >= 0 && mx < 100
      end

      if y_enemies > x_enemies
        self.x += dx
      elsif x_enemies > y_enemies
        self.y += dy
      else
        if rand < 0.5
          self.x += dx
        else
          self.y += dy
        end
      end
    end

    return false
  end
end
