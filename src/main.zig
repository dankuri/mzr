const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) {
            std.log.warn("Memory leak detected.\n", .{});
        }
    }

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
    const pid = cp.id;
    std.debug.print("PID: {}\n", .{pid});
    _ = try cp.wait();
    var endTime = try std.time.Instant.now();
    var elapsed = endTime.since(startTime);
    std.debug.print("Elapsed time: {}\n", .{std.fmt.fmtDuration(elapsed)});
    const rus = cp.resource_usage_statistics;
    if (rus.getMaxRss()) |rssNum| {
        std.debug.print("Max Memory Usage: {}\n", .{std.fmt.fmtIntSizeBin(rssNum)});
    } else {
        std.debug.print("Max Memory Usage: N/A\n", .{});
    }

    std.debug.print("Resource Usage Statistics: {?}\n", .{rus.rusage});
}
