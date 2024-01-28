extends Platform


@onready var raycast: RayCast2D = $RayCast
@onready var line: Line2D = $Line2D
@onready var particles = $Particles


func _physics_process(delta: float) -> void:
	if raycast.is_colliding():
		line.set_point_position(1, (raycast.get_collision_point() - position).rotated(-rotation))
		particles.position = (raycast.get_collision_point() - position).rotated(-rotation)
		
		if raycast.get_collider() == null:
			return
		
		if raycast.get_collider().name == "Player":
			SoundController.play_sfx("Laser")
			raycast.get_collider().die()
	else:
		line.set_point_position(1, Vector2(0, -600))
		particles.position = raycast.position + Vector2(0, -600)
