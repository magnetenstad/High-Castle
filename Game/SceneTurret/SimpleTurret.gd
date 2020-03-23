extends "Turret.gd"
var loaded = false

var enemies = []

const bomb_const = preload("res://SceneTurret/Bomb.tscn")

func _ready():
	$ShootTimer.start()


func _on_ShootTimer_timeout():
	enemies.clear()
	for overlap in $Area.get_overlapping_bodies():
		if "Enemy" in overlap.name:
			enemies.append(overlap)

	if enemies.size() > 0:
		var body = enemies[0]
		var bomb = bomb_const.instance()
		bomb.direction = (body.translation - translation).normalized()
		bomb.translate(translation + Vector3(0, 1, 0))
		get_node("Bombs").add_child(bomb)
		loaded = false

func _process(delta):
	var mat = get_node("Area/CSGSphere").get_material()
	mat.set_shader_param("time", OS.get_ticks_msec())
	
