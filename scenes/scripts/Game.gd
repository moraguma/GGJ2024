extends Node2D
class_name Game

const ITEM_TO_SCENE = {
	Globals.Items.ROCKET: preload("res://scenes/Rocket.tscn"),
	Globals.Items.GRAPPLE: preload("res://scenes/Grapple.tscn"),
	Globals.Items.BRICK: preload("res://scenes/Brick.tscn"),
	Globals.Items.BOX: preload("res://scenes/Box.tscn"),
	Globals.Items.GUN: preload("res://scenes/Gun.tscn")
}
const METEORS = [preload("res://scenes/MeteorBig.tscn"), preload("res://scenes/MeteorSmall.tscn")]
const SHIPS = [preload("res://scenes/ShipBig.tscn"), preload("res://scenes/ShipSmall.tscn"), preload("res://scenes/Tentacle.tscn")]
const STATIONS = [preload("res://scenes/Station1.tscn"), preload("res://scenes/Station2.tscn"), preload("res://scenes/Station3.tscn"), preload("res://scenes/Station4.tscn"), preload("res://scenes/Station5.tscn")]
const ITEM = preload("res://scenes/CollectibleItem.tscn")
const LASER = preload("res://scenes/LaserMeteor.tscn")

const SPAWN_DISTANCE_TO_PLAYER = 250
const UNCOUNTED_METERS = 20
const PIXELS_PER_METER = 16
const METERS_PER_SPAWN = 12
const SPAWNS_PER_STATION = 3
const SPAWNS_PER_ITEM = 2
const SPAWNS_PER_LASER = 8

var items = [null, null, null]
var datas = [null, null, null]
var selection = 0
var last_spawn_position = 0
var meters_walked = 0
var spawns = 0
var mode


@onready var player: Player = $Player
@onready var indicator: Sprite2D = $Indicator
@onready var bg: ParallaxBackground = $ParallaxBackground
@onready var scroll_bg: ParallaxLayer = $ParallaxBackground/ParallaxLayer2


func _ready() -> void:
	if not SoundController.current_music in ["Game", "GameLoop"]:
		SoundController.play_music("Game")
	
	GlobalCamera.start_gameplay(player)
	
	update_selection()
	random_spawn(false)


func set_mode(new_mode):
	mode = new_mode
	
	if mode != "NORMAL":
		$Tutorial.queue_free()
		$EscapePod.queue_free()


func _physics_process(delta: float) -> void:
	bg.scroll_offset[0] = GlobalCamera.get_screen_center_position()[0]
	
	if player.position[1] < 60:
		GlobalCamera.make_transparent()
	else:
		GlobalCamera.make_visible()
	
	if player.position[1] < -10:
		indicator.show()
		indicator.position[0] = player.position[0]
	else:
		indicator.hide()
	
	var dif = 1 if Input.is_action_just_pressed("scroll_down") else (-1 if Input.is_action_just_pressed("scroll_up") else 0)
	if dif != 0:
		selection = selection + dif
		if selection > 2: 
			selection = 0
		elif selection < 0:
			selection = 2
		
		update_selection()
	
	meters_walked = max(meters_walked, player.position[0] / PIXELS_PER_METER - UNCOUNTED_METERS)
	GlobalCamera.update_meters(meters_walked)
	
	if max(0, meters_walked - last_spawn_position) >= METERS_PER_SPAWN:
		last_spawn_position = meters_walked
		spawns += 1
		if spawns % SPAWNS_PER_STATION == 0:
			spawn_station()
		else:
			random_spawn(spawns % SPAWNS_PER_LASER == 0)
		
		if spawns % SPAWNS_PER_ITEM == 0:
			spawn_item()


func random_spawn(laser_time: bool):
	spawn_ship()
	if laser_time:
		spawn_laser()
	elif randf() < 0.6:
		spawn_meteor()


func spawn_laser():
	var laser = LASER.instantiate()
	var r = randi() % 2
	laser.position[0] = player.position[0] + SPAWN_DISTANCE_TO_PLAYER
	laser.position[1] = 300 if r == 0 else -30
	laser.vel = Vector2(0, -1 if laser.position[1] == 300 else 1).rotated(randf_range(-PI / 12, PI / 12)) * 600 / laser.mass
	laser.rotation += randf_range(-PI/6, PI/6)
	if laser.position[1] == -30:
		laser.rotation += PI
	add_child(laser) 


func spawn_meteor():
	var meteor = METEORS[randi() % len(METEORS)].instantiate()
	meteor.position[0] = player.position[0] + SPAWN_DISTANCE_TO_PLAYER
	meteor.position[1] = 300 if randi() % 2 == 0 else -30
	meteor.vel = Vector2(0, -1 if meteor.position[1] == 300 else 1).rotated(randf_range(-PI / 12, PI / 12)) * 800 / meteor.mass
	add_child(meteor) 


func spawn_ship():
	var ship = SHIPS[randi() % len(SHIPS)].instantiate()
	ship.position[0] = player.position[0] + SPAWN_DISTANCE_TO_PLAYER
	ship.position[1] = randf_range(50, 230)
	ship.rotation = randf_range(0, 2 * PI)
	ship.vel = Vector2(0, -1).rotated(randf_range(0, 2 * PI)) * 200 / ship.mass
	ship.rot = randf_range(-0.1, 0.1)
	add_child(ship) 


func spawn_item():
	var item = ITEM.instantiate()
	item.position[0] = player.position[0] + SPAWN_DISTANCE_TO_PLAYER
	item.position[1] = randf_range(100, 170)
	add_child(item)


func spawn_station():
	var station = STATIONS[randi() % len(STATIONS)].instantiate()
	station.position[0] = player.position[0] + SPAWN_DISTANCE_TO_PLAYER
	add_child(station)
	
	for child in station.get_children():
		child.reparent(self)
	
	station.queue_free()


## Returns whether or not the item was successfully added
func try_add_item(item, data: Dictionary):
	for i in range(len(items)):
		if items[i] == null:
			items[i] = item
			datas[i] = data
			update_selection()
			return true
	return false


func update_selection():
	GlobalCamera.update_hud(items, selection, datas[selection]["tooltip"] if datas[selection] != null else "")
	player.hold_item(items[selection])


func throw_item(pos: Vector2, vel: Vector2, rot: float):
	SoundController.play_sfx("Throw")
	
	var new_item: RotatableCharacterElement = ITEM_TO_SCENE[items[selection]].instantiate()
	
	for data in datas[selection]:
		new_item.set(data, datas[selection][data])
	
	items[selection] = null
	datas[selection] = null
	update_selection()
	
	new_item.position = pos
	new_item.velocity = vel
	new_item.rotation = rot
	
	add_child(new_item)
	
	player.try_collect_items()


func finish():
	SceneManager.goto_scene_and_call("res://scenes/GameOver.tscn", "startup", [int(meters_walked), mode])
