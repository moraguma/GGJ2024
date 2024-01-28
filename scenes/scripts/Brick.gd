extends RotatableCharacterElement
class_name Brick


const IMPULSE = 500
const SELF_IMPULSE = 50
const PLATFORM_SCENE = preload("res://scenes/BrickPlatform.tscn")


var active = true


func _collision_process(past_velocity: Vector2, collision: KinematicCollision2D, delta: float):
	if active:
		active = false
		
		collision.get_collider().vel = -collision.get_normal() * IMPULSE / collision.get_collider().mass
		
		var platform = PLATFORM_SCENE.instantiate()
		platform.position = position
		platform.rotation = rotation
		platform.vel = collision.get_normal() * SELF_IMPULSE / platform.mass
		parent.add_child(platform)
		queue_free()
