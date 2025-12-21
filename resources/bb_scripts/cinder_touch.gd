extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.IMMOLATE))
    bb_container_data.push_back(BBContainerData.new(" on hit"))

    return bb_container_data
