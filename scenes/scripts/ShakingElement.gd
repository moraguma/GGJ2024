extends Sprite2D

const SHAKE = 0.5
const DECAY = 0.8
const MAX_OFFSET = Vector2(32, 18)
const MAX_ROLL = 0.15
const TRAUMA_POWER = 3

@export var trauma = 0.5
var aim_rot = 0
var base_rotation = 0
@onready var noise = FastNoiseLite.new()
var noise_y = 0


func _ready():
	randomize()
	noise.seed = randi()
	noise.frequency = 0.25


func _process(delta):
	if trauma:
		shake()
	else:
		rotation = base_rotation


func shake():
	# Based on https://kidscancode.org/godot_recipes/2d/screen_shake/
	
	var amount = pow(trauma, TRAUMA_POWER)
	
	rotation = base_rotation + MAX_ROLL * amount * noise.get_noise_1d(noise_y)
	offset[0] = MAX_OFFSET[0] * amount * noise.get_noise_1d(noise_y)
	offset[1] = MAX_OFFSET[1] * amount * noise.get_noise_1d(noise_y + 9999)
	
	noise_y += 1
