extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Every time you "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.PARRY))
    bb_container_data.push_back(BBContainerData.new(", apply "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.EXHAUSTION)
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("on target"))


    return bb_container_data
