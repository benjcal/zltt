const std = @import("std");

const c = @import("c.zig");
const sdl = @import("sdl.zig");

pub var L: *c.lua_State = undefined;

pub fn init(file: []const u8) void {
    L = c.luaL_newstate().?;

    c.luaL_openlibs(L);

    initLuaFunctions();
    if (c.luaL_loadfile(L, file.ptr) != c.LUA_OK) {
        std.log.crit("error loading lua file: {s}\n", .{c.lua_tolstring(L, -1, null)});
        return;
    }

    if (c.lua_pcall(L, 0, 0, 0) != c.LUA_OK) {
        std.log.crit("error runing lua file: {s}\n", .{c.lua_tolstring(L, -1, null)});
    }
}

fn initLuaFunctions() void {
    c.lua_pushcfunction(L, lPutMainText);
    c.lua_setglobal(L, "putMainText");

    c.lua_pushcfunction(L, lPutSubText);
    c.lua_setglobal(L, "putSubText");

    c.lua_pushcfunction(L, lSetMainBGColor);
    c.lua_setglobal(L, "setMainBGColor");

    c.lua_pushcfunction(L, lSetSubBGColor);
    c.lua_setglobal(L, "setSubBGColor");

    c.lua_pushcfunction(L, lSetMainTextColor);
    c.lua_setglobal(L, "setMainTextColor");

    c.lua_pushcfunction(L, lSetSubTextColor);
    c.lua_setglobal(L, "setSubTextColor");
}

pub fn handleInputEvent(key: i32) void {
    c.lua_getglobal(L, "handleInputEvent");
    _ = c.lua_pushinteger(L, key);

    if (c.lua_pcall(L, 1, 0, 0) != c.LUA_OK) {
        std.log.crit("error runing lua function: {s}\n", .{c.lua_tolstring(L, -1, null)});
    }
}

pub fn lPutMainText(ls: ?*c.lua_State) callconv(.C) c_int {
    const _text = c.lua_tolstring(ls, 1, null);

    sdl.putMainText(std.mem.sliceTo(_text, 0));

    return 0;
}

pub fn lPutSubText(ls: ?*c.lua_State) callconv(.C) c_int {
    const _text = c.lua_tolstring(ls, 1, null);

    sdl.putSubText(std.mem.sliceTo(_text, 0));

    return 0;
}

pub fn lSetMainBGColor(ls: ?*c.lua_State) callconv(.C) c_int {
    const r = c.lua_tointeger(ls, 1);
    const g = c.lua_tointeger(ls, 2);
    const b = c.lua_tointeger(ls, 3);

    sdl.setMainBGColor(@intCast(u8, r), @intCast(u8, g), @intCast(u8, b));

    return 0;
}

pub fn lSetSubBGColor(ls: ?*c.lua_State) callconv(.C) c_int {
    const r = c.lua_tointeger(ls, 1);
    const g = c.lua_tointeger(ls, 2);
    const b = c.lua_tointeger(ls, 3);

    sdl.setSubBGColor(@intCast(u8, r), @intCast(u8, g), @intCast(u8, b));

    return 0;
}

pub fn lSetMainTextColor(ls: ?*c.lua_State) callconv(.C) c_int {
    const r = c.lua_tointeger(ls, 1);
    const g = c.lua_tointeger(ls, 2);
    const b = c.lua_tointeger(ls, 3);

    sdl.setMainTextColor(@intCast(u8, r), @intCast(u8, g), @intCast(u8, b));

    return 0;
}

pub fn lSetSubTextColor(ls: ?*c.lua_State) callconv(.C) c_int {
    const r = c.lua_tointeger(ls, 1);
    const g = c.lua_tointeger(ls, 2);
    const b = c.lua_tointeger(ls, 3);

    sdl.setSubTextColor(@intCast(u8, r), @intCast(u8, g), @intCast(u8, b));

    return 0;
}
