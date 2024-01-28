extends Node2D


var mode


@onready var score_label = $Score


func _ready() -> void:
	$Retry.mouse_entered.connect(SoundController.play_sfx.bind("Hover"))
	$Retry.pressed.connect(SoundController.play_sfx.bind("Click"))


func startup(score, new_mode):
	if score > Globals.highscore:
		Globals.highscore = score
	
	$Score.text = "[center]Survived for %sm\n\nHighscore : %sm" % [score, Globals.highscore]
	
	mode = new_mode


func retry() -> void:
	SceneManager.goto_scene_and_call("res://scenes/Game.tscn", "set_mode", [mode])
