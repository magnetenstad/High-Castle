extends TextureProgress


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var bop = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	tint_progress = Color(1, 1, 1, 1)
	tint_under = Color(0.5, 0.5, 0.5, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value += bop
	if value == 0 or value == 100:
		bop *= -1

