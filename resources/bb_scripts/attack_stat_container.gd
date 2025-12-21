extends BBScript




func get_bb_container_data(args: Array = []) -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    if args.size() < 2:
        return bb_container_data

    var selected_player: Character = args[1]

    var critical_damage: float = selected_player.get_stat_amount(Stats.CRITICAL_DAMAGE)[0]
    var adaptive_attack: float = selected_player.get_stat_amount(Stats.ADAPTIVE_ATTACK)[0]
    var total_attacks: float = selected_player.get_stat_amount(Stats.TOTAL_ATTACKS)[0]
    var penetration: float = selected_player.get_stat_amount(Stats.PENETRATION)[0]
    var crit_chance: float = selected_player.get_stat_amount(Stats.CRIT_CHANCE)[0]
    var wisdom: float = selected_player.get_stat_amount(Stats.WISDOM)[0]
    var combat: float = selected_player.get_stat_amount(Stats.COMBAT)[0]
    var power: float = selected_player.get_stat_amount(Stats.POWER)[0]
    var attack_type: StatResource = StatUtils.get_attack_type(selected_player.get_attack_damage_type())
    var highest_text: String = " (" + T.get_translated_string("highest").to_lower() + ")"


    bb_container_data += Info.from_stat(selected_player, BonusStat.new(attack_type, selected_player.get_attack_damage()))
    bb_container_data.push_back(BBContainerData.new(highest_text, Color.DIM_GRAY))


    if adaptive_attack:
        bb_container_data += Info.from_stat(selected_player, BonusStat.new(Stats.ADAPTIVE_ATTACK, adaptive_attack))

    if penetration:
        bb_container_data += Info.from_stat(selected_player, BonusStat.new(Stats.PENETRATION, penetration))

    match attack_type:
        Stats.PHYSICAL_ATTACK:
            if combat:
                bb_container_data += Info.from_stat(selected_player, BonusStat.new(Stats.COMBAT, combat))

        Stats.MAGIC_ATTACK:
            if wisdom:
                bb_container_data += Info.from_stat(selected_player, BonusStat.new(Stats.WISDOM, wisdom))

    if total_attacks:
        bb_container_data += Info.from_stat(selected_player, BonusStat.new(Stats.TOTAL_ATTACKS, total_attacks))


    if [Stats.PHYSICAL_ATTACK, Stats.MAGIC_ATTACK].has(attack_type):
        if critical_damage:
            bb_container_data += Info.from_stat(selected_player, BonusStat.new(Stats.CRITICAL_DAMAGE, critical_damage))
        if crit_chance:
            bb_container_data += Info.from_stat(selected_player, BonusStat.new(Stats.CRIT_CHANCE, crit_chance))


    if power:
        bb_container_data += Info.from_stat(selected_player, BonusStat.new(Stats.POWER, power))


    for bb in bb_container_data:
        bb.text = bb.text.replace("+", "")


    return bb_container_data
