program main;

{$mode objfpc}{$H+}

uses
    SysUtils,
    Classes,
    fpg_base,
    fpg_main,
    fpg_form,
    fpg_memo;

type TMainForm = class(TfpgForm)
private
    fMemo:      TfpgMemo;
public
    procedure AfterCreate; override;
end;

procedure TMainForm.AfterCreate;
var
    fixedSize:      TfpgSize;
begin
    inherited AfterCreate;

    WindowTitle := 'DirectBASIC IDE';
    SetPosition(100, 100, 800, 600);

    MinWidth := 800;
    MinHeight := 600;

    MaxWidth := 800;
    MaxHeight := 600;

    // Create memo
    fMemo := TfpgMemo.Create(Self);
    with fMemo do
    begin
        Name := 'Memo1';
        SetPosition(10, 10, 780, 580);
    end;
end;

var
    form:       TMainForm;
begin
    fpgApplication.Initialize;
    form := TMainForm.Create(nil);
    try
        form.Show;
        fpgApplication.Run;
    finally
        form.Free;
        fpgApplication.Destroy;
    end;
end.