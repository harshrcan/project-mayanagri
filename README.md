# Project Mayanagri

Stylized open-world crime game set in Mumbai. GTA-style, third-person,
rags-to-riches campaign: thief → gang leader → business owner → the city's
biggest name. Solo build by Harsh Rana, with AI tools, part-time around
school and work.

- **Working title:** Project Mayanagri (final name later)
- **Engine:** Godot 4.7.2-stable, GDScript only — see `AGENTS.md` for the locked rules
- **Platforms:** Windows PC (.exe) first, then Android (.apk) from the same project
- **Look:** stylized low-poly, strong lighting, Mumbai colour
- **Size targets:** ~1 GB PC, under 500 MB Android
- **Full plan:** `~/workspace/user/files/Project_Mayanagri_Full_Game_Plan.pdf`
  (14 pages, Nov 15, 2026) — the plan is the source of truth; this README is the build log.

## Tools (locked versions — do not upgrade mid-step without noting it here)

| Tool | Version | Where |
|---|---|---|
| Godot | **4.7.2-stable** (standard, no C#) | [godotengine.org/download](https://godotengine.org/download) — portable ZIP, no installer |
| Blender | **5.2.3 LTS** | [blender.org/download](https://www.blender.org/download/) — LTS line, supported to Jul 2028 |
| Git (+ Git LFS for models/audio) | 2.43.0 | `git lfs install` once per machine |
| Export templates | 4.7.2-stable | download at Step 10 (demo), not needed before then |

In this workspace Godot lives at `~/workspace/tools/godot/Godot_v4.7.2-stable_linux.x86_64`
and Blender at `~/workspace/tools/blender/blender-5.2.3-linux-x64/blender`.
On Harsh's laptop, install the same versions from the links above.

## Run it

```bash
# Open in the editor
godot --editor project.godot
# Or run the game directly (headless check used in CI / verification)
godot --headless --quit-after 60 project.godot
```

## Folder layout (from plan §9 — do not rename without updating AGENTS.md)

| Folder | Holds |
|---|---|
| `world/` | Main scene, districts, streaming chunks, road spline tool, lighting |
| `vehicles/` | Car / bike / auto — raycast physics, enter/exit |
| `characters/` | Player (Vijay/Vidya), shared skeleton, outfits |
| `ai/` | Citizens, traffic drivers, gang AI |
| `police/` | Heat system, constables, jeeps, bribes |
| `missions/` | Mission engine + mission data files (one file per mission) |
| `economy/` | Money, gang, robberies, businesses, turf |
| `ui/` | Menus, HUD, minimap, settings, touch controls |
| `audio/` | City bed, voices, radio, score (original / licensed only) |
| `data/` | JSON / resources: vehicles, NPC types, shops, businesses |
| `save/` | Save system (JSON, 3 slots) — runtime saves go to `user://`, not here |
| `docs/` | Step logs: spec → build → verification evidence, one file per step |
| `tools/` | Small helper scripts (NOT the Godot/Blender installs) |

## Build order (plan §10 — in order, no step starts until the previous check passes)

1. ✅ Tool setup + repo + folder layout + AI rules — **this step (Step 1)**
2. Lock the look — one Dharavi street corner, chai stall, parked auto, evening light
3. Player third-person controller + camera
4. Vehicles (car, bike, auto) + enter/exit
5. Roads / traffic
6. Citizens
7. Police / Heat
8. Home + saving
9. Mission engine + flashback + opening mission + two Act 1 missions
10. Public demo (menus, settings, minimap, sound, trailer, itch.io)
11. Gang / robberies, Acts 1–2 complete
12. Heists / businesses, Act 3, Steam Early Access
13. Film world / finale, Acts 4–5
14. Android
15. Launch 1.0

Progress is logged per step in `docs/` — see `docs/STEP1_SETUP.md`.

## Rules that protect the project

- **No real IP, ever:** real district names and public landmarks only. All vehicles,
  people, brands, films, parties and songs are invented. No real celebrities,
  no real car brands, no Bollywood songs. See AGENTS.md §Legal.
- **One district must be fun before a second exists.** Cut features, never polish.
- **One system per session.** Small modules, commit daily, verify before claiming done.
- **Cows and places of worship cannot be harmed in-game.** Satire targets invented
  people/groups only.

## GitHub

Repo: **https://github.com/harshrcan/project-mayanagri** (public).
`main` is the working branch; commit daily at minimum. Full setup log:
`docs/STEP1_SETUP.md`.
