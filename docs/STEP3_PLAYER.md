# Step 3 — Player: third-person controller + camera

**Status: BUILT — awaiting Harsh's playtest (feel check is his).**
Date: 2026-11-15. Plan §10 step 3. Check: *moving around feels good.*
Harsh locked the Step 2 look ("go ahead", 2026-11-15).

## 1. Spec (plain words)

Vee walks around the Dharavi corner. Third-person camera behind and above
him, mouse to look around, WASD to move, Shift to run, Space to jump,
left mouse (or F) to punch. The character turns toward where he's running.
The camera doesn't clip through walls — a spring arm pulls it in when a
building is behind him. Everything must feel responsive: he speeds up
quickly, stops quickly, jumps the moment you press Space.

**Numbers (tuned for feel, verified by the test harness):**
- Walk 4 m/s, run 7 m/s. Acceleration snappy on ground, weaker in air.
- Gravity 20 (snappier than real 9.8 — games cheat here), jump velocity 7
  (about a 1.2 m jump — enough to hop a crate, not fly).
- Camera: 4.5 m behind, orbit with mouse, pitch clamped so you can't flip
  under the floor or over the top.

**Controls:**
- W/A/S/D or arrows — move (relative to camera direction)
- Shift — run
- Space — jump
- Left mouse / F — punch (0.35 s swing, short cooldown; nothing to hit
  yet — citizens arrive in Step 6, the swing + signal are ready now)
- Click the game window to capture the mouse, Esc releases it.

**How input is defined:** actions are created at runtime by the player
script (`InputMap` in `player.gd`), not hand-written into `project.godot`
— the serialized `InputEventKey` format is fragile to write by hand, and
runtime setup is deterministic and testable. (If a later step wants
editor-visible actions, they can be moved into `project.godot` then.)

## 2. How it is built

- `characters/player.gd` — `CharacterBody3D`, capsule collision, all the
  movement math. The visual is a child node, so the mesh can be swapped
  without touching movement.
- `characters/player.tscn` — body + `SpringArm3D` + `Camera3D`.
  The camera is a child of the spring arm, which is a child of a yaw pivot
  on the player — camera orbits the player, never the other way round.
- `characters/vee_placeholder.gd` — a simple stylized figure built from
  primitives (blue shirt, head, swinging legs/arms, punching right arm).
  Placeholder on purpose: the controller must not depend on the mesh.
  A rigged character + Mixamo-style animations replace this visual later
  (see §4) — movement code does not change when that happens.
- The Dharavi corner spawns the player at the south end of the lane
  (0, 0.12, 8), facing the corner. The fixed shot camera is only used
  for `--shot` screenshots; in normal play the player camera is current.
- `characters/player_test.gd` + `characters/test_player.tscn` — headless
  test harness: drives the player with synthetic input and asserts walk
  speed, run speed, jump height/landing, punch timing, and camera yaw.
  Prints PASS/FAIL per check and quits with a non-zero code on failure.

## 3. Verification (Step 3 check)

- Headless import + run of the main scene: exit 0, zero script errors.
- Test harness: all assertions PASS (see §5).
- Fresh screenshot with Vee standing in the corner (`docs/step3_shot.png`).
- **Feel check is Harsh's:** only he can say if moving around feels good.
  He plays it on his laptop (Godot 4.7.2 → open project → run) and reports
  back; tuning numbers live at the top of `player.gd` so a fix is one edit.

## 4. Rigged character (plan asked for one — status)

Attempted in this step, time-boxed. Found a solid CC0 candidate:
Quaternius "Casual Female" + "Casual Male" (Ultimate Animated Characters
pack) — 17 clips each, skinned, ~1.75 m, material colours, via the Cinevva
catalog (see `docs/ASSET_LICENCES.md` for the full row). The direct CDN
fetch failed in this environment (the page reader cannot extract a binary
file) — NOT downloaded, NOT in the project. **Placeholder stands.**
The visual swap is a character-system task: download the pack from
quaternius.com on a machine with a browser, verify the clips
(idle/walk/run/jump) in Blender, then wire the AnimationPlayer in as
Vee's visual — Vijay = Casual Male, Vidya = Casual Female is the natural
pair. Kenney "Mini Characters" are the second choice (32 clips, but chibi
~0.78 m proportions — wrong scale for Vee). Mixamo was ruled out (needs an
Adobe account, not CC0).

## 5. Build notes / verification evidence

- Headless import: clean, zero errors/warnings. Headless run of the main
  scene: exit 0, prints `[Mayanagri] Dharavi corner ready.`
- Test harness `characters/player_test.gd`: **15/15 PASS**, exit 0.
  Measured: walk 2 s = 7.56 m (spec 4 m/s), run 2 s = 13.91 m (7 m/s),
  jump peak 1.28 m and lands back on the floor, punch triggers/ends/
  repeats, camera current, 4.5 m behind (measured 4.78 m from feet —
  spring 4.5 minus 0.3 margin, pivot 1.6 m up), yaw/pitch move and pitch
  clamps at 0.9.
- **Real bug caught by the screenshot check:** the first player shot
  showed Vee falling through the world — the ground was a visual-only
  `Prim.plane()` with no collision. Fixed by making the ground a solid
  slab (`solid_box`, top at y=0). Lesson: every surface the player can
  stand on must carry collision; the test harness's floor already did,
  which is why the tests passed while the real scene failed.
- Two test-boundary fixes (test, not game code): the punch re-try waited
  exactly the 0.5 s lockout and tripped on float dust — now waits 0.67 s;
  added the camera-distance check once the arm length was understood.
- Pants lightened (#2b2b30 → #40465a) after the shot showed the legs
  vanishing against the dark road.
- Shot: `docs/step3_shot.png` — gameplay view from Vee's camera
  (`--shot-player`). The fixed corner camera (`--shot`) is unchanged.
- **Feel check is Harsh's:** play it on his laptop (Godot 4.7.2 → open
  project → run; click to capture the mouse, Esc releases). Tuning
  numbers live at the top of `characters/player.gd` — walk/run speed,
  accel, gravity, jump velocity, mouse sensitivity. Report what feels
  off and it gets one tuning pass before Step 4.
