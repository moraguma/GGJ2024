extends Node2D


@export var amplitude: Vector2 = Vector2(0, 16)
@export var frequency: float = 0.5


var active = true


@onready var base_pos = position
var time = 0


func _process(delta):
	if active:
		time += delta
		
		position = base_pos + amplitude * sin(2 * PI * frequency * time)
