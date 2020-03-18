extends RigidBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var spd_x = 0
	var spd_y = 0
	var spd_z = 0
	
	if Input.is_key_pressed(KEY_D):
		spd_x = 1
	if Input.is_key_pressed(KEY_A):
		spd_x = -1
	if Input.is_key_pressed(KEY_S):
		spd_z = 1
	if Input.is_key_pressed(KEY_W):
		spd_z = -1
	if Input.is_key_pressed(KEY_SPACE):
		spd_y = 2
	
	add_central_force(Vector3(spd_x, spd_y, spd_z) * 30)
	
