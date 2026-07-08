# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Lace is a set of Ada components for game, simulation and GUI applications, from low-level (events, math) up to a game engine (GEL). It builds with GNAT `gprbuild` (compiled as Ada 2022 via `-gnat2022`) and is also published as Alire crates (`alire.toml` at each component root). Requires FLORIST (Ada POSIX) and the dev packages for Bullet, Freetype, Expat and SDL2.

## Environment setup

GPR project paths and scenario variables come from the environment. Nothing builds until this is done (typically in `~/.bashrc`):

```bash
export opengl_profile=desk     # safe | lean | desk
export opengl_platform=glx     # egl | glx | osmesa
export restrictions=xgc        # xgc | ravenscar
export OS=Linux
export FLORIST_BUILD=default

export LACE=/path/to/lace
source $LACE/lace-gpr_paths.sh   # prepends every component's library dir to GPR_PROJECT_PATH
```

Additional scenario variables (defined in `0-floor/lace_shared/lace_shared.gpr`, which every project imports): `Lace_Build_Mode` (`debug`* | `fast` | `small`), `Lace_OS` (`Linux`* | `Windows_NT` | `MacOSX`), `Lace_Restrictions` (`xgc`* | `ravenscar`). Pass with `-X`, e.g. `gprbuild -P foo.gpr -XLace_Build_Mode=fast`.

## Build and test commands

There is no unified test runner. Every demo/test is a standalone applet: a directory with its own `.gpr` whose executable is written into that same directory.

```bash
# Build one library
gprbuild -P 3-mid/opengl/library/opengl.gpr

# Build everything at once (an applet that 'with's every launch procedure)
cd 5-all/applet/build_all && gprbuild -P build_all_lace.gpr

# Build and run a single demo or test
cd 4-high/gel/applet/demo/sprite/mixed_shapes
gprbuild -P mixed_shapes.gpr
./launch_mixed_shapes

# Math regression suite
cd 1-base/math/applet/test/suite && gprbuild -P math_testsuite.gpr && ./launch_math_testsuite

# Alire (per component)
cd 1-base/lace && alr build
```

OpenGL and GEL applets expect asset symlinks in their directory: `assets/opengl -> 3-mid/opengl/assets` and `assets/gel -> 4-high/gel/applet/assets`. Checked-in demos already have them, committed as *relative* symlinks — keep any new ones relative. (`create_opengl_assets.sh` / `create_gel_assets.sh` in `3-mid/opengl/applet` and `4-high/gel/applet` create absolute ones for out-of-tree use.)

Compiled demo/test executables (`launch_*`, `test_*`, etc.) land next to their `.gpr` and are gitignored by name or path in the root `.gitignore` — add an entry when creating a new applet.

## Architecture

Components are organised into dependency tiers; a component may only depend on components in lower tiers:

| Tier | Component | Role |
|------|-----------|------|
| `5-all` | build_all | Applet that transitively builds every component and demo |
| `4-high` | gel | Game Engine Library; windowing backends in `library/sdl` (`gel_sdl.gpr`) and `library/gtk` (`gel_gtk.gpr`) |
| `3-mid` | opengl | 2D/3D rendering; also `physics` (interface + `bullet`, `box2d`, `c_math`, `vox` implementations) and `impact` |
| `2-low` | collada | Collada parser; also `neural` (experimental, gitignored) |
| `1-base` | lace | Core types, `lace.Events` (task-safe subject/observer, DSA-capable), `lace.Environ`; also `math`, `xml`, `swig` |
| `0-floor` | lace_shared | Abstract GPR holding shared compiler/style/binder options and scenario variables |

Component directory convention: `library/` (the `.gpr`s, referenced by `lace-gpr_paths.sh`), `source/`, `applet/` (`demo/`, `test/`, `tute/` — runnable programs), `assets/`, `private/` (vendored third-party code, e.g. opengl's `freetype`, `gid`, `gl`), `alire.toml`.

Points that span multiple files:

- **opengl profile/platform selection**: `opengl_core.gpr` picks source directories by scenario variable — `source/profile/{safe,lean,desk}` and `source/platform/{egl,glx,osmesa}`. The same API is implemented per profile/platform, so a change to a lean source may need mirroring in its safe/desk counterpart.
- **physics** has one `interface` library and several swappable `implement/*` backends, each with thin C/C++ binding layers (`*_thin`, `*_thin_cxx`, `*_thin_c` projects).
- **DSA (distributed) support**: `4-high/gel/applet/demo/distributed/dsa` uses PolyORB partitions (`client_partition`/`server_partition` executables); `lace.Events` is designed to work across partitions.

## Coding style

Defined in `document/coding style/coding_style.md` and enforced by GNAT style switches (`-gnaty…` in `lace_shared.gpr`); `-gnatwa` warnings are on.

- Identifier casing is distinctive: nouns capitalise their first letter, other words are lowercase — `procedure reverse_Elements (in_Container : in Container)`, `the_Grid`, `heights_File`.
- Namespace packages are referenced in lowercase: `lace.Events`, `ada.Containers`, `openGL.Model`.
- Context clauses: one `with`, packages grouped by namespace, most specific first, groups separated by blank lines.
- Commit messages: short imperative sentence ending with a full stop (see `git log`).
