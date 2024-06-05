const std = @import("std");
const twice = @import("v1/twice.zig");
const gate = @import("v1/gate.zig");

pub fn main() !void {
    std.debug.print("ML Stuff Working?\n", .{});

    std.debug.print("twice:\n", .{});
    twice.print();

    std.debug.print("AND gate:\n", .{});
    gate.print(gate.gates.AND);

    std.debug.print("NAND gate:\n", .{});
    gate.print(gate.gates.NAND);

    std.debug.print("OR gate:\n", .{});
    gate.print(gate.gates.OR);

    std.debug.print("NOR gate:\n", .{});
    gate.print(gate.gates.NOR);

    std.debug.print("XOR gate:\n", .{});
    gate.print(gate.gates.XOR);
}
