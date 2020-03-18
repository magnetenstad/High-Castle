extends Spatial

func _ready():
	var noise = OpenSimplexNoise.new()
	noise.period = 80
	noise.octaves = 6

	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(128, 128)
	plane_mesh.subdivide_depth = plane_mesh.size.x
	plane_mesh.subdivide_width = plane_mesh.size.x
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	
	data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = floor(noise.get_noise_3d(vertex.x, vertex.y, vertex.z) * 10 / 1) * 1
		
		data_tool.set_vertex(i, vertex)
	
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)
		
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.set_surface_material(0, load("res://terrain.tres"))
	
	add_child(mesh_instance)

func _process(delta):
	$Rotate.rotate_y(delta * 0.5)
	
