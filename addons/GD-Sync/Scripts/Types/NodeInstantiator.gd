@tool
@icon("res://addons/GD-Sync/UI/Icons/NodeInstantiator.png")
extends Node
class_name NodeInstantiator

























func instantiate_node() -> Node:
    var node: Node = scene.instantiate()
    read_original_properties(node)
    var id: int = _assign_instance_id(node)
    node.name = str(id)
    node.propagate_call("set_meta", ["PauseSync", false])

    if target:
        target.add_child(node)
    else:
        add_child(node)

    _send_remote_instantiate.call_deferred(node, _original_properties)
    _call_multiplayer_ready(node)
    node_instantiated.emit(node)
    return node







enum SPAWN_TYPE{

    NODE_PATH, 

    SCENE_ROOT
}

signal node_instantiated(node: Node)


@export var spawn_type: SPAWN_TYPE = SPAWN_TYPE.SCENE_ROOT: set = _set_spawn_type

var target_location: NodePath
var target: Node
var target_path: String

var scene: PackedScene


var replicate_on_join: bool = true







var sync_starting_changes: bool = true:
    set(value):
        sync_starting_changes = value
        notify_property_list_changed()

var excluded_properties: PackedStringArray = []

const _PERMANENT_EXCLUDED_PROPERTIES: PackedStringArray = [
    "position", 
    "rotation", 
    "scale"
]

var GDSync

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _node_id_list: Dictionary = {}

var _original_properties = null

var replicate_settings = null

func _ready() -> void :
    if Engine.is_editor_hint(): return

    GDSync = get_node("/root/GDSync")
    GDSync.expose_func(_instantiate_remote)
    GDSync.expose_func(_set_target_remote)
    _rng.randomize()

    if spawn_type == SPAWN_TYPE.SCENE_ROOT:
        target = get_tree().current_scene
    elif spawn_type == SPAWN_TYPE.NODE_PATH:
        target = get_node(target_location)

    target_path = str(target.get_path())

    if replicate_settings == null:
        replicate_settings = [
            get_path(), 
            sync_starting_changes, 
            excluded_properties, 
            scene.resource_path if scene != null else null, 
            target.get_path(), 
            {}
        ]

func _call_multiplayer_ready(node: Node) -> void :
    await get_tree().process_frame
    if is_instance_valid(node):
        node.propagate_call("_multiplayer_ready")

func _get_random_id() -> int:
    var id: int = _rng.randi()
    if _node_id_list.has(id):
        return _get_random_id()
    return id

func _assign_instance_id(node: Node) -> int:
    var id: int = _get_random_id()
    var instantiator_path: String = str(get_path())
    _node_id_list[id] = node
    node.set_meta("GDID", id)
    node.set_meta("Instantiator", instantiator_path)

    if replicate_on_join:
        GDSync._node_tracker.register_replication(node, instantiator_path, replicate_settings)

    _await_id_deletion(node)
    return id

func _await_id_deletion(node: Node) -> void :
    await node.tree_exiting
    var id: int = node.get_meta("GDID")

    if _node_id_list.has(id):
        _node_id_list.erase(id)

    if replicate_on_join:
        GDSync._node_tracker.deregister_replication(node)

func _send_remote_instantiate(node: Node, starting_properties: Dictionary) -> void :
    var changed_properties: Dictionary = {}

    if sync_starting_changes:
        var new_properties: Dictionary = _get_properties_as_bytes(node)

        for name in starting_properties:
            if new_properties[name] != starting_properties[name]:
                var new_value = bytes_to_var(new_properties[name])
                var type: int = typeof(new_value)
                match (type):
                    TYPE_OBJECT: continue
                    TYPE_CALLABLE: continue
                    TYPE_SIGNAL: continue
                    TYPE_RID: continue
                if _PERMANENT_EXCLUDED_PROPERTIES.has(name): continue
                if excluded_properties.has(name): continue
                if _contains_object(new_value): continue
                changed_properties[name] = new_value

    GDSync.call_func(_instantiate_remote, [node.get_meta("GDID"), changed_properties])
    node.propagate_call("remove_meta", ["PauseSync"])

func _contains_object(value) -> bool:
    if value is Object: return true

    if value is Array:
        for element in value:
            if _contains_object(element):
                return true

    if value is Dictionary:
        for key in value:
            if _contains_object(key) or _contains_object(value[key]):
                return true

    return false

func _set_target_remote(target_path: String) -> void :
    self.target_path = target_path
    target = get_node_or_null(target_path)

func _instantiate_remote(id: int, changed_properties: Dictionary) -> void :
    var instantiator_path: String = str(get_path())
    var node: Node = scene.instantiate()
    read_original_properties(node)
    _node_id_list[id] = node
    node.set_meta("GDID", id)
    node.set_meta("Instantiator", instantiator_path)
    if replicate_on_join:
        GDSync._node_tracker.register_replication(node, instantiator_path, replicate_settings)
    _await_id_deletion(node)
    node.name = str(id)

    if !is_instance_valid(target):
        target = get_node_or_null(target_path)
    if target == null:
        push_error("Instantiate failed, target not found")
        return

    if target:
        target.add_child(node)
    else:
        add_child(node)

    for name in changed_properties:
        node.set(name, changed_properties[name])

    node.propagate_call("_multiplayer_ready")
    node_instantiated.emit(node)

func _get_properties_as_bytes(node: Node) -> Dictionary:
    var property_values: Dictionary = {}
    for property in node.get_property_list():
        var property_name: String = property["name"]
        if property_name.begins_with("global_"):
            continue
        property_values[property_name] = var_to_bytes(node.get(property_name))

    return property_values

func read_original_properties(node: Node) -> void :
    if _original_properties == null:
        _original_properties = _get_properties_as_bytes(node)
        replicate_settings[ENUMS.NODE_REPLICATION_SETTINGS.ORIGINAL_PROPERTIES] = _original_properties

func _set_spawn_type(t: int) -> void :
    spawn_type = t
    notify_property_list_changed()

func _get_property_list() -> Array:
    var properties: Array = []

    properties.append({
        "name": "target_location", 
        "type": TYPE_NODE_PATH, 
        "usage": PROPERTY_USAGE_DEFAULT if spawn_type == SPAWN_TYPE.NODE_PATH else PROPERTY_USAGE_NO_EDITOR
    })

    properties.append({
        "name": "scene", 
        "type": TYPE_OBJECT, 
        "hint": PROPERTY_HINT_RESOURCE_TYPE, 
        "hint_string": "PackedScene"
    })

    properties.append({
        "name": "replicate_on_join", 
        "type": TYPE_BOOL, 
        "usage": PROPERTY_USAGE_DEFAULT
    })

    properties.append({
        "name": "sync_starting_changes", 
        "type": TYPE_BOOL, 
        "usage": PROPERTY_USAGE_DEFAULT
    })

    properties.append({
        "name": "excluded_properties", 
        "type": TYPE_PACKED_STRING_ARRAY, 
        "usage": PROPERTY_USAGE_DEFAULT if sync_starting_changes else PROPERTY_USAGE_NO_EDITOR
    })

    return properties
