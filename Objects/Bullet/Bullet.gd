extends RigidBody3D

var Damage: int = 0
var HitIndicator = preload("res://Objects/Bullet/HitIndicator.tscn")

func _on_body_entered(body: Node):
	_instantiate_hit_indicator(position)
	if body.is_in_group("Target") and body.has_method("HitSuccessful"):
		body.HitSuccessful(Damage)
	queue_free()


func Launch(direction: Vector3, damage: int, velocity: int) -> void:
	Damage = damage
	set_linear_velocity(direction * velocity)


func _on_timer_timeout():
	queue_free()


func _instantiate_hit_indicator(_position: Vector3) -> void:
	var hit_indicator = HitIndicator.instantiate()
	var world = get_tree().get_root().get_child(0)
	world.add_child(hit_indicator)
	hit_indicator.global_translate(_position)
