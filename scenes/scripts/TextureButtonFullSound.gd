extends TextureButtonHoverSound


func _ready():
	super()
	pressed.connect(SoundController.play_sfx.bind("Click"))
