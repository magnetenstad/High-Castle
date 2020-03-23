extends Particles


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	process_material.gravity = Vector3(9.8, 0, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
