const Self = @This();
const std = @import("../mod.zig");

fd: std.os.types.fd_type,
reader: std.io.Reader(std.os.types.fd_type, std.os.ReadError, std.os.read),
writer: std.io.Writer(std.os.types.fd_type, std.os.WriteError, std.os.write),

pub fn new(fd: std.os.types.fd_type) Self {
    return .{ .fd = fd, .writer = .{ .ctx = fd }, .reader = .{ .ctx = fd } };
}

pub fn read(self: Self, buf: []u8) std.os.ReadError!void {
    return self.reader.read_all(buf);
}
pub fn write(self: Self, buf: []const u8) std.os.WriteError!void {
    return self.writer.write_all(buf);
}
