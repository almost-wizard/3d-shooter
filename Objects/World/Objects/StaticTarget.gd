extends StaticBody3D


@export var Health = 1


func HitSuccessful(_damage: int, _direction: Vector3 = Vector3.ZERO, _position: Vector3 = Vector3.ZERO) -> void:
	Health -= _damage	
	if Health <= 0:
		queue_free()
