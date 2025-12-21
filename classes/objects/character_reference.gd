class_name CharacterReference extends Object

enum Type{PLAYER, ENEMY}

var type: Type = Type.PLAYER
var id: String = ""

var is_next: bool = false
var idx: int = -1

@warning_ignore("unused_private_class_variable")
var _ref: Character = null
