extends KinematicBody

const EXPLOSION = preload("res://SceneTurret/SimpleTurret/Explosion.tscn")

var velocity = Vector3()
var gravity = 1
var target = Vector3()
var direction = Vector3()
#var is_dying = false
var origin

const damage = 10

func _ready():
	velocity = 5*direction + 20*Vector3.UP


func _physics_process(delta):
	velocity.y -= gravity

	look_at(translation - direction, Vector3.UP)

	velocity = move_and_slide(velocity, Vector3.UP)



func _on_Area_body_entered(body):
	#print("name")
	#print(body.get_name())
	if "Dog" in body.get_name():
		body.take_damage(damage, origin)
		explode()
	elif "Terrain" in body.get_name():
		explode()



func explode():
	var particles = EXPLOSION.instance()
	$"/root/Main/World".add_child(particles)
	particles.translation = translation
	for child in particles.get_children():
		child.one_shot = true
	queue_free()
