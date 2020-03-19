extends Spatial

var offset = []
var rng = RandomNumberGenerator.new()
var lastUpdateTimer = 0

func _ready():
	for i in range(32+2):
		offset.append([])
		for j in range(32+2):
			rng.randomize() 
			#var rand = rng.randf_range(-100.0, 100.0)
			offset[i] += [0]
	GenerateMesh()
	
func Terraform():
	var ray_length = 1000
	var camera = get_viewport().get_camera()
	var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * ray_length
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(from, to)
	result.position.y += 1
	result.position.x = round(result.position.x) + 18
	result.position.y = round(result.position.y) + 18
	result.position.z = round(result.position.z) + 18
	print("x: " + str(result.position.x) + "  " + "z: " + str(result.position.z))
	offset[-result.position.z][-result.position.x] += .1
	offset[-result.position.z+1][-result.position.x] += .1
	offset[-result.position.z+1][-result.position.x+1] += .1
	offset[-result.position.z][-result.position.x+1] += .1
	GenerateMesh()

func _process(delta):
	lastUpdateTimer += delta
	if(lastUpdateTimer > 0.05) and Input.is_mouse_button_pressed(2):
		Terraform()
		lastUpdateTimer = 0
	
func GenerateMesh():
	for n in get_children():
		if(n.get_name() == "Terrain"):
			remove_child(n)
	var noise = OpenSimplexNoise.new()
	noise.period = 80
	noise.octaves = 6

	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(32, 32)
	plane_mesh.subdivide_depth = plane_mesh.size.x
	plane_mesh.subdivide_width = plane_mesh.size.x

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)

	var array_plane = surface_tool.commit()

	var data_tool = MeshDataTool.new()

	data_tool.create_from_surface(array_plane, 0)
	print(data_tool.get_vertex_count())
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = floor(noise.get_noise_3d(vertex.x, vertex.y, vertex.z) * 10) + offset[floor(i / (plane_mesh.size.x + 2))][i % int(plane_mesh.size.x + 2)]
		if(vertex.y > 10):
			print(vertex.y)
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
