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
YOU WIN
gfdgfdsgds
gfdsgfdsgfds
gfsdgdsgfsdgdsgds
'''
	temp_text += "Points: " + str(puntos) + "\n"
	temp_text += "Time: " + str(time) + "\n"
	temp_text += "Hints Used: " + str(hints_used) + "\n"
	temp_text += "Correct Sets: " + str(correct_sets) + "\n"
	temp_text += "Failed Sets: " + str(failed_sets) + "\n"	
	temp_text += "[center][img=121]res://img/cards/2-R-S-L.png[/img]    [img=121]res://img/cards/2-R-R-B.png[/img]    [img=121]res://img/cards/2-R-D-B.png[/img]
[font_size=10]DIFFERENT shape, SAME color, DIFFERENT fill and SAME number[/font_size][/center]" + "\n"	
	text_label.text = temp_text
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var main = get_tree().get_root().get_node("main")
	main.reset_board()
	var instance = get_node(".")
	get_tree().get_root().remove_child(instance)
