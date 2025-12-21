@tool
@icon("res://addons/GD-Sync/UI/Icons/SynchronizeIcon.png")
extends Node
class_name PropertySynchronizer




























func synchronize(forced: bool = true, force_reliable: bool = false) -> void :
    for property_name in _property_lookup:
        var property_data: Dictionary = _property_lookup[property_name]
        var new_property = node.get(property_name)
        if _check_property_changed(property_data, new_property):
            GDSync.call_func(_sync_received, [property_name, new_property, GDSync.get_multiplayer_time()], reliable || force_reliable)


func pause_interpolation(seconds: float) -> void :
    _pause_interpolation_remote(seconds)
    GDSync.call_func(_pause_interpolation_remote, [seconds])







enum BROADCAST_MODE{

    WHEN_HOST, 

    WHEN_CLIENT, 

    WHEN_OWNER, 

    WHEN_HOST_OR_LAST_VALID_OWNER, 




    WHEN_HOST_AND_NO_OWNER_OR_OWNER, 

    ALWAYS, 

    NEVER, 
}

signal value_changed(property_name: String, new_value)

enum PROCESS_MODE{

    PROCESS, 

    PHYSICS_PROCESS, 
}


@export var broadcast: BROADCAST_MODE: set = _set_broadcast

@export var process: PROCESS_MODE

@export var refresh_rate: int = 30

@export var node_path: NodePath:
    set(value):
        node_path = value
        node = get_node_or_null(node_path)
        _refresh_property_list()
        update_configuration_warnings()





@export var reliable: bool = false


@export var properties: PackedStringArray = []: set = _set_properties

var property_name: String:
    set(value):
        property_name = value
        _refresh_property_list()
        update_configuration_warnings()






var interpolated: bool = false:
    set(value):
        interpolated = value
        notify_property_list_changed()




var interpolation_speed: float = 1.0



var extrapolated: bool = false:
    set(value):
        extrapolated = value
        notify_property_list_changed()


var max_extrapolation_time: float = 0.2

var GDSync

var node: Node

var _cooldown: float = 0.0
var _current_cooldown: float = 0.0
var _interval_cooldown: float = 0.0
var _should_broadcast: bool = false
var _last_owner: int = -1

var _property_lookup: Dictionary = {}

func _ready() -> void :

    if property_name != "":
        properties.append(property_name)

    node = get_node_or_null(node_path)
    if Engine.is_editor_hint():
        set_process(false)
        set_physics_process(false)
        _refresh_property_lookup()
        _refresh_property_list()
    else:
        assert (node != null, "PropertySynchronizer Node is null")

        GDSync = get_node("/root/GDSync")

        _cooldown = 1.0 / refresh_rate
        _last_owner = GDSync.get_gdsync_owner(self)

        GDSync.expose_func(_sync_received)
        GDSync.expose_func(_pause_interpolation_remote)
        GDSync.host_changed.connect(_host_changed)
        GDSync.client_joined.connect(_client_joined)
        GDSync.client_left.connect(_client_left)
        GDSync.connect_gdsync_owner_changed(self, _owner_changed)

        _refresh_property_lookup()
        _clean_property_lookup()
        _update_sync_mode()
        set_process(process == PROCESS_MODE.PROCESS)
        set_physics_process(process == PROCESS_MODE.PHYSICS_PROCESS)

        if interpolated:
            interpolated = false
            await value_changed
            interpolated = true
        else:
            extrapolated = false

func _pause_interpolation_remote(seconds: float) -> void :
    interpolated = false
    await get_tree().create_timer(seconds).timeout
    interpolated = true

func _set_properties(p: PackedStringArray) -> void :
    properties = p
    _refresh_property_lookup()
    update_configuration_warnings()

func _set_broadcast(mode: int) -> void :
    broadcast = mode
    _update_sync_mode()

func _owner_changed(owner) -> void :
    if owner >= 0: _last_owner = owner
    _update_sync_mode()

func _host_changed(is_host: bool, new_host_id: int) -> void :
    _update_sync_mode()

func _update_sync_mode() -> void :
    if Engine.is_editor_hint() || GDSync == null: return
    var is_host: bool = GDSync.is_host()
    var is_owner: bool = GDSync.is_gdsync_owner(self)
    match (broadcast):
        BROADCAST_MODE.WHEN_HOST:
            _should_broadcast = is_host
        BROADCAST_MODE.WHEN_CLIENT:
            _should_broadcast = !is_host
        BROADCAST_MODE.WHEN_OWNER:
            _should_broadcast = is_owner
        BROADCAST_MODE.WHEN_HOST_OR_LAST_VALID_OWNER:
            var valid_owner: bool = GDSync.lobby_get_all_clients().has(_last_owner)
            _should_broadcast = (is_host and !valid_owner) || (valid_owner and _last_owner == GDSync.get_client_id())
        BROADCAST_MODE.WHEN_HOST_AND_NO_OWNER_OR_OWNER:
            _should_broadcast = (is_host and GDSync.get_gdsync_owner(self) < 0) || is_owner
        BROADCAST_MODE.ALWAYS:
            _should_broadcast = true
        BROADCAST_MODE.NEVER:
            _should_broadcast = false

func _process(delta: float) -> void :
    _check_property_states(delta)

func _physics_process(delta: float) -> void :
    _check_property_states(delta)

func _check_property_states(delta: float) -> void :
    if !GDSync.is_active(): return
    if _should_broadcast:
        if _may_synchronize(delta):
            synchronize(false)
    else:
        if interpolated: _interpolate(delta)
        if extrapolated: _extrapolate(delta)

func _check_property_changed(property_data: Dictionary, new_property) -> bool:
    if property_data["Type"] == TYPE_DICTIONARY:
        if property_data["TargetValue"] == null or !new_property.recursive_equal(property_data["TargetValue"], 5):
            property_data["TargetValue"] = new_property.duplicate(true)
            return true

    if property_data["Type"] == TYPE_ARRAY:
        if new_property != property_data["TargetValue"]:
            property_data["TargetValue"] = new_property.duplicate(true)
            return true

    if new_property != property_data["TargetValue"]:
        property_data["TargetValue"] = new_property
        return true

    return false

func _may_synchronize(delta: float) -> bool:
    _current_cooldown -= delta
    if _current_cooldown <= 0:
        _current_cooldown += _cooldown
        return true
    return false

func _client_joined(client_id: int) -> void :
    if _should_broadcast:
        synchronize(true, true)

func _client_left(client_id: int) -> void :
    _update_sync_mode()

func _sync_received(property_name: String, new_value, send_time: float) -> void :
    if !_property_lookup.has(property_name): return

    var property_data: Dictionary = _property_lookup[property_name]
    property_data["LastValue"] = property_data["TargetValue"]
    property_data["TargetValue"] = new_value
    property_data["ReceivedValue"] = new_value
    property_data["LastSyncTime"] = send_time

    if !interpolated || !property_data["IsFloating"]:
        node.set(property_name, new_value)
        value_changed.emit(property_name, new_value)

func _interpolate(delta: float) -> void :
    for property_name in _property_lookup:
        var property_data: Dictionary = _property_lookup[property_name]
        if !property_data["IsFloating"]: continue

        var current_value = node.get(property_name)
        var target_value = property_data.get("TargetValue", current_value)

        if current_value == null || target_value == null: continue

        if property_data["Type"] == TYPE_BASIS:
            current_value = current_value.orthonormalized()
            target_value = target_value.orthonormalized()

            var scale: Vector3 = node.scale

            var lerped_value = lerp(current_value, target_value, delta * interpolation_speed)
            node.set(property_name, lerped_value)

            node.scale = scale
            value_changed.emit(property_name, lerped_value)
        else:
            var lerped_value = lerp(current_value, target_value, delta * interpolation_speed)
            node.set(property_name, lerped_value)
            value_changed.emit(property_name, lerped_value)

func _extrapolate(delta: float) -> void :
    for property_name in _property_lookup:
        var property_data: Dictionary = _property_lookup[property_name]
        if !property_data["IsFloating"]: continue

        var last_value = property_data.get("LastValue")
        var target_value = property_data.get("ReceivedValue")

        if last_value == null || target_value == null: continue
        var extrapolate_time: float = min(GDSync.get_multiplayer_time() - property_data["LastSyncTime"], max_extrapolation_time)

        if property_data["Type"] == TYPE_VECTOR3:
            var vec_delta: Vector3 = target_value - last_value
            property_data["TargetValue"] = target_value + vec_delta * extrapolate_time
        elif property_data["Type"] == TYPE_VECTOR2:
            var vec_delta: Vector2 = target_value - last_value
            property_data["TargetValue"] = target_value + vec_delta * extrapolate_time

func _refresh_property_lookup() -> void :
    if node == null: return
    _property_lookup.clear()

    var property_list: Array = node.get_property_list()
    if node.get_script() != null:
        var script: Script = node.get_script()
        if script.get_class() != "CSharpScript":
            property_list.append_array(script.get_script_property_list())
        else:
            property_list.append_array(parse_csharp_properties(script))

    for property_name in properties:
        var property_data: Dictionary = {
            "TargetValue": null, 
            "ReceivedValue": null, 
            "LastValue": null, 
            "LastSyncTime": 0.0, 
            "Type": -1, 
            "IsFloating": false, 
            "Exists": false
        }
        _property_lookup[property_name] = property_data
        for node_property in property_list:
            if node_property["name"] == property_name:
                var property_type: int = node_property["type"]
                property_data["Exists"] = true
                property_data["Type"] = property_type

                var is_floating: bool = (property_type == TYPE_INT
                    || property_type == TYPE_FLOAT
                    || property_type == TYPE_VECTOR2
                    || property_type == TYPE_VECTOR3
                    || property_type == TYPE_VECTOR4
                    || property_type == TYPE_COLOR
                    || property_type == TYPE_QUATERNION
                    || property_type == TYPE_BASIS)
                property_data["IsFloating"] = is_floating

                break

func parse_csharp_properties(script: Script) -> Array[Dictionary]:
    var csharp_code: String = FileAccess.get_file_as_string(script.resource_path)
    var lines: PackedStringArray = csharp_code.split("\n")

    var variables: Array[Dictionary] = []
    var inside_method: bool = false
    var brace_level: int = 0
    var method_regex: RegEx = RegEx.new()
    var var_regex: RegEx = RegEx.new()
    method_regex.compile("^(?:public|private|protected|internal|static|virtual|override|sealed|async|new|\\s)*\\s*\\w+\\s+\\w+\\s*\\(.*\\)\\s*\\{?$")
    var_regex.compile("^(?:public|private|protected|internal|static|const|readonly|\\s)*\\s*(\\w+)\\s+(\\w+)\\s*(=.*)?;")

    var type_mapping: Dictionary = {
        "float": TYPE_FLOAT, 
        "Vector2": TYPE_VECTOR2, 
        "Vector3": TYPE_VECTOR3, 
        "Vector4": TYPE_VECTOR4, 
        "Color": TYPE_COLOR, 
        "Quaternion": TYPE_QUATERNION, 
        "Basis": TYPE_BASIS, 
    }

    for line in lines:
        line = line.strip_edges()
        if line == "" or line.begins_with("//"):
            continue
        brace_level += line.count("{") - line.count("}")
        if not inside_method:
            if method_regex.search(line):
                inside_method = true
                continue
            var var_match: RegExMatch = var_regex.search(line)
            if var_match:
                var type_name: String = var_match.get_string(1)
                var var_name: String = var_match.get_string(2)
                if type_name in type_mapping:
                    variables.append({"name": var_name, "type": type_mapping[type_name]})
        else:
            if brace_level == 0:
                inside_method = false
    return variables

func _clean_property_lookup() -> void :
    for property_name in _property_lookup:
        var property_data: Dictionary = _property_lookup[property_name]
        if !property_data["Exists"]: _property_lookup.erase(property_name)

func _get_configuration_warnings() -> PackedStringArray:
    var node: Node = get_node_or_null(node_path)
    if node == null:
        return ["No NodePath is specified."]

    var warnings: PackedStringArray = []

    _refresh_property_lookup()
    for property_name in _property_lookup:
        var property_data: Dictionary = _property_lookup[property_name]
        if !property_data["Exists"]:
            warnings.append("The selected Node does not have the property \"" + property_name + "\"")

    return warnings

func _refresh_property_list() -> void :
    notify_property_list_changed()

func _get_property_list() -> Array:
    var properties: Array = []

    properties.append({
        "name": "interpolation", 
        "type": TYPE_BOOL, 
        "usage": PROPERTY_USAGE_GROUP
    })

    properties.append({
        "name": "interpolated", 
        "type": TYPE_BOOL, 
        "usage": PROPERTY_USAGE_DEFAULT
    })

    properties.append({
        "name": "interpolation_speed", 
        "type": TYPE_FLOAT, 
        "usage": PROPERTY_USAGE_DEFAULT if interpolated else PROPERTY_USAGE_NO_EDITOR
    })

    properties.append({
        "name": "extrapolation", 
        "type": TYPE_BOOL, 
        "usage": PROPERTY_USAGE_GROUP if interpolated else PROPERTY_USAGE_NO_EDITOR
    })

    properties.append({
        "name": "extrapolated", 
        "type": TYPE_BOOL, 
        "usage": PROPERTY_USAGE_DEFAULT if interpolated else PROPERTY_USAGE_NO_EDITOR
    })

    properties.append({
        "name": "max_extrapolation_time", 
        "type": TYPE_FLOAT, 
        "usage": PROPERTY_USAGE_DEFAULT if interpolated and extrapolated else PROPERTY_USAGE_NO_EDITOR
    })

    return properties
