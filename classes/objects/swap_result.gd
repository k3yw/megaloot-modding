class_name ItemPressResult extends RefCounted


enum Type{
    SWAP, 
    MERGE, 
    TOGGLE, 
    CONSUME, 
    INTERACTION, 
    SET_LIMIT, 
    DISABLED, 
    HAS_DUPLICATES, 
    MISSING_SOCKET, 
    BUY, 
    NULL
    }

const SUCCESS_TYPES: Array[Type] = [Type.SWAP, Type.MERGE, Type.TOGGLE, Type.CONSUME]


var slots: Array[Slot] = [Empty.slot, Empty.slot]
var type: Type = ItemPressResult.Type.NULL


func _init(arg_slots: Array[Slot] = [], arg_type: Type = ItemPressResult.Type.NULL) -> void :
    slots = arg_slots
    type = arg_type
