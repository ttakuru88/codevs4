%w(work work_manager cell map resource unit worker knight fighter assassin castle village base).each do |w|
  require "#{__dir__}/#{w}.rb"
end

puts 'ttakuru88'

map = Map.new
work_manager = WorkManager.new

loop do
  STDOUT.flush

  ms = gets.to_i
  break if ms <= 0

  map.turn_init

  stage = gets.to_i
  turn  = gets.to_i
  all_resources_count = gets.to_i

  units_count = gets.to_i
  units_count.times do |i|
    map.add_unit Unit.load(gets)
  end

  enemies_count = gets.to_i
  enemies_count.times do |i|
    map.add_unit Unit.load(gets, true)
  end

  map.clean_units!

  if turn == 1
    12.times do |i|
      y = i * 9
      work_manager.add(10, [{type: :move, x: map.castle.x, y: y},
                            {type: :move, x: 100, y: y}])
    end

    x = map.castle.x - 4
    while x > 0
      work_manager.add(10, [{type: :move, x: x, y: 0},
                            {type: :move, x: x, y: 100}])

      x -= 9
    end
  end

  resources_count = gets.to_i
  resources_count.times do |i|
    if resource = map.add_resource(Resource.load(gets))
      work_manager.add(9, [{type: :move, x: resource.x, y: resource.y},
                           {type: :create_village}])
    end
  end
  gets

  work_manager.sort

  map.workers.each do |worker|
    worker.think(map, work_manager)
  end

  map.villages.each do |village|
    village.think(map)
  end

  map.bases.each do |base|
    base.think(map)
  end

  map.castle.think(map, work_manager)

  puts map.units.size
  map.units.each do |unit|
    puts "#{unit.id} #{unit.action_number}"
  end
end
