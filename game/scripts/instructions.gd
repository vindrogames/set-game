extends Node2D

var whoami
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_ins_close_button_pressed() -> void:
	#get_tree().root.remove_child(simultaneous_scene)
	var mainNode = get_node("/root/main")
	mainNode.remove_ins()
