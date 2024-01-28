extends Node2D


@onready var bg = $ParallaxBackground


func _ready() -> void:
	if not SoundController.current_music in ["Menu", "MenuLoop"]:
		SoundController.play_music("Menu")


func _process(delta: float) -> void:
	bg.scroll_offset[0] = GlobalCamera.get_screen_center_position()[0]


func goto(pos):
	GlobalCamera.follow_pos(pos)


func start_game(mode):
	SceneManager.goto_scene_and_call("res://scenes/Game.tscn", "set_mode", [mode])


func story_mode() -> void:
	SoundController.play_sfx("Play")
	SceneManager.goto_scene("res://scenes/StartingCutscene.tscn")
