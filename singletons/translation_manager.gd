extends Node

signal language_changed

const MAIN_TRANSLATION_CSV_PATH: String = "res://assets/translations/main.csv"
const TRANSLATIONS_CSV_NAME: String = "translations.csv"

const BB_PRESETS_DIR: String = "res://resources/bb_presets/"



var languages: Array[String] = []

var translations: Dictionary = {}

var bb_presets: Dictionary = {}



func _ready() -> void :
    TranslationServer.set_locale("english")

    load_languages()

    create_translations_dict()

    load_translation_file()
    create_translation_file()

    fix_translation()


func is_initialized() -> bool:
    return not translations.is_empty()



func load_languages() -> void :
    var read_file = FileAccess.open(get_translation_file_path(), FileAccess.READ)


    if not is_instance_valid(read_file):
        languages = [
            "english", 
            "french", 
            "german", 
            "spanish", 
            "japanese", 
            "koreana", 
            "polish", 
            "portuguese", 
            "russian", 
            "schinese", 
            "tchinese", 
        ]
        return

    var csv = read_file.get_csv_line()
    csv.remove_at(0)

    for key in csv:
        languages.push_back(key)

    read_file.close()







func create_translations_dict() -> void :
    var scenes: Array[Node] = [
        load("res://scenes/states/memory_selection_state/memory_selection_state.tscn").instantiate(), 
        load("res://scenes/states/main_menu_state/main_menu_state.tscn").instantiate(), 
        States.GAMEPLAY_STATE.instantiate(), 
        load("res://scenes/managers/popup_manager/popup_manager.tscn").instantiate(), 
        load("res://scenes/states/profile_state/profile_state.tscn").instantiate(), 
        load("res://scenes/states/library_state/library_state.tscn").instantiate(), 
        load("res://scenes/states/lobby_state/lobby_state.tscn").instantiate(), 
        load("res://scenes/general/main/main.tscn").instantiate(), 
    ]

    var translation_presets: Dictionary = File.json_to_dict("res://resources/json/translation_presets.json")
    var text_arr: Array[String] = []
    var key_arr: Array[String] = []

    for room in Rooms.LIST:
        if not is_instance_valid(room.action_container_scene):
            continue
        scenes.push_back(room.action_container_scene.instantiate())

    for key in translation_presets.keys():
        key_arr.push_back(key + "-text")

    for text in translation_presets.values():
        text_arr.push_back(text)



    for scene in scenes:
        for node in NodeUtils.get_all_children(scene, []):
            if node is GenericButton:
                if node.text.length():
                    text_arr.push_back(node.text)
                    key_arr.push_back(get_fixed_node_name(node.text, "-button"))


            if node is TabButton:
                if not node.text.length():
                    continue

                key_arr.push_back((node.text as String).to_lower().replace(" ", "-") + "-button")
                text_arr.push_back(node.text)


            if node is GenericLineEdit:
                if not node.line_edit.placeholder_text.length():
                    continue

                key_arr.push_back(get_fixed_key(node.line_edit.placeholder_text, "line-edit"))
                text_arr.push_back(node.line_edit.placeholder_text)


            if node is GenericDropDown:
                if not node.translate:
                    continue

                for selection in node.selections:
                    var selection_name = get_fixed_node_name(selection, "-drop-down-selection")
                    key_arr.push_back(selection_name)
                    text_arr.push_back(selection)


            if node is GenericLabel:
                register_label(key_arr, text_arr, node, "label")


            if node is HoverInfoModule:
                var hover_info_data: HoverInfoData = node.get_hover_info_data()
                if not is_instance_valid(hover_info_data):
                    continue

                var node_name: String = get_fixed_node_name(node.owner.name.to_snake_case(), "-hover")
                var description: String = get_bb_container_text(hover_info_data)

                if node.hover_info_name.length():
                    node_name = get_fixed_node_name(node.hover_info_name.to_snake_case(), "-hover")

                if not hover_info_data.name.is_empty():
                    text_arr.push_back(hover_info_data.name)
                    key_arr.push_back(get_fixed_key(node_name, "name"))

                if description.length() > 1:
                    text_arr.push_back(description)
                    key_arr.push_back(get_fixed_key(node_name, "description"))

                if node.bottom_hint.length() > 1:
                    text_arr.push_back(node.bottom_hint)
                    key_arr.push_back(get_fixed_key(node_name, "bottom-hint"))


    for scene in scenes:
        scene.queue_free()



    for window_mode in WindowMode.Type.keys():
        text_arr.push_back(window_mode.capitalize())
        key_arr.push_back(window_mode.to_lower() + "-window-mode-name")

    for game_mode in GameModes.LIST:
        text_arr.push_back(game_mode.name)
        key_arr.push_back(game_mode.get_id() + "-game-mode-name")

    for battle_action in BattleActions.LIST:
        var popup_label_data: PopupLabelData = battle_action.get_action_popup_label_data()
        if not is_instance_valid(popup_label_data):
            continue

        text_arr.push_back(popup_label_data.text.capitalize())
        key_arr.push_back(popup_label_data.text.to_lower().replace(" ", "-") + "-popup")

    for socket in SocketTypes.BASE_SOCKETS:
        var key: String = get_fixed_key(socket.name, "socket-name")
        text_arr.push_back(socket.name.capitalize())
        key_arr.push_back(key)



    var items_with_description: Array[ItemResource] = []
    for item in Items.LIST:
        var key: String = get_fixed_key(item.name, "item-name")
        text_arr.push_back(item.name)
        key_arr.push_back(key)

        if is_instance_valid(item.bb_script):
            items_with_description.push_back(item)



    for item in items_with_description:
        var key: String = get_fixed_key(item.name, "item-description")
        var script: BBScript = item.bb_script.new() as BBScript
        text_arr.push_back(get_bb_container_text(script))

        key_arr.push_back(key)



    for enemy in Enemies.LIST + Enemies.SPECIAL:
        var key: String = get_fixed_key(enemy.name, "enemy-name")
        text_arr.push_back(enemy.name)
        key_arr.push_back(key)


    for item_set in ItemSets.LIST:
        var key: String = get_fixed_key(item_set.name, "item-set-name")
        text_arr.push_back(item_set.name)
        key_arr.push_back(key)


    for item_set in Specializations.LIST:
        var specialization_arr: Array[Specialization] = Specializations.LIST[item_set].arr
        for specialization in specialization_arr:
            var key: String = get_fixed_key(specialization.name, "specialization-name")
            text_arr.push_back(specialization.name)
            key_arr.push_back(key)




    for stat in Stats.LIST:
        var key: String = (stat.name as String).to_lower().replace(" ", "-") + "-stat-name"
        text_arr.push_back(stat.name)
        key_arr.push_back(key)

    for status_effect in StatusEffects.LIST:
        var key: String = get_fixed_key(status_effect.name, "status-effect-name")
        text_arr.push_back(status_effect.name)
        key_arr.push_back(key)

        if status_effect.application_message.length():
            var application_message_key: String = (status_effect.application_message as String).to_lower().replace(" ", "-") + "-status-effect-application-message"
            text_arr.push_back(status_effect.application_message.capitalize())
            key_arr.push_back(application_message_key)

    for keyword in Keywords.LIST:
        var key: String = get_fixed_key(keyword.name, "keyword-name")
        text_arr.push_back(keyword.name)
        key_arr.push_back(key)

    for battle_action in BattleActions.LIST:
        var key: String = get_fixed_key(battle_action.name, "battle-action-name")
        text_arr.push_back(battle_action.name)
        key_arr.push_back(key)

    for ability in Abilities.LIST:
        var key: String = get_fixed_key(Abilities.get_file_name(ability), "ability-name")
        text_arr.push_back(ability.name)
        key_arr.push_back(key)

    for passive in Passives.LIST:
        var key: String = get_fixed_key(passive.name, "passive-name")
        text_arr.push_back(passive.name)
        key_arr.push_back(key)

    for trial in Trials.LIST:
        var key: String = get_fixed_key(trial.name, "trial-name")
        text_arr.push_back(trial.name)
        key_arr.push_back(key)

    for rarity in ItemRarity.Type.keys():
        var key: String = get_fixed_key(rarity, "rarity-name")
        text_arr.push_back(rarity)
        key_arr.push_back(key)

    for adventurer in Adventurers.LIST:
        var key: String = get_fixed_key(adventurer.name, "adventurer-name")
        text_arr.push_back(adventurer.name)
        key_arr.push_back(key)

        for idx in adventurer.chapters.size():
            var chapter: Chapter = adventurer.chapters[idx]
            var chapter_key: String = (adventurer.name as String).to_lower().replace(" ", "-") + "-chapter-" + str(idx)
            text_arr.push_back(chapter.text)
            key_arr.push_back(chapter_key)

    for status_effect_type in StatusEffectTypes.LIST:
        var key: String = get_fixed_key(status_effect_type.name, "status-effect-type-name")
        text_arr.push_back(status_effect_type.name)
        key_arr.push_back(key)


    for bb in bb_presets.values():
        text_arr.push_back(get_bb_container_text(bb))

    for key in bb_presets.keys():
        key_arr.push_back(key)



    for stat in Stats.LIST:
        var key: String = (stat.name as String).to_lower().replace(" ", "-") + "-stat-description"
        var text: String = get_bb_container_text(stat)

        if not text.length():
            continue

        text_arr.push_back(text)
        key_arr.push_back(key)



    for status_effect in StatusEffects.LIST:
        var key: String = get_fixed_key(status_effect.name, "status-effect-description")
        var text: String = get_bb_container_text(status_effect)

        if not text.length():
            continue

        text_arr.push_back(text)
        key_arr.push_back(key)


    for keyword in Keywords.LIST:
        var key: String = get_fixed_key(keyword.name, "keyword-description")
        var text: String = get_bb_container_text(keyword)

        if not text.length():
            continue

        text_arr.push_back(text)
        key_arr.push_back(key)


    for battle_action in BattleActions.LIST:
        var key: String = get_fixed_key(battle_action.name, "battle-action-description")
        var text: String = get_bb_container_text(battle_action)

        if not text.length():
            continue

        text_arr.push_back(text)
        key_arr.push_back(key)


    for ability in Abilities.LIST:
        var key: String = get_fixed_key(ability.name, "ability-description")
        var text: String = get_bb_container_text(ability)

        if not text.length():
            continue

        text_arr.push_back(text)
        key_arr.push_back(key)


    for passive in Passives.LIST:
        var key: String = get_fixed_key(passive.name, "passive-description")
        var text: String = get_bb_container_text(passive)

        if not text.length():
            continue

        text_arr.push_back(text)
        key_arr.push_back(key)



    for item_set in ItemSets.LIST:
        var key: String = get_fixed_key(item_set.name, "item-set-description")
        var text: String = get_bb_container_text(item_set, [false])

        if not text.length():
            continue

        text_arr.push_back(text)
        key_arr.push_back(key)


    for item_set in Specializations.LIST:
        var specialization_arr: Array[Specialization] = Specializations.LIST[item_set].arr
        for specialization in specialization_arr:
            var key: String = get_fixed_key(specialization.name, "specialization-description")

            var text: String = get_bb_container_text(specialization, [false])
            if not text.length():
                continue

            text_arr.push_back(text)
            key_arr.push_back(key)


    for trial in Trials.LIST:
        var key: String = get_fixed_key(trial.name, "trial-description")
        var hover_info_data = HoverInfoData.new()

        hover_info_data = Info.from_trial(hover_info_data, trial)

        var text: String = get_bb_container_text(hover_info_data)

        if not text.length():
            continue

        text_arr.push_back(text)
        key_arr.push_back(key)



    for idx in key_arr.size():
        var key: String = key_arr[idx]
        var text: String = text_arr[idx]
        translations[key] = {}


        for language in languages:
            translations[key][language] = ""

        text = text.replace("\n", "|\\n|")
        text = text.replace(",", ";")

        translations[key]["english"] = text




func register_label(key_arr: Array[String], text_arr: Array[String], label: GenericLabel, type: String) -> void :
    if label.text.length() < 2:
        return

    if not label.translate:
        return

    if label.is_value:
        return

    var label_name: String = label.name.to_snake_case()

    if not label.text.contains("\n") and label.autowrap_mode == TextServer.AUTOWRAP_OFF:
        label_name = label.text

    label_name = get_fixed_node_name(label_name, "-" + type)

    key_arr.push_back(label_name)
    text_arr.push_back(label.text)



func load_translation_file() -> void :
    var read_file = FileAccess.open(get_translation_file_path(), FileAccess.READ)

    if not is_instance_valid(read_file):
        return

    var csv_languages: PackedStringArray = []
    var line: int = 0

    while not read_file.eof_reached():
        var csv = read_file.get_csv_line()
        line += 1

        if line == 1:
            csv_languages = csv
            continue

        var key: String = csv[0]

        if csv.size() < 2:
            continue


        if not translations.keys().has(key):
            continue

        var translation_reference: String = translations[key]["english"]
        translation_reference = translation_reference.trim_suffix(" ")

        if translation_reference == csv[languages.find("english") + 1]:
            for idx in csv_languages.size():
                if idx < 2:
                    continue

                var translation: String = ""
                if csv.size() - 1 >= idx:
                    translation = csv[idx]

                translations[key][csv_languages[idx]] = translation


    read_file.close()





func create_translation_file() -> void :
    var write_file = FileAccess.open(File.get_file_dir() + "/" + TRANSLATIONS_CSV_NAME, FileAccess.WRITE)
    var csv_data: String = "id"


    for language in languages:
        csv_data += "," + language


    for key in translations.keys():
        csv_data += "\n"
        csv_data += key

        for language in languages:
            csv_data += "," + translations[key][language]


    write_file.store_string(csv_data)
    write_file.close()





func set_locale(lang: String) -> void :
    OptionsManager.options.current_language = maxi(0, languages.find(lang))
    TranslationServer.set_locale(lang)

    OptionsManager.save_options()

    for label in NodeManager.labels:
        label.reload_label()

    for tab_button in NodeManager.tab_buttons:
        tab_button.reload_label()

    for button in NodeManager.generic_buttons:
        button.reload_label()

    for generic_drop_down in NodeManager.generic_drop_downs:
        if generic_drop_down.translate:
            generic_drop_down.reload_selections()

    language_changed.emit()






func fix_translation() -> void :
    var keys: Array = translations.keys()
    var bb_keys: Array[String] = []


    for key in keys:
        if key.ends_with("-stat-description"):
            bb_keys.push_back(key)

        if key.ends_with("-status-effect-description"):
            bb_keys.push_back(key)

        if key.ends_with("-keyword-description"):
            bb_keys.push_back(key)

        if key.ends_with("-battle-action-description"):
            bb_keys.push_back(key)

        if key.ends_with("-ability-description"):
            bb_keys.push_back(key)

        if key.ends_with("-passive-description"):
            bb_keys.push_back(key)

        if key.ends_with("-item-set-description"):
            bb_keys.push_back(key)

        if key.ends_with("-specialization-description"):
            bb_keys.push_back(key)

        if key.ends_with("-trial-description"):
            bb_keys.push_back(key)

        if key.ends_with("-hover-description"):
            bb_keys.push_back(key)

        if key.ends_with("-item-description"):
            bb_keys.push_back(key)



    for language in languages:
        TranslationServer.set_locale(language)

        for key in bb_keys:
            var bb_container_data_arr: Array[BBContainerData] = []
            var text_arr: PackedStringArray = (translations[key][language] as String).split("|")
            for text in text_arr:
                if text == "\\n":
                    bb_container_data_arr.push_back(BBContainerData.new("\n"))
                    continue

                if text == "~":
                    bb_container_data_arr.push_back(BBContainerData.new("\n"))
                    continue


                if "@" in text:
                    var is_counter: bool = text.begins_with("[*")
                    var counter_bb = BBContainerData.new()
                    var amount: int = text.to_int()
                    var property = text.replace("[", "").replace("]", "").replace("*", "").replace("@", "").replace("-", "_").replace(str(amount), "").to_upper()

                    var result = ItemSets.get(property) as ItemSetResource
                    if is_instance_valid(result):
                        if is_counter:
                            var set_bb: BBContainerData = ItemSets.get_bb_container_data(result)
                            set_bb.text = "(%d)" % amount
                            set_bb.text_color = result.color
                            set_bb.is_counter = true
                            bb_container_data_arr.push_back(set_bb)
                            continue

                        counter_bb.bb_counter = BBCounter.new(result, amount)
                        bb_container_data_arr.push_back(counter_bb)


                    result = Stats.get(property) as StatResource
                    if is_instance_valid(result):
                        if is_counter:
                            var stat_bb: BBContainerData = Stats.get_bb_container_data(result)
                            stat_bb.text = "(%d)" % amount
                            stat_bb.text_color = result.color
                            stat_bb.is_counter = true
                            bb_container_data_arr.push_back(stat_bb)
                            continue

                        counter_bb.bb_counter = BBCounter.new(result, amount)
                        bb_container_data_arr.push_back(counter_bb)
                    continue



                if text.begins_with("[*"):
                    var property = text.replace("[*", "").replace("]", "").replace("-", "_").replace("*", "").replace(" ", "_").to_upper()

                    var result = Specializations.get(property)
                    if is_instance_valid(result):
                        var set_bb_container_data = BBContainerData.new()
                        bb_container_data_arr.push_back(set_bb_container_data)
                        set_bb_container_data.item_set_resource = result.original_item_set
                        set_bb_container_data.specialization = result
                        set_bb_container_data.is_multiplier = true
                        continue

                    result = ItemSets.get(property)
                    if is_instance_valid(result):
                        var set_bb_container_data = BBContainerData.new()
                        bb_container_data_arr.push_back(set_bb_container_data)
                        set_bb_container_data.item_set_resource = result
                        set_bb_container_data.is_multiplier = true
                    continue


                if text.begins_with("[-"):
                    var property = text.replace("[-", "").replace("]", "").replace("-", "_").replace(" ", "_").to_upper()
                    var result = ItemSets.get(property)
                    if is_instance_valid(result):
                        var set_bb_container_data = BBContainerData.new()
                        bb_container_data_arr.push_back(set_bb_container_data)
                        set_bb_container_data.item_set_resource = result
                        set_bb_container_data.text = ""
                    continue


                if text.begins_with("[$"):
                    var property = text.replace("[$", "").replace("]", "").replace("-", "_").replace("$", "").replace(" ", "_").to_upper()
                    var result = BattleActions.get(property)
                    if is_instance_valid(result):
                        bb_container_data_arr.push_back(BattleActions.get_bb_container_data(result, null))
                    continue


                if text.begins_with("[") and not "@" in text:
                    var property = text.replace("[", "").replace("]", "").replace("-", "_").replace("*", "").replace(" ", "_").to_upper()
                    var is_value: bool = text.ends_with("*")
                    var display_mode = Stats.DisplayMode.NORMAL
                    var result

                    if is_value:
                        display_mode = Stats.DisplayMode.UNKNOWN

                    result = Stats.get(property)
                    if is_instance_valid(result):
                        bb_container_data_arr.push_back(Stats.get_bb_container_data(result, display_mode))
                        continue

                    result = StatusEffects.get(property)
                    if is_instance_valid(result):
                        bb_container_data_arr += StatusEffects.get_bb_container_data(result)
                        continue

                    result = Abilities.get(property)
                    if is_instance_valid(result):
                        bb_container_data_arr += Abilities.get_bb_container_data(result)
                        continue

                    result = BattleActions.get(property)
                    if is_instance_valid(result):
                        bb_container_data_arr.push_back(BattleActions.get_bb_container_data(result))
                        continue

                    result = Keywords.get(property)
                    if is_instance_valid(result):
                        bb_container_data_arr.push_back(Keywords.get_bb_container_data(result))
                        continue

                    result = Trials.get(property)
                    if is_instance_valid(result):
                        bb_container_data_arr.push_back(Trials.get_bb_container_data(result))
                        continue

                    result = ItemSets.get(property)
                    if is_instance_valid(result):
                        bb_container_data_arr.push_back(ItemSets.get_bb_container_data(result))
                        continue

                    result = Passives.get(property)
                    if is_instance_valid(result):
                        bb_container_data_arr.push_back(Passives.get_bb_container_data(result))
                        continue

                    continue


                if text.begins_with("{"):
                    var property = text.replace("{", "").replace("}", "").replace(" ", "_").replace("-", "_").to_upper()
                    var tag = BBTags.get(property)
                    if is_instance_valid(tag):
                        var tag_bb_container_data = BBContainerData.new()
                        tag_bb_container_data.tag = tag
                        bb_container_data_arr.push_back(tag_bb_container_data)
                        continue


                if text.length():
                    var bb_text = BBContainerData.new()

                    if text.begins_with("<") and not "<.>" in text:
                        var color: Color = Color(text.left(8).replace("<", "").replace(">", ""))
                        text = text.right(text.length() - 8)
                        bb_text.left_image_color = color
                        bb_text.text_color = color

                    bb_text.text = text.replace(";", ",")
                    bb_container_data_arr.push_back(bb_text)


            translations[key][language] = bb_container_data_arr



    TranslationServer.set_locale("english")




func get_fixed_node_name(original_name: String, suffix: String) -> String:
    var node_name = original_name.to_lower().replace(" ", "-")

    node_name = node_name.trim_suffix("-")
    node_name += suffix.to_lower()

    node_name = node_name.replace("_", "-")
    node_name = node_name.replace(":", "")
    node_name = node_name.replace(".", "")
    node_name = node_name.replace("[", "")
    node_name = node_name.replace("]", "")

    return node_name



func get_bb_container_text(key, _args: Array = []) -> String:
    var hover_info_data = HoverInfoData.new()
    var text: String = ""

    if key is HoverInfoData:
        hover_info_data.unreference()
        hover_info_data = key

    if key is BBScript:
        hover_info_data.bb_container_data_arr += key.get_bb_container_data()

    if key is StatResource:
        hover_info_data = Info.from_stat_resource(hover_info_data, null, key)

    if key is StatusEffectResource:
        hover_info_data = Info.from_status_effect_resource(hover_info_data, key)

    if key is Keyword:
        hover_info_data = Info.from_keyword(hover_info_data, key)

    if key is BattleAction:
        hover_info_data = Info.from_battle_action(hover_info_data, key)

    if key is AbilityResource:
        hover_info_data = Info.from_ability(hover_info_data, key, null)

    if key is Passive:
        hover_info_data = Info.from_passive(hover_info_data, key)

    if key is ItemSetResource:
        hover_info_data = Info.from_item_set(hover_info_data, null, key)

    if key is Specialization:
        hover_info_data = Info.from_item_set(hover_info_data, null, key.original_item_set, key)


    if not is_instance_valid(hover_info_data):
        return text

    for bb_container_data in hover_info_data.bb_container_data_arr:
        if bb_container_data.text == "\n" or bb_container_data.text == "\\n":
            text += "|" + "\\n"
            continue


        var special_name: String = ""

        if not bb_container_data.stat_resource.name.is_empty():
            special_name = bb_container_data.stat_resource.name

        if is_instance_valid(bb_container_data.status_effect_resource):
            special_name = bb_container_data.status_effect_resource.name


        for ref_object in bb_container_data.ref_objects:
            if ref_object is Keyword:
                special_name = ref_object.name

            if ref_object is Passive:
                special_name = ref_object.name


        if is_instance_valid(bb_container_data.bb_counter):
            var symbol: String = "["

            if bb_container_data.is_counter:
                symbol = "[*"

            if is_instance_valid(bb_container_data.bb_counter.item_set_resource):
                text += "|" + symbol + str(bb_container_data.bb_counter.amount) + "@" + get_fixed_key(bb_container_data.bb_counter.item_set_resource.name, "") + "]"

            if is_instance_valid(bb_container_data.bb_counter.stat_resource):
                text += "|" + symbol + str(bb_container_data.bb_counter.amount) + "@" + get_fixed_key(bb_container_data.bb_counter.stat_resource.name, "") + "]"

            continue


        if is_instance_valid(bb_container_data.item_set_resource):
            if bb_container_data.is_multiplier:
                if bb_container_data.specialization:
                    text += "|" + "[*" + get_fixed_key(bb_container_data.specialization.name, "") + "]"
                    continue
                text += "|" + "[*" + get_fixed_key(bb_container_data.item_set_resource.name, "") + "]"
                continue

            if bb_container_data.hide_name:
                text += "|" + "[-" + get_fixed_key(bb_container_data.item_set_resource.name, "") + "]"
                continue

            special_name = bb_container_data.item_set_resource.name


        if is_instance_valid(bb_container_data.ability):
            special_name = bb_container_data.ability.name


        if is_instance_valid(bb_container_data.trial):
            special_name = bb_container_data.trial.name


        if is_instance_valid(bb_container_data.battle_action):
            if bb_container_data.show_cost:
                text += "|" + "[$" + get_fixed_key(bb_container_data.battle_action.name, "") + "]"
                continue
            special_name = bb_container_data.battle_action.name


        if special_name.length():
            text += "|" + "[" + get_fixed_key(special_name, "") + "]"

            if bb_container_data.is_value:
                text += "*"

            continue



        if bb_container_data.tag.name.length():
            text += "|" + "{" + bb_container_data.tag.name + "}"
            continue


        var color_text: String = ""
        if not bb_container_data.text_color == Color.DARK_GRAY:
            color_text = "<" + bb_container_data.text_color.to_html(false) + ">"

        text += "|" + color_text + bb_container_data.text.replace(",", ";")


    text = text.trim_prefix("|")

    return text








func get_translated_string(key: String, type: String = "Text") -> String:
    var search_key: String = get_fixed_key(key, type)
    var lang: String = "english"
    var result: String = ""


    if not translations.has(search_key):
        return key

    if TranslationServer.get_locale() == "None":
        if type == "Text" and translations.has(search_key):
            return translations[search_key][lang]
        return key

    if translations[search_key][TranslationServer.get_locale()].length():
        lang = TranslationServer.get_locale()

    result = translations[search_key][lang]

    result = result.replace("\\n", "\n")
    result = result.replace(";", ",")


    return result




func get_translated_bb_code(key: String, type: String = "") -> Array[BBContainerData]:
    var search_key: String = get_fixed_key(key, type)

    if not type.length():
        search_key = key

    if not translations.has(search_key):
        return []

    if TranslationServer.get_locale() == "None":
        return []

    if not translations[search_key][TranslationServer.get_locale()].size():
        return translations[search_key]["english"]

    return translations[search_key][TranslationServer.get_locale()]





func get_fixed_key(key: String, type: String) -> String:
    var chars_to_clean: Array[String] = [":", ".", "'", "[", "]"]
    var fixed_key: String = key.to_snake_case()

    fixed_key = fixed_key.replace(" ", "-")
    fixed_key = fixed_key.replace("_", "-")

    for char in chars_to_clean:
        fixed_key = fixed_key.replace(char, "")

    if type.length():
        fixed_key = fixed_key + "-" + type.to_lower().replace(" ", "-")

    return fixed_key




func get_translation_file_path() -> String:
    var translation_file_path: String = File.get_file_dir() + "/" + "translations_override.csv"

    if not FileAccess.file_exists(translation_file_path):
        return MAIN_TRANSLATION_CSV_PATH

    return translation_file_path
