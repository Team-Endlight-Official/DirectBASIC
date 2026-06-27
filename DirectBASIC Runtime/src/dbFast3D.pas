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

// Fast3D stuff
procedure SetFogModeFast(mode: GLenum);
procedure SetFogColorFast(r, g, b, a: single);
procedure SetFogDensityFast(density: single);
procedure SetFogStartEndFast(start, &end: single);

procedure SetMaterialSpecularFast(face: cardinal; r, g, b, a: single);
procedure SetMaterialShininessFast(face: cardinal; shininess: single);

procedure DrawMeshFast(var mesh: TFastMesh);
procedure DrawMeshFast(var mesh: TFastMesh; texture: TTexture2DHandle);
procedure Begin3DFast(w, h: cardinal; fov: single; nearPlane: single; farPlane: single);
procedure Begin3DFast(w, h: cardinal; camera: TFastCamera);
procedure End3DFast();

procedure Draw2DQuadFast(x, y, w, h, r, g, b, a: single; texture: TTexture2DHandle);
procedure Begin2DFast(w, h: cardinal);
procedure End2DFast();

procedure SetPositionFast(var mesh: TFastMesh; x, y, z: single);
procedure SetRotationFast(var mesh: TFastMesh; x, y, z: single);
procedure SetScaleFast(var mesh: TFastMesh; x, y, z: single);

procedure SetCameraPositionFast(var camera: TFastCamera; x, y, z: single);
procedure SetCameraRotationFast(var camera: TFastCamera; x, y, z: single);

// Return Functions
function CreateCubeFast(pos, rot, scale: TVec3): TFastMesh;
function CreatePyramidFast(pos, rot, scale: TVec3): TFastMesh;

function CreateCameraFast(pos, rot: TVec3; fov: single; nearPlane: single; farPlane: single): TFastCamera;

implementation

// Void Functions
procedure SetFogModeFast(mode: cardinal);
begin
    case mode of
    0: begin
        mode := GL_LINEAR;
    end;
    1: begin
        mode := GL_EXP;
    end;
    2: begin
        mode := GL_EXP2;
    end;
    else
        writeln('Invalid fog mode! Defaulting to GL_LINEAR.');
        mode := GL_LINEAR;
    end;

    glFogi(GL_FOG_MODE, mode);
end;

procedure SetFogColorFast(r, g, b, a: single);
var
    color: array[0..3] of single;
begin
    color[0] := r;
    color[1] := g;  
    color[2] := b;
    color[3] := a;
    glFogfv(GL_FOG_COLOR, color);
end;

procedure SetFogDensityFast(density: single);
begin
    glFogf(GL_FOG_DENSITY, density);
end;

procedure SetFogStartEndFast(start, &end: single);
begin
    glFogf(GL_FOG_START, start);
    glFogf(GL_FOG_END, &end);
end;

procedure SetMaterialSpecularFast(face: cardinal; r, g, b, a: single);
var
    specular: array[0..3] of single;
begin
    specular[0] := r;
    specular[1] := g;
    specular[2] := b;
    specular[3] := a;

    case face of
    0: begin
        face := GL_FRONT;
    end;
    1: begin
        face := GL_BACK;
    end;
    else
        writeln('Invalid face! Defaulting to GL_FRONT.');
        face := GL_FRONT;
    end;

    glMaterialfv(face, GL_SPECULAR, specular);
end;

procedure SetMaterialShininessFast(face: cardinal; shininess: single);
begin
    case face of
    0: begin
        face := GL_FRONT;
    end;
    1: begin
        face := GL_BACK;
    end;
    else
        writeln('Invalid face! Defaulting to GL_FRONT.');
        face := GL_FRONT;
    end;

    glMaterialf(face, GL_SHININESS, shininess);
end;

procedure DrawMeshFast(var mesh: TFastMesh);
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

    glPopMatrix;
end;

procedure DrawMeshFast(var mesh: TFastMesh; texture: TTexture2DHandle);
begin
    BindTexture(texture);
    DrawMeshFast(mesh);
    BindTexture(0);
end;

procedure Begin3DFast(w, h: cardinal; fov: single; nearPlane: single; farPlane: single);
begin
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;
    gluPerspective(fov, single(w) / single(h), nearPlane, farPlane);

    glMatrixMode(GL_MODELVIEW);
end;

procedure Begin3DFast(w, h: cardinal; camera: TFastCamera);
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

procedure End3DFast();
begin
    glPopMatrix;
end;

procedure Draw2DQuadFast(x, y, w, h, r, g, b, a: single; texture: TTexture2DHandle);
begin
    BindTexture(texture);

    glColor4f(r, g, b, a);
    glBegin(GL_QUADS);

    glTexCoord2f(1, 1); glVertex2f(x, y);
    glTexCoord2f(0, 1); glVertex2f(x + w, y);
    glTexCoord2f(0, 0); glVertex2f(x + w, y + h);
    glTexCoord2f(1, 0); glVertex2f(x, y + h);

    glEnd;

    BindTexture(0);
end;

procedure Begin2DFast(w, h: cardinal);
begin
    glMatrixMode(GL_PROJECTION);
    glPushMatrix;
    glLoadIdentity;
    glOrtho(0, w, h, 0, -1, 1);

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glLoadIdentity;

    glDisable(GL_DEPTH_TEST);
    glDisable(GL_FOG);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
end;

procedure End2DFast();
begin
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_FOG);
    glDisable(GL_BLEND);

    glPopMatrix;
end;

procedure SetPositionFast(var mesh: TFastMesh; x, y, z: single);
begin
    mesh.position.x := x;
    mesh.position.y := y;
    mesh.position.z := z;
end;

procedure SetRotationFast(var mesh: TFastMesh; x, y, z: single);
begin
    mesh.rotation.x := x;
    mesh.rotation.y := y;
    mesh.rotation.z := z;
end;

procedure SetScaleFast(var mesh: TFastMesh; x, y, z: single);
begin
    mesh.scale.x := x;
    mesh.scale.y := y;
    mesh.scale.z := z;
end;

procedure SetCameraPositionFast(var camera: TFastCamera; x, y, z: single);
begin
    camera.position.x := x;
    camera.position.y := y;
    camera.position.z := z;
end;

procedure SetCameraRotationFast(var camera: TFastCamera; x, y, z: single);
begin
    camera.rotation.x := x;
    camera.rotation.y := y;
    camera.rotation.z := z;
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

function CreatePyramidFast(pos, rot, scale: TVec3): TFastMesh;
begin
    SetLength(Result.vertices, 20);
    SetLength(Result.vertexColors, 20);
    SetLength(Result.texCoords, 20);

    // Face Bottom
    // Vertices
    Result.vertices[0] := TVec3.Create(0.5, -0.5, 0.5); // Front Right
    Result.vertices[1] := TVec3.Create(0.5, -0.5, -0.5); // Back Right
    Result.vertices[2] := TVec3.Create(-0.5, -0.5, -0.5); // Back Left
    Result.vertices[3] := TVec3.Create(-0.5, -0.5, 0.5); // Front Left
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

    // Face Front
    // Vertices
    Result.vertices[4] := TVec3.Create(-0.5, -0.5, 0.5); // Bottom Left
    Result.vertices[5] := TVec3.Create(0.0, 0.5, 0.0); // Top
    Result.vertices[6] := TVec3.Create(0.5, -0.5, 0.5); // Bottom Right
    Result.vertices[7] := TVec3.Create(0.5, -0.5, 0.5); // Bottom Right
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

    // Face Back
    // Vertices
    Result.vertices[8] := TVec3.Create(0.5, -0.5, -0.5); // Bottom Right
    Result.vertices[9] := TVec3.Create(0.0, 0.5, 0.0); // Top
    Result.vertices[10] := TVec3.Create(-0.5, -0.5, -0.5); // Bottom Left
    Result.vertices[11] := TVec3.Create(-0.5, -0.5, -0.5); // Bottom Left
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

    // Face Left
    // Vertices
    Result.vertices[12] := TVec3.Create(-0.5, -0.5, -0.5); // Back Left
    Result.vertices[13] := TVec3.Create(0.0, 0.5, 0.0); // Top
    Result.vertices[14] := TVec3.Create(-0.5, -0.5, 0.5); // Front Left
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

    // Face Right
    // Vertices
    Result.vertices[16] := TVec3.Create(0.5, -0.5, 0.5); // Front Right
    Result.vertices[17] := TVec3.Create(0.0, 0.5, 0.0); // Top
    Result.vertices[18] := TVec3.Create(0.5, -0.5, -0.5); // Back Right
    Result.vertices[19] := TVec3.Create(0.5, -0.5, -0.5); // Back Right
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