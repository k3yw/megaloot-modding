class_name EnemyUpgrade extends RefCounted


var enemy_resource: EnemyResource = EnemyResource.new()
var stats: Array[Stat] = []






func cleanup() -> void :
    for stat in stats:
        if not is_instance_valid(stat):
            continue
        stat.free()
