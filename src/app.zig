const sdl = @import("sdl.zig");
const lua = @import("lua.zig");
const cairo = @import("cairo.zig");

pub const Text = struct {
    content: []const u8,
    font: []const u8,
    width: i32,
    height: i32,
    fg: Color,
    bg: Color,
};

pub const Markup = struct {
    content: []const u8,
    width: i32,
    height: i32,
    bg: Color,
};

pub const Color = struct {
    r: f32,
    g: f32,
    b: f32,
};

pub fn init() !void {
    // init function work
    // init SDL
    try sdl.init();
    try lua.init();

    const m = Markup{
        .content = "<span foreground='#abb2bf' font_desc='Hack 12'>sadf;lkajdsf;lkj\nnew line</span>",
        .width = 800,
        .height = 600,
        .bg = Color{
            .r = 0.2,
            .g = 0.2,
            .b = 0.6,
        },
    };

    const s = try cairo.getSurfFromMarkup(m);
    try sdl.showSurface(s);
    // populate lua functions
}

pub fn run() !void {
    // main loop
    // run SDL event check loop
}
