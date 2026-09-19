program main;

{$mode objfpc}{$H+}

uses
    SysUtils,
    DBASIC.Lexer,
    DBASIC.Parser;

const
    VERSION = '0.1.1';

function readStdin: string;
var
    line: string;
begin
    Result := '';

    while not EOF(Input) do
    begin
        readln(line);

        if Result <> '' then
        begin
            Result := Result + LineEnding;
        end;

        Result := Result + line;
    end;
end;

procedure tokenize();
var
    param: string;
    lexer: TLexer;
begin
    param := readStdin;

    lexer := CreateLexer(param);
    Lex(lexer);
    
    writeln(GetTokensJSON(lexer));
end;

var
    // Compiler test
    lexer:      TLexer;
    parser:     TParser;

    // CLI Controls
    command:    string;
begin
    if ParamCount = 0 then
    begin
        writeln('DirectBASIC Compiler CLI v', VERSION);
        writeln('Write "directbasic help" to list all available commands.');
        writeln;
        writeln('Endlight 2024-2026');

        halt(1);
    end;

    // command parsing
    command := LowerCase(ParamStr(1));

    case command of
        'help':
        begin
            writeln('DirectBASIC available commands: ');
            writeln('build {file.bas} -- Compiles and Builds the specified file into either an executable or a library.');
            writeln('tokenize {string} -- Tokenizes the specified string and outputs a JSON representation of all the tokens.');
        end;
        'tokenize':
        begin
            tokenize;
        end;

        else
        begin 
            writeln('Unknown command, ', ParamStr(1));
            halt(1);
        end;
    end;
end.