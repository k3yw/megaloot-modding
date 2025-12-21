class_name File






static func get_file_paths(path: String) -> Array[String]:
    var dir = DirAccess.open(path)
    var file_paths: Array[String] = []

    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while not file_name == "":
            if not dir.current_is_dir():
                file_paths.push_back(file_name)
            file_name = dir.get_next()

    return file_paths


static func load_resources(arr: Array, dir: String) -> void :
    for file_name in get_file_paths(dir):
        var file_path: String = dir + file_name

        if ".tres.remap" in file_path:
            file_path = file_path.trim_suffix(".remap")

        var res = load(file_path)
        if not is_instance_valid(res):
            print("failed to load stat resource: " + file_path)
            continue

        arr.push_back(res)



static func json_to_dict(file_path: String) -> Dictionary:
    var file = FileAccess.open(file_path, FileAccess.READ)

    if file == null:
        print("Failed to open file: ", file_path)
        return {}

    var json_string = file.get_as_text()
    file.close()

    var json = JSON.new()
    var parse_result = json.parse(json_string)

    if parse_result != OK:
        print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
        return {}

    var dictionary = json.data
    if typeof(dictionary) != TYPE_DICTIONARY:
        print("JSON file does not contain a valid dictionary.")
        return {}

    return dictionary





static func get_user_file_dir() -> String:
    if ISteam.is_active():
        var install_dir = ISteam.steam.getAppInstallDir(ISteam.get_app_id())
        if install_dir.has("directory"):
            return install_dir["directory"].replace("\\", "/") + "/" + str(ISteam.get_steam_id())

    return "user://"


static func get_file_dir() -> String:
    if ISteam.is_active():
        var install_dir = ISteam.steam.getAppInstallDir(ISteam.steam.getAppID())
        if install_dir.has("directory"):
            return ISteam.steam.getAppInstallDir(ISteam.steam.getAppID())["directory"].replace("\\", "/")

    return "user://"
