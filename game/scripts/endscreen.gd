extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var main = get_tree().get_root().get_node("main")
	var puntos = main.points
	var time = main.time_played
	var hints_used = main.hints_used
	var failed_sets = main.failed_sets
	var correct_sets = main.correct_sets
	
	var text_label: RichTextLabel= get_node("RichTextLabel")
	var temp_text = '''
[center][font_size=21][color=fcdc4c]You made it![/color][/font_size][/center]

[font_size=18]You have completed the entire deck, quite an astonishing feet! Here are your stats for this game:[/font_size]
'''
	temp_text += "\nTotal points: " + str(puntos) + "\n"
	temp_text += "[color=fcdc4c]Correct Sets: " + str(correct_sets) + "[/color]\n"
	temp_text += "[color=d43815]Incorrect Sets: " + str(failed_sets) + "[/color]\n"
	# temp_text += "[color=fcdc4c]Correct No-Sets: " + str() + "[/color]\n"
	# temp_text += "[color=d43815]Incorrect No-Sets: " + str() + "[/color]\n"
	temp_text += "Hints Used: " + str(hints_used) + "\n"
	temp_text += "Time: " + str(time) + "\n"
			
	text_label.text = temp_text
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var main = get_tree().get_root().get_node("main")
	main.reset_board()
	var instance = get_node(".")
	get_tree().get_root().remove_child(instance)
