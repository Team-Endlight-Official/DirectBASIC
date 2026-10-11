unit DBASIC.Parser;

{$mode objfpc}{$H+}

interface

uses
    SysUtils,
    DBASIC.Lexer;

type TParser = record
    position:           integer;
    parenthesisDepth:   integer;
    indentDepth:        integer;

    tokens:             array of TToken;
    irSource:           string;
end;

// Functions
function CreateParser(var lexer: TLexer): TParser;

procedure NextToken(var parser: TParser);
function GetCurrentToken(var parser: TParser): TToken;
function GetNextToken(var parser: TParser): TToken;

procedure Parse(var parser: TParser);

procedure IncParenDepth(var parser: TParser; consume: boolean);
procedure DecParenDepth(var parser: TParser; consume: boolean);

procedure IncIndentDepth(var parser: TParser);
procedure DecIndentDepth(var parser: TParser);

procedure WriteIR(var parser: TParser);
procedure DumpIR(var parser: TParser; path: string);

implementation

uses
    StrUtils;

// Functions
function CreateParser(var lexer: TLexer): TParser;
begin
    Result.position :=          0;
    Result.parenthesisDepth :=  0;
    Result.indentDepth :=       0;
    Result.irSource :=          '';
    Result.tokens :=            lexer.tokens;
end;

procedure EmitIR(var parser: TParser; &string: string);
var
    input:      string;
    indents:    string;
begin
    indents := DupeString('        ', parser.indentDepth);
    input := indents + &string + LineEnding;

    parser.irSource := parser.irSource + input;
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

function GetNextToken(var parser: TParser): TToken;
begin
    Result := parser.tokens[parser.position + 1];
end;

// INTERNAL FUNCTIONS
procedure Parse(var parser: TParser);
begin
    EmitIR(parser, 'ISRCBEGIN');
    IncIndentDepth(parser);

    while GetCurrentToken(parser).kind <> TokenKind.tkEOF do
    begin
        if GetCurrentToken(parser).kind = TokenKind.tkLParen then
        begin
            IncParenDepth(parser, true);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkRParen then
        begin
            DecParenDepth(parser, true);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkComment then
        begin
            NextToken(parser);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkDigit then
        begin
            EmitIR(parser, GetCurrentToken(parser).value);
            NextToken(parser);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkPlusOp then
        begin
            EmitIR(parser, 'OP_PLUS');
            NextToken(parser);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkMinusOp then
        begin
            EmitIR(parser, 'OP_MINUS');
            NextToken(parser);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkMulOp then
        begin
            EmitIR(parser, 'OP_MUL');
            NextToken(parser);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkDivOp then
        begin
            EmitIR(parser, 'OP_DIV');
            NextToken(parser);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkNewLine then
        begin
            EmitIR(parser, 'STMTEND');
            EmitIR(parser, '');
            NextToken(parser);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkIdentifier then
        begin
            EmitIR(parser, GetCurrentToken(parser).value);
            NextToken(parser);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkString then
        begin
            EmitIR(parser, '"' + GetCurrentToken(parser).value + '"');
            NextToken(parser);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkAssignmentOp then
        begin
            EmitIR(parser, 'OP_ASS');
            NextToken(parser);
        end
        else
        begin
            NextToken(parser);
        end;
    end;

    DecIndentDepth(parser);
    EmitIR(parser, 'ISRCEND');
end;

procedure IncParenDepth(var parser: TParser; consume: boolean);
begin
    inc(parser.parenthesisDepth);
    writeln('PARENTHESIS DEPTH: ', parser.parenthesisDepth);
    if consume then NextToken(parser); // Consume (
end;

procedure DecParenDepth(var parser: TParser; consume: boolean);
begin
    dec(parser.parenthesisDepth);
    if (parser.parenthesisDepth < 0) then parser.parenthesisDepth := 0;

    writeln('PARENTHESIS DEPTH: ', parser.parenthesisDepth);
    if consume then NextToken(parser); // Consume )
end;

procedure IncIndentDepth(var parser: TParser);
begin
    inc(parser.indentDepth);
end;

procedure DecIndentDepth(var parser: TParser);
begin
    dec(parser.indentDepth);
    if (parser.indentDepth < 0) then parser.indentDepth := 0;
end;

procedure WriteIR(var parser: TParser);
begin
    writeln(parser.irSource);
end;

procedure DumpIR(var parser: TParser; path: string);
var
    f:      TextFile;
begin
    AssignFile(f, path + 'isrc');
    Rewrite(f);

    writeln(f, parser.irSource);
    CloseFile(f);
end;

end.