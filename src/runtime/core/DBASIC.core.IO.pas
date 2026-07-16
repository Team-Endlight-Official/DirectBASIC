unit DBASIC.core.IO;

{$mode objfpc}{$H+}

interface

uses
    sysutils;

// Public
function DoesFileExist(const filePath: string): boolean;
function IsFileExtension(const filePath, ext: string): boolean;
function ReadFile(const filePath: string): string;

implementation

// Public
function DoesFileExist(const filePath: string): boolean;
begin
    Result := FileExists(filePath);
end;

function IsFileExtension(const filePath, ext: string): boolean;
begin
    Result := LowerCase(ExtractFileExt(filePath)) = LowerCase(ext);
end;

function ReadFile(const filePath: string): string;
var
    inputFile:      TextFile;
    output, line:   string;
begin
    if not DoesFileExist(filePath) then
    begin
        writeln('Error: File does not exist: ', filePath);
        exit;
    end;

    AssignFile(inputFile, filePath);
    Reset(inputFile);

    while not Eof(inputFile) do
    begin
        ReadLn(inputFile, line);
        output := output + line + sLineBreak;
    end;

    CloseFile(inputFile);
    Result := output;
end;

end.