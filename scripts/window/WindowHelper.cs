using System;
using System.Text;
using System.Diagnostics;
using System.Runtime.InteropServices;
using Godot;
using System.Collections.Generic;


public partial class WindowHelper : Node
{
	// Win32 API 常量和函数
	private const int GWL_EXSTYLE = -20;

	private const int WS_EX_TOOLWINDOW = 0x00000080;
	private const int WS_EX_APPWINDOW = 0x00040000;
	private const int WS_EX_LAYERED = 0x00080000;
	private const int WS_EX_TRANSPARENT = 0x00000020;
	private const int WS_EX_DLGMODALFRAME = 0x00000001;
	private const int WS_EX_TOPMOST = 0x00000008;
	private const int WS_EX_NOACTIVATE = 0x08000000;

	private const int WS_CAPTION = 0x00C00000;
	private const int WS_THICKFRAME = 0x00040000;
	private const int WS_SYSMENU = 0x00080000; 
	private const uint WS_POPUP = 0x80000000;

	private const uint SWP_NOMOVE = 0x0002;
	private const uint SWP_NOSIZE = 0x0001;
	private const uint SWP_NOACTIVATE = 0x0010;
	private const uint SWP_SHOWWINDOW = 0x0040;
	private const uint SWP_ASYNCWINDOWPOS = 0x4000;
	private const uint SWP_NOZORDER = 0x0004;
	private const uint SWP_FRAMECHANGED = 0x0020;

	private const uint RDW_INVALIDATE = 0x0001;
	private const uint RDW_UPDATENOW = 0x0100;
	private const uint RDW_ALLCHILDREN = 0x0080;

	private static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
	private static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
	private static readonly IntPtr HWND_BOTTOM = new IntPtr(1);

	


	[DllImport("user32.dll")]
	private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

	[DllImport("user32.dll")]
	private static extern int GetWindowLong(IntPtr hWnd, int nIndex);

	[DllImport("user32.dll")]
	private static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

	[DllImport("user32.dll")]
	private static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter,
		int X, int Y, int cx, int cy, uint uFlags);
		
	[DllImport("user32.dll")]
	private static extern bool UpdateWindow(IntPtr hWnd);

	[DllImport("user32.dll")]
	private static extern bool RedrawWindow(IntPtr hWnd, IntPtr lprcUpdate, 
		IntPtr hrgnUpdate, uint flags);
		
	[DllImport("user32.dll", SetLastError = true)]
	private static extern int GetWindowThreadProcessId(IntPtr hWnd, out int lpdwProcessId);

	[DllImport("user32.dll")]
	public static extern int GetWindowTextLength(IntPtr hWnd);
	
	[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
	private static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);


	private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

	[DllImport("user32.dll")]
	private static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

	[DllImport("user32.dll")]
	private static extern bool EnumChildWindows(IntPtr hWndParent, EnumWindowsProc lpEnumFunc, IntPtr lParam);

	[DllImport("user32.dll")]
	private static extern bool SetForegroundWindow(IntPtr hWnd);


	public void SetBorderlessSafe(int hwndValue)
	{
		IntPtr hwnd = new IntPtr(hwndValue);

		if (hwnd == IntPtr.Zero)
		{
			return;
		}

		int exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);

		// 移除边框外观，但保留 DWM 正常合成需要的标志
		exStyle |= WS_SYSMENU;

		SetWindowLong(hwnd, GWL_EXSTYLE, exStyle);
	}
	
	public void HideFromTaskbar(int hwndValue, bool hide)
	{
		IntPtr hwnd = new IntPtr(hwndValue);

		if (hwnd == IntPtr.Zero)
		{
			return;
		}
		
		int exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);
		if (hide)
		{
			exStyle &= ~WS_EX_APPWINDOW;
			exStyle |= WS_EX_TOOLWINDOW;
		}
		else
		{
			exStyle |= WS_EX_APPWINDOW;
			exStyle &= ~WS_EX_TOOLWINDOW;
		}

		SetWindowLong(hwnd, GWL_EXSTYLE, exStyle);

		SetWindowPos(hwnd, IntPtr.Zero, 0, 0, 0, 0,
			SWP_NOMOVE | SWP_NOSIZE | 
			SWP_ASYNCWINDOWPOS | SWP_FRAMECHANGED | 
			SWP_SHOWWINDOW);
	}

	public void SetWindowTopmost(int hwndValue)
	{
		IntPtr hwnd = new IntPtr(hwndValue);
		
		if (hwnd == IntPtr.Zero) return;

		int exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);

		SetWindowLong(hwnd, GWL_EXSTYLE, exStyle | WS_EX_TOPMOST);

		SetWindowLong(hwnd, GWL_EXSTYLE, exStyle & ~WS_EX_NOACTIVATE);

		SetWindowPos(hwnd, HWND_TOPMOST, 
			0, 0, 0, 0, 
			SWP_NOMOVE | SWP_NOSIZE | 
			SWP_ASYNCWINDOWPOS | SWP_FRAMECHANGED | 
			SWP_SHOWWINDOW);

		UpdateWindow(hwnd);

		// SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0,
		// 	SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
		// SetForegroundWindow(hwnd);
	}

	public void SetWindowBottom(int hwndValue)
	{
		IntPtr hwnd = new IntPtr(hwndValue);

		if (hwnd == IntPtr.Zero) return;

		int exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);
		SetWindowLong(hwnd, GWL_EXSTYLE, exStyle & ~WS_EX_TOPMOST);


		SetWindowLong(hwnd, GWL_EXSTYLE, exStyle | WS_EX_NOACTIVATE);

		SetWindowPos(hwnd, HWND_BOTTOM, 
			0, 0, 0, 0, 
			SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | 
			SWP_ASYNCWINDOWPOS | SWP_FRAMECHANGED);

		UpdateWindow(hwnd);	
	}

	public void SetWindowMousePassthrough(int hwndValue)
	{
		IntPtr hwnd = new IntPtr(hwndValue);

		if (hwnd == IntPtr.Zero) return;

		int exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);
		exStyle |= WS_EX_LAYERED | WS_EX_TRANSPARENT;

		SetWindowLong(hwnd, GWL_EXSTYLE, exStyle);
	}

	public void SetForegroundWindow(int hwndValue)
	{
		IntPtr hwnd = new IntPtr(hwndValue);

		if (hwnd == IntPtr.Zero) return;

		SetForegroundWindow(hwnd);
	}
}
