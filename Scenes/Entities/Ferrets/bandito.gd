extends CharacterBody3D
class_name Bandito

signal boss_took_damage()
signal spawn_the_cake(position:Vector3)

@export var face_health : int = 15
@export var MAX_MASK_HEALTH : int = 5
@export var WALK_SPEED : float = 2
@export var SHOVE_FORCE : float = 35
@export var cake_visible : bool = false

@onready var skeleton : Skeleton3D = $ferret_Bandito/Armature/Skeleton3D
@onready var head_bone_id : int = skeleton.find_bone("Head")
@onready var mask_bone_start_id : int = skeleton.find_bone("Head.001")
@onready var mask_bone_end_id : int = skeleton.find_bone("Head.001_end")

@onready var anim : AnimationPlayer = $ferret_Bandito/AnimationPlayer
@onready var mask_hurtbox: RigidBody3D = %"Mask Hurtbox"
@onready var head_hurtbox: StaticBody3D = %"Head Hurtbox"
@onready var mask_mesh: MeshInstance3D = $ferret_Bandito/Armature/Skeleton3D/Mask
@onready var navigation_agent: NavigationAgent3D = %NavigationAgent3D
@onready var celebrate_zone: Area3D = %"Celebrate Zone"
@onready var chase_zone: Area3D = %"Chase Zone"
@onready var damage_phase_timer: Timer = $"Damage Phase Timer"
@onready var cake: Node3D = $Cake


var mask_fallen : bool = false
var player_inside_celebration : bool = false
var mask_health : int = MAX_MASK_HEALTH

func _ready() -> void:
	anim.play("Idle")
	head_hurtbox.process_mode = Node.PROCESS_MODE_DISABLED
	cake.visible = cake_visible

func _process(_delta: float) -> void:
	if not mask_fallen:
		var mask_start_pos : Vector3 = skeleton.get_bone_global_pose(mask_bone_start_id).origin
		var mask_end_pos : Vector3 = skeleton.get_bone_global_pose(mask_bone_end_id).origin
		mask_hurtbox.global_position = skeleton.to_global((mask_start_pos + mask_end_pos)/2)
	head_hurtbox.global_position = skeleton.to_global(skeleton.get_bone_global_pose(head_bone_id).origin)
	
	if anim.current_animation == "Celebrate":
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
	destination.y = 0
	var local_destination := destination - self.global_position
	var direction = local_destination.normalized()
	
	self.velocity = direction * WALK_SPEED
	move_and_slide()
	
	if self.global_position != destination:
		self.look_at(destination)

func take_damage() -> void:
	if mask_fallen:
		face_health -= 1
		boss_took_damage.emit()
		
		if face_health <= 0:
			setup_dying()
		return
	
	mask_health -= 1
	if mask_health <= 0:
		mask_falls()


func _on_chase_zone_body_entered(body: Node3D) -> void:
	if body is CakeMaster:
		navigation_agent.set_target_position(body.global_position)
		
		await get_tree().create_timer(1).timeout
		
		if chase_zone.overlaps_body(body):
			_on_chase_zone_body_entered(body)

func _on_celebrate_zone_body_entered(body: Node3D) -> void:
	if body is CakeMaster and not anim.current_animation == "Celebrate":
		player_inside_celebration = true
		anim.play("Celebrate")
		
		var shove_dir : Vector3 = (body.global_position - self.global_position).normalized()
		body.take_shove_from(shove_dir, SHOVE_FORCE)
		
		await get_tree().create_timer(1.05).timeout
		
		if celebrate_zone.overlaps_body(body):
			_on_celebrate_zone_body_entered(body)

func setup_dying() -> void:
	# Stop moving
	set_physics_process(false)
	set_process(false)
	anim.play("Idle")
	damage_phase_timer.stop()
	
	# Fade away
	var tween = get_tree().create_tween()
	tween.tween_property($ferret_Bandito/Armature/Skeleton3D/Character, "transparency", 1.0, 5.0)
	tween.tween_callback(drop_cake_then_die)

func mask_falls() -> void:
	print("starting damage timer")
	damage_phase_timer.start()
	
	head_hurtbox.process_mode = Node.PROCESS_MODE_INHERIT
	
	# clone the mask and hurtbox
	var mesh_copy : MeshInstance3D = mask_mesh.duplicate()
	var hurtbox_copy : RigidBody3D = mask_hurtbox.duplicate()
	mask_hurtbox.add_child(hurtbox_copy)
	hurtbox_copy.add_child(mesh_copy)
	
	# clean up original
	mask_mesh.visible = false
	mask_hurtbox.process_mode = Node.PROCESS_MODE_DISABLED
	
	# tuning
	mesh_copy.scale *= 8
	mesh_copy.position.y += .01
	hurtbox_copy.mass = 8
	hurtbox_copy.get_child(0).scale *= .6
	hurtbox_copy.global_position = head_hurtbox.global_position
	
	# drop the mask copy
	hurtbox_copy.reparent(get_tree().current_scene)
	hurtbox_copy.freeze = false
	
	mask_fallen = true

func mask_returns() -> void:
	# Turn on mask again
	head_hurtbox.process_mode = Node.PROCESS_MODE_DISABLED
	mask_hurtbox.process_mode = Node.PROCESS_MODE_INHERIT
	mask_mesh.visible = true
	mask_fallen = false
	mask_health = MAX_MASK_HEALTH
	
	# Clean mask
	for child in head_hurtbox.get_children():
		if child is not CollisionShape3D:
			child.queue_free()
	for child in mask_hurtbox.get_children():
		if child is not CollisionShape3D:
			child.queue_free()

func _on_damage_phase_timer_timeout() -> void:
	print("returning mask")
	mask_returns()

func drop_cake_then_die() -> void:
	spawn_the_cake.emit(self.global_position)
	self.queue_free()
