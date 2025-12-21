class_name SteamHandles extends RefCounted





var names: Array[String] = []
var handles: Array[int] = []






func set_handle(arg_name: String, handle: int) -> void :
    var idx = names.find(arg_name)

    if idx == -1:
        idx = names.size()

    if handles.size() - 1 < idx:
        handles.resize(idx + 1)
        names.resize(idx + 1)

    handles[idx] = handle
    names[idx] = arg_name



func get_handle(arg_name: String) -> int:
    var idx = names.find(arg_name)

    if idx == -1:
        return -1

    return handles[idx]



func from_handle(arg_handle: int) -> String:
    var idx = handles.find(arg_handle)

    if idx == -1:
        return ""

    return names[idx]
