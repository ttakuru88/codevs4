%w(work work_manager cell map resource unit battler worker knight fighter assassin castle village base).each do |w|
  require "#{__dir__}/#{w}.rb"
end

puts 'ttakuru88'

map = nil
stage = nil
work_manager = nil
prev_stage = -1
battler_work = nil

loop do
  STDOUT.flush

  ms = gets.to_i
  break if ms <= 0

  prev_stage = stage
  stage = gets.to_i
  if prev_stage != stage
    map = Map.new
    work_manager = WorkManager.new
    battler_work = WorkManager.new
  end

  turn  = gets.to_i
  all_resources = gets.to_i

  map.turn_init

  units_count = gets.to_i
  units_count.times do |i|
    map.add_unit Unit.load(gets)
  end

  enemies_count = gets.to_i
  enemies_count.times do |i|
    map.add_unit Unit.load(gets, true)
  end

  map.units.each do |unit|
    cell = map.at(unit.y, unit.x)
    ee = cell.enemies.size > 0
    cell.resources.each { |r| r.exists_enemy = ee }
  end

  map.clean_units!

  if turn == 0
    12.times do |i|
      y = i * 9
      work_manager.add(10, [{type: :move, x: map.castle.x, y: y},
                            {type: :move, x: 99, y: y}])
    end

    x = map.castle.x - 8
    while x > 0
      work_manager.add(10, [{type: :move, x: x, y: 0},
                            {type: :move, x: x, y: 99}])

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

  if all_resources >= Base::RESOURCE && map.bases.size <= 1
    far_worker = nil
    far = 0
    map.workers.each do |worker|
      if far < worker.x + worker.y
        far_worker = worker
        far = worker.x + worker.y
      end
    end

    if far_worker
      far_worker.create_base(map)
    end
  end

  if map.battlers.size > 0
    map.noguard_resources.reverse_each do |resource|
      8.times do |i|
        battler_work.add(10, [{type: :move, x: resource.x, y: resource.y},
                              {type: :wait}])
      end

      resource.guardian = true
    end
  end

  map.resources.each do |resource|
    resource.require_worker.times do |i|
      work_manager.add(10, [{type: :move, x: resource.x, y: resource.y},
                            {type: :wait}])
    end
    resource.require_worker = 0
  end

  map.battlers.each do |unit|
    unit.think(map, battler_work)
  end

  map.bases.each do |base|
    base.think(map, all_resources)
  end

  work_manager.available_works.each do |work|
    fabricator = map.castle
    min_dist = (work.typical_y - map.castle.y).abs + (work.typical_x - map.castle.x).abs

    map.villages.each do |village|
      dist = (work.typical_y - village.y).abs + (work.typical_x - village.x).abs
      if min_dist > dist
        min_dist = dist
        fabricator = village
      end
    end

    fabricator.create_worker if fabricator
  end

  map.villages.each do |village|
    village.think(map, all_resources)
  end

  puts map.active_units.size
  map.active_units.each do |unit|
    puts "#{unit.id} #{unit.action_number}"
  end
end
