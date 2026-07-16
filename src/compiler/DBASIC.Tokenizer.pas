unit DBASIC.Tokenizer;

{$mode objfpc}{$H+}

interface

// Public
uses
    sysutils;

// Public
type TTokenKind = (
    tkEOF,

    tkIdentifier,
    tkInteger,
    tkFloat,
    tkString,

    tkIf,
    tkElse,
    tkWhile,
    tkBegin,
    tkEnd,

    tkPlus,
    tkMinus,
    tkMultiply,
    tkDivide,

    tkEqual,
    tkGreater,
    tkLess,

    tkLeftParen,
    tkRightParen
);

type TToken = record
    kind:       TTokenKind;
    text:       string;
    line:       cardinal;
    column:     cardinal;
end;

type TLexer = record
    source:     string;
    position:   cardinal;
    line:       cardinal;
    column:     cardinal;
end;

// Public
procedure InitializeLexer(source: string);

function CurrentChar(): char;
procedure Advance();
procedure SkipWhitespace();

function NextToken(): TToken;

implementation

// Private
var
    lexer:      TLexer;

// Public
procedure InitializeLexer(source: string);
begin
    lexer.source :=     source;
    lexer.position :=   1;
    lexer.line :=       1;
    lexer.column :=     1;
end;

function CurrentChar(): char;
begin
    if lexer.position > length(lexer.source) then
        Result := #0
    else
        Result := lexer.source[lexer.position];
end;

procedure Advance();
begin
    if CurrentChar = #10 then
    begin
        inc(lexer.line);
        lexer.column := 1;
    end
    else
        inc(lexer.column);
    
    inc(lexer.position);
end;

procedure SkipWhitespace();
begin
    while CurrentChar in [' ', #9, #10, #13] do
        Advance;
end;

function NextToken(): TToken;
begin
    SkipWhitespace;

    if CurrentChar = #0 then
    begin
        Result.kind := tkEOF;
        exit;
    end;

    if CurrentChar in ['A'..'Z', 'a'..'z', '_'] then
        
end;

end.