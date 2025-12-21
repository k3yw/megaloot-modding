class_name BattleCamera extends Camera2D



@onready var rand = RandomNumberGenerator.new()
@onready var noise = FastNoiseLite.new()

@export var shake_time: float = 0.15

var shake_strength: float = 0.0
var noise_value: float = 0.0


func _ready() -> void :
    rand.randomize()
    noise.seed = rand.randi()
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    noise.frequency = 2



func _process(delta: float) -> void :
    var noise_shake_speed: float = 245.0
    var shake_offset: Vector2 = get_noise_offset(delta, noise_shake_speed, shake_strength)
    offset = shake_offset




func shake() -> void :
    await get_tree().physics_frame

    shake_strength = 3.5
    create_tween().tween_property(self, "shake_strength", 0.0, shake_time)




func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
    noise_value += delta * speed

    return Vector2(
        noise.get_noise_2d(1, noise_value) * strength, 
        noise.get_noise_2d(100, noise_value) * strength
        )
