# bug ワーカを余計に生産する
# bug 資源地の敵が見えているはずなのにワーカを作り続ける
# feature 右下のワーカがいない場合に派遣
# feature 攻撃拠点で貯め打ち
# 他の場所にワーカを派遣仕様とした時に近くに敵がいるとworkerを無駄に作る場合が？(schewarzとか
# スタンドアロンなワーカを最初の資源地用に散歩させたい

module Settings
  QUICK_TURN = 250.freeze
  VILLAGE_MAX = 6.freeze
  BASE_MAX = 3.freeze
end

%w(wish group_list work work_manager unit_tank group cell map resource unit battler worker knight fighter assassin castle village base).each do |w|
  require "#{__dir__}/#{w}.rb"
end

puts 'ttakuru88'

map = nil
stage = nil
prev_stage = -1

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
  end
  gets

  map.update_unknown_cells

  # 自城守る戦闘員
  if turn == 0
    map.create_group(:castle_guardian, 9, {knight: 40, fighter: 30, assassin: 20}, [{y: map.castle.y, x: map.castle.x, wait: true}], map.castle)
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

  # ニートワーカをグループに紐付け
  map.groups.clean_tmp_units
  map.standalones.each do |unit|
    map.groups.attach(unit)
  end

  # 死んだワーカなど不要データの除去
  map.die_tmp_villages

  dead_units = map.clean_dead_units

  # ワーカ毎の動き
  map.workers.each do |worker|
    worker.think(map, turn, resources_rest)
  end

  # 資源地略奪グループを作成し続ける
  map.attacker_bases.each do |base|
    next if map.groups.resource_guardians_at(base.y, base.x).size > 0

    list = [{assassin: 1, fighter: 1, knight: 2}]
    #list = [{assassin: 2, fighter: 3, knight: 5}]
    map.create_group(:resource_guardian, 9, list.sample, [{y: base.y, x: base.x, wait_charge: true}])
  end

  # 資源地毎の処理
  map.resources.each do |resource|
    cell = map.at(resource.y, resource.x)

    resource.exists_unit = cell.units.size > 0
    if map.sight?(resource.y, resource.x)
      resource.exists_enemy = cell.enemies.size > 0
    end
  end

  # 敵城直接攻撃グループ
  map.attacker_bases.each do |base|
    next if map.groups.enemy_castle_attackers_at(base.y, base.x).size > 0

    list = [{assassin: 1}, {fighter: 1}, {knight: 1}]
    map.create_group(:enemy_castle_attacker, 9, list.sample, [{y: base.y, x: base.x}, {enemy_castle: true}], base)
  end

  # 資源地防衛グループから1番近い敵がいる資源地をターゲットにする
  map.groups.free_resource_guardians.each do |group|
    resource = map.nearest_enemy_resource(group)
    if resource
      group.insert_task({x: resource.x, y: resource.y, destroy_enemy: true})
    elsif map.resources.size < 20 && (!group.next_point || !group.next_point[:find_resource])
      group.insert_task({find_resource: true, free: true, wait: true})
    end
  end

  # 敵城が見えていれば敵城付近に敵がいるかを保存
  if map.enemy_castle && map.sight?(map.enemy_castle.y, map.enemy_castle.x)
    enemy_battlers, sight_count = map.near_enemy_battlers(map.enemy_castle.y, map.enemy_castle.x)

    map.many_attacker_near_enemy_castle = (enemy_battlers.size / sight_count > 5) || enemy_battlers.size >= 10
  end

  map.groups.move

  wish_list = []
  wish_list += Base.wishes(map, resources_rest, turn)
  wish_list += map.groups.wishes
  wish_list += map.castle.wishes(map, turn, resources_rest)
  wish_list = wish_list.shuffle.sort_by(&:primary)

  wish_list.each do |wish|
    if resources_rest >= wish.cost
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
