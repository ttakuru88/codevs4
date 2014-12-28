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

  resources_count = gets.to_i
  resources_count.times do |i|
    resource = map.add_resource(Resource.load(gets))
    if resource
      groups.create(5, {worker: 5..5}, [{x: resource.x, y: resource.y, wait: true}])
    end
  end
  gets

  if turn == 0
    12.times do |i|
      y = i * 9
      groups.create(10, {worker: 1..1}, [{x: map.castle.x, y: y},
                                         {x: 99, y: y}])
    end

    x = map.castle.x - 8
    while x > 0
      groups.create(10, {worker: 1..1}, [{x: x, y: 0},
                                         {x: x, y: 99}])

      x -= 9
    end
  end

  map.neet_workers.each do |worker|
    groups.attach(worker)
  end

  map.die_tmp_villages
  dead_units = map.clean_dead_units

  groups.clean(dead_units)
  groups.move(map)

  wish_list = []
  wish_list += groups.wishes
  wish_list += Village.wishes(map)

  wish_list = wish_list.sort_by(&:primary)

  wish_list.each do |wish|
    if resources_rest >= wish.cost
      if wish.realize(map)
        resources_rest -= wish.cost
      end
    else
      break
    end
  end

  puts map.active_units.size
  map.active_units.each do |unit|
    puts "#{unit.id} #{unit.action_number}"
  end
end
