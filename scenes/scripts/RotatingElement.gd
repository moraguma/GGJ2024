extends Sprite2D


@export var rotation_speed = 0.5


func _process(delta: float) -> void:
	rotation += rotation_speed * delta
