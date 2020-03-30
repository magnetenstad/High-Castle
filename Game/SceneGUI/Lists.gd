extends VBoxContainer

const BUTT = preload("res://SceneGUI/Button.tscn")

func _ready():
	add_item("Core", "Tower", $TurretMargin/Turrets/TurretList)
	add_item("SimpleTurret", "Tower", $TurretMargin/Turrets/TurretList)
	add_item("PiTower", "Tower", $TurretMargin/Turrets/TurretList)
	add_item("Tree", "Tower", $TurretMargin/Turrets/TurretList)
	add_item("Spawner", "Tower", $TurretMargin/Turrets/TurretList)
	add_item("Dog", "Unit", $UnitMargin/Units/UnitList)
	
func add_item(item, button_type, parent):
	var butt = BUTT.instance()
	butt.item = item
	butt.button_type = button_type
	butt.text = item
	parent.add_child(butt)
	
