const std = @import("./mod.zig");

// TODO: actual format the text
// TODO: mutex the shit out of this
pub fn print(comptime fmt: []const u8, args: anytype) void {
    _ = args;
    std.io.stdout.write_all(fmt) catch {};
}