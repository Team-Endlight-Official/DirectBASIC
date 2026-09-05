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

procedure IncParenDepth(var parser: TParser; consume: boolean);
procedure DecParenDepth(var parser: TParser; consume: boolean);

procedure WriteIR(var parser: TParser);
procedure DumpIR(var parser: TParser; path: string);

implementation

// Functions
function CreateParser(var lexer: TLexer): TParser;
begin
    Result.position :=          0;
    Result.parenthesisDepth :=  0;
    Result.irSource :=          '';
    Result.tokens :=            lexer.tokens;
end;

procedure EmitIR(var parser: TParser; &string: string);
begin
    parser.irSource := parser.irSource + &string + LineEnding;
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

// INTERNAL FUNCTIONS
procedure ParseFunctionArguments(var parser: TParser);
var
    token:          TToken;
begin
    token := GetCurrentToken(parser);

    case token.kind of
        TokenKind.tkString:
        begin
            EmitIR(parser, 'ARG "' + token.value + '"');
        end;

        TokenKind.tkDigit:
        begin
            EmitIR(parser, 'ARG ' + token.value);
        end;

        TokenKind.tkIdentifier:
        begin
            EmitIR(parser, 'ARG ' + token.value);
        end;

        TokenKind.tkComma:
        begin
            EmitIR(parser, 'COMMA');
        end;

        TokenKind.tkDivOp:
        begin
            EmitIR(parser, 'OP_DIV');
        end;

        TokenKind.tkMulOp:
        begin
            EmitIR(parser, 'OP_MUL');
        end;

        TokenKind.tkPlusOp:
        begin
            EmitIR(parser, 'OP_PLUS');
        end;

        TokenKind.tkMinusOp:
        begin
            EmitIR(parser, 'OP_MINUS');
        end;

        TokenKind.tkLParen:
        begin
            IncParenDepth(parser, false);
            EmitIR(parser, 'PAREN_OPEN');
        end;

        TokenKind.tkRParen:
        begin
            DecParenDepth(parser, false);
            EmitIR(parser, 'PAREN_CLOSE');
        end;

        else
        begin
            writeln('Unknown argument token! ', GetCurrentToken(parser).kind);
            exit;
        end;
    end;

    NextToken(parser);

    {
    // Skip comma
    if GetCurrentToken(parser).kind = TokenKind.tkComma then
    begin
        EmitIR(parser, 'COMMA');
        NextToken(parser);
    end;
    }
end;

procedure ParseFunctionCall(var parser: TParser; &name: string);
begin
    IncParenDepth(parser, true); // Consume (

    EmitIR(parser, 'CALL ' + &name);

    while (GetCurrentToken(parser).kind <> TokenKind.tkRParen) and (parser.parenthesisDepth < 2) do
    begin
        ParseFunctionArguments(parser);
    end;

    DecParenDepth(parser, true); // Consume )
    EmitIR(parser, 'ENDCALL');
    EmitIR(parser, 'STMTEND');
    EmitIR(parser, '');
end;

procedure ParseIdentifierAssignment(var parser: TParser; &name: string);
var
    &type:          string;
    assigned:       TToken;
    assignedValue:  string;
begin
    NextToken(parser); // Consume =
    &type := '';
    assignedValue := '';

    assigned := GetCurrentToken(parser);
    case assigned.kind of
        TokenKind.tkString:
        begin
            &type := 'STRING';
            assignedValue := '"' + assigned.value + '"';
        end;
        TokenKind.tkDigit:
        begin
            &type := 'DIGIT';
            assignedValue := assigned.value;
        end;
    end;

    EmitIR(parser, 'VAR ' + &name + ' ' + &type);
    EmitIR(parser, 'SET ' + &name);
    EmitIR(parser, assignedValue);
    EmitIR(parser, 'STMTEND');
    EmitIR(parser, '');

    NextToken(parser);
end;

procedure ParseIdentifierStatement(var parser: TParser);
var
    &name:          string;
begin
    &name := GetCurrentToken(parser).value;

    NextToken(parser);

    case GetCurrentToken(parser).kind of
        TokenKind.tkLParen:             ParseFunctionCall(parser, &name);
        TokenKind.tkAssignmentOp:       ParseIdentifierAssignment(parser, &name);
    end;
end;

procedure ParseStatement(var parser: TParser);
begin
    case GetCurrentToken(parser).kind of
        TokenKind.tkIdentifier:         ParseIdentifierStatement(parser);
        TokenKind.tkNewLine:            NextToken(parser);
        else
        begin
            writeln('Unknown token! ', GetCurrentToken(parser).kind);
            NextToken(parser);
            exit;
        end;
    end;
end;

procedure Parse(var parser: TParser);
begin
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
        else
        begin
            ParseStatement(parser);
        end;
    end;
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

procedure WriteIR(var parser: TParser);
begin
    writeln(parser.irSource);
end;

procedure DumpIR(var parser: TParser; path: string);
var
    f:      TextFile;
begin
    AssignFile(f, path + 'ir.txt');
    Rewrite(f);

    writeln(f, parser.irSource);
    CloseFile(f);
end;

end.