extends KinematicBody

const EXPLOSION = preload("res://SceneTurret/Explosion.tscn")

var velocity = Vector3()
var gravity = 1
var target = Vector3()
var direction = Vector3()
#var is_dying = false

const damage = 10

func _ready():
	velocity = 5*direction + 20*Vector3.UP


func _physics_process(delta):
	velocity.y -= gravity

	look_at(translation - direction, Vector3.UP)

	velocity = move_and_slide(velocity, Vector3.UP)

	if is_on_floor():
		explode()


func _on_Area_body_entered(body):
	if "Enemy" in body.get_name():
		body.health -= damage
		body.velocity.y = 8
		explode()


func explode():
	var particles = EXPLOSION.instance()
	$"/root/Main/World".add_child(particles)
	particles.transform = transform
	for child in particles.get_children():
		child.one_shot = true
	queue_free()
