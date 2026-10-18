unit DBASIC.core.Console;

{$mode objfpc}{$H+}

interface

// Public
procedure BeginConsole(const title: string; width, height: integer);
procedure EndConsole;

procedure ConsolePrintLn(const msg: string);
procedure ConsolePump;
function IsConsoleOpen: boolean; inline;

implementation

uses
    SysUtils,
    Windows,
    Messages;

const
    MAX_LINES = 512;
    CLASS_NAME = 'dbasconsole';

var
    lines:          array[0..MAX_LINES - 1] of ansiString;
    lineCount:      integer = 0;
    scrollOffset:   integer = 0;

    classReady:     boolean = false;
    wnd:            HWND = 0;
    font:           HFONT = 0;
    lineH:          integer = 16;

// Private
procedure Redraw();
begin
    if wnd <> 0 then InvalidateRect(wnd, nil, false);
end;

procedure PaintConsole(w: HWND);
var
    ps:         TPaintStruct;
    dc, mem:    HDC;
    bmp, &old:  HBITMAP;
    rc:         TRect;
    br:         HBRUSH;
    visible, row, idx, bottom, first: integer;
    s:          ansiString;
begin
    dc := BeginPaint(w, ps);
    GetClientRect(w, rc);

    mem := CreateCompatibleDC(dc);
    bmp := CreateCompatibleBitmap(dc, rc.Right, rc.Bottom);
    &old := SelectObject(mem, bmp);

    br := CreateSolidBrush(RGB(10, 10 ,10));
    FillRect(mem, rc, br);
    DeleteObject(br);

    SelectObject(mem, font);
    SetBkMode(mem, TRANSPARENT);

    visible := rc.Bottom div lineH - 1;
    bottom := lineCount - 1 - scrollOffset;
    first := lineCount - MAX_LINES;

    if first < 0 then first := 0;

    for row := 0 to visible - 1 do
    begin
        idx := bottom - (visible - 1 - row);
        if (idx >= first) and (idx <= lineCount - 1) then
        begin
            s := lines[idx mod MAX_LINES];
            if Copy(s, 1, 5) = 'ERROR' then SetTextColor(mem, RGB(255, 100, 100))
            else if Copy(s, 1, 4) = 'WARN' then SetTextColor(mem, RGB(255, 210, 90))
            else if Copy(s, 1, 4) = 'INFO' then SetTextColor(mem, RGB(90, 210, 255))
            else SetTextColor(mem, RGB(210, 210, 210));
            TextOutA(mem, 4, row * lineH, pAnsiChar(s), length(s));
        end;
    end;

    BitBlt(dc, 0, 0, rc.Right, rc.Bottom, mem, 0, 0, SRCCOPY);
    SelectObject(mem, &old);
    DeleteObject(bmp);
    DeleteDC(dc);
    EndPaint(w, ps);
end;

function WndProc(w: HWND; msg: UINT; wp: WPARAM; lp: LPARAM): LRESULT; stdcall;
var
    delta:      integer;
begin
    Result := 0;

    case msg of
        WM_PAINT: PaintConsole(w);
        WM_ERASEBKGND: Result := 1;
        WM_SIZE: InvalidateRect(w, nil, false);

        WM_MOUSEWHEEL:
            begin
                delta := smallInt(wp shr 16) div 120;
                Inc(scrollOffset, delta * 3);
                if scrollOffset > lineCount - 1 then scrollOffset := lineCount - 1;
                if scrollOffset < 0 then scrollOffset := 0;
                InvalidateRect(w, nil, false);
            end;

        WM_CLOSE: DestroyWindow(w);
        WM_DESTROY: wnd := 0;
    else
        Result := DefWindowProc(w, msg, wp, lp);
    end;
end;

// PUBLIC
procedure BeginConsole(const title: string; width, height: integer);
var
    wc: TWndClass;
    dc: HDC;
    tm: TTextMetric;
begin
    if wnd <> 0 then
    begin
        writeln('WARN: Console already open!');
        exit;
    end;

    if not classReady then
    begin
        FillChar(wc, sizeof(wc), 0);
        wc.lpfnWndProc :=       @WndProc;
        wc.hInstance :=         HInstance;
        wc.hCursor :=           LoadCursor(0, IDC_ARROW);
        wc.lpszClassName :=     CLASS_NAME;
        RegisterClass(wc);

        classReady := true;
    end;

    font := CreateFont(-16, 0, 0, 0, FW_NORMAL, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, FIXED_PITCH or FF_MODERN, 'Courier New');

    dc := GetDC(0);
    SelectObject(dc, font);
    GetTextMetrics(dc, tm);
    lineH := tm.tmHeight + 2;
    ReleaseDC(0, dc);

    lineCount := 0;
    scrollOffset := 0;

    wnd := CreateWindowEx(0, CLASS_NAME, PChar(title), WS_OVERLAPPEDWINDOW or WS_VISIBLE, CW_USEDEFAULT, CW_USEDEFAULT, width, height, 0, 0, HInstance, nil);
end;

procedure EndConsole;
begin
    if wnd <> 0 then DestroyWindow(wnd);
    wnd := 0;

    if font <> 0 then DeleteObject(font);
    font := 0;
end;

function IsConsoleOpen: boolean; inline;
begin
    Result := wnd <> 0;
end;

procedure ConsolePump;
var
    m: TMsg;
begin
    while PeekMessage(m, 0, 0, 0, PM_REMOVE) do
    begin
        TranslateMessage(m);
        DispatchMessage(m);
    end;
end;

procedure ConsolePrintLn(const msg: string);
begin
    if wnd = 0 then exit;

    lines[lineCount mod MAX_LINES] := msg;
    inc(lineCount);
    scrollOffset := 0;
    Redraw;
    ConsolePump;
end;

end.