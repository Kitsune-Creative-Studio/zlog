const std = @import("std");

pub fn print() !void {
    std.debug.print("Hello, ZigLogger!\n", .{});
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}
