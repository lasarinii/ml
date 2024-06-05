const std = @import("std");

// AND - works
// { 0, 0, 0 },
// { 1, 0, 0 },
// { 0, 1, 0 },
// { 1, 1, 1 },
//
// NAND - works
// { 0, 0, 1 },
// { 1, 0, 1 },
// { 0, 1, 1 },
// { 1, 1, 0 },
//
// OR - works
// { 0, 0, 0 },
// { 1, 0, 1 },
// { 0, 1, 1 },
// { 1, 1, 1 },
//
// XOR - don't work with a single neuron
// but can work with and, nand and or gates: (x | y) & ~(x & y)
// { 0, 0, 0 },
// { 1, 0, 1 },
// { 0, 1, 1 },
// { 1, 1, 0 },
//
// NOR - aparently works
// { 0, 0, 1 },
// { 1, 0, 0 },
// { 0, 1, 0 },
// { 1, 1, 0 },
//

pub const gates = enum {
    AND,
    NAND,
    OR,
    NOR,
    XOR,
};

const sample = [4][3]f32;
const and_train = sample{
    [3]f32{ 0, 0, 0 },
    [3]f32{ 1, 0, 0 },
    [3]f32{ 0, 1, 0 },
    [3]f32{ 1, 1, 1 },
};
const nand_train = sample{
    [3]f32{ 0, 0, 1 },
    [3]f32{ 1, 0, 1 },
    [3]f32{ 0, 1, 1 },
    [3]f32{ 1, 1, 0 },
};
const or_train = sample{
    [3]f32{ 0, 0, 0 },
    [3]f32{ 1, 0, 1 },
    [3]f32{ 0, 1, 1 },
    [3]f32{ 1, 1, 1 },
};
const nor_train = sample{
    [3]f32{ 0, 0, 1 },
    [3]f32{ 1, 0, 0 },
    [3]f32{ 0, 1, 0 },
    [3]f32{ 1, 1, 0 },
};
const xor_train = sample{
    [3]f32{ 0, 0, 0 },
    [3]f32{ 1, 0, 1 },
    [3]f32{ 0, 1, 1 },
    [3]f32{ 1, 1, 0 },
};
var train: sample = undefined;
const train_count = 4;

fn sigmoidf(x: f32) f32 {
    return 1.0 / (1.0 + @exp(-x));
}

fn cost(w1: f32, w2: f32, b: f32) f32 {
    var result: f32 = 0;
    for (0..train_count) |i| {
        const x1 = train[i][0];
        const x2 = train[i][1];
        const y = sigmoidf(x1 * w1 + x2 * w2 + b);
        const d = y - train[i][2];
        result += d * d;
    }
    result /= train_count;
    return result;
}

pub fn print(gate: gates) void {
    const rand = std.crypto.random;
    var w1 = rand.float(f32);
    var w2 = rand.float(f32);
    var b = rand.float(f32);

    const eps = 1e-1;
    const rate = 1e-1;

    switch (gate) {
        gates.AND => train = and_train,
        gates.NAND => train = nand_train,
        gates.OR => train = or_train,
        gates.NOR => train = nor_train,
        gates.XOR => {
            xor_print();
            return;
        },
    }

    for (0..1_000_000) |_| {
        const c = cost(w1, w2, b);
        const dw1 = (cost(w1 + eps, w2, b) - c) / eps;
        const dw2 = (cost(w1, w2 + eps, b) - c) / eps;
        const db = (cost(w1, w2, b + eps) - c) / eps;

        w1 -= dw1 * rate;
        w2 -= dw2 * rate;
        b -= db * rate;
    }

    for (0..2) |i| {
        for (0..2) |j| {
            const if32 = @as(f32, @floatFromInt(i));
            const jf32 = @as(f32, @floatFromInt(j));
            std.debug.print("{} | {} = {d}\n", .{ i, j, sigmoidf(if32 * w1 + jf32 * w2 + b) });
        }
    }
}

// the function print(gate: gates) void works well for AND, NAND and OR gates, for reasons that I don't care, i want to keep the gate XOR in the same file that the others
// the bellow code is just for the XOR logic

const xor = struct {
    and_w1: f32 = undefined,
    and_w2: f32 = undefined,
    and_b: f32 = undefined,

    nand_w1: f32 = undefined,
    nand_w2: f32 = undefined,
    nand_b: f32 = undefined,

    or_w1: f32 = undefined,
    or_w2: f32 = undefined,
    or_b: f32 = undefined,
};

fn foward(m: xor, x1: f32, x2: f32) f32 {
    const a = sigmoidf(m.or_w1 * x1 + m.or_w2 * x2 + m.or_b);
    const b = sigmoidf(m.nand_w1 * x1 + m.nand_w2 * x2 + m.nand_b);
    return sigmoidf(a * m.and_w1 + b * m.and_w2 + m.and_b);
}

fn xor_cost(m: xor) f32 {
    var result: f32 = 0;
    for (0..train_count) |i| {
        const x1 = train[i][0];
        const x2 = train[i][1];
        const y = foward(m, x1, x2);
        const d = y - train[i][2];
        result += d * d;
    }
    result /= train_count;
    return result;
}

fn assign_rand_xor() xor {
    const rand = std.crypto.random;
    return xor{
        .and_w1 = rand.float(f32),
        .and_w2 = rand.float(f32),
        .and_b = rand.float(f32),

        .nand_w1 = rand.float(f32),
        .nand_w2 = rand.float(f32),
        .nand_b = rand.float(f32),

        .or_w1 = rand.float(f32),
        .or_w2 = rand.float(f32),
        .or_b = rand.float(f32),
    };
}

fn finite_diff(m: xor, eps: f32) xor {
    var g = xor{};
    const c = xor_cost(m);
    var saved: f32 = undefined;

    var m_var = m;

    // OR
    saved = m_var.or_w1;
    m_var.or_w1 += eps;
    g.or_w1 = (xor_cost(m_var) - c) / eps;
    m_var.or_w1 = saved;

    saved = m_var.or_w2;
    m_var.or_w2 += eps;
    g.or_w2 = (xor_cost(m_var) - c) / eps;
    m_var.or_w2 = saved;

    saved = m_var.or_b;
    m_var.or_b += eps;
    g.or_b = (xor_cost(m_var) - c) / eps;
    m_var.or_b = saved;

    // AND
    saved = m_var.and_w1;
    m_var.and_w1 += eps;
    g.and_w1 = (xor_cost(m_var) - c) / eps;
    m_var.and_w1 = saved;

    saved = m_var.and_w2;
    m_var.and_w2 += eps;
    g.and_w2 = (xor_cost(m_var) - c) / eps;
    m_var.and_w2 = saved;

    saved = m_var.and_b;
    m_var.and_b += eps;
    g.and_b = (xor_cost(m_var) - c) / eps;
    m_var.and_b = saved;

    // NAND
    saved = m_var.nand_w1;
    m_var.nand_w1 += eps;
    g.nand_w1 = (xor_cost(m_var) - c) / eps;
    m_var.nand_w1 = saved;

    saved = m_var.nand_w2;
    m_var.nand_w2 += eps;
    g.nand_w2 = (xor_cost(m_var) - c) / eps;
    m_var.nand_w2 = saved;

    saved = m_var.nand_b;
    m_var.nand_b += eps;
    g.nand_b = (xor_cost(m_var) - c) / eps;
    m_var.nand_b = saved;

    return g;
}

fn diff(m: xor, g: xor, rate: f32) xor {
    var res = m;

    res.or_w1 -= rate * g.or_w1;
    res.or_w2 -= rate * g.or_w2;
    res.or_b -= rate * g.or_b;

    res.and_w1 -= rate * g.and_w1;
    res.and_w2 -= rate * g.and_w2;
    res.and_b -= rate * g.and_b;

    res.nand_w1 -= rate * g.nand_w1;
    res.nand_w2 -= rate * g.nand_w2;
    res.nand_b -= rate * g.nand_b;

    return res;
}

fn xor_print() void {
    var m = assign_rand_xor();

    const eps: f32 = 1e-1;
    const rate: f32 = 1e-1;

    train = xor_train;

    for (0..300_000) |_| {
        const g = finite_diff(m, eps);
        m = diff(m, g, rate);
    }

    for (0..2) |i| {
        for (0..2) |j| {
            std.debug.print("{d} | {d} = {d}\n", .{ i, j, foward(m, @as(f32, @floatFromInt(i)), @as(f32, @floatFromInt(j))) });
        }
    }
}

// apparently, the 'xor_print() void' function can handle all of the cases,
// it is an evoluted version of the 'print() void' function because it have 2 layers, or 2 neurons, ou 3... it has something more.
