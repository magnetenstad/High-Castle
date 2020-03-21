extends Spatial

var speed = 12
var min_speed = 16
var max_speed = 36
var y_speed = 16
var spin = PI/1024
var dragging = false
var velocity = Vector3()

func _physics_process(delta):
	get_input()
	global_translate(velocity*delta)

func get_input():
	velocity.x = 0
	velocity.z = 0
	velocity.y = 0

	if Input.is_key_pressed(KEY_CONTROL):
		speed = max_speed
	else:
		speed = min_speed
	var vy = velocity.y
	if Input.is_key_pressed(KEY_A):
		velocity += -transform.basis.x * speed
	if Input.is_key_pressed(KEY_D):
		velocity += transform.basis.x * speed
	if Input.is_key_pressed(KEY_W):
		velocity += -transform.basis.x.cross(Vector3(0, 1, 0)) * speed
	if Input.is_key_pressed(KEY_S):
		velocity += transform.basis.x.cross(Vector3(0, 1, 0)) * speed
	velocity.y = vy

	if Input.is_key_pressed(KEY_SHIFT):
		velocity.y -= y_speed
	if Input.is_key_pressed(KEY_SPACE):
		velocity.y += y_speed
	if Input.is_key_pressed(KEY_LEFT):
		rotate_y(PI/100)
	if Input.is_key_pressed(KEY_RIGHT):
		rotate_y(-PI/100)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 3:
			dragging = not dragging
	elif event is InputEventMouseMotion and dragging:
		rotate_y(-lerp(0, spin, event.relative.x))
		rotate_object_local(Vector3(1, 0, 0), -lerp(0, spin, event.relative.y))
	if dragging:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
