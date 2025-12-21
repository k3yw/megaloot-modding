extends BBScript








func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.PARRY))
    bb_container_data.push_back(BBContainerData.new(" damage is doubled"))

    return bb_container_data
