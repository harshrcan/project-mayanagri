extends Node3D
## Step 2 — Dharavi street corner look test. SA-DE edition (Harsh, 2026-11-15).
## One corner at golden evening: chai stall, parked auto, two chawl blocks.
## Built from primitives with procedural textures (tools/make_textures.py).
## Run with `-- --shot` under Xvfb to save a screenshot to docs/step2_shot.png.
## `-- --shot-de` saves the DE look to docs/step2_shot_de.png.

const Prim = preload("res://world/prim.gd")
const AutoScript = preload("res://vehicles/auto.gd")
const StallScript = preload("res://world/chai_stall.gd")
const PlayerScene = preload("res://characters/player.tscn")

const ASPHALT := Color("2e2a26")
const SIDEWALK := Color("6f655a")
const DRAIN := Color("241f1c")
const WALL_A := Color("d69a4f")
const WALL_B := Color("b85a48")
const ROOF_RUST := Color("8a4632")
const SHUTTER_TEAL := Color("1f8a80")
const SHUTTER_GREEN := Color("3f8a46")
const WINDOW_DARK := Color("241a12")
const WINDOW_LIT := Color("ffb85c")
const WOOD_DARK := Color("5a3d22")
const CRATE := Color("8a6a42")
const SACK := Color("b09a6a")
const BUCKET := Color("3f6d8a")


func _ready() -> void:
	_build_environment()
	_build_ground()
	_build_buildings()
	_build_pole_and_wires()
	_build_string_lights()
	_build_stall_and_auto()
	_build_props()
	_build_camera()
	_build_player()
	print("[Mayanagri] Dharavi corner ready.")
	if "--shot" in OS.get_cmdline_user_args() or "--shot-player" in OS.get_cmdline_user_args() or "--shot-de" in OS.get_cmdline_user_args():
		_take_screenshot()


func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("2f5a8a")
	sky_mat.sky_horizon_color = Color("ff9e57")
	sky_mat.sky_curve = 0.12
	sky_mat.ground_bottom_color = Color("241c14")
	sky_mat.ground_horizon_color = Color("9a7a58")
	sky_mat.ground_curve = 0.06
	sky.sky_material = sky_mat
	env.sky = sky
	# Cool blue fill (not sky ambient): warm sun + cool shadows is what
	# separates the palette — sky ambient alone drowned everything orange.
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("66779a")
	env.ambient_light_energy = 0.6
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_strength = 1.0
	env.glow_bloom = 0.15
	env.fog_enabled = true
	env.fog_light_color = Color("c98a5e")
	env.fog_density = 0.006
	env.fog_sky_affect = 0.5
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-16, -115, 0)
	sun.light_color = Color("ffb36b")
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	add_child(sun)

	# DE sky: a few soft cloud banks, flat planes facing down.
	for c in [
		[Vector3(-15, 24, -25), Vector2(34, 20)],
		[Vector3(18, 26, -18), Vector2(26, 16)],
		[Vector3(0, 22, -42), Vector2(40, 22)],
	]:
		var cloud := MeshInstance3D.new()
		var cmesh := PlaneMesh.new()
		cmesh.size = c[1]
		cloud.mesh = cmesh
		cloud.position = c[0]
		cloud.rotation_degrees.x = 180.0
		cloud.material_override = Prim.cloud_mat()
		add_child(cloud)


func _build_ground() -> void:
	# Solid slab, not a visual-only plane: the player must stand on it
	# (Step 3 caught the plane having no collision — Vee fell through).
	Prim.solid_box(self, Vector3(0, -0.05, 0), Vector3(120, 0.1, 120), Prim.tmat("asphalt", Color.WHITE, Vector3(30, 30, 30)))
	# L-shaped sidewalk in the north-west quadrant, in front of the buildings.
	Prim.box(self, Vector3(-8.5, 0.06, -4.5), Vector3(11, 0.12, 3), Prim.tmat("pavement", Color.WHITE, Vector3(11, 3, 3)))
	Prim.box(self, Vector3(-4.5, 0.06, -8.5), Vector3(3, 0.12, 11), Prim.tmat("pavement", Color.WHITE, Vector3(3, 11, 11)))
	# Drain edge along the east-west lane.
	Prim.box(self, Vector3(-4, 0.02, -3.05), Vector3(20, 0.04, 0.3), Prim.tmat("asphalt", Color(0.55, 0.55, 0.55), Vector3(20, 1, 1)))


func _window(parent: Node, pos: Vector3, lit: bool, facing_x: bool) -> void:
	var frame_size := Vector3(1.2, 1.4, 0.1) if not facing_x else Vector3(0.1, 1.4, 1.2)
	var pane_size := Vector3(0.95, 1.15, 0.12) if not facing_x else Vector3(0.12, 1.15, 0.95)
	Prim.box(parent, pos, frame_size, WINDOW_DARK)
	if lit:
		Prim.box(parent, pos, pane_size, WINDOW_LIT, 1.6)
	else:
		Prim.box(parent, pos, pane_size, Color("1c150e"))


func _build_buildings() -> void:
	# Building A — ochre chawl along the north side (faces south, toward camera).
	Prim.solid_box(self, Vector3(-4, 3.5, -7.5), Vector3(20, 7, 3), Prim.tmat("brick_ochre", Color.WHITE, Vector3(10, 3.5, 1.5)))
	Prim.box(self, Vector3(-4, 7.15, -7.5), Vector3(20.2, 0.15, 3.2), Prim.tmat("tin", Color.WHITE, Vector3(10, 1, 1.6)), 0.0, Vector3(0.1, 0, 0))
	for x in [-12.0, -8.0, -4.0, 0.0]:
		_window(self, Vector3(x, 2.2, -5.95), x == -8.0 or x == 0.0, false)
	for x in [-10.0, -6.0, -2.0, 2.0]:
		_window(self, Vector3(x, 5.0, -5.95), x == -2.0, false)
	# Teal door on building A.
	Prim.box(self, Vector3(-12, 1.1, -5.95), Vector3(1.2, 2.2, 0.1), SHUTTER_TEAL)
	# Water tank on the roof.
	Prim.cyl(self, Vector3(-8, 7.9, -7.5), 0.9, 1.2, Prim.tmat("plaster", Color("b8b0a0"), Vector3(2, 2, 2)))
	Prim.cyl(self, Vector3(-8, 8.55, -7.5), 0.95, 0.08, Color("1a1a1a"))
	# Washing line + cloths on building A's front.
	Prim.box(self, Vector3(-7, 4.3, -5.8), Vector3(8, 0.02, 0.02), Color("111111"))
	var cloth_colors := [Color("e85a48"), Color("4a8ad9"), Color("f0e8d0")]
	for i in 3:
		var cx := -10.0 + float(i) * 3.0
		Prim.box(self, Vector3(cx, 3.85, -5.8), Vector3(0.7, 0.9, 0.03), cloth_colors[i], 0.0, Vector3(0, 0, 0.05 if i % 2 == 0 else -0.05))

	# Building B — faded red chawl along the west side (faces east).
	Prim.solid_box(self, Vector3(-7.5, 3.0, -4), Vector3(3, 6, 20), Prim.tmat("brick_red", Color.WHITE, Vector3(1.5, 3, 10)))
	Prim.box(self, Vector3(-7.5, 6.1, -4), Vector3(3.2, 0.15, 20.2), Prim.tmat("tin", Color.WHITE, Vector3(1.6, 1, 10)), 0.0, Vector3(0, 0, 0.08))
	for z in [-12.0, -8.0, -4.0, 0.0]:
		_window(self, Vector3(-5.95, 2.2, z), z == -8.0, true)
	for z in [-10.0, -6.0, -2.0, 2.0]:
		_window(self, Vector3(-5.95, 4.6, z), z == -2.0, true)
	# Corner shop: green shutter + signboard on building B's east face.
	Prim.box(self, Vector3(-5.93, 1.2, 1.5), Vector3(0.1, 2.4, 2.2), Prim.tmat("wood", SHUTTER_GREEN, Vector3(1, 2, 2)))
	Prim.box(self, Vector3(-5.93, 2.8, 1.5), Vector3(0.1, 0.5, 2.4), Color("e8b93c"))
	var shop_sign := Label3D.new()
	shop_sign.text = "GENERAL STORE"
	shop_sign.font_size = 32
	shop_sign.pixel_size = 0.006
	shop_sign.modulate = Color("3a2410")
	shop_sign.position = Vector3(-5.85, 2.8, 1.5)
	shop_sign.rotation.y = PI / 2
	add_child(shop_sign)


func _wire(a: Vector3, b: Vector3) -> void:
	var dir := b - a
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.02
	mesh.bottom_radius = 0.02
	mesh.height = dir.length()
	mi.mesh = mesh
	mi.position = (a + b) / 2.0
	mi.quaternion = Quaternion(Vector3.UP, dir.normalized())
	mi.material_override = Prim.mat(Color("111111"))
	add_child(mi)


func _build_pole_and_wires() -> void:
	Prim.cyl(self, Vector3(-1, 3.5, 6), 0.12, 7.0, WOOD_DARK)
	Prim.box(self, Vector3(-1, 6.4, 6), Vector3(1.4, 0.1, 0.1), WOOD_DARK)
	_wire(Vector3(-1, 6.3, 6), Vector3(-4, 6.9, -6))
	_wire(Vector3(-1, 6.3, 6), Vector3(-6, 6.0, 0))
	_wire(Vector3(-1, 6.1, 6), Vector3(-7.4, 5.6, -8))


func _build_string_lights() -> void:
	var a := Vector3(-2, 4.0, -5.9)
	var b := Vector3(-1, 4.6, 6)
	_wire(a, b)
	for i in range(1, 8):
		var t := float(i) / 8.0
		var pos := a.lerp(b, t)
		pos.y -= sin(PI * t) * 0.5
		Prim.sphere(self, pos, 0.06, Color("ffca7a"), 2.5)


func _build_stall_and_auto() -> void:
	var stall: Node3D = StallScript.create()
	stall.position = Vector3(-4.4, 0.12, -4.4)
	stall.rotation.y = PI / 4
	add_child(stall)
	var auto: Node3D = AutoScript.create()
	auto.position = Vector3(3.2, 0.12, 1.0)
	auto.rotation.y = -0.5
	add_child(auto)


func _build_props() -> void:
	Prim.box(self, Vector3(-6.2, 0.42, -3.6), Vector3(0.6, 0.6, 0.6), Prim.tmat("wood", Color.WHITE, Vector3(1, 1, 1)))
	Prim.box(self, Vector3(-6.2, 1.02, -3.6), Vector3(0.5, 0.5, 0.5), Prim.tmat("wood", Color.WHITE, Vector3(1, 1, 1)), 0.0, Vector3(0, 0.4, 0))
	var sack := Prim.sphere(self, Vector3(-5.6, 0.3, -5.6), 0.45, SACK)
	sack.scale = Vector3(1.0, 0.65, 1.0)
	var sack2 := Prim.sphere(self, Vector3(-5.0, 0.3, -5.7), 0.4, SACK)
	sack2.scale = Vector3(1.0, 0.65, 1.0)
	Prim.cyl(self, Vector3(-3.2, 0.27, -5.2), 0.18, 0.3, BUCKET)
	# Handcart (thela) in the left foreground — bed, two big wheels, handles.
	var cart := Node3D.new()
	cart.name = "Handcart"
	cart.position = Vector3(-1.5, 0, 2.8)
	cart.rotation.y = 0.5
	add_child(cart)
	Prim.box(cart, Vector3(0, 0.55, 0), Vector3(1.6, 0.08, 0.9), Prim.tmat("wood", Color.WHITE, Vector3(2, 1, 1)))
	Prim.box(cart, Vector3(0, 0.62, 0), Vector3(1.2, 0.25, 0.7), SACK)
	Prim.cyl(cart, Vector3(-0.2, 0.35, 0.48), 0.35, 0.06, Color("141414"), 0.0, Vector3(PI / 2, 0, 0))
	Prim.cyl(cart, Vector3(-0.2, 0.35, -0.48), 0.35, 0.06, Color("141414"), 0.0, Vector3(PI / 2, 0, 0))
	Prim.cyl(cart, Vector3(1.0, 0.45, 0.3), 0.03, 0.7, WOOD_DARK, 0.0, Vector3(0, 0, 1.1))
	Prim.cyl(cart, Vector3(1.0, 0.45, -0.3), 0.03, 0.7, WOOD_DARK, 0.0, Vector3(0, 0, 1.1))

	# --- SA-DE density pass (2026-11-15) ---
	# Streetlight with a warm lamp (second light source after the stall).
	Prim.cyl(self, Vector3(5.5, 2.5, -2), 0.07, 5.0, Color("1c1c1c"))
	Prim.box(self, Vector3(5.2, 4.95, -2), Vector3(0.7, 0.08, 0.08), Color("1c1c1c"))
	Prim.box(self, Vector3(4.85, 4.9, -2), Vector3(0.45, 0.1, 0.22), Color("ffca7a"), 2.0)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(4.85, 4.7, -2)
	lamp.light_color = Color("ffd9a0")
	lamp.light_energy = 1.4
	lamp.omni_range = 9.0
	add_child(lamp)
	# Trash bags near building B.
	for tb in [Vector3(-6.4, 0.22, 2.4), Vector3(-6.0, 0.2, 2.9), Vector3(-6.5, 0.45, 2.7)]:
		var bag := Prim.sphere(self, tb, 0.32, Color("161616"))
		bag.scale = Vector3(1.0, 0.7, 1.0)
	# Stack of bricks against building A.
	for i in 5:
		Prim.box(self, Vector3(-2.0 + float(i % 2) * 0.05, 0.12 + float(i / 2) * 0.22, -5.7), Vector3(0.42, 0.2, 0.2), Color("a85f52"), 0.0, Vector3(0, 0.1 * float(i), 0))
	# Water drum by the stall.
	Prim.cyl(self, Vector3(-5.8, 0.45, -3.2), 0.3, 0.9, Color("2f5fa8"))
	Prim.cyl(self, Vector3(-5.8, 0.92, -3.2), 0.32, 0.06, Color("24486e"))
	# Potted plants flanking the stall.
	for pp in [Vector3(-5.6, 0, -5.6), Vector3(-3.2, 0, -5.8)]:
		Prim.cyl(self, pp + Vector3(0, 0.2, 0), 0.25, 0.4, Color("a85f3a"))
		Prim.sphere(self, pp + Vector3(0, 0.55, 0), 0.3, Color("4a7a3a"))
		Prim.sphere(self, pp + Vector3(0.15, 0.7, 0.1), 0.22, Color("557f3f"))
	# Two more invented posters on building A.
	_poster(Vector3(-1, 3.2, -5.93), "MAYANAGRI\nNIGHTS", Color("7a2a2a"), Color("f0e8d0"))
	_poster(Vector3(-6, 3.4, -5.93), "CHAI PE\nCHARCHA", Color("2a4a7a"), Color("ffd94a"))
	# Dashed centre line along the lane.
	for dz in [-3.0, 0.0, 3.0, 6.0, 9.0]:
		Prim.box(self, Vector3(1.2, 0.02, dz), Vector3(0.12, 0.02, 1.5), Color("d8c25a"))


func _poster(pos: Vector3, text: String, bg: Color, fg: Color) -> void:
	Prim.box(self, pos, Vector3(0.9, 1.2, 0.04), bg)
	var l := Label3D.new()
	l.text = text
	l.font_size = 28
	l.pixel_size = 0.005
	l.modulate = fg
	l.position = pos + Vector3(0, 0, 0.05)
	add_child(l)


func _build_camera() -> void:
	var cam := Camera3D.new()
	cam.name = "ShotCamera"
	cam.position = Vector3(8.5, 3.8, 8.5)
	cam.fov = 60.0
	cam.current = true
	add_child(cam)
	cam.look_at(Vector3(-3, 1.5, -3.5), Vector3.UP)


func _build_player() -> void:
	# No player in --shot / --shot-de mode: the fixed camera owns the frame.
	# (--shot-player spawns the player and shoots from his camera.)
	if "--shot" in OS.get_cmdline_user_args() or "--shot-de" in OS.get_cmdline_user_args():
		return
	var player := PlayerScene.instantiate()
	player.position = Vector3(0, 0.3, 8)
	add_child(player)


func _take_screenshot() -> void:
	# Let the renderer settle a few frames, then save the viewport image.
	for i in 10:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	var path := "res://docs/step2_shot.png"
	if "--shot-player" in OS.get_cmdline_user_args():
		path = "res://docs/step3_shot.png"
	elif "--shot-de" in OS.get_cmdline_user_args():
		path = "res://docs/step2_shot_de.png"
	var err := img.save_png(path)
	if err == OK:
		print("[Mayanagri] screenshot saved to ", path, " (", img.get_width(), "x", img.get_height(), ")")
	else:
		print("[Mayanagri] ERROR saving screenshot: ", err)
	get_tree().quit()
