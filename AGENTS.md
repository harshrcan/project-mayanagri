# AGENTS.md — AI rules for Project Mayanagri

Read this file before writing or changing any code in this project.
The full game plan PDF is the source of truth for design;
this file is the source of truth for how code gets written here.

## 1. Locked stack

- **Godot 4.7.2-stable, standard build (GDScript only).** No C#, no C++ unless a
  hot path proves it necessary — and then only with Harsh's explicit say-so.
- **GDScript, Godot 4 syntax.** Typed where it helps (`var x: int`), no
  untyped soup in new systems. One class per file, file name = class name in
  snake_case.
- **Blender 5.2.3 LTS**, export as **glTF (.glb)**. One shared skeleton for
  every character (both leads + all NPCs) so animations retarget everywhere.
- **Git + Git LFS.** Models (`.glb/.fbx/.blend`) and audio (`.wav/.mp3/.ogg`)
  go through LFS — see `.gitattributes`. Never commit a build (`.exe/.apk/.pck`).

## 2. Folder layout (plan §9 — do not rename, do not freestyle)

```
world/  vehicles/  characters/  ai/  police/  missions/  economy/  ui/  audio/  data/  save/
docs/   tools/
```

- A system lives in **its own folder, one system per session**. If a task
  touches two systems, say so first and split it.
- `data/` holds JSON / Godot resources (vehicles, NPC types, shops, missions).
  **Missions are data files, not code** — a mission is a step list
  (go to / steal / escape heat / deliver / survive). New mission = new data
  file, no new code.
- `save/` holds the save *system*. Runtime saves go to `user://`, never into
  the repo.

## 3. Architecture rules (plan §9)

- **Event bus via signals.** Systems talk through signals
  (`crime_committed`, `heat_changed`, `mission_step_done`). Missions never
  reach into other systems directly.
- **World streaming:** map in 100 m chunks, load/unload around the player.
- **Pooling:** ~25 vehicles / ~40 NPCs on PC (~half on phones), recycled as
  the player moves. Never spawn unbounded actors.
- **Cheap AI:** NPCs near the player run full logic; far ones only follow paths.
- **Performance budgets (non-negotiable):** 30 fps @ 720p low-spec laptop,
  60 fps @ 1080p mid-range PC, 30 fps mid-range Android. Test on the weak
  machine weekly from Step 2 onward.
- **Input from the start:** keyboard + mouse, gamepad, and touch controls
  designed in — not bolted on at Step 14.

## 4. How to work each step (plan §10)

1. Write a short spec in plain words in `docs/STEPn_*.md` **before** coding.
2. Build inside the system's own folder, one system per session.
3. **Verify it runs before reporting it done.** Minimum: headless import +
   run with no errors (see §5). Playtest 20 min for gameplay steps and list
   what feels wrong.
4. Commit with a clear message (`step2: dharavi corner lighting pass`).
   Commit daily at minimum. Record a 15 s clip for milestone steps.
5. If time gets tight, cut districts and side activities — never the quality
   of steps 2–9.

## 5. Verification (the bar for "done")

- Every change must pass, from the project root:
  ```bash
  godot --headless --editor --quit --import   # import check
  godot --headless --quit-after 60 project.godot   # run check, zero errors
  ```
  (Use the local binary path on this machine:
  `~/workspace/tools/godot/Godot_v4.7.2-stable_linux.x86_64`.)
- No `push_error`, no broken scene references, no missing scripts in the log.
- A gameplay step is not done until a human (Harsh) has played it and the
  feel issues are listed in the step log.
- **Never claim a system works if you have not run it.** If you cannot run
  it here, say exactly what is unverified and what Harsh must run on his laptop.

## 6. Legal / content — hard rules (plan §12)

- Real place names and public landmarks only. **All vehicles, people,
  brands, films, parties, songs are invented.** No real celebrities, no real
  car brands, no real film titles, no Bollywood songs, no real business families.
- Satire targets invented people/groups only. No real politicians, no real
  police units, nothing targeting religion or caste.
- **Cows and places of worship cannot be harmed in-game.** Cows block
  traffic — that is a gameplay obstacle, not a target.
- Every asset (model, texture, sound, animation) gets a row in the asset
  licence log (`docs/ASSET_LICENCES.md`, created at Step 2): source + licence.
  AI-generated or CC0 only unless the licence is written down. If the licence
  is unclear, do not use the asset.

## 7. Style

- Stylized low-poly, flat / lightly painted textures in shared atlases.
- Strong lighting: warm golden evenings, neon/tube-light nights, grey wet
  monsoon days. Mumbai colour: painted shutters, hand-lettered signboards
  (Hindi / Marathi / English), truck art, invented film posters.
- Dialogue: short Hindi / Marathi / Bambaiya English barks. Keep lines short
  and funny; one surprise per mission.
- Left-hand traffic. Always. Bikes filter between cars, autos are tippy,
  honking is constant.

## 8. What NOT to do

- Do not start a step until the previous step's check passes.
- Do not build a second district until the first one is fun.
- Do not add online multiplayer — single-player first, co-op only after 1.0.
- Do not "improve" the plan silently: if a plan detail conflicts with what
  the engine can do, write it in the step log and ask Harsh.
- Do not put secrets, keys or personal data in the repo. Ever.
