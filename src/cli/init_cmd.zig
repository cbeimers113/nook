const cmd = @import("cmd.zig");

/// Command to create a new Nook project
pub const init: cmd.Command = .{
    .name = "init",
    .description = "Create a new Nook project",
    .callback = run,
};

/// Callback for the init command
fn run() ?[]const u8 {
    return null;
}
