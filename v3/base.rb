class Base < Unit
  RESOURCE = 500.freeze
  MAX_HP = 20000.0

  attr_accessor :action_type, :created_groups_count, :dead_groups_count

  @@bases_count = nil

  ACTION_TYPES = [:quick, :charge, :defense]

  def initialize(data)
    super

    action_index = self.class.bases_count
    action_index = 1 if action_index >= 3

    self.action_type = ACTION_TYPES[action_index]
    self.created_groups_count = 0
    self.dead_groups_count = 0
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
    return [] if map.bases.size < 1 && map.benefit_resources < 30
    return [] if map.bases.size > 1 && (resources_rest < RESOURCE || map.bases.size >= Settings::BASE_MAX)

    if map.defenser_bases.size > 0 && map.attacker_bases.size <= 0
      worker, min_dist = map.nearest_worker(map.at(99, 99))
      if worker && min_dist <= 60
        return [Wish.new(:create_base, Base::RESOURCE, worker.y, worker.x, 6, worker)]
      end
    end

    if map.defenser_bases.size <= 0 || map.attacker_bases.size > 0
      worker, min_dist = map.nearest_worker(map.castle)
      if min_dist < 6
        return [Wish.new(:create_base, Base::RESOURCE, map.castle.y, map.castle.x, 6, worker)]
      else
        map.groups.create(:base_creator, 7, {worker: 1}, [{y: map.castle.y, x: map.castle.x}])
      end
    end

    []
  end
end
