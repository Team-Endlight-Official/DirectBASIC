program test;

{$mode objfpc}{$H+}

uses
    sysutils,
    test_iniReader;

procedure executeProgram(const selection: string);
var
    selcInt:    integer;
begin
    selcInt := strToInt(selection);

    case selcInt of
    0: test_iniReader.runTest();
    else
        writeln('Invalid program selection! Aborting!');
        halt(1);
    end;
end;

var
    selection: string;
begin
    writeln('This is a testing program starter.');
    writeln('0: Ini File Reader');
    writeln('2: Calculator');
    write('Please select a testing program: ');
    read(selection);

    writeln('You selected program: ', selection);
    executeProgram(selection);

    readln;
    readln;
end.