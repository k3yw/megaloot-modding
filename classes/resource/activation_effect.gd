class_name ActivationEffect extends Resource


@export var ability: AbilityResource

@export var status_effect: BonusStatusEffect
@export var temp_stats: Array[BonusStat]
@export var use_limit: int = 1

@export var activates_during_skip: bool = true

@export var armor_percent_to_restore: int
@export var health_percent_to_restore: int
@export var mana_to_regenerate: int







func get_bb_container_data() -> Array[BBContainerData]:
    var bb_container_data: Array[BBContainerData] = []

    var footer: String = T.get_translated_string("Refills Every Battle Potion").to_lower()


    if is_instance_valid(ability):
        var ability_text: String = T.get_translated_string("ability").to_upper() + ": "
        bb_container_data.push_back(BBContainerData.new(ability_text, Color.DARK_GRAY))
        bb_container_data += Abilities.get_bb_container_data(ability, true)
        footer = ""

    if is_instance_valid(status_effect):
        var text: String = T.get_translated_string("Status Effect Potion Description Single")

        if status_effect.amount > 1:
            text = T.get_translated_string("Status Effect Potion Description Multiple")
            text = text.replace("{amount}", str(status_effect.amount))

        for bb in text.split("|"):
            if bb == "{status-effect}":
                bb_container_data += StatusEffects.get_bb_container_data(status_effect.resource)
                continue
            bb_container_data.push_back(BBContainerData.new(bb, Color.DARK_GRAY))

    for temp_stat in temp_stats:
        var text: String = T.get_translated_string("Temp Stat To Add Potion Description")
        for bb in text.split("|"):
            if bb == "{stat}":
                bb_container_data += temp_stat.get_bb_container_data()
                continue
            bb_container_data.push_back(BBContainerData.new(bb, Color.DARK_GRAY))



    if armor_percent_to_restore:
        var text: String = T.get_translated_string("Potion Repairs").to_lower()
        text = text.replace("{amount}", str(armor_percent_to_restore))

        for bb in text.split("|"):
            if bb == "{stat}":
                bb_container_data.push_back(Stats.get_bb_container_data(Stats.ARMOR))
                continue
            bb_container_data.push_back(BBContainerData.new(bb, Color.DARK_GRAY))


    if mana_to_regenerate:
        var text: String = T.get_translated_string("Potion Regenerates").to_lower()
        text = text.replace("{amount}", str(mana_to_regenerate))

        for bb in text.split("|"):
            if bb == "{stat}":
                bb_container_data.push_back(Stats.get_bb_container_data(Stats.MANA))
                continue
            bb_container_data.push_back(BBContainerData.new(bb, Color.DARK_GRAY))


    if health_percent_to_restore:
        var text: String = T.get_translated_string("Potion Restores").to_lower()
        text = text.replace("{amount}", str(health_percent_to_restore) + "%")

        for bb in text.split("|"):
            if bb == "{stat}":
                bb_container_data.push_back(Stats.get_bb_container_data(Stats.HEALTH))
                continue
            bb_container_data.push_back(BBContainerData.new(bb, Color.DARK_GRAY))


    if footer.length():
        bb_container_data.push_back(BBContainerData.new("\n"))
        bb_container_data.push_back(BBContainerData.new(footer, Color.DIM_GRAY))


    return bb_container_data
