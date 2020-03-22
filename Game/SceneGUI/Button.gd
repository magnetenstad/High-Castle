extends Button

var item;

func _ready():
	pass

func _on_Button_pressed():
	$"/root/Main/World/Merchant".selected_tower = item
	
