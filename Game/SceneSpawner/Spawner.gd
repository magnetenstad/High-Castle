extends "res://SceneTurret/Turret.gd"

const DOG = preload("res://SceneDog/Dog.tscn")
var rng = RandomNumberGenerator.new()

func _ready():
	health_max = 500
	health = 500
	rng.randomize()

func spawn():
	for i in range(10):
		var dog = DOG.instance()
		var pos = Vector3(2*(randf() -.5), 0, 2*(randf() -.5)).normalized() * 2 + Vector3(0, 1, 0) * 5 + self.translation
		dog.translate(pos)
		dog.team = team
		$"/root/Main/World/LevelController/Units".add_child(dog)
