extends KinematicBody

const EXPLOSION = preload("res://SceneTurret/Explosion.tscn")

var velocity = Vector3()
var gravity = 1
var target = Vector3()
var direction = Vector3()
#var is_dying = false

func _ready():
	var enemy_positions = []
	for enemy in $"/root/Main/World/LevelController/Enemies".get_children():
		enemy_positions.append(enemy.translation)
	var minimum_distance = pow(10, 9)
	var minimum_distance_position = Vector3()
	for pos in enemy_positions:
		if (pos.distance_to(translation)) < minimum_distance:
			minimum_distance = pos.distance_to(translation)
			minimum_distance_position = pos
	target = minimum_distance_position
	direction = (target - translation).normalized()
	velocity = 5*direction + 20*Vector3.UP

func _physics_process(delta):
	velocity.y -= gravity

	look_at(translation - direction, Vector3.UP)
	
	velocity = move_and_slide(velocity, Vector3.UP)
	if is_on_floor():# and not is_dying:
		#$DeathTimer.start()
		explode()
		
func _on_Area_body_entered(body):
	if "Enemy" in body.get_name():
		body.queue_free()
		explode()

func explode():
	var particles = EXPLOSION.instance()
	$"/root/Main/World".add_child(particles)
	particles.transform = transform
	for child in particles.get_children():
		child.one_shot = true
	queue_free()

func _on_DeathTimer_timeout():
	queue_free()
