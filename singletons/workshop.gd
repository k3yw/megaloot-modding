extends Node

const TO_LOAD_DIR: String = "res://to_load/"

var published_items: Array

var page_number: int = 1
var query_handler: int

var active_mods: Array[String] = []



func _init() -> void :
    Steam.ugc_query_completed.connect(_on_query_completed)
    Steam.item_downloaded.connect(_on_item_downloaded)

    for item in Steam.getSubscribedItems():
        var info: Dictionary
        info = get_item_install_info(item)

        if info["ret"] == false:
            Steam.downloadItem(item, true)
            continue

        var path: String = info["folder"]
        path = path.replace("//", "/")

        var dir = DirAccess.open(path)
        if dir:
            dir.list_dir_begin()
            var file_name = dir.get_next()
            while not file_name == "":
                print("found subscribed file: ", file_name)
                if file_name.ends_with(".pck") or file_name.ends_with(".zip"):
                    var success = ProjectSettings.load_resource_pack(path + "/" + file_name)
                    print("loaded pck result: ", file_name, " -> ", success)
                    if success:
                        active_mods.push_back(file_name)

                file_name = dir.get_next()


    for file_name in File.get_file_paths(TO_LOAD_DIR):
        if try_to_load_file(TO_LOAD_DIR + file_name):
            print("loaded: " + file_name)
            continue

        print("failed to load: " + file_name)




func try_to_load_file(file_path: String) -> bool:
    var file = null

    match file_path.get_extension():
        ".gd":
            file = (load(file_path) as GDScript).new()
            if is_instance_valid(file):
                return true

        ".tscn":
            file = (load(file_path) as PackedScene).instantiate()
            if is_instance_valid(file):
                return true


    file = load(file_path)

    if is_instance_valid(file):
        return true

    return false




func _on_item_downloaded(result: int, file_id: int, app_id: int) -> void :
    print("download item result: ", result, " : ", file_id, " : ", app_id)



func _on_query_completed(_p_query_handler: int, p_result: int, p_results_returned: int, _p_total_matching: int, _p_cached: bool) -> void :
    if p_result == Steam.RESULT_OK:
        fetch_query_result(p_results_returned)
    else:
        print("Couldn't get published items. Error: " + str(p_result))

    if p_result == 50:
        page_number += 1
        get_published_items(page_number)


func get_published_items(p_page: int = 1, p_only_ids: bool = false) -> void :
    var user_id: int = Steam.getSteamID()
    var app_id: int = Platform.get_app_id()
    var list: int = Steam.USER_UGC_LIST_PUBLISHED
    var type: int = Steam.WORKSHOP_FILE_TYPE_COMMUNITY
    var sort: int = Steam.USER_UGC_LIST_SORT_ORDER_CREATION_ORDER_DESC

    query_handler = Steam.createQueryUserUGCRequest(user_id, list, type, sort, app_id, app_id, p_page)
    Steam.setReturnOnlyIDs(query_handler, p_only_ids)
    Steam.sendQueryUGCRequest(query_handler)


func fetch_query_result(p_number_results: int) -> void :
    var result: Dictionary
    for i in range(p_number_results):
        result = Steam.getQueryUGCResult(query_handler, i)
        published_items.append(result)

    Steam.releaseQueryUGCRequest(query_handler)


func get_item_install_info(p_item_id: int) -> Dictionary:
    var info: Dictionary
    info = Steam.getItemInstallInfo(p_item_id)

    if info["ret"] == false:
        print("Item " + str(p_item_id) + " isn't installed or has no content")

    return info
