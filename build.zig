const std = @import("std");

/// Represents package metadata
const PackageMeta = struct {
    name: []const u8,
    version: []const u8,
    description: []const u8,
};

/// Configure the build
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Define the executable
    const exe = b.addExecutable(.{
        .name = "nook",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Define internal modules
    const core_mod = b.createModule(.{
        .root_source_file = b.path("src/core/core.zig"),
    });
    const log_mod = b.createModule(.{
        .root_source_file = b.path("src/log/log.zig"),
    });
    const project_mod = b.createModule(.{
        .root_source_file = b.path("src/project/project.zig"),
    });
    const util_mod = b.createModule(.{
        .root_source_file = b.path("src/util/util.zig"),
    });

    // Add args dependency
    const args_dep = b.dependency("args", .{
        .target = target,
        .optimize = optimize,
    });

    // Configure build metadata
    const pkg_meta = parseMeta(b);
    const build_meta = b.addOptions();
    build_meta.addOption([]const u8, "name", pkg_meta.name);
    build_meta.addOption([]const u8, "version", pkg_meta.version);
    build_meta.addOption([]const u8, "description", pkg_meta.description);

    // Configure internal module imports

    // Add imports to root
    exe.root_module.addImport("core", core_mod);
    exe.root_module.addImport("log", log_mod);
    exe.root_module.addImport("project", project_mod);
    exe.root_module.addImport("util", util_mod);
    exe.root_module.addImport("args", args_dep.module("args"));
    exe.root_module.addOptions("build_meta", build_meta);

    b.installArtifact(exe);
}

/// Parses build.zig.zon into package metadata
fn parseMeta(b: *std.Build) PackageMeta {
    const contents = std.fs.cwd().readFileAlloc(
        b.allocator,
        "build.zig.zon",
        1024 * 10,
    ) catch @panic("Could not read build.zig.zon");

    return .{
        .name = "nook",
        .version = extractField(contents, "version") orelse "0.0.0",
        .description = extractField(contents, "description") orelse "",
    };
}

/// Extracts a field from the build.zig.zon contents
fn extractField(source: []const u8, field: []const u8) ?[]const u8 {
    var lines = std.mem.tokenizeScalar(u8, source, '\n');

    while (lines.next()) |line| {
        if (!std.mem.containsAtLeast(u8, line, 1, field)) continue;

        const start = std.mem.indexOfScalar(u8, line, '"') orelse continue;
        const after = line[start + 1 ..];
        const end = std.mem.indexOfScalar(u8, after, '"') orelse continue;

        return after[0..end];
    }

    return null;
}
