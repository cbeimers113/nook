const data_type = @import("data_type.zig");
const log = @import("log");
const std = @import("std");

/// Represents a required positional argument for a command
pub const Arg = struct {
    name: []const u8,
    description: []const u8,
    data_type: data_type.DataType,
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
