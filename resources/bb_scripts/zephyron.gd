extends BBScript





func get_text_replacements(_args: Array = []) -> Dictionary[String, String]:
    var dict: Dictionary[String, String] = {
        "{amount}": "25"
    }

    return dict




func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []


    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ZEPHYRON, 1))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ZEPHYRON, 1))
    bb_container_data.push_back(BBContainerData.new(" Gain {amount}% "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" on every turn"))
    bb_container_data.push_back(BBContainerData.new(" resets every battle", Color.DIM_GRAY))

    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ZEPHYRON, 2))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ZEPHYRON, 2))
    bb_container_data.push_back(BBContainerData.new(" Dealt "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" will be applied to enemies with "))
    bb_container_data += StatusEffects.get_bb_container_data(StatusEffects.SILENCE)

    bb_container_data.push_back(BBContainerData.new("\n"))

    bb_container_data.push_back(BBContainerData.create_counter_hint(ItemSets.ZEPHYRON, 4))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(BBContainerData.create_counter_display(ItemSets.ZEPHYRON, 4))
    bb_container_data.push_back(BBContainerData.new(" First activated ability won't consume any "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MANA))


    return bb_container_data
