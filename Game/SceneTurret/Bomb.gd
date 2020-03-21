extends KinematicBody
var velocity = Vector3()
var gravity = 1

func _ready():
	var direction = (Vector3(randf()*2-1, 0, randf()*2-1)).normalized()
	velocity = 5*direction + 20*Vector3.UP

func _physics_process(delta): 
	velocity.y -= gravity
	
	look_at(translation + velocity, Vector3.UP)
	velocity = move_and_slide(velocity, Vector3.UP)
	
	print("HELLO")
	if is_on_floor():
		queue_free()
