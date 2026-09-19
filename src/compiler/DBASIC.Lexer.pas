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
    tkAccessor,
    tkAssignmentOp, tkPlusOp, tkMinusOp, tkMulOp, tkDivOp, tkGreaterOp, tkLessOp, tkLessEquOp, tkGreaterEquOp,
    tkWhileKw, tkDoKw, tkEndKw, tkBeginKw, tkIfKw, tkThenKw, tkElseKw, tkFunctionKw, tkForKw,
    tkIntegerDt, tkFloatDt, tkStringDt,
    tkNewLine,
    tkEOF,
    tkUnknown);

type TToken = record
    kind:       TokenKind;
    value:      string;
    line:       integer;
    column:     integer;
    start:      integer;
    &end:       integer;
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
function CreateLexer(const source: string): TLexer;

function GetCurrentChar(var lexer: TLexer): char;
function GetCharAt(var lexer: TLexer; position: integer): char;
function GetNextChar(var lexer: TLexer): char;
function GetPrevChar(var lexer: TLexer): char;
function GetCurrentPosition(var lexer: TLexer): integer;
function GetCurrentLine(var lexer: TLexer): integer;
function GetCurrentColumn(var lexer: TLexer): integer;
function GetSourceLength(var lexer: TLexer): integer;

function IsLetter(var lexer: TLexer): boolean;
function IsDigit(var lexer: TLexer): boolean;
function IsWhitespace(var lexer: TLexer): boolean;

procedure Advance(var lexer: TLexer);

procedure AddToken(var lexer: TLexer; kind: TokenKind; value: string; line, column, start, &end: integer);

procedure Lex(var lexer: TLexer);

procedure WriteTokens(var lexer: TLexer);
function GetTokensJSON(var lexer: TLexer): string;

implementation

uses
    SysUtils,
    DBASIC.core.IO;

// --- FUNCTIONS ---
function CreateLexer(const source: string): TLexer;
begin
    Result.position :=   1;
    Result.line :=       1;
    Result.column :=     1;

    Result.tokenCount := 0;
    Result.tokens :=     nil;

    // Check whether the source is a file path
    if (IsFileExtension(source, '.bas')) and (DoesFileExist(source)) then
    begin
        Result.source := ReadFile(source);
    end
    else
    begin
        Result.source := source;
    end;
    
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

function GetNextChar(var lexer: TLexer): char;
begin
    Result := GetCharAt(lexer, lexer.position + 1);
end;

function GetPrevChar(var lexer: TLexer): char;
begin
    Result := GetCharAt(lexer, lexer.position - 1);
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

procedure AddToken(var lexer: TLexer; kind: TokenKind; value: string; line, column, start, &end: integer);
var
    token:              TToken;
begin
    token.kind :=       kind;
    token.value :=      value;
    token.line :=       line;
    token.column :=     column;
    token.start :=      start;
    token.&end :=       &end;

    SetLength(lexer.tokens, Length(lexer.tokens) + 1);
    lexer.tokens[High(lexer.tokens)] := token;
end;

// \ INTERNAL LEXER FUNCTIONS
procedure ReadIdentifier(var lexer: TLexer);
var
    identifier:         string;
    kind:               TokenKind;
    start:              integer;
    &end:               integer;
begin
    identifier := '';
    kind       := TokenKind.tkUnknown;
    start      := GetCurrentPosition(lexer);
    &end       := GetCurrentPosition(lexer);

    while IsLetter(lexer) or IsDigit(lexer) do
    begin
        identifier := identifier + GetCurrentChar(lexer);
        inc(&end);
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
    // Check Datatype
        'Int':      kind := TokenKind.tkIntegerDt;
        'String':   kind := TokenKind.tkStringDt;
        'Float':    kind := TokenKind.tkFloatDt;

        else        kind := TokenKind.tkIdentifier;
    end;

    //writeln('Identifier: ', identifier, ' [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
    AddToken(lexer, kind, identifier, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
end;

procedure ReadNumber(var lexer: TLexer);
var
    number:          string;
    start:           integer;
    &end:            integer;
begin
    number := '';
    start  := GetCurrentPosition(lexer);
    &end   := GetCurrentPosition(lexer);

    while IsDigit(lexer) or (GetCurrentChar(lexer) in ['.']) do
    begin
        number := number + GetCurrentChar(lexer);
        inc(&end);
        Advance(lexer);
    end;

    //writeln('Number: ' + number, ' [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
    AddToken(lexer, TokenKind.tkDigit, number, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
end;

procedure ReadString(var lexer: TLexer);
var
    str:            string;
    start:          integer;
    &end:           integer;
begin
    start := GetCurrentPosition(lexer);
    &end := GetCurrentPosition(lexer);

    inc(&end);
    Advance(lexer);
    str := '';

    while GetCurrentChar(lexer) <> '"' do
    begin
        inc(&end);
        str := str + GetCurrentChar(lexer);
        Advance(lexer);
    end;

    inc(&end);
    Advance(lexer);

    //writeln('String: "', str, '" [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
    AddToken(lexer, TokenKind.tkString, str, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
end;

procedure ReadParenthesis(var lexer: TLexer);
var
    paren:              string;
    start:              integer;
    &end:               integer;
begin
    paren := '';
    start := GetCurrentPosition(lexer);
    &end := GetCurrentPosition(lexer);

    if GetCurrentChar(lexer) = '(' then
    begin
        inc(&end);
        paren := GetCurrentChar(lexer);
        Advance(lexer);

        //writeln('LParen: "', paren, '" [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
        AddToken(lexer, TokenKind.tkLParen, paren, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
    end
    else if GetCurrentChar(lexer) = ')' then
    begin
        inc(&end);
        paren := GetCurrentChar(lexer);
        Advance(lexer);

        //writeln('RParen: "', paren, '" [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
        AddToken(lexer, TokenKind.tkRParen, paren, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
    end;
end;

procedure ReadComma(var lexer: TLexer);
var
    comma:              string;
    start:              integer;
    &end:               integer;
begin
    comma := '';
    start := GetCurrentPosition(lexer);
    &end := GetCurrentPosition(lexer);

    if GetCurrentChar(lexer) = ',' then
    begin
        comma := GetCurrentChar(lexer);
        inc(&end);
        Advance(lexer);

        //writeln('Comma: "', comma, '" [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
        AddToken(lexer, TokenKind.tkComma, comma, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
    end;
end;

procedure ReadAccessor(var lexer: TLexer);
var
    accessor:              string;
    start:                 integer;
    &end:                  integer;
begin
    accessor := '';
    start := GetCurrentPosition(lexer);
    &end := GetCurrentPosition(lexer);

    if GetCurrentChar(lexer) = ':' then
    begin
        inc(&end);
        accessor := GetCurrentChar(lexer);
        Advance(lexer);

        //writeln('Comma: "', comma, '" [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
        AddToken(lexer, TokenKind.tkAccessor, accessor, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
    end;
end;

procedure ReadAssigner(var lexer: TLexer);
var
    assign:             string;
    start:              integer;
    &end:               integer;
begin
    assign := '';
    start := GetCurrentPosition(lexer);
    &end := GetCurrentPosition(lexer);

    if GetCurrentChar(lexer) = '=' then
    begin
        inc(&end);
        assign := GetCurrentChar(lexer);
        Advance(lexer);

        //writeln('Assignment Op: "', assign, '" [at line: ', GetCurrentLine(lexer), ', col: ', GetCurrentColumn(lexer), ']');
        AddToken(lexer, TokenKind.tkAssignmentOp, assign, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
    end;
end;

procedure ReadComment(var lexer: TLexer);
var
    comment:            string;
    start:              integer;
    &end:               integer;
begin
    start := GetCurrentPosition(lexer);
    &end := GetCurrentPosition(lexer);

    inc(&end);
    Advance(lexer);
    comment := '';

    while not (GetCurrentChar(lexer) in [#10, #13, #0]) do
    begin
        inc(&end);
        comment := comment + GetCurrentChar(lexer);
        Advance(lexer);
    end;

    AddToken(lexer, TokenKind.tkComment, comment, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
    Advance(lexer);
end;

procedure ReadOperand(var lexer: TLexer);
var
    operand:            string;
    start:              integer;
    &end:               integer;
begin
    operand := GetCurrentChar(lexer);
    start := GetCurrentPosition(lexer);
    &end := GetCurrentPosition(lexer) + 1;

    case operand of
        '+': AddToken(lexer, TokenKind.tkPlusOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
        '-': AddToken(lexer, TokenKind.tkMinusOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
        '*': AddToken(lexer, TokenKind.tkMulOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
        '/': AddToken(lexer, TokenKind.tkDivOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);

        '<': 
        begin
            if (GetNextChar(lexer) = '=') then
            begin
                inc(&end);
                operand := operand + '=';
                AddToken(lexer, TokenKind.tkLessEquOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
                Advance(lexer);
            end
            else
            begin
                AddToken(lexer, TokenKind.tkLessOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
            end;
        end;

        '>':
        begin
            if (GetNextChar(lexer) = '=') then
            begin
                operand := operand + '=';
                inc(&end);
                AddToken(lexer, TokenKind.tkGreaterEquOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
                Advance(lexer);
            end
            else
            begin
                AddToken(lexer, TokenKind.tkGreaterOp, operand, GetCurrentLine(lexer), GetCurrentColumn(lexer), start, &end);
            end;
        end;
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
            if GetCurrentChar(lexer) = #13 then
            begin
                AddToken(lexer, TokenKind.tkNewLine, '', GetCurrentLine(lexer), GetCurrentColumn(lexer), 0, 0)
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
        else if GetCurrentChar(lexer) = ':' then
        begin
            ReadAccessor(lexer);
        end
        else if GetCurrentChar(lexer) = ',' then
        begin
            ReadComma(lexer);
        end
        else if GetCurrentChar(lexer) in ['+', '-', '*', '/', '<', '>'] then
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
            AddToken(lexer, TokenKind.tkUnknown, GetCurrentChar(lexer), GetCurrentLine(lexer), GetCurrentColumn(lexer), 0, 0);
            Advance(lexer);
        end;
    end;

    AddToken(lexer, TokenKind.tkEOF, '', GetCurrentLine(lexer), GetCurrentColumn(lexer), 0, 0);

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
        writeln('[KIND: ', lexer.tokens[i].kind, ', VALUE: "', lexer.tokens[i].value, '" , LINE: ', lexer.tokens[i].line, ', COLUMN: ', lexer.tokens[i].column, ', START: ', lexer.tokens[i].start, ', END: ', lexer.tokens[i].&end, ']');
        inc(count, 1);
    end;

    writeln('Total tokens: ', count);
end;

function TokenKindToString(const kind: TokenKind): string;
begin
    case kind of
        TokenKind.tkIdentifier: exit('IDENTIFIER');
        TokenKind.tkLParen:     exit('LPAREN');
        TokenKind.tkRParen:     exit('RPAREN');
        TokenKind.tkString:     exit('STRING');
        TokenKind.tkDigit:      exit('DIGIT');
    end;

    Result := 'UNKNOWN';
end;

function GetTokensJSON(var lexer: TLexer): string;
var
    json:   string;
    i:      integer;
begin
    json := '';
    json := json + '{' + lineending;

    if Length(lexer.tokens) < 1 then
    begin
        writeln('ERR: No tokens found in this lexer!');
        Result := '';
        exit;
    end;

    json := json + '    "tokens": [' + lineending;

    for i := 0 to Length(lexer.tokens) - 1 do
    begin
        case lexer.tokens[i].kind of
            TokenKind.tkEOF:        continue;
            TokenKind.tkNewLine:    continue;
            
            else
            begin
                json := json + '        {' + lineending;

                json := json + '            "kind": ' + '"' + TokenKindToString(lexer.tokens[i].kind) + '",' + lineending;
                json := json + '            "value": ' + '"' + lexer.tokens[i].value + '",' + lineending;
                json := json + '            "start": ' + inttostr(lexer.tokens[i].start) + '",' + lineending;
                json := json + '            "end": ' + inttostr(lexer.tokens[i].&end) + '",' + lineending;

                json := json + '        },' + lineending;
            end;
        end;
    end;

    json := json + '    ]' + lineending;
    json := json + '}';
    Result := json;
end;

end.