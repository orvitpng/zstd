const Self = @This();
const std = @import("../mod.zig");

fd: std.os.types.fd_type,
writer: std.io.Writer(std.os.types.fd_type, std.os.WriteError, write_internal),

pub fn new(fd: std.os.types.fd_type) Self {
    return .{ .fd = fd, .writer = .{ .ctx = fd } };
}

pub fn write(self: Self, buf: []const u8) std.os.WriteError!void {
    return self.writer.write_all(buf);
}

fn write_internal(
    fd: std.os.types.fd_type,
    buf: []const u8,
) std.os.WriteError!usize {
    return std.os.write(fd, buf);
}
