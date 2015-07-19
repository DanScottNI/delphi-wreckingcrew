unit JumpTo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MdNumEd, WreckingCrew;

type
  TfrmJumpTo = class(TForm)
    lstPhases: TListBox;
    txtPhases: TMdNumEdit;
    cmdJump: TButton;
    cmdCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure txtPhasesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lstPhasesClick(Sender: TObject);
    procedure cmdJumpClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmJumpTo: TfrmJumpTo;

implementation

{$R *.dfm}

procedure TfrmJumpTo.FormShow(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to NumberOfLevels -1 do
    lstPhases.Items.Add('Phase ' + IntToStr(i+1));
end;

procedure TfrmJumpTo.txtPhasesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (txtPhases.Value > NumberOfLevels) then
    txtPhases.Value := numberoflevels;

  if (txtPhases.Value < 1) then
    txtPhases.Value := 1;

  lstPhases.ItemIndex := txtPhases.Value-1;
end;

procedure TfrmJumpTo.lstPhasesClick(Sender: TObject);
begin
  txtPhases.Value := lstPhases.Itemindex +1;
end;

procedure TfrmJumpTo.cmdJumpClick(Sender: TObject);
begin

  frmWreckingCrew.SaveLevelData();
  frmWreckingCrew.CurrentLevel := lstPhases.ItemIndex;
  frmWreckingCrew.LoadLevelData();
  frmWreckingCrew.DrawLevelData();
  frmWreckingCrew.Caption := 'Demolition v1.0 - Phase ' + IntToStr(frmWreckingCrew.CurrentLevel + 1);
end;

procedure TfrmJumpTo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmJumpTo := nil;
  Action := caFree;
end;

end.
