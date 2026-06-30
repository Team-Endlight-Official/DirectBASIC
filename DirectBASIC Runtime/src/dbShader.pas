unit dbShader;

{$mode objfpc}{$H+}

interface

uses
    dbCore, dbCore3D, dglOpenGL, sysutils;

type TShaderHandle = cardinal;

type TShaderData = record
    handle:         GLuint;
end;

type PShaderData = ^TShaderData;

// Internal
procedure db_shader_init_internal();

// Void Functions
procedure BeginShader(shader: TShaderHandle);
procedure EndShader();

procedure DeleteShader(shader: TShaderHandle);

// Return Functions
function LoadShader(vert, frag: string): TShaderHandle;

implementation

var
    shaders:        array of PShaderData;

// Internal
procedure db_shader_init_internal();
begin
    SetLength(shaders, 1);
    writeln('GLSL Shader module has been loaded!');
end;

function IS_SHADER_VALID(shader: TShaderHandle): boolean;
begin
    Result := (shader < Length(shaders)) or (shaders[shader] <> nil);
end;

function IS_SHADER_PATH_CORRECT(path, fileExt: string): boolean;
begin
    Result := (FileExists(path)) and (UpCase(ExtractFileExt(path)) = fileExt);
end;

// Void Functions
procedure BeginShader(shader: TShaderHandle);
begin
    if not IS_SHADER_VALID(shader) then
    begin
        writeln('Shader handle is invalid!');
        halt(1);
    end;

    glUseProgram(shaders[shader]^.handle);
end;

procedure EndShader();
begin
    glUseProgram(NULL);
end;

procedure DeleteShader(shader: TShaderHandle);
begin
    if not IS_SHADER_VALID(shader) then
    begin
        writeln('Shader handle is already deleted!');
        exit;
    end;

    glDeleteProgram(shaders[shader]^.handle);
    shaders[shader]^.handle := 0;

    Dispose(shaders[shader]);
    shaders[shader] := nil;

    writeln('Shader has been deleted!');
end;

// Return Functions
function LoadShader(vert, frag: string): TShaderHandle;
var
    id:                         cardinal;
    vertSource, fragSource:     PChar;
    vertHandle, fragHandle:     GLuint;
    shaderHandle:               GLuint;
begin
    if not IS_SHADER_PATH_CORRECT(vert, '.VERT') then
    begin
        writeln('Vertex Shader: ' + vert + ', does not exist or has the incorrect file extension');
        exit;
    end;

    if not IS_SHADER_PATH_CORRECT(frag, '.FRAG') then
    begin
        writeln('Fragment Shader: ' + frag + ', does not exist or has the incorrect file extension');
        exit;
    end;

    vertSource := PChar(ReadFile(vert));
    fragSource := PChar(ReadFile(frag));

    id := Length(shaders);
    SetLength(shaders, id + 1);
    New(shaders[id]);

    // Compile Shader
    vertHandle := glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertHandle, 1, @vertSource, nil);
    glCompileShader(vertHandle);

    fragHandle := glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragHandle, 1, @fragSource, nil);
    glCompileShader(fragHandle);

    // Create Shader Program
    shaderHandle := glCreateProgram();
    glAttachShader(shaderHandle, vertHandle);
    glAttachShader(shaderHandle, fragHandle);
    glLinkProgram(shaderHandle);

    // Delete already linked resources
    glDeleteShader(vertHandle);
    glDeleteShader(fragHandle);

    shaders[id]^.handle := shaderHandle;
    writeln('Shader has been loaded successfully');
    Result := id;
end;

end.