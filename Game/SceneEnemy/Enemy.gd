extends KinematicBody

# Declare member variables here. Examples:
var gravity = Vector3.DOWN * 12
var speed = 0.5
var jump_speed = 4
var jump = false
var target
var velocity = Vector3()
var attack_range = 1

var dmg = 20

var health = 1
const max_health = 20

func _ready():
	target = $"/root/Main/World/Merchant/Turrets/Core"
	health = max_health
	name = "Enemy"

func _physics_process(delta):
	velocity.x *= 0.5
	velocity.z *= 0.5
	velocity += gravity * delta
	#if randf() > 0.995:
	#	target = translation + Vector3(randf()*20 - 10, 0, randf()*20-10)
	if(is_instance_valid(target)):
		var vy = velocity.y
		velocity += speed * (target.translation - get_transform().origin).normalized()
		velocity.y = vy
	velocity = move_and_slide(velocity, Vector3.UP)
	if is_on_floor():
		velocity.y = jump_speed
	
	$Sprite3D.modulate = Color(1, health/float(max_health), health/float(max_health))

func _on_AttackTimer_timeout():
	if(is_instance_valid(target) && (target.translation - self.translation).length() < attack_range):
		target.take_damage(dmg)

func take_damage(amount, origin):
	if(is_instance_valid(target) || (origin.translation - self.translation).length() < (target.translation - self.translation).length()):
		target = origin
	health -= amount
	velocity.y = 8
	if health <= 0:
		queue_free()
