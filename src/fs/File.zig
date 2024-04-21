const Self = @This();
const std = @import("../mod.zig");

fd: std.os.types.fd_type,

pub fn write(self: Self, buf: []const u8) std.os.WriteError!usize {
    return std.os.write(self.fd, buf);
}
pub fn write_all(self: Self, buf: []const u8) std.os.WriteError!void {
    var i: usize = 0;
    while (i != buf.len) {
        i += try self.write(buf[i..]);
    }
}
