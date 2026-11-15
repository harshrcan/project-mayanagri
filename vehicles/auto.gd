## Parked auto rickshaw (kaali-peeli style) — original design, no real brand.
## Built from primitives. Faces +X (front at +X). No physics yet; Step 4
## reuses this and adds driving. Used by the Dharavi look test (Step 2).

const Prim = preload("res://world/prim.gd")

const YELLOW := Color("f2c200")
const BLACK := Color("1d1d20")
const TYRE := Color("141414")
const HUB := Color("cfcfcf")
const SEAT := Color("3a2a1c")
const GLASS_COL := Color("2c3e50")
const STEEL := Color("b8b8b8")


static func create() -> Node3D:
	var auto := Node3D.new()
	auto.name = "Auto"

	# Lower body + yellow band.
	Prim.box(auto, Vector3(0, 0.55, 0), Vector3(2.4, 0.55, 1.25), BLACK)
	Prim.box(auto, Vector3(0, 0.9, 0), Vector3(2.4, 0.18, 1.27), YELLOW)
	# Cabin floor + seat.
	Prim.box(auto, Vector3(-0.3, 1.0, 0), Vector3(1.5, 0.1, 1.15), BLACK)
	Prim.box(auto, Vector3(-0.45, 1.1, 0), Vector3(0.9, 0.14, 1.0), SEAT)
	Prim.box(auto, Vector3(-0.9, 1.35, 0), Vector3(0.12, 0.6, 1.0), SEAT)
	# Canopy roof.
	Prim.box(auto, Vector3(-0.3, 1.72, 0), Vector3(1.7, 0.08, 1.3), BLACK)
	# Rear pillars (canopy supports).
	Prim.box(auto, Vector3(-1.05, 1.4, 0.58), Vector3(0.08, 0.6, 0.08), BLACK)
	Prim.box(auto, Vector3(-1.05, 1.4, -0.58), Vector3(0.08, 0.6, 0.08), BLACK)
	# Windshield (tilted back slightly) + front nose.
	var shield := Prim.box(auto, Vector3(0.55, 1.35, 0), Vector3(0.05, 0.62, 1.15), GLASS_COL)
	shield.material_override = Prim.glass(GLASS_COL)
	shield.rotation.z = -0.12
	Prim.box(auto, Vector3(1.05, 0.75, 0), Vector3(0.5, 0.7, 1.2), YELLOW)
	Prim.box(auto, Vector3(1.05, 0.45, 0), Vector3(0.5, 0.18, 1.2), BLACK)
	# Headlight (emissive — catches the glow pass).
	Prim.sphere(auto, Vector3(1.32, 0.85, 0), 0.09, Color("ffe9a8"), 2.0)
	# Handlebar + mirrors.
	Prim.cyl(auto, Vector3(0.45, 1.15, 0), 0.03, 1.0, STEEL, 0.0, Vector3(PI / 2, 0, 0))
	Prim.box(auto, Vector3(0.45, 1.28, 0.62), Vector3(0.04, 0.12, 0.18), BLACK)
	Prim.box(auto, Vector3(0.45, 1.28, -0.62), Vector3(0.04, 0.12, 0.18), BLACK)
	# Wheels: one front, two rear.
	_wheel(auto, Vector3(1.0, 0.32, 0))
	_wheel(auto, Vector3(-0.85, 0.32, 0.6))
	_wheel(auto, Vector3(-0.85, 0.32, -0.6))
	return auto


static func _wheel(parent: Node, pos: Vector3) -> void:
	# Cylinder axis is Y; rotate so the axle runs along Z.
	Prim.cyl(parent, pos, 0.32, 0.12, TYRE, 0.0, Vector3(PI / 2, 0, 0))
	Prim.cyl(parent, pos, 0.14, 0.14, HUB, 0.0, Vector3(PI / 2, 0, 0))
