extends StaticBody

var health = 100
var health_max = 100
var target
var team

func _ready():
	pass
	
func _process(_delta):
	pass

func take_damage(n, origin):
	health -= n
	$Sprite3D.modulate = Color(1, health/float(health_max), health/float(health_max))
	$Base.modulate = Color(1, health/float(health_max), health/float(health_max))
	if(health <= 0):
		queue_free()

