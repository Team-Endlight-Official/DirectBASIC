unit DBASIC.graphics.Graphics;

{$mode objfpc}{$H+}

interface

// Public
procedure SetClearColor(r, g, b, a: single);
procedure SetClearMask(mask: cardinal);
procedure SetViewport(x, y, width, height: cardinal);
procedure Enable(cap: cardinal);
procedure Disable(cap: cardinal);

implementation

// Private
uses
    dglOpenGL;

// Private
procedure __DeductCap__(var cap: cardinal);
begin
    case cap of
    0: cap := GL_DEPTH_TEST;
    1: cap := GL_BLEND;
    2: cap := GL_CULL_FACE;
    3: cap := GL_SCISSOR_TEST;
    4: cap := GL_STENCIL_TEST;
    else
        writeln('Error: Invalid capability index: ', cap, '. Reverting to DEPTH_TEST.');
        cap := 0;
    end;
end;

// Public
procedure SetClearColor(r, g, b, a: single);
begin
    glClearColor(r, g, b, a);
end;

procedure SetClearMask(mask: cardinal);
begin
    glClear(mask);
end;

procedure SetViewport(x, y, width, height: cardinal);
begin
    glViewport(x, y, width, height);
end;

procedure Enable(cap: cardinal);
begin
    __DeductCap__(cap);
    glEnable(cap);
end;

procedure Disable(cap: cardinal);
begin
    __DeductCap__(cap);
    glDisable(cap);
end;

end.