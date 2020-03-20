extends Spatial


var speed = 8
var min_speed = 4
var max_speed = 24
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
		speed = (speed + max_speed*0.01)/(1+0.01)
	else:
		speed = min_speed
	
	if Input.is_key_pressed(KEY_A):
		velocity += -transform.basis.x * speed
	if Input.is_key_pressed(KEY_D):
		velocity += transform.basis.x * speed
	if Input.is_key_pressed(KEY_W):
		velocity += -transform.basis.z * speed
	if Input.is_key_pressed(KEY_S):
		velocity += transform.basis.z * speed
	if Input.is_key_pressed(KEY_SHIFT):
		velocity.y -= speed
	if Input.is_key_pressed(KEY_SPACE):
		velocity.y += speed
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
	if dragging:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)