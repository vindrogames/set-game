extends TextureButton

var selected = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.





func _on_pressed() -> void:
	var num_sel = get_node("/root/main").get_num_selected()
	var mainNode = get_node("/root/main")
	if (!selected):
		if num_sel < 3:
			selected = true
			get_node("TextureRect").modulate = Color(1, 1, 1, 0.5)
			mainNode.add_selections(9)

func clear_button():
	selected = false
	get_node("TextureRect").modulate = Color(1, 1, 1, 1)
