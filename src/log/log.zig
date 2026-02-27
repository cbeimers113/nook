const std = @import("std");

// ANSI escape codes for terminal styling
const red = "\x1b[31m";
const green = "\x1b[32m";
const yellow = "\x1b[33m";
const blue = "\x1b[34m";
const bold = "\x1b[1m";
const reset = "\x1b[0m";

/// Logs a message at the success level
pub fn success(msg: []const u8) void {
    std.log.info("{s}{s}{s}{s}", .{ green, bold, msg, reset });
}

/// Logs a message at the debug level
pub fn debug(msg: []const u8) void {
    std.log.debug("{s}{s}{s}", .{ blue, msg, reset });
}

/// Logs a message at the warning level
pub fn warn(msg: []const u8) void {
    std.log.warn("{s}{s}{s}", .{ yellow, msg, reset });
}

/// Logs a message at the error level
pub fn err(msg: []const u8) void {
    std.log.err("{s}{s}{s}", .{ red, msg, reset });
}
