unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, GR32_Image;

type
  TfrmAbout = class(TForm)
    lblTitle: TLabel;
    cmdOK: TButton;
    lblDescription: TLabel;
    lblHomepage: TLabel;
    imgMario: TImage32;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}

procedure TfrmAbout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmAbout := nil;
  Action := caFree;
end;

end.
