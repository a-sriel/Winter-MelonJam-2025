extends Node3D

var cave_path : String = "res://Scenes/Cave Scene.tscn"

func _ready() -> void:
	$CinematicCamera.make_current()
	$Player.hide()
	$AnimationPlayer.play("IntroCutscene")
	$"Cake Trail".hide()
	
	var anim1 : Animation = $AnimModels/ProtagFerret_Idle/ferret/AnimationPlayer.get_animation("Idle")
	anim1.loop_mode = (Animation.LOOP_LINEAR)
	$AnimModels/ProtagFerret_Idle/ferret/AnimationPlayer.play("Idle")
	
	var anim2 : Animation = $AnimModels/BanditFerret_Walk/Bandito/ferret_Bandito/AnimationPlayer.get_animation("Walk")
	anim2.loop_mode = (Animation.LOOP_LINEAR)
	$AnimModels/BanditFerret_Walk/Bandito/ferret_Bandito/AnimationPlayer.play("Walk")
	
	var anim3 : Animation = $AnimModels/BanditFerret_Stealing/Bandito/ferret_Bandito/AnimationPlayer.get_animation("Celebrate")
	anim3.loop_mode = (Animation.LOOP_LINEAR)
	$AnimModels/BanditFerret_Stealing/Bandito/ferret_Bandito/AnimationPlayer.play("Celebrate")
	
	var anim4 : Animation = $AnimModels/ProtagFerret_Walk/ferret/AnimationPlayer.get_animation("Walk")
	anim4.loop_mode = (Animation.LOOP_LINEAR)
	$AnimModels/ProtagFerret_Walk/ferret/AnimationPlayer.play("Walk")
	
	var anim5 : Animation = $AnimModels/ProtagFerret_Surprise/ferret/AnimationPlayer.get_animation("Celebrate")
	anim5.loop_mode = (Animation.LOOP_LINEAR)
	$AnimModels/ProtagFerret_Surprise/ferret/AnimationPlayer.play("Celebrate")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$Player.show()
	$Player/Head/Camera3D.make_current()
	
	$AnimModels/ProtagFerret_Idle.hide()
	$AnimModels/ProtagFerret_Walk.hide()
	$AnimModels/ProtagFerret_Surprise.hide()
	$AnimModels/BanditFerret_Walk.hide()
	$AnimModels/BanditFerret_Stealing.hide()
	
	$"Cake Trail".show()
	
func _on_enterance_trigger_body_entered(body: CharacterBody3D) -> void:
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
