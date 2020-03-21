extends "Turret.gd"

const bomb_const = preload("res://SceneTurret/Bomb.tscn")
func _ready():
	$ShootTimer.start()

func shoot():
	var bomb = bomb_const.instance()
		
	bomb.translate(translation + Vector3(0, 1, 0))
	get_node("Bombs").add_child(bomb)
