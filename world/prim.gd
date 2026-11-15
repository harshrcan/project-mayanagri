## Shared primitive builders for Project Mayanagri look tests.
## Flat-colour low-poly: no textures yet. Materials are cached by colour so
## the whole corner shares a handful of StandardMaterial3D resources.
## Usage: const Prim = preload("res://world/prim.gd")  then  Prim.box(...)

static var _mat_cache := {}


static func mat(color: Color, emission_energy := 0.0) -> StandardMaterial3D:
	var key := str(color.to_html(), "|", emission_energy)
	if _mat_cache.has(key):
		return _mat_cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 1.0
	m.metallic_specular = 0.0
	if emission_energy > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emission_energy
	_mat_cache[key] = m
	return m


static func glass(color: Color) -> StandardMaterial3D:
	var key := str("glass|", color.to_html())
	if _mat_cache.has(key):
		return _mat_cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(color.r, color.g, color.b, 0.45)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.roughness = 0.15
	m.metallic_specular = 0.6
	_mat_cache[key] = m
	return m


static func box(parent: Node, pos: Vector3, size: Vector3, color: Color, emission_energy := 0.0, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	mi.material_override = mat(color, emission_energy)
	parent.add_child(mi)
	return mi


static func cyl(parent: Node, pos: Vector3, radius: float, height: float, color: Color, emission_energy := 0.0, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	mi.material_override = mat(color, emission_energy)
	parent.add_child(mi)
	return mi


static func sphere(parent: Node, pos: Vector3, radius: float, color: Color, emission_energy := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat(color, emission_energy)
	parent.add_child(mi)
	return mi


static func plane(parent: Node, pos: Vector3, size: Vector2, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = mat(color)
	parent.add_child(mi)
	return mi


## A solid box that also blocks the player (used for ground + building walls).
static func solid_box(parent: Node, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mi := box(parent, pos, size, color)
	var body := StaticBody3D.new()
	body.position = pos
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	body.add_child(shape)
	parent.add_child(body)
	return mi
