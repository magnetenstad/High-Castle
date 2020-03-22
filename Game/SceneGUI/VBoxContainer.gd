extends VBoxContainer

func _ready():
	var butt
	
	butt = Button.new()
	butt.text = "SimpleTurret"
	add_child(butt)
	
	butt = Button.new()
	butt.text = "Tree"
	add_child(butt)
	
