const Self = @This();
const std = @import("../root.zig");

fd: std.os.types.fd_type,
reader: std.io.Reader(std.os.types.fd_type, std.os.ReadError, std.os.read),
writer: std.io.Writer(std.os.types.fd_type, std.os.WriteError, std.os.write),

fn new(fd: std.os.types.fd_type) Self {
    return .{ .fd = fd, .writer = .{ .ctx = fd }, .reader = .{ .ctx = fd } };
}

/// Creates a new `File` from the given path.
pub fn open(path: []const u8) std.os.OpenError!Self {
    return Self.new(try std.os.open(path));
}
/// Close the file.
pub fn close(self: Self) void {
    std.os.close(self.fd) catch |err| switch (err) {
        // Race condition, shouldn't happen if purely using this API
        .InvalidDescriptor => unreachable,
        else => return,
    };
}

/// Read the file.
pub fn read(self: Self, buf: []u8) std.os.ReadError!void {
    return self.reader.read_all(buf);
}
/// Write to the file.
pub fn write(self: Self, buf: []const u8) std.os.WriteError!void {
    return self.writer.write_all(buf);
}
