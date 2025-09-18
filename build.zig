const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const zlogModule = b.addModule("zlog", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "demo",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/demo.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.root_module.addImport("zlog", zlogModule);

    const demo_step = b.step("run", "Run demo file");
    const run_demo = b.addRunArtifact(exe);
    demo_step.dependOn(&run_demo.step);

    if (b.option(bool, "install-demo", "install the demo too") orelse false) {
        b.installArtifact(exe);
    }

    const test_step = b.step("test", "Run unit tests");
    const unit_tests = b.addTest(.{
        .root_module = b.createModule(.{ .root_source_file = b.path("tests/log_levels.zig"), .target = target, .optimize = optimize }),
        .test_runner = .{
            .path = b.path("tests/test_runner.zig"),
            .mode = .simple,
        },
    });
    unit_tests.root_module.addImport("zlog", zlogModule);
    const run_unit_tests = b.addRunArtifact(unit_tests);
    test_step.dependOn(&run_unit_tests.step);
}
