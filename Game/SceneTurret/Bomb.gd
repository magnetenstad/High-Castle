extends KinematicBody


var velocity = Vector3()
var gravity = 1
var target = Vector3()
var direction = Vector3()
var is_dying = false

const damage = 10

func _ready():
	velocity = 5*direction + 20*Vector3.UP
		

func _physics_process(delta):
	velocity.y -= gravity

	look_at(translation - direction, Vector3.UP)
	
	velocity = move_and_slide(velocity, Vector3.UP)
	if is_on_floor():
		queue_free()


func _on_Area_body_entered(body):
	if "Enemy" in body.get_name():
		body.health -= damage
		body.velocity.y = 8
		queue_free()
