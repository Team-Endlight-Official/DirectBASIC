program main;

{$mode objfpc}{$H+}

uses
    rtl_types,
    rtl_utils;

var
    v1, v2, v3: TVec2;
begin
    v1 := createVec2(4, 5);
    v2 := createVec2(2.3, 1.5);
    v3 := v1 / v2;

    writeln('Hello, Again!');
    writeln('This number is a string: ', toString(3.14));
    writeln('Vector2 to string: ', toString(v1));
    writeln('Vector2 operator overloading (v1 + v2): ', toString(v3));
    writeln('Vector2 length: ', toString(length(v1)));
    writeln('Size of Vector2: ', toString(sizeOf(v1)));
    readln;
end.