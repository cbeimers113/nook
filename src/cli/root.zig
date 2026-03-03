const arg = @import("arg.zig");
const cmd = @import("cmd.zig");
const log = @import("log");
const meta = @import("meta");
const option = @import("option.zig");
const std = @import("std");

const build_cmd = @import("build_cmd.zig");
const debug_cmd = @import("debug_cmd.zig");
const help_cmd = @import("help_cmd.zig");
const init_cmd = @import("init_cmd.zig");
const version_cmd = @import("version_cmd.zig");

/// Parse and handle command line arguments
pub fn handle(allocator: std.mem.Allocator) !u8 {
    // Register commands
    defer cmd.commands.deinit(allocator);
    try build_cmd.register(allocator);
    try debug_cmd.register(allocator);
    try help_cmd.register(allocator);
    try init_cmd.register(allocator);
    try version_cmd.register(allocator);

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
    for (cmd.commands.items) |c| {
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
    var pos_args: std.ArrayList(arg.Arg) = .empty;
    defer pos_args.deinit(allocator);
    var arg_idx: usize = 2;
    const cmd_args = command.args orelse &[_]arg.Arg{};

    if (args.len > 2) {
        for (args[2..args.len], 0..) |a, i| {
            // If this command takes more args, collect it
            if (i == cmd_args.len) break;
            try pos_args.append(allocator, .{
                .name = cmd_args[i].name,
                .description = cmd_args[i].description,
                .data_type = cmd_args[i].data_type,
                .value = a,
            });

            arg_idx += 1;
        }
    }

    // Missing positional arguments
    if (pos_args.items.len < cmd_args.len) {
        for (cmd_args[pos_args.items.len..]) |a| {
            log.err("Missing required argument: '{s}'", .{a.name});
        }
        return 1;
    }

    // Parse options
    var opt_args: std.ArrayList(option.Option) = .empty;
    defer opt_args.deinit(allocator);
    const cmd_opts = command.options orelse &[_]option.Option{};

    while (arg_idx < args.len) : (arg_idx += 1) {
        // Find matching option
        const a = args[arg_idx];
        var o: ?option.Option = null;
        for (cmd_opts) |opt| {
            if (opt.short != '\u{0}' and
                a.len == 2 and
                a[0] == '-' and
                a[1] == opt.short)
            {
                o = opt;
                break;
            }

            if (!std.mem.startsWith(u8, a, "--")) continue;
            if (std.mem.eql(u8, opt.long, std.mem.trimStart(u8, a, "--"))) {
                o = opt;
                break;
            }
        }

        if (o) |opt| {
            try opt_args.append(allocator, .{
                .long = opt.long,
                .short = opt.short,
                .description = opt.description,
                .data_type = opt.data_type,
                .value = std.mem.trimStart(u8, std.mem.trimStart(u8, a, "-"), "-"),
            });
        } else {
            log.err("Unknown option: '{s}'", .{a});
            return 1;
        }
    }

    std.debug.print("Got args: ", .{});
    for (pos_args.items, 0..) |a, i| {
        std.debug.print("{s}", .{a.name});
        if (i < pos_args.items.len - 1) std.debug.print(", ", .{});
    }
    std.debug.print("\n", .{});

    std.debug.print("Got options: ", .{});
    for (opt_args.items, 0..) |o, i| {
        std.debug.print("{s}", .{o.long});
        if (i < opt_args.items.len - 1) std.debug.print(", ", .{});
    }
    std.debug.print("\n", .{});

    // Execute command
    if (command.callback()) |msg| {
        log.err("{s}", .{msg});
        return 1;
    }

    return 0;
}
