extends Area2D
class_name CollectibleItem


const ITEMS = [
	Globals.Items.ROCKET,
	Globals.Items.GRAPPLE,
	Globals.Items.BRICK,
	Globals.Items.BOX,
	Globals.Items.GUN
]

const ITEM_TO_FRAME = {
	Globals.Items.ROCKET: 0,
	Globals.Items.GRAPPLE: 2,
	Globals.Items.BRICK: 1,
	Globals.Items.BOX: 3,
	Globals.Items.GUN: 4
}

const ITEM_TO_DATA = {
	Globals.Items.ROCKET: {
		"tooltip": "STICKS TO DEBRIS AND PROPPELS IT AWAY"
	},
	Globals.Items.GRAPPLE: {
		"tooltip": "BRINGS TWO OBJECTS TOGETHER",
		"is_first": true
	},
	Globals.Items.BRICK: {
		"tooltip": "IT'S A BRICK. YOU CAN THROW IT"
	},
	Globals.Items.BOX: {
		"tooltip": "CREATES AN INSTANTANEOUS BOX"
	},
	Globals.Items.GUN: {
		"tooltip": "TRANSFORMS A PIECE OF DEBRIS INTO AN ITEM"
	}
}

var item_id
var data = {}

@onready var sprite = $Sprite


func _ready():
	item_id = ITEMS[randi() % len(ITEMS)]
	while item_id == Globals.last_item:
		item_id = ITEMS[randi() % len(ITEMS)]
	Globals.last_item = item_id
	
	data = ITEM_TO_DATA[item_id]
	
	sprite.frame = ITEM_TO_FRAME[item_id]


func enter_area(obj):
	if obj.name == "Player":
		obj.touch_item(self)


func exit_area(obj):
	if obj.name == "Player":
		obj.leave_item(self)
