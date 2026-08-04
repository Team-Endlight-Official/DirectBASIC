program main;

{$mode objfpc}{$H+}

uses
    SysUtils,
    DBASIC.Lexer,
    DBASIC.Parser;

var
    lexer:      TLexer;
    parser:         TParser;
begin
    writeln('Hello, DirectBASIC!');
    writeln('');
    writeln('LEXER/TOKENIZER:');
    writeln('');

    lexer := CreateLexer('codes/example.dbx');
    Lex(lexer);
    WriteTokens(lexer);

    writeln('');
    writeln('IR PARSER:');
    writeln('');
    parser := CreateParser(lexer);
    Parse(parser);

    readln;
end.