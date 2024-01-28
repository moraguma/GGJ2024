extends TextureButton
class_name TextureButtonHoverSound


func _ready():
	mouse_entered.connect(SoundController.play_sfx.bind("Hover"))
