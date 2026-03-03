const arg = @import("arg.zig");
const log = @import("log");
const option = @import("option.zig");
const std = @import("std");

// The command registry
pub var commands: std.ArrayList(Command) = .empty;

/// Represents a command supported by the CLI
pub const Command = struct {
    name: []const u8,
    description: []const u8,
    args: ?[]const arg.Arg = null,
    options: ?[]const option.Option = null,
    callback: *const fn () ?[]const u8,

    /// Print the command's help string
    pub fn help(self: Command) void {
        std.debug.print("{s}\n\n{s}USAGE{s}:\n\t{s}{s}{s}", .{
            self.description,
            log.BOLD,
            log.RESET,
            log.BLUE,
            self.name,
            log.RESET,
        });
        std.debug.print(" {s}[help|ARGS]{s}", .{
            log.YELLOW,
            log.RESET,
        });
        // TODO: print args in order
        if (self.options) |_| {
            std.debug.print(" {s}[--OPTIONS]{s}", .{
                log.MAGENTA,
                log.RESET,
            });
        }
        std.debug.print("\n\n", .{});

        // Null-coalesce args and options into empty slices
        const args = self.args orelse &[_]arg.Arg{};
        const options = self.options orelse &[_]option.Option{};

        // Measure spaces to align arg and option descriptions
        var arg_spaces: usize = "help".len;
        var opt_spaces: usize = 0;
        for (args) |a| {
            if (a.name.len > arg_spaces) arg_spaces = a.name.len;
        }
        for (options) |o| {
            if (o.long.len > opt_spaces) opt_spaces = o.long.len;
        }

        // List args
        std.debug.print("{s}ARGS{s}:\n", .{
            log.BOLD,
            log.RESET,
        });
        for (args) |a| {
            a.help(arg_spaces);
        }

        // List options
        if (options.len == 0) return;
        std.debug.print("\n{s}OPTIONS{s}:\n", .{
            log.BOLD,
            log.RESET,
        });
        for (options) |o| {
            o.help(opt_spaces);
        }
    }
};
