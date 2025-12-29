extends Node2D

var button_type = null

func _on_start_pressed() -> void:
	button_type = "start"
	$fade_transition.show()
	$fade_transition/fade_timer.start()
	$fade_transition/AnimationPlayer.play("fade_out") 

func _on_credits_pressed() -> void:
	button_type = "credits"
	get_tree().change_scene_to_file("res://credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_fade_timer_timeout() -> void:
	if button_type == "start" :
		get_tree().change_scene_to_file("res://Scenes/Overworld Scene.tscn")
