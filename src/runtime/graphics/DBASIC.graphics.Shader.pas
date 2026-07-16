unit DBASIC.graphics.Shader;

{$mode objfpc}{$H+}

interface

uses
    dglOpenGL;

// Public
type TShader = record
    handle:         GLuint;

    vertexPath:     string;
    fragmentPath:   string;
end;

// Public
function LoadShader(vpath, fpath: string): TShader;
procedure BeginShader(shader: TShader);
procedure EndShader();
procedure DestroyShader(shader: TShader);
function IsShaderValid(shader: TShader): boolean;

implementation

// Private
uses
    sysutils,
    DBASIC.core.IO;

// Private

// Public
function LoadShader(vpath, fpath: string): TShader;
var
    output:         TShader;
    vCode, fCode:   string;
    vid, fid:       GLuint;

    success:        integer;
    infoLog:        array[0..512] of ansiChar;
begin
    // Check file extensions
    if not IsFileExtension(vpath, '.vert') then
    begin
        writeln('Error: Vertex Shader file has invalid file extension!');
        exit;
    end;

    if not IsFileExtension(fpath, '.frag') then
    begin
        writeln('Error: Fragment Shader file has invalid file extension!');
        exit;
    end;

    // Read shader sources!
    vCode := ReadFile(vpath);
    fCode := ReadFile(fpath);

    // Compile Vertex Shader
    vid := glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vid, 1, @vCode, nil);
    glCompileShader(vid);

    glGetShaderiv(vid, GL_COMPILE_STATUS, @success);
    if success = 0 then
    begin
        glGetShaderInfoLog(vid, 512, nil, @infoLog[0]);
        writeln('Error: Vertex Shader compilation failed: ', string(infoLog));
        glDeleteShader(vid);
        exit;
    end;

    // Compile Fragment Shader
    fid := glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fid, 1, @fCode, nil);
    glCompileShader(fid);

    glGetShaderiv(fid, GL_COMPILE_STATUS, @success);
    if success = 0 then
    begin
        glGetShaderInfoLog(fid, 512, nil, @infoLog[0]);
        writeln('Error: Fragment Shader compilation failed: ', string(infoLog));
        glDeleteShader(fid);
        exit;
    end;

    writeln('Shader has been compiled successfully');

    // Create Shader Program
    output.handle := glCreateProgram();
    glAttachShader(output.handle, vid);
    glAttachShader(output.handle, fid);
    glLinkProgram(output.handle);

    glGetProgramiv(output.handle, GL_LINK_STATUS, @success);
    if success = 0 then
    begin
        glGetProgramInfoLog(output.handle, 512, nil, @infoLog[0]);
        writeln('Error: Shader linking failed: ', string(infoLog));
        glDeleteProgram(output.handle);
        exit;
    end;

    glDeleteShader(vid);
    glDeleteShader(fid);

    writeln('Shader has been loaded successfully!');
    Result := output;
end;


procedure BeginShader(shader: TShader);
begin
    if not IsShaderValid(shader) then
    begin
        writeln('Error: Shader is not valid!');
        exit;
    end;

    glUseProgram(shader.handle);
end;

procedure EndShader();
begin
    glUseProgram(0);
end;

procedure DestroyShader(shader: TShader);
begin
    if not IsShaderValid(shader) then
    begin
        writeln('Warn: Shader is not valid!');
        exit;
    end;

    glDeleteProgram(shader.handle);
    writeln('Shader has been deleted!');
end;

function IsShaderValid(shader: TShader): boolean;
begin
    Result := shader.handle <> 0;
end;

end.