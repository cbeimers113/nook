const args = @import("args");
const log = @import("log");
const std = @import("std");
const build_meta = @import("build_meta");

/// Nook toolchain CLI entry point
pub fn main() u8 {
    // Create allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create arg parser
    var parser = try args.ArgumentParser.init(allocator, .{
        .name = build_meta.name,
        .version = build_meta.version,
        .description = "An experimental systems programming language",
        .config = args.Config.default(),
    });
    defer parser.deinit();

    // Setup commands
    if (!setup_init_cmd(&parser)) return 1;
    if (!setup_build_cmd(&parser)) return 1;

    // Parse args
    var res = parser.parseProcess() catch |err| {
        const msg: []const u8 = switch (err) {
            args.errors.ParseError.MissingRequired => "Missing required argument(s)",
            args.errors.ParseError.UnknownOption => "Unknown option provided",
            else => "An unknown error occurred",
        };

        log.err(msg);
        return 1;
    };
    defer res.deinit();

    // Handle results
    if (res.subcommand) |cmd| {
        std.debug.print("Command: {s}", .{cmd});
        // TODO: invoke callback
        return 0;
    }

    // Print help string if no recognized command entered
    parser.printHelp() catch {
        log.err("Could not produce help string");
        return 1;
    };

    return 0;
}

/// Configures the init command
fn setup_init_cmd(parser: *args.ArgumentParser) bool {
    parser.addSubcommand(.{
        .name = "init",
        .help = "Initialize a Nook project",
        .args = &[_]args.ArgSpec{
            .{ .name = "name", .positional = true, .required = true, .help = "The name of the project" },
        },
    }) catch {
        log.err("Could not configure init command");
        return false;
    };

    return true;
}

/// Configures the build command
fn setup_build_cmd(parser: *args.ArgumentParser) bool {
    parser.addSubcommand(.{
        .name = "build",
        .help = "Build a Nook project",
        .args = &[_]args.ArgSpec{
            .{ .name = "output", .short = 'o', .long = "output", .help = "The name of the output file" },
            .{ .name = "verbose", .short = 'v', .long = "verbose", .value_type = .bool, .help = "Log verbose details" },
        },
    }) catch {
        log.err("Could not configure build command");
        return false;
    };

    return true;
}
