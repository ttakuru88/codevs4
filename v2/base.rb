class Base < Unit
  RESOURCE = 500.freeze

  attr_accessor :action_type, :created_groups_count

  @@bases_count = nil

  ACTION_TYPES = [:quick, :charge, :defense]

  def initialize(data)
    super

    action_index = self.class.bases_count
    action_index = 1 if action_index >= 3

    self.action_type = ACTION_TYPES[action_index]
    self.created_groups_count = 0

    self.class.inc_count
  end

  def self.bases_count
    @@bases_count
  end

  def self.reset_count
    @@bases_count = 0
  end

  def self.inc_count
    @@bases_count += 1
  end

  def self.wishes(map, resources_rest, turn)
    return [] if map.bases.size >= 2 && resources_rest < RESOURCE
    return [] if map.bases.size >= 3

    wish_list = []

    if map.bases.size == 1
      worker, min_dist = map.nearest_worker(map.at(99, 99))
      if worker
        wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 7, worker)
      end
    elsif map.bases.size == 2
      worker, min_dist = map.nearest_worker(map.at(50, 50))
      if worker
        wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 7, worker)
      end
    else
      worker, min_dist = map.nearest_worker(map.expect_enemy_castle_position)
      if worker && (min_dist <= 30 || map.expected_enemy_castle_positions.size > 0)
        wish_list << Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 7, worker)
      end
    end

    wish_list
  end
end
