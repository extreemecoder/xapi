const std = @import("std");
const testing = std.testing;
const windows = std.os.windows;

pub extern fn WNDPROC(
    hwnd: windows.HWND,
    uMsg: windows.UINT,
    wParam: windows.WPARAM,
    lParam: windows.LPARAM
) windows.LRESULT;

const WNDCLASSW = extern struct {
    style: u32,
    lpfnWndProc: *WNDPROC,
    cbClsExtra: i32,
    cbWndExtra: i32,
    hInstance: windows.HINSTANCE,
    hIcon: windows.HICON,
    hCursor: windows.HCURSOR,
    hbrBackground: windows.HBRUSH,
    lpszMenuName: windows.LPCWSTR,
    lpszClassName: windows.LPCWSTR,
};


pub export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}
