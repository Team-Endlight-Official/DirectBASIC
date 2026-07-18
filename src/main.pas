program main;

{$mode objfpc}{$H+}

uses
    SysUtils,
    DBASIC.core.IO;

// Basic interpreter thingy :D

var
    sourcePosition: integer;

type TSource = record
    source:     string;
end;

function LoadSource(const path: string): TSource;
begin
    Result.source := ReadFile(path);
end;

function GetCurrentChar(var source: TSource): char;
begin
    Result := source.source[sourcePosition];
end;

function GetCharAt(var source: TSource; position: integer): char;
begin
    Result := source.source[position];
end;

function GetPosition(): integer;
begin
    Result := sourcePosition;
end;

procedure Advance();
begin
    inc(sourcePosition, 1);
end;

function GetSourceLength(var source: TSource): integer;
begin
    Result := length(source.source);
end;

function IsLetter(var source: TSource): boolean;
begin
    Result := GetCurrentChar(source) in ['a'..'z', 'A'..'Z', '_', '"'];
end;

function IsDigit(var source: TSource): boolean;
begin
    Result := GetCurrentChar(source) in ['0'..'9'];
end;

function IsWhitespace(var source: TSource): boolean;
begin
    Result := GetCurrentChar(source) in [' ', #9..#13];
end;

procedure AcceptString(var source: TSource);
var
    start, &end:        integer;
    strCount:           integer;
    str:                string;
begin
    start := 0;
    &end := 0;
    strCount := -1;
    str := '';

    if (GetCurrentChar(source) <> '"') and (strCount < 0) then
    begin
        writeln(GetCurrentChar(source));
        Advance();
        exit;
    end;

    if GetCurrentChar(source) = '"' then
    begin
        writeln('[BEGIN STRING]');

        Advance();
        start := GetPosition - 1;
        strCount := 0;
    end
    else
    begin
        exit
    end;

    while strCount > -1 do
    begin
        if GetCurrentChar(source) = '"' then
        begin
            Advance();

            &end := GetPosition - 1;
            str := copy(source.source, start, &end);

            writeln('STRING: ' + str);
            writeln('[END STRING]');
            exit;
        end
        else
        begin
            str := str + GetCharAt(source, start + GetPosition);
            Advance();
            inc(strCount, 1);
        end;
    end;
end;

procedure Interpret(var source: TSource);
begin
    sourcePosition := 0;

    writeln('[INTERPRETATION BEGUN]');

    while sourcePosition < GetSourceLength(source) do
    begin
        if IsWhitespace(source) then
        begin
            Advance();
        end
        else if IsLetter(source) then
        begin
            AcceptString(source);
        end
        else if IsDigit(source) then
        begin
            writeln('Digit: ' + GetCurrentChar(source));
            Advance();
        end
        else
        begin
            Advance();
        end;
    end;

    writeln('[INTERPRETATION ENDED]');
end;

var
    s:      TSource;
begin
    writeln('Hello, DirectBASIC!');
    s := LoadSource('codes/example.dib');
    writeln(s.source);
    Interpret(s);

    readln;
end.