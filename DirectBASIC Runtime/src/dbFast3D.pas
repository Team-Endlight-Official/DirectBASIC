unit dbFast3D;

{$mode objfpc}{$H+}

interface // Public

uses
    dbCore, dbMath3D, dbTexture2D, sysutils, gl, glu, glext;

// Fast Mesh
type TFastMesh = record
    position:           TVec3;
    rotation:           TVec3;
    scale:              TVec3;

    vertices:           array of TVec3;
    vertexColors:       array of TVec3;
    texCoords:          array of TVec2;
end;

// Fast Camera
type TFastCamera = record
    position:           TVec3;
    rotation:           TVec3;
    fov:                single;
    nearPlane:          single;
    farPlane:           single;
end;

// Void Functions
procedure PrintGLInfo();

// Core GL Stuff
procedure SetViewport(x, y, w, h: integer);
procedure SetClearColor(r, g, b, a: single);
procedure SetClearMask(mask: longInt);

// Debug stuff
procedure EnableWireframe();
procedure DisableWireframe();

// Fast3D stuff
procedure DrawFastMesh(mesh: TFastMesh);
procedure DrawFastMesh(mesh: TFastMesh; texture: TTexture2DHandle);
procedure BeginFast3D(w, h: cardinal; fov: single; nearPlane: single; farPlane: single);
procedure BeginFast3D(w, h: cardinal; camera: TFastCamera);

// Return Functions
function CreateCubeFast(pos, rot, scale: TVec3): TFastMesh;
function CreateCameraFast(pos, rot: TVec3; fov: single; nearPlane: single; farPlane: single): TFastCamera;

implementation

// Void Functions
procedure PrintGLInfo();
begin
    writeln('GL Vendor: ' + PChar(glGetString(GL_VENDOR)));
    writeln('GL Renderer: ' + PChar(glGetString(GL_RENDERER)));
    writeln('GL Version: ' + PChar(glGetString(GL_VERSION)));
    writeln('GL GLSL Version: ' + PChar(glGetString(GL_SHADING_LANGUAGE_VERSION)));
end;

procedure SetViewport(x, y, w, h: integer);
begin
    glViewport(x, y, w, h);
end;

procedure SetClearColor(r, g, b, a: single);
begin
    glClearColor(r, g, b, a);
end;

procedure SetClearMask(mask: longInt);
begin
    glClear(mask);
end;

procedure EnableWireframe();
begin
    glDisable(GL_TEXTURE_2D);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    glLineWidth(1.25);
end;

procedure DisableWireframe();
begin
    glEnable(GL_TEXTURE_2D);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
end;

procedure DrawFastMesh(mesh: TFastMesh);
var
    i: integer;
begin
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glTranslatef(mesh.position.x, mesh.position.y, -mesh.position.z);
    glRotatef(mesh.rotation.x, 1, 0, 0);
    glRotatef(mesh.rotation.y, 0, 1, 0);
    glRotatef(mesh.rotation.z, 0, 0, 1);
    glScalef(mesh.scale.x, mesh.scale.y, mesh.scale.z);

    glBegin(GL_QUADS);
        for i := 0 to Length(mesh.vertices) - 1 do
        begin
            glColor3f(mesh.vertexColors[i].x, mesh.vertexColors[i].y, mesh.vertexColors[i].z);
            glTexCoord2f(mesh.texCoords[i].x, mesh.texCoords[i].y);
            glVertex3f(mesh.vertices[i].x, mesh.vertices[i].y, mesh.vertices[i].z);
        end;
    glEnd;
end;

procedure DrawFastMesh(mesh: TFastMesh; texture: TTexture2DHandle);
begin
    BindTexture(texture);
    DrawFastMesh(mesh);
    BindTexture(0);
end;

procedure BeginFast3D(w, h: cardinal; fov: single; nearPlane: single; farPlane: single);
begin
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    gluPerspective(fov, single(w) / single(h), nearPlane, farPlane);

    glMatrixMode(GL_MODELVIEW);
end;

procedure BeginFast3D(w, h: cardinal; camera: TFastCamera);
begin
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    gluPerspective(camera.fov, single(w) / single(h), camera.nearPlane, camera.farPlane);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;
    glRotatef(-camera.rotation.x, 1, 0, 0);
    glRotatef(-camera.rotation.y, 0, 1, 0);
    glRotatef(-camera.rotation.z, 0, 0, 1);
    glTranslatef(-camera.position.x, -camera.position.y, -camera.position.z);
end;

// Return Functions
function CreateCubeFast(pos, rot, scale: TVec3): TFastMesh;
begin
    // Generate Mesh Data
    SetLength(Result.vertices, 24);
    SetLength(Result.vertexColors, 24);
    SetLength(Result.texCoords, 24);

    // Front Face
    // Vertices
    Result.vertices[0] := TVec3.Create(-0.5, -0.5, 0.5); // Bottom Left
    Result.vertices[1] := TVec3.Create(-0.5, 0.5, 0.5); // Top Left
    Result.vertices[2] := TVec3.Create(0.5, 0.5, 0.5); // Top Right
    Result.vertices[3] := TVec3.Create(0.5, -0.5, 0.5); // Bottom Right
    // Vertex Colors
    Result.vertexColors[0] := TVec3.Create(1, 0, 0); // Red
    Result.vertexColors[1] := TVec3.Create(0, 1, 0); // Green
    Result.vertexColors[2] := TVec3.Create(0, 0, 1); // Blue
    Result.vertexColors[3] := TVec3.Create(1, 1, 0); // Yellow
    // Texture Coordinates
    Result.texCoords[0] := TVec2.Create(0, 0); // Bottom Left
    Result.texCoords[1] := TVec2.Create(0, 1); // Top Left
    Result.texCoords[2] := TVec2.Create(1, 1); // Top Right
    Result.texCoords[3] := TVec2.Create(1, 0); // Bottom Right

    // Back Face
    // Vertices
    Result.vertices[4] := TVec3.Create(0.5, -0.5, -0.5); // Bottom Right
    Result.vertices[5] := TVec3.Create(0.5, 0.5, -0.5); // Top Right
    Result.vertices[6] := TVec3.Create(-0.5, 0.5, -0.5); // Top Left
    Result.vertices[7] := TVec3.Create(-0.5, -0.5, -0.5); // Bottom Left
    // Vertex Colors
    Result.vertexColors[4] := TVec3.Create(1, 0, 0); // Red
    Result.vertexColors[5] := TVec3.Create(0, 1, 0); // Green
    Result.vertexColors[6] := TVec3.Create(0, 0, 1); // Blue
    Result.vertexColors[7] := TVec3.Create(1, 1, 0); // Yellow
    // Texture Coordinates
    Result.texCoords[4] := TVec2.Create(0, 0); // Bottom Left
    Result.texCoords[5] := TVec2.Create(0, 1); // Top Left
    Result.texCoords[6] := TVec2.Create(1, 1); // Top Right
    Result.texCoords[7] := TVec2.Create(1, 0); // Bottom Right

    // Top Face
    // Vertices
    Result.vertices[8] := TVec3.Create(-0.5, 0.5, 0.5); // Front Left
    Result.vertices[9] := TVec3.Create(-0.5, 0.5, -0.5); // Back Left
    Result.vertices[10] := TVec3.Create(0.5, 0.5, -0.5); // Back Right
    Result.vertices[11] := TVec3.Create(0.5, 0.5, 0.5); // Front Right
    // Vertex Colors
    Result.vertexColors[8] := TVec3.Create(1, 0, 0); // Red
    Result.vertexColors[9] := TVec3.Create(0, 1, 0); // Green
    Result.vertexColors[10] := TVec3.Create(0, 0, 1); // Blue
    Result.vertexColors[11] := TVec3.Create(1, 1, 0); // Yellow
    // Texture Coordinates
    Result.texCoords[8] := TVec2.Create(0, 0); // Bottom Left
    Result.texCoords[9] := TVec2.Create(0, 1); // Top Left
    Result.texCoords[10] := TVec2.Create(1, 1); // Top Right
    Result.texCoords[11] := TVec2.Create(1, 0); // Bottom Right

    // Bottom Face
    // Vertices
    Result.vertices[12] := TVec3.Create(0.5, -0.5, 0.5); // Front Right
    Result.vertices[13] := TVec3.Create(0.5, -0.5, -0.5); // Back Right
    Result.vertices[14] := TVec3.Create(-0.5, -0.5, -0.5); // Back Left
    Result.vertices[15] := TVec3.Create(-0.5, -0.5, 0.5); // Front Left
    // Vertex Colors
    Result.vertexColors[12] := TVec3.Create(1, 0, 0); // Red
    Result.vertexColors[13] := TVec3.Create(0, 1, 0); // Green
    Result.vertexColors[14] := TVec3.Create(0, 0, 1); // Blue
    Result.vertexColors[15] := TVec3.Create(1, 1, 0); // Yellow
    // Texture Coordinates
    Result.texCoords[12] := TVec2.Create(0, 0); // Bottom Left
    Result.texCoords[13] := TVec2.Create(0, 1); // Top Left
    Result.texCoords[14] := TVec2.Create(1, 1); // Top Right
    Result.texCoords[15] := TVec2.Create(1, 0); // Bottom Right

    // Left Face
    // Vertices
    Result.vertices[16] := TVec3.Create(-0.5, -0.5, -0.5); // Bottom Left
    Result.vertices[17] := TVec3.Create(-0.5, 0.5, -0.5); // Top Left
    Result.vertices[18] := TVec3.Create(-0.5, 0.5, 0.5); // Top Right
    Result.vertices[19] := TVec3.Create(-0.5, -0.5, 0.5); // Bottom Right
    // Vertex Colors
    Result.vertexColors[16] := TVec3.Create(1, 0, 0); // Red
    Result.vertexColors[17] := TVec3.Create(0, 1, 0); // Green
    Result.vertexColors[18] := TVec3.Create(0, 0, 1); // Blue
    Result.vertexColors[19] := TVec3.Create(1, 1, 0); // Yellow
    // Texture Coordinates
    Result.texCoords[16] := TVec2.Create(0, 0); // Bottom Left
    Result.texCoords[17] := TVec2.Create(0, 1); // Top Left
    Result.texCoords[18] := TVec2.Create(1, 1); // Top Right
    Result.texCoords[19] := TVec2.Create(1, 0); // Bottom Right

    // Right Face
    // Vertices
    Result.vertices[20] := TVec3.Create(0.5, -0.5, 0.5); // Bottom Left
    Result.vertices[21] := TVec3.Create(0.5, 0.5, 0.5); // Top Left
    Result.vertices[22] := TVec3.Create(0.5, 0.5, -0.5); // Top Right
    Result.vertices[23] := TVec3.Create(0.5, -0.5, -0.5); // Bottom Right
    // Vertex Colors
    Result.vertexColors[20] := TVec3.Create(1, 0, 0); // Red
    Result.vertexColors[21] := TVec3.Create(0, 1, 0); // Green
    Result.vertexColors[22] := TVec3.Create(0, 0, 1); // Blue
    Result.vertexColors[23] := TVec3.Create(1, 1, 0); // Yellow
    // Texture Coordinates
    Result.texCoords[20] := TVec2.Create(0, 0); // Bottom Left
    Result.texCoords[21] := TVec2.Create(0, 1); // Top Left
    Result.texCoords[22] := TVec2.Create(1, 1); // Top Right
    Result.texCoords[23] := TVec2.Create(1, 0); // Bottom Right

    Result.position := pos;
    Result.rotation := rot;
    Result.scale := scale;
end;

function CreateCameraFast(pos, rot: TVec3; fov: single; nearPlane: single; farPlane: single): TFastCamera;
begin
    Result.position := pos;
    Result.rotation := rot;
    Result.fov := fov;
    Result.nearPlane := nearPlane;
    Result.farPlane := farPlane;
end;

end.