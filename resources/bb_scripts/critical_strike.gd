extends BBScript










func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []
    var stat: StatResource = Stats.CRIT_CHANCE

    bb_container_data.push_back(BBContainerData.new("Increase ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.PHYSICAL_DAMAGE))
    bb_container_data.push_back(BBContainerData.new(" ", Color.DARK_GRAY))

    if args[0] == BattleActions.OMNI_CRIT:
        bb_container_data.push_back(BBContainerData.new("and ", Color.DARK_GRAY))
        bb_container_data.push_back(Stats.get_bb_container_data(Stats.MAGIC_DAMAGE))
        bb_container_data.push_back(BBContainerData.new("\n"))
        stat = Stats.OMNI_CRIT_CHANCE

    bb_container_data.push_back(BBContainerData.new("by 100% + % ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.CRITICAL_DAMAGE))
    return bb_container_data
