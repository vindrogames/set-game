extends Node2D

######### DEBUG SETTINGS ############
const DEBUG = false
######### END ###########

######### PARAMETER SETTINGS ###########
const MAX_FICHAS = 81
const PUNTOS_ACIERTO = 3
const PUNTOS_ERROR = -2
const PUNTOS_NO_SET_CORRECTO = 4
const PUNTOS_NO_SET_ERROR = -5
const MAX_NUMBER_HINTS = 3
######### END ###########

######### TRACKING SETTINGS ############
var points = 0
var time_played = 0
var hints_used = 0
var failed_sets = 0
var correct_sets = 0
######### END ###########

var cards = []
var tablero = []
var num_selected = 0
var selections = []
var sound_select
var sound_right
var sound_wrong
var winners = []
var number_hints = MAX_NUMBER_HINTS
# We can track if the game is paused, for now only for the timer feature
var global_pause = false

const Cards = preload("res://scripts/card.gd")
var ins_scene = preload("res://scenes/instructions.tscn")
var end_screen = preload("res://scenes/endscreen.tscn")
var instance
############### COLORS ##################
var yellow_card: Color = Color(0.98,0.86,0.29,1)
var red_card: Color = Color(2.12,0.56,0.21,1)
var red_red: Color = Color.html("#d43815")
var tween_timer: float = 0.5

######### HINT ############
var hint

######### TIME ##############

var minutes = 0
var old_minutes = 0
var seconds = 0
var old_seconds = 0

# This will get the starting unix time in the format 232322323223
var initial_unix_time: float = Time.get_unix_time_from_system()
var initial_unix_time_int: int = initial_unix_time

var pause_starts: float = 0
var pause_ends: float = 0
var pause_time: float = 0


func _init() -> void:
	init_cards()
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (not DEBUG):
		var node_trampas: Node2D = get_node("trampas")
		node_trampas.hide()
		node_trampas.PROCESS_MODE_DISABLED
	update_points(0)
	var tablero_valido = false
	while (not tablero_valido):
	# We fill the initial board with the fichas
		for i in range(0,12):
			tablero.append(cards.pop_back())
		# Lets check if there is at least 1 solution available
		tablero_valido = solution_finder_simple()
		# If there is no slution available we reset the state of the game completely
		if (not tablero_valido):
			## This was clearing the cheat solver helper button
			## clear_solver_button_container()
			cards.clear()
			init_cards()
			tablero.clear()
	# Now we update the cards themselves on the board to reflect the cards on tablero	
	# clear_solver_button_container()
	var check_if_solution = solution_finder_simple()
	if not check_if_solution:
		print("Warning: there is no solution available")
	else:
		print("Ok: Solution available")
	#await get_tree().create_timer(2.0).timeout
	update_tablero(selections)
	
	#### LOAD SOUNDS ####
	
	sound_select = get_node("sound/select")
	sound_right = get_node("sound/right")
	sound_wrong = get_node("sound/wrong")
	
	# We are on production
	
func _process(_delta: float) -> void:
	update_timer()
######## NOTES ########
#
#	This is the card stack initializer, it will go through the image directory and will take from the file name
#	the caracteristics of the Card object: number, color, shape and fill and will create an array with card
#	objects, with its reference with the image that should load and then will shuffle
######################

func init_cards():
	var dir = DirAccess.open("res://img/cards")
	if dir != null:
		# We followed the godot tutorial to go through all the files on the directory:
		# https://docs.godotengine.org/en/stable/classes/class_diraccess.html#diraccess
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# if we find a directory inside the folder we do not want to do anything with the cards
				print("Found directory: " + file_name)
			# What happened is that when exporting to HTML or Windows it only exported somehow in the directory the .import files
			# I had to infer the file name from this file so it also works from inside Godot and when exporting
			elif ("import" in file_name) :
				var real_filename = file_name[0] + "-" + file_name[2] + "-" + file_name[4] + "-"+ file_name[6] + ".png"
				# Here we build the stack of cards
				cards.append(Cards.new(file_name[0],file_name[2],file_name[4],file_name[6],real_filename))
			# Then we select the next file until the next file name is empty
			file_name = dir.get_next()
	else:
		# In case there is no directory quit the application
		get_tree().quit()
	cards.shuffle()
	
	return cards;

func solution_finder_simple():
	
	var exist_solution = false
	var combs = [[0, 1, 2], [0, 1, 3], [0, 1, 4], [0, 1, 5], [0, 1, 6], [0, 1, 7], [0, 1, 8], [0, 1, 9], [0, 1, 10], [0, 1, 11], [0, 2, 3], [0, 2, 4], [0, 2, 5], [0, 2, 6], [0, 2, 7], [0, 2, 8], [0, 2, 9], [0, 2, 10], [0, 2, 11], [0, 3, 4], [0, 3, 5], [0, 3, 6], [0, 3, 7], [0, 3, 8], [0, 3, 9], [0, 3, 10], [0, 3, 11], [0, 4, 5], [0, 4, 6], [0, 4, 7], [0, 4, 8], [0, 4, 9], [0, 4, 10], [0, 4, 11], [0, 5, 6], [0, 5, 7], [0, 5, 8], [0, 5, 9], [0, 5, 10], [0, 5, 11], [0, 6, 7], [0, 6, 8], [0, 6, 9], [0, 6, 10], [0, 6, 11], [0, 7, 8], [0, 7, 9], [0, 7, 10], [0, 7, 11], [0, 8, 9], [0, 8, 10], [0, 8, 11], [0, 9, 10], [0, 9, 11], [0, 10, 11], [1, 2, 3], [1, 2, 4], [1, 2, 5], [1, 2, 6], [1, 2, 7], [1, 2, 8], [1, 2, 9], [1, 2, 10], [1, 2, 11], [1, 3, 4], [1, 3, 5], [1, 3, 6], [1, 3, 7], [1, 3, 8], [1, 3, 9], [1, 3, 10], [1, 3, 11], [1, 4, 5], [1, 4, 6], [1, 4, 7], [1, 4, 8], [1, 4, 9], [1, 4, 10], [1, 4, 11], [1, 5, 6], [1, 5, 7], [1, 5, 8], [1, 5, 9], [1, 5, 10], [1, 5, 11], [1, 6, 7], [1, 6, 8], [1, 6, 9], [1, 6, 10], [1, 6, 11], [1, 7, 8], [1, 7, 9], [1, 7, 10], [1, 7, 11], [1, 8, 9], [1, 8, 10], [1, 8, 11], [1, 9, 10], [1, 9, 11], [1, 10, 11], [2, 3, 4], [2, 3, 5], [2, 3, 6], [2, 3, 7], [2, 3, 8], [2, 3, 9], [2, 3, 10], [2, 3, 11], [2, 4, 5], [2, 4, 6], [2, 4, 7], [2, 4, 8], [2, 4, 9], [2, 4, 10], [2, 4, 11], [2, 5, 6], [2, 5, 7], [2, 5, 8], [2, 5, 9], [2, 5, 10], [2, 5, 11], [2, 6, 7], [2, 6, 8], [2, 6, 9], [2, 6, 10], [2, 6, 11], [2, 7, 8], [2, 7, 9], [2, 7, 10], [2, 7, 11], [2, 8, 9], [2, 8, 10], [2, 8, 11], [2, 9, 10], [2, 9, 11], [2, 10, 11], [3, 4, 5], [3, 4, 6], [3, 4, 7], [3, 4, 8], [3, 4, 9], [3, 4, 10], [3, 4, 11], [3, 5, 6], [3, 5, 7], [3, 5, 8], [3, 5, 9], [3, 5, 10], [3, 5, 11], [3, 6, 7], [3, 6, 8], [3, 6, 9], [3, 6, 10], [3, 6, 11], [3, 7, 8], [3, 7, 9], [3, 7, 10], [3, 7, 11], [3, 8, 9], [3, 8, 10], [3, 8, 11], [3, 9, 10], [3, 9, 11], [3, 10, 11], [4, 5, 6], [4, 5, 7], [4, 5, 8], [4, 5, 9], [4, 5, 10], [4, 5, 11], [4, 6, 7], [4, 6, 8], [4, 6, 9], [4, 6, 10], [4, 6, 11], [4, 7, 8], [4, 7, 9], [4, 7, 10], [4, 7, 11], [4, 8, 9], [4, 8, 10], [4, 8, 11], [4, 9, 10], [4, 9, 11], [4, 10, 11], [5, 6, 7], [5, 6, 8], [5, 6, 9], [5, 6, 10], [5, 6, 11], [5, 7, 8], [5, 7, 9], [5, 7, 10], [5, 7, 11], [5, 8, 9], [5, 8, 10], [5, 8, 11], [5, 9, 10], [5, 9, 11], [5, 10, 11], [6, 7, 8], [6, 7, 9], [6, 7, 10], [6, 7, 11], [6, 8, 9], [6, 8, 10], [6, 8, 11], [6, 9, 10], [6, 9, 11], [6, 10, 11], [7, 8, 9], [7, 8, 10], [7, 8, 11], [7, 9, 10], [7, 9, 11], [7, 10, 11], [8, 9, 10], [8, 9, 11], [8, 10, 11], [9, 10, 11]]
	for l in combs:
		var resul = solver_params(tablero[l[0]],tablero[l[1]],tablero[l[2]])
		if resul[0]:
			exist_solution = true
			hint = l[0]
			print("Hint: " + str(l[0]))
	if (!exist_solution):
		# If there is no solution we need the hint to be an invalid value
		hint = -5
	return exist_solution
	
# Solver al que se le pasan los parametros
func solver_params(t1, t2, t3):
	
	var result = []
	
	var result_num = true
	var result_color = true
	var result_shape = true
	var result_fill = true
	var result_no_ficha = true
	
	var ficha1
	var ficha2
	var ficha3
	
	ficha1 = t1
	ficha2 = t2
	ficha3 = t3
	
	# We have to check if there are no cards on the spot positions of the tablero
	if not ficha1 or not ficha2 or not ficha3:
		result_no_ficha = false
		# If there is any ficha  missing then for sure we cannot proceed
	else:
		if ficha1.get_n() == ficha2.get_n() and ficha1.get_n() != ficha3.get_n():
			# The number is wrong
			result_num = false
		if ficha1.get_c() == ficha2.get_c() and ficha1.get_c() != ficha3.get_c():
			# The number is wrong
			result_color = false
		if ficha1.get_s() == ficha2.get_s() and ficha1.get_s() != ficha3.get_s():
			result_shape = false
		if ficha1.get_f() == ficha2.get_f() and ficha1.get_f() != ficha3.get_f():
			result_fill = false
		
		if ficha2.get_n() == ficha3.get_n() and ficha2.get_n() != ficha1.get_n():
			result_num = false
		if ficha2.get_c() == ficha3.get_c() and ficha2.get_c() != ficha1.get_c():
			result_color = false
		if ficha2.get_s() == ficha3.get_s() and ficha2.get_s() != ficha1.get_s():
			result_shape = false
		if ficha2.get_f() == ficha3.get_f() and ficha2.get_f() != ficha1.get_f():
			result_fill = false
			
		if ficha1.get_n() == ficha3.get_n() and ficha2.get_n() != ficha1.get_n():
			result_num = false
		if ficha1.get_c() == ficha3.get_c() and ficha2.get_c() != ficha1.get_c():
			result_color = false
		if ficha1.get_s() == ficha3.get_s() and ficha2.get_s() != ficha1.get_s():
			result_shape = false
		if ficha1.get_f() == ficha3.get_f() and ficha2.get_f() != ficha1.get_f():
			result_fill = false
	
	result.append(result_num && result_color && result_shape && result_fill && result_no_ficha)
	result.append(result_num)
	result.append(result_color)
	result.append(result_shape)
	result.append(result_fill)
	
	return result
	
func update_tablero(last_selections):
	
############ NOTES #############
# This array "tablero" mantains the logical state of the board and has 12 slots for cards                            
# ┌───────────────────────────────────────┐     
# │   x   x   x   x   x   x   x   x   x   │     
# │ 0 x 1 x 2 x 3 x 4 x 5 x 6 x 7 x 8 x 9 │     
# └─┬───┬───┬─────────────────────────────┘                                                            
#   │   │   └────────────┐                                      
#   │   └─────────┐      │                                              
#   │    ┌───┐  ┌─┴─┐  ┌─┴─┐                                  
#   └────┤1 1│  │1 2│  │1 3│                  
#        └───┘  └───┘  └───┘                                                            
#        ┌───┐  ┌───┐  ┌───┐                                
#        │2 1│  │2 2│  │2 3│                  
#        └───┘  └───┘  └───┘                                                           
#   And each cards is selected from 1-1 to 4-3
	
	var color_apagado = Color(0,0,0,0.5)
	print(last_selections)
	## try to do animation
	##if last_selections:
		##do_animation(last_selections)
		
	if tablero[0] != null:	
		#await get_tree().create_timer(2.0).timeout
		get_node("tablero-cards/1-1/TextureRect").set_texture(tablero[0].get_texture())
		
	else:
		get_node("tablero-cards/1-1/TextureRect").modulate = color_apagado
		get_node("tablero-cards/1-1").disabled = true
	if tablero[1] != null:
		get_node("tablero-cards/1-2/TextureRect").set_texture(tablero[1].get_texture())
		
	else:
		get_node("tablero-cards/1-2/TextureRect").modulate = color_apagado
		get_node("tablero-cards/1-2").disabled = true
	if tablero[2] != null:
		get_node("tablero-cards/1-3/TextureRect").set_texture(tablero[2].get_texture())
		
	else:
		get_node("tablero-cards/1-3/TextureRect").modulate = color_apagado
		get_node("tablero-cards/1-3").disabled = true
	if tablero[3] != null:
		get_node("tablero-cards/2-1/TextureRect").set_texture(tablero[3].get_texture())
	else:
		get_node("tablero-cards/2-1/TextureRect").modulate = color_apagado
		get_node("tablero-cards/2-1").disabled = true
	if tablero[4]:
		get_node("tablero-cards/2-2/TextureRect").set_texture(tablero[4].get_texture())
	else:
		get_node("tablero-cards/2-2/TextureRect").modulate = color_apagado
		get_node("tablero-cards/2-2").disabled = true
	if tablero[5]:
		get_node("tablero-cards/2-3/TextureRect").set_texture(tablero[5].get_texture())
	else:
		get_node("tablero-cards/2-3/TextureRect").modulate = color_apagado
		get_node("tablero-cards/2-3").disabled = true
	if tablero[6]:
		get_node("tablero-cards/3-1/TextureRect").set_texture(tablero[6].get_texture())
	else:
		get_node("tablero-cards/3-1/TextureRect").modulate = color_apagado
		get_node("tablero-cards/3-1").disabled = true
	if tablero[7]:
		get_node("tablero-cards/3-2/TextureRect").set_texture(tablero[7].get_texture())
	else:
		get_node("tablero-cards/3-2/TextureRect").modulate = color_apagado
		get_node("tablero-cards/3-2").disabled = true
	if tablero[8]:
		get_node("tablero-cards/3-3/TextureRect").set_texture(tablero[8].get_texture())
	else:
		get_node("tablero-cards/3-3/TextureRect").modulate = color_apagado
		get_node("tablero-cards/3-3").disabled = true
	if tablero[9]:
		get_node("tablero-cards/4-1/TextureRect").set_texture(tablero[9].get_texture())
	else:
		get_node("tablero-cards/4-1/TextureRect").modulate = color_apagado
		get_node("tablero-cards/4-1").disabled = true
	if tablero[10]:
		get_node("tablero-cards/4-2/TextureRect").set_texture(tablero[10].get_texture())
	else:
		get_node("tablero-cards/4-2/TextureRect").modulate = color_apagado
		get_node("tablero-cards/4-2").disabled = true
	if tablero[11]:
		get_node("tablero-cards/4-3/TextureRect").set_texture(tablero[11].get_texture())
	else:
		get_node("tablero-cards/4-3/TextureRect").modulate = color_apagado
		get_node("tablero-cards/4-3").disabled = true
	#get_node("helper/tablero_label").set_text(str(fichas.size()))
	#update_cards_left_state()
	
	if (DEBUG):
		print(len(cards))
	var number_cards_deck = len(cards)
	var final_string =  "Cards:\n" + str(number_cards_deck)
	get_node("tablero-info/stats-container/stat-cards").set_text(final_string)
	var tmp_texture = load("res://img/mazo/set-deck-5-good.png")
	if number_cards_deck > 66:
		tmp_texture = load("res://img/mazo/set-deck-5-good.png")		
	elif number_cards_deck > 51:
		tmp_texture = load("res://img/mazo/set-deck-4-good.png")		
	elif number_cards_deck > 36:
		tmp_texture = load("res://img/mazo/set-deck-3-good.png")		
	elif number_cards_deck > 21:
		tmp_texture = load("res://img/mazo/set-deck-2-good.png")		
	# TODO: Adjust the images and the number of the decks
	elif number_cards_deck > 0:
		tmp_texture = load("res://img/mazo/set-deck-1-good.png")	
	get_node("tablero-info/set-deck").set_texture(tmp_texture)
	
	if number_cards_deck == 0:		
		get_node("tablero-info/set-deck").modulate = color_apagado
		
	
	######## Save the Hint somewhere so it doesnt change even if the user click several times
	# It will only change when the boards is updated
	# I dont think i need to call it again but whatever
	solution_finder_simple()
	# The Hint is saved on the variable 
	
func get_num_selected():
	return num_selected

func add_num_selected():
	num_selected = num_selected + 1
	
func add_selections(n):
	selections.append(n)
	add_num_selected()
	sound_select.play()
	# When the user select the third card then we check if the selection is valid
	if num_selected > 2:
		var resul = solver_params(tablero[selections[0]],tablero[selections[1]],tablero[selections[2]])
		if resul[0]:
			print("hay algo")
			var final_text = "Yes!\nThat's a SET\n+" + str(PUNTOS_ACIERTO) + " points"
			get_node("tablero-info/set-result").set_text(final_text)
			sound_select.stop()
			sound_right.play()
			update_points(PUNTOS_ACIERTO)
			correct_sets = correct_sets + 1
			# Lets check if there is enough cards from the stack to pop out
			if tablero.size() > 0 :
				tablero[selections[0]] = cards.pop_front()
			if tablero.size() > 0 :
				tablero[selections[1]] = cards.pop_front()
			if tablero.size() > 0 :
				tablero[selections[2]] = cards.pop_front()
			clear_solver_button_container()
			update_tablero(selections)

			# Again we check if there is a solution available after poping the cards
			var check_if_solution = solution_finder_simple()
			if not check_if_solution:
				print("Warning: there is no solution available")
				#TODO: We have to do something in case there is no solution available
			else:
				print("Ok: Solution available")
			
			var tween = get_tree().create_tween()
			var label_result: Label = get_node("tablero-info/set-result")
			tween.tween_property(label_result, "modulate", yellow_card, tween_timer/2)
			tween.tween_property(label_result, "modulate", Color.WHITE, tween_timer/2)
			
		else:
			print("nada")
			update_points(PUNTOS_ERROR)
			var final_text = "Sorry\nThat's not a SET\n" + str(PUNTOS_ERROR) + " points"
			get_node("tablero-info/set-result").set_text(final_text)
			sound_select.stop()
			sound_wrong.play()
			var tween = get_tree().create_tween()
			var label_result: Label = get_node("tablero-info/set-result")
			tween.tween_property(label_result, "modulate", red_red, tween_timer/2)
			tween.tween_property(label_result, "modulate", Color.WHITE, tween_timer/2)

		########### Inform user for the solution
		var res_num = get_node("tablero-info/res-num") 
		var res_color = get_node("tablero-info/res-color")
		var res_shape = get_node("tablero-info/res-shape")
		var res_fill = get_node("tablero-info/res-fill")
		if (resul[1]):
			var final_string = "Number\n\nSET"
			res_num.set_text(final_string)
		else:
			var final_string = "Number\n\nNO SET"
			res_num.set_text(final_string)
		if (resul[2]):
			var final_string = "Color\n\nSET"
			res_color.set_text(final_string)
		else:
			var final_string = "Color\n\nNO SET"
			res_color.set_text(final_string)
		if (resul[3]):
			var final_string = "Shape\n\nSET"
			res_shape.set_text(final_string)
		else:
			var final_string = "Shape\n\nNO SET"
			res_shape.set_text(final_string)
		if (resul[4]):
			var final_string = "Fill\n\nSET"
			res_fill.set_text(final_string)
		else:
			var final_string = "Fill\n\nNO SET"
			res_fill.set_text(final_string)
		
		num_selected = 0
		#update_points_button()
		
		selections.clear()
		clear_buttons()
		check_endgame()
		
func remove_selections(n):
	# TODO: look for the selection
	selections.append(n)
	add_num_selected()
	
		
func clear_buttons():
	#TODO: aqui tengo que arreglar el tema de que no me resetee el color de los botones
	# DONE? -> Fixed i think
	if tablero[0]:
		get_node("tablero-cards/1-1").clear_button()
	if tablero[1]:
		get_node("tablero-cards/1-2").clear_button()
	if tablero[2]:
		get_node("tablero-cards/1-3").clear_button()
	if tablero[3]:
		get_node("tablero-cards/2-1").clear_button()
	if tablero[4]:
		get_node("tablero-cards/2-2").clear_button()
	if tablero[5]:
		get_node("tablero-cards/2-3").clear_button()	
	if tablero[6]:
		get_node("tablero-cards/3-1").clear_button()
	if tablero[7]:
		get_node("tablero-cards/3-2").clear_button()
	if tablero[8]:
		get_node("tablero-cards/3-3").clear_button()
	if tablero[9]:
		get_node("tablero-cards/4-1").clear_button()
	if tablero[10]:
		get_node("tablero-cards/4-2").clear_button()
	if tablero[11]:
		get_node("tablero-cards/4-3").clear_button()

func _on_trampas_button_pressed() -> void:
	clear_solver_button_container()
	solution_finder()
	
func clear_solver_button_container():
	for i in get_node("trampas/trampas_container").get_children():
		i.queue_free()
	winners = []
	
func solution_finder():	
	var winners_label_text = ""
	var combs = [[0, 1, 2], [0, 1, 3], [0, 1, 4], [0, 1, 5], [0, 1, 6], [0, 1, 7], [0, 1, 8], [0, 1, 9], [0, 1, 10], [0, 1, 11], [0, 2, 3], [0, 2, 4], [0, 2, 5], [0, 2, 6], [0, 2, 7], [0, 2, 8], [0, 2, 9], [0, 2, 10], [0, 2, 11], [0, 3, 4], [0, 3, 5], [0, 3, 6], [0, 3, 7], [0, 3, 8], [0, 3, 9], [0, 3, 10], [0, 3, 11], [0, 4, 5], [0, 4, 6], [0, 4, 7], [0, 4, 8], [0, 4, 9], [0, 4, 10], [0, 4, 11], [0, 5, 6], [0, 5, 7], [0, 5, 8], [0, 5, 9], [0, 5, 10], [0, 5, 11], [0, 6, 7], [0, 6, 8], [0, 6, 9], [0, 6, 10], [0, 6, 11], [0, 7, 8], [0, 7, 9], [0, 7, 10], [0, 7, 11], [0, 8, 9], [0, 8, 10], [0, 8, 11], [0, 9, 10], [0, 9, 11], [0, 10, 11], [1, 2, 3], [1, 2, 4], [1, 2, 5], [1, 2, 6], [1, 2, 7], [1, 2, 8], [1, 2, 9], [1, 2, 10], [1, 2, 11], [1, 3, 4], [1, 3, 5], [1, 3, 6], [1, 3, 7], [1, 3, 8], [1, 3, 9], [1, 3, 10], [1, 3, 11], [1, 4, 5], [1, 4, 6], [1, 4, 7], [1, 4, 8], [1, 4, 9], [1, 4, 10], [1, 4, 11], [1, 5, 6], [1, 5, 7], [1, 5, 8], [1, 5, 9], [1, 5, 10], [1, 5, 11], [1, 6, 7], [1, 6, 8], [1, 6, 9], [1, 6, 10], [1, 6, 11], [1, 7, 8], [1, 7, 9], [1, 7, 10], [1, 7, 11], [1, 8, 9], [1, 8, 10], [1, 8, 11], [1, 9, 10], [1, 9, 11], [1, 10, 11], [2, 3, 4], [2, 3, 5], [2, 3, 6], [2, 3, 7], [2, 3, 8], [2, 3, 9], [2, 3, 10], [2, 3, 11], [2, 4, 5], [2, 4, 6], [2, 4, 7], [2, 4, 8], [2, 4, 9], [2, 4, 10], [2, 4, 11], [2, 5, 6], [2, 5, 7], [2, 5, 8], [2, 5, 9], [2, 5, 10], [2, 5, 11], [2, 6, 7], [2, 6, 8], [2, 6, 9], [2, 6, 10], [2, 6, 11], [2, 7, 8], [2, 7, 9], [2, 7, 10], [2, 7, 11], [2, 8, 9], [2, 8, 10], [2, 8, 11], [2, 9, 10], [2, 9, 11], [2, 10, 11], [3, 4, 5], [3, 4, 6], [3, 4, 7], [3, 4, 8], [3, 4, 9], [3, 4, 10], [3, 4, 11], [3, 5, 6], [3, 5, 7], [3, 5, 8], [3, 5, 9], [3, 5, 10], [3, 5, 11], [3, 6, 7], [3, 6, 8], [3, 6, 9], [3, 6, 10], [3, 6, 11], [3, 7, 8], [3, 7, 9], [3, 7, 10], [3, 7, 11], [3, 8, 9], [3, 8, 10], [3, 8, 11], [3, 9, 10], [3, 9, 11], [3, 10, 11], [4, 5, 6], [4, 5, 7], [4, 5, 8], [4, 5, 9], [4, 5, 10], [4, 5, 11], [4, 6, 7], [4, 6, 8], [4, 6, 9], [4, 6, 10], [4, 6, 11], [4, 7, 8], [4, 7, 9], [4, 7, 10], [4, 7, 11], [4, 8, 9], [4, 8, 10], [4, 8, 11], [4, 9, 10], [4, 9, 11], [4, 10, 11], [5, 6, 7], [5, 6, 8], [5, 6, 9], [5, 6, 10], [5, 6, 11], [5, 7, 8], [5, 7, 9], [5, 7, 10], [5, 7, 11], [5, 8, 9], [5, 8, 10], [5, 8, 11], [5, 9, 10], [5, 9, 11], [5, 10, 11], [6, 7, 8], [6, 7, 9], [6, 7, 10], [6, 7, 11], [6, 8, 9], [6, 8, 10], [6, 8, 11], [6, 9, 10], [6, 9, 11], [6, 10, 11], [7, 8, 9], [7, 8, 10], [7, 8, 11], [7, 9, 10], [7, 9, 11], [7, 10, 11], [8, 9, 10], [8, 9, 11], [8, 10, 11], [9, 10, 11]]
	for l in combs:
		var resul = solver_params(tablero[l[0]],tablero[l[1]],tablero[l[2]])
		if resul[0]:
			winners.append([l[0],l[1],l[2]])
			winners_label_text = winners_label_text + str(int(l[0])+1) + " " + str(int(l[1])+1) + " " + str(int(l[2])+1) + "\n"
			var button1 = Button.new()
			var style: StyleBoxFlat = StyleBoxFlat.new()
			style.set_bg_color(Color.BLUE)
			style.set_border_color(Color.RED)
			button1.add_theme_stylebox_override("normal", style)
			#button1.text = str(int(l[0])+1) + " " + str(int(l[1])+1) + " " + str(int(l[2])+1)			
			button1.connect("pressed",Callable(self,"_on_button_solver_pressed"))
			button1.connect("mouse_entered",Callable(self,"_on_button_solver_entered").bind(l[0],l[1],l[2]))
			button1.connect("button_down",Callable(self,"_on_button_solver_entered").bind(l[0],l[1],l[2]))
			button1.connect("mouse_exited",Callable(self,"_on_button_solver_exited").bind(l[0],l[1],l[2]))
			button1.connect("button_up",Callable(self,"_on_button_solver_exited").bind(l[0],l[1],l[2]))
			button1.set("first",1)
			button1.set_custom_minimum_size(Vector2(0,20))
			get_node("trampas/trampas_container").add_child(button1)
	print(winners)
	
func _on_button_solver_entered(pos1,pos2,pos3):
	if pos1 == 0 or pos2 == 0 or pos3 == 0:
		get_node("tablero-cards/1-1/TextureRect").modulate = Color(0.25,0.25,0.25)
	if pos1 == 1 or pos2 == 1 or pos3 == 1:
		get_node("tablero-cards/1-2/TextureRect").modulate = Color(0.25,0.25,0.25)
	if pos1 == 2 or pos2 == 2 or pos3 == 2:
		get_node("tablero-cards/1-3/TextureRect").modulate = Color(0.25,0.25,0.25)
	if pos1 == 3 or pos2 == 3 or pos3 == 3:
		get_node("tablero-cards/2-1/TextureRect").modulate = Color(0.25,0.25,0.25)
	if pos1 == 4 or pos2 == 4 or pos3 == 4:
		get_node("tablero-cards/2-2/TextureRect").modulate = Color(0.25,0.25,0.25)
	if pos1 == 5 or pos2 == 5 or pos3 == 5:
		get_node("tablero-cards/2-3/TextureRect").modulate = Color(0.25,0.25,0.25)
	if pos1 == 6 or pos2 == 6 or pos3 == 6:
		get_node("tablero-cards/3-1/TextureRect").modulate = Color(0.25,0.25,0.25)
	if pos1 == 7 or pos2 == 7 or pos3 == 7:
		get_node("tablero-cards/3-2/TextureRect").modulate = Color(0.25,0.25,0.25)
	if pos1 == 8 or pos2 == 8 or pos3 == 8:
		get_node("tablero-cards/3-3/TextureRect").modulate = Color(0.25,0.25,0.25)
	if pos1 == 9 or pos2 == 9 or pos3 == 9:
		get_node("tablero-cards/4-1/TextureRect").modulate = Color(0.25,0.25,0.25)
	if pos1 == 10 or pos2 == 10 or pos3 == 10:
		get_node("tablero-cards/4-2/TextureRect").modulate = Color(0.25,0.25,0.25)
	if pos1 == 11 or pos2 == 11 or pos3 == 11:
		get_node("tablero-cards/4-3/TextureRect").modulate = Color(0.25,0.25,0.25)
	
func _on_button_solver_exited(_pos1,_pos2,_pos3):
	get_node("tablero-cards/1-1/TextureRect").modulate = Color(1,1,1)
	get_node("tablero-cards/1-2/TextureRect").modulate = Color(1,1,1)
	get_node("tablero-cards/1-3/TextureRect").modulate = Color(1,1,1)
	get_node("tablero-cards/2-1/TextureRect").modulate = Color(1,1,1)
	get_node("tablero-cards/2-2/TextureRect").modulate = Color(1,1,1)
	get_node("tablero-cards/2-3/TextureRect").modulate = Color(1,1,1)
	get_node("tablero-cards/3-1/TextureRect").modulate = Color(1,1,1)
	get_node("tablero-cards/3-2/TextureRect").modulate = Color(1,1,1)
	get_node("tablero-cards/3-3/TextureRect").modulate = Color(1,1,1)
	get_node("tablero-cards/4-1/TextureRect").modulate = Color(1,1,1)
	get_node("tablero-cards/4-2/TextureRect").modulate = Color(1,1,1)
	get_node("tablero-cards/4-3/TextureRect").modulate = Color(1,1,1)

func remove_ins():
	global_pause = false
	pause_ends = Time.get_unix_time_from_system()
	pause_time = pause_time + pause_ends - pause_starts
	pause_ends = 0
	pause_starts = 0
	get_tree().get_root().remove_child(instance)
	
# Timer function to check how much time passed until the users end the panel
# TODO: A pausing feature for when game ends/ or when using the how to play button
# we track if only 1 second or 1 minute passed to update the text on those intervals

	
# Now the function itself, since we want to check how  much time passed
func update_timer():	
	
	var unix_time: float = Time.get_unix_time_from_system()
	
	var actual_time_passed: int = (unix_time - initial_unix_time) - (pause_time)	
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(actual_time_passed)
	# originally the format was $s as string but using $02d will autocomplete ceroes in the left
	var str_time := "%02d:%02d" % [dt.minute, dt.second]
	old_minutes = minutes
	old_seconds = seconds
	minutes = dt.minute
	seconds = dt.second
	#this If will make sure to only update every second or every minute
	if (((minutes != old_minutes) || (seconds != old_seconds)) && not global_pause ):
		#print(str)
		get_node("top-bar/game-time").set_text(str_time)
		time_played = str_time
		

# We will check if there is no set
func _on_nosetbtn_pressed() -> void:	
	if (solution_finder_simple()):		
		# TODO: Inform user that there is a solution
		var final_text = "You are wrong\nthere is a SET" + "\n" + str(PUNTOS_NO_SET_ERROR) + " points"
		var font_size = font_calculator(final_text)
		print(font_size)
		var node: Label = get_node("tablero-info/set-result")
		node.add_theme_font_size_override("temp", font_size)
		get_node("tablero-info/set-result").set_text(final_text)
		update_points(PUNTOS_NO_SET_ERROR)
	else:	
		# TODO: Update text of the cards indicating that there is indeed no solution available
		update_points(PUNTOS_NO_SET_CORRECTO)
		var final_text = "You are right!\nthrere is no SET" + "\n+" + str(PUNTOS_NO_SET_CORRECTO) + " points"
		get_node("tablero-info/set-result").set_text(final_text)
		# If the player checks that there are no solutions and there are no more cards to be dealt then the game is over
		if (len(cards) == 0):
			show_end_screen()
		
func font_calculator(texto):
	var long = len(texto)
	var font_size = 18
	if (long > 13):
		font_size = 12
	return font_size
	
func update_points(new_points):
	points += new_points
	var final_points = "Points:\n" + str(points)
	get_node("tablero-info/stats-container/res-fill").set_text(final_points)
	
func update_hints():
	var final_hints = "Hints:\n" + str(number_hints)
	get_node("tablero-info/stats-container/res-fill2").set_text(final_hints)


func _on_hintbtn_pressed() -> void:
	if (number_hints > 0):
		if hint == 0:
			hint_modulate("tablero-cards/1-1/TextureRect")
		elif hint == 1:
			hint_modulate("tablero-cards/1-2/TextureRect")
		elif hint == 2:
			hint_modulate("tablero-cards/1-3/TextureRect")
		elif hint == 3:
			hint_modulate("tablero-cards/2-1/TextureRect")
		elif hint == 4:
			hint_modulate("tablero-cards/2-2/TextureRect")
		elif hint == 5:
			hint_modulate("tablero-cards/2-3/TextureRect")
		elif hint == 6:
			hint_modulate("tablero-cards/3-1/TextureRect")
		elif hint == 7:
			hint_modulate("tablero-cards/3-2/TextureRect")
		elif hint == 8:
			hint_modulate("tablero-cards/3-3/TextureRect")
		elif  hint == 9:
			hint_modulate("tablero-cards/4-1/TextureRect")
		elif  hint == 10:
			hint_modulate("tablero-cards/4-2/TextureRect")
		elif  hint == 11:
			hint_modulate("tablero-cards/4-3/TextureRect")
		else:
			print("No solution")
		number_hints = number_hints - 1		
	else:
		print("No more hints")
	update_hints()
	
func hint_modulate(string_hint_button):
	var node = get_node(string_hint_button)	
	var tween = get_tree().create_tween()	
	tween.tween_property(node, "modulate",Color.YELLOW_GREEN, tween_timer*3)
	tween.tween_property(node, "modulate", Color.WHITE, tween_timer*3)
	
func do_animation(last_selection):
	for i in last_selection:
		if (i == 0):
			if tablero[0] != null:
				
				var old_deck_texture = get_node("tablero-info/set-deck").get_texture()
				get_node("tablero-info/set-deck").set_texture(tablero[0].get_texture())
				
				var from_node = get_node("tablero-info/set-deck")
				var origin = from_node.get_global_transform().get_origin()
				
				var go_to_node = get_node("tablero-cards/1-1")
				var destination = go_to_node.get_global_transform().get_origin()
				
				#var card_copy: TextureButton = get_node("tablero-cards/1-1").duplicate()
				#card_copy.set_position(destination)
				#get_node(".").add_child(card_copy)
				
				var deck_copy: TextureRect = get_node("tablero-info/set-deck").duplicate()
				deck_copy.set_position(origin)
				get_node(".").add_child(deck_copy)
				
				var tween = get_tree().create_tween()	
				tween.tween_property(deck_copy, "position", destination, tween_timer*3)
				tween.tween_callback(deck_copy.queue_free)
				#tween.tween_callback(card_copy.queue_free)

				#tween.tween_property(deck_copy, "modulate", Color.WHITE, tween_timer*3)
				#get_node("tablero-cards/1-1/TextureRect").set_texture(tablero[0].get_texture())
				



func _on_instructionsbtn_toggled(toggled_on: bool) -> void:
	if (toggled_on):
		global_pause = true
		pause_starts = 0
		pause_ends = 0	
		pause_starts = Time.get_unix_time_from_system()
		instance = ins_scene.instantiate()
		get_tree().get_root().add_child(instance)
	else:
		global_pause = false
		pause_ends = Time.get_unix_time_from_system()
		pause_time = pause_time + pause_ends - pause_starts
		pause_ends = 0
		pause_starts = 0
		get_tree().get_root().remove_child(instance)
		
func deal_new_board():
	tablero.clear()
	for i in range(0,12):
		tablero.append(cards.pop_back())
	update_tablero(null)

func _on_tramps_deal_pressed() -> void:
	deal_new_board()
	
func show_end_screen():
	global_pause = true
	pause_starts = 0
	pause_ends = 0	
	pause_starts = Time.get_unix_time_from_system()
	instance = end_screen.instantiate()
	get_tree().get_root().add_child(instance)
	
func check_endgame():
	# We will check if there are cards in the deck
	if (len(cards) == 0):
		# Now we have to ckeck if there are cards in tablero
		if (len(tablero) == 0):
			show_end_screen()
		
func reset_board():
	cards.clear()
	selections.clear()
	init_cards()
	tablero.clear()
	var tablero_valido = false
	while (not tablero_valido):
	# We fill the initial board with the fichas
		for i in range(0,12):
			tablero.append(cards.pop_back())
		# Lets check if there is at least 1 solution available
		tablero_valido = solution_finder_simple()
		# If there is no slution available we reset the state of the game completely
		if (not tablero_valido):
			## This was clearing the cheat solver helper button
			## clear_solver_button_container()
			cards.clear()
			init_cards()
			tablero.clear()
	# Now we update the cards themselves on the board to reflect the cards on tablero	
	# clear_solver_button_container()
	var check_if_solution = solution_finder_simple()
	if not check_if_solution:
		print("Warning: there is no solution available")
	else:
		print("Ok: Solution available")
	
	points = 0
	update_points(0)
	time_played = 0
	hints_used = 0
	failed_sets = 0
	correct_sets = 0
	num_selected = 0
	number_hints = MAX_NUMBER_HINTS
	update_timer()
	update_hints()
	clear_buttons()	
	num_selected = 0
	enable_all_buttons()
	update_tablero(selections)
	global_pause = false
	get_node("tablero-info/set-deck").modulate = Color(1,1,1)
	get_node("tablero-info/set-result").text = ""
	### timer resets
	minutes = 0
	old_minutes = 0
	seconds = 0
	old_seconds = 0

	# This will get the starting unix time in the format 232322323223
	initial_unix_time = Time.get_unix_time_from_system()
	initial_unix_time_int = initial_unix_time

	pause_starts = 0
	pause_ends = 0
	pause_time = 0
	
	######### 

func _on_reset_button_pressed() -> void:
	reset_board()
	
func get_puntos():
	return points

func enable_all_buttons():	
	#TODO: aqui tengo que arreglar el tema de que no me resetee el color de los botones
	# DONE? -> Fixed i think
	if tablero[0]:
		get_node("tablero-cards/1-1").disabled = false
	if tablero[1]:
		get_node("tablero-cards/1-2").disabled = false
	if tablero[2]:
		get_node("tablero-cards/1-3").disabled = false
	if tablero[3]:
		get_node("tablero-cards/2-1").disabled = false
	if tablero[4]:
		get_node("tablero-cards/2-2").disabled = false
	if tablero[5]:
		get_node("tablero-cards/2-3").disabled = false
	if tablero[6]:
		get_node("tablero-cards/3-1").disabled = false
	if tablero[7]:
		get_node("tablero-cards/3-2").disabled = false
	if tablero[8]:
		get_node("tablero-cards/3-3").disabled = false
	if tablero[9]:
		get_node("tablero-cards/4-1").disabled = false
	if tablero[10]:
		get_node("tablero-cards/4-2").disabled = false
	if tablero[11]:
		get_node("tablero-cards/4-3").disabled = false
