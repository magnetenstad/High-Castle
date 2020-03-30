extends Spatial


# Create variables
var selected_tower
var balance
var core_placed = [false, false, false, false, false, false, false, false, false, false]

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
		attempt_build(raytrace_mouse(event.position), selected_tower, 0)

func attempt_build(target_position, tower_id, team):
	if (tower_id == "Core" and core_placed[team]) || !target_position:
		return
	var tower_price = get_price(tower_id)
	if team != 0 || balance >= tower_price:
		var tower = tower_preloads[tower_id].instance()
		tower.translate(target_position)
		get_node("Turrets").add_child(tower)
		tower.set_name(tower_id)
		tower.team = team
		balance -= tower_price
		if tower_id == "Core":
			core_placed[team] = true
			
			
func raytrace_mouse(mouse_position):
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	if(result.empty()):
		return false
	if "Terrain" in result.collider.name:
		result.position.y += 1
		result.position.x = round(result.position.x - .5) + .5
		result.position.y = round(result.position.y) - .42
		result.position.z = round(result.position.z - .5) + .5
	return result.position

func raytrace_down(position):
	var from = position
	var to = position + Vector3(0,-1,0) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	if(result.empty()):
		return false
	if "Terrain" in result.collider.name:
		result.position.y += 1
		result.position.x = round(result.position.x - .5) + .5
		result.position.y = round(result.position.y) - .42
		result.position.z = round(result.position.z - .5) + .5
	return result.position

func get_price(tower_type):
	return VALUES.tower_prices[tower_type]

	
