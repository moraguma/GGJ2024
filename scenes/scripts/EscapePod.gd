extends Area2D


var player = null


@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var parent: Game = get_parent()


func _physics_process(delta: float) -> void:
	if player != null:
		player.position = position


func body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		sprite.active = false
		body.sprite.hide()
		body.right_hand.hide()
		body.left_hand.hide()
		
		animation_player.play("escape")


func go_to_ending():
	if Globals.highscore < parent.meters_walked:
		Globals.highscore = parent.meters_walked
	
	SceneManager.goto_scene("res://scenes/EndingCutscene.tscn")
