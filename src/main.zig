const cli = @import("cli");
const std = @import("std");

/// Nook toolchain CLI entry point
pub fn main() !u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    const exit_code = try cli.handle(gpa.allocator());
    return exit_code;
}
