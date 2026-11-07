@echo off
rem ---------------------------------------------------------------------------
rem  Disney's Rooftop Ruckus - build script for Windows
rem
rem    build.bat          build -> build\ruckus.exe
rem    build.bat run      build, then start the game
rem    build.bat clean    delete the build folder
rem    build.bat tools    only check/download the build tools
rem    build.bat help
rem
rem  The game is produced from YOUR copy of the original game: the static
rem  recompiler (submodule recomp\) translates Ruckus.exe, Ruckus.dll, moses.dll
rem  and Aaron.dll to C on this computer, and the result is compiled together
rem  with a Win32 replacement layer on SDL2 (engine\ = rapture-engine).
rem  Nothing generated from your files leaves the build folder.
rem
rem  Game files: put them in this folder, or in its parent folder, or set
rem  GAME_DATA to the folder that holds them:
rem      set GAME_DATA=C:\Games\Ruckus
rem
rem  Needs: MinGW-w64, CMake and SDL2 (found or downloaded in portable form by
rem  engine\tools\setup-build-env.ps1, nothing is installed system-wide) and
rem  Python 3.11+ with the packages pefile and capstone (installed for the
rem  current user with pip if missing).
rem ---------------------------------------------------------------------------
setlocal
cd /d "%~dp0"
set "RAPTURE_ROOT=%~dp0."
set "ACTION=%~1"

if /i "%ACTION%"=="help"  goto :help
if /i "%ACTION%"=="-h"    goto :help
if /i "%ACTION%"=="/?"    goto :help
if /i "%ACTION%"=="clean" goto :clean

rem --- submodules --------------------------------------------------------------
if not exist "%~dp0engine\CMakeLists.txt" goto :init_submodules
if not exist "%~dp0recomp\CMakeLists.txt" goto :init_submodules
goto :submodules_ok
:init_submodules
echo Submodules missing: running "git submodule update --init --recursive" ...
git -C "%~dp0." submodule update --init --recursive
if errorlevel 1 goto :fail_submodule
if not exist "%~dp0engine\CMakeLists.txt" goto :fail_submodule
if not exist "%~dp0recomp\CMakeLists.txt" goto :fail_submodule
:submodules_ok

rem --- compiler, CMake, SDL2 -----------------------------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0engine\tools\setup-build-env.ps1"
if errorlevel 1 goto :fail_tools
call "%~dp0build.env.bat"
set "PATH=%MS_GCC_BIN%;%MS_CMAKE_BIN%;%PATH%"

rem --- Python 3.11+ with pefile and capstone ----------------------------------
set "PY="
for %%P in (python.exe) do if not "%%~$PATH:P"=="" set "PY=%%~$PATH:P"
if not defined PY for %%P in (py.exe) do if not "%%~$PATH:P"=="" set "PY=%%~$PATH:P"
if not defined PY goto :fail_python
if /i "%PY:~-6%"=="py.exe" (
    for /f "delims=" %%I in ('"%PY%" -3 -c "import sys; print(sys.executable)"') do set "PY=%%I"
)
"%PY%" -c "import sys; sys.exit(0 if sys.version_info >= (3, 11) else 1)"
if errorlevel 1 goto :fail_python
"%PY%" -c "import pefile, capstone" 2>nul
if errorlevel 1 (
    echo The recompiler needs the Python packages pefile and capstone: installing them for the current user...
    "%PY%" -m pip install --user pefile capstone
    "%PY%" -c "import pefile, capstone"
    if errorlevel 1 goto :fail_python_packages
)
if /i "%ACTION%"=="tools" goto :eof

rem --- the game files ----------------------------------------------------------
if defined GAME_DATA goto :have_game_data
if exist "%~dp0Ruckus.dll" set "GAME_DATA=%~dp0."
if not defined GAME_DATA if exist "%~dp0..\Ruckus.dll" set "GAME_DATA=%~dp0.."
if not defined GAME_DATA goto :fail_game_data
:have_game_data
for %%F in ("%GAME_DATA%") do set "GAME_DATA=%%~fF"
for %%F in (Ruckus.exe Ruckus.dll moses.dll Aaron.dll abu.rrs abufx.rrs abulin.rrs frenzy.rrs frenzylz.rrs) do (
    if not exist "%GAME_DATA%\%%F" (
        echo Missing game file: "%GAME_DATA%\%%F"
        goto :fail_game_data
    )
)
echo Game files: %GAME_DATA%

rem --- configure (runs the recompiler on the game files) and build -----------------
echo.
echo === Configuring (recompiling your game files) ===
cmake -S recomp -B build -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release ^
    -DSDL2_DIR="%MS_SDL2_DIR%" -DPython3_EXECUTABLE="%PY%" ^
    -DGAME_DIR="%GAME_DATA%" -DGAME_CONFIG="%~dp0recomp\configs\ruckus.toml" -DGAME_EXE=ruckus ^
    -DRAPTURE_ENGINE_DIR="%~dp0engine" -DRECOMP_BUILD_TESTS=OFF
if errorlevel 1 goto :fail_build

echo.
echo === Building ===
cmake --build build -j %NUMBER_OF_PROCESSORS%
if errorlevel 1 goto :fail_build

echo.
echo Build OK: %~dp0build\ruckus.exe
echo The game runs in its own folder ("%GAME_DATA%"); the executable goes there by itself.
if /i "%ACTION%"=="run" goto :run
echo Start it with "build.bat run" or by opening build\ruckus.exe.
goto :eof

:run
start "" /D "%GAME_DATA%" "%~dp0build\ruckus.exe"
goto :eof

:clean
rmdir /s /q build 2>nul
echo Build folder deleted.
goto :eof

:help
echo Usage: build.bat [run ^| clean ^| tools ^| help]
echo.
echo   (none)  build into build\ruckus.exe
echo   run     build and start the game
echo   clean   delete the build folder
echo   tools   only check/download the build tools
echo.
echo   Game files: this folder, its parent, or the folder in GAME_DATA.
goto :eof

:fail_submodule
echo.
echo Cannot get the submodules engine\ and recomp\. Clone with:
echo   git clone --recurse-submodules ^<url^>
echo or run:  git submodule update --init --recursive
exit /b 1

:fail_tools
echo.
echo The build tools are not ready. Nothing was built.
exit /b 1

:fail_python
echo.
echo Python 3.11 or newer is needed to run the recompiler (https://www.python.org/downloads/).
echo Install it, make sure python.exe or py.exe is in PATH, then run build.bat again.
exit /b 1

:fail_python_packages
echo.
echo Could not install the Python packages pefile and capstone.
echo Install them yourself:  python -m pip install --user pefile capstone
exit /b 1

:fail_game_data
echo.
echo The files of your copy of the game were not found.
echo Copy the installed game (Ruckus.exe, Ruckus.dll, moses.dll, Aaron.dll, the *.rrs and *.avi files)
echo into this folder or its parent folder, or set GAME_DATA to their folder, e.g.
echo   set GAME_DATA=C:\Games\Ruckus
exit /b 1

:fail_build
echo.
echo BUILD FAILED. See the messages above.
exit /b 1
