extends Resource

class_name WeaponResource


@export var WeaponName: String

@export var ToggleAnimation: String
@export var ShootAnimation: String
@export var ReloadAnimation: String

@export var CurrentAmmo: int
@export var ReserveAmmo: int
@export var MagazineAmmo: int
@export var MaxAmmo: int

@export var AutoFire: bool
@export var FireRange: int
@export var Damage: int

@export_flags("Hitscan", "Projectile") var Type
@export var ProjectileInstance: PackedScene
@export var ProjectileVelocity: int
