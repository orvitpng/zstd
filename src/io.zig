const std = @import("./root.zig");

pub const stdin = std.fs.File.new(std.os.get_stream_fd(.in)).reader;
pub const stdout = std.fs.File.new(std.os.get_stream_fd(.out)).writer;
pub const stderr = std.fs.File.new(std.os.get_stream_fd(.err)).writer;

pub fn Reader(
    comptime Context: type,
    comptime ReadError: type,
    read_fn: fn (ctx: Context, buf: []u8) ReadError!usize,
) type {
    return struct {
        const Self = @This();

        pub const Error = ReadError;

        ctx: Context,

        pub fn read(self: Self, buf: []u8) Error!usize {
            return read_fn(self.ctx, buf);
        }
        pub fn read_all(self: Self, buf: []u8) Error!void {
            var i: usize = 0;
            while (i != buf.len) {
                i += try self.read(buf[i..]);
            }
        }
    };
}
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
