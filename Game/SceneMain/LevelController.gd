extends Node

const enemy_const = preload("res://SceneEnemy/Enemy.tscn")
var rng = RandomNumberGenerator.new()

func _ready():
	pass

func start_level():
	for i in range(10):
		var enemy = enemy_const.instance()
		rng.randomize()
		var pos = Vector3(2*(randf() -.5), 0, 2*(randf() -.5)).normalized() * 30 + Vector3(0, 1, 0) * 5
		enemy.translate(pos)
		get_node("Enemies").add_child(enemy)
