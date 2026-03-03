const cmd = @import("cmd.zig");

/// Command to build a Nook project
pub const build: cmd.Command = .{
    .name = "build",
    .description = "Build a Nook project",
    .options = &build_opts,
    .callback = run,
};

/// Options for the build command
const build_opts = [_]cmd.Option{
    .{
        .long = "out",
        .short = 'o',
        .description = "Output file name, default = module name",
        .data_type = .string,
    },
    .{
        .long = "verbose",
        .short = 'v',
        .description = "Enable verbose logging",
        .data_type = .flag,
    },
    cmd.help_option,
};

/// Callback for the build command
fn run() ?[]const u8 {
    return null;
}
