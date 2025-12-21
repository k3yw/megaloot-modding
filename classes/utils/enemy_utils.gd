class_name EnemyUtils









static func is_valid(enemy) -> bool:
    if not is_instance_valid(enemy):
        return false

    if not enemy is Enemy:
        return false

    return true
