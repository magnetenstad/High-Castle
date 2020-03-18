extends Spatial


const turret_const = preload("res://Scenes/Turret.tscn")

const ray_length = 1000

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var camera = get_viewport().get_camera()
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * ray_length
		var space_state = get_world().get_direct_space_state()
		var result = space_state.intersect_ray(from, to)
		result.position.y += 1
		result.position.x = round(result.position.x)
		result.position.y = round(result.position.y)
		result.position.z = round(result.position.z)
		Spawn(result.position)

func _ready():
	pass
	
func Spawn(pos):
	var turret = turret_const.instance()
	
	turret.translate(pos)
	print(pos)
	get_node("Turrets").add_child(turret)
	pass


