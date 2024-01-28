extends Camera2D


signal finish_transition

const PROCESS_PRIORITY = 2

const TRANSITION_TIME = 2.0
const LERP_WEIGHT = 0.1

const SHAKE = 0.5
const DECAY = 0.8
const MAX_OFFSET = Vector2(160, 90)
const MAX_ROLL = 0.15
const TRAUMA_POWER = 2

@onready var ITEM_TO_FRAME = {
	Globals.Items.ROCKET: 0,
	Globals.Items.GRAPPLE: 2,
	Globals.Items.BRICK: 1,
	Globals.Items.BOX: 3,
	Globals.Items.GUN: 4
}

@onready var center: Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height")) / 2
@onready var aim_pos: Vector2 = center
var aim_node: Node2D = null

var trauma = 0.0
var aim_rot = 0
var base_rotation = 0
@onready var noise = FastNoiseLite.new()
var noise_y = 0


@onready var shader_canvas = $ShaderCanvas

@onready var hud = $HUD
@onready var item_sprites: Array[Sprite2D] = [$HUD/Items/Item, $HUD/Items/Item2, $HUD/Items/Item3]
@onready var cursor: Sprite2D = $HUD/Cursor
@onready var tooltip: RichTextLabel = $HUD/Tooltip
@onready var meters: RichTextLabel = $HUD/Meters


func _ready():
	process_priority = PROCESS_PRIORITY
	
	randomize()
	noise.seed = randi()
	noise.frequency = 0.25
	
	position = center
	shader_canvas.size = Vector2i(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height")) + 2 * Vector2i(MAX_OFFSET)
	shader_canvas.position = -center - MAX_OFFSET


func _process(delta):
	position = lerp(position, get_effective_aim_pos(), LERP_WEIGHT)
	
	if trauma:
		trauma = max(trauma - DECAY * delta, 0)
		shake()
	else:
		rotation = base_rotation
	
	hud.position = get_screen_center_position() - position + Vector2(-240, -135)


func add_trauma(amount = SHAKE):
	trauma = amount


func shake():
	# Based on https://kidscancode.org/godot_recipes/2d/screen_shake/
	
	var amount = pow(trauma, TRAUMA_POWER)
	
	rotation = base_rotation + MAX_ROLL * amount * noise.get_noise_1d(noise_y)
	offset[0] = MAX_OFFSET[0] * amount * noise.get_noise_1d(noise_y)
	offset[1] = MAX_OFFSET[1] * amount * noise.get_noise_1d(noise_y + 9999)
	
	noise_y += 1


func get_effective_aim_pos() -> Vector2:
	var effective_aim_pos = aim_pos
	if aim_node != null:
		effective_aim_pos = aim_node.position
	return effective_aim_pos


func follow_node(node: Node2D):
	aim_node = node


func follow_pos(pos: Vector2):
	aim_pos = pos


func snap_to_aim():
	position = get_effective_aim_pos()


func start_transition_animation():
	var tween = create_tween()
	tween.tween_method(set_shader_value, 0.0, 1.0, TRANSITION_TIME / 2.0)
	tween.tween_callback(finish_transition_animation)
	tween.tween_method(set_shader_value, 1.0, 2.0, TRANSITION_TIME / 2.0)


func set_shader_value(value: float):
	shader_canvas.material.set_shader_parameter("progress", value)


func finish_transition_animation():
	aim_pos = center
	aim_node = null
	snap_to_aim()
	
	emit_signal("finish_transition")


func start_gameplay(player):
	limit_top = 0
	limit_left = 0
	limit_bottom = 270
	
	follow_node(player)
	snap_to_aim()
	
	hud.show()


func update_hud(items: Array, selection: int, tooltip_text: String):
	for i in range(3):
		if items[i] != null:
			item_sprites[i].show()
			item_sprites[i].frame = ITEM_TO_FRAME[items[i]]
		else:
			item_sprites[i].hide()
	
	cursor.position[0] = item_sprites[selection].position[0]
	
	tooltip.text = tooltip_text


func update_meters(amount: int):
	meters.text = str(amount) + "m"
