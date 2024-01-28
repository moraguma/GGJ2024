extends Button


@export var aim_pos: Vector2

func _ready() -> void:
	mouse_entered.connect(SoundController.play_sfx.bind("Hover"))
	pressed.connect(SoundController.play_sfx.bind("Click"))


func _pressed():
	GlobalCamera.follow_pos(aim_pos)
