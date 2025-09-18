const std = @import("std");
// const zlog = @import("zlog");

test "simple test" {
    const a = 1;
    const b = 2;
    try std.testing.expect(a + b == 3);
}
