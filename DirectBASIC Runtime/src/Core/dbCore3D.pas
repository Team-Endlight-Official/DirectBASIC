unit dbCore3D;

{$mode objfpc}{$H+}

interface

uses
    dbCore, dbMath3D, dbTexture2D, sysutils, dglOpenGL;

// Void Functions
procedure Initialize3D();
procedure PrintGLInfo();
function GetMaxTextureSlots(): cardinal;

// Core GL Stuff
procedure SetViewport(x, y, w, h: integer);
procedure SetClearColor(r, g, b, a: single);
procedure SetClearMask(mask: longInt);

procedure EnableFog();
procedure DisableFog();

procedure EnableCullFace();
procedure SetCullFace(face: cardinal);
procedure DisableCullFace();

procedure EnableDepthTest();
procedure SetDepthFunc(func: cardinal);
procedure DisableDepthTest();

procedure EnableTexture2D();
procedure DisableTexture2D();

procedure EnableLighting();
procedure DisableLighting();

// Debug stuff
procedure EnableWireframe();
procedure DisableWireframe();

implementation

var
    gl_maximumTextureSlots:         GLint;

procedure Initialize3D();
begin
    if not InitOpenGL then
    begin
        writeln('Failed to initialize dglOpenGL!');
        halt(1);
    end;

    ReadExtensions;
    ReadImplementationProperties;

    // Read GL properties
    glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, @gl_maximumTextureSlots);
    writeln('GL Maximum Texture Slots: ' + IntToStr(gl_maximumTextureSlots));
end;

procedure PrintGLInfo();
begin
    writeln('GL Vendor: ' + PChar(glGetString(GL_VENDOR)));
    writeln('GL Renderer: ' + PChar(glGetString(GL_RENDERER)));
    writeln('GL Version: ' + PChar(glGetString(GL_VERSION)));
    writeln('GL GLSL Version: ' + PChar(glGetString(GL_SHADING_LANGUAGE_VERSION)));
end;

function GetMaxTextureSlots(): cardinal;
begin
    Result := gl_maximumTextureSlots;
end;

// Core GL Stuff
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

procedure EnableFog();
begin
    glEnable(GL_FOG);
end;

procedure DisableFog();
begin
    glDisable(GL_FOG);
end;

procedure EnableCullFace();
begin
    glEnable(GL_CULL_FACE);
end;

procedure SetCullFace(face: cardinal);
begin
    case face of
    0: begin
        face := GL_FRONT;
    end;
    1: begin
        face := GL_BACK;
    end;
    else
        writeln('Invalid cull face! Defaulting to GL_FRONT.');
        face := GL_FRONT;
    end;

    glCullFace(face);
end;

procedure DisableCullFace();
begin
    glDisable(GL_CULL_FACE);
end;

procedure EnableDepthTest();
begin
    glEnable(GL_DEPTH_TEST);
end;

procedure SetDepthFunc(func: cardinal);
begin
    case func of
    0: begin
        func := GL_LEQUAL;
    end;
    else
        writeln('Invalid depth func! Defaulting to GL_LEQUAL.');
        func := GL_LEQUAL;
    end;
end;

procedure DisableDepthTest();
begin
    glDisable(GL_DEPTH_TEST);
end;

procedure EnableTexture2D();
begin
    glEnable(GL_TEXTURE_2D);
end;

procedure DisableTexture2D();
begin
    glDisable(GL_TEXTURE_2D);
end;

procedure EnableLighting();
begin
    glEnable(GL_LIGHTING);
end;

procedure DisableLighting();
begin
    glDisable(GL_LIGHTING);
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

end.