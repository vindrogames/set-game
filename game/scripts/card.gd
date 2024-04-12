var number: String
var color: String
var shape: String
var fill: String
var file_name: String
var texture: Texture

func _init(n,c,s,f,fn):
	number = n
	color = c
	shape = s
	fill = f
	file_name = fn
	var final_string = "res://img/cards/"+ file_name
	texture = load(final_string)

func print_file_name():
	
	var final_string = "res://img/cards/"+ file_name
	return final_string
	
func print_name_simple():
	var final_string = number+ "-"+color+"-"+shape+"-"+fill
	return final_string
	
func get_n():
	return number
func get_c():
	return color
func get_s():
	return shape
func get_f():
	return fill
	
func set_c(c):
	color = c
	
func get_texture():
	return texture
