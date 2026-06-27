unit dbCore;

{$mode objfpc}{$H+}

interface // Public

uses
    sysutils;

const
    NULL = 0;
    PI = 3.14159;

// Math Functions
function DegToRad(deg: single): single;
function RadToDeg(rad: single): single;
function Clamp(value, min, max: single): single;
procedure Clamp(var value: single; min, max: single);

implementation

function DegToRad(deg: single): single;
begin
    Result := deg * PI / 180.0;
end;

function RadToDeg(rad: single): single;
begin
    Result := rad * 180.0 / PI;
end;

function Clamp(value, min, max: single): single;
begin
    if value < min then
        value := min
    else if value > max then
        value := max;
    Result := value;
end;

procedure Clamp(var value: single; min, max: single);
begin
    if value < min then
        value := min
    else if value > max then
        value := max;
end;

end.