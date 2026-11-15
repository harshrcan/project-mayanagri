extends Node3D
## Step 2 — Dharavi street corner look test. Realistic GTA V edition (Harsh, 2026-11-15).
## One corner at golden evening: chai stall, parked auto, two chawl blocks.
## Buildings, streetlight, tree and auto are Blender models (tools/build_dharavi.py);
## small props stay Prim-based. Textures are procedural (tools/make_textures.py).
## Run with `-- --shot-real` under Xvfb to save a screenshot to docs/step2_shot_realistic.png.

const Prim = preload("res://world/prim.gd")
const StallScript = preload("res://world/chai_stall.gd")
const PlayerScene = preload("res://characters/player.tscn")
const BuildingA = preload("res://world/models/building_a.glb")
const BuildingB = preload("res://world/models/building_b.glb")
const StreetlightModel = preload("res://world/models/streetlight.glb")
const TreeModel = preload("res://world/models/tree.glb")
const AutoModel = preload("res://vehicles/auto.glb")

const WOOD_DARK := Color("5a3d22")
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
	if "--shot" in OS.get_cmdline_user_args() or "--shot-player" in OS.get_cmdline_user_args() or "--shot-de" in OS.get_cmdline_user_args() or "--shot-real" in OS.get_cmdline_user_args():
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
	env.ambient_light_color = Color("7a7f92")
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_strength = 1.0
	env.glow_bloom = 0.15
	env.fog_enabled = true
	env.fog_light_color = Color("c98a5e")
	env.fog_density = 0.008
	env.fog_sky_affect = 0.5
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-28, -115, 0)
	sun.light_color = Color("ffb36b")
	sun.light_energy = 1.5
	sun.shadow_enabled = true
	sun.shadow_blur = 1.0
	sun.directional_shadow_max_distance = 150.0
	add_child(sun)
	# Dim cool fill from the east so the shaded faces never go dead black.
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-30, 65, 0)
	fill.light_color = Color("8a9ab0")
	fill.light_energy = 0.2
	fill.shadow_enabled = false
	add_child(fill)

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
	# 200 m wide so the distant skyline stands on ground, not the void.
	Prim.solid_box(self, Vector3(0, -0.05, 0), Vector3(200, 0.1, 200), Prim.tmat("asphalt", Color.WHITE, Vector3(50, 50, 50)))
	# L-shaped sidewalk in the north-west quadrant, in front of the buildings.
	Prim.box(self, Vector3(-8.5, 0.06, -4.5), Vector3(11, 0.12, 3), Prim.tmat("pavement", Color.WHITE, Vector3(11, 3, 3)))
	Prim.box(self, Vector3(-4.5, 0.06, -8.5), Vector3(3, 0.12, 11), Prim.tmat("pavement", Color.WHITE, Vector3(3, 11, 11)))
	# Drain edge along the east-west lane.
	Prim.box(self, Vector3(-4, 0.02, -3.05), Vector3(20, 0.04, 0.3), Prim.tmat("asphalt", Color(0.55, 0.55, 0.55), Vector3(20, 1, 1)))


func _build_buildings() -> void:
	# Blender-modelled buildings (tools/build_dharavi.py). The .glb files
	# are the visuals; invisible collision boxes keep the player out.
	# (Windows, balconies, AC units, parapets, pipes, door, tank, shop
	# shutter and signboard are all in the models now.)
	var a := BuildingA.instantiate()
	add_child(a)
	Prim.collision_box(self, Vector3(-4, 3.5, -7.5), Vector3(20, 7, 3))
	var b := BuildingB.instantiate()
	add_child(b)
	Prim.collision_box(self, Vector3(-7.5, 3.0, -4), Vector3(3, 6, 20))
	# Washing line + cloths on building A's front.
	Prim.box(self, Vector3(-7, 4.3, -5.8), Vector3(8, 0.02, 0.02), Color("111111"))
	var cloth_colors := [Color("e85a48"), Color("4a8ad9"), Color("f0e8d0")]
	for i in 3:
		var cx := -10.0 + float(i) * 3.0
		Prim.box(self, Vector3(cx, 3.85, -5.8), Vector3(0.7, 0.9, 0.03), cloth_colors[i], 0.0, Vector3(0, 0, 0.05 if i % 2 == 0 else -0.05))
	# GENERAL STORE sign text on building B's signboard.
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


func _build_bicycle() -> void:
	# A bicycle leaning on building B's east face (length along Z, front +Z).
	var bike := Node3D.new()
	bike.position = Vector3(-5.7, 0, 4)
	bike.rotation.z = 0.12
	add_child(bike)
	var tyre := Color("1a1a1a")
	var steel := Color("6a6a6a")
	for wz in [-1.1, 1.1]:
		Prim.cyl(bike, Vector3(0, 0.33, wz), 0.33, 0.04, tyre, 0.0, Vector3(0, 0, PI / 2))
		Prim.cyl(bike, Vector3(0, 0.33, wz), 0.05, 0.06, steel, 0.0, Vector3(0, 0, PI / 2))
	# Frame bars (cylinders tilted in the Y-Z plane, rotation about X).
	Prim.cyl(bike, Vector3(0, 0.875, 0.075), 0.025, 1.85, steel, 0.0, Vector3(PI / 2, 0, 0))
	Prim.cyl(bike, Vector3(0, 0.475, 0.45), 0.025, 1.13, steel, 0.0, Vector3(1.35, 0, 0))
	Prim.cyl(bike, Vector3(0, 0.6, -0.475), 0.025, 0.9, steel, 0.0, Vector3(-0.99, 0, 0))
	Prim.cyl(bike, Vector3(0, 0.465, 1.05), 0.025, 0.29, steel, 0.0, Vector3(-0.35, 0, 0))
	Prim.cyl(bike, Vector3(0, 0.34, -0.6), 0.02, 1.0, steel, 0.0, Vector3(PI / 2, 0, 0))
	Prim.box(bike, Vector3(0, 0.95, 1.0), Vector3(0.5, 0.05, 0.05), steel)
	Prim.box(bike, Vector3(0, 0.9, -0.85), Vector3(0.05, 0.05, 0.3), tyre)


func _build_skyline() -> void:
	# Distant Mumbai skyline ringing the corner (55-70 m out, inside the
	# 200 m ground plane). Dark and fog-hazed, the way GTA V hazes Los
	# Santos — a silhouette, not a wall of lit boxes. No collision.
	var rng := RandomNumberGenerator.new()
	rng.seed = 2413
	var sky_mat := Color("262b36")
	var lit_mat := Color("ffb85c")
	for i in 16:
		var angle := TAU * float(i) / 16.0 + rng.randf_range(-0.12, 0.12)
		var dist := rng.randf_range(55.0, 70.0)
		var x := cos(angle) * dist
		var z := sin(angle) * dist
		var w := rng.randf_range(8.0, 16.0)
		var h := rng.randf_range(10.0, 22.0)
		var d := rng.randf_range(8.0, 14.0)
		Prim.box(self, Vector3(x, h / 2.0, z), Vector3(w, h, d), sky_mat)
		if rng.randf() < 0.6:
			var dir_to_centre := Vector3(-x, 0, -z).normalized()
			var side := Vector3(-dir_to_centre.z, 0, dir_to_centre.x)
			var n := rng.randi_range(2, 5)
			for j in n:
				var face_pos := Vector3(x, rng.randf_range(3.0, h - 2.0), z)
				face_pos += dir_to_centre * (maxf(w, d) / 2.0 + 0.1)
				face_pos += side * rng.randf_range(-w / 3.0, w / 3.0)
				Prim.box(self, face_pos, Vector3(0.7, 0.9, 0.7), lit_mat, 1.5)


func _build_stall_and_auto() -> void:
	var stall: Node3D = StallScript.create()
	stall.position = Vector3(-4.4, 0.12, -4.4)
	stall.rotation.y = PI / 4
	add_child(stall)
	var auto := AutoModel.instantiate()
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
	# Streetlight (Blender model) with its warm lamp light.
	var streetlight := StreetlightModel.instantiate()
	streetlight.position = Vector3(5.5, 0, -2)
	add_child(streetlight)
	var lamp := OmniLight3D.new()
	lamp.position = Vector3(4.85, 4.7, -2)
	lamp.light_color = Color("ffd9a0")
	lamp.light_energy = 1.4
	lamp.omni_range = 9.0
	add_child(lamp)
	# Tree on the east side, behind the auto.
	var tree := TreeModel.instantiate()
	tree.position = Vector3(7, 0, -4)
	add_child(tree)
	# Second tree on the west sidewalk, near the south end.
	var tree2 := TreeModel.instantiate()
	tree2.position = Vector3(-8.5, 0, 7)
	tree2.rotation.y = 0.8
	tree2.scale = Vector3.ONE * 0.85
	add_child(tree2)
	_build_bicycle()
	_build_skyline()
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
	# No player in --shot / --shot-de / --shot-real mode: the fixed camera owns the frame.
	# (--shot-player spawns the player and shoots from his camera.)
	if "--shot" in OS.get_cmdline_user_args() or "--shot-de" in OS.get_cmdline_user_args() or "--shot-real" in OS.get_cmdline_user_args():
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
	elif "--shot-real" in OS.get_cmdline_user_args():
		path = "res://docs/step2_shot_realistic.png"
	var err := img.save_png(path)
	if err == OK:
		print("[Mayanagri] screenshot saved to ", path, " (", img.get_width(), "x", img.get_height(), ")")
	else:
		print("[Mayanagri] ERROR saving screenshot: ", err)
	get_tree().quit()
