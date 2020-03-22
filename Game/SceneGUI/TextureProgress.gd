extends TextureProgress

var health = 100

func _ready():
	tint_progress = Color(1, 1, 1, 1)
	tint_under = Color(0.5, 0.5, 0.5, 1)

func _process(delta):
	value = health
	$Label.text = str(health)
	

