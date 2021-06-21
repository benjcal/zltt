const std = @import("std");
const print = std.debug.print;

const allocator = std.heap.c_allocator;

const strings = @import("strings.zig");
const lua = @import("lua.zig");
const c = @import("c.zig");

var R: *c.SDL_Renderer = undefined;
var F: *c.TTF_Font = undefined;

pub fn init() !void {
    // init SDL
    _ = c.SDL_Init(c.SDL_INIT_VIDEO);

    // init fonts
    try initTTF();

    // make window
    const wFlags = c.SDL_WINDOW_RESIZABLE | c.SDL_WINDOW_SHOWN;
    const window = c.SDL_CreateWindow("Bolt", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, 800, 600, wFlags);

    // init renderer
    R = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED).?;

    // initial layout drawing
    drawLayout();
    _ = c.SDL_RenderPresent(R);

    initLuaFunctions();

    // start loop for events
    startEventLoop();
}

fn startEventLoop() void {
    while (true) {
        var ev: c.SDL_Event = undefined;
        _ = c.SDL_WaitEvent(&ev);

        switch (ev.type) {
            c.SDL_QUIT => break,

            c.SDL_KEYDOWN => {
                if (ev.key.keysym.sym == 27) {
                    break;
                }
                callLuaEventHandler(ev.key.keysym.sym);
            },

            else => continue,
        }
    }
}

fn drawLayout() void {
    // draw bg
    const bgRect = c.SDL_Rect{
        .x = 0,
        .y = 0,
        .w = 800,
        .h = 600,
    };
    _ = c.SDL_SetRenderDrawColor(R, 40, 44, 52, 255);
    _ = c.SDL_RenderFillRect(R, &bgRect);

    // get font height
    var fontHeight: c_int = undefined;
    _ = c.TTF_SizeText(F, "", null, &fontHeight);

    // draw mode line
    const modeRect = c.SDL_Rect{
        .x = 0,
        .y = 600 - (fontHeight * 2),
        .w = 800,
        .h = 19,
    };
    _ = c.SDL_SetRenderDrawColor(R, 44, 50, 61, 255);
    _ = c.SDL_RenderFillRect(R, &modeRect);
}

fn initLuaFunctions() void {
    c.lua_pushcfunction(lua.L, luaCalPutText);
    c.lua_setglobal(lua.L, "puttext");
}

fn initTTF() !void {
    // init fontconfig
    const fc = c.FcInitLoadConfigAndFonts();

    // select font to use
    const pat = c.FcNameParse("Hack:style=Bold");
    c.FcDefaultSubstitute(pat);

    var result: c.FcResult = undefined;

    const font = c.FcFontMatch(fc, pat, &result);

    var file: ?[*:0]u8 = undefined;

    _ = c.FcPatternGetString(font, c.FC_FILE, 0, &file);

    _ = c.TTF_Init();

    F = c.TTF_OpenFont(file, 16).?;
}

fn putText(text: []const u8) void {
    // clear renderer
    _ = c.SDL_RenderClear(R);
    drawLayout();

    const textColor = c.SDL_Color{
        .r = 170,
        .g = 178,
        .b = 191,
        .a = 255,
    };

    var textHeight: c_int = undefined;
    var textWidth: c_int = undefined;

    // split in lines
    var lines = std.mem.split(text, "|");

    var i: c_int = 0;
    while (true) {
        const line = lines.next();
        if (line != null) {
            const l = line.?;
            const textSurface = c.TTF_RenderText_Blended(F, l.ptr, textColor);
            const textTexture = c.SDL_CreateTextureFromSurface(R, textSurface);

            _ = c.TTF_SizeText(F, l.ptr, &textWidth, &textHeight);
            const rect = c.SDL_Rect{ .x = 0, .y = textHeight * i, .h = textHeight, .w = textWidth };
            _ = c.SDL_RenderCopy(R, textTexture, null, &rect);
        } else {
            break;
        }
        i = i + 1;
    }

    _ = c.SDL_RenderPresent(R);
}

fn callLuaEventHandler(key: i32) void {
    _ = c.lua_getglobal(lua.L, "event");
    _ = c.lua_pushinteger(lua.L, key);

    _ = c.lua_pcallk(lua.L, 1, 0, 0, 0, null);
}

fn luaCalPutText(L: ?*c.lua_State) callconv(.C) c_int {
    const text = c.lua_tolstring(L, 1, null);

    putText(std.mem.sliceTo(text, 0));

    return 0;
}

test "sample test" {
    try std.testing.expect(2 == 2);
}
