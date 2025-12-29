extends CharacterBody3D
class_name Bandito

@export var face_health : int = 10
@export var mask_health : int = 5
@export var WALK_SPEED : float = 2
@export var SHOVE_FORCE : float = 25

@onready var skeleton : Skeleton3D = $bandito
@onready var head_bone_id : int = skeleton.find_bone("Head")
@onready var mask_bone_start_id : int = skeleton.find_bone("Head.001")
@onready var mask_bone_end_id : int = skeleton.find_bone("Head.001_end")

@onready var anim : AnimationPlayer = $bandito/AnimationPlayer
@onready var mask_hurtbox: RigidBody3D = %"Mask Hurtbox"
@onready var head_hurtbox: StaticBody3D = %"Head Hurtbox"
@onready var mask_mesh: MeshInstance3D = $bandito/Armature/Skeleton3D/Mask
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var celebrate_zone: Area3D = %"Celebrate Zone"
@onready var chase_zone: Area3D = %"Chase Zone"


var mask_fallen : bool = false
var player_inside_celebration : bool = false


func _ready() -> void:
	anim.play("Armature|Walk")
	head_hurtbox.process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	if not mask_fallen:
		var mask_start_pos : Vector3 = skeleton.get_bone_global_pose(mask_bone_start_id).origin
		var mask_end_pos : Vector3 = skeleton.get_bone_global_pose(mask_bone_end_id).origin
		mask_hurtbox.global_position = skeleton.to_global((mask_start_pos + mask_end_pos)/2)
	head_hurtbox.global_position = skeleton.to_global(skeleton.get_bone_global_pose(head_bone_id).origin)
	
	if anim.current_animation == "Armature|Celebrate":
		return
	
	if self.get_real_velocity():
		anim.play("Armature|Walk")
	else:
		anim.play("Idle")

func _physics_process(_delta: float) -> void:
	# Navigation
	if navigation_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		move_and_slide()
		return
	
	var destination := navigation_agent.get_next_path_position()
	var local_destination := destination - self.global_position
	var direction = local_destination.normalized()
	
	if self.global_position != destination:
		self.look_at(destination)
	
	self.velocity = direction * WALK_SPEED
	move_and_slide()

func take_damage() -> void:
	if mask_fallen:
		face_health -= 1
		var tween = get_tree().create_tween()
		tween.tween_property($bandito/Armature/Skeleton3D/Character, "transparency", 1.0, 1.0)
		tween.tween_callback(self.queue_free)
		
	
	mask_health -= 1
	if mask_health <= 0:
		head_hurtbox.process_mode = Node.PROCESS_MODE_INHERIT
		
		# clone the mask for later
		var mesh_copy : MeshInstance3D = mask_mesh.duplicate()
		mask_hurtbox.add_child(mesh_copy)
		
		# clean up original
		mask_mesh.visible = false
		
		# tuning
		mesh_copy.scale *= 8
		mesh_copy.position.y += .01
		mask_hurtbox.mass = 8
		mask_hurtbox.get_child(0).scale *= .6
		mask_hurtbox.global_position = head_hurtbox.global_position
		
		# drop the mask copy
		mask_hurtbox.reparent(get_tree().current_scene)
		mask_hurtbox.freeze = false
		
		mask_fallen = true


func _on_chase_zone_body_entered(body: Node3D) -> void:
	if body is CakeMaster:
		navigation_agent.set_target_position(body.global_position)
		
		await get_tree().create_timer(1).timeout
		
		if chase_zone.overlaps_body(body):
			_on_chase_zone_body_entered(body)

func _on_celebrate_zone_body_entered(body: Node3D) -> void:
	if body is CakeMaster and not anim.current_animation == "Armature|Celebrate":
		player_inside_celebration = true
		anim.play("Armature|Celebrate")
		
		var shove_dir : Vector3 = (body.global_position - self.global_position).normalized()
		body.take_shove_from(shove_dir, SHOVE_FORCE)
		
		await get_tree().create_timer(1.05).timeout
		
		if celebrate_zone.overlaps_body(body):
			_on_celebrate_zone_body_entered(body)


func _on_damage_phase_timer_timeout() -> void:
	pass # Replace with function body.
