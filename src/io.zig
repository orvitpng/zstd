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

        /// Write bytes to the writer.
        pub fn write(self: Self, buf: []const u8) Error!usize {
            return write_fn(self.ctx, buf);
        }
        /// Write all bytes to the writer.
        ///
        /// This is different from `write` in that it will keep writing until
        /// all bytes are written.
        pub fn write_all(self: Self, buf: []const u8) Error!void {
            var i: usize = 0;
            while (i != buf.len) {
                i += try self.write(buf[i..]);
            }
        }

        // TODO: make this more readable w/ better errors
        // TODO: optimize this
        /// Write a formatted string to the writer.
        ///
        /// Accepted format specifiers:
        /// - Array
        ///   - `s`: string
        pub fn format(
            self: Self,
            comptime fmt: []const u8,
            args: anytype,
        ) Error!void {
            const ArgsType = @TypeOf(args);
            const args_info = @typeInfo(ArgsType);
            if (args_info != .Struct)
                @compileError("expected tuple or struct, found " ++ @typeName(ArgsType));
            const fields = args_info.Struct.fields;

            comptime var index = 0;
            comptime var i = 0;
            inline while (i < fmt.len) {
                // no need to worry about wasting a syscall here, write_all
                // compiles out if the buffer is empty
                try self.write_all(fmt[blk: {
                    comptime var start = i;
                    inline while (i < fmt.len) : (i += 1) switch (fmt[i]) {
                        '{' => break :blk start,
                        '}' => @compileError("missing opening '{'"),
                        '\\' => {
                            if (i + 1 == fmt.len) @compileError("unexpected end of format string");
                            if (start != i)
                                try self.write_all(fmt[start..i]);
                            i += 1;
                            start = i;
                        },
                        else => {},
                    };
                    return try self.write_all(fmt[start..i]);
                }..i]);
                i += 1;

                const start = i;
                inline while (i != fmt.len and fmt[i] != '}') : (i += 1) {}
                try self.format_type(
                    @field(args, fields[index].name),
                    fmt[start..i],
                );

                i += 1;
                index += 1;
            }
        }
        pub fn format_type(
            self: Self,
            value: anytype,
            comptime specifier: []const u8,
        ) Error!void {
            return switch (@typeInfo(@TypeOf(value))) {
                .Pointer => self.format_type(value.*, specifier),
                .Array => {
                    if (specifier.len == 0)
                        @compileError("arrays must have a specifier");

                    if (specifier[0] == 's')
                        return self.write_all(&value);
                    @compileError("unsupported array specifier: " ++ specifier[0]);
                },
                else => |tag| @compileError("unsupported argument type: " ++ @tagName(tag)),
            };
        }
    };
}
