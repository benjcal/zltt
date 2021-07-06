const std = @import("std");

const app = @import("app.zig");

// const sdl = @import("sdl.zig");
// const lua = @import("lua.zig");
// const config = @import("config.zig");
// const c = @import("c.zig");

pub fn main() !void {
    try app.init();
    // render init
    // render run

    // try sdl.init();

    // const luaFile = std.mem.sliceTo(std.os.argv[1], 0);
    // lua.init(luaFile);

    // sdl.startEventLoop();
}
