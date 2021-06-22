const std = @import("std");
const expect = std.testing.expect;

const c = @import("c.zig");
const sdl = @import("sdl.zig");

pub fn render(text: []const u8) !void {
    var lineBuffer: [256]u8 = [_]u8{0} ** 256;
    var tagBuffer: [64]u8 = undefined;
    var fgColor = c.SDL_Color{
        .r = 255,
        .g = 255,
        .b = 255,
        .a = 255,
    };

    var bgColor = c.SDL_Color{
        .r = 0,
        .g = 0,
        .b = 0,
        .a = 255,
    };

    var i: usize = 0;

    // start by clearing the screen
    sdl.clearScreen();

    var currLine: u16 = 0;
    var linePos: u16 = 0;
    while (i < text.len) {
        if (text[i] == '<') {
            // render text before tag
            const textSurface = c.TTF_RenderText_Blended(sdl.F, &lineBuffer, fgColor);

            const textTexture = c.SDL_CreateTextureFromSurface(sdl.R, textSurface);
            _ = c.SDL_FreeSurface(textSurface);

            var textHeight: c_int = undefined;
            var textWidth: c_int = undefined;
            _ = c.TTF_SizeText(sdl.F, &lineBuffer, &textWidth, &textHeight);

            const rect = c.SDL_Rect{ .x = 0, .y = textHeight * currLine, .h = textHeight, .w = textWidth };

            _ = c.SDL_RenderCopy(sdl.R, textTexture, null, &rect);
            _ = c.SDL_DestroyTexture(textTexture);

            // start iterating to get the tag value
            var j: usize = 0;
            i += 1;
            while (text[i] != '>') {
                tagBuffer[j] = text[i];
                i += 1;
                j += 1;
            }

            // Background color tag
            if (tagBuffer[0] == 'B') {
                const hex = tagBuffer[1..7];
                bgColor = try getColor(hex);

                // set bg color to c
                tagBuffer = [_]u8{0} ** 64;
                continue;
            }

            // Foreground color tag
            if (tagBuffer[0] == 'F') {
                const hex = tagBuffer[1..7];
                fgColor = try getColor(hex);
                // set fg color to c
                tagBuffer = [_]u8{0} ** 64;
                continue;
            }

            // New line tag
            if (tagBuffer[0] == 'N') {
                // start new line
                tagBuffer = [_]u8{0} ** 64;
                continue;
            }

            // render regular text

        } else {
            lineBuffer[linePos] = text[i];
            linePos += 1;
        }
        i += 1;
    }

    _ = c.SDL_RenderPresent(sdl.R);
}

fn hexToInt(hex: u8) u8 {
    switch (hex) {
        '0' => return 0,
        '1' => return 1,
        '2' => return 2,
        '3' => return 3,
        '4' => return 4,
        '5' => return 5,
        '6' => return 6,
        '7' => return 7,
        '8' => return 8,
        '9' => return 9,
        'A', 'a' => return 10,
        'B', 'b' => return 11,
        'C', 'c' => return 12,
        'D', 'd' => return 13,
        'E', 'e' => return 14,
        'F', 'f' => return 15,
        else => unreachable,
    }
}

test "hexToInt test" {
    try expect(hexToInt('0') == 0);
    try expect(hexToInt('F') == 15);
}

fn getColor(hexColor: []const u8) !c.SDL_Color {
    if (hexColor.len > 6) {
        return error.InvalidHexColor;
    }

    return c.SDL_Color{
        .r = hexToInt(hexColor[0]) * 16 + hexToInt(hexColor[1]),
        .g = hexToInt(hexColor[2]) * 16 + hexToInt(hexColor[3]),
        .b = hexToInt(hexColor[4]) * 16 + hexToInt(hexColor[5]),
        .a = 255,
    };
}

test "getColor test" {
    const c = try getColor("FFFFFF");
    try expect(c.r == 255);
    try expect(c.g == 255);
    try expect(c.b == 255);

    const c1 = try getColor("00FF00");
    try expect(c1.r == 0);
    try expect(c1.g == 255);
    try expect(c1.b == 0);
}
