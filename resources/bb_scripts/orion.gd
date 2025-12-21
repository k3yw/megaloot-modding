extends BBScript







func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ORION, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ORION, 1))

    bb_container_data.push_back(BBContainerData.new(" Gain increased damage resistance as your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" falls, up to 75% resistance when at 25% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))


    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ORION, 3))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ORION, 3))
    bb_container_data.push_back(BBContainerData.new(" At the end of the first 3 turns, repair 25%"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" of your "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.ARMOR))

    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ORION, 4))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ORION, 4))
    bb_container_data.push_back(BBContainerData.new(" Unable to "))
    bb_container_data.push_back(Keywords.get_bb_container_data(Keywords.HEAL))

    return bb_container_data
