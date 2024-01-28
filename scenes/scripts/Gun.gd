extends RotatableCharacterElement
class_name Gun


const COLLECTIBLE_SCENE = preload("res://scenes/CollectibleItem.tscn")


var active = true


func _collision_process(past_velocity: Vector2, collision: KinematicCollision2D, delta: float):
	if active:
		active = false
		
		SoundController.play_sfx("Pulverizer")
		
		var item = COLLECTIBLE_SCENE.instantiate()
		item.position = collision.get_collider().position
		
		collision.get_collider().queue_free()
		
		GlobalCamera.add_trauma()
		
		parent.add_child(item)
		queue_free()
