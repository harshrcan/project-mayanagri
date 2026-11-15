#!/usr/bin/env python3
"""Build Vee, the player character, in Blender — a proper GTA V-like
humanoid (real proportions, face, hair, clothes, shoes), not the old
blocky placeholder.

Run:  blender --background --python tools/build_vee.py
Writes: characters/vee.glb

The model faces -Z (Godot forward). Animation pivots are empty nodes
named LegL_pivot / LegR_pivot / ArmL_pivot / ArmR_pivot (the head and
torso are children of Torso_pivot); characters/vee_placeholder.gd
finds them by name and drives the same procedural walk/run/jump/punch
poses as before. All geometry is original, modelled here.
"""
import bpy
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "characters", "vee.glb")


def G(p):
    """Godot (x, y, z) -> Blender (x, -z, y). Works for positions and
    for relative offsets (it is a linear map)."""
    return (p[0], -p[2], p[1])


def GS(s):
    """Godot size (sx, sy, sz) -> Blender (sx, sz, sy)."""
    return (s[0], s[2], s[1])


_mats = {}


def flat_mat(name, color, rough=0.85, metallic=0.0):
    if name in _mats:
        return _mats[name]
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metallic
    _mats[name] = m
    return m


def box(parent, name, pos, size, mat, bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(location=G(pos))
    o = bpy.context.active_object
    o.name = name
    o.dimensions = GS(size)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.data.materials.append(mat)
    if bevel > 0:
        mod = o.modifiers.new("bev", "BEVEL")
        mod.width = bevel
        mod.segments = 2
    if parent is not None:
        o.parent = parent
    return o


def cone(parent, name, pos, r_bottom, r_top, height, mat, segments=10):
    bpy.ops.mesh.primitive_cone_add(radius1=r_bottom, radius2=r_top,
                                    depth=height, vertices=segments, location=G(pos))
    o = bpy.context.active_object
    o.name = name
    o.data.materials.append(mat)
    if parent is not None:
        o.parent = parent
    return o


def cyl(parent, name, pos, radius, height, mat, segments=10):
    return cone(parent, name, pos, radius, radius, height, mat, segments)


def sphere(parent, name, pos, radius, mat, scale=(1, 1, 1)):
    bpy.ops.mesh.primitive_uv_sphere_add(radius=radius, location=G(pos),
                                         segments=20, ring_count=14)
    o = bpy.context.active_object
    o.name = name
    o.scale = GS(scale)
    o.data.materials.append(mat)
    if parent is not None:
        o.parent = parent
    return o


def pivot(parent, name, pos):
    bpy.ops.object.empty_add(type="PLAIN_AXES", location=G(pos))
    o = bpy.context.active_object
    o.name = name
    if parent is not None:
        o.parent = parent
    return o


def build():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()

    skin = flat_mat("skin", (0.78, 0.54, 0.38), rough=0.7)
    shirt = flat_mat("shirt", (0.18, 0.44, 0.70), rough=0.9)
    pants = flat_mat("pants", (0.25, 0.27, 0.36), rough=0.95)
    hair_m = flat_mat("hair", (0.08, 0.08, 0.08), rough=0.9)
    shoe_m = flat_mat("shoe", (0.12, 0.11, 0.10), rough=0.6)
    dark = flat_mat("dark", (0.05, 0.05, 0.05), rough=0.5)
    belt_m = flat_mat("belt", (0.16, 0.12, 0.09), rough=0.7)

    # --- legs (hip pivots at y 0.85, feet on the ground) ---
    for side, sx in [("L", -1), ("R", 1)]:
        leg = pivot(None, f"Leg{side}_pivot", (sx * 0.11, 0.85, 0))
        cone(leg, f"Thigh{side}", (0, -0.21, 0), 0.075, 0.095, 0.42, pants)
        cone(leg, f"Shin{side}", (0, -0.62, 0), 0.055, 0.07, 0.40, pants)
        # Shoe: toe forward (-Z), sole on y 0.
        box(leg, f"Shoe{side}", (0, -0.81, -0.04), (0.11, 0.08, 0.28), shoe_m, bevel=0.02)

    # --- torso (pivot at the hips so the whole upper body can lean) ---
    torso = pivot(None, "Torso_pivot", (0, 0.85, 0))
    box(torso, "Torso", (0, 0.28, 0), (0.46, 0.55, 0.26), shirt, bevel=0.03)
    box(torso, "Belt", (0, 0.02, 0), (0.47, 0.06, 0.27), belt_m, bevel=0.01)
    # Collar: a flattened torus around the neck. The default torus lies
    # in the Blender X-Y plane, which is the Godot X-Z (horizontal) plane.
    bpy.ops.mesh.primitive_torus_add(major_radius=0.09, minor_radius=0.02,
                                     location=G((0, 0.56, 0)))
    collar = bpy.context.active_object
    collar.name = "Collar"
    collar.data.materials.append(shirt)
    collar.parent = torso

    # --- head (pivot at the neck, y 1.45) ---
    head = pivot(torso, "Head_pivot", (0, 0.60, 0))
    sphere(head, "Skull", (0, 0.10, 0), 0.115, skin, scale=(1.0, 1.15, 1.05))
    box(head, "Jaw", (0, 0.03, -0.02), (0.16, 0.10, 0.14), skin, bevel=0.02)
    box(head, "Nose", (0, 0.08, -0.11), (0.03, 0.06, 0.04), skin, bevel=0.01)
    sphere(head, "EarL", (-0.11, 0.10, 0), 0.03, skin)
    sphere(head, "EarR", (0.11, 0.10, 0), 0.03, skin)
    sphere(head, "EyeL", (-0.04, 0.12, -0.118), 0.015, dark)
    sphere(head, "EyeR", (0.04, 0.12, -0.118), 0.015, dark)
    box(head, "BrowL", (-0.04, 0.155, -0.118), (0.05, 0.015, 0.015), hair_m)
    box(head, "BrowR", (0.04, 0.155, -0.118), (0.05, 0.015, 0.015), hair_m)
    # Hair: cap over the top/back of the skull + a fringe on the forehead.
    sphere(head, "Hair", (0, 0.14, 0.02), 0.12, hair_m, scale=(1.02, 0.9, 1.05))
    box(head, "Fringe", (0, 0.17, -0.09), (0.2, 0.06, 0.05), hair_m, bevel=0.01)

    # --- arms (shoulder pivots at y 1.35) ---
    for side, sx in [("L", -1), ("R", 1)]:
        arm = pivot(torso, f"Arm{side}_pivot", (sx * 0.29, 0.50, 0))
        cone(arm, f"UpperArm{side}", (0, -0.14, 0), 0.05, 0.058, 0.28, shirt)
        cone(arm, f"Forearm{side}", (0, -0.40, 0), 0.042, 0.05, 0.26, skin)
        box(arm, f"Hand{side}", (0, -0.58, 0), (0.07, 0.12, 0.045), skin, bevel=0.015)
        box(arm, f"Thumb{side}", (sx * -0.045, -0.55, -0.01), (0.02, 0.05, 0.02), skin, bevel=0.008)

    bpy.ops.export_scene.gltf(filepath=OUT, export_format="GLB")
    print("exported", OUT)


if __name__ == "__main__":
    build()
