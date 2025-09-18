const std = @import("std");

pub const BaseLogLevel = enum(u8) {
    NOSET = 0,
    FATAL = 10,
    ERROR = 30,
    WARN = 50,
    INFO = 70,
    DEBUG = 90,
    ALL = 100,
};

test "Base log levels" {
    const expectEqual = std.testing.expectEqual;

    try expectEqual(0, @intFromEnum(BaseLogLevel.NOSET));
    try expectEqual(10, @intFromEnum(BaseLogLevel.FATAL));
    try expectEqual(30, @intFromEnum(BaseLogLevel.ERROR));
    try expectEqual(50, @intFromEnum(BaseLogLevel.WARN));
    try expectEqual(70, @intFromEnum(BaseLogLevel.INFO));
    try expectEqual(90, @intFromEnum(BaseLogLevel.DEBUG));
    try expectEqual(100, @intFromEnum(BaseLogLevel.ALL));
}
