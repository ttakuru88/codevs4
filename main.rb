%w(cell map resource unit worker knight fighter assassin castle village base).each do |w|
  require "#{__dir__}/#{w}.rb"
end

puts 'ttakuru88'

map = Map.new

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

  resources_count = gets.to_i
  resources_count.times do |i|
    map.add_resource Resource.load(gets)
  end
  gets

  map.workers.each_with_index do |worker, i|
    worker.think(map, i)
  end

  map.villages.each do |village|
    village.think(map)
  end

  map.bases.each do |base|
    base.think(map)
  end

  map.castle.think(map)

  puts map.units.size
  map.units.each do |unit|
    puts "#{unit.id} #{unit.action_number}"
  end
end
