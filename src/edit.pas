program edit;

{$mode objfpc}{$H+}

uses
    sysutils,
    edit_guiwindow;

var
    window:     TGUIWindow;
begin
    if not guiWindow_init() then halt(1);

    window := guiWindow_create('Test Window SDL2', 800, 600);
    while guiWindow_isRunning(window) do
    begin
        if guiWindow_isDirty(window) then
        begin
            guiWindow_renderClearColor(window, 24, 24, 24, 255);
            guiWindow_renderPresent(window);

            guiWindow_setDirty(window, false);
        end;

        if guiWindow_waitEvent(window) = 0 then break;
        guiWindow_handleEvents(window);

        while guiWindow_pollEvent(window) = 1 do guiWindow_handleEvents(window);
    end;

    guiWindow_destroy(window);
    guiWindow_quit();
    readln;
end.