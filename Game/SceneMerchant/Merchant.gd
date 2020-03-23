extends Spatial


# Create variables
var selected_tower
var balance
var core_placed = false

# Constant values
const start_balance = 100

# Technical constants
const ray_length = 1000
const VALUES = preload("res://SceneMain/VALUES.gd")
const tower_preloads = {
	"PiTower": preload("res://SceneTurret/PiTower/PiTower.tscn"),
	"SimpleTurret": preload("res://SceneTurret/SimpleTurret/SimpleTurret.tscn"),
	"Core": preload("res://SceneTurret/Core/Core.tscn"),
	"Tree": preload("res://SceneTree/Tree.tscn"),
	"Spawner": preload("res://SceneSpawner/Spawner.tscn")
}


func _ready():
	balance = start_balance
	selected_tower = "Core"

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		attempt_build(event.position)

func attempt_build(mouse_position):
	if selected_tower == "Core" and core_placed:
		return
	var tower_price = get_price(selected_tower)
	if balance >= tower_price:
		# target_position is the spawn position on the map
		var target_position = raytrace_mouse(mouse_position)
		if target_position:
			var tower = tower_preloads[selected_tower].instance()
			
			tower.translate(target_position)
			get_node("Turrets").add_child(tower)
			tower.set_name(selected_tower)
			balance -= tower_price
			if selected_tower == "Core":
				core_placed = true
			
			
func raytrace_mouse(mouse_position):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	if(result.empty()):
		return false
	if(result.collider.name == "Terrain_col"):
		result.position.y += 1
		result.position.x = round(result.position.x - .5) + .5
		result.position.y = round(result.position.y) - .42
		result.position.z = round(result.position.z - .5) + .5
	return result.position

func get_price(tower_type):
	return VALUES.tower_prices[tower_type]

	
