# TimeSplitters 2, recompiled

This turns your own copy of TimeSplitters 2 for the original Xbox into a
native Windows program. Not an emulator: the game's own code is translated to
C and compiled, and the graphics, sound and input calls are answered by a
native implementation instead of emulated hardware.

**No game content is included here, and none ever will be.** This repository
holds the build files, the per-title fixes and the instructions. You supply
the disc you own. The translated code that comes out contains the game, so it
is not committed either, and you should not pass it on.

---

## What you need

| | |
| --- | --- |
| Windows | 10 or 11, 64-bit |
| Visual Studio | 2019 or 2022, with the **Desktop development with C++** workload |
| Python | 3.10 or newer, on `PATH` as `py -3` |
| CMake | 3.20+. The one bundled with Visual Studio is fine |
| Disk | About 6 GB for the extracted game, 4 GB for the build |
| Your copy of the game | TimeSplitters 2, Xbox |

The build takes roughly ten minutes on a modern desktop, most of it compiling
a million lines of generated C.

---

## 1. Clone, with submodules

The engine is a submodule, and it has a submodule of its own. Both are
needed, so clone recursively:

```
git clone --recurse-submodules https://github.com/<you>/split2-recomp.git
cd split2-recomp
```

If you already cloned without `--recurse-submodules`:

```
git submodule update --init --recursive
```

## 2. Build the symbol tool, once

The pipeline identifies the console's own library functions inside the game
so they can be replaced with native ones. That identification uses
XbSymbolDatabase, which is a C library and has to be built once:

```
cd xboxrecomp
cmake -S third_party/XbSymbolDatabase -B third_party/XbSymbolDatabase/build
cmake --build third_party/XbSymbolDatabase/build --config Release
cd ..
```

## 3. Put your game files in `game/`

Extract your disc to a folder named `game` at the root of this repository, so
that `game\default.xbe` exists. A disc image can be unpacked with
[extract-xiso](https://github.com/XboxDev/extract-xiso).

```
split2-recomp/
  game/
    default.xbe
    ... the rest of the disc ...
```

`game/` is ignored by git. Nothing in it is ever committed.

## 4. Translate the game

Two steps. The first finds the library functions, the second translates the
game and writes about a million lines of C into `src/recomp/gen/`.

```
cd xboxrecomp
py -3 -m tools.xdk_symbols "../game/default.xbe"
py -3 scripts/recompile.py "../game/default.xbe" ^
    --work-dir ../out --project .. --seeds ../config/seeds/4553000A.json
cd ..
```

`--seeds` matters. It supplies function addresses that static analysis cannot
find because they are only ever reached through a pointer at run time.
Without it the game starts and then stops early.

Expect roughly 7,000 functions translated and none failed.

## 5. Build

```
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release
```

Use `-G "Visual Studio 16 2019"` if that is what you have.

## 6. Play

```
build\Release\timesplitters2_recomp.exe
```

Double-click it or make a shortcut; it finds `game/` on its own. It is a
windowed program, so diagnostics go to a log file beside the executable
rather than to a console.

Or use one of the two launchers, which set the display options for you:

| | |
| --- | --- |
| `play-4x3.bat` | 4:3, supersampled and sharpened. **Use this one.** |
| `play-16x9.bat` | 16:9. Experimental and unfinished — see below. |

---

## Display

The picture always keeps its proportions. Resize the window to any shape and
the space left over becomes black bars; nothing is ever stretched to fit.

| Variable | |
| --- | --- |
| `RECOMP_RES_SCALE` | `1`–`8`. Render this many times larger and filter back down: supersampling. `2` is a good default and costs very little. |
| `RECOMP_ANISO` | `1`–`16`. Sharpen textures at glancing angles. Skips the 2D layer, which wants no filtering. |
| `RECOMP_WIDESCREEN=1` | Present at 16:9 instead of 4:3, and tell the title the console is widescreen. |
| `RECOMP_HOR_PLUS=0.75` | Widen the camera's horizontal field of view to match. |

### Why 16:9 is still experimental

TimeSplitters 2 has no widescreen mode. It never asks the console whether the
television is 16:9 — the four places it reads console settings ask for the
language, the audio setup and the parental controls, and never the video flags
— there is no option for it in the menus, and the word appears nowhere in the
executable. So 16:9 here is not the game's own mode being switched on. It is
the projection being widened from outside.

The world comes out right: the horizontal field of view widens, the vertical
stays put, so you see more to the sides rather than the same view stretched.

The flat layer drawn on top does not. The HUD, menus, the logo, fades and
full-motion video are placed in 640x480 screen coordinates by the game itself
and never pass through the projection, so they cannot be widened the same way
and are stretched instead. Finishing this means deciding, element by element,
which of them belong in a centred 4:3 box and which have to span the whole
screen — a fade or a letterbox bar must cover everything, a health meter must
not — and that is still to do.

---

## While it is running

| Key | |
| --- | --- |
| F9 | Frame rate on screen |
| F10 | Step the frame cap: adaptive, 60, 30, off |
| F11 | Save a screenshot and a replayable frame capture beside the executable |

A gamepad works out of the box on all four ports. To remap anything:

```
cd xboxrecomp
py -3 -m tools.input_ui
```

That writes a config which the game reads on the next start. Keyboard play is
supported but the stick directions are unbound by default, so a pad is the
better experience today.

---

## Useful switches

Set these in the environment before starting the executable.

| Variable | |
| --- | --- |
| `RECOMP_GAME_DIR` | Use game files from somewhere other than `game/` |
| `RECOMP_FPS_CAP` | `adaptive` (default), `60`, `30`, or `0` for uncapped |
| `RECOMP_FPS_OVERLAY=1` | Start with the frame rate already showing |
| `RECOMP_SAMPLE=1000` | Sample where time is being spent, then report |

---

## What works, and what does not

It plays. The front end, the story levels and the arcade modes run, with
sound and with a pad.

Known problems, with the detail in [docs/](docs/):

- **The picture is dimmer than the console's**, by roughly a third. Three
  full-screen passes are involved and the cause is not yet found.
- **A faint horizontal line** has been seen once and never reproduced.
- Keyboard stick directions are unbound by default.

[docs/timesplitters2-open-issues.md](docs/timesplitters2-open-issues.md) is the
current list. [docs/second-title-bringup.md](docs/second-title-bringup.md) is
how it was brought up, and is the best thing to read if you want to work on
it. [docs/ts2-performance-plan.md](docs/ts2-performance-plan.md) covers the
frame time work.

---

## If something goes wrong

The executable writes a log beside itself. Start there: it names the
configuration it loaded, the device it created, and anything it refused.

- **"This needs the game's own files"** — `game\default.xbe` is not where it
  expects. Check step 3, or set `RECOMP_GAME_DIR`.
- **The symbol step cannot find its tool** — step 2 was skipped, or the build
  failed. The error names the path it looked in.
- **The build fails with thousands of errors in `src/recomp/gen/`** — the
  translation step did not finish. Re-run step 4 and read its output.
- **It starts and quits immediately** — almost always the seed file being
  missed in step 4.

---

## Legal

This repository contains engine and tooling code only. It ships no game code,
no assets, and no copyrighted material of any kind.

Recompiling requires game files from a copy you own. Do not distribute the
recompiled executable or anything under `src/recomp/gen/`: both contain the
game's own code. Do not redistribute library code recovered during the
identification step either.

The engine is [xboxrecomp](xboxrecomp/), included here as a submodule, and
carries its own licence and history.
