extends BBScript







func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.UNCHAINED, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.UNCHAINED, 1))
    bb_container_data.push_back(BBContainerData.new(" Debuffs will be applied to all enemies", Color.DARK_GRAY))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.UNCHAINED, 2))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.UNCHAINED, 2))
    bb_container_data.push_back(BBContainerData.new(" Double the debuffs you apply", Color.DARK_GRAY))


    return bb_container_data
