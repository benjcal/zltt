const std = @import("std");
const print = std.debug.print;

const c = @import("c.zig");

const Config = struct {
    fontFace: []const u8,
    fontSize: u8,
};

pub fn getFromLuaState(L: *c.lua_State) Config {
    _ = c.lua_getglobal(L, "font_face");
    const fontFace = c.lua_tolstring(L, -1, null);

    _ = c.lua_getglobal(L, "font_size");
    const fontSize = c.lua_tointegerx(L, -1, null);

    var config = Config{
        .fontFace = std.mem.sliceTo(fontFace, 0),
        .fontSize = @intCast(u8, fontSize),
    };

    return config;
}
