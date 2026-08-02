program main;

{$mode objfpc}{$H+}

uses
    SysUtils,
    DBASIC.Lexer;

var
    lexer:      TLexer;
begin
    writeln('Hello, DirectBASIC!');
    lexer := CreateLexer('codes/example.dib');
    Lex(lexer);

    WriteTokens(lexer);

    readln;
end.