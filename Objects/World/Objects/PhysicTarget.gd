extends RigidBody3D

@export var Health = 10


func HitSuccessful(_damage: int, _direction: Vector3 = Vector3.ZERO, _position: Vector3 = Vector3.ZERO) -> void:
	Health -= _damage
	
	if Health <= 0:
		queue_free()
	
	var hit_position = _position - get_global_transform().origin
	
	if _direction != Vector3.ZERO:
		apply_impulse(_damage * _direction, hit_position)
