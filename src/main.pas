program main;

{$mode objfpc}{$H+}

uses
    SysUtils,
    DBASIC.Lexer,
    DBASIC.Parser,
    DBASIC.core.IO;

var
    // Compiler test
    lexer:      TLexer;
    parser:     TParser;
    input:      string;
begin
    if not DoesFileExist('main.bas') then exit;

    input := ReadFile('main.bas');

    lexer := CreateLexer(input);
    Lex(lexer);

    parser := CreateParser(lexer);
    Parse(parser);

    DumpIR(parser, '');
end.