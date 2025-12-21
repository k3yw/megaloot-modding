extends AbilityScript








func can_activate() -> bool:
    var attacks: int = 0
    for turn in character.battle_profile.get_valid_turns():
        attacks += turn.attacks
    return attacks >= 3
