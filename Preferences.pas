unit Preferences;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, WreckingCrewData;

type
  TfrmPreferences = class(TForm)
    lblPalettes: TLabel;
    lstPalettes: TListBox;
    chkEnableGridlinesByDefault: TCheckBox;
    cmdOK: TButton;
    cmdCancel: TButton;
    lblGridlinesColour: TLabel;
    cbGridlineColours: TComboBox;
    lblPaletteDescription: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure lstPalettesClick(Sender: TObject);
    procedure cmdOKClick(Sender: TObject);
    procedure cmdInstallPalClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    PaletteDes : Array Of String;
    procedure PopulatePalettes;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPreferences: TfrmPreferences;

implementation

{$R *.dfm}

procedure TfrmPreferences.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  frmPreferences := nil;
end;

procedure TfrmPreferences.FormCreate(Sender: TObject);
begin
  // First we need to populate the list of palettes
  PopulatePalettes();
end;

procedure TfrmPreferences.PopulatePalettes();
var
  i,x : Integer;
  TempString : String;
begin
  if Palettes = nil then
    Palettes := TStringList.Create;
  try
    // Load the palette definition file into memory.
    Palettes.LoadFromFile(ExtractFileDir(ParamStr(0)) + '\Palettes\pal.dat');
    SetLength(PaletteDes,Palettes.Count);
    // Loop through each palette in the file, and add them to the listbox
    for i := 0 to Palettes.Count -1 do
    begin
      TempString := '';
      for x := 0 to length(Palettes.Strings[i]) do
      begin
        If Palettes.Strings[i][x] = ':' then
        begin
          lstPalettes.Items.Add(Trim(TempString));
          TempString := '';
        end
        else
          TempString := TempString + Palettes.Strings[i][x];
      end;
      PaletteDes[i] := Trim(TempString);
    end;
  except
    FreeAndNil(Palettes);
  end;
end;

procedure TfrmPreferences.lstPalettesClick(Sender: TObject);
begin
  lblPaletteDescription.Caption := 'Palette Description: ' + chr(13) + chr(10) + chr(13) + chr(10) + PaletteDes[lstPalettes.ItemIndex];
end;

procedure TfrmPreferences.cmdOKClick(Sender: TObject);
begin
  GridlinesColour := cbGridlineColours.ItemIndex;
  EnableGridlinesDef := chkEnableGridlinesByDefault.Checked;
  CurrentPaletteStr := ExtractFileDir(ParamStr(0)) + '\Palettes\' + lstPalettes.Items[lstPalettes.ItemIndex];
  CurrentPaletteNum := lstPalettes.ItemIndex;
  LoadCurrentPalette();
  SaveOptions(ExtractFileDir(ParamStr(0))+'\options.ini');

end;

procedure TfrmPreferences.cmdInstallPalClick(Sender: TObject);
begin
  showmessage('I don''t work. But I' +
    ' will allow the updating of the palette data file and copying of the palette file into the palette directory');
end;

procedure TfrmPreferences.FormShow(Sender: TObject);
begin
  cbGridlineColours.ItemIndex := GridlinesColour;
  chkEnableGridlinesByDefault.Checked := EnableGridlinesDef;
  lstpalettes.ItemIndex := CurrentPaletteNum;
  lblPaletteDescription.Caption := 'Palette Description: ' + chr(13) + chr(10) + chr(13) + chr(10) + PaletteDes[lstPalettes.ItemIndex];
end;

end.

