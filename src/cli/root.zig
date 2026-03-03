const cmd = @import("cmd.zig");
const log = @import("log");
const meta = @import("meta");
const std = @import("std");

const build_cmd = @import("build_cmd.zig");
const debug_cmd = @import("debug_cmd.zig");
const init_cmd = @import("init_cmd.zig");

/// The command registry
const commands = [_]cmd.Command{
    build_cmd.build,
    debug_cmd.debug,
    .{
        .name = "help",
        .description = "Display the Nook CLI help message",
        .callback = help,
    },
    init_cmd.init,
    .{
        .name = "version",
        .description = "Display the Nook version",
        .callback = version,
    },
};

/// Parse and handle command line arguments
pub fn handle(allocator: std.mem.Allocator) !u8 {
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
    for (commands) |c| {
        if (!std.mem.eql(u8, c.name, cmd_name)) continue;
        maybe_command = c;
        break;
    }

    // Error if command not found
    const command = maybe_command orelse {
        log.err("Command '{s}' does not exist", .{cmd_name});
        return 1;
    };

    // Parse positional args
    var pos_args: std.ArrayList(cmd.Arg) = .empty;
    defer pos_args.deinit(allocator);
    var arg_idx: usize = 2;
    const cmd_args = command.args orelse &[_]cmd.Arg{};

    if (args.len > 2) {
        for (args[2..args.len], 0..) |arg, i| {
            // All commands get the "help" arg
            if (i == 0 and std.mem.eql(u8, arg, "help")) {
                command.help();
                return 0;
            }

            // If this command takes more args, collect it
            if (i == cmd_args.len) break;
            try pos_args.append(allocator, .{
                .name = cmd_args[i].name,
                .description = cmd_args[i].description,
                .data_type = cmd_args[i].data_type,
                .value = arg,
            });

            arg_idx += 1;
        }
    }

    // Missing positional arguments
    if (pos_args.items.len < cmd_args.len) {
        for (cmd_args[pos_args.items.len..]) |arg| {
            log.err("Missing required argument: '{s}'", .{arg.name});
        }
        return 1;
    }

    // Parse options
    var opt_args: std.ArrayList(cmd.Option) = .empty;
    defer opt_args.deinit(allocator);
    const cmd_opts = command.options orelse &[_]cmd.Option{};

    while (arg_idx < args.len) : (arg_idx += 1) {
        // Find matching option
        const arg = args[arg_idx];
        var option: ?cmd.Option = null;
        for (cmd_opts) |opt| {
            if (opt.short != '\u{0}' and
                arg.len == 2 and
                arg[0] == '-' and
                arg[1] == opt.short)
            {
                option = opt;
                break;
            }

            if (!std.mem.startsWith(u8, arg, "--")) continue;
            if (std.mem.eql(u8, opt.long, std.mem.trimStart(u8, arg, "--"))) {
                option = opt;
                break;
            }
        }

        if (option) |opt| {
            try opt_args.append(allocator, .{
                .long = opt.long,
                .short = opt.short,
                .description = opt.description,
                .data_type = opt.data_type,
                .value = std.mem.trimStart(u8, std.mem.trimStart(u8, arg, "-"), "-"),
            });
        } else {
            log.err("Unknown option: '{s}'", .{arg});
            return 1;
        }
    }

    // Execute command
    if (command.callback()) |msg| {
        log.err("{s}", .{msg});
        return 1;
    }

    return 0;
}

/// Callback for the help command
pub fn help() ?[]const u8 {
    // Nook intro
    std.debug.print("{s}\n\n", .{meta.description});

    // Usage
    std.debug.print("{s}USAGE:{s}\n\t{s}{s} {s}[COMMAND] {s}[help|ARGS] {s}[--OPTIONS]{s}\n\n", .{
        log.BOLD,
        log.RESET,
        log.GREEN,
        meta.name,
        log.BLUE,
        log.YELLOW,
        log.MAGENTA,
        log.RESET,
    });

    // Measure spaces for command description aligment
    var spaces: usize = 0;
    for (commands) |command| {
        if (command.name.len > spaces) spaces = command.name.len;
    }

    // Commands list
    std.debug.print("{s}COMMANDS{s}:\n", .{
        log.BOLD,
        log.RESET,
    });
    for (commands) |command| {
        std.debug.print("\t{s}{s}{s}: ", .{
            log.BLUE,
            command.name,
            log.RESET,
        });

        // Align with spaces
        for (0..spaces - command.name.len) |_| {
            std.debug.print(" ", .{});
        }
        std.debug.print("{s}{s}{s}\n", .{
            log.DIM,
            command.description,
            log.RESET,
        });
    }

    return null;
}

/// Callback for the version command
fn version() ?[]const u8 {
    std.debug.print("{s} v{s}\n", .{ meta.name, meta.version });
    return null;
}
