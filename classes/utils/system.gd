class_name System


enum VersionType{FULL, PLAYTEST, DEMO}






static func get_version_type() -> VersionType:
    if Platform.get_app_id() == 2461710:
        return VersionType.DEMO

    if OS.has_feature("demo"):
        return VersionType.DEMO

    return VersionType.FULL


static func is_demo() -> bool:
    return get_version_type() == VersionType.DEMO


static func get_version() -> String:
    return "1.23.1"
