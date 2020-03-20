extends Spatial


const TURRET = preload("res://SceneTurret/SimpleTurret.tscn")
const CORE = preload("res://SceneTurret/Core.tscn")

const ray_length = 1000

var is_first_turret = true

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		if(is_first_turret):
			var camera = get_viewport().get_camera()
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * ray_length
			var space_state = get_world().get_direct_space_state()
			var result = space_state.intersect_ray(from, to)
			if(result.empty()):
				return
			if(result.collider.name == "Terrain_col"):
				result.position.y += 1
				result.position.x = round(result.position.x - .5) + .5
				result.position.y = round(result.position.y) - .42
				result.position.z = round(result.position.z - .5) + .5
				Spawn(result.position, "Core")
				is_first_turret = false
				$"/root/Main/World/LevelController".start_level()
		else:
			var camera = get_viewport().get_camera()
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * ray_length
			var space_state = get_world().get_direct_space_state()
			var result = space_state.intersect_ray(from, to)
			if(result.empty()):
				return
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
		var turret = TURRET.instance()
		
		turret.translate(pos)
		get_node("Turrets").add_child(turret)
	elif(name == "Core"):
		var core = CORE.instance()
		core.set_name("Core")
		core.translate(pos)
		get_node("Turrets").add_child(core)
	pass


