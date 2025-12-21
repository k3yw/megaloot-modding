extends AbilityScript








func can_activate() -> bool:
    for turn in character.battle_profile.get_valid_turns():
        for status_effect in turn.received_status_effects:
            if status_effect.resource == StatusEffects.INVULNERABILITY:
                return true
    return false
