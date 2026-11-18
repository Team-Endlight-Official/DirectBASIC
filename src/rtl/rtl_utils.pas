/// DirectBASIC Runtime Library Utils Unit.
/// Version 0.0.1:
/// --> simpler and more unified 'toString' functions.
/// --> toInt, toFloat, toChar functions comming soon!

unit rtl_utils;

{$mode objfpc}{$H+}

interface

uses
    rtl_types;

{PUBLIC API}

// To String functions
function toString(const v: integer): string; overload;
function toString(const v: double): string; overload;
function toString(const v: char): string; overload;
function toString(const v: TVec2): string; overload;

implementation

uses
    sysutils;

{PRIVATE API}

{IMPLEMENTATION}
function toString(const v: integer): string; overload;
begin
    Result := intToStr(v);
end;

function toString(const v: double): string; overload;
begin
    Result := floatToStr(v);
end;

function toString(const v: char): string; overload;
begin
    Result := string(v);
end;

function toString(const v: TVec2): string; overload;
begin
    Result := '(x: ' + floatToStr(v.x) + ', y: ' + floatToStr(v.y) + ')';
end;

end.