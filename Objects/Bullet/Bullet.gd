extends RigidBody3D

var Damage: int = 0

func _on_body_entered(body: Node):
	if body.is_in_group("Target") and body.has_method("HitSuccessful"):
		body.HitSuccessful(Damage)
	queue_free()


func Launch(direction: Vector3, damage: int, velocity: int) -> void:
	Damage = damage
	set_linear_velocity(direction * velocity)


func _on_timer_timeout():
	queue_free()
