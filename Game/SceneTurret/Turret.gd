extends StaticBody

var HP = 100
var maxHP = 100
var target

func _ready():
	pass
	
func _process(delta):
	pass

func takeDamage(n):
	HP -= n
	if(HP <= 0):
		queue_free()

