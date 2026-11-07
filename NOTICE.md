# Notice

This is an **unofficial**, non-commercial fan project for game preservation and
interoperability. It is **not affiliated with, endorsed by or sponsored by** The Walt Disney
Company, Disney Interactive or Rapture Technologies.

*Disney*, *Rooftop Ruckus*, *Aladdin*, *Hot Shots* and the related names and characters are trademarks of
their respective owners. They are mentioned only to identify the game this port is compatible
with.

This repository contains only a build script and documents; the engine (`engine/`) and the static
recompiler (`recomp/`) are separate repositories written from scratch. None of them contains
**game data** (no `.rrs` archives, executables, DLLs, videos, images, sounds, music, texts or help
files of the original game), **original or decompiled code** or **game logic**: the code of the
game is translated to C on the user's computer at build time, from the user's own copy of the
game, and stays in `build/`. Do not commit or distribute `build/` or `dist/`, game files or any
file generated from them.

To use this software you must own the original game.
