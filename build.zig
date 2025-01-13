const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "moving_rectangle_with_zig_and_sdl2",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    if (target.result.os.tag == .windows) {
        std.debug.print("Building for Windows\n", .{});
        const sdl_path = std.process.getEnvVarOwned(b.allocator, "SDL2_PATH") catch {
            std.debug.print("SDL2_PATH is missing in env\n", .{});
            return;
        };
        defer b.allocator.free(sdl_path);
        exe.linkLibC();

        exe.addIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{sdl_path}) });
        exe.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib/x64", .{sdl_path}) });

        exe.linkSystemLibrary("SDL2");
        exe.linkSystemLibrary("SDL2main");
        exe.linkSystemLibrary("shell32");

        const dll_path = std.fs.path.join(
            b.allocator,
            &[_][]const u8{ sdl_path, "lib", "x64", "SDL2.dll" },
        ) catch unreachable;
        defer b.allocator.free(dll_path);

        const install_step = b.addInstallFileWithDir(
            .{ .cwd_relative = dll_path },
            .bin,
            "SDL2.dll",
        );
        b.getInstallStep().dependOn(&install_step.step);
    } else {
        std.debug.print("Building for MacOs\n", .{});
        exe.linkSystemLibrary("SDL2");
        exe.linkFramework("CoreServices");
        exe.linkFramework("CoreGraphics");
        exe.linkFramework("Foundation");
        exe.addIncludePath(.{ .cwd_relative = "/opt/homebrew/include" });
        exe.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/lib" });
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
