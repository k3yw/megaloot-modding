extends OmniLight3D


@onready var rand = RandomNumberGenerator.new()
@onready var default_range: float = omni_range
@onready var noise = FastNoiseLite.new()

@export var flicker_strength: float = 0.015

var noise_value: float = 0.0


func _ready() -> void :
    rand.randomize()
    noise.seed = rand.randi()
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    noise.frequency = 2



func _process(_delta: float) -> void :
    omni_range = default_range + noise.get_noise_1d(Time.get_ticks_msec() * 0.0023) * flicker_strength
