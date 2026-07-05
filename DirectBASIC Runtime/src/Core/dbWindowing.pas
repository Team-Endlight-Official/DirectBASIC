unit dbWindowing;

{$mode objfpc}{$H+}

interface // Public

uses
    dbCore, glfw, sysutils;

// Windowing Handle

type TWindowHandle = type cardinal;

type TWindowData = record
    width:          cardinal;
    height:         cardinal;
    title:          string;

    isResized:      boolean;
    winHandle:      pGLFWwindow;
end;

type TWindowCreationInfo = record
    resizable:      boolean;
    visible:        boolean;
    forwardCompat:  boolean;
    glMajorVersion: integer;
    glMinorVersion: integer;
    glProfile:      integer;
end;

const
    WCI_GL_CORE_PROFILE = GLFW_OPENGL_CORE_PROFILE;
    WCI_GL_COMPAT_PROFILE = GLFW_OPENGL_COMPAT_PROFILE;
    WCI_GL_ANY_PROFILE = GLFW_OPENGL_ANY_PROFILE;

    WCI_COMPAT: TWindowCreationInfo = (
        resizable:      true;
        visible:        true;
        forwardCompat:  true;
        glMajorVersion: 3;
        glMinorVersion: 3;
        glProfile:      WCI_GL_COMPAT_PROFILE;
    );

    WCI_330: TWindowCreationInfo = (
        resizable:      true;
        visible:        true;
        forwardCompat:  false;
        glMajorVersion: 3;
        glMinorVersion: 3;
        glProfile:      WCI_GL_CORE_PROFILE;
    );

// Internal Functions
procedure glfw_error_callback(error: longInt; const description: PChar); cdecl;
procedure glfw_window_size_callback(window: pGLFWwindow; w, h: longInt); cdecl;

procedure db_windowing_init_internal();

// Void Functions
procedure DestroyWindow(win: TWindowHandle);
procedure UpdateWindow(win: TWindowHandle);
procedure SetContextCurrent(win: TWindowHandle);
procedure SetWindowTitle(win: TWindowHandle; title: string);
procedure SetWindowResizable(win: TWindowHandle; resizable: boolean);
procedure SetWindowPosition(win: TWindowHandle; x, y: integer);
procedure EnableVSync();
procedure DisableVSync();
procedure SetWindowVisible(win: TWindowHandle; visible: boolean);
procedure LockCursor(win: TWindowHandle);
procedure UnlockCursor(win: TWindowHandle);
procedure CloseWindow(win: TWindowHandle);
procedure PollEvents();

// Return Functions
function CreateWindow(w, h: cardinal; title: string): TWindowHandle;
function CreateWindow(w, h: cardinal; title: string; wci: TWindowCreationInfo): TWindowHandle;
function WindowShouldClose(win: TWindowHandle): boolean;
function GetWindowAspectRatio(win: TWindowHandle): single;
function WasWindowResized(win: TWindowHandle): boolean;
function GetWindowWidth(win: TWindowHandle): cardinal;
function GetWindowHeight(win: TWindowHandle): cardinal;

function IsKeyDown(win: TWindowHandle; key: longInt): boolean;
function IsKeyUp(win: TWindowHandle; key: longInt): boolean;
procedure GetCursorPos(win: TWindowHandle; var x, y: double);

implementation // Private / Implementation

type PWindowData = ^TWindowData;

var
    windows:        array of PWindowData;


// INTERNAL PRIVATE GLFW FUNCTIONS
function BOOL_TO_GLFWBOOL(glfwBool: boolean): longInt;
begin
    if glfwBool = true then
        Result := GLFW_TRUE
    else if glfwBool = false then
        Result := GLFW_FALSE
    else
        Result := GLFW_FALSE;
end;

// Void Functions
procedure glfw_error_callback(error: longInt; const description: PChar); cdecl;
begin
    writeln('GLFW Error: ' + description);
end;

procedure glfw_window_size_callback(window: pGLFWwindow; w, h: longInt); cdecl;
var
    data: PWindowData;
begin
    data := PWindowData(glfwGetWindowUserPointer(window));

    if data = nil then
        exit;

    data^.width := w;
    data^.height := h;
    data^.isResized := true;
end;

procedure db_windowing_init_internal();
begin
    glfwSetErrorCallback(@glfw_error_callback);

    if glfwInit = GLFW_FALSE then
    begin
        writeln('GLFW could not be initialized!');
        halt(1);
    end;

    SetLength(windows, 1);
    writeln('Windowing module has been initialized!');
end;

function IS_WINDOW_VALID(window: TWindowHandle): boolean;
begin
    Result := (window < Length(windows)) or (windows[window] <> nil);
end;

procedure DestroyWindow(win: TWindowHandle);
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to destroy is invalid 0.');
        exit;
    end;

    glfwDestroyWindow(windows[win]^.winHandle);
    writeln('GLFW Window has been destroyed!');

    windows[win]^.winHandle := nil;
    windows[win]^.width := 0;
    windows[win]^.height := 0;
    windows[win]^.title := '';

    Dispose(windows[win]);
    windows[win] := nil;
end;

procedure UpdateWindow(win: TWindowHandle);
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to update is invalid 0.');
        exit;
    end;

    glfwSwapBuffers(windows[win]^.winHandle);
end;

procedure SetContextCurrent(win: TWindowHandle);
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to set context current is invalid 0.');
        exit;
    end;

    glfwMakeContextCurrent(windows[win]^.winHandle);
end;

procedure SetWindowTitle(win: TWindowHandle; title: string);
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to set title is invalid 0.');
        exit;
    end;

    windows[win]^.title := title;
    glfwSetWindowTitle(windows[win]^.winHandle, PChar(windows[win]^.title));
end;

procedure SetWindowResizable(win: TWindowHandle; resizable: boolean);
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to set resizable attrib is invalid 0.');
        exit;
    end;

    glfwSetWindowAttrib(windows[win]^.winHandle, GLFW_RESIZABLE, BOOL_TO_GLFWBOOL(resizable));
end;

procedure SetWindowPosition(win: TWindowHandle; x, y: integer);
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to set position is invalid 0.');
        exit;
    end;

    glfwSetWindowPos(windows[win]^.winHandle, x, y);
end;

procedure EnableVSync();
begin
    glfwSwapInterval(1);
end;

procedure DisableVSync();
begin
    glfwSwapInterval(0);
end;

procedure SetWindowVisible(win: TWindowHandle; visible: boolean);
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to set visible is invalid 0.');
        exit;
    end;

    glfwSetWindowAttrib(windows[win]^.winHandle, GLFW_VISIBLE, BOOL_TO_GLFWBOOL(visible));
end;

procedure LockCursor(win: TWindowHandle);
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to lock cursor is invalid 0.');
        exit;
    end;

    glfwSetInputMode(windows[win]^.winHandle, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
end;

procedure UnlockCursor(win: TWindowHandle);
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to unlock cursor is invalid 0.');
        exit;
    end;

    glfwSetInputMode(windows[win]^.winHandle, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
end;

procedure CloseWindow(win: TWindowHandle);
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to close is invalid 0.');
        exit;
    end;

    glfwSetWindowShouldClose(windows[win]^.winHandle, GLFW_TRUE);
end;

procedure PollEvents();
begin
    glfwPollEvents;
end;

// Return Functions
function CreateWindow(w, h: cardinal; title: string): TWindowHandle;
var
    id:             cardinal;
begin
    id := Length(windows);
    SetLength(windows, id + 1);

    New(windows[id]);

    windows[id]^.width :=    w;
    windows[id]^.height :=   h;
    windows[id]^.title :=    title;
    windows[id]^.isResized := false;

    windows[id]^.winHandle := glfwCreateWindow(windows[id]^.width, windows[id]^.height, PChar(windows[id]^.title), nil, nil);
    if windows[id]^.winHandle = nil then
    begin
        glfwTerminate;
        writeln('GLFW Window could not be created!');
        halt(1);
    end;
    glfwSetWindowUserPointer(windows[id]^.winHandle, windows[id]);

    glfwSetWindowSizeCallback(windows[id]^.winHandle, @glfw_window_size_callback);
    writeln('GLFW Window has been created successfully!');
    Result := id;
end;

function CreateWindow(w, h: cardinal; title: string; wci: TWindowCreationInfo): TWindowHandle;
begin
    glfwWindowHint(GLFW_RESIZABLE, BOOL_TO_GLFWBOOL(wci.resizable));
    glfwWindowHint(GLFW_VISIBLE, BOOL_TO_GLFWBOOL(wci.visible));
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, wci.glMajorVersion);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, wci.glMinorVersion);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, BOOL_TO_GLFWBOOL(wci.forwardCompat));
    glfwWindowHint(GLFW_OPENGL_PROFILE, wci.glProfile);

    Result := CreateWindow(w, h, title);
end;

function WindowShouldClose(win: TWindowHandle): boolean;
begin
    Result := glfwWindowShouldClose(windows[win]^.winHandle) = GLFW_TRUE;
end;

function GetWindowAspectRatio(win: TWindowHandle): single;
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to get aspect ration from is invalid 0.');
        exit;
    end;

    Result := single(windows[win]^.width) / single(windows[win]^.height);
end;

function WasWindowResized(win: TWindowHandle): boolean;
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to check resize status from is invalid 0.');
        Result := false;
        exit;
    end;

    Result := windows[win]^.isResized;
    windows[win]^.isResized := false;
end;

function GetWindowWidth(win: TWindowHandle): cardinal;
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to get width from is invalid 0.');
        exit;
    end;

    Result := windows[win]^.width;
end;

function GetWindowHeight(win: TWindowHandle): cardinal;
begin
    if not IS_WINDOW_VALID(win) then
    begin
        writeln('GLFW Window you tried to get height from is invalid 0.');
        exit;
    end;

    Result := windows[win]^.height;
end;

function IsKeyDown(win: TWindowHandle; key: longInt): boolean;
begin
    Result := glfwGetKey(windows[win]^.winHandle, key) = GLFW_PRESS;
end;

function IsKeyUp(win: TWindowHandle; key: longInt): boolean;
begin
    Result := glfwGetKey(windows[win]^.winHandle, key) = GLFW_RELEASE;
end;

procedure GetCursorPos(win: TWindowHandle; var x: double; var y: double);
var
    xPos, yPos: double;
begin
    glfwGetCursorPos(windows[win]^.winHandle, xPos, yPos);
    x := xPos;
    y := yPos;
end;

end.