extends CharacterBody2D
class_name CharacterElement


# --------------------------------------------------------------------------------------------------
# CONSTANTS
# --------------------------------------------------------------------------------------------------
const PROCESS_PRIORITY = 1
const GRAVITY = 0.02
const FORCE_CONSTANT = 6
const TORQUE_CONSTANT = 0.003
const SELF_FORCE_CONSTANT = 50
const STICK_DISTANCE = 2


# --------------------------------------------------------------------------------------------------
# VARIABLES
# --------------------------------------------------------------------------------------------------
var terminal_speed = Vector2(0, 50)
var normal = Vector2(0, 0)

var stuck_wkref = null
var stuck
var old_stuck_pos: Vector2
var old_stuck_rot: float
var old_stuck_from_center: Vector2


@onready var parent: Game = get_parent()


func _ready() -> void:
	add_to_group("CharacterElements")
	
	process_priority = PROCESS_PRIORITY


func _physics_process(delta: float) -> void:
	if stuck_wkref != null:
		if stuck_wkref.get_ref() == null:
			unstick()
	
	if stuck != null:
		_update_stuck_transform()
		_stuck_process(delta)
	else:
		_movement_process(delta)


func _update_stuck_transform():
	position += stuck.position - old_stuck_pos
	old_stuck_pos = stuck.position
	
	var new_stuck_from_center = old_stuck_from_center.rotated(stuck.rotation - old_stuck_rot)
	position += new_stuck_from_center - old_stuck_from_center
	old_stuck_from_center = new_stuck_from_center
	old_stuck_rot = stuck.rotation


func _movement_process(delta: float):
	velocity = _get_velocity()
	
	var past_velocity = velocity
	var collided = move_and_slide()
	
	normal = Vector2(0, 0)
	if collided:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			normal += collision.get_normal()
			if collision.get_collider() is RigidBody2D:
				_collision_process(past_velocity, collision, delta)
		
		if normal != Vector2(0, 0):
			normal = normal.normalized()


## Will be called every frame if stuck
func _stuck_process(delta: float):
	pass


## Will only be called if collided with RigidBody2D
func _collision_process(past_velocity: Vector2, collision: KinematicCollision2D, delta: float):
	collision.get_collider().aim_vel += past_velocity.project(collision.get_normal()) * FORCE_CONSTANT * delta / collision.get_collider().mass
	
	var tangent = collision.get_normal().rotated(PI / 2)
	var tangent_vel = past_velocity.project(tangent)
	var normalized_torque = 1 if past_velocity.dot(tangent) > 0 else -1
	collision.get_collider().aim_rot += normalized_torque * tangent_vel.length() * (position - collision.get_collider().position).length() * TORQUE_CONSTANT / collision.get_collider().mass * delta
	
	if stuck:
		stuck.aim_vel += -past_velocity.project(collision.get_normal()) * FORCE_CONSTANT * delta / stuck.mass
	
	velocity += -past_velocity.project(collision.get_normal()) * delta * SELF_FORCE_CONSTANT * delta 


func _get_velocity():
	return _get_side_velocity() + _get_gravity_velocity()


func _get_side_velocity():
	return velocity - velocity.project(terminal_speed)


func _get_gravity_velocity():
	return lerp(velocity.project(terminal_speed), terminal_speed, GRAVITY)


func stick(object: RigidBody2D, normal: Vector2):
	stuck_wkref = weakref(object)
	
	velocity = Vector2(0, 0)
	position += normal * STICK_DISTANCE
	
	stuck = object
	old_stuck_pos = object.position
	old_stuck_rot = object.rotation
	old_stuck_from_center = position - object.position


func unstick():
	stuck_wkref = null
	stuck = null
