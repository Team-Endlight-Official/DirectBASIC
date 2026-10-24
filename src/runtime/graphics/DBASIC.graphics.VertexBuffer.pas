unit DBASIC.graphics.VertexBuffer;

{$mode objfpc}{$H+}

interface

uses
    dglOpenGL,
    sysutils;

// PUBLIC

type TVertexBuffer = record
    handle:         Gluint;
    btype:          integer;
end;

function CreateVertexBuffer(const btype: integer): TVertexBuffer;
procedure BeginVertexBuffer(var vertexBuffer: TVertexBuffer);
procedure EndVertexBuffer(var vertexBuffer: TVertexBuffer);
procedure DestroyVertexBuffer(var vertexBuffer: TVertexBuffer);

function IsVertexBufferValid(var vertexBuffer: TVertexBuffer): boolean;


implementation

function CreateVertexBuffer(const btype: integer): TVertexBuffer;
begin
    glGenBuffers(1, @Result.handle);
    Result.btype := btype;

    writeln('VertexBuffer ', Result.handle, ' has been created!');
end;

procedure BeginVertexBuffer(var vertexBuffer: TVertexBuffer);
begin
    if not IsVertexBufferValid(vertexBuffer) then exit;

    glBindBuffer(vertexBuffer.btype, vertexBuffer.handle);
end;

procedure EndVertexBuffer(var vertexBuffer: TVertexBuffer);
begin
    if not IsVertexBufferValid(vertexBuffer) then exit;

    glBindBuffer(vertexBuffer.btype, 0);
end;

procedure DestroyVertexBuffer(var vertexBuffer: TVertexBuffer);
begin
    if not IsVertexBufferValid(vertexBuffer) then exit;
    EndVertexBuffer(vertexBuffer);
    writeln('VertexBuffer ', vertexBuffer.handle, ' has been deleted!');
    glDeleteBuffers(1, @vertexBuffer.handle);
end;

function IsVertexBufferValid(var vertexBuffer: TVertexBuffer): boolean;
begin
    Result := not(vertexBuffer.handle = 0);
end;

end.