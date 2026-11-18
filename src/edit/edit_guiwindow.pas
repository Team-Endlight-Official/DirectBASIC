//  DirectBASIC Editor GUIWindow unit.
//  This unit is purely for the window and it's renderer.
//  Implementation uses SDL2.
//
//  Version 0.0.1:
//  --> Simple window handling.

unit edit_guiwindow;

{$mode objfpc}{$H+}

interface

uses
    sysutils,
    sdl2;

// GUI Window Struct
type TGUIWindow = record
    p_window:       PSDL_Window;
    p_renderer:     PSDL_Renderer;
    m_event:        TSDL_Event;
    m_running:      boolean;
    m_dirty:        boolean;

    m_title:        string;
    m_width:        cardinal;
    m_height:       cardinal;
end;

type PGUIWindow = ^TGUIWindow;

// Functions
function guiWindow_init(): boolean;
procedure guiWindow_quit();

// Creation/Destroying
function guiWindow_create(const title: string; const width, height: cardinal): TGUIWindow;
procedure guiWindow_destroy(var window: TGUIWindow);

// Polling Events
procedure guiWindow_handleEvents(var window: TGUIWindow);
function guiWindow_waitEvent(var window: TGUIWindow): integer; inline;
function guiWindow_pollEvent(var window: TGUIWindow): integer; inline;

// Rendering
procedure guiWindow_renderPresent(var window: TGUIWindow); inline;
procedure guiWindow_renderClearColor(var window: TGUIWindow; r, g, b, a: byte);

// Setters
procedure guiWindow_closeWindow(var window: TGUIWindow); inline;
procedure guiWindow_setDirty(var window: TGUIWindow; const flag: boolean); inline;

// Getters
function guiWindow_isRunning(var window: TGUIWindow): boolean; inline;
function guiWindow_isDirty(var window: TGUIWindow): boolean; inline;

implementation

// Private variables
var
    m_isInit:       boolean = false;

// Functions
function guiWindow_init(): boolean;
begin
    if SDL_Init(SDL_INIT_VIDEO) <> 0 then
    begin
        writeln('[SDL2]: Failed to initialize: ', SDL_GetError());
        m_isInit := false;
    end
    else
    begin
        m_isInit := true;
    end;

    writeln('[SDL2]: SDL2 has been initialized.');
    Result := m_isInit;
end;


procedure guiWindow_quit();
begin
    if not m_isInit then exit;

    SDL_Quit();
    m_isInit := false;
    writeln('[SDL2]: SDL2 has been terminated.');
end;

// Creation/Destroying
function guiWindow_create(const title: string; const width, height: cardinal): TGUIWindow;
begin
    if not m_isInit then exit;

    // Values setting
    Result.m_title  := title;
    Result.m_width  := width;
    Result.m_height := height;

    // Window Creation
    Result.p_window := SDL_CreateWindow(pchar(title), SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, longInt(width), longInt(height), SDL_WINDOW_RESIZABLE or SDL_WINDOW_ALLOW_HIGHDPI);
    if Result.p_window = nil then
    begin
        writeln('[SDL2]: Failed to create a Window: ', SDL_GetError());
        guiWindow_quit();
        exit;
    end;

    // Renderer Creation
    Result.p_renderer := SDL_CreateRenderer(Result.p_window, -1, SDL_RENDERER_ACCELERATED or SDL_RENDERER_PRESENTVSYNC);
    if Result.p_renderer = nil then
    begin
        writeln('[SDL2]: Failed to create a Renderer: ', SDL_GetError());
        guiWindow_destroy(Result);
        guiWindow_quit();
        exit;
    end;

    Result.m_running := true;
    Result.m_dirty := true;
    writeln('[SDL2]: GUI Window has been created.');
end;

procedure guiWindow_destroy(var window: TGUIWindow);
begin
    if not m_isInit then exit;

    // Reset values
    window.m_running    := false;
    window.m_dirty      := false;
    window.m_height     := 0;
    window.m_width      := 0;
    window.m_title      := '';

    // Destroy Renderer
    if window.p_renderer <> nil then
    begin
        SDL_DestroyWindow(window.p_renderer);
        window.p_renderer := nil;

        writeln('[SDL2]: GUI Window Renderer has been destroyed.');
    end;

    // Destroy Window
    if window.p_window <> nil then
    begin
        SDL_DestroyWindow(window.p_window);
        window.p_window := nil;

        writeln('[SDL2]: GUI Window has been destroyed.');
    end;
end;


// Polling Events
procedure guiWindow_handleEvents(var window: TGUIWindow);
begin
    case window.m_event.type_ of
        SDL_QUITEV:         window.m_running := false;
        SDL_WINDOWEVENT:    window.m_dirty := true;

        SDL_KEYDOWN:
        begin
            if window.m_event.key.keysym.sym = SDLK_ESCAPE then window.m_running := false;
            window.m_dirty := true;
        end;

        SDL_MOUSEMOTION, SDL_MOUSEBUTTONDOWN, SDL_MOUSEBUTTONUP: window.m_dirty := true;
    end;
end;

function guiWindow_waitEvent(var window: TGUIWindow): integer; inline;
begin
    Result := SDL_WaitEvent(@window.m_event);
end;

function guiWindow_pollEvent(var window: TGUIWindow): integer; inline;
begin
    Result := SDL_PollEvent(@window.m_event);
end;


// Rendering
procedure guiWindow_renderPresent(var window: TGUIWindow); inline;
begin
    SDL_RenderPresent(window.p_renderer);
end;

procedure guiWindow_renderClearColor(var window: TGUIWindow; r, g, b, a: byte);
begin
    SDL_SetRenderDrawColor(window.p_renderer, r, g, b, a);
    SDL_RenderClear(window.p_renderer);
end;

// Setters
procedure guiWindow_closeWindow(var window: TGUIWindow); inline;
begin
    window.m_running := false;
end;

procedure guiWindow_setDirty(var window: TGUIWindow; const flag: boolean); inline;
begin
    window.m_dirty := flag;
end;

// Getters
function guiWindow_isRunning(var window: TGUIWindow): boolean; inline;
begin
    Result := window.m_running;
end;

function guiWindow_isDirty(var window: TGUIWindow): boolean; inline;
begin
    Result := window.m_dirty;
end;

end.