unit ExportLevel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, WreckingCrew;

type
  TfrmExportLevel = class(TForm)
    txtOutputFileName: TEdit;
    cmdExport: TButton;
    lblFilename: TLabel;
    cmdBrowse: TButton;
    cbPhase: TComboBox;
    lblPhase: TLabel;
    SaveDialog: TSaveDialog;
    cmdCancel: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cmdExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cmdBrowseClick(Sender: TObject);
  private
    procedure ExportFile(pFilename: String);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmExportLevel: TfrmExportLevel;


const
  XORKEY : Byte = 63;

implementation

{$R *.dfm}

procedure TfrmExportLevel.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmExportLevel := nil;
  Action := caFree;
end;

procedure TfrmExportLevel.ExportFile(pFilename : String);
var
  LevelFile : TMemoryStream;
  TempBuf : Byte;
  i,x : Integer;
begin
  LevelFile := TMemoryStream.Create;
  try
    // Write the header.
    TempBuf := $57;
    LevelFile.Write(TempBuf,1);
    TempBuf := $43;
    LevelFile.Write(TempBuf,1);
    TempBuf := $44;
    LevelFile.Write(TempBuf,1);
    TempBuf := $41;
    LevelFile.Write(TempBuf,1);
    TempBuf := $54;
    LevelFile.Write(TempBuf,1);
    TempBuf := $41;
    LevelFile.Write(TempBuf,1);

    // Now write the actual level data
    For I := 0 To 7 do
    begin

      For X := 0 To 5 do
      begin
        TempBuf := ROM[LevelLoc[cbPhase.ItemIndex] + (I * 6) + X] xor XORKEY;

        LevelFile.Write(TempBuf,1);
      end;

    end;
    LevelFile.SaveToFile(pFilename);
  finally
    FreeAndNil(LevelFile);
  end;

end;

procedure TfrmExportLevel.cmdExportClick(Sender: TObject);
begin
  ExportFile(txtOutputFilename.text);
  messagebox(Handle,'Demolition has successfully exported the level',
  PChar(Application.Title),0);
end;

procedure TfrmExportLevel.FormShow(Sender: TObject);
var
  I : Integer;
begin
  for i := 0 to NumberOfLevels - 1 do
    cbPhase.Items.Add('Phase ' + IntToStr(i+1));
  cbPhase.ItemIndex := 0;
end;

procedure TfrmExportLevel.cmdBrowseClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    txtOutputFilename.Text := SaveDialog.Filename;
    txtOutputFilename.SelStart := length(txtOutputFilename.Text);
  end;
end;

end.
