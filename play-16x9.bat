@echo off
rem TimeSplitters 2 -- 16:9. EXPERIMENTAL, and not finished.
rem
rem TimeSplitters 2 has no widescreen mode of its own. It never asks the
rem console whether the television is 16:9, it has no option for it, and
rem there is no such word anywhere in the executable. So this is not the
rem game's widescreen being switched on -- there is none to switch on. It
rem is the projection being widened from outside.
rem
rem What works: the world. The camera's horizontal field of view is widened
rem and the vertical left alone, so you see more to the sides rather than
rem the same view stretched. Geometry, proportions and perspective are all
rem correct.
rem
rem What does not: the flat layer drawn on top -- the HUD, menus, the logo,
rem fades and full-motion video. Those are positioned in 640x480 screen
rem coordinates by the game itself, never pass through the projection, and
rem so cannot be widened the same way. At 16:9 they are stretched. Fixing
rem that means deciding, element by element, which ones belong in a centred
rem 4:3 box and which must span the screen -- a fade or a letterbox bar has
rem to cover everything, a health meter does not -- and that is per-screen
rem work still to do.
rem
rem Use play-4x3.bat unless you are working on this.
rem
rem   RECOMP_WIDESCREEN=1    present the frame at 16:9 rather than 4:3, and
rem                          tell the title the console is widescreen
rem   RECOMP_HOR_PLUS=0.75   widen the horizontal field of view by
rem                          (4/3)/(16/9). Together with the line above the
rem                          squeeze and the stretch cancel exactly
rem   RECOMP_HOR_PLUS_REG=60 the constant register holding the first column
rem                          of this title's projection. Only change this
rem                          when adapting the trick to another game
setlocal
cd /d "%~dp0" || exit /b 1

set RECOMP_RES_SCALE=2
set RECOMP_ANISO=16
set RECOMP_WIDESCREEN=1
set RECOMP_HOR_PLUS=0.75
set RECOMP_HOR_PLUS_REG=60

build\Release\timesplitters2_recomp.exe %*
