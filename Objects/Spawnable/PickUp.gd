extends RigidBody3D


@export var WeaponName: String
@export var CurrentAmmo: int
@export var ReserveAmmo: int

@export_enum("Weapon", "Ammo clip") var Type = "Weapon"

var ReadyToPickUp: bool = false


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	ReadyToPickUp = true
