extends Spatial

const TREE = preload("res://SceneTree/Tree.tscn")

var offset = []
var noise_height = []
var last_update_timer = 0

var terrain_size = 128

func _ready():
	for i in range(terrain_size+1):
		offset.append([])
		for j in range(terrain_size+1):
			offset[i] += [0]
			
	for i in range(terrain_size+1):
		noise_height.append([])
		for j in range(terrain_size+1):
			noise_height[i] += [0]
	
	generate_mesh()
	
	# Trees
	
#	var rand_generate = RandomNumberGenerator.new()
#	for i in range(terrain_size):
#		for j in range(terrain_size):
#			if rand_generate.randi_range(0, 1000) == 0:
#				spawn_tree(Vector3(-terrain_size/2 + i, 0, -terrain_size/2 + j))

#func spawn_tree(pos):
#	var tree = TREE.instance()
#	tree.translate(pos)
#	get_node("Trees").add_child(tree)
	
func terraform(n):
	var ray_length = 1000
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	if(result.empty()):
		return
	result.position.y += 1
	result.position.x = round(result.position.x) + terrain_size / 2 + 1
	result.position.y = round(result.position.y) + terrain_size / 2 + 1
	result.position.z = round(result.position.z) + terrain_size / 2 + 1
	
	if(n > 0):
		var lowest_neighbor = min(
			min(offset[-result.position.z][-result.position.x] + noise_height[-result.position.z][-result.position.x],
			offset[-result.position.z+1][-result.position.x] + noise_height[-result.position.z+1][-result.position.x]),
			min(offset[-result.position.z+1][-result.position.x+1] + noise_height[-result.position.z+1][-result.position.x+1],
			offset[-result.position.z][-result.position.x+1] + noise_height[-result.position.z][-result.position.x+1]))
		
		
		offset[-result.position.z][-result.position.x] = max(lowest_neighbor + 1 - noise_height[-result.position.z][-result.position.x], offset[-result.position.z][-result.position.x] )
		offset[-result.position.z+1][-result.position.x] = max(lowest_neighbor + 1 - noise_height[-result.position.z+1][-result.position.x], offset[-result.position.z+1][-result.position.x])
		offset[-result.position.z+1][-result.position.x+1] = max(lowest_neighbor + 1 - noise_height[-result.position.z+1][-result.position.x+1], offset[-result.position.z+1][-result.position.x+1])
		offset[-result.position.z][-result.position.x+1] = max(lowest_neighbor + 1 - noise_height[-result.position.z][-result.position.x+1], offset[-result.position.z][-result.position.x+1])
	else:
		var highest_neighbor = max(
			max(offset[-result.position.z][-result.position.x] + noise_height[-result.position.z][-result.position.x],
			offset[-result.position.z+1][-result.position.x] + noise_height[-result.position.z+1][-result.position.x]),
			max(offset[-result.position.z+1][-result.position.x+1] + noise_height[-result.position.z+1][-result.position.x+1],
			offset[-result.position.z][-result.position.x+1] + noise_height[-result.position.z][-result.position.x+1]))
		
		
		offset[-result.position.z][-result.position.x] = min(highest_neighbor - 1 - noise_height[-result.position.z][-result.position.x], offset[-result.position.z][-result.position.x] )
		offset[-result.position.z+1][-result.position.x] = min(highest_neighbor - 1 - noise_height[-result.position.z+1][-result.position.x], offset[-result.position.z+1][-result.position.x])
		offset[-result.position.z+1][-result.position.x+1] = min(highest_neighbor - 1 - noise_height[-result.position.z+1][-result.position.x+1], offset[-result.position.z+1][-result.position.x+1])
		offset[-result.position.z][-result.position.x+1] = min(highest_neighbor - 1 - noise_height[-result.position.z][-result.position.x+1], offset[-result.position.z][-result.position.x+1])
	generate_mesh()

#func _process(delta):
#	lastUpdateTimer += delta
#	if(lastUpdateTimer > 0.5) and Input.is_mouse_button_pressed(2):
#		lastUpdateTimer = 0

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 2:
		if(Input.is_key_pressed(KEY_SHIFT)):
			terraform(-1)
		else:
			terraform(1)
	
func generate_mesh():
	for n in get_children():
		if(n.get_name() == "Terrain"):
			remove_child(n)
	var noise = OpenSimplexNoise.new()
	noise.period = 80
	noise.octaves = 6

	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(terrain_size, terrain_size)
	plane_mesh.subdivide_depth = plane_mesh.size.x-1
	plane_mesh.subdivide_width = plane_mesh.size.x-1

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)

	var array_plane = surface_tool.commit()

	var data_tool = MeshDataTool.new()

	data_tool.create_from_surface(array_plane, 0)
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = floor(noise.get_noise_3d(vertex.x, vertex.y, vertex.z) * 10) + offset[floor(i / (plane_mesh.size.x + 1))][i % int(plane_mesh.size.x + 1)]
		noise_height[floor(i / (plane_mesh.size.x + 1))][i % int(plane_mesh.size.x + 1)] = vertex.y
		data_tool.set_vertex(i, vertex)
	
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)

	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()

	var mesh_instance = MeshInstance.new()
	mesh_instance.set_name("Terrain")
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.set_surface_material(0, load("res://Assets/terrain.tres"))

	mesh_instance.create_trimesh_collision()
	add_child(mesh_instance)
	
	# Water:
	
	plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(terrain_size, terrain_size)
	
	surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)

	array_plane = surface_tool.commit()

	data_tool = MeshDataTool.new()

	data_tool.create_from_surface(array_plane, 0)
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()

	mesh_instance = MeshInstance.new()
	mesh_instance.set_name("Water")
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.set_surface_material(0, load("res://Assets/water.tres"))
	mesh_instance.translate(mesh_instance.translation + Vector3(0, -0.5, 0))
	add_child(mesh_instance)
	
