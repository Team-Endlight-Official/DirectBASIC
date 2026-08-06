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

        else
        begin
            writeln('Unknown argument token!');
            exit;
        end;
    end;

    NextToken(parser);

    // Skip comma
    if GetCurrentToken(parser).kind = TokenKind.tkComma then
    begin
        NextToken(parser);
    end;
end;

procedure ParseFunctionCall(var parser: TParser; &name: string);
begin
    NextToken(parser); // Consume (

    EmitIR(parser, 'CALL ' + &name);

    while GetCurrentToken(parser).kind <> TokenKind.tkRParen do
    begin
        ParseFunctionArguments(parser);
    end;

    NextToken(parser); // Consume )
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
    EmitIR(parser, 'SET ' + &name + ' ' + assignedValue);
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
            writeln('Unknown token!');
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
            inc(parser.parenthesisDepth, 1);
            //writeln('PARENTHESIS DEPTH: ', parser.parenthesisDepth);
            NextToken(parser);
        end
        else if GetCurrentToken(parser).kind = TokenKind.tkRParen then
        begin
            dec(parser.parenthesisDepth, 1);
            //writeln('PARENTHESIS DEPTH: ', parser.parenthesisDepth);
            NextToken(parser);
        end
        else
        begin
            ParseStatement(parser);
        end;
    end;
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