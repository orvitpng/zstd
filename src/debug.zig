const std = @import("./root.zig");

// TODO: actual format the text
// TODO: mutex the shit out of this
/// Write a formatted string to stderr.
pub fn print(comptime fmt: []const u8, args: anytype) void {
    std.io.stderr.format(fmt, args) catch {};
}
pub fn println(comptime fmt: []const u8, args: anytype) void {
    print(fmt ++ "\n", args);
}
