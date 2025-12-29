extends RigidBody3D

@export var amount : int = 25


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CakeMaster:
		body.refill_pies(amount)
		amount *= .5
		self.scale *= .7
		
		if amount <= 0:
			self.queue_free()
