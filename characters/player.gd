class_name VeePlayer
extends CharacterBody3D
## Vee — third-person player controller (Step 3).
## Walk / run / jump / punch + orbit camera on a spring arm.
## Movement is independent of the visual (child node "Visual"), so the
## placeholder mesh can be swapped for a rigged character later.

signal punched

const WALK_SPEED := 4.0
const RUN_SPEED := 7.0
const ACCEL_GROUND := 40.0
const ACCEL_AIR := 18.0
const GRAVITY := 20.0
const JUMP_VELOCITY := 7.0
const MOUSE_SENS := 0.0025
const PITCH_MIN := -1.1
const PITCH_MAX := 0.9
const PUNCH_TIME := 0.35
const PUNCH_COOLDOWN := 0.15

var yaw := 0.0
var pitch := 0.0
var punch_timer := 0.0
var punch_cooldown := 0.0
var punch_count := 0
var _jump_held := false

@onready var pivot: Node3D = $YawPivot
@onready var spring: SpringArm3D = $YawPivot/SpringArm3D
@onready var visual: VeePlaceholder = $Visual


## Input actions are created at runtime (not hand-written in project.godot):
## the serialized InputEventKey format is fragile, runtime setup is
## deterministic and testable.
static func ensure_input() -> void:
	_add_key_action("move_forward", [KEY_W, KEY_UP])
	_add_key_action("move_back", [KEY_S, KEY_DOWN])
	_add_key_action("move_left", [KEY_A, KEY_LEFT])
	_add_key_action("move_right", [KEY_D, KEY_RIGHT])
	_add_key_action("run", [KEY_SHIFT])
	_add_key_action("jump", [KEY_SPACE])
	_add_key_action("punch", [KEY_F])


static func _add_key_action(action_name: String, keys: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for key in keys:
		var exists := false
		for ev in InputMap.action_get_events(action_name):
			if ev is InputEventKey and ev.physical_keycode == key:
				exists = true
		if not exists:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action_name, ev)


func _ready() -> void:
	ensure_input()
	_apply_camera()


func _apply_camera() -> void:
	pivot.rotation.y = yaw
	spring.rotation.x = pitch


func rotate_camera(delta_yaw: float, delta_pitch: float) -> void:
	yaw -= delta_yaw
	pitch = clampf(pitch - delta_pitch, PITCH_MIN, PITCH_MAX)
	_apply_camera()


func try_punch() -> bool:
	if punch_timer > 0.0 or punch_cooldown > 0.0:
		return false
	punch_timer = PUNCH_TIME
	punch_cooldown = PUNCH_TIME + PUNCH_COOLDOWN
	punch_count += 1
	punched.emit()
	return true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			try_punch()
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_camera(event.relative.x * MOUSE_SENS, event.relative.y * MOUSE_SENS)
	elif event.is_action_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("punch") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		try_punch()


func _physics_process(delta: float) -> void:
	punch_timer = maxf(0.0, punch_timer - delta)
	punch_cooldown = maxf(0.0, punch_cooldown - delta)

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var dir := Basis(Vector3.UP, yaw) * Vector3(input_dir.x, 0.0, input_dir.y)
	if dir.length() > 1.0:
		dir = dir.normalized()
	var target_speed := RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED
	var accel := ACCEL_GROUND if is_on_floor() else ACCEL_AIR
	var hv := Vector3(velocity.x, 0.0, velocity.z)
	hv = hv.move_toward(dir * target_speed, accel * delta)
	velocity.x = hv.x
	velocity.z = hv.z

	# Manual edge detection (works with real keys and synthetic test input).
	var jump_pressed := Input.is_action_pressed("jump")
	if jump_pressed and not _jump_held and is_on_floor():
		velocity.y = JUMP_VELOCITY
	_jump_held = jump_pressed
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	move_and_slide()

	if dir.length() > 0.1:
		var target_yaw := atan2(-dir.x, -dir.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_yaw, clampf(12.0 * delta, 0.0, 1.0))

	var punch_progress := -1.0
	if punch_timer > 0.0:
		punch_progress = 1.0 - punch_timer / PUNCH_TIME
	visual.animate(delta, hv.length(), is_on_floor(), punch_progress)
