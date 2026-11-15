# Step 2 — Lock the look: one Dharavi street corner

**Status: BUILT — awaiting Harsh's lock (is this a screenshot you'd post?).**
Date: 2026-11-15. Plan §10 step 2. Check: *a screenshot you would post.*
Shot: `docs/step2_shot.png` (1280×720, rendered in this VM).

## 1. Spec (plain words)

One street corner in Dharavi at golden evening. The whole game’s art
direction gets decided here — if this frame doesn’t look like the game we
want, nothing downstream is right yet.

**What the frame must contain:**
- A chai stall: counter, kettle steaming, rows of small glasses, a hand-
  lettered signboard (invented name, Hindi + English), a warm tube light
  glowing over it, a couple of stools.
- A parked auto rickshaw: black-and-yellow (kaali-peeli) style, three
  wheels, canopy, headlight off, slightly angled as if the driver just
  stepped away.
- Street corner: two chawl-style buildings meeting at the corner — tin
  roofs, painted shutters (teal, ochre, rust red), washing line, a
  political-style poster for an *invented* party, tangled wires overhead.
- Ground: narrow lane with a drain edge, a few scattered props (crate,
  bucket, bicycle leaning on a wall), string lights across the lane.

**Light (the whole point of this step):**
- Low warm evening sun from the west, long shadows down the lane.
- Sky: warm orange near the horizon fading to dusky blue; light fog so the
  far end of the lane melts away.
- The stall’s tube light is the second light source — warm pool of light
  on the counter, everything else falling into evening blue.
- Post effects: glow/bloom on the lights, warm colour grade. Quality
  slider comes at Step 10; the grade itself is decided here.

**Palette (Mumbai colour, flat low-poly):** teal shutters, ochre walls,
rust tin, warm yellow stall light, deep blue evening shadows. No textures
yet — flat colours carry the look; painted textures and the modular kit
come with the district build. If it looks good flat, it will look great
textured.

## 2. How it will be built

- `world/dharavi_corner.tscn` — the corner scene (replaces the Step 1
  placeholder as the main scene once it runs).
- `world/chai_stall.tscn` — the stall as its own scene, so later districts
  reuse it.
- `vehicles/auto.tscn` — the parked auto as its own scene; Step 4 (vehicles)
  reuses it and adds driving. No physics yet — it is parked.
- Primitive meshes + `StandardMaterial3D` flat colours, roughness 1.
  No imported models in this step; Blender kit starts after the look is locked.
- `WorldEnvironment`: procedural sky, fog, tonemap + glow. One
  `DirectionalLight3D` (sun, shadows on) + 1–2 `PointLight3D` at the stall.
- One fixed camera angle for the check shot, framed like a film still:
  stall on the left, auto on the right, lane leading away between buildings.

## 3. Verification (Step 2 check)

- Headless import + run: exit 0, zero errors, zero missing references.
- **Screenshot:** try `xvfb-run` + a small capture script in this VM
  (`get_viewport().get_texture().get_image().save_png`). If this VM cannot
  render (no GPU/Xvfb), say so explicitly and move the screenshot check to
  Harsh’s laptop — never fake the check. The check is “a screenshot you
  would post”, and only Harsh can judge that.
- Harsh looks at the shot and either locks the look or lists what to change
  (light angle, colours, composition). No Step 3 until he locks it.

## 4. Notes / decisions deferred

- Building kit (40 pieces) and textures: after the look is locked.
- The auto’s exact parody name: pick when the vehicle data files land
  (Step 4). For now it is just “the auto”.
- Monsoon/wet-road variant of the corner: later step, not this one.

## 5. Build notes (what actually got built)

- `world/prim.gd` — shared primitive builders + material cache (one
  StandardMaterial3D per colour, so the corner shares a handful of materials).
- `vehicles/auto.gd` — parked auto, faces +X, own file so Step 4 reuses it.
- `world/chai_stall.gd` — "Amrut Chai" stall (invented name), own file so
  later districts reuse it. Signboard text via Label3D (English only —
  Hindi lettering needs a Devanagari font, a later pass).
- `world/dharavi_corner.gd` + `world/dharavi_corner.tscn` — the corner;
  now the project's main scene. Ground + buildings carry StaticBody3D
  collision already (Step 3 needs it).
- Screenshot path: `world/dharavi_corner.gd:_take_screenshot()` — run with
  `-- --shot` under Xvfb, saves `docs/step2_shot.png` after 10 frames.
  Rendered here with Mesa llvmpipe (software GL, OpenGL 4.5) — no GPU in
  this VM. ALSA/V-Sync warnings in that run are VM environment noise
  (no sound card / no display), not game errors.

## 6. Verification + iterations

- Headless import + run: exit 0, zero script errors (one real bug caught
  and fixed by the check: `PointLight3D` does not exist in Godot 4 —
  it is `OmniLight3D`).
- 4 screenshot iterations, each judged from the actual render:
  1. Everything worked, but the frame drowned in orange; sign text
     overflowed its board; auto read as a black box.
  2. Fog 0.012→0.008, darker ground, bigger plane, sign text resized,
     auto turned to front 3/4. Better, still monochrome orange; horizon
     line still visible.
  3. Deeper blue sky top, stronger wall colours, fog 0.01, 120 m ground
     plane, smaller roof overhangs, handcart added. Horizon line gone,
     but orange wash persisted.
  4. **Fix that worked: ambient switched from sky to a cool blue colour
     (#66779a, 0.5) — warm sun + cool shadows.** Palette finally
     separates: ochre vs brick-red walls, green shutter, yellow auto,
     warm stall glow. This is the shot in `docs/step2_shot.png`.
- Known remaining nits (not look-blocking, for later steps): roofs read
  as flat dark slabs from this angle (textures/parapets later); washing
  cloths are small; foreground is mostly empty road.
- **Step 2 check is Harsh's call:** only he can say if the shot is one
  he'd post. If he locks it, Step 3 (player controller) starts. If not,
  he lists what to change and it gets one more pass.

## 7. Direction change — GTA San Andreas graphics (2026-11-15)

Harsh locked the flat-colour look ("go ahead"), then redirected:
**graphics like GTA San Andreas**, and **size doesn't matter**
("dont care about size"). So the flat-colour look above is SUPERSEDED,
not locked any more. What changes for this corner:

- Flat colours → real textures: brick/plaster walls with windows,
  shutters, grime; road with lane markings and patches; pavement slabs.
- Density: more props per metre (bins, crates, wires, posters, plants),
  the way SA streets are cluttered, not clean.
- Light stays warm and hazy, but the haze becomes SA-style draw-distance
  fog rather than a colour wash.
- Size targets from the plan (~1 GB PC, <500 MB Android) no longer
  constrain the graphics work.
- Textures are painted by hand / CC0 (same licence rules — every texture
  gets a row in `docs/ASSET_LICENCES.md`). No textures ripped from SA
  itself — that would be Rockstar's art, not ours.

Open question: **original 2004 SA or Definitive Edition?** The 2004
look is low-res textures + heavy haze (PS2-era); the Definitive Edition
is sharper textures + bright blue skies + cleaner light. References
pulled 2026-11-15 (kept outside the repo — Rockstar screenshots, not
ours to commit): `~/workspace/sa_ref_original.jpg`,
`~/workspace/sa_ref_de.jpg`.

**PICKED 2026-11-15: Definitive Edition.** The rework spec:

- Textures, all procedural and generated by `tools/make_textures.py`
  into `world/textures/` (256×256, tileable, ours — no SA art ripped):
  brick ochre + brick red, plaster, asphalt, pavement slabs, corrugated
  rust tin, wood planks, soft cloud.
- Density: streetlight with a warm lamp, trash bags, brick stack, water
  drum, potted plants, two more invented posters, extra wires, dashed
  centre line on the road.
- Light (DE): brighter blue sky top, warm horizon, clouds, fog
  0.01 → 0.006 (DE's long view distance), sun 1.2 → 1.3, cool ambient
  0.5 → 0.55. Same golden evening, cleaner air.
- The corner gets its texture/density pass once Harsh picks.

**DE rework built 2026-11-15 (this section):**

- Generator `tools/make_textures.py` (numpy + PIL, run it to regenerate):
  8 tileable 256×256 PNGs in `world/textures/` — brick ochre/red,
  plaster, asphalt, pavement, tin, wood, cloud. All original procedural
  work, ours. (First tin pass had rust blobs like red paint — fixed by
  raising the rust threshold and blending instead of replacing.)
- `world/prim.gd` now takes a Color OR a Material on every shape helper,
  plus `Prim.tmat()` (textured material cache with UV scale) and
  `Prim.cloud_mat()`. UV scale rule: tile ≈ 2 m on walls, 4 m on asphalt,
  1 m on pavement.
- Corner changes: brick walls, tin roofs, plaster water tank, wood
  shutter/counter/crates/cart, asphalt road, pavement sidewalk, dashed
  centre line, streetlight + warm lamp, trash bags, brick stack, water
  drum, potted plants, two invented posters (MAYANAGRI NIGHTS, CHAI PE
  CHARCHA), extra wires, 3 cloud banks. Light: sun 1.3, fog 0.006,
  ambient 0.6, sky top brighter blue.
- 3 screenshot iterations: (1) textures in, but building B's shaded face
  nearly black and the horizon seam visible; (2) brick_red lightened,
  sky ground band matched to fog, ambient 0.6 — seam gone, B readable;
  (3) clouds lowered into frame. Shot: `docs/step2_shot_de.png`
  (fixed camera) + `docs/step3_shot.png` (gameplay view, re-shot with
  the new look). Headless run clean; player tests still 15/15 PASS.
- **DE check is Harsh's:** lock it and Step 4 (vehicles) starts; or
  list what to change.

## 8. Direction change #2 — modern good 3D, not retro SA (2026-11-15)

Harsh rejected the DE rework: "no real gta san andreas like graphics
like 3d and all good great graphics". Read plainly: he does NOT want
the game to look like actual San Andreas (dated PS2-era geometry,
even the Definitive Edition). He wants proper modern 3D graphics —
the SA part is the world and gameplay (open streets, cars, third
person), not the look. The DE rework above is SUPERSEDED, kept in git
history only (commit e93116f). The procedural texture set stays useful
— a modern look still needs textures — but the corner must be rebuilt
the modern way: Blender-modelled buildings (window frames, balconies,
parapets, AC units, pipes) instead of textured boxes, detailed
vehicles and props, better lighting/shadows, a rigged character
instead of the primitive Vee.

Open question: **realistic-modern (GTA V style) or stylized-modern
(No Straight Roads 2 style)?** References pulled 2026-11-15 (kept
outside the repo): `~/workspace/ref_gta5.jpg`,
`~/workspace/ref_stylized.jpg`. The new look test starts once Harsh
picks.

**PICKED 2026-11-15: realistic, GTA V style.** The rebuild spec
(Step 2 v3):

- Blender-modelled, not primitives: `tools/build_dharavi.py` builds
  Building A + B (window frames + sills + glass, balconies with
  railings, parapets, AC units, pipes, plinth, teal door, water tank,
  shop awning), a streetlight with a curved arm, a tree, and a
  detailed auto — exported as `.glb` to `world/models/` +
  `vehicles/auto.glb`. Bevels on the main masses so edges catch
  light. UVs by cube projection (2 m tiles on walls).
- Textures upgraded to 512px with more detail (grime, cracks,
  patches) + new concrete, leaves, bark. Still procedural, still
  ours.
- Godot side: the `.glb` files are the visuals; invisible collision
  boxes keep the player out of the walls (same footprints as before,
  so the layout and the Step 3 tests don't move). Small props
  (stall, crates, sacks, drum, plants, posters, dashes) stay
  Prim-based for this pass. The primitive Vee stays for this pass
  too — the environment is the deliverable; a modelled character is
  the next modelling task.
- Light stays golden evening (sun 1.3, fog 0.006, ambient 0.6) —
  the realism comes from geometry + textures, not a new time of day.
- Check: fixed shot + gameplay shot read as a modern 3D street,
  not a textured box diorama.

### Realistic rebuild — BUILT 2026-11-15 (5 iterations)

- **Iteration 1:** models in, shot reads as a real street (frames,
  balconies, AC, parapet, tree, detailed auto) — but the windows
  were flat grey, the auto pale green-yellow, the tree a smooth blob.
- **Iteration 2:** glass metallic 0.3→0 (it was mirroring the sky),
  sun elevation −16°→−28°, ambient 0.6→0.7, tree made irregular.
  Windows went dark, but the lit ones still didn't glow and the
  auto's roof read light grey.
- **Iteration 3:** ambient warmed (`#66779a`→`#7a7f92`, the blue
  ambient was turning the yellow auto green), sun 1.3→1.5,
  steel metallic 0.4→0.1, tree rebuilt as 9 smaller blobs, leaves
  darkened. Auto reads yellow; roof still light.
- **Iteration 4:** roof given a near-black matte canopy material.
  Shot looked unchanged — **lesson: Godot caches .glb imports; after
  re-exporting a .glb you must re-run `--headless --editor --quit
  --import` before the runtime sees the new model.**
- **Iteration 5 (the bug):** the lit windows still didn't glow. The
  .glb JSON proved the emission was exported correctly — the real
  bug was geometry: the window "frame" was a SOLID box and the glass
  sat inside it, invisible. Real windows now: glass on the wall,
  frame as 4 bars proud of it, sill below. Same fix for the teal
  door (panel moved proud of its frame). Windows now show dark glass
  + warm lit glass with real frames.
- **Final shots:** `docs/step2_shot_realistic.png` (fixed camera) and
  `docs/step3_shot.png` (gameplay view, re-shot). Verification:
  headless import clean, headless run exit 0 (`Dharavi corner
  ready.`), player tests 15/15 PASS.
- **Still placeholder / known gaps:** Vee is still the primitive
  blocky figure (reads out of place next to the realistic corner —
  a modelled character is the next modelling task); the tree is
  still blobby up close (stylized, needs leaf-card work later); the
  chai stall is still Prim-based; lit windows glow white-ish rather
  than warm orange under ACES.
- **Gate:** Harsh's verdict — lock it (then Step 4 vehicles) or list
  changes.

### Graphics push — GTA V-like character + skyline (2026-11-15)

Harsh asked for "better real gta v like character n graphics" after
the realistic look test. Two things changed:

- **Character:** the blocky placeholder Vee was replaced by a
  Blender-modelled humanoid (`tools/build_vee.py` →
  `characters/vee.glb`, see `docs/STEP3_PLAYER.md` §7). Same
  animation API, same controller.
- **Graphics:** the horizon was empty brown. Added a distant Mumbai
  skyline (`_build_skyline()` in `world/dharavi_corner.gd`): 16
  dark buildings (10–22 m) ringing the corner at 55–70 m, a few lit
  windows, fog-hazed. Iteration 1 put them at 45–58 m in
  `#2e3440` — they read as giant sunlit cardboard boxes looming
  over the chawls. Iteration 2: pushed to 55–70 m, darker
  `#262b36`, heights capped at 22 m, ground plane widened 120→200 m
  so they stand on ground, fog 0.006→0.008. They now read as a
  distant city. Also added: a second tree on the west sidewalk, a
  bicycle leaning on building B, softer sun shadows
  (`shadow_blur` 1.0, max distance 150) and a dim cool fill light
  from the east (0.2, no shadows).
- Shots: `docs/step2_shot_realistic.png` + `docs/step3_shot.png`
  (re-shot). Verification: import clean, headless run exit 0,
  player tests 15/15 PASS.
- **Gate:** still Harsh's verdict — lock the look (then Step 4
  vehicles) or list changes.
