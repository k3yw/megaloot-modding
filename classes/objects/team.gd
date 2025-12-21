class_name Team extends RefCounted


enum Type{NULL = -1, BLUE, RED}


var enemy_upgrades: Array[EnemyUpgrade] = []




static func get_border(team: Type) -> AtlasTexture:
    var atlas_texture = AtlasTexture.new()
    atlas_texture.atlas = preload("res://assets/textures/ui/partner_border.png")
    atlas_texture.region.size = Vector2(38, 38)

    match team:
        Type.BLUE: atlas_texture.region.position.x = 38
        Type.RED: atlas_texture.region.position.x = 38 * 3

    return atlas_texture


func add_enemy_upgrade(new_enemy_upgrades: EnemyUpgrade) -> void :
    for enemy_upgrade in enemy_upgrades:
        if not enemy_upgrade.enemy_resource == new_enemy_upgrades.enemy_resource:
            continue

        for stat in new_enemy_upgrades.stats:
            var new_stat = Stat.new()
            new_stat.set_stat(stat)
            StatUtils.change_stat_amount(enemy_upgrade.stats, new_stat)
        return

    enemy_upgrades.push_back(new_enemy_upgrades)



func get_enemy_upgrade_stats(enemy_resource: EnemyResource) -> Array[Stat]:
    var stats: Array[Stat] = []

    for enemy_upgrade in enemy_upgrades:
        if not enemy_upgrade.enemy_resource == enemy_resource:
            continue

        for stat in enemy_upgrade.stats:
            var new_stat = Stat.new()
            new_stat.set_stat(stat)
            stats.push_back(new_stat)

    return stats
