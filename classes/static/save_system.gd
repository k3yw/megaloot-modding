class_name SaveSystem extends RefCounted







static func get_value(value):
    if not is_instance_valid(value):
        return value

    if value is Resource:
        return value.resource_path

    if value is Object:
        return get_data(value)

    if value is float:
        if value == - INF:
            value = "-inf"

    return value




static func get_data(object: Object) -> Dictionary:
    if not is_instance_valid(object):
        return {}

    var object_dict: Dictionary = inst_to_dict(object)
    var data_dict: Dictionary = {}


    for name in object_dict.keys():
        if (name as String).begins_with("@"):
            continue

        if (name as String).begins_with("_"):
            continue

        var value = object_dict[name]


        if value is Array:
            var new_array: Array = []
            for element in value:
                new_array.push_back(get_value(element))

            data_dict[name] = new_array
            continue


        data_dict[name] = get_value(value)


    return data_dict








static func deserialize(property, value):
    if property is Resource:
        if value is String:
            if not value.begins_with("res://"):
                return value

            if ResourceLoader.exists(value):
                return load(value)

        return null


    if property is Object:
        var new_property = (property.get_script() as GDScript).new()

        if value == null:
            value = {}

        if not value is Dictionary:
            value = {}

        load_data(new_property, value)
        return new_property





    if property is float:
        if value is String:
            if value == "-inf":
                return - INF

    return value







static func load_data(object: Object, data_dict: Dictionary) -> void :
    for property_name in data_dict:
        var property = object.get(String(property_name))
        var deserialized = null

        if property == null:
            continue


        if property is Array:
            var typed_script = property.get_typed_script()
            var arr_property = null

            property.clear()

            if is_instance_valid(typed_script):
                arr_property = typed_script

            if typed_script is GDScript:
                arr_property = typed_script.new()


            for element in data_dict[property_name]:
                if element == null:
                    property.push_back(null)
                    continue

                if is_instance_valid(arr_property):
                    var new_element = deserialize(arr_property, element)
                    property.push_back(new_element)
                    if not new_element is Object and is_instance_valid(typed_script):
                        print("failed loading property: ", property_name, " : ", new_element)
                    continue


                var deserialized_element = deserialize(element, element)
                if property.get_typed_builtin() == TYPE_INT:
                    deserialized_element = int(deserialized_element)


                property.push_back(deserialized_element)

            continue



        if not is_instance_valid(deserialized):
            deserialized = deserialize(property, data_dict[property_name])


        object.set(property_name, deserialized)






static func save_encrypted(object: Object, file_path: String) -> void :
    var file = FileAccess.open_encrypted_with_pass(file_path, FileAccess.WRITE, "g9DKUYth-(e0kuw")
    var save: Dictionary = get_data(object)

    file.store_var(var_to_bytes(save).compress(FileAccess.COMPRESSION_GZIP))





static func load_encrypted(object: Object, file_path: String) -> void :
    if not exists(file_path):
        return

    var file = FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ, "g9DKUYth-(e0kuw")
    if not is_instance_valid(file):
        return

    var file_data = file.get_var()

    if not file_data is PackedByteArray:
        load_data(object, file_data)
        return

    file_data = bytes_to_var((file_data as PackedByteArray).decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP))

    load_data(object, file_data)






static func save_json(object: RefCounted, file_path: String) -> void :
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    var save: Dictionary = get_data(object)
    file.store_var(JSON.stringify(save))





static func load_json(object: RefCounted, file_path: String) -> void :
    if not exists(file_path):
        return

    var file = FileAccess.open(file_path, FileAccess.READ)
    var file_data = file.get_var()

    if file_data is String:
        file_data = file_data.replace("-inf", "\"-inf\"")

    var json = JSON.parse_string(file_data)
    load_data(object, json)





static func exists(file_path: String) -> bool:
    var dir = DirAccess.open("user://")
    return dir.file_exists(file_path.lstrip("user://"))
