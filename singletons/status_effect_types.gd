extends Node




const BUFF: StatusEffectType = preload("res://resources/status_effect_types/buff.tres")
const DEBUFF: StatusEffectType = preload("res://resources/status_effect_types/debuff.tres")
const PENALTY: StatusEffectType = preload("res://resources/status_effect_types/penalty.tres")
const NEUTRAL: StatusEffectType = preload("res://resources/status_effect_types/neutral.tres")
const BLESSING: StatusEffectType = preload("res://resources/status_effect_types/blessing.tres")


const LIST: Array[StatusEffectType] = [
    BUFF, 
    DEBUFF, 
    PENALTY, 
    NEUTRAL, 
    BLESSING, 
]
