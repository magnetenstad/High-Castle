extends Node


var lastSpawn = 0
var merchant
var n = 0

func _ready():
	yield(get_tree().create_timer(0.1),"timeout")
	merchant = $"/root/Main/World/Merchant"
	
	merchant.attempt_build(merchant.raytrace_down(Vector3(-4, 200, -3)), "SimpleTurret", 1)
	merchant.attempt_build(merchant.raytrace_down(Vector3(0, 200, 0)), "Core", 1)
	merchant.attempt_build(merchant.raytrace_down(Vector3(4, 200, 0)), "SimpleTurret", 1)
	merchant.attempt_build(merchant.raytrace_down(Vector3(6, 200, 2)), "SimpleTurret", 1)
	merchant.attempt_build(merchant.raytrace_down(Vector3(4, 200, 4)), "SimpleTurret", 1)
	merchant.attempt_build(merchant.raytrace_down(Vector3(0, 200, 4)), "Spawner", 1)
	
func _process(delta):
	if(OS.get_ticks_msec() - lastSpawn > 3000):
		lastSpawn = OS.get_ticks_msec()
		
		var playerCore = false
		for child in $"/root/Main/World/Merchant/Turrets".get_children():
			if("Core" in child.name && child.team == 0):
				playerCore = true
				
		if(playerCore):
			var spawners = []
			for child in $"/root/Main/World/Merchant/Turrets".get_children():
				if("Spawner" in child.name && child.team == 1):
					spawners.append(child)
			if(spawners.size() > 0):
				spawners[n%spawners.size()].spawn(0)
				n += 1
