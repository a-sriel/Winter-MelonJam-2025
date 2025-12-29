extends Node3D

var cave_path : String = "res://Scenes/Cave Scene.tscn"

func _ready() -> void:
	$CinematicCamera.make_current()
	$Player.hide()
	
	var anim1 : Animation = $ProtagFerret_Idle/ferret/AnimationPlayer.get_animation("Idle")
	anim1.loop_mode = (Animation.LOOP_LINEAR)
	$ProtagFerret_Idle/ferret/AnimationPlayer.play("Idle")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$Player/Head/Camera3D.make_current()

func _on_enterance_trigger_body_entered(body: Node3D) -> void:
	if body is CakeMaster:
		get_tree().change_scene_to_file(cave_path)

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
