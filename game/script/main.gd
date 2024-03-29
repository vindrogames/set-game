extends Node2D

var fichas = []
var tablero = []
var num_selected = 0
var selections = []
var sound_click
var sound_correct
var sound_wrong
var winners = []

##########################
#    
func _init():
	randomize()
	init_fichas()
	
func _ready():
	
	get_node("helper/cardlist_label").hide()
	get_node("helper/Label2").hide()
	#get_node("helper/tablero_label").hide()
# warning-ignore:unused_variable
	var tablero_valido = false
	
	while (not tablero_valido):
	# We fill the initial board with the fichas
		for i in range(0,12):
			tablero.append(fichas.pop_front())
		# Lets check if there is at least 1 solution available
		tablero_valido = solution_finder_simple()
		# If there is no slution available we reset the state of the game completely
		if (not tablero_valido):
			clear_solver_button_container()
			fichas.clear()
			init_fichas()
			update_label_text()
			tablero.clear()	
	
	update_tablero_text()
	update_label_text()
	sound_click = get_node("sound/click")
	sound_correct = get_node("sound/correct")
	sound_wrong = get_node("sound/wrong")
	clear_solver_button_container()
	var check_if_solution = solution_finder_simple()
	if not check_if_solution:
		print("Warning: there is no solution available")
	else:
		print("Ok: Solution available")
	
func clickok():
	sound_click.play()

func get_num_selected():
	return num_selected
	
func add_num_selected():
	num_selected = num_selected + 1
	
func sub_num_selected():
	num_selected = num_selected - 1

##############################################################################
# This function tracks the selection of cards that the user does when playing
#

func add_selections(n):
	selections.append(n)
	add_num_selected()
	# When the user select the third card then we check if the selection is valid
	if num_selected > 2:
		var resul = solver_params(tablero[selections[0]],tablero[selections[1]],tablero[selections[2]])
		if resul:
			print("hay algo")
			get_node("helper/solver_label").set_text("YES!!!!!!")
			var solved_sprite = get_node("solved1/CollisionShape2D/sprite")
			var temp_texture = load(tablero[selections[0]].print_file_name())
			solved_sprite.set_texture(temp_texture)
			
			solved_sprite = get_node("solved2/CollisionShape2D/sprite")
			temp_texture = load(tablero[selections[1]].print_file_name())
			solved_sprite.set_texture(temp_texture)
			
			solved_sprite = get_node("solved3/CollisionShape2D/sprite")
			temp_texture = load(tablero[selections[2]].print_file_name())
			solved_sprite.set_texture(temp_texture)
			
			# Lets check if there is enough fichas from the stack to pop out
			if tablero.size() > 0 :
				tablero[selections[0]] = fichas.pop_front()
			if tablero.size() > 0 :
				tablero[selections[1]] = fichas.pop_front()
			if tablero.size() > 0 :
				tablero[selections[2]] = fichas.pop_front()
				
			update_tablero_text()
			update_label_text()
			sound_click.stop()
			sound_correct.play()
			get_node("helper/solutions_label").set_text("")
			clear_solver_button_container()
			# Again we check if there is a solution available after poping the cards
			var check_if_solution = solution_finder_simple()
			if not check_if_solution:
				print("Warning: there is no solution available")
				#TODO: We have to do something in case there is no solution available
			else:
				print("Ok: Solution available")
			
			
		else:
			print("nada")
			get_node("helper/solver_label").set_text("NOU :-(")
			sound_wrong.play()
		num_selected = 0
		
		selections.clear()
		clear_buttons()

func clear_buttons():
	#TODO: aqui tengo que arreglar el tema de que no me resetee el color de los botones
	# DONE? -> Fixed i think
	if tablero[0]:
		get_node("topleft").clear_button()
	if tablero[1]:
		get_node("topmiddle1").clear_button()
	if tablero[2]:
		get_node("topmiddle2").clear_button()
	if tablero[3]:
		get_node("topright").clear_button()
	if tablero[4]:
		get_node("centerleft").clear_button()
	if tablero[5]:
		get_node("centermiddle1").clear_button()
	if tablero[6]:
		get_node("centermiddle2").clear_button()
	if tablero[7]:
		get_node("centerright").clear_button()
	if tablero[8]:
		get_node("bottomleft").clear_button()
	if tablero[9]:
		get_node("bottommiddle1").clear_button()
	if tablero[10]:
		get_node("bottommiddle2").clear_button()
	if tablero[11]:
		get_node("bottomright").clear_button()

func solver():
	
	var result = true
	
	var ficha1
	var ficha2
	var ficha3
	
	ficha1 = tablero[0]
	ficha2 = tablero[1]
	ficha3 = tablero[2]
	
	if ficha1.get_n() == ficha2.get_n() and ficha1.get_n() != ficha3.get_n():
		result = false
	if ficha1.get_c() == ficha2.get_c() and ficha1.get_c() != ficha3.get_c():
		result = false
	if ficha1.get_s() == ficha2.get_s() and ficha1.get_s() != ficha3.get_s():
		result = false
	if ficha1.get_f() == ficha2.get_f() and ficha1.get_f() != ficha3.get_f():
		result = false
	
	if ficha2.get_n() == ficha3.get_n() and ficha2.get_n() != ficha1.get_n():
		result = false
	if ficha2.get_c() == ficha3.get_c() and ficha2.get_c() != ficha1.get_c():
		result = false
	if ficha2.get_s() == ficha3.get_s() and ficha2.get_s() != ficha1.get_s():
		result = false
	if ficha2.get_f() == ficha3.get_f() and ficha2.get_f() != ficha1.get_f():
		result = false
		
	if ficha1.get_n() == ficha3.get_n() and ficha2.get_n() != ficha1.get_n():
		result = false
	if ficha1.get_c() == ficha3.get_c() and ficha2.get_c() != ficha1.get_c():
		result = false
	if ficha1.get_s() == ficha3.get_s() and ficha2.get_s() != ficha1.get_s():
		result = false
	if ficha1.get_f() == ficha3.get_f() and ficha2.get_f() != ficha1.get_f():
		result = false
	return result
	
func solver_params(t1, t2, t3):
	
	var result = true
	
	var ficha1
	var ficha2
	var ficha3
	
	ficha1 = t1
	ficha2 = t2
	ficha3 = t3
	
	if not ficha1 or not ficha2 or not ficha3:
		return false
	
	if ficha1.get_n() == ficha2.get_n() and ficha1.get_n() != ficha3.get_n():
		result = false
	if ficha1.get_c() == ficha2.get_c() and ficha1.get_c() != ficha3.get_c():
		result = false
	if ficha1.get_s() == ficha2.get_s() and ficha1.get_s() != ficha3.get_s():
		result = false
	if ficha1.get_f() == ficha2.get_f() and ficha1.get_f() != ficha3.get_f():
		result = false
	
	if ficha2.get_n() == ficha3.get_n() and ficha2.get_n() != ficha1.get_n():
		result = false
	if ficha2.get_c() == ficha3.get_c() and ficha2.get_c() != ficha1.get_c():
		result = false
	if ficha2.get_s() == ficha3.get_s() and ficha2.get_s() != ficha1.get_s():
		result = false
	if ficha2.get_f() == ficha3.get_f() and ficha2.get_f() != ficha1.get_f():
		result = false
		
	if ficha1.get_n() == ficha3.get_n() and ficha2.get_n() != ficha1.get_n():
		result = false
	if ficha1.get_c() == ficha3.get_c() and ficha2.get_c() != ficha1.get_c():
		result = false
	if ficha1.get_s() == ficha3.get_s() and ficha2.get_s() != ficha1.get_s():
		result = false
	if ficha1.get_f() == ficha3.get_f() and ficha2.get_f() != ficha1.get_f():
		result = false
	return result
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

	
func get_random_sprite_name():
	var num_random = randi()%3+1
	var number
	var color
	var form
	var fill
	if num_random == 1:
		number = "1"
	elif num_random == 2:
		number = "2"
	else:
		number = "3"

	num_random = randi()%3+1
	if num_random == 1:
		color = "G"
	elif num_random == 2:
		color = "P"
	else:
		color = "R"
		
	num_random = randi()%3+1
	if num_random == 1:
		form = "R"
	elif num_random == 2:
		form = "D"
	else:
		form = "S"
		
	num_random = randi()%3+1
	if num_random == 1:
		fill = "F"
	elif num_random == 2:
		fill = "B"
	else:
		fill = "L"
		
	#print(num_random)
	var final_string = "res://img/img-128x128/" + number+ "-"+color+"-"+form+"-"+fill + ".png"
	#print(final_string)
	return final_string


func update_label_text():
	var tmp_text = ""
	var iterator = 0
	for i in fichas:
		tmp_text = tmp_text + i.print_name_simple() + "\n"
		iterator = iterator + 1
	get_node("helper/cardlist_label").set_text(tmp_text)
	

func update_tablero_text():
	var tmp_text = ""
	var iterator = 0
	for i in tablero:
		if iterator == 4 or iterator == 8:
			tmp_text = tmp_text + "\n\n"
		if i:
			tmp_text = tmp_text + i.print_name_simple() + "  "
			
		iterator = iterator + 1	
	var new_img
	
	var color_apagado = Color(0,0,0,0.5)
	if tablero[0]:
		new_img = load(tablero[0].print_file_name())
		get_node("topleft/CollisionShape2D/sprite").set_texture(new_img)
	else:
		get_node("topleft/CollisionShape2D/sprite").modulate = color_apagado
		get_node("topleft/CollisionShape2D").disabled = true
	if tablero[1]:
		new_img = load(tablero[1].print_file_name())
		get_node("topmiddle1/CollisionShape2D/sprite").set_texture(new_img)
	else:
		get_node("topmiddle1/CollisionShape2D/sprite").modulate = color_apagado
		get_node("topmiddle1/CollisionShape2D").disabled = true
	if tablero[2]:
		new_img = load(tablero[2].print_file_name())
		get_node("topmiddle2/CollisionShape2D/sprite").set_texture(new_img)
	else:
		get_node("topmiddle2/CollisionShape2D/sprite").modulate = color_apagado
		get_node("topmiddle2/CollisionShape2D").disabled = true
	if tablero[3]:
		new_img = load(tablero[3].print_file_name())
		get_node("topright/CollisionShape2D/sprite").set_texture(new_img)
	else:
		get_node("topright/CollisionShape2D/sprite").modulate = color_apagado
		get_node("topright/CollisionShape2D").disabled = true
	if tablero[4]:
		new_img = load(tablero[4].print_file_name())
		get_node("centerleft/CollisionShape2D/sprite").set_texture(new_img)
	else:
		get_node("centerleft/CollisionShape2D/sprite").modulate = color_apagado
		get_node("centerleft/CollisionShape2D").disabled = true
	if tablero[5]:
		new_img = load(tablero[5].print_file_name())
		get_node("centermiddle1/CollisionShape2D/sprite").set_texture(new_img)
	else:
		get_node("centermiddle1/CollisionShape2D/sprite").modulate = color_apagado
		get_node("centermiddle1/CollisionShape2D").disabled = true
	if tablero[6]:
		new_img = load(tablero[6].print_file_name())
		get_node("centermiddle2/CollisionShape2D/sprite").set_texture(new_img)
	else:
		get_node("centermiddle2/CollisionShape2D/sprite").modulate = color_apagado
		get_node("centermiddle2/CollisionShape2D").disabled = true
	if tablero[7]:
		new_img = load(tablero[7].print_file_name())
		get_node("centerright/CollisionShape2D/sprite").set_texture(new_img)
	else:
		get_node("centerright/CollisionShape2D/sprite").modulate = color_apagado
		get_node("centerright/CollisionShape2D").disabled = true
	if tablero[8]:
		new_img = load(tablero[8].print_file_name())
		get_node("bottomleft/CollisionShape2D/sprite").set_texture(new_img)
	else:
		get_node("bottomleft/CollisionShape2D/sprite").modulate = color_apagado
		get_node("bottomleft/CollisionShape2D").disabled = true
	if tablero[9]:
		new_img = load(tablero[9].print_file_name())
		get_node("bottommiddle1/CollisionShape2D/sprite").set_texture(new_img)
	else:
		get_node("bottommiddle1/CollisionShape2D/sprite").modulate = color_apagado
		get_node("bottommiddle1/CollisionShape2D").disabled = true
	if tablero[10]:
		new_img = load(tablero[10].print_file_name())
		get_node("bottommiddle2/CollisionShape2D/sprite").set_texture(new_img)
	else:
		get_node("bottommiddle2/CollisionShape2D/sprite").modulate = color_apagado
		get_node("bottommiddle2/CollisionShape2D").disabled = true
	if tablero[11]:
		new_img = load(tablero[11].print_file_name())
		get_node("bottomright/CollisionShape2D/sprite").set_texture(new_img)
	else:
		get_node("bottomright/CollisionShape2D/sprite").modulate = color_apagado
		get_node("bottomright/CollisionShape2D").disabled = true
	get_node("helper/tablero_label").set_text(str(fichas.size()))
func restart():
	clear_solver_button_container()
	fichas.clear()
	init_fichas()
	update_label_text()
	tablero.clear()
# warning-ignore:unused_variable
	for i in range(0,12):
		tablero.append(fichas.pop_front())
	update_tablero_text()
	update_label_text()
	get_node("helper/solutions_label").set_text("")
	solver_params(tablero[0],tablero[1],tablero[2])
	print(fichas.size())
	get_node("helper/tablero_label").set_text(str(fichas.size()))
	
func _on_Button_pressed():
	#restart()
	reset_tablero()
	var resultado = ""#= solver_params(tablero[0],tablero[1],tablero[2])
	if resultado:
		print("hay algo")
	else:
		print("nada")
		
	var check_if_solution = solution_finder_simple()
	if not check_if_solution:
		print("Warning: there is no solution available")
	else:
		print("Ok: Solution available")
	
func init_fichas():
	var Fichas = load("res://script/ficha.gd")
	fichas.append(Fichas.new("1","G","D","B"))
	fichas.append(Fichas.new("1","G","D","F"))
	fichas.append(Fichas.new("1","G","D","L"))
	fichas.append(Fichas.new("1","G","R","B"))
	
	fichas.append(Fichas.new("1","G","R","F"))
	fichas.append(Fichas.new("1","G","R","L"))
	fichas.append(Fichas.new("1","G","S","B"))
	fichas.append(Fichas.new("1","G","S","F"))
	
	fichas.append(Fichas.new("1","G","S","L"))
	fichas.append(Fichas.new("1","P","D","B"))
	fichas.append(Fichas.new("1","P","D","F"))
	fichas.append(Fichas.new("1","P","D","L"))
	
	fichas.append(Fichas.new("1","P","R","B"))
	fichas.append(Fichas.new("1","P","R","F"))
	fichas.append(Fichas.new("1","P","R","L"))
	fichas.append(Fichas.new("1","P","S","B"))
	
	fichas.append(Fichas.new("1","P","S","F"))
	fichas.append(Fichas.new("1","P","S","L"))
	fichas.append(Fichas.new("1","R","D","B"))
	fichas.append(Fichas.new("1","R","D","F"))
	
	fichas.append(Fichas.new("1","R","D","L"))
	fichas.append(Fichas.new("1","R","R","B"))
	fichas.append(Fichas.new("1","R","R","F"))
	fichas.append(Fichas.new("1","R","R","L"))
	
	fichas.append(Fichas.new("1","R","S","B"))
	fichas.append(Fichas.new("1","R","S","F"))
	fichas.append(Fichas.new("1","R","S","L"))
	fichas.append(Fichas.new("2","G","D","B"))
	
	fichas.append(Fichas.new("2","G","D","F"))
	fichas.append(Fichas.new("2","G","D","L"))
	fichas.append(Fichas.new("2","G","R","B"))
	fichas.append(Fichas.new("2","G","R","F"))
	
	fichas.append(Fichas.new("2","G","R","L"))
	fichas.append(Fichas.new("2","G","S","B"))
	fichas.append(Fichas.new("2","G","S","F"))
	fichas.append(Fichas.new("2","G","S","L"))
	
	fichas.append(Fichas.new("2","P","D","B"))
	fichas.append(Fichas.new("2","P","D","F"))
	fichas.append(Fichas.new("2","P","D","L"))
	fichas.append(Fichas.new("2","P","R","B"))
	
	fichas.append(Fichas.new("2","P","R","F"))
	fichas.append(Fichas.new("2","P","R","L"))
	fichas.append(Fichas.new("2","P","S","B"))
	fichas.append(Fichas.new("2","P","S","F"))
	
	fichas.append(Fichas.new("2","P","S","L"))
	fichas.append(Fichas.new("2","R","D","B"))
	fichas.append(Fichas.new("2","R","D","F"))
	fichas.append(Fichas.new("2","R","D","L"))
	
	fichas.append(Fichas.new("2","R","R","B"))
	fichas.append(Fichas.new("2","R","R","F"))
	fichas.append(Fichas.new("2","R","R","L"))
	fichas.append(Fichas.new("2","R","S","B"))
	fichas.append(Fichas.new("2","R","S","F"))
	fichas.append(Fichas.new("2","R","S","L"))
	
	fichas.append(Fichas.new("3","G","D","B"))
	fichas.append(Fichas.new("3","G","D","F"))
	fichas.append(Fichas.new("3","G","D","L"))
	fichas.append(Fichas.new("3","G","R","B"))
	fichas.append(Fichas.new("3","G","R","F"))
	fichas.append(Fichas.new("3","G","R","L"))
	
	fichas.append(Fichas.new("3","G","S","B"))
	fichas.append(Fichas.new("3","G","S","F"))
	fichas.append(Fichas.new("3","G","S","L"))
	fichas.append(Fichas.new("3","P","D","B"))
	fichas.append(Fichas.new("3","P","D","F"))
	fichas.append(Fichas.new("3","P","D","L"))
	
	fichas.append(Fichas.new("3","P","R","B"))
	fichas.append(Fichas.new("3","P","R","F"))
	fichas.append(Fichas.new("3","P","R","L"))
	fichas.append(Fichas.new("3","P","S","B"))
	fichas.append(Fichas.new("3","P","S","F"))
	fichas.append(Fichas.new("3","P","S","L"))
	
	fichas.append(Fichas.new("3","R","D","B"))
	fichas.append(Fichas.new("3","R","D","F"))
	fichas.append(Fichas.new("3","R","D","L"))
	fichas.append(Fichas.new("3","R","R","B"))
	fichas.append(Fichas.new("3","R","R","F"))
	fichas.append(Fichas.new("3","R","R","L"))
	
	fichas.append(Fichas.new("3","R","S","B"))
	fichas.append(Fichas.new("3","R","S","F"))
	fichas.append(Fichas.new("3","R","S","L"))
	
	fichas.shuffle()

func solution_finder():	
	var winners_label_text = ""
	var combs = [[0, 1, 2], [0, 1, 3], [0, 1, 4], [0, 1, 5], [0, 1, 6], [0, 1, 7], [0, 1, 8], [0, 1, 9], [0, 1, 10], [0, 1, 11], [0, 2, 3], [0, 2, 4], [0, 2, 5], [0, 2, 6], [0, 2, 7], [0, 2, 8], [0, 2, 9], [0, 2, 10], [0, 2, 11], [0, 3, 4], [0, 3, 5], [0, 3, 6], [0, 3, 7], [0, 3, 8], [0, 3, 9], [0, 3, 10], [0, 3, 11], [0, 4, 5], [0, 4, 6], [0, 4, 7], [0, 4, 8], [0, 4, 9], [0, 4, 10], [0, 4, 11], [0, 5, 6], [0, 5, 7], [0, 5, 8], [0, 5, 9], [0, 5, 10], [0, 5, 11], [0, 6, 7], [0, 6, 8], [0, 6, 9], [0, 6, 10], [0, 6, 11], [0, 7, 8], [0, 7, 9], [0, 7, 10], [0, 7, 11], [0, 8, 9], [0, 8, 10], [0, 8, 11], [0, 9, 10], [0, 9, 11], [0, 10, 11], [1, 2, 3], [1, 2, 4], [1, 2, 5], [1, 2, 6], [1, 2, 7], [1, 2, 8], [1, 2, 9], [1, 2, 10], [1, 2, 11], [1, 3, 4], [1, 3, 5], [1, 3, 6], [1, 3, 7], [1, 3, 8], [1, 3, 9], [1, 3, 10], [1, 3, 11], [1, 4, 5], [1, 4, 6], [1, 4, 7], [1, 4, 8], [1, 4, 9], [1, 4, 10], [1, 4, 11], [1, 5, 6], [1, 5, 7], [1, 5, 8], [1, 5, 9], [1, 5, 10], [1, 5, 11], [1, 6, 7], [1, 6, 8], [1, 6, 9], [1, 6, 10], [1, 6, 11], [1, 7, 8], [1, 7, 9], [1, 7, 10], [1, 7, 11], [1, 8, 9], [1, 8, 10], [1, 8, 11], [1, 9, 10], [1, 9, 11], [1, 10, 11], [2, 3, 4], [2, 3, 5], [2, 3, 6], [2, 3, 7], [2, 3, 8], [2, 3, 9], [2, 3, 10], [2, 3, 11], [2, 4, 5], [2, 4, 6], [2, 4, 7], [2, 4, 8], [2, 4, 9], [2, 4, 10], [2, 4, 11], [2, 5, 6], [2, 5, 7], [2, 5, 8], [2, 5, 9], [2, 5, 10], [2, 5, 11], [2, 6, 7], [2, 6, 8], [2, 6, 9], [2, 6, 10], [2, 6, 11], [2, 7, 8], [2, 7, 9], [2, 7, 10], [2, 7, 11], [2, 8, 9], [2, 8, 10], [2, 8, 11], [2, 9, 10], [2, 9, 11], [2, 10, 11], [3, 4, 5], [3, 4, 6], [3, 4, 7], [3, 4, 8], [3, 4, 9], [3, 4, 10], [3, 4, 11], [3, 5, 6], [3, 5, 7], [3, 5, 8], [3, 5, 9], [3, 5, 10], [3, 5, 11], [3, 6, 7], [3, 6, 8], [3, 6, 9], [3, 6, 10], [3, 6, 11], [3, 7, 8], [3, 7, 9], [3, 7, 10], [3, 7, 11], [3, 8, 9], [3, 8, 10], [3, 8, 11], [3, 9, 10], [3, 9, 11], [3, 10, 11], [4, 5, 6], [4, 5, 7], [4, 5, 8], [4, 5, 9], [4, 5, 10], [4, 5, 11], [4, 6, 7], [4, 6, 8], [4, 6, 9], [4, 6, 10], [4, 6, 11], [4, 7, 8], [4, 7, 9], [4, 7, 10], [4, 7, 11], [4, 8, 9], [4, 8, 10], [4, 8, 11], [4, 9, 10], [4, 9, 11], [4, 10, 11], [5, 6, 7], [5, 6, 8], [5, 6, 9], [5, 6, 10], [5, 6, 11], [5, 7, 8], [5, 7, 9], [5, 7, 10], [5, 7, 11], [5, 8, 9], [5, 8, 10], [5, 8, 11], [5, 9, 10], [5, 9, 11], [5, 10, 11], [6, 7, 8], [6, 7, 9], [6, 7, 10], [6, 7, 11], [6, 8, 9], [6, 8, 10], [6, 8, 11], [6, 9, 10], [6, 9, 11], [6, 10, 11], [7, 8, 9], [7, 8, 10], [7, 8, 11], [7, 9, 10], [7, 9, 11], [7, 10, 11], [8, 9, 10], [8, 9, 11], [8, 10, 11], [9, 10, 11]]
	for l in combs:
		var resul = solver_params(tablero[l[0]],tablero[l[1]],tablero[l[2]])
		if resul:
			winners.append([l[0],l[1],l[2]])
			winners_label_text = winners_label_text + str(int(l[0])+1) + " " + str(int(l[1])+1) + " " + str(int(l[2])+1) + "\n"
			var button1 = Button.new()
			#button1.text = str(int(l[0])+1) + " " + str(int(l[1])+1) + " " + str(int(l[2])+1)			
			button1.connect("pressed",Callable(self,"_on_button_solver_pressed"))
			button1.connect("mouse_entered",Callable(self,"_on_button_solver_entered").bind(l[0],l[1],l[2]))
			button1.connect("button_down",Callable(self,"_on_button_solver_entered").bind(l[0],l[1],l[2]))
			button1.connect("mouse_exited",Callable(self,"_on_button_solver_exited").bind(l[0],l[1],l[2]))
			button1.connect("button_up",Callable(self,"_on_button_solver_exited").bind(l[0],l[1],l[2]))
			button1.set("first",1)
			get_node("solver_button_container").add_child(button1)			
	print(winners)
	get_node("helper/solutions_label").set_text(winners_label_text)
	
# This funcion will simply check if there is any solution available checked the current status of the board
func solution_finder_simple():
	
	var exist_solution = false
	var combs = [[0, 1, 2], [0, 1, 3], [0, 1, 4], [0, 1, 5], [0, 1, 6], [0, 1, 7], [0, 1, 8], [0, 1, 9], [0, 1, 10], [0, 1, 11], [0, 2, 3], [0, 2, 4], [0, 2, 5], [0, 2, 6], [0, 2, 7], [0, 2, 8], [0, 2, 9], [0, 2, 10], [0, 2, 11], [0, 3, 4], [0, 3, 5], [0, 3, 6], [0, 3, 7], [0, 3, 8], [0, 3, 9], [0, 3, 10], [0, 3, 11], [0, 4, 5], [0, 4, 6], [0, 4, 7], [0, 4, 8], [0, 4, 9], [0, 4, 10], [0, 4, 11], [0, 5, 6], [0, 5, 7], [0, 5, 8], [0, 5, 9], [0, 5, 10], [0, 5, 11], [0, 6, 7], [0, 6, 8], [0, 6, 9], [0, 6, 10], [0, 6, 11], [0, 7, 8], [0, 7, 9], [0, 7, 10], [0, 7, 11], [0, 8, 9], [0, 8, 10], [0, 8, 11], [0, 9, 10], [0, 9, 11], [0, 10, 11], [1, 2, 3], [1, 2, 4], [1, 2, 5], [1, 2, 6], [1, 2, 7], [1, 2, 8], [1, 2, 9], [1, 2, 10], [1, 2, 11], [1, 3, 4], [1, 3, 5], [1, 3, 6], [1, 3, 7], [1, 3, 8], [1, 3, 9], [1, 3, 10], [1, 3, 11], [1, 4, 5], [1, 4, 6], [1, 4, 7], [1, 4, 8], [1, 4, 9], [1, 4, 10], [1, 4, 11], [1, 5, 6], [1, 5, 7], [1, 5, 8], [1, 5, 9], [1, 5, 10], [1, 5, 11], [1, 6, 7], [1, 6, 8], [1, 6, 9], [1, 6, 10], [1, 6, 11], [1, 7, 8], [1, 7, 9], [1, 7, 10], [1, 7, 11], [1, 8, 9], [1, 8, 10], [1, 8, 11], [1, 9, 10], [1, 9, 11], [1, 10, 11], [2, 3, 4], [2, 3, 5], [2, 3, 6], [2, 3, 7], [2, 3, 8], [2, 3, 9], [2, 3, 10], [2, 3, 11], [2, 4, 5], [2, 4, 6], [2, 4, 7], [2, 4, 8], [2, 4, 9], [2, 4, 10], [2, 4, 11], [2, 5, 6], [2, 5, 7], [2, 5, 8], [2, 5, 9], [2, 5, 10], [2, 5, 11], [2, 6, 7], [2, 6, 8], [2, 6, 9], [2, 6, 10], [2, 6, 11], [2, 7, 8], [2, 7, 9], [2, 7, 10], [2, 7, 11], [2, 8, 9], [2, 8, 10], [2, 8, 11], [2, 9, 10], [2, 9, 11], [2, 10, 11], [3, 4, 5], [3, 4, 6], [3, 4, 7], [3, 4, 8], [3, 4, 9], [3, 4, 10], [3, 4, 11], [3, 5, 6], [3, 5, 7], [3, 5, 8], [3, 5, 9], [3, 5, 10], [3, 5, 11], [3, 6, 7], [3, 6, 8], [3, 6, 9], [3, 6, 10], [3, 6, 11], [3, 7, 8], [3, 7, 9], [3, 7, 10], [3, 7, 11], [3, 8, 9], [3, 8, 10], [3, 8, 11], [3, 9, 10], [3, 9, 11], [3, 10, 11], [4, 5, 6], [4, 5, 7], [4, 5, 8], [4, 5, 9], [4, 5, 10], [4, 5, 11], [4, 6, 7], [4, 6, 8], [4, 6, 9], [4, 6, 10], [4, 6, 11], [4, 7, 8], [4, 7, 9], [4, 7, 10], [4, 7, 11], [4, 8, 9], [4, 8, 10], [4, 8, 11], [4, 9, 10], [4, 9, 11], [4, 10, 11], [5, 6, 7], [5, 6, 8], [5, 6, 9], [5, 6, 10], [5, 6, 11], [5, 7, 8], [5, 7, 9], [5, 7, 10], [5, 7, 11], [5, 8, 9], [5, 8, 10], [5, 8, 11], [5, 9, 10], [5, 9, 11], [5, 10, 11], [6, 7, 8], [6, 7, 9], [6, 7, 10], [6, 7, 11], [6, 8, 9], [6, 8, 10], [6, 8, 11], [6, 9, 10], [6, 9, 11], [6, 10, 11], [7, 8, 9], [7, 8, 10], [7, 8, 11], [7, 9, 10], [7, 9, 11], [7, 10, 11], [8, 9, 10], [8, 9, 11], [8, 10, 11], [9, 10, 11]]
	for l in combs:
		var resul = solver_params(tablero[l[0]],tablero[l[1]],tablero[l[2]])
		if resul:
			exist_solution = true	
	return exist_solution
	
func _on_button_finder_pressed():
	clear_solver_button_container()
	solution_finder()

func clear_solver_button_container():
	for i in get_node("solver_button_container").get_children():
		i.queue_free()
	winners = []
	
	
func _on_button_solver_entered(pos1,pos2,pos3):
	print(pos1,pos2,pos3)
	if pos1 == 0 or pos2 == 0 or pos3 == 0:
		get_node("topleft/CollisionShape2D/sprite").modulate = Color(0.25,0.25,0.25)
	if pos1 == 1 or pos2 == 1 or pos3 == 1:
		get_node("topmiddle1/CollisionShape2D/sprite").modulate = Color(0.25,0.25,0.25)
	if pos1 == 2 or pos2 == 2 or pos3 == 2:
		get_node("topmiddle2/CollisionShape2D/sprite").modulate = Color(0.25,0.25,0.25)
	if pos1 == 3 or pos2 == 3 or pos3 == 3:
		get_node("topright/CollisionShape2D/sprite").modulate = Color(0.25,0.25,0.25)
	if pos1 == 4 or pos2 == 4 or pos3 == 4:
		get_node("centerleft/CollisionShape2D/sprite").modulate = Color(0.25,0.25,0.25)
	if pos1 == 5 or pos2 == 5 or pos3 == 5:
		get_node("centermiddle1/CollisionShape2D/sprite").modulate = Color(0.25,0.25,0.25)
	if pos1 == 6 or pos2 == 6 or pos3 == 6:
		get_node("centermiddle2/CollisionShape2D/sprite").modulate = Color(0.25,0.25,0.25)
	if pos1 == 7 or pos2 == 7 or pos3 == 7:
		get_node("centerright/CollisionShape2D/sprite").modulate = Color(0.25,0.25,0.25)
	if pos1 == 8 or pos2 == 8 or pos3 == 8:
		get_node("bottomleft/CollisionShape2D/sprite").modulate = Color(0.25,0.25,0.25)
	if pos1 == 9 or pos2 == 9 or pos3 == 9:
		get_node("bottommiddle1/CollisionShape2D/sprite").modulate = Color(0.25,0.25,0.25)
	if pos1 == 10 or pos2 == 10 or pos3 == 10:
		get_node("bottommiddle2/CollisionShape2D/sprite").modulate = Color(0.25,0.25,0.25)
	if pos1 == 11 or pos2 == 11 or pos3 == 11:
		get_node("bottomright/CollisionShape2D/sprite").modulate = Color(0.25,0.25,0.25)
	
	
func _on_button_solver_exited(pos1,pos2,pos3):
	print(pos1,pos2,pos3)
	get_node("topleft/CollisionShape2D/sprite").modulate = Color(1,1,1)
	get_node("topmiddle1/CollisionShape2D/sprite").modulate = Color(1,1,1)
	get_node("topmiddle2/CollisionShape2D/sprite").modulate = Color(1,1,1)
	get_node("topright/CollisionShape2D/sprite").modulate = Color(1,1,1)
	get_node("centerleft/CollisionShape2D/sprite").modulate = Color(1,1,1)
	get_node("centermiddle1/CollisionShape2D/sprite").modulate = Color(1,1,1)
	get_node("centermiddle2/CollisionShape2D/sprite").modulate = Color(1,1,1)
	get_node("centerright/CollisionShape2D/sprite").modulate = Color(1,1,1)
	get_node("bottomleft/CollisionShape2D/sprite").modulate = Color(1,1,1)
	get_node("bottommiddle1/CollisionShape2D/sprite").modulate = Color(1,1,1)
	get_node("bottommiddle2/CollisionShape2D/sprite").modulate = Color(1,1,1)
	get_node("bottomright/CollisionShape2D/sprite").modulate = Color(1,1,1)
	

	
func reset_tablero():
	clear_solver_button_container()
	#fichas.clear()
	#init_fichas()
	update_label_text()
	tablero.clear()
# warning-ignore:unused_variable
	for i in range(0,12):
		tablero.append(fichas.pop_front())
	update_tablero_text()
	update_label_text()
	get_node("helper/solutions_label").set_text("")
	#solver_params(tablero[0],tablero[1],tablero[2])
	print(fichas.size())
	get_node("helper/tablero_label").set_text(str(fichas.size()))


func _on_how_to_play_button_pressed():
	get_node("how_to_play_dialog").popup()


func _on_close_help_button_pressed():
	get_node("how_to_play_dialog").hide()
