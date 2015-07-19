unit StartLive;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MdNumEd, WreckingCrew;

type
  TfrmLives = class(TForm)
    lblLives: TLabel;
    txtLives: TMdNumEdit;
    cmdOK: TButton;
    cmdCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLives: TfrmLives;

implementation

{$R *.dfm}

procedure TfrmLives.FormShow(Sender: TObject);
begin
  txtLives.Value := ROM[StartingLives];
end;

procedure TfrmLives.cmdOKClick(Sender: TObject);
begin
  ROM[StartingLives] := txtLives.Value;
end;

procedure TfrmLives.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmLives := nil;
  action := caFree;
end;

end.
