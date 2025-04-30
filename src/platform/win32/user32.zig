const std = @import("std");
const windows = struct {
    usingnamespace std.os.windows;
};

pub extern "user32" fn LoadCursorW(
    windows.HINSTANCE,
    windows.LPCWSTR
) callconv(.winapi) windows.HCURSOR;

pub extern "user32" fn AdjustWindowRectEx(
    windows.LPRECT,
    windows.DWORD,
    windows.BOOL,
    windows.DWORD,
) callconv(.winapi) windows.BOOL;

pub extern "user32" fn CreateWindowExW(
    windows.DWORD,
    windows.LPCWSTR,
    windows.LPCWSTR,
    windows.DWORD,
    i32,
    i32,
    i32,
    i32,
    windows.HWND,
    windows.HMENU,
    windows.HINSTANCE,
    windows.LPVOID,
) callconv(.winapi) windows.HWND;
