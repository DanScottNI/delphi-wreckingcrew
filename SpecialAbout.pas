unit SpecialAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvGIF, ExtCtrls;

type
  TfrmSpecialAbout = class(TForm)
    Image1: TImage;
    procedure Image1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSpecialAbout: TfrmSpecialAbout;

implementation

{$R *.dfm}

procedure TfrmSpecialAbout.Image1Click(Sender: TObject);
begin
  frmSpecialAbout.ModalResult := mrok;
end;

procedure TfrmSpecialAbout.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmSpecialAbout := nil;
  action := caFree;
end;

end.
