@echo off
rem Builds Disney's Rooftop Ruckus on rapture-engine (submodule engine\).
rem PROVISIONAL: the static recompiler that translates your own Ruckus.dll to C at build time is
rem still being developed, so this script only checks the engine submodule and stops.
setlocal
if not exist "%~dp0engine\CMakeLists.txt" (
	echo engine\ is empty: run  git submodule update --init
	exit /b 1
)
echo Engine submodule: OK.
echo.
echo Disney's Rooftop Ruckus cannot be built yet: the static recompiler that translates the game
echo DLL of your own copy (Ruckus.dll) to C is still in development.
echo See README.md for the status.
exit /b 1
