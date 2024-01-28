extends CharacterElement
class_name RotatableCharacterElement


func _update_stuck_transform():
	rotate(stuck.rotation - old_stuck_rot)
	
	super()


func throw(initial_vel: Vector2, initial_rotation: float):
	velocity = initial_vel
	rotation = initial_rotation
