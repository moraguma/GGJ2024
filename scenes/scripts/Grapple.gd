extends RotatableCharacterElement
class_name Grapple


const CONSTANT_FORCE = 20


@export var code = ""
var wk_pair = null
var pair = null
var rendering_rope = false
var is_first


@onready var rope: Line2D = $Rope


func _ready() -> void:
	if is_first:
		code = str(randi())
		parent.try_add_item(Globals.Items.GRAPPLE, {"tooltip": "WILL CONNECT TO YOUR OTHER GRAPPLE", "code": code})
	
	add_to_group(code)


func _movement_process(delta: float):
	if pair != null:
		queue_free()
		pair.queue_free()
	else:
		super(delta)


func _physics_process(delta: float) -> void:
	if wk_pair != null:
		if wk_pair.get_ref() == null:
			pair = null
			wk_pair = null
	
	super(delta)


func _stuck_process(delta: float):
	if pair != null:
		stuck.aim_vel += (pair.position - position).normalized() * (pair.position - position).length() * CONSTANT_FORCE * delta / stuck.mass
		
		if rendering_rope:
			rope.set_point_position(1, (pair.position - position).rotated(-rotation))


func connect_pair(new_pair):
	wk_pair = weakref(new_pair)
	pair = new_pair


func _collision_process(past_velocity: Vector2, collision: KinematicCollision2D, delta: float):
	super(past_velocity, collision, delta)
	
	if stuck == null:
		stick(collision.get_collider(), collision.get_normal())
		
		var group_nodes = get_tree().get_nodes_in_group(code)
		group_nodes.erase(self)
		if len(group_nodes) != 0:
			SoundController.play_sfx("Grapple")
			
			var new_pair = group_nodes[0]
			if new_pair.stuck != null and pair == null:
				connect_pair(new_pair)
				new_pair.connect_pair(self)
				
				rendering_rope = true
				rope.add_point(Vector2(0, 0))
				rope.add_point((new_pair.position - position).rotated(-rotation))
