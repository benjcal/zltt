const std = @import("std");

const c = @import("c.zig");
const lua = @import("lua.zig");

pub var R: *c.SDL_Renderer = undefined;
pub var F: *c.TTF_Font = undefined;
pub var W: *c.SDL_Window = undefined;

pub fn init() !void {
    // init SDL
    _ = c.SDL_Init(c.SDL_INIT_VIDEO);

    // init fonts
    try initTTF();

    // make window
    const initWindowHeight: u32 = 800;
    const initWindowWidth: u32 = 600;

    const wFlags = c.SDL_WINDOW_RESIZABLE | c.SDL_WINDOW_SHOWN;

    W = c.SDL_CreateWindow(
        "Bolt",
        c.SDL_WINDOWPOS_CENTERED,
        c.SDL_WINDOWPOS_CENTERED,
        initWindowHeight,
        initWindowWidth,
        wFlags,
    ).?;

    // init renderer
    R = c.SDL_CreateRenderer(
        W,
        -1,
        c.SDL_RENDERER_ACCELERATED,
    ).?;

    // initial layout drawing
    drawLayout(800, 600);
    _ = c.SDL_RenderPresent(R);

    try renderTextMain("Hello World!\nthis is a new line\n\nadfaskdfhd");
    try renderTextSub("Hello World!");

    _ = c.SDL_StartTextInput();

    // start loop for events
    startEventLoop();
}

fn startEventLoop() void {
    _ = c.SDL_StartTextInput();

    while (true) {
        var ev: c.SDL_Event = undefined;
        _ = c.SDL_WaitEvent(&ev);

        switch (ev.type) {
            c.SDL_QUIT => break,

            c.SDL_TEXTINPUT => {
                if (ev.text.text[0] == 27) {
                    break;
                }
                // callLuaEventHandler(ev.text.text[0]);
            },

            else => continue,
        }
    }
}

fn drawLayout(w: c_int, h: c_int) void {
    // draw bg
    const bgRect = c.SDL_Rect{
        .x = 0,
        .y = 0,
        .w = w,
        .h = h,
    };
    _ = c.SDL_SetRenderDrawColor(R, 40, 44, 52, 255);
    _ = c.SDL_RenderFillRect(R, &bgRect);

    // get font height
    var fontHeight: c_int = undefined;
    _ = c.TTF_SizeText(F, "", null, &fontHeight);

    // draw mode line
    const modeRect = c.SDL_Rect{
        .x = 0,
        .y = h - fontHeight,
        .w = w,
        .h = fontHeight,
    };

    _ = c.SDL_SetRenderDrawColor(R, 44, 50, 61, 255);
    _ = c.SDL_RenderFillRect(R, &modeRect);
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

pub fn clearScreen() void {
    _ = c.SDL_RenderClear(R);
    drawLayout();
}

fn renderTextMain(text: []const u8) !void {
    var fgColor = c.SDL_Color{
        .r = 170,
        .g = 178,
        .b = 191,
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

    _ = c.SDL_RenderPresent(R);
}

fn renderTextSub(text: []const u8) !void {
    var w: c_int = undefined;
    var h: c_int = undefined;

    c.SDL_GetWindowSize(W, null, &h);

    var fgColor = c.SDL_Color{
        .r = 170,
        .g = 178,
        .b = 191,
        .a = 255,
    };

    const textSurface = c.TTF_RenderText_Blended(F, text.ptr, fgColor);

    const textTexture = c.SDL_CreateTextureFromSurface(R, textSurface);
    _ = c.SDL_FreeSurface(textSurface);

    var textHeight: c_int = undefined;
    var textWidth: c_int = undefined;

    _ = c.TTF_SizeText(F, text.ptr, &textWidth, &textHeight);

    const rect = c.SDL_Rect{ .x = 0, .y = h - textHeight, .h = textHeight, .w = textWidth };

    _ = c.SDL_RenderCopy(R, textTexture, null, &rect);
    _ = c.SDL_DestroyTexture(textTexture);

    _ = c.SDL_RenderPresent(R);
}
