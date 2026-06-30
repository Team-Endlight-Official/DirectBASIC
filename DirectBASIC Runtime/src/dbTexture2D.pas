unit dbTexture2D;

{$mode objfpc}{$H+}

interface // Public

uses
    sysutils, dglOpenGL, dbCore, FPimage, FPReadPNG, FPReadBMP;

type TTexture2DHandle = cardinal;

type TTexture2DData = record
    width:          cardinal;
    height:         cardinal;
    handle:         GLuint;
    path:           string;
end;

// Internal
procedure db_texture2d_init_internal();


// Void Functions
procedure BeginTexture2D(texture: TTexture2DHandle);
procedure EndTexture2D();
procedure DeleteTexture2D(texture: TTexture2DHandle);

// Return Functions
function LoadTexture2D(path: string): TTexture2DHandle;

implementation

type PTexture2DData = ^TTexture2DData;

var
    textures:       array of PTexture2DData;

// Internal
procedure db_texture2d_init_internal();
begin
    SetLength(textures, 1);
    writeln('Texture 2D module has been loaded!');
end;

function IS_TEXTURE_2D_VALID(texture: TTexture2DHandle): boolean; // Internal check! might become user accessible!
begin
    Result := (texture < Length(textures)) or (textures[texture] <> nil);
end;

// Void Functions
procedure BeginTexture2D(texture: TTexture2DHandle);
begin
    if not IS_TEXTURE_2D_VALID(texture) then
    begin
        writeln('Texture2D handle is invalid!');
        exit;
    end;

    glBindTexture(GL_TEXTURE_2D, textures[texture]^.handle);
end;

procedure EndTexture2D();
begin
    glBindTexture(GL_TEXTURE_2D, 0);
end;

procedure DeleteTexture2D(texture: TTexture2DHandle);
var
    path:           string;
begin
    if texture = NULL then
    begin
        writeln('Texture is already deleted!');
        exit;
    end;

    path := textures[texture]^.path;

    glDeleteTextures(1, @textures[texture]^.handle);

    textures[texture]^.width := 0;
    textures[texture]^.height := 0;
    textures[texture]^.handle := 0;
    textures[texture]^.path := '';

    Dispose(textures[texture]);
    textures[texture] := nil;

    writeln('Texture 2D: ' + path + ' has been deleted!');
end;

// Return Functions
function LoadTexture2D(path: string): TTexture2DHandle;
var
    id:             cardinal;
    handle:         GLuint;

    img:            TFPMemoryImage;
    reader:         TFPCustomImageReader;
    x, y:           integer;
    pixelData:      array of byte;
    color:          TFPColor;
    i:              integer;

begin
    // Try to load image
    if UpCase(ExtractFileExt(path)) = '.PNG' then
        reader := TFPReaderPNG.Create
    else
        reader := TFPReaderBMP.Create;

    id := Length(textures);
    SetLength(textures, id + 1);

    New(textures[id]);

    img := TFPMemoryImage.Create(0, 0);
    img.LoadFromFile(path, reader);
    reader.Free;

    SetLength(pixelData, img.Width * img.Height * 4);
    i := 0;

    for y := img.Height - 1 downto 0 do
    begin
        for x := 0 to img.Width - 1 do
        begin
            color := img.Colors[x, y];
            pixelData[i]        := Color.red div 256;
            pixelData[i + 1]    := Color.green div 256;
            pixelData[i + 2]    := Color.blue div 256;
            pixelData[i + 3]    := Color.alpha div 256;
            Inc(i, 4);
        end;
    end;

    glGenTextures(1, @handle);
    glBindTexture(GL_TEXTURE_2D, handle);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, IMG.Width, IMG.Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, @PIXELDATA[0]);

    glGenerateMipmap(GL_TEXTURE_2D);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);    

    textures[id]^.width  :=       img.Width;
    textures[id]^.height :=       img.Height;
    textures[id]^.handle :=       handle;
    textures[id]^.path :=         path;
    img.Free;
    glBindTexture(GL_TEXTURE_2D, NULL);

    writeln('Texture 2D: ' + path + ' has been loaded successfully!');
    Result := id;
end;

end.