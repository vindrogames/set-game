extends Button

var old_style: StyleBox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_hover(boton: Button):
	var new_stylebox_normal = self.get_theme_stylebox("normal").duplicate()
	old_style = new_stylebox_normal
	new_stylebox_normal.border_width_top = 7
	new_stylebox_normal.border_color = Color(0, 1, 0.5)
	self.add_theme_stylebox_override("normal", new_stylebox_normal)
