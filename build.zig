const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const xiph_opus_tools = b.dependency("xiph-opus-tools", .{});

    const lib = b.addStaticLibrary(.{
        .name = "opus-tools",
        .target = target,
        .optimize = optimize,
    });

    lib.defineCMacro("OUTSIDE_SPEEX", "");
    lib.defineCMacro("RANDOM_PREFIX", b.option([]const u8, "random-prefix",
        \\A prefix to give to all public functions, 
        \\to avoid collisions when linking against 
        \\speex separately (defaults to 'speex').
    ) orelse "speex");

    if (b.option(bool, "fixed-point", "Enable fixed point") orelse false) {
        lib.defineCMacro("FIXED_POINT", "1");
    }

    if (target.result.cpu.arch.isAARCH64() or target.result.cpu.arch.isARM()) {
        const neon = target.result.cpu.features.isEnabled(
            @intFromEnum(std.Target.aarch64.Feature.neon),
        ) or target.result.cpu.features.isEnabled(
            @intFromEnum(std.Target.arm.Feature.neon),
        );

        if (neon) {
            lib.defineCMacro("USE_NEON", "1");
        }
    }

    if (target.result.cpu.arch.isX86()) {
        const sse = target.result.cpu.features.isEnabled(
            @intFromEnum(std.Target.x86.Feature.sse),
        );
        if (sse) {}
    }

    // "resample_neon.h" is missing from the upstream and for some
    // reason nobody cared to put it back there, see
    // https://github.com/xiph/opus-tools/issues/60#issuecomment-830678017
    lib.addIncludePath(b.path("include/"));
    lib.addIncludePath(xiph_opus_tools.path("src/"));
    lib.addCSourceFiles(.{
        .root = xiph_opus_tools.path("src"),
        .files = &.{
            "resample.c",
        },
    });
    lib.linkLibC();

    lib.installHeader(
        xiph_opus_tools.path("src/speex_resampler.h"),
        "speex_resampler.h",
    );

    b.installArtifact(lib);
}
