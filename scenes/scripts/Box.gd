extends RotatableCharacterElement
class_name Box


const PLATFORM_SCENE = preload("res://scenes/BoxPlatform.tscn")


var in_range = []


func enter_area(body: Node2D) -> void:
	in_range.append(body)


func exit_area(body: Node2D) -> void:
	in_range.erase(body)
	
	if len(in_range) == 1:
		var platform = PLATFORM_SCENE.instantiate()
		platform.position = position
		platform.rotation = rotation
		platform.vel = velocity / 10
		parent.add_child(platform)
		queue_free()
