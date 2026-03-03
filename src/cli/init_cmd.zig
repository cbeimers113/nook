const cmd = @import("cmd.zig");

/// Command to create a new Nook project
pub const init: cmd.Command = .{
    .name = "init",
    .description = "Create a new Nook project",
    .options = &init_opts,
    .callback = run,
};

/// Options for the init command
const init_opts = [_]cmd.Option{cmd.help_option};

/// Callback for the init command
fn run() ?[]const u8 {
    return null;
}
