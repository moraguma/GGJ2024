extends CharacterElement
class_name Player

# --------------------------------------------------------------------------------------------------
# CONSTANTS
# --------------------------------------------------------------------------------------------------
# Physics
const CHECKING_DISTANCE = 18
const SPAWNING_DISTANCE = 24
const THROWING_SPEED = 250
const VELOCITY_TRANSFER_CONSTANT = 1.0

# Movement
const MAX_MOVE_SPEED = 100
const JUMP_SPEED = 60

const ACCEL = 0.2
const DECEL = 0.4
const AIR_ACCEL = 0.03

# Animation
const H_SPEED_ANIMATION_TOLERANCE = 5

const HAND_DISTANCE_FROM_BODY = 24
const HAND_ANIMATION_LERP_WEIGHT = 0.1
const BASE_RIGHT_HAND_POS = Vector2(16, 8)
const BASE_LEFT_HAND_POS = Vector2(-16, 8)

const OPEN_HAND_FRAME = 0
const CLOSED_HAND_FRAME = 2

const ITEM_TO_FRAME = {
	Globals.Items.ROCKET: 4,
	Globals.Items.GRAPPLE: 3,
	Globals.Items.BRICK: 5,
	Globals.Items.BOX: 6,
	Globals.Items.GUN: 7
}

# --------------------------------------------------------------------------------------------------
# VARIABLES
# --------------------------------------------------------------------------------------------------
var item = Globals.Items.ROCKET
var items_in_reach = []
var checking_bodies = []

# --------------------------------------------------------------------------------------------------
# NODES
# --------------------------------------------------------------------------------------------------
@onready var distance_checker: ShapeCast2D = $DistanceChecker
@onready var jump_checker: ShapeCast2D = $JumpChecker

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $BodySprite
@onready var right_hand = $RightHand # For equipment
@onready var left_hand = $LeftHand # For grabs


func _physics_process(delta: float) -> void:
	_check_process()
	
	if stuck != null and Input.is_action_just_released("grab"):
		unstick()
	
	_animation_process()
	_throw_process()
	
	super(delta)


func _check_process():
	var i = 0
	while i < len(checking_bodies):
		var checking_body = checking_bodies[i].get_ref()
		if checking_body == null:
			checking_bodies.remove_at(i)
		elif checking_body.position[1] < -100 or checking_body.position[0] - position[0] < -600:
			print("Freed")
			checking_body.queue_free()
			checking_bodies.remove_at(i)
		else:
			i += 1
	
	if position[1] > 350:
		SoundController.play_sfx("Death")
		die()


func _animation_process():
	if is_on_wall():
		if abs(velocity[0]) > H_SPEED_ANIMATION_TOLERANCE:
			animation_player.play("walk")
		else:
			animation_player.play("idle")
	else:
		animation_player.play("jump")
	
	if velocity[0] > 0:
		sprite.flip_h = false
	elif velocity[0] < 0:
		sprite.flip_h = true
	
	left_hand.frame = CLOSED_HAND_FRAME if stuck != null else OPEN_HAND_FRAME
	right_hand.frame = ITEM_TO_FRAME[item] if item != null else OPEN_HAND_FRAME
	
	left_hand.position = lerp(left_hand.position, 
		(stuck.position - position).normalized() * HAND_DISTANCE_FROM_BODY if stuck != null else BASE_LEFT_HAND_POS, 
		HAND_ANIMATION_LERP_WEIGHT)
	right_hand.position = lerp(right_hand.position, 
		(get_global_mouse_position() - position).normalized() * HAND_DISTANCE_FROM_BODY if item != null else BASE_RIGHT_HAND_POS,
		HAND_ANIMATION_LERP_WEIGHT
	)
	
	for hand in [left_hand, right_hand]:
		hand.rotation = Vector2(0, -1).angle_to(hand.position)


func _throw_process():
	if item != null and Input.is_action_just_pressed("throw"):
		var mouse_dir = (get_global_mouse_position() - position).normalized()
		distance_checker.target_position = mouse_dir * CHECKING_DISTANCE
		distance_checker.force_shapecast_update()
		if not distance_checker.is_colliding():
			parent.throw_item(position + mouse_dir * SPAWNING_DISTANCE, velocity + mouse_dir * THROWING_SPEED, Vector2(0, -1).angle_to(mouse_dir))
		else:
			GlobalCamera.add_trauma()


func _get_side_velocity():
	var side_velocity = velocity - velocity.project(terminal_speed)
	var aim_side_velocity = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"),
								Input.get_action_strength("down") - Input.get_action_strength("up"))
	if aim_side_velocity != Vector2(0, 0):
		aim_side_velocity = (aim_side_velocity.normalized() * MAX_MOVE_SPEED).project(terminal_speed.rotated(PI / 2))
	
	var accel = ACCEL
	if not is_on_wall():
		accel = AIR_ACCEL
	elif aim_side_velocity.dot(side_velocity) <= 0:
		accel = DECEL
	
	return lerp(side_velocity, aim_side_velocity, accel)


func _get_gravity_velocity():
	if Input.is_action_just_pressed("jump") and jump_checker.is_colliding():
		SoundController.play_sfx("Jump")
		return Vector2(0, -1) * JUMP_SPEED
	return super()


func _collision_process(past_velocity: Vector2, collision: KinematicCollision2D, delta: float):
	super(past_velocity, collision, delta)
	
	if stuck == null:
		position += collision.get_collider().linear_velocity * delta * VELOCITY_TRANSFER_CONSTANT
		if Input.is_action_pressed("grab"):
			stick(collision.get_collider(), collision.get_normal())


func hold_item(new_item):
	item = new_item


func touch_item(collectible: CollectibleItem):
	if not parent.try_add_item(collectible.item_id, collectible.data):
		items_in_reach.append(collectible)
	else:
		SoundController.play_sfx("Pickup")
		collectible.queue_free()


func leave_item(collectible: CollectibleItem):
	items_in_reach.erase(collectible)


func try_collect_items():
	var i = 0
	while i < len(items_in_reach):
		if parent.try_add_item(items_in_reach[i].item_id, items_in_reach[i].data):
			SoundController.play_sfx("Pickup")
			items_in_reach[i].queue_free()
			items_in_reach.remove_at(i)
		else:
			break


func enter_checker(body):
	if not body in checking_bodies and body != self:
		checking_bodies.append(weakref(body))


func die():
	parent.finish()


func step():
	SoundController.play_sfx("Footstep")
