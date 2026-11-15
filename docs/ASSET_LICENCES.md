# Asset licence log — Project Mayanagri

Every model, texture, sound and animation in the game gets a row here:
source + licence. If the licence is unclear, the asset is NOT used.
Rule from AGENTS.md §6: AI-generated or CC0 only unless the licence is
written down here.

## In use

| Asset | Source | Licence | Notes |
|---|---|---|---|
| Dharavi corner, chai stall, auto, handcart (all primitives) | Built in-project, `world/`, `vehicles/` | Original (ours) | Flat colours, no textures yet |
| Procedural textures (brick, plaster, asphalt, pavement, tin, wood, cloud) | Generated in-project by `tools/make_textures.py` (numpy + PIL), `world/textures/` | Original (ours) | 256×256 tileable PNGs, SA-DE pass 2026-11-15 |
| Vee placeholder body | Built in-project, `characters/vee_placeholder.gd` | Original (ours) | Procedural poses, replaced later |
| "Amrut Chai", "General Store", "Bhai" names/signs | Invented in-project | Original (ours) | No real brands |
| Godot 4.7.2 engine | godotengine.org | MIT | Engine, not a game asset |

## Candidates (NOT in the game yet)

| Asset | Source | Licence | Notes |
|---|---|---|---|
| Quaternius "Casual Female" + "Casual Male" (Ultimate Animated Characters pack) | Quaternius via Cinevva catalog https://app.cinevva.com/game-assets/free-3d-character-models (original: quaternius.com) | CC0 | 17 clips each, skinned, ~1.75 m, material colours (no external textures). Found 2026-11-15 during Step 3; direct CDN fetch failed in this environment (binary not extractable via the page reader) — NOT downloaded, NOT in the project. Next step: download the pack from quaternius.com (or Kenney's Mini Characters) on a machine with a browser, verify clips (idle/walk/run/jump) in Blender, then wire the AnimationPlayer in as Vee's visual. Vijay = Casual Male, Vidya = Casual Female is the natural pair. |
| Kenney "Mini Characters" (e.g. Character Male A / Female A) | Kenney (kenney.nl) via same Cinevva catalog | CC0 | 32 clips, skinned, texture embedded in Cinevva repack. Chibi proportions (~0.78 m) — wrong scale for Vee, so second choice behind Quaternius. |

## Rejected / not used

| Asset | Reason |
|---|---|
| Mixamo characters/animations | Requires an Adobe account; licence is not CC0 — not used unless Harsh decides otherwise. |
| Any real car brand, film, song, celebrity likeness | Plan §12: never. Real place names + public landmarks only. |
