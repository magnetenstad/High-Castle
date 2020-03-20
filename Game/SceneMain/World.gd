extends Spatial

var offset = []
var noiseHeight = []
var lastUpdateTimer = 0

func _ready():
	for i in range(32+1):
		offset.append([])
		for j in range(32+1):
			offset[i] += [0]
			
	for i in range(32+1):
		noiseHeight.append([])
		for j in range(32+1):
			noiseHeight[i] += [0]
	GenerateMesh()
	
func Terraform(n):
	var ray_length = 1000
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	result.position.y += 1
	result.position.x = round(result.position.x) + 17
	result.position.y = round(result.position.y) + 17
	result.position.z = round(result.position.z) + 17
	
	if(n > 0):
		var lowestNeighbor = min(
			min(offset[-result.position.z][-result.position.x] + noiseHeight[-result.position.z][-result.position.x],
			offset[-result.position.z+1][-result.position.x] + noiseHeight[-result.position.z+1][-result.position.x]),
			min(offset[-result.position.z+1][-result.position.x+1] + noiseHeight[-result.position.z+1][-result.position.x+1],
			offset[-result.position.z][-result.position.x+1] + noiseHeight[-result.position.z][-result.position.x+1]))
		
		
		offset[-result.position.z][-result.position.x] = max(lowestNeighbor + 1 - noiseHeight[-result.position.z][-result.position.x], offset[-result.position.z][-result.position.x] )
		offset[-result.position.z+1][-result.position.x] = max(lowestNeighbor + 1 - noiseHeight[-result.position.z+1][-result.position.x], offset[-result.position.z+1][-result.position.x])
		offset[-result.position.z+1][-result.position.x+1] = max(lowestNeighbor + 1 - noiseHeight[-result.position.z+1][-result.position.x+1], offset[-result.position.z+1][-result.position.x+1])
		offset[-result.position.z][-result.position.x+1] = max(lowestNeighbor + 1 - noiseHeight[-result.position.z][-result.position.x+1], offset[-result.position.z][-result.position.x+1])
	else:
		var highestNeighbor = max(
			max(offset[-result.position.z][-result.position.x] + noiseHeight[-result.position.z][-result.position.x],
			offset[-result.position.z+1][-result.position.x] + noiseHeight[-result.position.z+1][-result.position.x]),
			max(offset[-result.position.z+1][-result.position.x+1] + noiseHeight[-result.position.z+1][-result.position.x+1],
			offset[-result.position.z][-result.position.x+1] + noiseHeight[-result.position.z][-result.position.x+1]))
		
		
		offset[-result.position.z][-result.position.x] = min(highestNeighbor - 1 - noiseHeight[-result.position.z][-result.position.x], offset[-result.position.z][-result.position.x] )
		offset[-result.position.z+1][-result.position.x] = min(highestNeighbor - 1 - noiseHeight[-result.position.z+1][-result.position.x], offset[-result.position.z+1][-result.position.x])
		offset[-result.position.z+1][-result.position.x+1] = min(highestNeighbor - 1 - noiseHeight[-result.position.z+1][-result.position.x+1], offset[-result.position.z+1][-result.position.x+1])
		offset[-result.position.z][-result.position.x+1] = min(highestNeighbor - 1 - noiseHeight[-result.position.z][-result.position.x+1], offset[-result.position.z][-result.position.x+1])
	GenerateMesh()

#func _process(delta):
#	lastUpdateTimer += delta
#	if(lastUpdateTimer > 0.5) and Input.is_mouse_button_pressed(2):
#		lastUpdateTimer = 0
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 2:
		if(Input.is_key_pressed(KEY_SHIFT)):
			Terraform(-1)
		else:
			Terraform(1)
	
func GenerateMesh():
	for n in get_children():
		if(n.get_name() == "Terrain"):
			remove_child(n)
	var noise = OpenSimplexNoise.new()
	noise.period = 80
	noise.octaves = 6

	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(32, 32)
	plane_mesh.subdivide_depth = plane_mesh.size.x-1
	plane_mesh.subdivide_width = plane_mesh.size.x-1

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)

	var array_plane = surface_tool.commit()

	var data_tool = MeshDataTool.new()

	data_tool.create_from_surface(array_plane, 0)
	print(data_tool.get_vertex_count())
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = floor(noise.get_noise_3d(vertex.x, vertex.y, vertex.z) * 10) + offset[floor(i / (plane_mesh.size.x + 1))][i % int(plane_mesh.size.x + 1)]
		noiseHeight[floor(i / (plane_mesh.size.x + 1))][i % int(plane_mesh.size.x + 1)] = vertex.y
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
	print(get_children().size())
	add_child(mesh_instance)
