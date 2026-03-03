const cmd = @import("cmd.zig");

/// Command for debugging the CLI
pub const debug: cmd.Command = .{
    .name = "debug",
    .description = "Debug the Nook CLI",
    .args = &debug_args,
    .options = &debug_opts,
    .callback = run,
};

/// Args for the debug command
const debug_args = [_]cmd.Arg{
    .{
        .name = "foo",
        .description = "A string argument",
        .data_type = .string,
    },
    .{
        .name = "bar",
        .description = "An int argument",
        .data_type = .int,
    },
    .{
        .name = "baz",
        .description = "A bool argument",
        .data_type = .flag,
    },
    .{
        .name = "zap",
        .description = "A float argument",
        .data_type = .float,
    },
};

/// Options for the debug command
const debug_opts = [_]cmd.Option{
    .{
        .long = "string",
        .short = 's',
        .description = "A string option",
        .data_type = .string,
    },
    .{
        .long = "int",
        .short = 'i',
        .description = "An int option",
        .data_type = .int,
    },
    .{
        .long = "bool",
        .short = 'b',
        .description = "A bool/flag option",
        .data_type = .flag,
    },
    .{
        .long = "float",
        .short = 'f',
        .description = "A float option",
        .data_type = .float,
    },
};

/// Callback for the debug command
fn run() ?[]const u8 {
    return null;
}
