# Modified version of Brackey's Proto Character Controller
# https://github.com/Brackeys/brackeys-proto-controller/blob/main/proto_controller/proto_controller.gd

extends CharacterBody3D
class_name CakeMaster

@export var LOOK_SPEED : float = .0015
@export var BASE_SPEED : float = 7
@export var SPRINT_SPEED : float = 10
@export var JUMP_SPEED : float = 4.5
@export var THROW_FORCE: float = 10

@onready var head: Node3D = %Head
@onready var cam: Camera3D = head.get_child(0)
@onready var ferret: Node3D = %ferret
@onready var anim: AnimationPlayer = %ferret.get_child(1)
@onready var pie: RigidBody3D = %Pie

var move_speed : float = 0
var mouse_captured : bool = false
var look_rotation : Vector2

func _ready() -> void:
	capture_mouse()

#TODO: Optimize this
func _process(_delta: float) -> void:
	if self.get_real_velocity():
		anim.play("Armature|Walk")
	else:
		anim.play("Armature|_TPose")

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative) # passes mouse position relative to the previous position (position at the last frame)
	
	if Input.is_action_just_pressed("action_fire"):
		throw_pie()

func _physics_process(delta: float) -> void:
	
	# Character movement
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_SPEED
	
	if Input.is_action_pressed("sprint"):
		move_speed = SPRINT_SPEED
	else:
		move_speed = BASE_SPEED
	
	# Player movement
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var move_dir := (self.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if move_dir:
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
	
	self.move_and_slide()

## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * LOOK_SPEED
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * LOOK_SPEED
	
	self.transform.basis = Basis()
	self.rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func throw_pie() -> void:
	var clone : RigidBody3D = pie.duplicate()
	get_tree().current_scene.add_child(clone)
	clone.global_position = pie.global_position
	clone.set_collision_mask_value(1, true) # pie will scan for walls
	clone.set_collision_mask_value(2, true) # pie will scan for enemies
	
	# Calc throw direction
	var forward_dir := -cam.get_global_transform().basis.z
	clone.apply_central_impulse(Vector3.ONE * THROW_FORCE * forward_dir)
