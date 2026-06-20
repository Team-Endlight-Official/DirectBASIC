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

implementation

function DegToRad(deg: single): single;
begin
    Result := deg * PI / 180.0;
end;

function RadToDeg(rad: single): single;
begin
    Result := rad * 180.0 / PI;
end;

end.