class_name EnemyManager extends GameplayComponent








func upgrade_enemy(team: Team.Type, enemy_upgrade: EnemyUpgrade) -> void :
    match team:
        Team.Type.BLUE: memory.blue_team.add_enemy_upgrade(enemy_upgrade)
        Team.Type.RED: memory.red_team.add_enemy_upgrade(enemy_upgrade)

    for enemy in memory.battle.enemies_to_battle:
        if not enemy.resource == enemy_upgrade.enemy_resource:
            continue

        for stat in enemy_upgrade.stats:
            var bonus_stat = BonusStat.new()
            BonusStat.apply_stat(bonus_stat, stat)
            character_manager.add_stat(enemy, bonus_stat)
            gameplay_state.create_stat_added_popup(bonus_stat)

    gameplay_state.play_sfx(preload("res://assets/sfx/convert_to_battle_stats.wav"), 0.0, randf_range(1.0, 1.15))
