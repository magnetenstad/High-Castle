extends VBoxContainer

const BUTT = preload("res://SceneGUI/Button.tscn")

func _ready():
	add_item("SimpleTurret")
	add_item("Tree")

func add_item(item):
	var butt = BUTT.instance()
	butt.item = item
	butt.text = item
	add_child(butt)
	
