const cmd = @import("cmd.zig");
const std = @import("std");

/// Command to create a new Nook project
pub const command: cmd.Command = .{
    .name = "init",
    .description = "Create a new Nook project",
    .options = &options,
    .callback = run,
};

/// Options for the init command
const options = [_]cmd.Option{cmd.help_option};

/// Register the init comand
pub fn register(allocator: std.mem.Allocator) !void {
    try cmd.commands.append(allocator, command);
}

/// Callback for the init command
fn run() ?[]const u8 {
    return null;
}
