const std = @import("std");
const c = @import("c.zig");
const lua = @import("lua.zig");

var window: *c.SDL_Window = undefined;

// Main BG Color
var MBGR: u8 = 0;
var MBGG: u8 = 0;
var MBGB: u8 = 0;

// Sub BG Color
var SBGR: u8 = 0;
var SBGG: u8 = 0;
var SBGB: u8 = 0;

// Main Text Color
var MTCR: u8 = 255;
var MTCG: u8 = 255;
var MTCB: u8 = 255;

// Sub Text Color
var STCR: u8 = 255;
var STCG: u8 = 255;
var STCB: u8 = 255;

var main_text_buffer: []u8 = undefined;
var sub_text_buffer: []u8 = undefined;

pub fn putMainText(text: []const u8) void {
    std.mem.copy(u8, main_text_buffer, text);
    main_text_buffer[text.len] = 0;
    redraw() catch |err| return;
}

pub fn putSubText(text: []const u8) void {
    std.mem.copy(u8, sub_text_buffer, text);
    sub_text_buffer[text.len] = 0;
    redraw() catch |err| return;
}

pub fn setMainBGColor(r: u8, g: u8, b: u8) void {
    MBGR = r;
    MBGG = g;
    MBGB = b;
    redraw() catch |err| return;
}

pub fn setSubBGColor(r: u8, g: u8, b: u8) void {
    SBGR = r;
    SBGG = g;
    SBGB = b;
    redraw() catch |err| return;
}

pub fn setMainTextColor(r: u8, g: u8, b: u8) void {
    MTCR = r;
    MTCG = g;
    MTCB = b;
    redraw() catch |err| return;
}

pub fn setSubTextColor(r: u8, g: u8, b: u8) void {
    STCR = r;
    STCG = g;
    STCB = b;
    redraw() catch |err| return;
}

pub fn init() !void {
    // initialize memory
    main_text_buffer = try std.heap.c_allocator.alloc(u8, 10_000);
    sub_text_buffer = try std.heap.c_allocator.alloc(u8, 1_000);

    std.mem.copy(u8, main_text_buffer, "\x00");
    std.mem.copy(u8, sub_text_buffer, "\x00");

    // init SDL
    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        std.log.crit("error on initializing SDL {s}\n", .{c.SDL_GetError()});
        return error.ErrorInitializingSDL;
    }

    // make window
    const init_window_width: u32 = 800;
    const init_window_height: u32 = 600;

    const w_flags = c.SDL_WINDOW_RESIZABLE | c.SDL_WINDOW_SHOWN;

    window = c.SDL_CreateWindow(
        "zltt",
        c.SDL_WINDOWPOS_CENTERED,
        c.SDL_WINDOWPOS_CENTERED,
        init_window_width,
        init_window_height,
        w_flags,
    ).?;

    // start text input to receive the proper keys on keypress
    c.SDL_StartTextInput();
}

pub fn showSurface(src: *c.SDL_Surface) !void {
    const screen = c.SDL_GetWindowSurface(window);

    if (c.SDL_BlitSurface(src, null, screen, null) != 0) {
        std.log.crit("error SDL blitting surface to screen {s}\n", .{c.SDL_GetError()});
        return error.ErrorBlittingToScreen;
    }

    if (c.SDL_UpdateWindowSurface(window) != 0) {
        std.log.crit("error SDL updating window surface {s}\n", .{c.SDL_GetError()});
        return error.ErrorBlittingToScreen;
    }

    c.SDL_Delay(2000);
}

fn redraw() !void {
    _ = c.SDL_RenderClear(R);

    var w: c_int = undefined;
    var h: c_int = undefined;

    c.SDL_GetWindowSize(W, &w, &h);

    const fh = c.TTF_FontHeight(F);

    const s = c.SDL_CreateRGBSurface(0, w, h, 32, 0, 0, 0, 0);

    const mainRect = c.SDL_Rect{
        .x = 0,
        .y = 0,
        .w = w,
        .h = h - fh,
    };

    const subRect = c.SDL_Rect{
        .x = 0,
        .y = h - fh,
        .w = w,
        .h = fh,
    };

    _ = c.SDL_FillRect(s, &mainRect, c.SDL_MapRGBA(s.*.format, MBGR, MBGG, MBGB, 255));
    _ = c.SDL_FillRect(s, &subRect, c.SDL_MapRGBA(s.*.format, SBGR, SBGG, SBGB, 255));

    const t = c.SDL_CreateTextureFromSurface(R, s);

    _ = c.SDL_RenderCopy(R, t, null, null);

    try renderTextMain(main_text_buffer);
    try renderTextSub(sub_text_buffer);
    _ = c.SDL_RenderPresent(R);
}

pub fn startEventLoop() void {
    // _ = c.SDL_StartTextInput();

    while (true) {
        var ev: c.SDL_Event = undefined;
        _ = c.SDL_WaitEvent(&ev);

        switch (ev.type) {
            c.SDL_WINDOWEVENT => {
                if (ev.window.event == c.SDL_WINDOWEVENT_RESIZED) {
                    redraw() catch |_| continue;
                }
            },

            c.SDL_QUIT => break,

            c.SDL_KEYDOWN => {
                switch (ev.key.keysym.sym) {
                    13, 27, 8 => lua.handleInputEvent(ev.key.keysym.sym),
                    else => continue,
                }
            },

            c.SDL_TEXTINPUT => {
                if (ev.text.text[0] == 27) {
                    break;
                }
                lua.handleInputEvent(ev.text.text[0]);
            },

            else => continue,
        }
    }
}

fn initTTF() !void {
    // init fontconfig
    const fc = c.FcInitLoadConfigAndFonts();

    // select font to use
    const pat = c.FcNameParse("Hack");
    c.FcDefaultSubstitute(pat);

    var result: c.FcResult = undefined;
    const font = c.FcFontMatch(fc, pat, &result);

    var file: ?[*:0]u8 = undefined;
    _ = c.FcPatternGetString(font, c.FC_FILE, 0, &file);

    _ = c.TTF_Init();

    F = c.TTF_OpenFont(file, 16).?;
}

fn renderTextMain(text: []const u8) !void {
    var fgColor = c.SDL_Color{
        .r = MTCR,
        .g = MTCG,
        .b = MTCB,
        .a = 255,
    };

    var lines = std.mem.split(text, "\n");
    var lineCount: c_int = 0;

    while (true) {
        if (lines.next()) |line| {
            const len = line.len;

            // allocate space for new line + null terminator
            const newLine = try std.heap.c_allocator.alloc(u8, len + 1);

            // copy line on memory
            std.mem.copy(u8, newLine, line);

            // null terminate newLine
            newLine[len] = 0;

            const textSurface = c.TTF_RenderText_Blended(F, newLine.ptr, fgColor);

            const textTexture = c.SDL_CreateTextureFromSurface(R, textSurface);
            _ = c.SDL_FreeSurface(textSurface);

            var textHeight: c_int = undefined;
            var textWidth: c_int = undefined;
            _ = c.TTF_SizeText(F, newLine.ptr, &textWidth, &textHeight);

            const rect = c.SDL_Rect{ .x = 0, .y = textHeight * lineCount, .h = textHeight, .w = textWidth };

            _ = c.SDL_RenderCopy(R, textTexture, null, &rect);
            _ = c.SDL_DestroyTexture(textTexture);
            lineCount += 1;
        } else {
            break;
        }
    }
}

fn renderTextSub(text: []const u8) !void {
    var h: c_int = undefined;

    c.SDL_GetWindowSize(W, null, &h);

    var textHeight: c_int = undefined;
    var textWidth: c_int = undefined;

    _ = c.TTF_SizeText(F, text.ptr, &textWidth, &textHeight);

    var fgColor = c.SDL_Color{
        .r = STCR,
        .g = STCG,
        .b = STCB,
        .a = 255,
    };

    const textSurface = c.TTF_RenderText_Blended(F, text.ptr, fgColor);

    const textTexture = c.SDL_CreateTextureFromSurface(R, textSurface);
    _ = c.SDL_FreeSurface(textSurface);

    const rect = c.SDL_Rect{ .x = 0, .y = h - textHeight, .h = textHeight, .w = textWidth };

    _ = c.SDL_RenderCopy(R, textTexture, null, &rect);
    _ = c.SDL_DestroyTexture(textTexture);
}
