pub const target = switch (@import("builtin").os.tag) {
    .linux => @import("./linux/root.zig"),
    else => @compileError("unsupported os"),
};

pub const types = target.types;

pub const ReadError = error{Unknown};
pub fn read(fd: types.fd_type, buf: []u8) ReadError!usize {
    return switch (target.read(fd, buf.ptr, buf.len)) {
        .ok => |val| val,
        .err => error.Unknown,
    };
}
pub const WriteError = error{Unknown};
pub fn write(fd: types.fd_type, buf: []const u8) WriteError!usize {
    return switch (target.write(fd, buf.ptr, buf.len)) {
        .ok => |val| val,
        .err => error.Unknown,
    };
}

pub fn get_stream_fd(stream: enum { in, out, err }) target.types.fd_type {
    return switch (stream) {
        .in => 0,
        .out => 1,
        .err => 2,
    };
}
