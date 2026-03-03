const data_type = @import("data_type.zig");
const log = @import("log");
const std = @import("std");

/// Global options
pub const help_option: Option = .{
    .long = "help",
    .short = 'h',
    .description = "Display help for this command",
    .data_type = .flag,
};

/// Represents a key-value argument for a command
pub const Option = struct {
    long: []const u8,
    short: u8 = '\u{0}',
    description: []const u8,
    data_type: data_type.DataType,
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
