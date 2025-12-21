extends BBScript





func get_text_replacements(_args: Array = []) -> Dictionary[String, String]:
    var dict: Dictionary[String, String] = {
        "{gold}": "25", 
    }
    return dict



func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" "))
    bb_container_data.push_back(BBContainerData.new("Get an extra "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.DIAMOND))
    bb_container_data.push_back(BBContainerData.new(" from opening a chest"))

    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" "))

    bb_container_data.push_back(BBContainerData.new("Start with +{gold} "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.GOLD))


    return bb_container_data
