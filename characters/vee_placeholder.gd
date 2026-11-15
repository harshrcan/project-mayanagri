class_name VeePlaceholder
extends Node3D
## Placeholder body for Vee (Step 3). Built from primitives, procedural
## walk / run / jump / punch poses. Replaced by a rigged character later;
## the controller (player.gd) never touches this file's internals except
## through animate(). Faces -Z (Godot forward).

const Prim = preload("res://world/prim.gd")

const SHIRT := Color("2f6fb2")
const PANTS := Color("40465a")
const SKIN := Color("c98a5e")
const HAIR := Color("1a1a1a")

var _phase := 0.0
var _leg_l: Node3D
var _leg_r: Node3D
var _arm_l: Node3D
var _arm_r: Node3D


func _ready() -> void:
	_leg_l = _limb(Vector3(-0.11, 0.8, 0), Vector3(0.16, 0.75, 0.16), PANTS)
	_leg_r = _limb(Vector3(0.11, 0.8, 0), Vector3(0.16, 0.75, 0.16), PANTS)
	Prim.box(self, Vector3(0, 1.1, 0), Vector3(0.5, 0.6, 0.28), SHIRT)
	Prim.sphere(self, Vector3(0, 1.6, 0), 0.16, SKIN)
	Prim.box(self, Vector3(0, 1.74, 0), Vector3(0.3, 0.1, 0.3), HAIR)
	_arm_l = _limb(Vector3(-0.3, 1.35, 0), Vector3(0.13, 0.6, 0.13), SHIRT)
	_arm_r = _limb(Vector3(0.3, 1.35, 0), Vector3(0.13, 0.6, 0.13), SHIRT)


func _limb(pos: Vector3, size: Vector3, color: Color) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = pos
	add_child(pivot)
	Prim.box(pivot, Vector3(0, -size.y / 2.0, 0), size, color)
	return pivot


## speed: horizontal speed in m/s. punch_progress: -1 = no punch, else 0..1.
func animate(delta: float, speed: float, on_floor: bool, punch_progress: float) -> void:
	var ratio := clampf(speed / 7.0, 0.0, 1.0)
	if on_floor and speed > 0.3:
		_phase += delta * (4.0 + speed * 1.6)
		var swing := sin(_phase) * 0.55 * ratio
		_leg_l.rotation.x = swing
		_leg_r.rotation.x = -swing
		_arm_l.rotation.x = -swing * 0.8
		_arm_r.rotation.x = swing * 0.8
		position.y = absf(cos(_phase)) * 0.05 * ratio
	elif not on_floor:
		_leg_l.rotation.x = 0.5
		_leg_r.rotation.x = -0.3
		_arm_l.rotation.x = -0.6
		_arm_r.rotation.x = -0.6
		position.y = 0.0
	else:
		var k := clampf(10.0 * delta, 0.0, 1.0)
		_leg_l.rotation.x = lerpf(_leg_l.rotation.x, 0.0, k)
		_leg_r.rotation.x = lerpf(_leg_r.rotation.x, 0.0, k)
		_arm_l.rotation.x = lerpf(_arm_l.rotation.x, 0.0, k)
		_arm_r.rotation.x = lerpf(_arm_r.rotation.x, 0.0, k)
		position.y = 0.0
	if punch_progress >= 0.0:
		_arm_r.rotation.x = -1.6 * sin(PI * punch_progress)
