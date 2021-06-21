const std = @import("std");

pub fn concat(dst: []u8, src: []u8) !void {
    var lastIndex = std.mem.indexOf(u8, dst, "\x00");
    if (lastIndex) |index| {
        for (src) |ch, i| {
            dst[index + i] = ch;
        }
    }
}

pub fn zero(str: []u8) void {
    for (str) |*ch| {
        ch.* = 0;
    }
}
