unit dbUnsafe3D;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface // Public

uses
    dbCore, dbCore3D, dbMath3D, dbTexture2D, sysutils, dglOpenGL;

// Vertex Container
type TVertexContainerHandle = cardinal;

// W.I.P
type TBuffer = record
    handle:         GLuint;
    bufferType:     longInt;
    size:           cardinal;
end;

type TVertexContainerData = record
    handle:        GLuint;
    buf:           GLuint;
    flag_isBuilt:       byte;

    data_vertexCount:   cardinal;
end;

type PVertexContainerData = ^TVertexContainerData;

// Internal
procedure db_unsafe3d_init_internal();

// Public
function CreateVertexContainer(): TVertexContainerHandle;
procedure DeleteVertexContainer(vcontainer: TVertexContainerHandle);

procedure BuildVertexContainer(vcontainer: TVertexContainerHandle);
procedure AddBuffer(vcontainer: TVertexContainerHandle; &type: cardinal; size: cardinal; data: pointer; usage: cardinal);

procedure DrawPrimitive(vcontainer: TVertexContainerHandle);

implementation

var
    vertexContainers:       array of PVertexContainerData;

// Internal
procedure db_unsafe3d_init_internal();
begin
    SetLength(vertexContainers, 1);
    writeln('Unsafe3D module has been initialized!');
end;

function IS_VERTEX_CONTAINER_VALID(vcontainer: TVertexContainerHandle): boolean;
begin
    Result := (vcontainer < Length(vertexContainers)) or (vertexContainers[vcontainer] <> nil);
end;

function IS_VERTEX_CONTAINER_BUILT(vcontainer: TVertexContainerHandle): boolean;
begin
    Result := (vertexContainers[vcontainer]^.flag_isBuilt = 1);
end;

function CreateVertexContainer(): TVertexContainerHandle;
var
    id:         cardinal;
begin
    id := Length(vertexContainers);
    SetLength(vertexContainers, id + 1);
    New(vertexContainers[id]);

    glGenVertexArrays(1, @vertexContainers[id]^.handle);
    glBindVertexArray(vertexContainers[id]^.handle);

    writeln('Vertex Container has been created!');
    Result := id;
end;

procedure DeleteVertexContainer(vcontainer: TVertexContainerHandle);
begin
    if not IS_VERTEX_CONTAINER_VALID(vcontainer) then
    begin
        writeln('Vertex Container was already deleted!');
        exit;
    end;

    glDeleteBuffers(1, @vertexContainers[vcontainer]^.buf);
    glDeleteVertexArrays(1, @vertexContainers[vcontainer]^.handle);
    vertexContainers[vcontainer]^.handle := 0;
    vertexContainers[vcontainer]^.flag_isBuilt := 0;

    Dispose(vertexContainers[vcontainer]);
    vertexContainers[vcontainer] := nil;

    writeln('Vertex Container has been deleted!');
end;

procedure BuildVertexContainer(vcontainer: TVertexContainerHandle);
begin
    glBindVertexArray(NULL);

    vertexContainers[vcontainer]^.flag_isBuilt := 1;

    writeln('Vertex Container has been built!');
end;

procedure AddBuffer(vcontainer: TVertexContainerHandle; &type: cardinal; size: cardinal; data: pointer; usage: cardinal);
begin
    // Setup BufferType
    case &type of
    0: begin
        &type := GL_ARRAY_BUFFER;
    end;
    else
        writeln('Invalid Buffer Type! Defaulting to GL_ARRAY_BUFFER.');
        &type := GL_ARRAY_BUFFER;
    end;

    // Setup Usage
    case usage of
    0: begin
        usage := GL_STATIC_DRAW;
    end;
    else
        writeln('Invalid Usage! Defaulting to GL_STATIC_DRAW.');
        usage := GL_STATIC_DRAW;
    end;

    // Create buffer!
    glGenBuffers(1, @vertexContainers[vcontainer]^.buf);
    glBindBuffer(&type, vertexContainers[vcontainer]^.buf);

    glBufferData(&type, size, data, usage);
    vertexContainers[vcontainer]^.data_vertexCount := 3;

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), nil);
    glEnableVertexAttribArray(0);

    glBindBuffer(&type, 0);
end;

procedure DrawPrimitive(vcontainer: TVertexContainerHandle);
begin
    glBindVertexArray(vertexContainers[vcontainer]^.handle);
    glEnableVertexAttribArray(0);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(0);
    glBindVertexArray(0);
end;

end.