extends StaticBody

var health = 100
var health_max = 100
var target

func _ready():
	pass
	
func _process(_delta):
	pass

func take_damage(n):
	health -= n
	if(health <= 0):
		queue_free()

