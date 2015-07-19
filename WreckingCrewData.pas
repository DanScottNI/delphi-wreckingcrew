unit WreckingCrewData;

interface

uses GR32, Classes, WreckingCrew, INIFiles, SysUtils, Graphics, dialogs;

procedure LoadDefaultOptions();
procedure LoadOptions(pOptionsFile : String);
procedure SaveOptions(pOptionsFile : String);
procedure LoadPalettes(pPaletteDataFile:String);
procedure LoadCurrentPalette();

var
  EnableGridlinesDef : Boolean = true;
  GridlinesColour : Byte;
  CurrentPaletteStr : String;
  CurrentPaletteNum : Integer;
  Palettes : TStringList;
  // The gridline colours
  GridlineColours : Array [0..21] of TColor32 = (clBlack32, clDimGray32,
  clGray32,clLightGray32,clWhite32,clMaroon32,clGreen32,clOlive32,clNavy32,
  clPurple32,clTeal32,clRed32,clLime32,clYellow32,clBlue32,clFuchsia32,
  clAqua32,clTrWhite32,clTrBlack32,clTrRed32,clTrGreen32,clTrBlue32);
  LastROMLoaded : String;

implementation

procedure LoadPalettes(pPaletteDataFile:String);
begin

  if Palettes = nil then
    Palettes := TStringList.Create;
  if FileExists(pPaletteDataFile) = false then
  begin
    FreeAndNil(Palettes);
    exit;
  end;
  try
    Palettes.LoadFromFile(pPaletteDataFile);
  except
    FreeAndNil(Palettes);
  end;

end;

procedure LoadCurrentPalette();
var
  i : Integer;
  FileStr : TFileStream;
  Red,Green, Blue : Byte;
begin
  if (Palettes = nil) or (FileExists(CurrentPaletteStr)=false) then
  begin
    frmWreckingCrew.LoadNESPalette;
    exit;
  end;
  
  FileStr := TFileStream.Create(CurrentPaletteStr,fmOpenRead);
  try
    for i := 0 to 63 do
    begin
      Red :=0;
      Green :=0;
      Blue :=0;

      FileStr.Read(Red,1);
      FileStr.Read(Green,1);
      FileStr.Read(Blue,1);
      NESPal[i] := WinColor(StringToColor('$' + IntToHex(Blue,2) + IntToHex(Green,2) + IntToHex(Red,2)));
    end;
  finally
    FreeAndNil(FileStr);
  end;
end;

procedure LoadDefaultOptions();
var
  i : Integer;
begin
  GridLinesColour := 4;
  EnableGridlinesDef := True;
  LastROMLoaded := '';
  CurrentPaletteNum := 0;
  if Palettes = nil then LoadPalettes(ExtractFileDir(ParamStr(0)) + '\Palettes\');

  // Now work out which palette is selected
  CurrentPaletteStr := ExtractFileDir(ParamStr(0)) + '\Palettes\';
  for i := 1 to length(Palettes.Strings[CurrentPaletteNum]) do
  begin
    if Palettes.Strings[CurrentPaletteNum][i] = ':' then break;
    CurrentPaletteStr := CurrentPaletteStr + Palettes.Strings[CurrentPaletteNum][i]
  end;
  CurrentPaletteStr := Trim(CurrentPaletteStr);

  LoadCurrentPalette();
end;

procedure LoadOptions(pOptionsFile : String);
var
  INI : TMemINIFile;
  i : integer;
begin
  // Open the ini file.
  INI := TMemINIFile.Create(pOptionsFile);
  try
    GridLinesColour := INI.ReadInteger('Options','GridlineColour',4);
    EnableGridlinesDef := INI.ReadBool('Options','EnableGridlinesDef',True);
    LastROMLoaded := INI.ReadString('General','LastROMLoaded','');
    CurrentPaletteNum := INI.ReadInteger('Options','Palette',0);
    if Palettes = nil then LoadPalettes(ExtractFileDir(ParamStr(0)) + '\Palettes\');

    // Now work out which palette is selected
    CurrentPaletteStr := ExtractFileDir(ParamStr(0)) + '\Palettes\';
    for i := 1 to length(Palettes.Strings[CurrentPaletteNum]) do
    begin
      if Palettes.Strings[CurrentPaletteNum][i] = ':' then break;
      CurrentPaletteStr := CurrentPaletteStr + Palettes.Strings[CurrentPaletteNum][i]
    end;
    CurrentPaletteStr := Trim(CurrentPaletteStr);

    LoadCurrentPalette();
  finally
    FreeAndNil(INI);
  end;
end;

procedure SaveOptions(pOptionsFile : String);
var
  INI : TMemINIFile;
begin
  // Open the ini file.
  INI := TMemINIFile.Create(pOptionsFile);
  try
    INI.WriteInteger('Options','GridlineColour',GridLinesColour);
    INI.WriteBool('Options','EnableGridlinesDef',EnableGridlinesDef);
    INI.WriteString('General','LastROMLoaded',LastROMLoaded);
    INI.WriteInteger('Options','Palette',CurrentPaletteNum);
    INI.UpdateFile;
  finally
    FreeAndNil(INI);
  end;
end;

end.
