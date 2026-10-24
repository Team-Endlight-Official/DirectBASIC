unit DBASIC.graphics.VertexArray;

{$mode objfpc}{$H+}

interface

uses
    dglOpenGL,
    sysutils;

// PUBLIC

type TVertexArray = record
    handle:         Gluint;
end;

function CreateVertexArray(): TVertexArray;
procedure BeginVertexArray(var vertexArray: TVertexArray);
procedure EndVertexArray();
procedure DestroyVertexArray(var vertexArray: TVertexArray);

function IsVertexArrayValid(var vertexArray: TVertexArray): boolean;


implementation

function CreateVertexArray(): TVertexArray;
begin
    glGenVertexArrays(1, @Result.handle);
    writeln('VertexArray ', Result.handle, ' has been created!');
end;

procedure BeginVertexArray(var vertexArray: TVertexArray);
begin
    if not IsVertexArrayValid(vertexArray) then exit;

    glBindVertexArray(vertexArray.handle);
end;

procedure EndVertexArray();
begin
    glBindVertexArray(0);
end;

procedure DestroyVertexArray(var vertexArray: TVertexArray);
begin
    if not IsVertexArrayValid(vertexArray) then exit;
    EndVertexArray();
    writeln('VertexArray ', vertexArray.handle, ' has been deleted!');
    glDeleteVertexArrays(1, @vertexArray.handle);
end;

function IsVertexArrayValid(var vertexArray: TVertexArray): boolean;
begin
    Result := not(vertexArray.handle = 0);
end;

end.