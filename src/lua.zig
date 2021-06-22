const c = @import("c.zig");

pub var L: *c.lua_State = undefined;

pub fn init(configFile: []const u8) void {
    L = c.luaL_newstate().?;

    c.luaL_openlibs(L);

    _ = c.luaL_loadfilex(L, configFile.ptr, null);
    _ = c.lua_pcall(L, 0, 0, 0);
}

fn initLuaFunctions() void {
    c.lua_pushcfunction(lua.L, luaCalPutText);
    c.lua_setglobal(lua.L, "puttext");
}

fn callLuaEventHandler(key: i32) void {
    _ = c.lua_getglobal(lua.L, "event");
    _ = c.lua_pushinteger(lua.L, key);

    _ = c.lua_pcall(lua.L, 1, 0, 0);
}

fn luaCalPutText(L: ?*c.lua_State) callconv(.C) c_int {
    const _text = c.lua_tolstring(L, 1, null);

    text.render(std.mem.sliceTo(_text, 0)) catch |err| return 0;

    return 0;
}
