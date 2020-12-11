const std = @import("std");

const print = std.debug.print;
const allocator = std.heap.page_allocator;

const N = u16;
const C = u64;

const Arr = std.ArrayList(N);

pub fn main() !void {
    const inputFileName = std.os.argv[1];

    const arr = try loadData(inputFileName);
    defer arr.deinit();

    std.sort.sort(N, arr.items, {}, less);

    task1(arr.items);
    try task2(arr.items);
}

fn task1(items: []N) void {
    var gaps = [_]N{0} ** 4;

    var prev: N = 0;
    for (items) |n| {
        gaps[n-prev] += 1;
        prev = n;
    }

    print("{}\n", .{gaps[1] * gaps[3]});
}

fn task2(items: []N) !void {
    const max = items[items.len-1];

    var options = try allocator.alloc(C, max+1);
    defer allocator.free(options);

    for (options[1..options.len]) |v, i| {
        options[i] = 0;
    }
    options[0] = 1;

    for (items) |n| {
        options[n] = (if (n>=3) options[n-3] else 0)
            + (if (n>=2) options[n-2] else 0)
            + (if (n>=1) options[n-1] else 0);
    }

    print("{}\n", .{options[max]});
}

fn less(x: void, a: N, b: N) bool {
    return a < b;
}

fn loadData(fileName: [*:0]u8) !Arr {
    const file = try std.fs.cwd().openFileZ(fileName, .{.read = true });
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024*1024);
    defer allocator.free(content);

    var arr = Arr.init(allocator);

    var max: N = 0;
    var split = std.mem.split(content, "\n");
    while (split.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const n = try std.fmt.parseUnsigned(N, line, 10);
        max = std.math.max(n, max);
        try arr.append(n);
    }
    try arr.append(max+3);

    return arr;
}
