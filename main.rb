%w(cell map resource unit worker knight fighter assassin castle village base).each do |w|
  require "#{__dir__}/#{w}.rb"
end

puts 'ttakuru88'

loop do
  STDOUT.flush

  ms = gets.to_i
  break if ms <= 0

  stage = gets.to_i
  turn  = gets.to_i
  all_resources_count = gets.to_i

  map = Map.new

  units_count = gets.to_i
  units_count.times do |i|
    map.add_unit Unit.load(gets)
  end

  enemies_count = gets.to_i
  enemies_count.times do |i|
    map.add_unit Unit.load(gets, true)
  end

  resources_count = gets.to_i
  resources_count.times do |i|
    map.add_resource Resource.load(gets)
  end

  gets

  map.units.each do |unit|
    unit.think
  end

  puts map.units.size
  map.units.each do |unit|
    puts "#{unit.id} #{unit.action_number}"
  end
end
