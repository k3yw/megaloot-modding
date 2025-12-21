extends StatScript







func initialize() -> void :
    if not is_instance_valid(character):
        return

    character.about_to_attack.connect( func(target: Character, damage_data: DamageData):
        damage_data.is_lucky = Math.rand_success(character.get_stat_amount(Stats.LUCK)[0], RNGManager.gameplay_rand)
        if damage_data.is_lucky:
            damage_data.apply_multiplier(1.25)
    )
