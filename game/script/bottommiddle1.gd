extends Area2D


var selected = false

func _ready():	
	pass	

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed():
		self.on_click()

func on_click():
	var num_sel = get_node("/root/Node2D").get_num_selected()
	var mainNode = get_node("/root/Node2D")
	if (!selected):
		if num_sel < 3:
			selected = true
			get_node("CollisionShape2D/sprite").modulate = Color(1, 1, 1, 0.5)
			mainNode.add_selections(9)
			get_node("/root/Node2D").clickok()

func clear_button():
	selected = false
	get_node("CollisionShape2D/sprite").modulate = Color(1, 1, 1, 1)
