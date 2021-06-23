const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const libs = [_][]const u8{
        "c",
        "SDL2",
        "SDL2_ttf",
        "fontconfig",
        "luajit-5.1",
    };

    const tests = b.addTest("src/tests.zig");
    tests.setBuildMode(mode);
    for (libs) |lib| {
        tests.linkSystemLibrary(lib);
    }

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&tests.step);

    const exe = b.addExecutable("zig-sdl", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    for (libs) |lib| {
        exe.linkSystemLibrary(lib);
    }
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    run_cmd.addArg("lua/init.lua");

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
