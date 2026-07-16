unit DBASIC.&platform.Windowing;

{$mode objfpc}{$H+}

interface

uses
    sysutils;

// Public
procedure CreateWindow(width, height: cardinal; title: string);
procedure CloseWindow();
procedure PollEvents();
procedure SwapBuffers();
procedure DestroyWindow();

function WindowShouldClose(): boolean;
function DoesWindowExist(): boolean;

implementation

uses
    glfw, dglOpenGL;

// Private
var
    window:     PGLFWwindow;

// Public
function DoesWindowExist(): boolean;
begin
    Result := window <> nil;
end;

function WindowShouldClose(): boolean;
begin
    if not DoesWindowExist() then
    begin
        writeln('Error: Window does not exist.');
        Result := true;
        exit;
    end;

    if glfwWindowShouldClose(window) = GLFW_TRUE then
    begin
        Result := true;
        exit;
    end;

    Result := false;
end;

procedure CreateWindow(width, height: cardinal; title: string);
begin
    if DoesWindowExist() then
    begin
        writeln('Warn: Window already exists.');
        exit;
    end;

    if glfwInit = GLFW_FALSE then
    begin
        writeln('Error: Failed to initialize GLFW.');
        exit;
    end;

    glfwDefaultWindowHints();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, 1);
    glfwWindowHint(GLFW_RESIZABLE, 0);
    glfwWindowHint(GLFW_VISIBLE, 1);
    
    window := glfwCreateWindow(width, height, PChar(title), nil, nil);
    if window = nil then
    begin
        writeln('Error: Failed to create GLFW window.');
        glfwTerminate;
        exit;
    end;

    glfwMakeContextCurrent(window);

    if not InitOpenGL() then
    begin
        writeln('Error: Failed to initialize OpenGL.');
        DestroyWindow;
        halt(1);
    end;

    ReadExtensions;
    ReadImplementationProperties;
end;

procedure DestroyWindow();
begin
    if not DoesWindowExist() then
    begin
        writeln('Warn: Window does not exist.');
        exit;
    end;

    glfwDestroyWindow(window);
    window := nil;
    glfwTerminate();
end;

procedure CloseWindow();
begin
    if not DoesWindowExist() then
    begin
        writeln('Warn: Window does not exist.');
        exit;
    end;

    glfwSetWindowShouldClose(window, 1);
end;

procedure PollEvents();
begin
    if not DoesWindowExist() then
    begin
        writeln('Warn: Window does not exist.');
        exit;
    end;

    glfwPollEvents();
end;

procedure SwapBuffers();
begin
    if not DoesWindowExist() then
    begin
        writeln('Warn: Window does not exist.');
        exit;
    end;

    glfwSwapBuffers(window);
end;

end.