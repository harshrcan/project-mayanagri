class_name VeePlaceholder
extends Node3D
## Vee's visual — a Blender-modelled character (tools/build_vee.py):
## real proportions, face, hair, shirt, shoes. The .glb carries empty
## pivot nodes (LegL/R_pivot, ArmL/R_pivot) that this script drives
## with the same procedural walk / run / jump / punch poses the old
## primitive placeholder used. The controller (player.gd) only calls
## animate() and sets rotation.y, so the swap is invisible to it.
## Faces -Z (Godot forward).

const VeeModel = preload("res://characters/vee.glb")

var _phase := 0.0
var _leg_l: Node3D
var _leg_r: Node3D
var _arm_l: Node3D
var _arm_r: Node3D


func _ready() -> void:
	var model := VeeModel.instantiate()
	add_child(model)
	_leg_l = model.find_child("LegL_pivot", true, false)
	_leg_r = model.find_child("LegR_pivot", true, false)
	_arm_l = model.find_child("ArmL_pivot", true, false)
	_arm_r = model.find_child("ArmR_pivot", true, false)


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
