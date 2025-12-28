extends RigidBody3D
class_name Pie

@onready var death_timer: Timer = $"Death Timer"

func throw(dir:Vector3, force:float) -> void:
	var clone : RigidBody3D = self.duplicate()
	get_tree().current_scene.add_child(clone)
	
	clone.global_position = self.global_position
	clone.set_collision_mask_value(1, true) # pie will scan for walls
	clone.set_collision_mask_value(2, true) # pie will scan for enemies
	clone.contact_monitor = true
	clone.max_contacts_reported = 1
	
	clone.freeze = false
	var random_torque = Vector3(randf_range(-.1, .1), randf_range(-.1, .1), randf_range(-.1, .1))
	print(random_torque)
	clone.apply_central_impulse(Vector3.ONE * force * dir)
	clone.apply_torque_impulse(random_torque)
	clone.death_timer.start()

# Freeze on any collision
func _on_body_entered(_body: Node) -> void:
	self.freeze = true
	set_deferred("set_contact_monitor", false)
	self.max_contacts_reported = 0

# Kill thrown pies but now pie in hand
func _on_death_timer_timeout() -> void:
	self.queue_free()
