const std = @import("std");

const train = [_][2]f32{
    [_]f32{ 0, 0 },
    [_]f32{ 1, 2 },
    [_]f32{ 2, 4 },
    [_]f32{ 3, 6 },
    [_]f32{ 4, 8 },
};

const train_count = @typeInfo(@TypeOf(train)).Array.len;

fn cost(w: f32, b: f32) f32 {
    var result: f32 = 0;
    for (0..train_count) |i| {
        const x = train[i][0];
        const y = x * w + b;

        const d = y - train[i][1];
        result += d * d;
    }
    result /= train_count;
    return result;
}

pub fn print() void {
    const rand = std.crypto.random;
    var w = rand.float(f32) * 10;
    var b = rand.float(f32) * 1;

    const eps = 1e-3;
    const rate = 1e-3;

    for (0..500) |_| {
        const c = cost(w, b);
        const dw = (cost(w + eps, b) - c) / eps;
        const db = (cost(w, b + eps) - c) / eps;
        w -= dw * rate;
        b -= db * rate;
    }
    std.debug.print("w: {d}; b: {d}; c: {d}\n", .{ w, b, cost(w, b) });
}
