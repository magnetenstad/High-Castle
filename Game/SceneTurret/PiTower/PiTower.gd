extends "res://SceneTurret/Turret.gd"

var loaded = false
var rotating = 0
var enemies = []
const damage = 3

func _ready():
	$FireTimer.start()


func _process(delta):
	if 16 > rotating and rotating > 0:
		rotate_y(PI/16)
		rotating += 1
		print(rotating)
	elif rotating == 16:
		rotating = 0


func _on_FireTimer_timeout():
	enemies.clear()
	for overlap in $Area.get_overlapping_bodies():
		if "Enemy" in overlap.name:
			overlap.health -= damage
	rotating += 1
