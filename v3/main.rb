module Settings
  QUICK_TURN = 250.freeze
end

%w(wish group_list work work_manager unit_tank group cell map resource unit battler worker knight fighter assassin castle village base).each do |w|
  require "#{__dir__}/#{w}.rb"
end

puts 'ttakuru88'

map = nil
stage = nil
prev_stage = -1
save_resources = nil

loop do
  STDOUT.flush

  ms = gets.to_i
  break if ms <= 0

  prev_stage = stage
  stage      = gets.to_i

  if prev_stage != stage
    # ゲーム開始時
    map = Map.new
    Base.reset_count
    save_resources = 0
  end

  turn           = gets.to_i
  resources_rest = gets.to_i

  map.turn_init

  # 味方読み込み
  units_count = gets.to_i
  units_count.times do |i|
    unit = Unit.load(gets)
    map.inverse = unit.y + unit.x > 100 if unit.castle?
    unit.inverse if map.inverse

    map.add_unit(unit)
  end

  # 敵読み込み
  enemies_count = gets.to_i
  enemies_count.times do |i|
    enemy = Unit.load_enemy(gets)
    enemy.inverse if map.inverse

    map.add_enemy(enemy)
  end

  # 資源地読み込み
  resources_count = gets.to_i
  resources_count.times do |i|
    resource = Resource.load(gets)
    resource.inverse if map.inverse

    resource = map.add_resource(resource)
    if resource
      map.create_group(:resource_worker, 10, {worker: 5}, [{x: resource.x, y: resource.y, wait: true}])
      map.create_group(:resource_guardian, 9, {assassin: 1, fighter: 1, knight: 3}, [{wait_charge: true}, {x: resource.x, y: resource.y, wait: true}])
    end
  end
  gets

  # マップ全域探索ワーカ予約
  if turn == 0
    10.downto(0) do |i|
      y = i * 9 + 5
      map.create_group(:search_worker, 8, {worker: 1}, [{x: map.castle.x, y: map.castle.y},
                                      {x: map.castle.x, y: y},
                                      {x: 99, y: y}, {near_enemy_castle: true, wait: true}])
    end

    x = map.castle.x - 9
    while x >= -4
      px = [0, x].max
      map.create_group(:search_worker, 8, {worker: 1}, [{x: map.castle.x, y: map.castle.y},
                                     {x: px, y: 4},
                                     {x: px, y: 95}, {near_enemy_castle: true, wait: true}])

      x -= 9
    end
  end

  # ニートワーカをグループに紐付け
  map.standalones.each do |unit|
    map.groups.attach(unit)
  end

  # 予測と実際のダメージ差異から敵の城の位置を予測
  unless map.enemy_castle
    map.workers.each do |unit|
      if unit.prev_hp
        enemies = map.near_enemies(unit)
        expect_prev_hp = unit.hp + unit.damage(map, enemies)
        if unit.prev_hp > expect_prev_hp && unit.y + unit.x >= 150
          map.expected_enemy_castle_positions << {y: unit.y, x: unit.x}
          unit.prev = true if unit.worker?
        end
      end

      unit.prev_hp = unit.hp
    end
  end

  # 死んだワーカなど不要データの除去
  map.die_tmp_villages

  dead_units = map.clean_dead_units

  map.resources.each do |resource|
    cell = map.at(resource.y, resource.x)

    resource.exists_unit = cell.units.size > 0
    if map.sight?(resource.y, resource.x)
      resource.exists_enemy = cell.enemies.size > 0
    end
  end

  # 敵城が見えていれば敵城付近に敵がいるかを保存
  if map.enemy_castle && map.sight?(map.enemy_castle.y, map.enemy_castle.x)
    enemy_battlers, sight_count = map.near_enemy_battlers(map.enemy_castle.y, map.enemy_castle.x)

    map.many_attacker_near_enemy_castle = (enemy_battlers.size / sight_count > 5) || enemy_battlers.size >= 10
  end

  # バトラーの設置
  if turn == 0
    map.create_group(:castle_guardian, 9, {knight: 40, fighter: 30, assassin: 20}, [{y: map.castle.y, x: map.castle.x}], map.castle)
  end

  map.groups.move

  save_resources += (map.benefit_resources * 0.15).ceil
  save_resources = 0 if map.bases.size > 0

  wish_list = []
  wish_list += Village.wishes(map)
  wish_list += Base.wishes(map, resources_rest, turn)
  wish_list += map.groups.wishes
  wish_list = wish_list.shuffle.sort_by(&:primary)

  wish_list.each do |wish|
    rest = resources_rest
    rest -= save_resources if wish.type == :create_worker
    if rest >= wish.cost
      resources_rest -= wish.cost if wish.realize(map, resources_rest, turn)
    else
      break
    end
  end

  # 出力
  puts map.active_units.size
  map.active_units.each do |unit|
    puts "#{unit.id} #{unit.action_number(map)}"
  end
end
