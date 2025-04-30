const std = @import("std");
const windows = struct {
    usingnamespace std.os.windows;
    usingnamespace @import("user32.zig");
    usingnamespace @import("defines.zig");
};

const system_state = struct {
    h_instance: windows.HINSTANCE,
    hwnd: windows.HWND,
};

var clock_frequency: f64 = undefined;
var start_time: windows.LARGE_INTEGER = undefined;

pub fn startup(
    state: *system_state,
    application_name: []u8,
    x: i32,
    y: i32,
    width: i32,
    height: i32,
) bool {

    state = .{
        .h_instance = windows.kernel32.GetModuleHandleW(0),
        .hwnd = undefined,
    };

    const icon: windows.HICON = windows.LoadIcon(state.h_instance, windows.IDI_APPLICATION);
    const wc: windows.WNDCLASSW = .{
        .style = windows.CS_DBLCLKS, // Get double-clicks
        .lpfnWndProc = &win32_process_message(),
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = state.h_instance,
        .hIcon = icon,
        .hCursor = windows.LoadCursorW(windows.NULL, windows.IDC_ARROW),
        .hbrBackground = windows.NULL,
        .lpszClassName = "kohi_window_class",
    };

    if(!windows.RegisterClassW(&wc)) {
        windows.MessageBoxW(0, "Window registration failed", "Error", windows.MB_ICONEXCLAMATION | windows.MB_OK);
        return false;
    }

    var window_x: u32 = x;
    var window_y: u32 = y;
    var window_width: u32 = width;
    var window_height: u32 = height;

    const window_style: u32 = windows.WS_OVERLAPPED | windows.WS_SYSMENU | windows.WS_CAPTION | windows.WS_MAXIMIZEBOX | windows.WS_MINIMIZEBOX | windows.WS_THICKFRAME;
    const window_ex_style = windows.WS_EX_APPWINDOW;

    var border_rect: windows.RECT = .{ 0, 0, 0, 0, };
    _ = windows.AdjustWindowRectEx(&border_rect, window_style, 0, window_ex_style);

    window_x += border_rect.left;
    window_y += border_rect.top;

    window_width += border_rect.right - border_rect.left;
    window_height += border_rect.bottom - border_rect.top;

    const handle: windows.HWND = windows.CreateWindowExW(
        window_ex_style,
        "kohi_window_class",
        application_name,
        window_style,
        window_x,
        window_y,
        window_width,
        window_height,
        0, 0,
        state.h_instance,
        0
    );

    if (handle == 0) {
        windows.MessageBoxW(windows.NULL, "Window creation failed!", "Error!", windows.MB_ICONEXCLAMATION | windows.MB_OK);
        error.WindowCreationFailed;
        return false;
    } else {
        state.hwnd = handle;
    }

    const should_activate = true; // TODO: if the window should not accept input, this should be false
    const show_window_command_flags: i32 = undefined;
    if (should_activate) {
        show_window_command_flags = windows.SW_SHOW;
    } else {
        show_window_command_flags = windows.SW_SHOWNOACTIVATE;
    }
    _ = windows.ShowWindow(state.hwnd, show_window_command_flags);

    // Clock Setup
    var frequency: windows.LARGE_INTEGER = undefined;
    windows.QueryPerformanceFrequency(&frequency);
    clock_frequency = 1.0 / @as(f64, frequency.QuadPart);
    windows.QueryPerformanceCounter(&start_time);

    return true;
}

pub fn shutdown(
    state: *system_state,
) void {
    if (state.hwnd) {
        windows.DestroyWindow(state.hwnd);
        state.hwnd = 0;
    }
}

pub fn process_messages(
) bool {
    var message: windows.MSG = undefined;
    while (windows.PeekMessageW(&message, windows.NULL, 0, 0, windows.PM_REMOVE)) {
        windows.TranslateMessage(&message);
        windows.DispatchMessageW(&message);
    }

    return true;
}

pub fn get_absolute_time(
) f64 {
    var now_time: windows.LARGE_INTENGER = undefined;
    windows.QueryPerformanceCounter(&now_time);

    return @as(f64, now_time.QuadPart) * clock_frequency;
}

pub fn sleep(
    ms: u64,
) void {
    windows.Sleet(ms);
}

pub fn win32_process_message(
    hwnd: windows.HWND,
    msg: u32,
    w_param: windows.WPARAM,
    l_param: windows.LPARAM,
) windows.LRESULT {
    return switch(msg) {
        windows.WM_ERASEBKGND => {
            // Notify the OS that erasing will be handled by the application to prevent flicker.
            return 1;
        },
        windows.WM_CLOSE => {
            // TODO: Fire an event for the application to quit.
            return 0;
        },
        windows.WM_DESTROY => {
            windows.PostQuitMessage(0);
            return 0;
        },
        windows.WM_SIZE => {
            // Get the updated size.
            var r: windows.RECT = undefined;
            windows.GetClientRect(hwnd, &r);
            const width: u32 = r.right - r.left;
            const height: u32 = r.bottom - r.top;

            // TODO: Fire an event for window resize.
            break;
        },
        windows.WM_KEYDOWN, windows.WM_SYSKEYDOWN, windows.WM_KEYUP, windows.WM_SYSKEYUP => {
            // Key pressed/released
            const pressed: bool = (msg == windows.WM_KEYDOWN or msg == windows.WM_SYSKEYDOWN);

            // TODO: Input processing
            break;
        },
        windows.WM_MOUSEMOVE => {
            const x_position: i32 = windows.GET_X_LPARAM(l_param);
            const y_position: i32 = windows.GET_Y_LPARAM(l_param);

            // TODO: Input processing
            break;
        },
        windows.WM_MOUSEWHEEL => {
            var z_delta: i32 = windows.GET_WHEEL_DELTA_WPARAM(w_param);
            if (z_delta != 0) {
                // Flatten the input to an OS-independent (-1, 1)
                if (z_delta < 0) {
                    z_delta = -1;
                } else {
                    z_delta = 1;
                }
            }

            // TODO: Input processing
            break;
        },
        windows.WM_LBUTTONDOWN, windows.WM_MBUTTONDOWN, windows.WM_RBUTTONDOWN, windows.WM_LBUTTONUP, windows.WM_MBUTTONUP, windows.WM_RBUTTONUP => {
            const pressed: bool = (msg == windows.WM_LBUTTONDOWN or msg == windows.WM_MBUTTONDOWN or msg == windows.WM_RBUTTONDOWN);

            // TODO: Input processing
            break;
        },
        
        else => {
            return windows.DefWindowProcW(hwnd, msg, w_param, l_param);
        },
    };
}
