extends Spatial

const TREE = preload("res://SceneTree/Tree.tscn")

var offset = []
var noise_height = []
var last_update_timer = 0

var chunk_size = 16
#total terrain size. Must be multiple of chunk size
var terrain_size = 256

func _ready():
	
	for i in range(terrain_size+1):
		offset.append([])
		for j in range(terrain_size+1):
			offset[i] += [0]
			
	for i in range(terrain_size+1):
		noise_height.append([])
		for j in range(terrain_size+1):
			noise_height[i] += [0]
			
	generate_water()
	for x in range(terrain_size / chunk_size):
		for z in range(terrain_size / chunk_size):
			generate_terrain(x, z)
	
	# Trees
	
#	var rand_generate = RandomNumberGenerator.new()
#	for i in range(terrain_size):
#		for j in range(terrain_size):
#			if rand_generate.randi_range(0, 1000) == 0:
#				spawn_tree(Vector3(-terrain_size/2 + i, 0, -terrain_size/2 + j))

func try_change(x, z, n, buffered_offset):
	var height_neighbors = [
		buffered_offset[x+1][z] + noise_height[x+1][z],
		buffered_offset[x][z+1] + noise_height[x][z+1],
		buffered_offset[x-1][z] + noise_height[x-1][z],
		buffered_offset[x][z-1] + noise_height[x][z-1],
		]
		
	if(n>0):
		if(height_neighbors.max() - (offset[x][z] + noise_height[x][z]) >= 0 &&
		 height_neighbors.min() - (offset[x][z] + noise_height[x][z]) >= 0):
			offset[x][z] += n
	else:
		if(height_neighbors.max() - (offset[x][z] + noise_height[x][z]) <= 0 &&
		 height_neighbors.min() - (offset[x][z] + noise_height[x][z]) <= 0):
			offset[x][z] += n
	return offset[x][z]

func terraform(n):
	var ray_length = 1000
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	if(result.empty()):
		return
	result.position.x = round(result.position.x - 0.75) + terrain_size
	result.position.z = round(result.position.z - 0.75) + terrain_size
	
	var x = result.position.x - terrain_size/2 - chunk_size/2
	var z = result.position.z - terrain_size/2 - chunk_size/2
	
	var buffered_offset = offset + []
	var heights = [
	noise_height[x][z] + offset[x][z],
	noise_height[x+1][z] + offset[x+1][z],
	noise_height[x+1][z+1] + offset[x+1][z+1],
	noise_height[x][z+1] + offset[x][z+1]]
	
	if(n > 0):
		var min_height  = heights.min()
		if(noise_height[x][z] + offset[x][z] == min_height):
			try_change(x, z, n, buffered_offset)
		if(noise_height[x+1][z] + offset[x+1][z] == min_height):
			try_change(x+1, z, n, buffered_offset)
		if(noise_height[x+1][z+1] + offset[x+1][z+1] == min_height):
			try_change(x+1, z+1, n, buffered_offset)
		if(noise_height[x][z+1] + offset[x][z+1] == min_height):
			try_change(x, z+1, n, buffered_offset)
	else:
		var max_height  = heights.max()
		if(noise_height[x][z] + offset[x][z] == max_height):
			try_change(x, z, n, buffered_offset)
		if(noise_height[x+1][z] + offset[x+1][z] == max_height):
			try_change(x+1, z, n, buffered_offset)
		if(noise_height[x+1][z+1] + offset[x+1][z+1] == max_height):
			try_change(x+1, z+1, n, buffered_offset)
		if(noise_height[x][z+1] + offset[x][z+1] == max_height):
			try_change(x, z+1, n, buffered_offset)
			
	var chunks = [[round(((x+1) / terrain_size) * (terrain_size / chunk_size)),
	round(((z+1) / terrain_size) * (terrain_size / chunk_size))],
	[round(((x+1) / terrain_size) * (terrain_size / chunk_size)),
	round(((z-1) / terrain_size) * (terrain_size / chunk_size))],
	[round(((x-1) / terrain_size) * (terrain_size / chunk_size)),
	round(((z-1) / terrain_size) * (terrain_size / chunk_size))],
	[round(((x-1) / terrain_size) * (terrain_size / chunk_size)),
	round(((z+1) / terrain_size) * (terrain_size / chunk_size))]
	]
	var refreshed_chunks = []
	for chunk in chunks:
		if(!refreshed_chunks.has(chunk)):
			refreshed_chunks += [chunk]
	for chunk in refreshed_chunks:
		print(chunk)
		generate_terrain(chunk[0], chunk[1])

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 2:
		if(Input.is_key_pressed(KEY_SHIFT)):
			terraform(-1)
		else:
			terraform(1)
	
func generate_terrain(x, z):
	print(str(x) + ", " + str(z))
	for n in get_children():
		if(n.get_name() == ("Terrain" + str(x) + "_" + str(z)) || n.get_name() == ("Water" + str(x) + "_" + str(z))):
			print("found")
			remove_child(n)
	var noise = OpenSimplexNoise.new()
	noise.period = 80
	noise.octaves = 6

	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = plane_mesh.size.x-1
	plane_mesh.subdivide_width = plane_mesh.size.x-1

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)

	var array_plane = surface_tool.commit()

	var data_tool = MeshDataTool.new()

	data_tool.create_from_surface(array_plane, 0)
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		noise_height[vertex.x + x * chunk_size][vertex.z + z * chunk_size] = floor(noise.get_noise_3d(vertex.x + x * chunk_size, vertex.y, vertex.z + z * chunk_size) * 10)
		vertex.y = noise_height[vertex.x + x * chunk_size][vertex.z + z * chunk_size] + offset[vertex.x + x * chunk_size][vertex.z + z * chunk_size]
		data_tool.set_vertex(i, vertex)
	
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)

	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()

	var mesh_instance = MeshInstance.new()
	mesh_instance.set_name("Terrain" + str(x) + "_" + str(z))
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.set_surface_material(0, load("res://Assets/terrain.tres"))
	mesh_instance.translate(mesh_instance.translation + Vector3(x * chunk_size +chunk_size/2, 0, z * chunk_size +chunk_size/2)
	- Vector3(terrain_size / 2, 0, terrain_size / 2))
	
	var mat = mesh_instance.get_surface_material(0)
	mat.set_shader_param("chunk_size", chunk_size)

	mesh_instance.create_trimesh_collision()
	add_child(mesh_instance)
	
	
func generate_water():
#	Water:

	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(terrain_size, terrain_size)

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)

	var array_plane = surface_tool.commit()

	var data_tool = MeshDataTool.new()

	data_tool.create_from_surface(array_plane, 0)
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()

	var mesh_instance = MeshInstance.new()
	mesh_instance.set_name("Water")
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.set_surface_material(0, load("res://Assets/water.tres"))
	mesh_instance.translate(mesh_instance.translation + Vector3(0, -0.5, 0))
	add_child(mesh_instance)

