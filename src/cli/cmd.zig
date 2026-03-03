const log = @import("log");
const std = @import("std");

/// Represents the data type of an argument
pub const DataType = enum {
    string,
    int,
    float,
    flag,
};

/// Represents a required positional argument for a command
pub const Arg = struct {
    name: []const u8,
    description: []const u8,
    data_type: DataType,
    value: []const u8 = "",

    fn help(self: Arg, spaces: usize) void {
        std.debug.print("\t{s}{s}{s}: ", .{
            log.YELLOW,
            self.name,
            log.RESET,
        });

        for (0..spaces - self.name.len) |_| {
            std.debug.print(" ", .{});
        }

        std.debug.print("{s}{s}{s}\n", .{
            log.DIM,
            self.description,
            log.RESET,
        });
    }
};

/// Represents a key-value argument for a command
pub const Option = struct {
    long: []const u8,
    short: u8 = '\u{0}',
    description: []const u8,
    data_type: DataType,
    value: []const u8 = "",

    fn help(self: Option, spaces: usize) void {
        std.debug.print("\t{s}--{s} ", .{
            log.MAGENTA,
            self.long,
        });
        for (0..spaces - self.long.len) |_| {
            std.debug.print(" ", .{});
        }

        if (self.short == '\u{0}') {
            std.debug.print("  ", .{});
        } else {
            std.debug.print("-{c}", .{self.short});
        }

        std.debug.print("{s}: {s}{s}{s} ({s})\n", .{
            log.RESET,
            log.DIM,
            self.description,
            log.RESET,
            @tagName(self.data_type),
        });
    }
};

/// Represents a command supported by the CLI
pub const Command = struct {
    name: []const u8,
    description: []const u8,
    args: ?[]const Arg = null,
    options: ?[]const Option = null,
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
        const args = self.args orelse &[_]Arg{};
        const options = self.options orelse &[_]Option{};

        // Measure spaces to align arg and option descriptions
        var arg_spaces: usize = "help".len;
        var opt_spaces: usize = 0;
        for (args) |arg| {
            if (arg.name.len > arg_spaces) arg_spaces = arg.name.len;
        }
        for (options) |opt| {
            if (opt.long.len > opt_spaces) opt_spaces = opt.long.len;
        }

        // List args
        std.debug.print("{s}ARGS{s}:\n", .{
            log.BOLD,
            log.RESET,
        });
        for (args) |arg| {
            arg.help(arg_spaces);
        }
        const help_arg: Arg = .{
            .name = "help",
            .description = "Display the command's help message",
            .data_type = .string,
        };
        help_arg.help(arg_spaces);

        // List options
        if (options.len == 0) return;
        std.debug.print("\n{s}OPTIONS{s}:\n", .{
            log.BOLD,
            log.RESET,
        });
        for (options) |option| {
            option.help(opt_spaces);
        }
    }
};
