puts 'ttakuru88'

loop do
  STDOUT.flush

  ms = gets.to_i
  break if ms <= 0

  stage = gets.to_i
  turn  = gets.to_i
  all_resources_count = gets.to_i

  units = []
  units_count = gets.to_i
  units_count.times do |i|
    units << gets
  end

  enemies = []
  enemies_count = gets.to_i
  enemies_count.times do |i|
    enemies << gets
  end

  resources = []
  resources_count = gets.to_i
  resources_count.times do |i|
    resources << gets
  end

  gets

  puts '0'
end
