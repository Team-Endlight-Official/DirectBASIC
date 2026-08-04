unit DBASIC.Lexer;

{$mode objfpc}{$H+}

interface

type TokenKind = (
    tkIdentifier,
    tkDigit,
    tkString,
    tkComment,
    tkLParen, tkRParen,
    tkComma,
    tkAssignmentOp, tkPlusOp, tkMinusOp, tkMulOp, tkDivOp, tkGreaterOp, tkLessOp,
    tkWhileKw, tkDoKw, tkEndKw, tkBeginKw, tkIfKw, tkThenKw, tkElseKw, tkFunctionKw, tkForKw,
    tkNewLine,
    tkEOF,
    tkUnknown);

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

    tokens:     array of TToken;
    tokenCount: cardinal;
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

procedure AddToken(var lexer: TLexer; kind: TokenKind; value: string; line, column: integer);

procedure Lex(var lexer: TLexer);

procedure WriteTokens(var lexer: TLexer);

implementation

uses
    SysUtils,
    DBASIC.core.IO;

// --- FUNCTIONS ---
function CreateLexer(const sourcePath: string): TLexer;
begin
    Result.position :=   1;
    Result.line :=       1;
    Result.column :=     1;

    Result.tokenCount := 0;
    Result.tokens :=     nil;

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
    if position > length(lexer.source) then
        Result := #0
    else
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

procedure AddToken(var lexer: TLexer; kind: TokenKind; value: string; line, column: integer);
var
    token:              TToken;
begin
    token.kind :=       kind;
    token.value :=      value;
    token.line :=       line;
    token.column :=     column;

    SetLength(lexer.tokens, Length(lexer.tokens) + 1);
    lexer.tokens[High(lexer.tokens)] := token;
end;

// \ INTERNAL LEXER FUNCTIONS
procedure ReadIdentifier(var lexer: TLexer);
var
    identifier:         string;
    kind:               TokenKind;
begin
    identifier := '';
    kind       := TokenKind.tkUnknown;

    while IsLetter(lexer) or IsDigit(lexer) do
    begin
        identifier := identifier + GetCurrentChar(lexer);
        Advance(lexer);
    end;

    // Check Keyword

    case identifier of
        'Begin':    kind := TokenKind.tkBeginKw;
        'End':      kind := TokenKind.tkEndKw;
        'If':       kind := TokenKind.tkIfKw;
        'Else':     kind := TokenKind.tkElseKw;
        'Then':     kind := TokenKind.tkThenKw;
        'Do':       kind := TokenKind.tkDoKw;
        'While':    kind := TokenKind.tkWhileKw;
        'Function': kind := TokenKind.tkFunctionKw;
        'For':      kind := TokenKind.tkForKw;
        else        kind := TokenKind.tkIdentifier;
    end;

    //writeln('Identifier: ', identifier, ' [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
    AddToken(lexer, kind, identifier, GetCurrentLine(lexer), GetCurrentColumn(lexer));
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

    //writeln('Number: ' + number, ' [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
    AddToken(lexer, TokenKind.tkDigit, number, GetCurrentLine(lexer), GetCurrentColumn(lexer));
end;

procedure ReadString(var lexer: TLexer);
var
    str:            string;
begin
    Advance(lexer);
    str := '';

    while GetCurrentChar(lexer) <> '"' do
    begin
        str := str + GetCurrentChar(lexer);
        Advance(lexer);
    end;

    Advance(lexer);

    //writeln('String: "', str, '" [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
    AddToken(lexer, TokenKind.tkString, str, GetCurrentLine(lexer), GetCurrentColumn(lexer));
end;

procedure ReadParenthesis(var lexer: TLexer);
var
    paren:              string;
begin
    paren := '';

    if GetCurrentChar(lexer) = '(' then
    begin
        paren := GetCurrentChar(lexer);
        Advance(lexer);

        //writeln('LParen: "', paren, '" [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
        AddToken(lexer, TokenKind.tkLParen, paren, GetCurrentLine(lexer), GetCurrentColumn(lexer));
    end
    else if GetCurrentChar(lexer) = ')' then
    begin
        paren := GetCurrentChar(lexer);
        Advance(lexer);

        //writeln('RParen: "', paren, '" [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
        AddToken(lexer, TokenKind.tkRParen, paren, GetCurrentLine(lexer), GetCurrentColumn(lexer));
    end;
end;

procedure ReadComma(var lexer: TLexer);
var
    comma:              string;
begin
    comma := '';

    if GetCurrentChar(lexer) = ',' then
    begin
        comma := GetCurrentChar(lexer);
        Advance(lexer);

        //writeln('Comma: "', comma, '" [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
        AddToken(lexer, TokenKind.tkComma, comma, GetCurrentLine(lexer), GetCurrentColumn(lexer));
    end;
end;

procedure ReadAssigner(var lexer: TLexer);
var
    assign:             string;
begin
    assign := '';

    if GetCurrentChar(lexer) = '=' then
    begin
        assign := GetCurrentChar(lexer);
        Advance(lexer);

        //writeln('Assignment Op: "', assign, '" [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
        AddToken(lexer, TokenKind.tkAssignmentOp, assign, GetCurrentLine(lexer), GetCurrentColumn(lexer));
    end;
end;

procedure ReadComment(var lexer: TLexer);
var
    comment:            string;
begin
    Advance(lexer);
    comment := '';

    while not (GetCurrentChar(lexer) in [#10, #13, #0]) do
    begin
        comment := comment + GetCurrentChar(lexer);
        Advance(lexer);
    end;

    AddToken(lexer, TokenKind.tkComment, comment, GetCurrentLine(lexer), GetCurrentColumn(lexer));
    Advance(lexer);
end;

procedure ReadOperand(var lexer: TLexer);
var
    operand:            string;
begin
    operand := GetCurrentChar(lexer);
    case operand of
        '+': AddToken(lexer, TokenKind.tkPlusOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer));
        '-': AddToken(lexer, TokenKind.tkMinusOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer));
        '*': AddToken(lexer, TokenKind.tkMulOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer));
        '/': AddToken(lexer, TokenKind.tkDivOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer));
        '<': AddToken(lexer, TokenKind.tkLessOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer));
        '>': AddToken(lexer, TokenKind.tkGreaterOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer));
    end;


    Advance(lexer);
end;

// / INTERNAL LEXER FUNCTIONS

procedure Lex(var lexer: TLexer);
begin
    //writeln('[LEXICAL ANALYSIS BEGUN]');

    while lexer.position <= GetSourceLength(lexer) do
    begin
        if IsWhitespace(lexer) then
        begin
            if GetCurrentChar(lexer) = #10 then
            begin
                AddToken(lexer, TokenKind.tkNewLine, '', GetCurrentLine(lexer), GetCurrentColumn(lexer))
            end;

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
        else if GetCurrentChar(lexer) = '"' then
        begin
            ReadString(lexer);
        end
        else if GetCurrentChar(lexer) = ';' then
        begin
            ReadComment(lexer);
        end
        else if GetCurrentChar(lexer) = ',' then
        begin
            ReadComma(lexer);
        end
        else if GetcurrentChar(lexer) in ['+', '-', '*', '/', '<', '>'] then
        begin
            ReadOperand(lexer);
        end
        else if GetCurrentChar(lexer) = '=' then
        begin
            ReadAssigner(lexer);
        end
        else if GetCurrentChar(lexer) in ['(', ')'] then
        begin
            ReadParenthesis(lexer);
        end
        else
        begin
            AddToken(lexer, TokenKind.tkUnknown, GetCurrentChar(lexer), GetCurrentLine(lexer), GetCurrentColumn(lexer));
            Advance(lexer);
        end;
    end;

    AddToken(lexer, TokenKind.tkEOF, '', GetCurrentLine(lexer), GetCurrentColumn(lexer));

    //writeln('[LEXICAL ANALYSIS ENDED]');
end;

procedure WriteTokens(var lexer: TLexer);
var
    i:      integer;
    count:  integer;
begin
    count := 0;

    if Length(lexer.tokens) < 1 then
    begin
        writeln('ERR: No tokens found in this lexer!');
        exit;
    end;

    for i := 0 to Length(lexer.tokens) - 1 do
    begin
        writeln('[KIND: ', lexer.tokens[i].kind, ', VALUE: "', lexer.tokens[i].value, '" , LINE: ', lexer.tokens[i].line, ', COLUMN: ', lexer.tokens[i].column, ']');
        inc(count, 1);
    end;

    writeln('Total tokens: ', count);
end;

end.