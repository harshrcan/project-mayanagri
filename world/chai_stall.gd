## Chai stall — "Amrut Chai" (invented name). Faces +Z (front toward the lane).
## Own scene file so later districts reuse it. The tube light over the
## counter is the second light source in the Step 2 look test.

const Prim = preload("res://world/prim.gd")

const WOOD := Color("7a5230")
const WOOD_LIGHT := Color("9a6b3f")
const SIGN_YELLOW := Color("e8b93c")
const SIGN_TEXT := Color("3a2410")
const STEEL := Color("b8b8b8")
const ROOF_RUST := Color("8a4632")


static func create() -> Node3D:
	var stall := Node3D.new()
	stall.name = "ChaiStall"

	# Counter + top + back wall + shelves (wood texture, SA-DE pass).
	Prim.box(stall, Vector3(0, 0.5, 0.55), Vector3(2.4, 1.0, 0.15), Prim.tmat("wood", Color.WHITE, Vector3(2, 1, 1)))
	Prim.box(stall, Vector3(0, 1.02, 0), Vector3(2.4, 0.08, 1.3), Prim.tmat("wood", Color.WHITE, Vector3(2, 1, 1)))
	Prim.box(stall, Vector3(0, 0.8, -0.55), Vector3(2.4, 1.6, 0.15), Prim.tmat("wood", Color.WHITE, Vector3(2, 1, 1)))
	Prim.box(stall, Vector3(0, 1.15, -0.42), Vector3(2.2, 0.06, 0.3), Prim.tmat("wood", Color.WHITE, Vector3(2, 1, 1)))
	Prim.box(stall, Vector3(0, 1.55, -0.42), Vector3(2.2, 0.06, 0.3), Prim.tmat("wood", Color.WHITE, Vector3(2, 1, 1)))
	# Jars on the shelves (chai masala, sugar, biscuits).
	Prim.cyl(stall, Vector3(-0.7, 1.3, -0.42), 0.09, 0.24, Color("d9a441"))
	Prim.cyl(stall, Vector3(-0.4, 1.3, -0.42), 0.09, 0.24, Color("b0522f"))
	Prim.cyl(stall, Vector3(0.5, 1.3, -0.42), 0.09, 0.24, Color("7a9a4a"))
	Prim.cyl(stall, Vector3(0.8, 1.3, -0.42), 0.09, 0.24, Color("d9a441"))
	# Kettle + stack of cutting-chai glasses on the counter.
	Prim.cyl(stall, Vector3(-0.8, 1.18, 0.1), 0.11, 0.22, STEEL)
	Prim.cyl(stall, Vector3(-0.68, 1.24, 0.1), 0.03, 0.2, STEEL, 0.0, Vector3(0, 0, 0.7))
	for i in 6:
		var gx := -0.1 + float(i % 3) * 0.22
		var gz := 0.15 + float(i / 3) * 0.22
		Prim.cyl(stall, Vector3(gx, 1.1, gz), 0.035, 0.09, Color("e8a34c"))
	# Signboard + painted text (Label3D, default font — English only here;
	# Hindi lettering needs a Devanagari font, a later pass).
	Prim.box(stall, Vector3(0, 2.15, 0), Vector3(2.4, 0.6, 0.08), SIGN_YELLOW)
	var sign := Label3D.new()
	sign.text = "AMRUT CHAI"
	sign.font_size = 40
	sign.pixel_size = 0.006
	sign.modulate = SIGN_TEXT
	sign.position = Vector3(0, 2.15, 0.06)
	stall.add_child(sign)
	var sub := Label3D.new()
	sub.text = "CUTTING CHAI - VADA PAV"
	sub.font_size = 24
	sub.pixel_size = 0.005
	sub.modulate = Color("e8e0c8")
	sub.position = Vector3(0, 0.55, 0.64)
	stall.add_child(sub)
	# Roof: 4 poles + sloped tin sheet.
	for px in [-1.1, 1.1]:
		for pz in [-0.55, 0.55]:
			Prim.cyl(stall, Vector3(px, 1.25, pz), 0.04, 2.5, WOOD)
	Prim.box(stall, Vector3(0, 2.55, 0), Vector3(2.7, 0.05, 1.6), Prim.tmat("tin", Color.WHITE, Vector3(2, 1, 1)), 0.0, Vector3(0.08, 0, 0))
	# Tube light (emissive) + the warm omni light that lights the counter.
	Prim.box(stall, Vector3(0, 1.78, 0.45), Vector3(1.6, 0.06, 0.06), Color("ffd9a0"), 3.0)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 1.6, 0.8)
	light.light_color = Color("ffc06a")
	light.light_energy = 2.2
	light.omni_range = 6.0
	light.shadow_enabled = false
	stall.add_child(light)
	# Two stools in front.
	for sx in [-0.8, 0.8]:
		Prim.cyl(stall, Vector3(sx, 0.55, 1.15), 0.18, 0.06, Prim.tmat("wood", Color.WHITE, Vector3(1, 1, 1)))
		Prim.cyl(stall, Vector3(sx, 0.28, 1.15), 0.04, 0.55, WOOD)
	return stall
