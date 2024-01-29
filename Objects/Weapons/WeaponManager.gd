extends Node3D


signal weapon_change
signal update_ammo
signal update_weapon_stack

@export var WeaponResources: Array[WeaponResource]
@export var StartWeapons: Array[String]

var CurrentWeapon: WeaponResource = null
var WeaponsStack = []
var WeaponIndicator: int = 0
var NextWeapon: String
var WeaponsList: Dictionary = {}
var CollisionExclude: Array = []

@onready var Animator: AnimationPlayer = $Rig/AnimationPlayer
@onready var BulletPoint: Marker3D = $Rig/BulletPoint

var HitIndicator = preload("res://Objects/Bullet/HitIndicator.tscn")

enum {NULL, HITSCAN, PROJECTILE}


func _ready() -> void:
	for weapon in WeaponResources:
		WeaponsList[weapon.WeaponName] = weapon
	
	for i in StartWeapons:
		WeaponsStack.push_back(i)
	
	CurrentWeapon = WeaponsList[WeaponsStack[0]]
	emit_signal("update_weapon_stack", WeaponsStack)
	Enter()


func _process(delta):	
	if IsPlayerShooting():
		Shoot()


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("weapon_up"):
		WeaponIndicator = min(WeaponIndicator + 1, WeaponsStack.size() - 1)
		Exit(WeaponsStack[WeaponIndicator])
	
	if Input.is_action_pressed("weapon_down"):
		WeaponIndicator = max(0, WeaponIndicator - 1)
		Exit(WeaponsStack[WeaponIndicator])

	if Input.is_action_pressed("weapon_reload"):
		Reload()


func Enter() -> void:
	Animator.queue(CurrentWeapon.ToggleAnimation)
	emit_signal("weapon_change", CurrentWeapon.WeaponName)
	emit_signal("update_ammo", [CurrentWeapon.CurrentAmmo, CurrentWeapon.ReserveAmmo])


func Exit(_next_weapon: String) -> void:
	if _next_weapon != CurrentWeapon.WeaponName:
		if Animator.get_current_animation() != CurrentWeapon.ToggleAnimation:
			Animator.play_backwards(CurrentWeapon.ToggleAnimation)
			NextWeapon = _next_weapon


func ChangeWeapon(_new_weapon: String) -> void:
	CurrentWeapon = WeaponsList[_new_weapon]
	NextWeapon = ""
	Enter()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == CurrentWeapon.ToggleAnimation and NextWeapon:
		ChangeWeapon(NextWeapon)


func IsPlayerShooting() -> bool:
	if CurrentWeapon.AutoFire:
		return Input.is_action_pressed("shoot")
	else:
		return Input.is_action_just_pressed("shoot")


func Reload() -> void:
	if CurrentWeapon.CurrentAmmo == CurrentWeapon.MagazineAmmo:
		return
	if !Animator.is_playing():
		if CurrentWeapon.ReserveAmmo != 0:
			Animator.play(CurrentWeapon.ReloadAnimation)
			var reload_amount = min(
				CurrentWeapon.MagazineAmmo - CurrentWeapon.CurrentAmmo,
				CurrentWeapon.MagazineAmmo,
				CurrentWeapon.ReserveAmmo,
			)
			CurrentWeapon.CurrentAmmo += reload_amount
			CurrentWeapon.ReserveAmmo -= reload_amount
			
			emit_signal("update_ammo", [CurrentWeapon.CurrentAmmo, CurrentWeapon.ReserveAmmo])


func Shoot() -> void:
	if CurrentWeapon.CurrentAmmo != 0:
		if !Animator.is_playing():
			Animator.play(CurrentWeapon.ShootAnimation)
			CurrentWeapon.CurrentAmmo -= 1
			emit_signal("update_ammo", [CurrentWeapon.CurrentAmmo, CurrentWeapon.ReserveAmmo])
			
			var camera_collision = _get_camera_collision()
			match CurrentWeapon.Type:
				NULL:
					print("Weapon type not specified")
				HITSCAN:
					HitscanCollision(camera_collision)
				PROJECTILE:
					LaunchProjectile(camera_collision)
	else:
		Reload()


func LaunchProjectile(collision_point: Vector3) -> void:
	var bullet_transform = BulletPoint.get_global_transform().origin
	var bullet_direction = (collision_point - bullet_transform).normalized()
	
	var Projectile = CurrentWeapon.ProjectileInstance.instantiate()
	
	var ProjectileRID = Projectile.get_rid()
	CollisionExclude.push_front(ProjectileRID)
	Projectile.tree_exited.connect(RemoveExclusion.bind(ProjectileRID))
	
	BulletPoint.add_child(Projectile)
	Projectile.Launch(
		bullet_direction,
		CurrentWeapon.Damage,
		CurrentWeapon.ProjectileVelocity
	)


func HitscanCollision(collision_point: Vector3) -> void:
	var bullet_transform = BulletPoint.get_global_transform().origin
	var bullet_direction = (collision_point - bullet_transform).normalized()
	var _new_intersection = PhysicsRayQueryParameters3D.create(
		bullet_transform,
		collision_point + bullet_direction * 2
	)
	var bullet_collision = get_world_3d().direct_space_state.intersect_ray(_new_intersection)
	
	if bullet_collision:
		_instantiate_hit_indicator(bullet_collision.position)
		HitscanDamage(
			bullet_collision.collider,
			bullet_direction,
			bullet_collision.position
		)


func HitscanDamage(collider: Node3D, direction: Vector3, _position: Vector3) -> void:
	if collider.is_in_group("Target") and collider.has_method("HitSuccessful"):
		collider.HitSuccessful(CurrentWeapon.Damage, direction, _position)


func RemoveExclusion(projectile_rid) -> void:
	CollisionExclude.erase(projectile_rid)


func _get_camera_collision() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var viewport_size = get_viewport().get_size()
	
	var RayOrigin = camera.project_ray_origin(viewport_size / 2)
	var RayEnd = camera.project_ray_normal(viewport_size / 2) * CurrentWeapon.FireRange
	
	var NewIntersection = PhysicsRayQueryParameters3D.create(RayOrigin, RayEnd)
	NewIntersection.set_exclude(CollisionExclude)
	
	var Intersection = get_world_3d().direct_space_state.intersect_ray(NewIntersection)
	
	if not Intersection.is_empty():
		return Intersection.position
	
	return RayEnd


func _instantiate_hit_indicator(_position: Vector3) -> void:
	var hit_indicator = HitIndicator.instantiate()
	var world = get_tree().get_root().get_child(0)
	world.add_child(hit_indicator)
	hit_indicator.global_translate(_position)




