unit dbInit;

{$mode objfpc}{$H+}

interface

uses
    dbWindowing, dbUnsafe3D, dbTexture2D, dbShader;

implementation

initialization
    writeln('DirectBASIC Runtime initializing...');
    db_windowing_init_internal;
    db_unsafe3d_init_internal;
    db_texture2d_init_internal;
    db_shader_init_internal;

    writeln('DirectBASIC Runtime has been initialized successfully!');    
end.