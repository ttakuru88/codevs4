module Settings
  QUICK_TURN = 275.freeze
end

%w(wish group_list work work_manager unit_tank group cell map resource unit battler worker knight fighter assassin castle village base).each do |w|
  require "#{__dir__}/#{w}.rb"
end

puts 'ttakuru88'

map = nil
stage = nil
prev_stage = -1
groups = nil

loop do
  STDOUT.flush

  ms = gets.to_i
  break if ms <= 0

  prev_stage = stage
  stage      = gets.to_i
  if prev_stage != stage
    map = Map.new
    groups = GroupList.new
  end

  turn           = gets.to_i
  resources_rest = gets.to_i

  map.turn_init

  units_count = gets.to_i
  units_count.times do |i|
    map.add_unit Unit.load(gets), turn
  end

  enemies_count = gets.to_i
  enemies_count.times do |i|
    map.add_enemy Unit.load_enemy(gets)
  end

  map.standalones.each do |worker|
    groups.attach(worker, map)
  end

  resources_count = gets.to_i
  resources_count.times do |i|
    resource = map.add_resource(Resource.load(gets))
    if resource
      groups.create(8, {worker: 5}, [{resource: true, x: resource.x, y: resource.y, wait: true}])
    end
  end
  gets

  if turn == 0
    10.downto(0) do |i|
      y = i * 9 + 5
      groups.create(10, {worker: 1}, [{x: map.castle.x, y: map.castle.y},
                                      {x: map.castle.x, y: y},
                                      {x: 99, y: y}, {near_enemy_castle: true, wait: true}])
    end

    x = map.castle.x - 9
    while x >= -4
      px = [0, x].max
      groups.create(10, {worker: 1}, [{x: map.castle.x, y: map.castle.y},
                                     {x: px, y: 4},
                                     {x: px, y: 95}, {near_enemy_castle: true, wait: true}])

      x -= 9
    end
  end

  map.die_tmp_villages

  unless map.enemy_castle
    map.units.each do |unit|
      if unit.prev_hp
        enemies = map.near_enemies(unit)
        expect_prev_hp = unit.hp + unit.damage(map, enemies)
        if unit.prev_hp > expect_prev_hp && unit.y + unit.x >= 158
          map.expected_enemy_castle_positions << {y: unit.y, x: unit.x}
        end
      end

      unit.prev_hp = unit.hp
    end
  end

  dead_units = map.clean_dead_units
  groups.clean(dead_units)
  groups.clean_destroyed_group

  map.set_group(groups.all)

  map.resources.each do |resource|
    cell = map.at(resource.y, resource.x)

    resource.exists_unit = cell.units.size > 0
    if map.sight?(resource.y, resource.x)
      resource.exists_enemy = cell.enemies.size > 0
    end
  end

  map.bases.each_with_index do |base, i|
    next if map.at(base.y, base.x).battler_groups.size > 0

    if i == 1 && map.nearest_unguard_resource(base)
      if rand <= 0.66
        list = [{knight: 1, fighter: 1, assassin: 1}]
        groups.create(7, list.sample, [{x: base.x, y: base.y}, {enemy_resource: true}])
      else
        list = [{knight: 1, fighter: 1, assassin: 1}]
        groups.create(7, list.sample, [{x: base.x, y: base.y}, {near_castle: true}])
      end
    else
      list = if groups.attacker_count < 6
        [{knight: 3}, {fighter: 2, knight: 1}, {knight: 1, assassin: 1}]
      else
        unit_weight = map.bases.size > 1 ? 4 : 6
        [{knight: 4 * unit_weight, fighter: 3 * unit_weight, assassin: 3 * unit_weight}]
      end
      groups.create(7, list.sample, [{x: base.x, y: base.y}, {enemy_castle: true}])
    end
  end

  if turn < Settings::QUICK_TURN && map.danger_castle?
    groups.create(6, {worker: 1}, [{x: map.castle.x, y: map.castle.y, wait: true}])
  end

  groups.resource_groups.each do |group|
    cell = map.at(group.y, group.x)
    resource = cell.resources[0]
    group.primary = (resource.exists_unit && !resource.exists_enemy) ? 7 : 8
  end

  groups.move(map)

  wish_list = []
  wish_list += groups.wishes
  wish_list += Village.wishes(map)
  wish_list += Base.wishes(map, resources_rest, turn)
  wish_list = wish_list.shuffle.sort_by(&:primary)

  wish_list.each do |wish|
    if resources_rest >= wish.cost
      resources_rest -= wish.cost if wish.realize(map, resources_rest, turn)
    else
      break
    end
  end

  puts map.active_units.size
  map.active_units.each do |unit|
    puts "#{unit.id} #{unit.action_number}"
  end
end
