unit ImportLevel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, WreckingCrew;

type
  TfrmImportLevel = class(TForm)
    txtFileName: TEdit;
    cmdExport: TButton;
    lblFilename: TLabel;
    cmdBrowse: TButton;
    cbPhase: TComboBox;
    lblPhase: TLabel;
    cmdCancel: TButton;
    OpenDialog: TOpenDialog;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cmdBrowseClick(Sender: TObject);
    procedure cmdExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ImportFile(pFilename: String);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmImportLevel: TfrmImportLevel;

const
  XORKEY : Byte = 63;

implementation

{$R *.dfm}

procedure TfrmImportLevel.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  frmImportLevel := nil;
  Action := caFree;
end;

procedure TfrmImportLevel.cmdBrowseClick(Sender: TObject);
begin
  if opendialog.execute then
  begin
    txtFilename.Text := OpenDialog.FileName;
    txtFilename.SelStart := length(txtFilename.Text);
  end;
end;

procedure TfrmImportLevel.cmdExportClick(Sender: TObject);
begin
  if FileExists(txtFileName.Text) = True then
    ImportFile(txtFileName.Text)
  else
    messagebox(Handle,'The file specified does not exist',PChar(Application.Title),0);
end;

procedure TfrmImportLevel.ImportFile(pFilename : String);
var
  LevelFile : TMemoryStream;
  TempBuf : Byte;
  i,x : Integer;
begin
  LevelFile := TMemoryStream.Create;
  try
    LevelFile.LoadFromFile(pFilename);

    // Now we check that the data file has a valid header.
    // If it does not, then exit the subroutine, freeing
    // the memorystream in the the process.
    LevelFile.Read(TempBuf,1);
    if TempBuf <> $57 then
    begin
      FreeAndNil(LevelFile);
      Exit;
    end;
    LevelFile.Read(TempBuf,1);
    if TempBuf <> $43 then
    begin
      messagebox(Handle,'Demolition has detected that this data file has not got a valid header. Aborting import.',
      PChar(Application.Title),0);
      FreeAndNil(LevelFile);
      Exit;
    end;
    LevelFile.Read(TempBuf,1);
    if TempBuf <> $44 then
    begin
      messagebox(Handle,'Demolition has detected that this data file has not got a valid header. Aborting import.',
      PChar(Application.Title),0);
      FreeAndNil(LevelFile);
      Exit;
    end;
    LevelFile.Read(TempBuf,1);
    if TempBuf <> $41 then
    begin
      messagebox(Handle,'Demolition has detected that this data file has not got a valid header. Aborting import.',
      PChar(Application.Title),0);
      FreeAndNil(LevelFile);
      Exit;
    end;
    LevelFile.Read(TempBuf,1);
    if TempBuf <> $54 then
    begin
      messagebox(Handle,'Demolition has detected that this data file has not got a valid header. Aborting import.',
      PChar(Application.Title),0);
      FreeAndNil(LevelFile);
      Exit;
    end;
    LevelFile.Read(TempBuf,1);
    if TempBuf <> $41 then
    begin
      messagebox(Handle,'Demolition has detected that this data file has not got a valid header. Aborting import.',
      PChar(Application.Title),0);
      FreeAndNil(LevelFile);
      Exit;
    end;
    // Yay, we've passed the header checks. Now decrypt the data
    // so it can be used.

    for i := 6 to LevelFile.Size -1 do
    begin
      TempBuf :=0;
      LevelFile.Seek(i,soFromBeginning);
      LevelFile.Read(TempBuf,1);
      // First to decrypt the data, we need to
      // rotate the bits back.
      // Next we need to xor it.
      //TempBuf := RotateByte(TempBuf xor XORKEY);
      TempBuf := TempBuf xor XORKEY;
      LevelFile.Seek(i,soFromBeginning);
      // Next we rewrite it to the memorystream for easy access.
      LevelFile.Write(TempBuf,1);
    end;

    // We have decrypted the data successfully.
    // Now load it into memory.
    // First seek to the beginning of the file
    // past the header.
    LevelFile.Seek(6,soFromBeginning);

    // Now load the level data
    For I := 0 To 7 do
    begin

      For X := 0 To 5 do
      begin
        TempBuf := 0;
        LevelFile.Read(TempBuf,1);
        ROM[LevelLoc[cbPhase.ItemIndex] + (I * 6) + X] := TempBuf;
      end;

    end;
    if cbPhase.ItemIndex = frmWreckingCrew.CurrentLevel then
    begin
      frmWreckingCrew.LoadLevelData();
      frmWreckingCrew.DrawLevelData();
      frmWreckingCrew.Caption := 'Demolition v1.0 - Phase ' + IntToStr(frmWreckingCrew.CurrentLevel + 1);
    end;
  finally
    FreeAndNil(LevelFile);
  end;

  ModalResult := mrOK;

end;


procedure TfrmImportLevel.FormShow(Sender: TObject);
var
  I : Integer;
begin
  for i := 0 to NumberOfLevels - 1 do
    cbPhase.Items.Add('Phase ' + IntToStr(i+1));
  cbPhase.ItemIndex := 0;
end;

end.
