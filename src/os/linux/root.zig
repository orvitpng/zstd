pub const errors = @import("./errors.zig");
pub const target = switch (@import("builtin").cpu.arch) {
    .x86_64 => @import("./x86_64/root.zig"),
    else => @compileError("unsupported arch"),
};
pub const types = @import("./types.zig");

pub const syscalls = target.syscalls;

pub fn read(fd: types.fd_type, buf: [*]u8, count: usize) ErrnoResult {
    return get_errno(syscalls.three(
        .read,
        @bitCast(@as(isize, fd)),
        @intFromPtr(buf),
        count,
    ));
}
pub fn write(fd: types.fd_type, buf: [*]const u8, count: usize) ErrnoResult {
    return get_errno(syscalls.three(
        .write,
        @bitCast(@as(isize, fd)),
        @intFromPtr(buf),
        count,
    ));
}
pub fn open(
    filename: [*]const u8,
    flags: c_int,
    mode: types.mode_type,
) ErrnoResult {
    return get_errno(syscalls.three(
        .open,
        @intFromPtr(filename),
        flags,
        mode,
    ));
}
pub fn close(fd: types.fd_type) ErrnoResult {
    return get_errno(syscalls.one(.close, @bitCast(@as(isize, fd))));
}

pub const ErrnoResult = union(enum) { ok: usize, err: errors.Errors };
pub fn get_errno(ret: usize) ErrnoResult {
    const int: isize = @bitCast(ret);
    return if (int > -4096 and int < 0)
        ErrnoResult{ .err = @enumFromInt(-int) }
    else
        ErrnoResult{ .ok = ret };
}
