extends Node
## Headless test harness for the Step 3 player controller.
## Drives the player with synthetic input and asserts walk / run / jump /
## punch / camera behaviour. Run: godot --headless --path . <this scene>
## Prints PASS/FAIL per check; quits 0 on all-pass, 1 on any failure.

const PlayerScene = preload("res://characters/player.tscn")
const Prim = preload("res://world/prim.gd")

var failures := 0
var player: VeePlayer


func _ready() -> void:
	Prim.solid_box(self, Vector3(0, -0.5, -40), Vector3(200, 1, 200), Color("333333"))
	player = PlayerScene.instantiate()
	player.position = Vector3(0, 0.5, 0)
	add_child(player)
	await get_tree().process_frame
	await get_tree().process_frame
	await _run_tests()
	if failures == 0:
		print("[TEST] ALL PASS")
		get_tree().quit(0)
	else:
		print("[TEST] FAILURES: ", failures)
		get_tree().quit(1)


func _check(check_name: String, cond: bool, detail: String = "") -> void:
	if cond:
		print("[TEST] PASS: ", check_name, " ", detail)
	else:
		print("[TEST] FAIL: ", check_name, " ", detail)
		failures += 1


func _wait_physics(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _run_tests() -> void:
	# 1. Walk forward for 2 s (4 m/s, snappy accel -> ~8 m).
	var start := player.global_position
	Input.action_press("move_forward")
	await _wait_physics(120)
	Input.action_release("move_forward")
	var walked := start.distance_to(player.global_position)
	_check("walk 2s moves 6-9.5m", walked > 6.0 and walked < 9.5, str(walked))
	_check("walk moves forward (-Z)", player.global_position.z < start.z - 5.0, str(player.global_position))

	# 2. Run forward for 2 s (7 m/s -> ~14 m), must beat walking.
	start = player.global_position
	Input.action_press("move_forward")
	Input.action_press("run")
	await _wait_physics(120)
	Input.action_release("run")
	Input.action_release("move_forward")
	var ran := start.distance_to(player.global_position)
	_check("run 2s moves 11-15.5m", ran > 11.0 and ran < 15.5, str(ran))
	_check("run faster than walk", ran > walked, str(ran, " vs ", walked))

	# 3. Jump: rises, then lands back on the floor.
	var y0 := player.global_position.y
	var max_y := y0
	Input.action_press("jump")
	await _wait_physics(5)
	Input.action_release("jump")
	for i in 90:
		await get_tree().physics_frame
		max_y = maxf(max_y, player.global_position.y)
	_check("jump rises >0.6m", max_y - y0 > 0.6, str(max_y - y0))
	_check("jump lands back", absf(player.global_position.y - y0) < 0.15, str(player.global_position.y))

	# 4. Punch: triggers, ends, can repeat.
	# (Lockout is 0.35 s swing + 0.15 s cooldown = 0.5 s, so wait 0.67 s.)
	var ok := player.try_punch()
	_check("punch triggers", ok and player.punch_timer > 0.0, str(player.punch_timer))
	await _wait_physics(40)
	_check("punch ends after 0.67s", player.punch_timer <= 0.0, str(player.punch_timer))
	var ok2 := player.try_punch()
	_check("punch can repeat", ok2, "")

	# 5. Camera: sits behind the player, is current, orbits on command.
	var cam: Camera3D = player.get_node("YawPivot/SpringArm3D/Camera3D")
	_check("camera is current", cam.current, "")
	_check("camera behind player (+Z side)", cam.global_position.z > player.global_position.z + 3.0, str(cam.global_position))
	# Spring arm 4.5 m minus 0.3 margin, pivot 1.6 m up: ~4.5 m from feet.
	var cam_dist := cam.global_position.distance_to(player.global_position)
	_check("camera ~4.5m from player", cam_dist > 4.0 and cam_dist < 5.0, str(cam_dist))
	var yaw0 := player.yaw
	player.rotate_camera(1.0, 0.0)
	_check("camera yaw changes", absf(player.yaw - yaw0) > 0.5, str(player.yaw))
	player.rotate_camera(0.0, 0.5)
	_check("camera pitch moves", player.pitch < 0.0 and player.pitch >= -1.1, str(player.pitch))
	player.rotate_camera(0.0, -5.0)
	_check("camera pitch clamps at max", is_equal_approx(player.pitch, 0.9), str(player.pitch))
