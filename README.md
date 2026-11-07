# Disney's Rooftop Ruckus – unofficial port on the Rapture engine

*Disney's Rooftop Ruckus* (Italian edition: *Disney Abu sui tetti*) is one of Disney's "Hot Shot" games (Disney Interactive, about 1999),
a Windows game built on Rapture Technologies' `moses.dll` + `Aaron.dll` engine. This repository is
meant to build a native Windows version of it with
**[rapture-engine](https://github.com/LuC-iTA-GHorg/rapture-engine)**, a from-scratch
reimplementation of that engine in C++17 + SDL2 shared by the four Hot Shot games, included here as
a git submodule (`engine/`). No emulator, no virtual machine.

> **You need your own copy of the original game.** This repository contains **no game data, no
> original code, no decompiled code and no game logic**. See [NOTICE.md](NOTICE.md).

## Status: work in progress – not playable yet

The engine is complete and public. The game's own logic lives in its game DLL (`Ruckus.dll`), which is
not part of this repository and never will be. The plan is a **static recompiler** (in the style of
N64Recomp and XenonRecomp) that, at build time and on your own computer, translates the x86 code
of **your** copy of `Ruckus.dll` to C and compiles it together with the engine. Nothing produced from
your files is stored in or distributed with this repository.

The recompiler is still being developed, so for now `build.bat` only checks the engine submodule
and stops with a message: **the game cannot be built or played from this repository yet.**

## Requirements

- Windows 10 or 11, 64-bit, and git.
- The files of your own copy of the game, installed from the original CD: `Ruckus.exe`, `Ruckus.dll`, `moses.dll`, `Aaron.dll`, `Launcher.exe`, `abu.rrs`, `abufx.rrs`, `abulin.rrs`, `frenzy.rrs`, `frenzylz.rrs`, `DDLogo.avi`, `DILogo.avi`.
- When the recompiler is ready: the MinGW-w64 toolchain, CMake and SDL2, found or downloaded by the
  engine's `tools/setup-build-env.ps1` (portable, no system-wide installs).

## Building (when the recompiler is ready)

```bat
git clone --recurse-submodules https://github.com/LuC-iTA-GHorg/rooftop-ruckus-rapture-port.git
cd rooftop-ruckus-rapture-port
rem copy the files of your installed game here (or set GAME_DATA to their folder), then:
build.bat
```

If you cloned without `--recurse-submodules`: `git submodule update --init`.
Do not commit or publish `build/`, `dist/` or any file generated from your game files.

## License

No license has been chosen yet for the code of this project: until then, all rights are reserved
by its author. The game, its names and its data belong to their respective owners.
