extends KinematicBody

# Declare member variables here. Examples:
var gravity = Vector3.DOWN * 12
var speed = 4
var jump_speed = 6
var jump = false

var velocity = Vector3()

func _physics_process(delta):
	velocity += gravity * delta
	get_input()
	velocity = move_and_slide(velocity, Vector3.UP)
	if jump == true and is_on_floor():
		velocity.y = jump_speed
	
func get_input():
	velocity.x = 0
	velocity.z = 0
	if Input.is_key_pressed(KEY_A):
		velocity += -transform.basis.x * speed
	if Input.is_key_pressed(KEY_D):
		velocity += transform.basis.x * speed
	if Input.is_key_pressed(KEY_W):
		velocity += -transform.basis.z * speed
	if Input.is_key_pressed(KEY_S):
		velocity += transform.basis.z * speed
	if Input.is_key_pressed(KEY_LEFT):
		rotate_y(PI/100)
	if Input.is_key_pressed(KEY_RIGHT):
		rotate_y(-PI/100)
	jump = false
	if Input.is_key_pressed(KEY_SPACE):
		jump = true