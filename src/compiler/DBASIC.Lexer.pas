unit DBASIC.Lexer;

{$mode objfpc}{$H+}

interface

type TokenKind = (tkIdentifier, tkDigit, tkString, tkEOF);

type TToken = record
    kind:       TokenKind;
    value:      string;
    line:       integer;
    column:     integer;
end;

type TLexer = record
    source:     string;
    position:   integer;
    line:       integer;
    column:     integer;
end;

// --- FUNCTIONS ---
function CreateLexer(const sourcePath: string): TLexer;
function GetCurrentChar(var lexer: TLexer): char;
function GetCharAt(var lexer: TLexer; position: integer): char;
function GetCurrentPosition(var lexer: TLexer): integer;
function GetCurrentLine(var lexer: TLexer): integer;
function GetCurrentColumn(var lexer: TLexer): integer;
function GetSourceLength(var lexer: TLexer): integer;

function IsLetter(var lexer: TLexer): boolean;
function IsDigit(var lexer: TLexer): boolean;
function IsWhitespace(var lexer: TLexer): boolean;

procedure Advance(var lexer: TLexer);

procedure Lex(var lexer: TLexer);

implementation

uses
    SysUtils,
    DBASIC.core.IO;

// --- FUNCTIONS ---
function CreateLexer(const sourcePath: string): TLexer;
begin
    Result.position := 1;
    Result.line :=     1;
    Result.column :=   1;
    Result.source := ReadFile(sourcePath);
    writeln('Lexer has been created!');
end;

function GetCurrentChar(var lexer: TLexer): char;
begin
    if lexer.position > length(lexer.source) then
        Result := #0
    else
        Result := lexer.source[lexer.position];
end;

function GetCharAt(var lexer: TLexer; position: integer): char;
begin
    Result := lexer.source[position];
end;

function GetCurrentPosition(var lexer: TLexer): integer;
begin
    Result := lexer.position;
end;

function GetCurrentLine(var lexer: TLexer): integer;
begin
    Result := lexer.line;
end;

function GetCurrentColumn(var lexer: TLexer): integer;
begin
    Result := lexer.column;
end;

function GetSourceLength(var lexer: TLexer): integer;
begin
    Result := length(lexer.source);
end;

function IsLetter(var lexer: TLexer): boolean;
begin
    Result := GetCurrentChar(lexer) in ['a'..'z', 'A'..'Z', '_'];
end;

function IsDigit(var lexer: TLexer): boolean;
begin
    Result := GetCurrentChar(lexer) in ['0'..'9'];
end;

function IsWhitespace(var lexer: TLexer): boolean;
begin
    Result := GetCurrentChar(lexer) in [' ', #9..#13];
end;

procedure Advance(var lexer: TLexer);
begin
    if GetCurrentChar(lexer) = #10 then
    begin
        inc(lexer.line, 1);
        lexer.column := 1;
    end
    else
        inc(lexer.column, 1);
    
    inc(lexer.position, 1);
end;

// \ INTERNAL LEXER FUNCTIONS
procedure ReadIdentifier(var lexer: TLexer);
var
    identifier:         string;
begin
    identifier := '';

    while IsLetter(lexer) or IsDigit(lexer) do
    begin
        identifier := identifier + GetCurrentChar(lexer);
        Advance(lexer);
    end;

    writeln('Identifier: ', identifier, ' [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
end;

procedure ReadNumber(var lexer: TLexer);
var
    number:          string;
begin
    number := '';

    while IsDigit(lexer) or (GetCurrentChar(lexer) in ['.']) do
    begin
        number := number + GetCurrentChar(lexer);
        Advance(lexer);
    end;

    writeln('Number: ' + number, ' [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
end;

// / INTERNAL LEXER FUNCTIONS

procedure Lex(var lexer: TLexer);
begin
    writeln('[LEXICAL ANALYSIS BEGUN]');

    while lexer.position <= GetSourceLength(lexer) do
    begin
        if IsWhitespace(lexer) then
        begin
            Advance(lexer);
        end
        else if IsLetter(lexer) then
        begin
            ReadIdentifier(lexer);
        end
        else if IsDigit(lexer) then
        begin
            ReadNumber(lexer);
        end
        else
        begin
            Advance(lexer);
        end;
    end;

    writeln('[LEXICAL ANALYSIS ENDED]');
end;

end.