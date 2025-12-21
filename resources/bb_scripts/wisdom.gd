extends BBScript










func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []
    var stat: StatResource = Stats.WISDOM

    if args[0] == Stats.ELDERSHIP:
        stat = Stats.ELDERSHIP

    bb_container_data.push_back(BBContainerData.new("<.>"))
    bb_container_data.push_back(BBContainerData.new(" Increases "))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" output by total "))
    bb_container_data.push_back(Stats.get_bb_container_data(stat))

    if args[0] == Stats.ELDERSHIP:
        bb_container_data.push_back(BBContainerData.new("\n"))
        bb_container_data.push_back(BBContainerData.new("<.>"))
        bb_container_data.push_back(BBContainerData.new(" Increases "))
        bb_container_data.push_back(Stats.get_bb_container_data(Stats.ARMOR))
        bb_container_data.push_back(BBContainerData.new(" by total "))
        bb_container_data.push_back(Stats.get_bb_container_data(stat))


    return bb_container_data
