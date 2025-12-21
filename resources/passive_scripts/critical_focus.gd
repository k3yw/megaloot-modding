extends GameLogicScript






func initialize() -> void :
    character.about_to_attack.connect( func(_target: Character, damage_data: DamageData):
        if damage_data.is_crit:
            damage_data.accuracy += 25
    )
