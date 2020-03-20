extends KinematicBody

# Declare member variables here. Examples:
var gravity = Vector3.DOWN * 12
var speed = 2
var jump_speed = 4
var jump = false
var target = Vector3()
var velocity = Vector3()

func _physics_process(delta):
	
	velocity.x *= 0.5
	velocity.z *= 0.5
	
	target = get_node("../Player").get_transform().origin
	var vy = velocity.y
	velocity += speed * (target - get_transform().origin).normalized()
	velocity.y = vy
	velocity += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)
	if is_on_floor():
		velocity.y = jump_speed