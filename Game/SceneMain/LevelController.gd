extends Node

const ENEMY = preload("res://SceneEnemy/Enemy.tscn")
var rng = RandomNumberGenerator.new()

func _ready():
	pass

func start_level():
	var turrets = $"/root/Main/World/Merchant/Turrets"
	if turrets.has_node("Core"):
		for i in range(10):
			var enemy = ENEMY.instance()
			rng.randomize()
			var pos = Vector3(2*(randf() -.5), 0, 2*(randf() -.5)).normalized() * 5 + Vector3(0, 1, 0) * 5
			if turrets.has_node("Spawner"):
				pos += turrets.get_node("Spawner").translation
			enemy.translate(pos)
			get_node("Enemies").add_child(enemy)
