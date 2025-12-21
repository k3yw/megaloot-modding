extends BBScript





func get_bb_container_data(_args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []
    var agility_amount: int = 25

    bb_container_data.push_back(BBContainerData.new("Every time you hit an enemy this turn, get {agility-amount}% ", Color.DARK_GRAY))
    bb_container_data.push_back(Stats.get_bb_container_data(Stats.AGILITY))

    bb_container_data.push_back(BBContainerData.new("\n"))
    bb_container_data.push_back(BBContainerData.new("ACTIVATION CONDITION: ", Color.DIM_GRAY))
    bb_container_data.push_back(BattleActions.get_bb_container_data(BattleActions.DODGE))
    bb_container_data.push_back(BBContainerData.new(" at least once", Color.DIM_GRAY))


    if T.is_initialized():
        bb_container_data = Info.get_translated_bb_container_data_arr("prowlers_strike", "ability-description")
        for bb in bb_container_data:
            bb.text = bb.text.replace("{agility-amount}", str(agility_amount))


    return bb_container_data
