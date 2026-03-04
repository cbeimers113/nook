const cmd = @import("cmd.zig");
const log = @import("log");
const std = @import("std");

const cmd_build = @import("cmd_build.zig");
const cmd_debug = @import("cmd_debug.zig");
const cmd_help = @import("cmd_help.zig");
const cmd_init = @import("cmd_init.zig");
const cmd_version = @import("cmd_version.zig");

/// Parse and handle command line arguments
pub fn handle(allocator: std.mem.Allocator) !u8 {
    // Register commands
    defer cmd.commands.deinit(allocator);
    try cmd_build.register(allocator);
    try cmd_debug.register(allocator);
    try cmd_help.register(allocator);
    try cmd_init.register(allocator);
    try cmd_version.register(allocator);

    // Get command line args
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Determine the command; no command given = help command
    var cmd_name: []const u8 = "help";
    if (args.len > 1) {
        cmd_name = args[1];
    }

    // Check if the command exists
    var maybe_command: ?cmd.Command = null;
    for (cmd.commands.items) |command| {
        if (!std.mem.eql(u8, command.name, cmd_name)) continue;
        maybe_command = command;
        break;
    }

    // Error if command not found
    const command = maybe_command orelse {
        log.err("Command '{s}' does not exist", .{cmd_name});
        return 1;
    };

    // Collect positional and optional arguments
    var pos_args: std.ArrayList(cmd.Arg) = .empty;
    defer pos_args.deinit(allocator);
    var opt_args: std.ArrayList(cmd.Option) = .empty;
    defer opt_args.deinit(allocator);

    // Null-coalesce this command's supported arguments
    const cmd_args = command.args orelse &[_]cmd.Arg{};
    const cmd_options = command.options orelse &[_]cmd.Option{};

    // Parse each user-provided argument
    for (args, 0..) |arg, i| {
        if (i < 2) continue;

        // Positional arg; check if we require more
        if (arg[0] != '-') {
            const count = pos_args.items.len;
            if (count == cmd_args.len) {
                log.err("Extra argument provided: '{s}'", .{arg});
                return 1;
            }

            const cmd_arg = cmd_args[count];
            try pos_args.append(allocator, .{
                .name = cmd_arg.name,
                .description = cmd_arg.description,
                .data_type = cmd_arg.data_type,
                .value = arg,
            });
            continue;
        }

        // Optional arg; check if we recognize it
        var maybe_option: ?cmd.Option = null;
        for (cmd_options) |option| {

            // Check for matching short identifier
            if (option.short != '\u{0}' and
                arg.len == 2 and
                arg[0] == '-' and
                arg[1] == option.short)
            {
                maybe_option = option;
                break;
            }

            // Check for matching long identifier
            if (!std.mem.startsWith(u8, arg, "--")) continue;
            if (std.mem.eql(u8, option.long, std.mem.trimStart(u8, arg, "--"))) {
                maybe_option = option;
                break;
            }
        }

        if (maybe_option) |option| {
            try opt_args.append(allocator, .{
                .long = option.long,
                .short = option.short,
                .description = option.description,
                .data_type = option.data_type,
                .value = std.mem.trimStart(u8, std.mem.trimStart(u8, arg, "-"), "-"),
            });
            continue;
        }

        log.err("Unknown option: '{s}'", .{arg});
        return 1;
    }

    // Help option takes precedence
    for (opt_args.items) |option| {
        if (!option.eq(cmd.help_option)) continue;
        command.help();
        return 0;
    }

    // Check for missing positional arguments
    if (pos_args.items.len < cmd_args.len) {
        for (cmd_args[pos_args.items.len..]) |arg| {
            log.err("Missing required argument: '{s}'", .{arg.name});
        }
        return 1;
    }

    // Execute command
    if (command.callback()) |msg| {
        log.err("{s}", .{msg});
        return 1;
    }

    return 0;
}
