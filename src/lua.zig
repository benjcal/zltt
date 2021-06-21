const c = @import("c.zig");

pub var L: *c.lua_State = undefined;

pub fn init(configFile: []const u8) void {
    L = c.luaL_newstate().?;

    c.luaL_openlibs(L);

    _ = c.luaL_loadfilex(L, configFile.ptr, null);
    _ = c.lua_pcallk(L, 0, 0, 0, 0, null);
}
