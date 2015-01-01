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
    map.add_unit Unit.load(gets)
  end

  enemies_count = gets.to_i
  enemies_count.times do |i|
    map.add_enemy Unit.load_enemy(gets)
  end

  map.standalones.each do |worker|
    groups.attach(worker)
  end

  resources_count = gets.to_i
  resources_count.times do |i|
    resource = map.add_resource(Resource.load(gets))
    if resource
      groups.create(9, {worker: 5}, [{x: resource.x, y: resource.y, wait: true}])
    end
  end
  gets

  if turn == 0
    10.downto(0) do |i|
      y = i * 9 + 4
      worker_count = i > 7 ? 2 : 1
      groups.create(10, {worker: worker_count}, [{x: map.castle.x, y: y},
                                         {x: 99, y: y}, {near_enemy_castle: true, wait: true}])
    end

    x = map.castle.x - 9
    STDERR.puts x
    while x >= -4
      px = [0, x].max
      groups.create(10, {worker: 1}, [{x: px, y: 0},
                                      {x: px, y: 99}, {near_enemy_castle: true, wait: true}])

      x -= 9
    end
  end

  map.die_tmp_villages
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

  map.bases.each do |base|
    next if map.at(base.y, base.x).battler_groups.size > 0

    nearest_base, dist = map.nearest_base(map.castle)
    if base == nearest_base && dist < 100
      list = [{knight: 1}, {fighter: 1}, {assassin: 1}]
      if map.near_castle_battlers.size < 40
        groups.create(7, list[2], [{x: base.x, y: base.y}, {near_castle: true}])
      else
        list = [{knight: 1, fighter: 1, assassin: 1}]
        groups.create(7, list.sample, [{x: base.x, y: base.y}, {enemy_resource: true}])
      end
    else
      if rand < 0.2
        list = [{knight: 1, fighter: 1, assassin: 1}]
        groups.create(7, list.sample, [{x: base.x, y: base.y}, {enemy_resource: true}])
      else
        list = [{knight: 4, fighter: 3, assassin: 3}]
  #      list = [{assassin: 10}]
        groups.create(7, list.sample, [{x: base.x, y: base.y}, {enemy_castle: true}])
      end
    end
  end

  groups.move(map)

  wish_list = []
  wish_list += groups.wishes
  wish_list += Village.wishes(map)
  wish_list += Base.wishes(map, resources_rest)
  wish_list = wish_list.sort_by(&:primary)

  wish_list.each do |wish|
    if resources_rest >= wish.cost
      resources_rest -= wish.cost if wish.realize(map)
    else
      break
    end
  end

  puts map.active_units.size
  map.active_units.each do |unit|
    puts "#{unit.id} #{unit.action_number}"
  end
end
