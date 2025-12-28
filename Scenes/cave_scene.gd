extends Node3D

var arena_path : String = "res://Scenes/Arena Scene.tscn"

func _on_enterance_trigger_body_entered(body: Node3D) -> void:
	if body is CakeMaster:
		get_tree().change_scene_to_file(arena_path)
