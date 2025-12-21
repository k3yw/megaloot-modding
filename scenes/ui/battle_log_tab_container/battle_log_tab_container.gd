class_name BattleLogTabContainer extends MarginContainer


enum PageType{CURRENT_BATTLE, LAST_BATTLE}

@export var scroll_container: GenericScrollContainer
@export var battle_log_page_container: Control
@export var log_clip: ClipContainer

@export var next_page_button: GenericButton
@export var last_page_button: GenericButton
@export var turn_label: GenericLabel

@export var current_battle_label: GenericLabel


var last_phantom_battle_log_pages: Dictionary[int, Array] = {}
var last_battle_log_pages: Dictionary[int, Array] = {}

var phantom_battle_log_pages: Dictionary[int, Array] = {}
var battle_log_pages: Dictionary[int, Array] = {}

var current_page_type: PageType = PageType.CURRENT_BATTLE
var is_phantom_page: bool = false
var current_turn_page: int = 1

var loaded_log_bbs: Dictionary = {}
var log_bb_start_idx: int = 0

var last_log_bb: Array[BBContainerData] = []
var repeats: int = 1




func _ready() -> void :
    visibility_changed.connect(_on_visibility_changed)

    next_page_button.pressed.connect( func():
        _on_next_page_button_pressed()
        update_all()
        )

    last_page_button.pressed.connect( func():
        _on_last_page_button_pressed()
        update_all()
        )




func _on_next_page_button_pressed() -> void :
    current_turn_page += 1

    match current_page_type:
        PageType.CURRENT_BATTLE:
            if not is_phantom_page and not battle_log_pages.has(current_turn_page):
                current_turn_page -= 1
                return

            if is_phantom_page and not phantom_battle_log_pages.has(current_turn_page):
                is_phantom_page = false
                current_turn_page = 1
                return


        PageType.LAST_BATTLE:
            if not is_phantom_page and not last_battle_log_pages.has(current_turn_page):
                if phantom_battle_log_pages.size() > 0:
                    current_page_type = PageType.CURRENT_BATTLE
                    is_phantom_page = true
                    current_turn_page = 1
                    return

                if battle_log_pages.size() > 0:
                    current_page_type = PageType.CURRENT_BATTLE
                    current_turn_page = 1
                    return


            if is_phantom_page and not last_phantom_battle_log_pages.has(current_turn_page):
                if last_battle_log_pages.size() > 0:
                    is_phantom_page = false
                    current_turn_page = 1
                    return

                if phantom_battle_log_pages.size() > 0:
                    current_page_type = PageType.CURRENT_BATTLE
                    is_phantom_page = true
                    current_turn_page = 1
                    return

                if battle_log_pages.size() > 0:
                    current_page_type = PageType.CURRENT_BATTLE
                    current_turn_page = 1
                    return








func _on_last_page_button_pressed() -> void :
    current_turn_page -= 1

    match current_page_type:
        PageType.CURRENT_BATTLE:
            if not is_phantom_page and not battle_log_pages.has(current_turn_page):
                if phantom_battle_log_pages.size() > 0:
                    current_turn_page = phantom_battle_log_pages.size()
                    is_phantom_page = true
                    return

                if last_battle_log_pages.size() > 0:
                    current_turn_page = last_battle_log_pages.size()
                    current_page_type = PageType.LAST_BATTLE
                    is_phantom_page = false
                    return

                if last_phantom_battle_log_pages.size() > 0:
                    current_turn_page = last_phantom_battle_log_pages.size()
                    current_page_type = PageType.LAST_BATTLE
                    is_phantom_page = true
                    return

                current_turn_page += 1
                return


            if is_phantom_page:
                if last_battle_log_pages.size() > 0:
                    current_turn_page = last_battle_log_pages.size()
                    current_page_type = PageType.LAST_BATTLE
                    is_phantom_page = false
                    return

                if last_phantom_battle_log_pages.size() > 0:
                    current_turn_page = last_phantom_battle_log_pages.size()
                    current_page_type = PageType.LAST_BATTLE
                    is_phantom_page = true
                    return

                current_turn_page += 1
                return


        PageType.LAST_BATTLE:
            if not is_phantom_page and not last_battle_log_pages.has(current_turn_page):
                if last_phantom_battle_log_pages.size() > 0:
                    current_turn_page = last_phantom_battle_log_pages.size()
                    is_phantom_page = true
                    return

                current_turn_page += 1
                return

            if is_phantom_page and not last_phantom_battle_log_pages.has(current_turn_page):
                current_turn_page += 1
                return





func _process(_delta: float) -> void :
    var new_log_bb_start_idx: int = floori(float(scroll_container.scroll_container.scroll_vertical) / 16)
    if not log_bb_start_idx == new_log_bb_start_idx:
        update_bbs()

    log_bb_start_idx = new_log_bb_start_idx

    process_buttons()




func process_buttons() -> void :
    next_page_button.disabled = false
    last_page_button.disabled = false


    match current_page_type:
        PageType.CURRENT_BATTLE:
            if not is_phantom_page and not battle_log_pages.has(current_turn_page + 1):
                next_page_button.disabled = true

            if not is_phantom_page and not battle_log_pages.has(current_turn_page - 1):
                if not phantom_battle_log_pages.size() > 0 and not last_battle_log_pages.size() > 0 and not last_phantom_battle_log_pages.size():
                    last_page_button.disabled = true

            if is_phantom_page and not phantom_battle_log_pages.has(current_turn_page - 1):
                if not last_battle_log_pages.size() > 0 and not last_phantom_battle_log_pages.size():
                    last_page_button.disabled = true


        PageType.LAST_BATTLE:
            if not is_phantom_page and not last_battle_log_pages.has(current_turn_page - 1):
                if not last_phantom_battle_log_pages.size() > 0:
                    last_page_button.disabled = true

            if is_phantom_page and not last_phantom_battle_log_pages.has(current_turn_page - 1):
                last_page_button.disabled = true




func reset_for_phantom() -> void :
    phantom_battle_log_pages = battle_log_pages.duplicate()
    battle_log_pages = {}

    current_turn_page = phantom_battle_log_pages.size()
    is_phantom_page = true
    update_all()



func reset_for_new_battle() -> void :
    last_phantom_battle_log_pages = phantom_battle_log_pages.duplicate()
    last_battle_log_pages = battle_log_pages.duplicate()
    phantom_battle_log_pages = {}
    battle_log_pages = {}

    is_phantom_page = false
    current_turn_page = 1

    update_all()



func get_visible_bbs() -> Array[Array]:
    var visible_bbs: Array[Array] = []
    var visible_amount: int = int(float(scroll_container.scroll_container.size.y) / 16)
    var start_idx: int = floori(float(scroll_container.scroll_container.scroll_vertical) / 16)

    if not battle_log_pages.has(current_turn_page):
        return visible_bbs

    for idx in range(start_idx, start_idx + visible_amount):
        if battle_log_pages[current_turn_page].size() - 1 < idx:
            continue
        visible_bbs.push_back(battle_log_pages[current_turn_page][idx])

    return visible_bbs



func add_to_log(bb_container_data_arr: Array[BBContainerData], turn: int) -> void :
    if not battle_log_pages.has(turn):
        battle_log_pages[turn] = []

    if not last_log_bb.is_empty():
        var curr_id: String = ""
        var last_id: String = ""

        for bb in bb_container_data_arr:
            if not is_instance_valid(bb):
                continue
            curr_id += bb.text

        for bb in last_log_bb:
            if not is_instance_valid(bb):
                continue
            last_id += bb.text

        if last_id == curr_id:
            var new_bb: Array[BBContainerData] = last_log_bb.duplicate()
            repeats += 1

            new_bb.push_back(BBContainerData.new(" x" + str(repeats)))

            battle_log_pages[turn].pop_back()
            battle_log_pages[turn].push_back(new_bb)

            update_bbs()
            return


    battle_log_pages[turn].push_back(bb_container_data_arr)
    last_log_bb = bb_container_data_arr
    repeats = 1

    update_bbs()




func update_all() -> void :
    update_page()
    update_bbs()



func get_curr_page_dict() -> Dictionary:
    match get_curr_page_type():
        [PageType.LAST_BATTLE, true]: return last_phantom_battle_log_pages
        [PageType.LAST_BATTLE, false]: return last_battle_log_pages
        [PageType.CURRENT_BATTLE, true]: return phantom_battle_log_pages
        [PageType.CURRENT_BATTLE, false]: return battle_log_pages

    return {}


func get_curr_page_type() -> Array:
    return [current_page_type, is_phantom_page]


func get_active_bb_indexes() -> Array:
    if not is_visible_in_tree():
        return []

    while scroll_container.scroll_container.size.y == 0.0:
        await get_tree().process_frame

    var visible_amount: int = int(float(scroll_container.scroll_container.size.y) / 16)
    var start_idx: int = floori(float(scroll_container.scroll_container.scroll_vertical) / 16)
    return range(start_idx, start_idx + visible_amount)



func get_text_label(type: Array, turn: int, idx: int) -> GenericRichTextLabel:
    var text_label = loaded_log_bbs[type][turn][idx]
    if not is_instance_valid(text_label):
        return null
    return text_label as GenericRichTextLabel



func update_bbs() -> void :
    var active_bb_indexes: Array = await get_active_bb_indexes()
    var curr_type: Array = get_curr_page_type()
    update_container_size()


    for type in loaded_log_bbs:
        for turn in loaded_log_bbs[type]:
            var indexes_to_erase: Array[int] = []

            for idx in loaded_log_bbs[type][turn]:
                if active_bb_indexes.has(idx) and type == curr_type:
                    if turn == current_turn_page:
                        continue

                var text_label: GenericRichTextLabel = get_text_label(type, turn, idx)
                text_label.hide()

                battle_log_page_container.remove_child(text_label)
                text_label.queue_free()

                indexes_to_erase.push_back(idx)

            for index_to_erase in indexes_to_erase:
                loaded_log_bbs[type][turn].erase(index_to_erase)



    if not loaded_log_bbs.has(current_turn_page):
        loaded_log_bbs[current_turn_page] = {}

    var page_dict: Dictionary = get_curr_page_dict()
    if not page_dict.has(current_turn_page):
        page_dict[current_turn_page] = []

    reset_loaded_log_bbs()


    for idx in active_bb_indexes:
        if loaded_log_bbs[curr_type][current_turn_page].has(idx):
            continue

        if page_dict[current_turn_page].size() - 1 < idx:
            continue

        add_bb(idx)




func add_bb(idx: int) -> void :
    var page_dict: Dictionary = get_curr_page_dict()
    var type: Array = get_curr_page_type()

    var bb_arr: Array[BBContainerData] = page_dict[current_turn_page][idx]
    var text_label: GenericRichTextLabel = preload("res://scenes/ui/generic_rich_text_label/generic_rich_text_label.tscn").instantiate()
    battle_log_page_container.add_child(text_label)

    for bb in bb_arr:
        if not is_instance_valid(bb):
            continue
        text_label.add_bb_container(bb)

    text_label.position.y = idx * 16

    reset_loaded_log_bbs()

    loaded_log_bbs[type][current_turn_page][idx] = text_label



func reset_loaded_log_bbs() -> void :
    var type: Array = get_curr_page_type()
    if not loaded_log_bbs.has(type):
        loaded_log_bbs[type] = {}

    if not loaded_log_bbs[type].has(current_turn_page):
        loaded_log_bbs[type][current_turn_page] = {}


func update_new_turn(new_turn: int) -> void :
    if not is_phantom_page and current_page_type == PageType.CURRENT_BATTLE:
        if current_turn_page == new_turn - 1:
            current_turn_page = new_turn

    update_all()




func update_page() -> void :
    var dead_text: String = ""
    current_battle_label.text = T.get_translated_string("current-battle").to_upper()

    if current_page_type == PageType.LAST_BATTLE:
        current_battle_label.text = T.get_translated_string("last-battle").to_upper()

    if is_phantom_page:
        dead_text = " " + T.get_translated_string("Dead").to_upper()
    var turn_text: String = T.get_translated_string("Current Turn")

    turn_text = turn_text.replace("{turn-number}", str(current_turn_page)).to_upper()

    turn_label.text = turn_text + dead_text




func update_container_size() -> void :
    var page_dict: Dictionary = get_curr_page_dict()
    if not page_dict.has(current_turn_page):
        return

    var size_y: float = page_dict[current_turn_page].size() * 16
    var size_x: float = 0

    for child in battle_log_page_container.get_children():
        if child is Control:
            size_x = maxf(size_x, child.size.x)


    battle_log_page_container.custom_minimum_size.x = size_x
    log_clip.custom_minimum_size.y = size_y

    log_clip.update_minimum_size()

    battle_log_page_container.size.x = size_x
    log_clip.size.y = size_y

    scroll_container.update()



func copy_log(source: BattleLogTabContainer) -> void :
    last_phantom_battle_log_pages = source.last_phantom_battle_log_pages
    last_battle_log_pages = source.last_battle_log_pages
    phantom_battle_log_pages = source.phantom_battle_log_pages
    battle_log_pages = source.battle_log_pages


func _on_visibility_changed() -> void :
    update_all()
