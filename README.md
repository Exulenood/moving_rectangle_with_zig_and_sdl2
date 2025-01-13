# Moving Rectangle

This is a first attempt to approach SDL2 via zig.
Its just a rectangle on a white surface to be moved with the keyboard's arrow-keys.

To compile:

1. install zig: https://ziglang.org/learn/getting-started/
2. install SDL2: https://wiki.libsdl.org/SDL2/Installation (To build on MacOs: if you dont use Homebrew, you have to alter the Path-handling in the build.zig).
3. run zig build

The executable is generated in <project-folder>/zig-out/bin
