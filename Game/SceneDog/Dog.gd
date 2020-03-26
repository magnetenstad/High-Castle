extends KinematicBody

# Declare member variables here. Examples:
var gravity = Vector3.DOWN * 12
var speed = 0.5
var jump_speed = 4
var jump = false
var target
var velocity = Vector3()
var attack_range = 1.5

var dmg = 7
var team

var health = 1
const health_max = 20

var enemy_list = []

func _ready():
	health = health_max
	name = "Enemy"

func _physics_process(delta):
	velocity.x *= 0.5
	velocity.z *= 0.5
	velocity += gravity * delta
	if(is_instance_valid(target)):
		var vy = velocity.y
		velocity += speed * (target.translation - get_transform().origin).normalized()
		velocity.y = vy
	velocity = move_and_slide(velocity, Vector3.UP)
	if is_on_floor():
		velocity.y = jump_speed

func _on_AttackTimer_timeout():
	enemy_list.clear()
	for tmp_turret in get_tree().get_nodes_in_group("Turrets"):
		if(tmp_turret.team != team):
			enemy_list.append(tmp_turret)
	for tmp_dog in get_tree().get_nodes_in_group("Dogs"):
		if(tmp_dog.team != team):
			enemy_list.append(tmp_dog)
	
	for enemy_tmp in enemy_list:
		if(!is_instance_valid(target) || (enemy_tmp.translation - self.translation).length() <
		(target.translation - self.translation).length()):
			target = enemy_tmp
			
	if(is_instance_valid(target) && (target.translation - self.translation).length() < attack_range):
		target.take_damage(dmg, self)

func take_damage(amount, origin):
	if(!is_instance_valid(target) || (is_instance_valid(origin) && (origin.translation - self.translation).length() <
	(target.translation - self.translation).length())):
		target = origin
	health -= amount
	velocity.y = 8
	$Sprite3D.modulate = Color(1, health/float(health_max), health/float(health_max))
	if health <= 0:
		queue_free()
		$"/root/Main/World/Merchant".balance += 5
