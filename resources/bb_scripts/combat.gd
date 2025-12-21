extends BBScript






func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("Increases "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.PHYSICAL_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" output by total "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.COMBAT))


    return bb_container_data
