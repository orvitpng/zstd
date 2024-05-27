pub const target = switch (@import("builtin").os.tag) {
    .linux => @import("./linux/root.zig"),
    else => @compileError("unsupported os"),
};

pub const types = target.types;

pub const ReadError = error{Unknown};
/// Read from a file descriptor.
pub fn read(fd: types.fd_type, buf: []u8) ReadError!usize {
    return switch (target.read(fd, buf.ptr, buf.len)) {
        .ok => |val| val,
        .err => error.Unknown,
    };
}

pub const WriteError = error{Unknown};
/// Write to a file descriptor.
pub fn write(fd: types.fd_type, buf: []const u8) WriteError!usize {
    return switch (target.write(fd, buf.ptr, buf.len)) {
        .ok => |val| val,
        .err => error.Unknown,
    };
}

pub const OpenError = error{Unknown};
// TODO: flags and mode
/// Open a file descriptor.
pub fn open(path: []const u8) OpenError!types.fd_type {
    return switch (target.open(path.ptr, 0, 0)) {
        .ok => |val| val,
        .err => error.Unknown,
    };
}

pub const CloseError = error{
    /// The file descriptor is invalid.
    InvalidDescriptor,
    /// The close operation was interrupted.
    Interrupted,
    /// An I/O error occurred during the close operation.
    IOError,
    /// There is no space left on the device (mostly for network file systems).
    NoSpace,
    /// The disk quota was exceeded (mostly for network file systems).
    DiskQuotaExceeded,
    Unknown,
};
/// Close a file descriptor.
pub fn close(fd: types.fd_type) CloseError!void {
    return switch (target.close(fd)) {
        .ok => void,
        .err => |err| switch (err) {
            .BADF => error.InvalidDescriptor,
            .INTR => error.Interrupted,
            .IO => error.IOError,
            .NOSPC => error.NoSpace,
            .DQUOT => error.DiskQuotaExceeded,
            else => error.Unknown,
        },
    };
}

/// Get the file descriptor for a standard stream.
pub fn get_stream_fd(stream: enum { in, out, err }) target.types.fd_type {
    return switch (stream) {
        .in => 0,
        .out => 1,
        .err => 2,
    };
}
