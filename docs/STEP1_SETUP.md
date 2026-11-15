# Step 1 — Tool setup + repo + folder layout + AI rules

**Status: DONE except GitHub remote (needs Harsh — see §4).**
Date: 2026-11-15. Plan §10 step 1. Check: *empty project runs and is pushed*
→ runs: ✅ verified below. Pushed: ⏳ blocked on repo creation decision.

## 1. Spec (plain words)

Before any game code: pin exact tool versions, prove the empty Godot project
imports and runs headless with zero errors, lay out the plan §9 folders,
write the AI rules file, and get the whole thing into git so every later step
builds on a known-good base.

## 2. Tools — what was found, what was installed

| Tool | Before | After | How verified |
|---|---|---|---|
| Git | 2.43.0 ✅ present | 2.43.0 | `git --version` |
| Godot | ❌ not installed | **4.7.2-stable** (standard, no C#) | `./Godot_v4.7.2-stable_linux.x86_64 --version` → `4.7.2.stable.official.ed1daf0bf` |
| Blender | ❌ not installed | **5.2.3 LTS** | `./blender --version` → `Blender 5.2.3 LTS, build date 2026-10-22` |
| GitHub CLI (`gh`) | 2.102.0, ❌ not logged in | 2.102.0, not logged in | `gh auth status` — no host. Not needed: repo creation goes through the connected GitHub connector instead |
| Git LFS | ❌ not installed | install attempted via `apt-get install git-lfs` on 2026-11-15 — **confirm with `git lfs version` before Step 2** (no binary assets exist yet, so nothing is blocked) | — |
| Python | 3.12.3 | 3.12.3 | helper scripts only |

**Version choice notes**
- Godot latest stable confirmed via GitHub Releases API: `4.7.2-stable`,
  published 2026-08-18, `prerelease: false`. (4.8-beta1 exists — deliberately
  NOT used.) Standard build, GDScript only, per plan §9.
- Blender: 5.3 released Nov 10, 2026 but is a regular release; **5.2.3 LTS**
  (Oct 21, 2026) chosen for a long project — LTS fixes run to Jul 2028.
- Download sources (official only): github.com/godotengine/godot releases,
  download.blender.org. Godot zip is ~75 MB, Blender tarball ~368 MB.

**Install locations in this workspace** (persist in home dir):
- Godot: `~/workspace/tools/godot/Godot_v4.7.2-stable_linux.x86_64`
- Blender: `~/workspace/tools/blender/blender-5.2.3-linux-x64/blender`

**Harsh's laptop needs the same versions** (see §5): Godot 4.7.2-stable
Windows x86_64 from godotengine.org/download, Blender 5.2.3 LTS from
blender.org/download. Both are portable — unzip and run, no installer.

## 3. Project layout created

Root: `~/workspace/project-mayanagri/` — this IS the Godot project root
(`project.godot` lives here).

Folders (plan §9, each with a one-line README): `world/ vehicles/
characters/ ai/ police/ missions/ economy/ ui/ audio/ data/ save/`
plus `docs/` (step logs) and `tools/` (helper scripts).

Files:
- `project.godot` — Godot 4.7, Forward+ on PC, Mobile renderer on Android,
  main scene `res://world/main.tscn`, 1280×720 default.
- `world/main.tscn` + `world/main.gd` — minimal placeholder scene (camera +
  sun + a `_ready()` print). Step 2 replaces it with the Dharavi corner.
- `AGENTS.md` — AI rules: locked stack, folder layout, signals event bus,
  streaming/pooling/performance budgets, verification bar, legal rules
  (invented everything, cows/worship safe, licence log).
- `README.md` — project overview, tool table, run instructions, build order.
- `.gitignore` — `.godot/`, builds (`*.exe/.apk/.pck`), Blender `*.blend1`.
- `.gitattributes` — Git LFS for `*.glb/.gltf/.fbx/.blend/.wav/.mp3/.ogg/.exr/.hdr`.

## 4. Verification (Step 1 check)

Run from the project root, Godot 4.7.2 headless, 2026-11-15:

```
godot --headless --editor --quit --import
→ exit 0, filesystem scan DONE, no errors

godot --headless --quit-after 60 --path .
→ exit 0
→ "[Mayanagri] Main scene ready. Godot 4.7.2-stable (official)"
```

Zero errors, zero warnings about missing scripts/scenes. `.godot/` generated
and correctly git-ignored.

**Git:** local repo initialised (`main` branch), first commit `6fb66bb`
— "step1: tool setup — Godot 4.7.2, Blender 5.2.3 LTS, folder layout, AI
rules, empty project runs", 21 files.

**GitHub:** connector status `connected` (account harshrcan). Searched
GitHub for `project-mayanagri` → **0 results, repo does not exist yet**.
Creation is ready to go via the connector's `create_repository` — but the
repo does NOT exist and nothing is pushed yet, because visibility is Harsh's
call (below).

## 5. What still needs Harsh

1. **Repo visibility — private or public?** (one-word answer)
   Plan §11 is build-in-public (clips from week 1, Discord at demo), which
   leans public — but a public repo from day one also publishes all code.
   Recommended: **private now, flip to public at the Step 10 demo** — keeps
   the option open either way. Once he answers, creation + first push is one
   command:
   `create_repository(name="project-mayanagri", private=<true/false>)`
   then `git remote add origin … && git push -u origin main`.
2. **Install on his laptop** (only needed when he wants to open/play it
   himself): Godot 4.7.2-stable Windows + Blender 5.2.3 LTS, links in §2.
   Not needed to keep building here — this workspace already runs it.
3. **Git LFS on his laptop** (`git lfs install` once) — only matters once
   models/audio land in Step 2.
4. **Open questions from the plan (§13)** — not blocking Step 2, but needed
   soon: final game name? hours/week? weakest PC + phone to target? friends
   for art/voice/music?

## 6. Feel / notes

- Nothing to playtest yet — this step is scaffolding only, by design.
- `gh` CLI login is intentionally skipped: the GitHub connector already
  covers repo creation and pushes; Harsh should NOT paste tokens anywhere.
- Export templates (4.7.2) NOT downloaded yet — needed first at Step 10
  (demo builds). Noted in README so nobody hunts for them mid-step.
