extends Node3D

var arena_path : String = "res://Scenes/Arena Scene.tscn"


func _on_enterance_trigger_body_entered(body: Node3D) -> void:
	if body is CakeMaster:
		get_tree().change_scene_to_file(arena_path)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().paused = true
		$Pause_Menu.show()
	
func _on_resume_pressed() -> void:
	$Pause_Menu.hide()
	get_tree().paused = false
	$Player.capture_mouse()
	
func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
func _on_close_pressed() -> void:
	get_tree().quit()
