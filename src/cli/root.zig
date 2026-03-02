const cmd = @import("cmd.zig");
const log = @import("log");
const meta = @import("meta");
const std = @import("std");

const build_cmd = @import("build_cmd.zig");
const init_cmd = @import("init_cmd.zig");

/// The command registry
var commands: std.ArrayList(cmd.Command) = .empty;

/// Parse and handle command line arguments
pub fn handle(allocator: std.mem.Allocator) !u8 {
    defer commands.deinit(allocator);

    // Register the commands
    // ---------------------

    // Top-level commands
    try commands.append(allocator, .{
        .name = "help",
        .description = "Display the Nook CLI help message",
        .callback = help,
    });
    try commands.append(allocator, .{
        .name = "version",
        .description = "Display the Nook version",
        .callback = version,
    });
    try commands.append(allocator, .{
        .name = "init",
        .description = "Create a new Nook project",
        .callback = init_cmd.run,
    });

    // Build command
    var build_opts: std.ArrayList(cmd.Option) = try .initCapacity(allocator, 2);
    defer build_opts.deinit(allocator);
    try build_opts.append(allocator, .{
        .long = "out",
        .short = 'o',
        .description = "Name of the output file",
        .data_type = .string,
    });
    try build_opts.append(allocator, .{
        .long = "verbose",
        .short = 'v',
        .description = "Enable verbose logging",
        .data_type = .flag,
    });
    try commands.append(allocator, .{
        .name = "build",
        .description = "Build a Nook project",
        .options = &build_opts,
        .callback = build_cmd.run,
    });

    // Handling
    // -------

    // Get command line args
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Determine the command; no command given = help command
    var cmd_name: []const u8 = "help";
    if (args.len > 1) {
        cmd_name = args[1];
    }

    // Check if the command exists
    for (commands.items) |command| {
        if (!std.mem.eql(u8, command.name, cmd_name)) continue;
        if (command.callback()) |msg| {
            log.err("{s}", .{msg});
            return 1;
        }

        return 0;
    }

    // Command does not exist
    log.err("Command '{s}' does not exist", .{cmd_name});
    return 1;
}

/// Callback for the help command
pub fn help() ?[]const u8 {
    // Nook intro
    std.debug.print("{s}\n\n", .{meta.description});

    // Usage
    std.debug.print("{s}USAGE:{s}\n\t{s}{s} {s}[COMMAND] {s}[ARGS] {s}[--OPTIONS]{s}\n\n", .{
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
    for (commands.items) |command| {
        if (command.name.len > spaces) spaces = command.name.len;
    }

    // Commands list
    std.debug.print("{s}COMMANDS{s}:\n", .{
        log.BOLD,
        log.RESET,
    });
    for (commands.items) |command| {
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
