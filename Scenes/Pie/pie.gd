extends RigidBody3D
class_name Pie

@onready var death_timer: Timer = $"Death Timer"
@onready var cooldown_timer: Timer = %Cooldown

var can_throw : bool = true


func throw(dir:Vector3, force:float) -> void:
	if not can_throw:
		return
	
	var clone : RigidBody3D = self.duplicate()
	get_tree().current_scene.add_child(clone)
	
	# Collisions
	clone.global_position = self.global_position
	clone.set_collision_mask_value(1, true) # pie will scan for walls
	clone.set_collision_mask_value(2, true) # pie will scan for enemies
	clone.contact_monitor = true
	clone.max_contacts_reported = 1
	
	# Movement
	clone.freeze = false
	var random_torque = Vector3(randf_range(-.1, .1), randf_range(-.1, .1), randf_range(-.1, .1))
	clone.apply_central_impulse(Vector3.ONE * force * dir)
	clone.apply_torque_impulse(random_torque)
	
	clone.death_timer.start()
	self.cooldown_timer.start()

# Freeze on any collision
func _on_body_entered(_body: Node) -> void:
	self.freeze = true
	set_deferred("set_contact_monitor", false)
	self.max_contacts_reported = 0

func _on_cooldown_timeout() -> void:
	can_throw = true

# Kill thrown pies but now pie in hand
func _on_death_timer_timeout() -> void:
	self.queue_free()
