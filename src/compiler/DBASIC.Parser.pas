unit DBASIC.Parser;

{$mode objfpc}{$H+}

interface

uses
    SysUtils,
    DBASIC.Lexer;

type TParser = record
    position:           integer;
    parenthesisDepth:   integer;

    tokens:             array of TToken;
    irSource:           string;
end;

// Functions
function CreateParser(var lexer: TLexer): TParser;

procedure NextToken(var parser: TParser);
function GetCurrentToken(var parser: TParser): TToken;

procedure Parse(var parser: TParser);

implementation

// Functions
function CreateParser(var lexer: TLexer): TParser;
begin
    Result.position :=          0;
    Result.parenthesisDepth :=  0;
    Result.irSource :=          '';
    Result.tokens :=            lexer.tokens;
end;

procedure NextToken(var parser: TParser);
begin
    if GetCurrentToken(parser).kind = TokenKind.tkEOF then
        exit;

    inc(parser.position, 1);
end;

function GetCurrentToken(var parser: TParser): TToken;
begin
    Result := parser.tokens[parser.position];
end;

procedure Parse(var parser: TParser);
begin
    while GetCurrentToken(parser).kind <> TokenKind.tkEOF do
    begin
        if GetCurrentToken(parser).kind = TokenKind.tkLParen then
        begin
            inc(parser.parenthesisDepth, 1);
            writeln('PARENTHESIS DEPTH: ', parser.parenthesisDepth);
            NextToken(parser);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkRParen then
        begin
            dec(parser.parenthesisDepth, 1);
            writeln('PARENTHESIS DEPTH: ', parser.parenthesisDepth);
            NextToken(parser);
        end
        else
        begin
            writeln('TOKEN PARSED!');
            NextToken(parser);
        end;
    end;
end;

end.