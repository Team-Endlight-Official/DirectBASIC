/// DirectBASIC Runtime Library Types Unit.
/// Version 0.0.1:
/// --> basic Vector2 type

unit rtl_types;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

{Vector 2 Type}
type TVec2 = record
    x, y:   double;

    // Operators
    class operator + (const a, b: TVec2): TVec2;
    class operator - (const a, b: TVec2): TVec2;
    class operator * (const a, b: TVec2): TVec2;
    class operator / (const a, b: TVec2): TVec2;
end;

{Vector 2 Functions}
function createVec2(): TVec2; overload;
function createVec2(const x, y: double): TVec2; overload;
function createVec2(const v: TVec2): TVec2; overload;

{General Vector Functions}
function length(const v: TVec2): double; overload;

implementation

{Vector 2 Type}

{Vector 2 Functions}
function createVec2(): TVec2; overload;
begin
    Result.x := 0.0;
    Result.y := 0.0;
end;

function createVec2(const x, y: double): TVec2; overload;
begin
    Result.x := x;
    Result.y := y;
end;

function createVec2(const v: TVec2): TVec2; overload;
begin
    Result.x := v.x;
    Result.y := v.y;
end;

{Vector 2 Overloads}
class operator TVec2.+(const a, b: TVec2): TVec2;
begin
    Result.x := a.x + b.x;
    Result.y := a.y + b.y;
end;

class operator TVec2.-(const a, b: TVec2): TVec2;
begin
    Result.x := a.x - b.x;
    Result.y := a.y - b.y;
end;

class operator TVec2.*(const a, b: TVec2): TVec2;
begin
    Result.x := a.x * b.x;
    Result.y := a.y * b.y;
end;

class operator TVec2./(const a, b: TVec2): TVec2;
begin
    Result.x := a.x / b.x;
    Result.y := a.y / b.y;
end;

{General Vector Functions}
function length(const v: TVec2): double; overload;
begin
    Result := sqrt(v.x * v.x + v.y * v.y);
end;

end.