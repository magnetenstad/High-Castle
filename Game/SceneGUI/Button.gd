extends Button

var team
var item
var button_type
var n = 0

func _ready():
	pass

func _on_Button_pressed():
	if(button_type == "Tower"):
		$"/root/Main/World/Merchant".selected_tower = item
	elif(button_type == "Wave"):
		for child in $"/root/Main/World/Merchant/Turrets".get_children():
			if("Spawner" in child.name):
				child.spawn()
	elif(button_type == "Unit"):
		var spawners = []
		for child in $"/root/Main/World/Merchant/Turrets".get_children():
			if("Spawner" in child.name && child.team == 0):
				spawners.append(child)
		if(spawners.size() > 0):
			spawners[n%spawners.size()].spawn(item)
			n += 1
	
