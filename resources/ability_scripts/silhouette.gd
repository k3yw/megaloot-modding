extends AbilityScript








func can_activate() -> bool:
    for turn in character.battle_profile.get_valid_turns():
        if turn.backstabs > 0:
            return true

    return false
