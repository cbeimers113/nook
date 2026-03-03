const cmd = @import("cmd.zig");
const option = @import("option.zig");
const std = @import("std");

/// Command to build a Nook project
pub const command: cmd.Command = .{
    .name = "build",
    .description = "Build a Nook project",
    .options = &options,
    .callback = run,
};

/// Options for the build command
const options = [_]option.Option{
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
    option.help_option,
};

/// Register the build comand
pub fn register(allocator: std.mem.Allocator) !void {
    try cmd.commands.append(allocator, command);
}

/// Callback for the build command
fn run() ?[]const u8 {
    return null;
}
