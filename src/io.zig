const std = @import("./mod.zig");

pub const stdin = std.fs.File{ .fd = std.os.get_stream_fd(.in) };
pub const stdout = std.fs.File{ .fd = std.os.get_stream_fd(.out) };
pub const stderr = std.fs.File{ .fd = std.os.get_stream_fd(.err) };
