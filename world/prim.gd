## Shared primitive builders for Project Mayanagri.
## SA-DE look: procedural textures (world/textures/, made by
## tools/make_textures.py) + flat colours where paint is enough.
## Materials are cached so the whole corner shares a handful of resources.
## Usage: const Prim = preload("res://world/prim.gd")  then  Prim.box(...)
## A shape's last colour argument takes a Color OR a Material
## (e.g. Prim.tmat("brick_ochre", Color.WHITE, Vector3(10, 3.5, 1.5))).

const TEX_DIR := "res://world/textures/"

static var _mat_cache := {}
static var _tex_cache := {}
static var _tmat_cache := {}


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


static func _resolve_mat(m, emission_energy := 0.0) -> Material:
	if m is Material:
		return m
	return mat(m, emission_energy)


static func tex(tex_name: String) -> Texture2D:
	if not _tex_cache.has(tex_name):
		var t: Texture2D = load(TEX_DIR + tex_name + ".png")
		_tex_cache[tex_name] = t
	return _tex_cache[tex_name]


## Textured material. tint multiplies the texture (WHITE = as painted).
## uv_scale tiles the texture: a 2 m tile on a 20 m wall is (10, ...).
static func tmat(tex_name: String, tint: Color, uv_scale: Vector3) -> StandardMaterial3D:
	var key := str(tex_name, "|", tint.to_html(), "|", uv_scale)
	if _tmat_cache.has(key):
		return _tmat_cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex(tex_name)
	m.albedo_color = tint
	m.roughness = 0.9
	m.metallic_specular = 0.0
	m.uv1_scale = uv_scale
	_tmat_cache[key] = m
	return m


static func cloud_mat() -> StandardMaterial3D:
	if _tmat_cache.has("cloud"):
		return _tmat_cache["cloud"]
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex("cloud")
	m.albedo_color = Color(1, 1, 1, 0.95)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.disable_fog = true
	_tmat_cache["cloud"] = m
	return m


static func box(parent: Node, pos: Vector3, size: Vector3, mat_or_color, emission_energy := 0.0, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	mi.material_override = _resolve_mat(mat_or_color, emission_energy)
	parent.add_child(mi)
	return mi


static func cyl(parent: Node, pos: Vector3, radius: float, height: float, mat_or_color, emission_energy := 0.0, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mi.mesh = mesh
	mi.position = pos
	mi.rotation = rot
	mi.material_override = _resolve_mat(mat_or_color, emission_energy)
	parent.add_child(mi)
	return mi


static func sphere(parent: Node, pos: Vector3, radius: float, mat_or_color, emission_energy := 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = _resolve_mat(mat_or_color, emission_energy)
	parent.add_child(mi)
	return mi


static func plane(parent: Node, pos: Vector3, size: Vector2, mat_or_color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	mi.material_override = _resolve_mat(mat_or_color)
	parent.add_child(mi)
	return mi


## A solid box that also blocks the player (used for ground + building walls).
static func solid_box(parent: Node, pos: Vector3, size: Vector3, mat_or_color) -> MeshInstance3D:
	var mi := box(parent, pos, size, mat_or_color)
	var body := StaticBody3D.new()
	body.position = pos
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	shape.shape = box_shape
	body.add_child(shape)
	parent.add_child(body)
	return mi
