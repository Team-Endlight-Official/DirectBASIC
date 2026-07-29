unit DBASIC.Parser;

{$mode objfpc}{$H+}

interface

// OLD STUB CODE!! IGNORE

type ASTNodeKind = (nkProgram, nkFunctionCall, nkIdentifier, nkString, nkDigit, nkAssignment);

type
PASTNode = ^TASTNode;

TASTNode = record
    kind:           ASTNodeKind;
    value:          string;

    children:       array of PASTNode;
end;

implementation

end.