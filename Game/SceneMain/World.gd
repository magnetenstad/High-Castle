extends Spatial

const TREE = preload("res://SceneTree/Tree.tscn")

var offset = []
var noise_height = []
var last_update_timer = 0

var chunk_size = 16
var chunk_count = 16
var terrain_size = chunk_size * chunk_count

var verticesdict = {}
	
func _ready():
	
	for i in range(terrain_size+1):
		offset.append([])
		noise_height.append([])
		for _j in range(terrain_size+1):
			offset[i] += [0]
			noise_height[i] += [0]
	
	# Water
	var array_mesh_and_vertices = array_mesh_generate(terrain_size, false)
	var mesh_instance = mesh_instance_from_array_mesh("Water_0_0", array_mesh_and_vertices[0], array_mesh_and_vertices[1], load("res://Assets/water.tres"), false)
	water_from_mesh_instance(mesh_instance)

	for x in range(chunk_count):
		for z in range(chunk_count):
			mesh_instance = mesh_instance_from_noise("Terrain_" + str(x) + "_" + str(z), x, z, chunk_size, load("res://Assets/terrain.tres"), true)
			terrain_from_mesh_instance(mesh_instance, x, z)

func _input(event):
	if event.is_pressed() and not event.is_echo():
		if Input.is_key_pressed(KEY_K):
			game_save()
		if Input.is_key_pressed(KEY_L):
			game_load()
	
func terraform(n):
	var ray_length = 1000
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	if(result.empty()):
		return

	var x = round(result.position.x - 0.75) + terrain_size/2 - chunk_size/2
	var z = round(result.position.z - 0.75) + terrain_size/2 - chunk_size/2

	var buffered_offset = offset + []
	var heights = [
		noise_height[x][z] + offset[x][z],
		noise_height[x+1][z] + offset[x+1][z],
		noise_height[x+1][z+1] + offset[x+1][z+1],
		noise_height[x][z+1] + offset[x][z+1]
	]

	var target_height
	if(n > 0):
		target_height = heights.min()
	else:
		target_height = heights.max()

	if(noise_height[x][z] + offset[x][z] == target_height):
		try_change(x, z, n, buffered_offset)
	if(noise_height[x+1][z] + offset[x+1][z] == target_height):
		try_change(x+1, z, n, buffered_offset)
	if(noise_height[x+1][z+1] + offset[x+1][z+1] == target_height):
		try_change(x+1, z+1, n, buffered_offset)
	if(noise_height[x][z+1] + offset[x][z+1] == target_height):
		try_change(x, z+1, n, buffered_offset)

	var chunks = [
		[round(((x+1) / terrain_size) * (chunk_count)),
		round(((z+1) / terrain_size) * (chunk_count))],
		[round(((x+1) / terrain_size) * (chunk_count)),
		round(((z-1) / terrain_size) * (chunk_count))],
		[round(((x-1) / terrain_size) * (chunk_count)),
		round(((z-1) / terrain_size) * (chunk_count))],
		[round(((x-1) / terrain_size) * (chunk_count)),
		round(((z+1) / terrain_size) * (chunk_count))]
	]

	var refreshed_chunks = []
	for chunk in chunks:
		if(!refreshed_chunks.has(chunk)):
			refreshed_chunks += [chunk]
	for chunk in refreshed_chunks:
		x = chunk[0]
		z = chunk[1]
		var mesh_instance = mesh_instance_from_noise("Terrain_" + str(x) + "_" + str(z), x, z, chunk_size, load("res://Assets/terrain.tres"), true)
		terrain_from_mesh_instance(mesh_instance, x, z)

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

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 2:
		if(Input.is_key_pressed(KEY_SHIFT)):
			terraform(-1)
		else:
			terraform(1)

func array_mesh_generate(size, is_subdivided):  # generates flat array_mesh with optional subdivision
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size, size)
	
	if is_subdivided:
		plane_mesh.subdivide_depth = plane_mesh.size.x-1
		plane_mesh.subdivide_width = plane_mesh.size.x-1
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_mesh = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_mesh, 0)
	
	var vertices = []
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertices.append([vertex.x, vertex.y, vertex.z])

	return [array_mesh, vertices] # returns both array_mesh and vertices for saving

func array_mesh_from_noise(x, z, size): # generates array_mesh with noise
	var array_mesh = array_mesh_generate(size, true)[0]
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_mesh, 0)

	var noise = OpenSimplexNoise.new()
	noise.period = 80
	noise.octaves = 6
	var vertices = []
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		noise_height[vertex.x + x * chunk_size][vertex.z + z * chunk_size] = floor(noise.get_noise_3d(vertex.x + x * chunk_size, vertex.y, vertex.z + z * chunk_size) * 10)
		vertex.y = noise_height[vertex.x + x * chunk_size][vertex.z + z * chunk_size] + offset[vertex.x + x * chunk_size][vertex.z + z * chunk_size]
		data_tool.set_vertex(i, vertex)
		vertices.append([vertex.x, vertex.y, vertex.z])
	
		for i in range(array_mesh.get_surface_count()):
			array_mesh.surface_remove(i)

	data_tool.commit_to_surface(array_mesh)
	
	return [array_mesh, vertices] # returns both array_mesh and vertices for saving
	
func array_mesh_from_vertices(vertices, size, is_subdivided): # generates array_mesh from vertices array
	var array_mesh = array_mesh_generate(size, is_subdivided)[0]
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_mesh, 0)

	for i in vertices.size():
		var vertex = vertices[i]
		data_tool.set_vertex(i, Vector3(vertex[0], vertex[1], vertex[2]))

		for i in range(array_mesh.get_surface_count()):
			array_mesh.surface_remove(i)

	data_tool.commit_to_surface(array_mesh)
	
	return array_mesh # returns only array_mesh since vertices is already known

func mesh_instance_from_array_mesh(mesh_name, array_mesh, vertices, material, has_collision): # instances mesh_instance (get array_mesh and vertices from array_mesh_(..))
	for child in get_children():
		if child.get_name() == mesh_name:
			remove_child(child)
	
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_mesh, 0)
	surface_tool.generate_normals()

	var mesh_instance = MeshInstance.new()
	mesh_instance.set_name(mesh_name)
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.set_surface_material(0, material)
	
	if has_collision:
		mesh_instance.create_trimesh_collision()

	add_child(mesh_instance)
	verticesdict[mesh_name] = vertices # adds vertecies to dict for saving
	
	return mesh_instance

func mesh_instance_from_noise(mesh_name, x, z, size, material, has_collision):
	var array_mesh_and_vertices = array_mesh_from_noise(x, z, size)
	return mesh_instance_from_array_mesh(mesh_name, array_mesh_and_vertices[0], array_mesh_and_vertices[1], material, has_collision)

func mesh_instance_from_vertices(mesh_name, vertices, size, material, has_collision, is_subdivided):
	var array_mesh = array_mesh_from_vertices(vertices, size, is_subdivided)
	return mesh_instance_from_array_mesh(mesh_name, array_mesh, vertices, material, has_collision)

func terrain_from_mesh_instance(mesh_instance, x, z): # manipulates mesh_instance
	mesh_instance.translate(mesh_instance.translation
		+ Vector3(x * chunk_size + chunk_size/2, 0, z * chunk_size + chunk_size/2)
		- Vector3(terrain_size / 2, 0, terrain_size / 2))
	var mat = mesh_instance.get_surface_material(0)
	mat.set_shader_param("chunk_size", chunk_size)
	return mesh_instance
	
func water_from_mesh_instance(mesh_instance): # manipulates mesh_instance
	mesh_instance.translate(mesh_instance.translation + Vector3(0, -0.5, 0))
	return mesh_instance
	
func game_save():
	var file = File.new()
	file.open("user://savegame.save", File.WRITE)

	var root = {}
	
	root["verticesdict"] = verticesdict
	root["meshes"] = []

	for child in get_children():
		if "Water" in child.name or "Terrain" in child.name:
			root["meshes"].append(child.name)

	file.store_line(to_json(root))
	file.close()

func game_load():
	var file = File.new()
	if not file.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	for child in get_children():
		if "Water" in child.name or "Terrain" in child.name:
			remove_child(child)
			child.queue_free()

	file.open("user://savegame.save", File.READ)
	
	var current_line = parse_json(file.get_line())
	
	while current_line != null:
		for mesh_name in current_line["meshes"]:
			var coords = mesh_name.split_floats("_", false)
			var x = coords[1]
			var z = coords[2]
			
			if "Water" in mesh_name:
				var mesh_instance = mesh_instance_from_vertices(mesh_name, current_line["verticesdict"][mesh_name], terrain_size, load("res://Assets/water.tres"), false, false)
				water_from_mesh_instance(mesh_instance)
			else:
				var mesh_instance = mesh_instance_from_vertices(mesh_name, current_line["verticesdict"][mesh_name], chunk_size, load("res://Assets/terrain.tres"), true, true)
				terrain_from_mesh_instance(mesh_instance, x, z)
		
		current_line = parse_json(file.get_line())
		
	file.close()
