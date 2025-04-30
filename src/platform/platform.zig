const std = @import("std");
const builtin = @import("builtin");

const platform = struct {
    usingnamespace switch(builtin.os.tag) {
        .windows => @import("win32/win32.zig"),
    
        else => error.UnsupportedOperatingSystem,
    };
};
