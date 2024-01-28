extends Node


const MASTER_BUS = 0
const MUSIC_BUS = 1
const SFX_BUS = 2


enum Items {
	ROCKET,
	GRAPPLE,
	BRICK,
	BOX,
	GUN
}


var last_item = null
var highscore = 0


func _ready() -> void:
	randomize()
