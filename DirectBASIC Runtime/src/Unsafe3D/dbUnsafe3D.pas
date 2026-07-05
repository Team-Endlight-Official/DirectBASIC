unit dbUnsafe3D;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface // Public

uses
    dbCore, dbCore3D, dbMath3D, dbTexture2D, sysutils, dglOpenGL;


// Internal
procedure db_unsafe3d_init_internal();

// Public

implementation



// Internal
procedure db_unsafe3d_init_internal();
begin
    writeln('Unsafe3D module has been loaded!');
end;

// Public


end.