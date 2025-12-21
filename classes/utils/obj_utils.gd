class_name ObjUtils



static func cleanup_arr(arr_ref: Array) -> void :
    for obj in arr_ref:
        if not is_instance_valid(obj):
            continue

        if obj is Object:
            obj.free()
            continue
        print("failed object arr cleanup:", obj)

    arr_ref.clear()
