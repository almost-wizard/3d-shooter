extends CharacterBody3D

const WALK_SPEED = 4.0
const SPRINT_SPEED = 6.0
var speed

const JUMP_VELOCITY = 4.5
const AIR_BRAKING = 1.0

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const CAMERA_SENSITIVITY = 0.003

@onready var Camera = $CameraHolder/Camera
@onready var CameraHolder = $CameraHolder


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion:
		CameraHolder.rotate_y(-event.relative.x * CAMERA_SENSITIVITY)
		Camera.rotate_x(-event.relative.y * CAMERA_SENSITIVITY)
		Camera.rotation.x = clamp(Camera.rotation.x, deg_to_rad(-60), deg_to_rad(70))
	

func _physics_process(delta):
	_handle_move(delta)
	move_and_slide()


func _handle_move(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("run"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (CameraHolder.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * AIR_BRAKING)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * AIR_BRAKING)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	Camera.transform.origin = _headbob(t_bob)


func _headbob(time) -> Vector3:
	var pos = Vector3()
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
