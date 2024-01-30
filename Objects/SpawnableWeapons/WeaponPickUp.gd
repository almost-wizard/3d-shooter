extends RigidBody3D


@export var WeaponName: String
@export var CurrentAmmo: int
@export var ReserveAmmo: int

var ReadyToPickUp: bool = false


func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	ReadyToPickUp = true
