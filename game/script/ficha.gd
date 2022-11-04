class_name Ficha

var number
var color
var shape
var fill
var color_type
var file_name

func _init(n,c,s,f,ct,fn):
	number = n
	color = c
	shape = s
	fill = f
	color_type = ct
	file_name = fn
	

	
func print_file_name():
	
	var final_string = "res://img/" + color_type +"/" + file_name
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
