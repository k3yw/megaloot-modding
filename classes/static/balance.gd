class_name Balance


const ENEMY_SCALE_RATE: float = 1.0175
const STARTING_GOLD_COINS: int = 15
const SCALE_RATE: float = 1.25
const MAX_ENEMIES: int = 6






static func get_max_enemy_upgrade(floor_number: int) -> int:
    return mini(3, floori(float(floor_number) * 0.5) + 1)





static func get_time_gold_reward(time_left: float, max_time: float, floor_number: int) -> float:
    var gold: float = GameModes.PVP.get_script_instance().get_gold_on_kill(null, floor_number)
    var percentage: float = time_left / max_time

    return floorf(gold * percentage)




static func get_market_rarity(item_resource: ItemResource, floor_number: int) -> ItemRarity.Type:
    var spawn_floor: int = item_resource.spawn_floor
    var difference: int = floori(float(floor_number) / spawn_floor)
    var rarity: int = 0


    for i in mini(mini(floor_number + 1, 20), difference):
        var fail_chance: int = 60 + (i * 2)
        if fail_chance >= 100:
            break

        if Math.rand_success(fail_chance):
            continue
        rarity += 1


    return clampi(rarity, ItemRarity.Type.COMMON, ItemRarity.Type.DIVINE) as ItemRarity.Type






static func get_scale_rate(floor_number: int) -> float:
    var grow: float = floor_number * (1.0 / 30.0)
    return SCALE_RATE + (grow * 0.75)
