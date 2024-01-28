extends Button


@export var transition_path: String


func _ready() -> void:
	mouse_entered.connect(SoundController.play_sfx.bind("Hover"))
	pressed.connect(SoundController.play_sfx.bind("Click"))


func _pressed():
	SceneManager.goto_scene(transition_path)
