extends Node2D


func _ready():
	SoundController.play_music("Game")
	
	$AnimationPlayer.play("cutscene")


func end_cutscene():
	SceneManager.goto_scene_and_call("res://scenes/Game.tscn", "set_mode", ["NORMAL"])
