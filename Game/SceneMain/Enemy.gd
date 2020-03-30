extends Node


func _ready():
	pass
	yield(get_tree().create_timer(0.1),"timeout")
	var merchant = $"/root/Main/World/Merchant"
	
	merchant.attempt_build(merchant.raytrace_down(Vector3(-4, 200, -3)), "SimpleTurret", 1)
	merchant.attempt_build(merchant.raytrace_down(Vector3(0, 200, 0)), "Core", 1)
	merchant.attempt_build(merchant.raytrace_down(Vector3(4, 200, 0)), "SimpleTurret", 1)
	merchant.attempt_build(merchant.raytrace_down(Vector3(6, 200, 2)), "SimpleTurret", 1)
	merchant.attempt_build(merchant.raytrace_down(Vector3(4, 200, 4)), "SimpleTurret", 1)
	merchant.attempt_build(merchant.raytrace_down(Vector3(0, 200, 4)), "Spawner", 1)
