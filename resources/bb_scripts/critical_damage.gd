extends BBScript









func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Increases ", Color.DARK_GRAY))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.CRITICAL_STRIKE))
    bb_container_data.push_back(BBContainerData.new(" and ", Color.DARK_GRAY))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.OMNI_CRIT))
    bb_container_data.push_back(BBContainerData.new(" damage", Color.DARK_GRAY))


    return bb_container_data
