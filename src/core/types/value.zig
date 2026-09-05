const std = @import("std");

pub const Value = union(enum) {
    val_bool: bool,
    val_int: i64,
    val_float: f64,
    val_char: u8,
    val_str: []const u8,

    /// Return the raw string value of the value
    pub fn raw(self: Value, allocator: std.mem.Allocator) []const u8 {
        return switch (self) {
            .val_bool => |b| std.fmt.allocPrint(allocator, "{any}", .{b}) catch "(OOM; bool)",
            .val_int => |i| std.fmt.allocPrint(allocator, "{d}", .{i}) catch "(OOM; int)",
            .val_float => |f| std.fmt.allocPrint(allocator, "{d}", .{f}) catch "(OOM; float)",
            .val_char => |c| std.fmt.allocPrint(allocator, "{c}", .{c}) catch "(OOM; char)",
            .val_str => |s| std.fmt.allocPrint(allocator, "{s}", .{s}) catch "(OOM; string)",
        };
    }

    /// Return a string representation of the value
    pub fn string(self: Value, allocator: std.mem.Allocator) []const u8 {
        return std.fmt.allocPrint(allocator, "[{s}: {s}]", .{
            @tagName(self),
            self.raw(allocator),
        }) catch @tagName(self);
    }
};
