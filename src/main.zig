const std = @import("std");

const sdl = @import("sdl.zig");
const lua = @import("lua.zig");
const config = @import("config.zig");
const c = @import("c.zig");

pub fn main() !void {
    lua.init("lua/config.lua");

    const config1 = config.getFromLuaState(lua.L);

    try sdl.init();
}
