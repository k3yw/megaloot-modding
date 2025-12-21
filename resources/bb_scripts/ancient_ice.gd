extends BBScript







func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ANCIENT_ICE, 1))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ANCIENT_ICE, 1))

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" Receive "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.EPHEMERAL_ARMOR)
    bb_container_data.push_back(BBContainerData.new(" that equals to "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.FREEZE_DAMAGE))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("  dealt to enemies with "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.FREEZE)

    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" At the end of your first turn, apply "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.FREEZE)
    bb_container_data.push_back(BBContainerData.new(" to all"))
    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("  enemies"))

    return bb_container_data
