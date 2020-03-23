extends VBoxContainer

const BUTT = preload("res://SceneGUI/Button.tscn")

func _ready():
	add_item("Core", "Tower")
	add_item("SimpleTurret", "Tower")
	add_item("PiTower", "Tower")
	add_item("Tree", "Tower")
	add_item("Spawner", "Tower")
	add_item("Start Wave", "Wave")
	
func add_item(item, button_type):
	var butt = BUTT.instance()
	butt.item = item
	butt.button_type = button_type
	butt.text = item
	add_child(butt)
	
