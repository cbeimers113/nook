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
};

/// Represents a key-value argument for a command
pub const Option = struct {
    long: []const u8,
    short: u8 = '\u{0}',
    description: []const u8,
    data_type: DataType,
    value: []const u8 = "",
};

/// Represents a command supported by the CLI
pub const Command = struct {
    name: []const u8,
    description: []const u8,
    args: ?*std.ArrayList(Arg) = null,
    options: ?*std.ArrayList(Option) = null,
    callback: *const fn () ?[]const u8,

    // /// Print the command's help string
    // fn help(self: Command) void {}
};
