class_name Classes





static func instance_from_string(obj_str: String) -> Object:
    var obj_str_arr: PackedStringArray = obj_str.split(": ")
    var object = ClassDB.instantiate(obj_str_arr[0])

    for obj_var in obj_str_arr[1].split(", "):
        var var_data: PackedStringArray = obj_var.split("=")
        object.set(var_data[0], str_to_var(var_data[1]))

    return object
