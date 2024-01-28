extends Node2D


const SPEED = 200.0


@onready var bg = $ParallaxBackground


func _ready() -> void:
	$Ship.play("default")
	$AnimationPlayer.play("cutscene")
	GlobalCamera.follow_node($Ship)
	
	SoundController.play_music("Ending")


func shake():
	GlobalCamera.add_trauma()


func _process(delta: float) -> void:
	GlobalCamera.snap_to_aim()
	
	bg.scroll_offset[0] = GlobalCamera.get_screen_center_position()[0]


func end_cutscene():
	SceneManager.goto_scene_and_call("res://scenes/Menu.tscn", "goto", [Vector2(720, 135)])
