program test;

{$mode objfpc}{$H+}
{$APPTYPE GUI}

uses
    SysUtils,
    DBASIC.core.Console;

begin
    BeginConsole('WOW', 800, 600);
    ConsolePrintLn('Hello, Console!');
    ConsolePrintLn('ERROR: You idiot!');
    ConsolePrintLn('WARN: Ehm... actually..!');
    ConsolePrintLn('INFO: just so you know.. this is actually insane');
    ConsolePrintLn('Here we go again!');

    ConsolePrintLn('');
    ConsolePrintLn('App Information: ');
    ConsolePrintLn('Width: 800');
    ConsolePrintLn('Height: 600');
    ConsolePrintLn('OpenGL Version: 3.3.0 CORE');
    ConsolePrintLn('Windowing Backend: GLFW');

    while IsConsoleOpen do 
    begin
        ConsolePump;
        Sleep(16);
    end;

    EndConsole();
end.