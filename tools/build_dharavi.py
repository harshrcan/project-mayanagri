#!/usr/bin/env python3
"""Build the Dharavi corner's realistic models in Blender (GTA V look).

Run:  blender --background --python tools/build_dharavi.py
Writes: world/models/building_a.glb, building_b.glb, streetlight.glb,
        tree.glb, vehicles/auto.glb

All geometry is original, modelled here from the corner's layout.
Materials use the procedural textures from tools/make_textures.py
(256/512px PNGs, ours) — never art ripped from any game.

Coordinate note: the script models in GODOT coordinates (Y-up, the
corner's layout numbers) and converts to Blender (Z-up) with G()/GS().
The glTF exporter converts back to Y-up on export, so the .glb files
drop into Godot at the same positions.
"""
import bpy
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "world", "models")
AUTO_OUT = os.path.join(HERE, "..", "vehicles")
TEX = os.path.join(HERE, "..", "world", "textures")
os.makedirs(OUT, exist_ok=True)

# ---------------------------------------------------------------- helpers
def G(p):
    """Godot (x, y, z) -> Blender (x, -z, y)."""
    return (p[0], -p[2], p[1])


def GS(s):
    """Godot size (sx, sy, sz) -> Blender (sx, sz, sy)."""
    return (s[0], s[2], s[1])


def _rot_godot_to_blender(rot_godot):
    """Single-axis Godot euler -> Blender euler.
    Godot Rx -> Blender Rx, Godot Ry -> Blender Rz, Godot Rz -> Blender Ry(-)."""
    rx, ry, rz = rot_godot
    return (rx, -rz, ry)


_mats = {}


def tex_mat(name, rough=0.9):
    if name in _mats:
        return _mats[name]
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    img = bpy.data.images.load(os.path.join(TEX, name + ".png"))
    tex = m.node_tree.nodes.new("ShaderNodeTexImage")
    tex.image = img
    m.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = rough
    _mats[name] = m
    return m


def flat_mat(name, color, rough=0.9, metallic=0.0, emission=None, emission_strength=0.0):
    if name in _mats:
        return _mats[name]
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metallic
    if emission is not None:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = emission_strength
    _mats[name] = m
    return m


STEEL_DARK = None
STEEL_LIGHT = None
GLASS_DARK = None
GLASS_LIT = None


def _flat_mats():
    global STEEL_DARK, STEEL_LIGHT, GLASS_DARK, GLASS_LIT
    STEEL_DARK = flat_mat("steel_dark", (0.12, 0.12, 0.12), rough=0.8, metallic=0.1)
    STEEL_LIGHT = flat_mat("steel_light", (0.75, 0.75, 0.72), rough=0.5, metallic=0.4)
    # Dark glass: no metal (metallic mirrors the bright sky and turns the
    # windows light grey), rough enough not to glare.
    GLASS_DARK = flat_mat("glass_dark", (0.06, 0.05, 0.04), rough=0.4, metallic=0.0)
    # Lit windows: deep orange, modest strength — ACES washes a bright
    # warm emissive to near-white, so keep the colour saturated.
    GLASS_LIT = flat_mat("glass_lit", (1.0, 0.45, 0.1), rough=0.4,
                         emission=(1.0, 0.45, 0.1), emission_strength=2.0)


def box(parts, name, pos, size, mat, tile=2.0, bevel=0.0, rot_godot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(location=G(pos))
    o = bpy.context.active_object
    o.name = name
    o.dimensions = GS(size)
    o.rotation_euler = _rot_godot_to_blender(rot_godot)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(mat)
    if bevel > 0:
        mod = o.modifiers.new("bev", "BEVEL")
        mod.width = bevel
        mod.segments = 2
    parts.append((o, tile))
    return o


def cyl(parts, name, pos, radius, height, mat, tile=1.0, axis="y"):
    """axis: the Godot axis the cylinder runs along ('y' = vertical)."""
    bpy.ops.mesh.primitive_cylinder_add(radius=radius, depth=height, location=G(pos))
    o = bpy.context.active_object
    o.name = name
    if axis == "x":
        o.rotation_euler = (0, math.pi / 2, 0)
    elif axis == "z":
        o.rotation_euler = (math.pi / 2, 0, 0)
    o.data.materials.append(mat)
    parts.append((o, tile))
    return o


def torus(parts, name, pos, major, minor, mat, tile=1.0):
    """Wheel tyre: disc in the Godot X-Y plane (axle along Godot Z)."""
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor,
                                     location=G(pos), rotation=(math.pi / 2, 0, 0))
    o = bpy.context.active_object
    o.name = name
    o.data.materials.append(mat)
    parts.append((o, tile))
    return o


def blob(parts, name, pos, radius, mat, scale=(1, 1, 1), tile=1.0):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=radius, location=G(pos))
    o = bpy.context.active_object
    o.name = name
    o.scale = GS(scale)
    o.data.materials.append(mat)
    parts.append((o, tile))
    return o


def project_uvs(parts):
    """Bake transforms, then cube-project UVs per part (tile = metres per repeat)."""
    for (o, tile) in parts:
        bpy.ops.object.select_all(action="DESELECT")
        o.select_set(True)
        bpy.context.view_layer.objects.active = o
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.cube_project(cube_size=tile)
        bpy.ops.object.mode_set(mode="OBJECT")
    bpy.ops.object.select_all(action="DESELECT")


def export_model(parts, path):
    project_uvs(parts)
    bpy.ops.object.select_all(action="DESELECT")
    for (o, _t) in parts:
        o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True)
    print("exported", path, "objects:", len(parts))
    bpy.ops.object.delete()
    bpy.ops.object.select_all(action="DESELECT")


# ---------------------------------------------------------------- windows etc.
def _window(parts, pos, facing, lit):
    """A window on a solid wall mass: the glass sits ON the wall and the
    frame is 4 bars proud of it (a solid frame box would swallow the glass)."""
    x, y, z = pos
    glass = GLASS_LIT if lit else GLASS_DARK
    conc = tex_mat("concrete")
    if facing == "z":  # front face toward +Z
        box(parts, "glass", (x, y, z + 0.02), (1.1, 1.3, 0.04), glass, tile=1.0)
        box(parts, "frame_top", (x, y + 0.71, z + 0.05), (1.3, 0.08, 0.1), conc, tile=1.0)
        box(parts, "frame_bot", (x, y - 0.71, z + 0.05), (1.3, 0.08, 0.1), conc, tile=1.0)
        box(parts, "frame_l", (x - 0.61, y, z + 0.05), (0.08, 1.5, 0.1), conc, tile=1.0)
        box(parts, "frame_r", (x + 0.61, y, z + 0.05), (0.08, 1.5, 0.1), conc, tile=1.0)
        box(parts, "sill", (x, y - 0.79, z + 0.05), (1.4, 0.08, 0.2), conc, tile=1.0)
    else:  # front face toward +X
        box(parts, "glass", (x + 0.02, y, z), (0.04, 1.3, 1.1), glass, tile=1.0)
        box(parts, "frame_top", (x + 0.05, y + 0.71, z), (0.1, 0.08, 1.3), conc, tile=1.0)
        box(parts, "frame_bot", (x + 0.05, y - 0.71, z), (0.1, 0.08, 1.3), conc, tile=1.0)
        box(parts, "frame_l", (x + 0.05, y, z - 0.61), (0.1, 1.5, 0.08), conc, tile=1.0)
        box(parts, "frame_r", (x + 0.05, y, z + 0.61), (0.1, 1.5, 0.08), conc, tile=1.0)
        box(parts, "sill", (x + 0.05, y - 0.79, z), (0.2, 0.08, 1.4), conc, tile=1.0)


def _balcony_z(parts, pos):
    """Balcony on a +Z-facing wall. pos = (x, slab_y, wall_z)."""
    x, y, z = pos
    conc = tex_mat("concrete")
    box(parts, "balc_slab", (x, y, z + 0.45), (1.8, 0.12, 0.9), conc, tile=1.0)
    box(parts, "balc_rail", (x, y + 1.0, z + 0.88), (1.8, 0.05, 0.05), STEEL_DARK, tile=1.0)
    for dx in [-0.85, -0.42, 0.0, 0.42, 0.85]:
        box(parts, "balc_bar", (x + dx, y + 0.55, z + 0.88), (0.04, 0.9, 0.04), STEEL_DARK, tile=1.0)
    for dx in [-0.7, 0.7]:
        box(parts, "balc_bracket", (x + dx, y - 0.2, z + 0.2), (0.08, 0.4, 0.4), STEEL_DARK, tile=1.0)


def _balcony_x(parts, pos):
    """Balcony on a +X-facing wall. pos = (wall_x, slab_y, z)."""
    x, y, z = pos
    conc = tex_mat("concrete")
    box(parts, "balc_slab", (x + 0.45, y, z), (0.9, 0.12, 1.8), conc, tile=1.0)
    box(parts, "balc_rail", (x + 0.88, y + 1.0, z), (0.05, 0.05, 1.8), STEEL_DARK, tile=1.0)
    for dz in [-0.85, -0.42, 0.0, 0.42, 0.85]:
        box(parts, "balc_bar", (x + 0.88, y + 0.55, z + dz), (0.04, 0.9, 0.04), STEEL_DARK, tile=1.0)
    for dz in [-0.7, 0.7]:
        box(parts, "balc_bracket", (x + 0.2, y - 0.2, z + dz), (0.4, 0.4, 0.08), STEEL_DARK, tile=1.0)


def _ac_z(parts, pos):
    x, y, z = pos
    box(parts, "ac", (x, y, z + 0.2), (0.7, 0.5, 0.4), STEEL_LIGHT, tile=1.0)
    cyl(parts, "ac_fan", (x, y, z + 0.42), 0.18, 0.04, STEEL_DARK, tile=1.0, axis="z")


def _ac_x(parts, pos):
    x, y, z = pos
    box(parts, "ac", (x + 0.2, y, z), (0.4, 0.5, 0.7), STEEL_LIGHT, tile=1.0)
    cyl(parts, "ac_fan", (x + 0.42, y, z), 0.18, 0.04, STEEL_DARK, tile=1.0, axis="x")

# ---------------------------------------------------------------- buildings
def build_building_a():
    """Ochre chawl, 20x7x3 at (-4, 3.5, -7.5). Front faces +Z (toward the lane)."""
    parts = []
    conc = tex_mat("concrete")
    brick = tex_mat("brick_ochre")
    box(parts, "mass", (-4, 3.5, -7.5), (20, 7, 3), brick, tile=2.0, bevel=0.05)
    box(parts, "plinth", (-4, 0.25, -7.5), (20.3, 0.5, 3.3), conc, tile=2.0)
    for (px, pz, sx, sz) in [(-4, -6.05, 20.2, 0.15), (-4, -8.95, 20.2, 0.15),
                             (-14.05, -7.5, 0.15, 3.2), (6.05, -7.5, 0.15, 3.2)]:
        box(parts, "parapet", (px, 7.25, pz), (sx, 0.5, sz), conc, tile=2.0)
    for x in [-12.0, -8.0, -4.0, 0.0]:
        _window(parts, (x, 2.2, -6), "z", lit=(x in (-8.0, 0.0)))
    for x in [-10.0, -6.0, -2.0, 2.0]:
        _window(parts, (x, 5.0, -6), "z", lit=(x == -2.0))
    for x in [-8.0, 0.0]:
        _balcony_z(parts, (x, 4.2, -6))
    for x in [-10.0, 2.0]:
        _ac_z(parts, (x, 4.2, -6))
    cyl(parts, "pipe", (-13.5, 3.5, -5.95), 0.06, 7.0, STEEL_DARK, tile=1.0)
    cyl(parts, "pipe", (5.5, 3.5, -5.95), 0.06, 7.0, STEEL_DARK, tile=1.0)
    cyl(parts, "pipe_h", (-4, 0.6, -5.95), 0.05, 20.0, STEEL_DARK, tile=1.0, axis="x")
    teal = flat_mat("teal", (0.12, 0.54, 0.50), rough=0.7)
    box(parts, "door_frame", (-12, 1.15, -5.98), (1.3, 2.3, 0.12), conc, tile=1.0)
    # Panel sits proud of the frame's front, or the frame swallows it.
    box(parts, "door", (-12, 1.05, -5.90), (1.1, 2.1, 0.06), teal, tile=1.0)
    box(parts, "door_step", (-12, 0.07, -5.8), (1.4, 0.15, 0.5), conc, tile=1.0)
    cyl(parts, "tank", (-8, 7.9, -7.5), 0.9, 1.2, tex_mat("plaster"), tile=2.0)
    cyl(parts, "tank_lid", (-8, 8.55, -7.5), 0.95, 0.08, STEEL_DARK, tile=1.0)
    for dx, dz in [(-0.7, -0.7), (0.7, -0.7), (-0.7, 0.7), (0.7, 0.7)]:
        box(parts, "tank_leg", (-8 + dx, 7.35, -7.5 + dz), (0.1, 0.3, 0.1), STEEL_DARK, tile=1.0)
    return parts


def build_building_b():
    """Faded red chawl, 3x6x20 at (-7.5, 3, -4). Front faces +X (toward the lane)."""
    parts = []
    conc = tex_mat("concrete")
    brick = tex_mat("brick_red")
    box(parts, "mass", (-7.5, 3.0, -4), (3, 6, 20), brick, tile=2.0, bevel=0.05)
    box(parts, "plinth", (-7.5, 0.25, -4), (3.3, 0.5, 20.3), conc, tile=2.0)
    for (px, pz, sx, sz) in [(-7.5, -14.05, 3.2, 0.15), (-7.5, 6.05, 3.2, 0.15),
                             (-9.05, -4, 0.15, 20.2), (-5.95, -4, 0.15, 20.2)]:
        box(parts, "parapet", (px, 6.25, pz), (sx, 0.5, sz), conc, tile=2.0)
    for z in [-12.0, -8.0, -4.0, 0.0]:
        _window(parts, (-6, 2.2, z), "x", lit=(z == -8.0))
    for z in [-10.0, -6.0, -2.0, 2.0]:
        _window(parts, (-6, 4.6, z), "x", lit=(z == -2.0))
    for z in [-8.0, 0.0]:
        _balcony_x(parts, (-6, 3.8, z))
    for z in [-10.0, 2.0]:
        _ac_x(parts, (-6, 4.2, z))
    cyl(parts, "pipe", (-5.95, 3.0, -13.5), 0.06, 6.0, STEEL_DARK, tile=1.0)
    cyl(parts, "pipe", (-5.95, 3.0, 5.5), 0.06, 6.0, STEEL_DARK, tile=1.0)
    cyl(parts, "pipe_h", (-5.95, 0.6, -4), 0.05, 20.0, STEEL_DARK, tile=1.0, axis="z")
    # Corner shop: green shutter + yellow signboard on the east face.
    wood = tex_mat("wood")
    box(parts, "shutter", (-5.93, 1.2, 1.5), (0.1, 2.4, 2.2), wood, tile=1.0)
    sign_yellow = flat_mat("sign_yellow", (0.91, 0.73, 0.24), rough=0.8)
    box(parts, "signboard", (-5.93, 2.8, 1.5), (0.1, 0.5, 2.4), sign_yellow, tile=1.0)
    # Awning over the shop, sloping down away from the wall.
    box(parts, "awning", (-5.35, 3.25, 1.5), (1.2, 0.06, 2.6), flat_mat("awning_red", (0.55, 0.2, 0.16), rough=0.85),
        tile=1.0, rot_godot=(0, 0, -0.35))
    return parts


# ---------------------------------------------------------------- streetlight / tree / auto
def build_streetlight():
    """Local frame: origin at the base, arm reaches toward -X (the road)."""
    parts = []
    cyl(parts, "base", (0, 0.15, 0), 0.12, 0.3, STEEL_DARK, tile=1.0)
    cyl(parts, "pole", (0, 2.5, 0), 0.07, 5.0, STEEL_DARK, tile=1.0)
    # Elbow: a Y-cylinder rotated 45 deg about Godot Z (axis toward -X/up).
    elbow = cyl(parts, "elbow", (-0.18, 4.95, 0), 0.05, 0.5, STEEL_DARK, tile=1.0)
    elbow.rotation_euler = _rot_godot_to_blender((0, 0, math.pi / 4))
    cyl(parts, "arm", (-0.55, 5.15, 0), 0.05, 0.7, STEEL_DARK, tile=1.0, axis="x")
    box(parts, "lamp_head", (-0.85, 5.1, 0), (0.45, 0.1, 0.22), STEEL_DARK, tile=1.0)
    lamp = flat_mat("lamp_glass", (1.0, 0.8, 0.5), rough=0.4,
                    emission=(1.0, 0.8, 0.5), emission_strength=3.0)
    box(parts, "lamp_glass", (-0.85, 5.04, 0), (0.4, 0.02, 0.18), lamp, tile=1.0)
    return parts


def build_tree():
    """Local frame: origin at the base. Trunk + 4 foliage blobs."""
    parts = []
    cyl(parts, "trunk", (0, 1.25, 0), 0.16, 2.5, tex_mat("bark"), tile=1.0)
    leaves = tex_mat("leaves")
    # Irregular canopy: many small blobs, wider than tall, not one sphere.
    for (bx, by, bz, br, sx, sy, sz) in [
        (0, 3.3, 0, 0.9, 1.4, 0.7, 1.3),
        (0.9, 3.0, 0.3, 0.7, 1.3, 0.65, 1.1),
        (-0.85, 3.1, -0.25, 0.7, 1.2, 0.7, 1.2),
        (0.1, 3.9, 0.1, 0.6, 1.1, 0.7, 1.0),
        (-0.3, 2.9, 0.7, 0.55, 1.2, 0.65, 1.0),
        (0.5, 3.5, -0.6, 0.6, 1.2, 0.7, 1.1),
        (-1.1, 3.3, 0.4, 0.55, 1.1, 0.65, 1.0),
        (1.2, 3.4, -0.3, 0.55, 1.1, 0.65, 1.0),
        (0, 3.6, 0.5, 0.5, 1.1, 0.65, 1.0),
    ]:
        blob(parts, "canopy", (bx, by, bz), br, leaves, scale=(sx, sy, sz))
    return parts


def build_auto():
    """Kaali-peeli auto, local frame: origin at ground centre, faces +X."""
    parts = []
    yellow = flat_mat("auto_yellow", (0.94, 0.75, 0.13), rough=0.35)
    tyre = flat_mat("tyre", (0.08, 0.08, 0.08), rough=1.0)
    lamp = flat_mat("headlight", (1.0, 0.85, 0.6), rough=0.3,
                    emission=(1.0, 0.85, 0.6), emission_strength=2.0)
    box(parts, "body", (0, 0.55, 0), (3.2, 0.55, 1.7), yellow, tile=1.0, bevel=0.06)
    box(parts, "skirt", (0, 0.3, 0), (3.2, 0.25, 1.75), STEEL_DARK, tile=1.0)
    box(parts, "cabin", (-0.2, 1.05, 0), (1.8, 0.5, 1.5), yellow, tile=1.0, bevel=0.08)
    # Canopy roof: near-black, matte — a lit-up grey roof reads wrong.
    canopy = flat_mat("canopy", (0.05, 0.05, 0.05), rough=0.9, metallic=0.0)
    box(parts, "roof", (-0.2, 1.32, 0), (1.9, 0.08, 1.55), canopy, tile=1.0)
    # Windshield: thin in X, leans back (top toward -X).
    box(parts, "windshield", (0.72, 1.05, 0), (0.05, 0.7, 1.4), GLASS_DARK, tile=1.0,
        rot_godot=(0, 0, 0.5))
    box(parts, "sidewin_l", (-0.2, 1.05, 0.76), (1.6, 0.4, 0.04), GLASS_DARK, tile=1.0)
    box(parts, "sidewin_r", (-0.2, 1.05, -0.76), (1.6, 0.4, 0.04), GLASS_DARK, tile=1.0)
    for wx in [-1.1, 1.1]:
        for wz in [-0.8, 0.8]:
            torus(parts, "tyre", (wx, 0.42, wz), 0.32, 0.1, tyre, tile=1.0)
            cyl(parts, "hub", (wx, 0.42, wz), 0.18, 0.08, STEEL_LIGHT, tile=1.0, axis="z")
    box(parts, "headlight_l", (1.62, 0.6, 0.5), (0.06, 0.12, 0.25), lamp, tile=1.0)
    box(parts, "headlight_r", (1.62, 0.6, -0.5), (0.06, 0.12, 0.25), lamp, tile=1.0)
    box(parts, "bumper_f", (1.65, 0.35, 0), (0.08, 0.12, 1.7), STEEL_DARK, tile=1.0)
    box(parts, "bumper_r", (-1.65, 0.35, 0), (0.08, 0.12, 1.7), STEEL_DARK, tile=1.0)
    box(parts, "grille", (1.62, 0.45, 0), (0.05, 0.2, 0.9), STEEL_DARK, tile=1.0)
    return parts


# ---------------------------------------------------------------- main
def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()
    for block in bpy.data.meshes:
        if block.users == 0:
            bpy.data.meshes.remove(block)


def main():
    _flat_mats()
    clear_scene()
    export_model(build_building_a(), os.path.join(OUT, "building_a.glb"))
    clear_scene()
    export_model(build_building_b(), os.path.join(OUT, "building_b.glb"))
    clear_scene()
    export_model(build_streetlight(), os.path.join(OUT, "streetlight.glb"))
    clear_scene()
    export_model(build_tree(), os.path.join(OUT, "tree.glb"))
    clear_scene()
    export_model(build_auto(), os.path.join(AUTO_OUT, "auto.glb"))
    print("ALL MODELS DONE")


if __name__ == "__main__":
    main()
