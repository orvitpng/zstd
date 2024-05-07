const std = @import("std");

pub fn build(b: *std.Build) void {
    const root = b.path("./src/root.zig");
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("zstd", .{
        .root_source_file = root,
        .target = target,
        .optimize = optimize,
    });

    const tests = b.addTest(.{
        .root_source_file = root,
        .target = target,
        .optimize = optimize,
    });
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
