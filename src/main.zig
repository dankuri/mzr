const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var argv = std.ArrayList([]const u8).init(allocator);
    defer argv.deinit();

    var argIter = try std.process.argsWithAllocator(allocator);
    defer argIter.deinit();
    _ = argIter.skip();

    if (argIter.next()) |arg| {
        try argv.append(arg);
    } else {
        std.debug.print("No command to run\n", .{});
        return;
    }

    while (argIter.next()) |arg| {
        try argv.append(arg);
    }

    var cp = std.process.Child.init(argv.items, allocator);
    cp.request_resource_usage_statistics = true;
    var startTime = try std.time.Instant.now();
    _ = try cp.spawn();
    // const pid = cp.id;
    // std.debug.print("PID: {}\n", .{pid});
    _ = try cp.wait();
    var endTime = try std.time.Instant.now();
    var elapsed = endTime.since(startTime);
    std.debug.print("\ncmd: ", .{});
    printJoinedString(argv.items);
    std.debug.print("\ttime: {}", .{std.fmt.fmtDuration(elapsed)});
    const rus = cp.resource_usage_statistics;
    if (rus.getMaxRss()) |rssNum| {
        std.debug.print("\tmax mem: {}\n", .{std.fmt.fmtIntSizeBin(rssNum)});
    } else {
        std.debug.print("\tmax mem: N/A\n", .{});
    }
    // std.debug.print("Resource Usage Statistics: {?}\n", .{rus.rusage});
}

fn printJoinedString(strings: [][]const u8) void {
    for (strings) |s| {
        std.debug.print("{s} ", .{s});
    }
}
