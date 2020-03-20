extends Spatial


const turret_const = preload("res://SceneTurret/SimpleTurret.tscn")
const core_const = preload("res://SceneTurret/Core.tscn")

const ray_length = 1000

var isFirstTurret = true

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		if(isFirstTurret):
			var camera = get_viewport().get_camera()
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * ray_length
			var space_state = get_world().get_direct_space_state()
			var result = space_state.intersect_ray(from, to)
			if(result.collider.name == "Terrain_col"):
				result.position.y += 1
				result.position.x = round(result.position.x - .5) + .5
				result.position.y = round(result.position.y) - .42
				result.position.z = round(result.position.z - .5) + .5
				Spawn(result.position, "Core")
				isFirstTurret = false
		else:
			var camera = get_viewport().get_camera()
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * ray_length
			var space_state = get_world().get_direct_space_state()
			var result = space_state.intersect_ray(from, to)
			if(result.collider.name == "Terrain_col"):
				result.position.y += 1
				result.position.x = round(result.position.x - .5) + .5
				result.position.y = round(result.position.y) - .42
				result.position.z = round(result.position.z - .5) + .5
				Spawn(result.position, "Turret")

func _ready():
	pass
	
func Spawn(pos, name):
	if(name == "Turret"):
		var turret = turret_const.instance()
		
		turret.translate(pos)
		get_node("Turrets").add_child(turret)
	elif(name == "Core"):
		var core = core_const.instance()
		
		core.translate(pos)
		get_node("Turrets").add_child(core)
	pass


