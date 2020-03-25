extends Button

var item
var button_type

func _ready():
	pass

func _on_Button_pressed():
	if(button_type == "Tower"):
		$"/root/Main/World/Merchant".selected_tower = item
	elif(button_type == "Wave"):
		for child in $"/root/Main/World/Merchant/Turrets".get_children():
			if("Spawner" in child.name):
				child.spawn()
	
