const std = @import("./mod.zig");

pub const stdin = std.fs.File.new(std.os.get_stream_fd(.in));
pub const stdout = std.fs.File.new(std.os.get_stream_fd(.out));
pub const stderr = std.fs.File.new(std.os.get_stream_fd(.err));

pub fn Writer(
    comptime Context: type,
    comptime WriteError: type,
    write_fn: fn (ctx: Context, buf: []const u8) WriteError!usize,
) type {
    return struct {
        const Self = @This();

        pub const Error = WriteError;

        ctx: Context,

        pub fn write(self: Self, buf: []const u8) Error!usize {
            return write_fn(self.ctx, buf);
        }
        pub fn write_all(self: Self, buf: []const u8) Error!void {
            var i: usize = 0;
            while (i != buf.len) {
                i += try self.write(buf[i..]);
            }
        }
    };
}
