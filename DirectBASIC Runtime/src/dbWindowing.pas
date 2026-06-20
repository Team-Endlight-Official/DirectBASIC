unit dbWindowing;

{$mode objfpc}{$H+}

interface // Public

uses
    dbCore, glfw, sysutils;

// Windowing Handle

type TWindowHandle = cardinal;

type TWindowData = record
    width:          cardinal;
    height:         cardinal;
    title:          string;
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

    WCI_330: TWindowCreationInfo = (
        resizable:      true;
        visible:        true;
        forwardCompat:  true;
        glMajorVersion: 3;
        glMinorVersion: 3;
        glProfile:      WCI_GL_COMPAT_PROFILE;
    );

// Void Functions
procedure DestroyWindow(win: TWindowHandle);
procedure UpdateWindow(win: TWindowHandle);
procedure MakeContextCurrent(win: TWindowHandle);
procedure SetWindowTitle(win: TWindowHandle; title: string);
procedure SetWindowResizable(win: TWindowHandle; resizable: boolean);
procedure SetWindowPosition(win: TWindowHandle; x, y: integer);
procedure SetSwapInterval(interval: integer);
procedure SetWindowVisible(win: TWindowHandle; visible: boolean);
procedure CloseWindow(win: TWindowHandle);
procedure PollEvents();

// Return Functions
function CreateWindow(w, h: cardinal; title: string): TWindowHandle;
function CreateWindow(w, h: cardinal; title: string; wci: TWindowCreationInfo): TWindowHandle;
function WindowShouldClose(win: TWindowHandle): boolean;
function GetWindowAspectRatio(win: TWindowHandle): single;

function IsKeyDown(win: TWindowHandle; key: longInt): boolean;
function IsKeyUp(win: TWindowHandle; key: longInt): boolean;

implementation // Private / Implementation

var
    windows:        array of TWindowData;


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


procedure DestroyWindow(win: TWindowHandle);
begin
    if win = NULL then
    begin
        writeln('GLFW Window you tried to destroy is invalid 0.');
        exit;
    end;

    glfwDestroyWindow(windows[win].winHandle);
    writeln('GLFW Window has been destroyed!');

    windows[win].winHandle := nil;
    windows[win].width := 0;
    windows[win].height := 0;
    windows[win].title := '';

    win := NULL;
end;

procedure UpdateWindow(win: TWindowHandle);
begin
    if win = NULL then
    begin
        writeln('GLFW Window you tried to update is invalid 0.');
        exit;
    end;

    glfwSwapBuffers(windows[win].winHandle);
end;

procedure MakeContextCurrent(win: TWindowHandle);
begin
    if win = NULL then
    begin
        writeln('GLFW Window you tried to make context current is invalid 0.');
        exit;
    end;

    glfwMakeContextCurrent(windows[win].winHandle);
end;

procedure SetWindowTitle(win: TWindowHandle; title: string);
begin
    if win = NULL then
    begin
        writeln('GLFW Window you tried to set title is invalid 0.');
        exit;
    end;

    windows[win].title := title;
    glfwSetWindowTitle(windows[win].winHandle, PChar(windows[win].title));
end;

procedure SetWindowResizable(win: TWindowHandle; resizable: boolean);
begin
    if win = NULL then
    begin
        writeln('GLFW Window you tried to set resizable attrib is invalid 0.');
        exit;
    end;

    glfwSetWindowAttrib(windows[win].winHandle, GLFW_RESIZABLE, BOOL_TO_GLFWBOOL(resizable));
end;

procedure SetWindowPosition(win: TWindowHandle; x, y: integer);
begin
    if win = NULL then
    begin
        writeln('GLFW Window you tried to set position is invalid 0.');
        exit;
    end;

    glfwSetWindowPos(windows[win].winHandle, x, y);
end;

procedure SetSwapInterval(interval: integer);
begin
    glfwSwapInterval(interval);
end;

procedure SetWindowVisible(win: TWindowHandle; visible: boolean);
begin
    if win = NULL then
    begin
        writeln('GLFW Window you tried to set visible is invalid 0.');
        exit;
    end;

    glfwSetWindowAttrib(windows[win].winHandle, GLFW_VISIBLE, BOOL_TO_GLFWBOOL(visible));
end;

procedure CloseWindow(win: TWindowHandle);
begin
    if win = NULL then
    begin
        writeln('GLFW Window you tried to close is invalid 0.');
        exit;
    end;

    glfwSetWindowShouldClose(windows[win].winHandle, GLFW_TRUE);
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

    windows[id].width :=    w;
    windows[id].height :=   h;
    windows[id].title :=    title;

    windows[id].winHandle := glfwCreateWindow(windows[id].width, windows[id].height, PChar(windows[id].title), nil, nil);
    if windows[id].winHandle = nil then
    begin
        glfwTerminate;
        writeln('GLFW Window could not be created!');
        halt(1);
    end;

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
    Result := glfwWindowShouldClose(windows[win].winHandle) = GLFW_TRUE;
end;

function GetWindowAspectRatio(win: TWindowHandle): single;
begin
    if win = NULL then
    begin
        writeln('GLFW Window you tried to get aspect ration from is invalid 0.');
        exit;
    end;

    Result := single(windows[win].width) / single(windows[win].height);
end;

function IsKeyDown(win: TWindowHandle; key: longInt): boolean;
begin
    Result := glfwGetKey(windows[win].winHandle, key) = GLFW_PRESS;
end;

function IsKeyUp(win: TWindowHandle; key: longInt): boolean;
begin
    Result := glfwGetKey(windows[win].winHandle, key) = GLFW_RELEASE;
end;

// Initialisation logic
initialization
    glfwSetErrorCallback(@glfw_error_callback);

    if glfwInit = GLFW_FALSE then
    begin
        writeln('GLFW could not be initialized!');
        halt(1);
    end;

    SetLength(windows, 1);
    writeln('GLFW has been initialized successfully!');
end.