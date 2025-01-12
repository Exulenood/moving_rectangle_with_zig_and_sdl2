const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const Rectangle = @import("rectangle.zig").Rectangle;

pub fn main() !void {
    // SDL_Init initializes the Video-Subsystem of SDL.
    // Returns negative value on error, 0 on success
    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        std.debug.print("SDL2 Initialization failed: {s}\n", .{c.SDL_GetError()});
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    // Create a window named "Moving Rectangle" with certain measurements in the center of the screen:
    const window = c.SDL_CreateWindow("Moving Rectangle", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, 800, 600, c.SDL_WINDOW_SHOWN) orelse {
        std.debug.print("Window could not be created: {s}\n", .{c.SDL_GetError()});
        return error.SDLWindowCreationFailed;
    };
    defer c.SDL_DestroyWindow(window);

    // Create the Renderer to render stuff on the window above and request GPU-Usage:
    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED) orelse {
        std.debug.print("Renderer could not be created: {s}\n", .{c.SDL_GetError()});
        return error.SDLRendererCreationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    var rect = Rectangle.init(350, 250);

    var quit = false;

    // This is the main loop - every cycle is a re-render:
    while (!quit) {
        var event: c.SDL_Event = undefined;
        // Process all pending events in the SDL event queue
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                // stop loop when window is closed
                c.SDL_QUIT => quit = true,
                c.SDL_KEYDOWN => {
                    switch (event.key.keysym.sym) {
                        c.SDLK_LEFT => rect.move(-1, 0),
                        c.SDLK_RIGHT => rect.move(1, 0),
                        c.SDLK_UP => rect.move(0, -1),
                        c.SDLK_DOWN => rect.move(0, 1),
                        c.SDLK_ESCAPE => quit = true,
                        else => {},
                    }
                },
                else => {},
            }
        }
        // Pick White Color
        _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);

        // Clear Window with picked color
        _ = c.SDL_RenderClear(renderer);

        // Pick Black Color
        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);

        // Declare Rectangle Position and Measurements
        const sdl_rect = c.SDL_Rect{
            .x = rect.x,
            .y = rect.y,
            .w = rect.width,
            .h = rect.height,
        };

        // draw rectangle from above with latest picked color
        _ = c.SDL_RenderFillRect(renderer, &sdl_rect);

        // Swap the back buffer with the front buffer (double buffering - one prepares, one shows)
        c.SDL_RenderPresent(renderer);
    }
}
