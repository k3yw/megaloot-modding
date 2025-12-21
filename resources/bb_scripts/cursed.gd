extends BBScript







func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.CURSED, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.CURSED, 1))
    bb_container_data.push_back(BBContainerData.new(" At the start of the battle, receive "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.CURSE)
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" and 5 stacks of "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.MALICE_SHIELD)

    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.CURSED, 3))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.CURSED, 3))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MALICE_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" you deal will be spread"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new(" to all enemies with "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.CURSE)

    return bb_container_data
