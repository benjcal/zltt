const std = @import("std");
const print = std.debug.print;

const c = @import("c.zig");

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        print("failed SDL init: {s}\n", .{c.SDL_GetError()});
    }

    const window = c.SDL_CreateWindow("Experiment", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 600, 400, c.SDL_WINDOW_SHOWN);
    if (window == null) {
        print("error on creatig window: {s}\n", .{c.SDL_GetError()});
    }

    const img = c.SDL_LoadBMP("src/zig.bmp");
    if (img == null) {
        print("error loading image: {s}\n", .{c.SDL_GetError()});
    }

    _ = c.SDLPango_Init();

    var context = c.SDLPango_CreateContext();
    c.SDLPango_SetDefaultColor(context, c.MATRIX_WHITE_BACK);
    c.SDLPango_SetMinimumSize(context, 640, 0);
    c.SDLPango_SetMarkup(context, "Hello <b>W<span foreground='red'>o</span><i>r</i><u>l</u>d</b>!", -1);
    const w = c.SDLPango_GetLayoutWidth(context);
    const h = c.SDLPango_GetLayoutHeight(context);

    const margin_x: c_int = 10;
    const margin_y: c_int = 10;
    var ws = c.SDL_GetWindowSurface(window);

    print("create surface: {s}\n", .{c.SDL_GetError()});

    var surface = c.SDL_CreateRGBSurface(0, w, h, 32, 0, 0, 0, 0);

    c.SDLPango_Draw(context, surface, margin_x, margin_y);
    print("error: {s}\n", .{c.SDL_GetError()});

    print("error: {s}\n", .{c.SDL_GetError()});
    _ = c.SDL_BlitSurface(surface, null, ws, null);
    print("error: {s}\n", .{c.SDL_GetError()});
    _ = c.SDL_UpdateWindowSurface(window);

    print("error: {s}\n", .{c.SDL_GetError()});
    c.SDL_Delay(2000);
}
