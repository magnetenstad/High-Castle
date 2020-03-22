extends Spatial

# Currency
var balance = 0

# Variable for tower selection
var selected_tower

# Constant values
const VALUES = preload("res://SceneMain/VALUES.gd")
const start_balance = 100

# Constant tower references
const TURRET = preload("res://SceneTurret/SimpleTurret.tscn")
const CORE = preload("res://SceneTurret/Core.tscn")
const TREE = preload("res://SceneTree/Tree.tscn")

# Raytracing constant
const ray_length = 1000

func _ready():
	balance = start_balance
	selected_tower = "Core"

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		attempt_build(event.position)

func attempt_build(mouse_position):
	if buy_tower(selected_tower):
		# target_position is the spawn position on the map
		var target_position = raytrace_mouse(mouse_position)
		if target_position:
			var tower
			
			match selected_tower:
				"SimpleTurret":
					tower = TURRET.instance()
				"Core":
					tower = CORE.instance()
				"Tree":
					tower = TREE.instance()
				_:
					return
				
			tower.translate(target_position)
			get_node("Turrets").add_child(tower)
			tower.set_name(selected_tower)
			
			if(selected_tower == "Core"):
				$"/root/Main/World/LevelController".start_level()
		else:
			unbuy_tower(selected_tower)
			
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

func buy_tower(tower_type):
	var tower_price = VALUES.tower_prices[tower_type]
	if balance >= tower_price:
		balance -= tower_price
		return true
	return false

func unbuy_tower(tower_type):
	var tower_price = VALUES.tower_prices[tower_type]
	balance += tower_price
		
	
