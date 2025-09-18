const std = @import("std");

pub fn print() !void {
    std.debug.print("Hello, ZigLogger!\n", .{});
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "add function adds two numbers" {
    try std.testing.expect(add(2, 3) == 5);
    try std.testing.expect(add(-1, 1) == 0);
    try std.testing.expect(add(0, 0) == 0);
}
