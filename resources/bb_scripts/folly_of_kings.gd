extends BBScript






func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Recieve a random status effect every turn"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("and "))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.POLYMORPH))
    bb_container_data.push_back(BBContainerData.new(" every 2 turns"))

    return bb_container_data
