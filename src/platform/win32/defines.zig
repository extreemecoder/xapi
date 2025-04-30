const std = @import("std");
const windows = struct {
    usingnamespace std.os.windows;
};

const WNDCLASSW = struct {
    style: windows.UINT,
    lpfnWndProc: windows.WNDPROC,
    cbClsExtra: i32,
    cbWndExtra: i32,
    hInstance: windows.HINSTANCE,
    hIcon: windows.HICON,
    hCursor: windows.HCURSOR,
    hbrBackground: windows.HBRUSH,
    lpszMenuName: windows.LPCWSTR,
    lpszClassName: windows.LPCWSTR,
};
