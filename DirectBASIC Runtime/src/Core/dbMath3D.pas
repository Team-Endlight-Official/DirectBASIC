unit dbMath3D;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
    sysutils;

// Vector 3
type TVec3 = record
    x, y, z:        single;

    class function Create(nx, ny, nz: single): TVec3; static;

    class operator +(a, b: TVec3): TVec3;
    class operator -(a, b: TVec3): TVec3;
    class operator *(a, b: TVec3): TVec3;
    class operator /(a, b: TVec3): TVec3;
    class operator =(a, b: TVec3): boolean;
end;

// Vector 2
type TVec2 = record
    x, y:           single;

    class function Create(nx, ny: single): TVec2; static;

    class operator +(a, b: TVec2): TVec2;
    class operator -(a, b: TVec2): TVec2;
    class operator *(a, b: TVec2): TVec2;
    class operator /(a, b: TVec2): TVec2;
    class operator =(a, b: TVec2): boolean;
end;

const
    Vec3Zero: TVec3 = (x: 0; y: 0; z: 0);
    Vec3One: TVec3 = (x: 1; y: 1; z: 1);
    Vec2Zero: TVec2 = (x: 0; y: 0);
    Vec2One: TVec2 = (x: 1; y: 1);

implementation

// Vector 3
class function TVec3.Create(nx, ny, nz: single): TVec3;
begin
    Result.x := nx;
    Result.y := ny;
    Result.z := nz;
end;

class operator TVec3.+(a, b: TVec3): TVec3;
begin
    Result.x := a.x + b.x;
    Result.y := a.y + b.y;
    Result.z := a.z + b.z;
end;

class operator TVec3.-(a, b: TVec3): TVec3;
begin
    Result.x := a.x - b.x;
    Result.y := a.y - b.y;
    Result.z := a.z - b.z;
end;

class operator TVec3.*(a, b: TVec3): TVec3;
begin
    Result.x := a.x * b.x;
    Result.y := a.y * b.y;
    Result.z := a.z * b.z;
end;

class operator TVec3./(a, b: TVec3): TVec3;
begin
    Result.x := a.x / b.x;
    Result.y := a.y / b.y;
    Result.z := a.z / b.z;
end;

class operator TVec3.=(a, b: TVec3): boolean;
begin
    Result := (a.x = b.x) and (a.y = b.y) and (a.z = b.z);
end;

// Vector 2
class function TVec2.Create(nx, ny: single): TVec2;
begin
    Result.x := nx;
    Result.y := ny;
end;

class operator TVec2.+(a, b: TVec2): TVec2;
begin
    Result.x := a.x + b.x;
    Result.y := a.y + b.y;
end;

class operator TVec2.-(a, b: TVec2): TVec2;
begin
    Result.x := a.x - b.x;
    Result.y := a.y - b.y;
end;

class operator TVec2.*(a, b: TVec2): TVec2;
begin
    Result.x := a.x * b.x;
    Result.y := a.y * b.y;
end;

class operator TVec2./(a, b: TVec2): TVec2;
begin
    Result.x := a.x / b.x;
    Result.y := a.y / b.y;
end;

class operator TVec2.=(a, b: TVec2): boolean;
begin
    Result := (a.x = b.x) and (a.y = b.y);
end;

end.