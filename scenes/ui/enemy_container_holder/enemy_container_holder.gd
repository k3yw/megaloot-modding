class_name EnemyContainerHolder extends Control


@export var h_seperation: int = 20


var battle_speed: float = 1.0




func _process(delta: float) -> void :
    update(delta)


func update(delta: float) -> void :
    var containers: Array[EnemyContainer] = get_containers()
    var positions: Array[float] = []

    if not containers.size():
        return

    for idx in containers.size():
        var target_pos: float = get_target_position(positions)
        positions.push_back(target_pos)


    var max_size: float = h_seperation * (containers.size() - 1)
    for idx in containers.size():
        var enemy_container: EnemyContainer = containers[idx]
        max_size += enemy_container.size.x


    for idx in containers.size():
        var enemy_container: EnemyContainer = containers[idx]
        var target_pos: float = positions[idx] - (max_size / 2)
        enemy_container.position.x = lerp(enemy_container.position.x, target_pos, minf(1.0, 10 * battle_speed * delta))



func get_target_position(positions: Array[float]) -> float:
    var containers: Array[EnemyContainer] = get_containers()

    if not positions.size():
        return 0.0

    return positions.back() + containers[positions.size() - 1].size.x + h_seperation



func get_visible_containers() -> Array[EnemyContainer]:
    var containers: Array[EnemyContainer] = []

    for container in get_containers():
        if not container.visible:
            continue
        containers.push_back(container)

    return containers



func get_containers() -> Array[EnemyContainer]:
    var containers: Array[EnemyContainer] = []

    for idx in get_child_count():
        var enemy_container: EnemyContainer = get_child(idx)
        if not enemy_container.visible:
            continue
        containers.push_back(enemy_container)

    return containers
