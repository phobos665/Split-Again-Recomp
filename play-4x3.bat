@echo off
rem TimeSplitters 2 -- 4:3. The accurate configuration, and the one to use.
rem
rem The game is shown at the shape it was made for. Resize the window to
rem anything you like: the picture keeps its proportions and the space left
rem over becomes black bars, so nothing is ever stretched.
rem
rem What this turns on beyond a plain run:
rem   RECOMP_RES_SCALE=2   render at 1280x960 and filter back down, which is
rem                        supersampling -- it smooths edges, alpha-tested
rem                        cutouts and the 2D layer alike. 3 and 4 also work
rem                        and cost little; 1 is the console's own size.
rem   RECOMP_ANISO=16      sharpen textures seen at a glancing angle. Left
rem                        off the 2D layer, which wants no filtering.
rem
rem The frame rate is capped the way the console paced itself. F10 steps the
rem cap (adaptive, 60, 30, off) and F9 shows the rate.
setlocal
cd /d "%~dp0" || exit /b 1

set RECOMP_RES_SCALE=2
set RECOMP_ANISO=16

build\Release\timesplitters2_recomp.exe %*
