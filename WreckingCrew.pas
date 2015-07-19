unit WreckingCrew;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GR32,GR32_Image, StdCtrls, idGlobal, INIFiles, Menus,
  GR32_Layers, ToolWin, ComCtrls, ImgList, ActnList;

type
  TfrmWreckingCrew = class(TForm)
    OpenDialog: TOpenDialog;
    imgLevel: TImage32;
    MainMenu: TMainMenu;
    mnuFile: TMenuItem;
    mnuHelp: TMenuItem;
    mnuOpenROM: TMenuItem;
    mnuSaveROM: TMenuItem;
    mnuCloseROM: TMenuItem;
    N1: TMenuItem;
    mnuPreferences: TMenuItem;
    N2: TMenuItem;
    mnuExit: TMenuItem;
    mnuAbout: TMenuItem;
    imgTiles: TImage32;
    mnuTools: TMenuItem;
    mnuLevelImport: TMenuItem;
    mnuLevelExport: TMenuItem;
    mnuExportSaveState: TMenuItem;
    tlbToolbar: TToolBar;
    ImageList: TImageList;
    tlbOpenROM: TToolButton;
    tlbSaveROM: TToolButton;
    tlbCloseROM: TToolButton;
    tlbSep: TToolButton;
    tlbJumpTo: TToolButton;
    tlbGridlines: TToolButton;
    tlbStartingLives: TToolButton;
    ActionList: TActionList;
    actCreateAbout: TAction;
    actCreateExport: TAction;
    actCreateImport: TAction;
    actCreateJumpTo: TAction;
    actCreatePreferences: TAction;
    actCreateExportSaveState: TAction;
    actCreateStartingLives: TAction;
    actOpenROM: TAction;
    actSaveROM: TAction;
    actCloseROM: TAction;
    procedure imgTilesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure imgLevelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure imgLevelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer; Layer: TCustomLayer);
    procedure imgLevelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mnuExitClick(Sender: TObject);
    procedure tlbGridlinesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actCreateAboutExecute(Sender: TObject);
    procedure actCreateExportExecute(Sender: TObject);
    procedure actCreateImportExecute(Sender: TObject);
    procedure actCreateJumpToExecute(Sender: TObject);
    procedure actCreatePreferencesExecute(Sender: TObject);
    procedure actOpenROMExecute(Sender: TObject);
    procedure actCreateExportSaveStateExecute(Sender: TObject);
    procedure actCreateStartingLivesExecute(Sender: TObject);
    procedure actCloseROMExecute(Sender: TObject);
    procedure actSaveROMExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    Procedure LoadNESROM(pFilename : String);
    Procedure LoadPaletteData();
    Procedure DrawTiles();
    function ByteToBin(OneByte: Byte): String;
    procedure LoadDataFile(pDataFile: String);
    procedure Draw3x1NESTile(pBitmap: TBitmap32; pX, pY, pPal, pOffset,
      pPatternTable: Integer);
    procedure Draw3x2NESTile(pBitmap: TBitmap32; pX, pY, pPal, pOffset,
      pPatternTable: Integer);
    procedure DrawTileSelector;
    procedure DrawNESTile(pBitmap : TBitmap32; pX, pY : Integer; pPal : Integer; pOffset : Integer; pPatternTable : Integer; pLadderBelow : Boolean = false; pLadderByte1: Byte = 1; pLadderByte2 : Byte = 1; pUseWholeTSALadderBelow : Boolean = false);
    procedure SaveNESROM(pFilename: String);
  public
    { Public declarations }
  CurrentLevel : Integer;    
    Procedure LoadNESPalette();
    Procedure DrawLevelData();
    Procedure LoadLevelData();
    Procedure SaveLevelData();
  end;

// The TSA data structure
type TTSAData = record
  TSAData : Array [0..3, 0..1] of Byte;
end;

type TTSADataLocStr = record
  Normal : Integer;
  CharacterOverlay : Integer;
  CharacterPal : Byte;
  LadderBelow : Integer;
  LadderAboveBelow : Integer;
  UseWholeTSABelow : Boolean;
  LadderBelowByte1, LadderBelowByte2 : Byte;
  LadderAbove : Integer;
  Palette : Byte;
end;

var
  frmWreckingCrew: TfrmWreckingCrew;
  CurrentTile : Integer;
  SpritePatternTable,PatternTable : Integer;
  PaletteData : Array [0..7, 0..3] of Byte;
  NESPal : Array [0 .. 63] Of TColor32;
  ROM : Array Of Byte;
  Tiles : TBitmap32;
  PaletteStart : Integer;
  LevelLoc : Array [0 ..99] of Integer;
  StartingLives : Integer;
  LevelData : Array [0 .. 7, 0..11] of Byte;
  TSADataLoc : Array [0..15] Of TTSADataLocStr;
  Filename : String;
  NumberOfLevels : Integer;
  EnableGridlines : Boolean;

implementation

uses StartLive, Preferences, JumpTo, ExportLevel, About, ImportLevel,
  SaveStateImport, WreckingCrewData;

{$R *.dfm}

{ TfrmWreckingCrew }

procedure TfrmWreckingCrew.DrawLevelData;
var
  LevelDataBMP : Tbitmap32;
  i, x : Integer;
begin
  LevelDataBMP := TBitmap32.Create;
  try
    LevelDataBMP.Width := 192;
    LevelDataBMP.Height := 256;
    // Just draw all the first row blocks
    for i := 0 to 7 do
      for x :=0 to 11 do
        LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(LevelData[i,x] * 16,0,16,32),Tiles);

    // Work out what graphics to use for the ladders.
    for i :=0 to 7 do
    begin
      for x := 0 to 11 do
      begin

        if i < 7 then
        begin
          if LevelData[i,x] = 5 then
          begin
            if i > 0 then
            begin
              // If the above and below tiles are breakable ladders, then
              // draw the complete ladder
              if (LevelData[i-1,x] = 5) and (LevelData[i+1,x] = 5) then
                LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(32,64,16,32),Tiles)
              else if (LevelData[i-1,x] = 5) and (LevelData[i+1,x] <> 5) then
              begin
                // If the above tile is a breakable ladder, but the below tile
                // is an unbreakable ladder, then draw a tile which has a breakable
                // ladder continuation, but a ladder adaptor thing.
                if (LevelData[i+1,x] = 1) then
                  LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(16,64,16,32),Tiles)
                else if (LevelData[i+1,x] <> 1) and (LevelData[i-1,x] = 5) then
                  // If the above tile is a breakable ladder, but the below
                  // tile isn't, draw a breakable ladder which continues
                  // at the top, but has a platform at the bottom.
                  LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(0,64,16,32),Tiles);

              end
              // If the below tile isn't a breakable ladder, but a normal ladder
              // then draw a tile which has a breakable
              // ladder continuation, but a ladder adaptor thing.
              else if (LevelData[i+1,x] = 1) and (LevelData[i-1,x] <> 5) then
                LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(LevelData[i,x]*16,32,16,32),Tiles)
              // If the below tile isn't a breakable ladder, and the
              // above tile isn't either, then draw a breakable ladder
              // with a normal platform underneath and no continuation.
              else if (LevelData[i-1,x] <> 5) and (LevelData[i+1,x] <> 5) then
                LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(LevelData[i,x] * 16,0,16,32),Tiles)
              // If the above tile isn't a breakable ladder, but the below
              // tile is, then draw a breakable ladder with no continuation at
              // the top, and a continuation at the bottom
              else if (LevelData[i-1,x] <> 5) and (LevelData[i+1,x] = 5) then
                LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(48,64,16,32),Tiles);
            end
            else
            begin
              // We are on the top row
              if i = 0 then
              begin
                // If the below block is a breakable block then draw
                // a breakable ladder with a continuation at the bottom and
                // a normal top.
                if (LevelData[i+1,x] =5) then
                  LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(48,64,16,32),Tiles)
                // If the below block is a ladder then draw a normal top
                // with a ladder at the bottom.
                else if (LevelData[i+1,x] =1) then
                  LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(LevelData[i,x]*16,32,16,32),Tiles);

              end;
            end
          end
          else if (LevelData[i,x] = 1) then
          begin
            if i > 0 then
            begin
              // If the above and below tiles are ladders, then
              // draw the complete ladder
              if (LevelData[i-1,x] = 1) and (LevelData[i+1,x] = 1) then
                LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(0,96,16,32),Tiles)
              else if (LevelData[i-1,x] = 1) and (LevelData[i+1,x] <> 1) then
              begin
                // If the above tile is a ladder, but the below tile
                // is an breakable ladder, then draw a tile which has a
                // ladder continuation, but a ladder adaptor thing.
                if (LevelData[i+1,x] = 5) then
                  LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(LevelData[i,x]*16,32,16,32),Tiles);
              end
              // If the above tile isn't a ladder, but the below
              // tile is, then draw a ladder with no continuation at
              // the top, and a continuation at the bottom
              else if (LevelData[i-1,x] <> 1) and (LevelData[i+1,x] = 1) then
                LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(0,96,16,32),Tiles)
              // If the above tile isn't a ladder, but the below tile is a
              // breakable ladder then draw a ladder with a ladder adaptor
              // at the bottom.
              else if (LevelData[i-1,x] <> 1) and (LevelData[i+1,x] = 5) then
                LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(LevelData[i,x]*16,32,16,32),Tiles)
            end;
            if i = 0 then
            begin

              // If the below block is a ladder then draw
              // a ladder with a continuation at the bottom and
              // a normal top.
              if (LevelData[i+1,x] =1) then
                LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(0,96,16,32),Tiles)
              // If the below block is a ladder then draw a normal top
              // with a ladder at the bottom.
              else if (LevelData[i+1,x] =1) then
                LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(LevelData[i,x]*16,32,16,32),Tiles)
              // the below tile is a
              // breakable ladder then draw a ladder with a ladder adaptor
              // at the bottom.
              else if (LevelData[i+1,x] = 5) then
                LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(LevelData[i,x]*16,32,16,32),Tiles);
            end;
          end
          else
            if (LevelData[i+1,x] = 5) or (LevelData[i+1,x] = 1) then
              LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(LevelData[i,x]*16,32,16,32),Tiles);
        end
        else
        begin
          // Check which type of ladder it is.
          if (LevelData[i,x] = 1) then
          begin
            LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(LevelData[i,x]*16,0,16,32),Tiles);
          end
          else if (LevelData[i,x] = 5) then
          begin
            // If the block above is a breakable ladder, and the current
            // block is a breakable ladder, draw a breakable ladder
            // with a continuation at the top.
            if LevelData[i-1,x] = 5 then
              LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(0,64,16,32),Tiles)
            // If the block is any other block then draw a block with
            // a normal top and normal bottom.
            else
              LevelDataBMP.Draw(bounds(x*16,i*32,16,32),bounds(LevelData[i,x]*16,0,16,32),Tiles);
          end;


        end;
      end;
    end;

    // Now draw the gridlines.
    if EnableGridlines = true then
    begin
      for i := 1 to 7 do
      begin
        for x :=1 to 11 do
        begin
          LevelDataBMP.Line(x*16,0,x*16,256, GridlineColours[GridlinesColour]);
          LevelDataBMP.Line(0,i*32,LevelDataBMP.Width,i*32, GridlineColours[GridlinesColour]);
        end;
      end;
    end;
    imgLevel.Bitmap := LevelDataBMP;
  finally

    FreeAndNil(LevelDataBMP);
  end;
end;

procedure TfrmWreckingCrew.DrawTileSelector();
var
  TilesBMP : Tbitmap32;
  i, x, TempX, TempY : Integer;

begin
  TilesBMP := TBitmap32.Create;
  try
    TilesBMP.Width := 32;
    TilesBMP.Height := 256;

    for i := 0 to 7 do
      for x := 0 to 1 do
        TilesBMP.Draw(bounds(x*16,i*32,16,32),bounds((i*2+x) * 16,0,16,32),Tiles);

    // Work out the current X, Y of the currently selected tile
    TempX := (CurrentTile mod 2) * 16;
    TempY := (CurrentTile div 2) * 32;
    TilesBMP.FrameRectS(TempX,TempY,TempX+16, TempY+32,clRed32);
    imgTiles.Bitmap := TilesBMP;
  finally
    FreeAndNil(TilesBMP);
  end;
end;

procedure TfrmWreckingCrew.DrawTiles;
var
  i : Integer;
begin
  if Tiles = nil then
    Tiles := TBitmap32.Create;
  try
    Tiles.Width := 256;
    Tiles.Height := 128;

    for i := 0 to 15 do
    begin
      DrawNESTile(Tiles,i*16,0,TSADataLoc[i].Palette,TSADataLoc[i].Normal,PatternTable,False);
      DrawNESTile(Tiles,i*16,32,TSADataLoc[i].Palette,TSADataLoc[i].Normal,PatternTable, true, TSADataLoc[i].LadderBelowByte1, TSADataLoc[i].LadderBelowByte2);
    end;
    // Now draw the breakable ladders types
    DrawNESTile(Tiles,0,64,TSADataLoc[5].Palette,TSADataLoc[5].LadderAbove,PatternTable);
    DrawNESTile(Tiles,16,64,TSADataLoc[5].Palette,TSADataLoc[5].LadderAbove,PatternTable, true, TSADataLoc[5].LadderBelowByte1, TSADataLoc[5].LadderBelowByte2);
    DrawNESTile(Tiles,32,64,TSADataLoc[5].Palette,TSADataLoc[5].LadderAboveBelow,PatternTable);
    DrawNESTile(Tiles,48,64,TSADataLoc[5].Palette,TSADataLoc[5].LadderBelow,PatternTable, true, TSADataLoc[5].LadderBelowByte1, TSADataLoc[5].LadderBelowByte2,TSADataLoc[5].UseWholeTSABelow);
    // Now draw the ladder type
    DrawNESTile(Tiles,0,96,TSADataLoc[1].Palette,TSADataLoc[1].LadderAboveBelow, PatternTable);
    // Now draw the enemy overlays
    for i := 11 to 13 do
    begin
      Draw3x1NESTile(Tiles,i*16+4,0,TSADataLoc[i].CharacterPal,TSADataLoc[i].CharacterOverlay,SpritePatternTable);
      Draw3x1NESTile(Tiles,i*16+4,32,TSADataLoc[i].CharacterPal,TSADataLoc[i].CharacterOverlay,SpritePatternTable);

    end;

    // Now draw the enemy overlays
    for i := 14 to 15 do
    begin
      Draw3x2NESTile(Tiles,i*16,0,TSADataLoc[i].CharacterPal,TSADataLoc[i].CharacterOverlay,SpritePatternTable);
      Draw3x2NESTile(Tiles,i*16,32,TSADataLoc[i].CharacterPal,TSADataLoc[i].CharacterOverlay,SpritePatternTable);
    end;
  except
    FreeAndNil(Tiles);
  end;

end;

// This function draws 2BPP tiles to a Bitmap32
// very speedily. Hopefully!
procedure TfrmWreckingCrew.DrawNESTile(pBitmap : TBitmap32;
  pX, pY : Integer; pPal : Integer; pOffset : Integer;
    pPatternTable : Integer; pLadderBelow : Boolean = false;
      pLadderByte1: Byte = 1; pLadderByte2 : Byte = 1;
        pUseWholeTSALadderBelow : Boolean = false);
var
  PixelArr : Array [0..15] of Byte;
  i,Height, Width, x,y : Integer;
  curBit, curBit2 : Char;
  TempBin : String;
  LadderByteTempArr : Array [0..1] of byte;
begin
  for Height := 0 to 3 do
  begin
    for width := 0 to 1 do
    begin
      // Load in the pixel array
      for i := 0 to 15 do
        PixelArr[i] := ROM[(ROM[pOffset + ((Height * 2) + Width)]*16) + pPatternTable + i];

      for y := 0 to 7 do
      begin
        for x := 0  to 7 do
        begin
          TempBin := ByteToBin(PixelArr[y]);
          CurBit := TempBin[x + 1];
          TempBin := ByteToBin(PixelArr[y + 8]);
          CurBit2 := TempBin[x + 1];

          TempBin := CurBit + CurBit2;

          if TempBin = '00' Then
            pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,0]]
          else if TempBin = '10' Then
            pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,1]]
          else if TempBin = '01' Then
            pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,2]]
          else if TempBin = '11' Then
            pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,3]];
        end;
      end;
    end;
  end;

  // Now if the ladder below variable is set,
  if pLadderBelow = true and (pUseWholeTSALadderBelow= false) then
  begin
    LadderByteTempArr[0] := pLadderByte1;
    LadderByteTempArr[1] := pLadderByte2;
    for Height := 3 to 3 do
    begin
      for width := 0 to 1 do
      begin
        // Load in the pixel array
        for i := 0 to 15 do
          PixelArr[i] := ROM[(LadderByteTempArr[width]*16) + pPatternTable + i];

        for y := 0 to 7 do
        begin
          for x := 0  to 7 do
          begin
            TempBin := ByteToBin(PixelArr[y]);
            CurBit := TempBin[x + 1];
            TempBin := ByteToBin(PixelArr[y + 8]);
            CurBit2 := TempBin[x + 1];

            TempBin := CurBit + CurBit2;

            if TempBin = '00' Then
              pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,0]]
            else if TempBin = '10' Then
              pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,1]]
            else if TempBin = '01' Then
              pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,2]]
            else if TempBin = '11' Then
              pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,3]];
          end;
        end;
      end;
    end;
  end;

end;

// This function draws 2BPP tiles to a Bitmap32
// very speedily. Hopefully!
procedure TfrmWreckingCrew.Draw3x1NESTile(pBitmap : TBitmap32; pX, pY : Integer; pPal : Integer; pOffset : Integer; pPatternTable : Integer);
var
  PixelArr : Array [0..15] of Byte;
  i,Height, Width, x,y : Integer;
  curBit, curBit2 : Char;
  TempBin : String;
begin
  for Height := 0 to 2 do
  begin
    for width := 0 to 0 do
    begin
      // Load in the pixel array
      for i := 0 to 15 do
        PixelArr[i] := ROM[(ROM[pOffset + ((Height) + Width)]*16) + pPatternTable + i];

      for y := 0 to 7 do
      begin
        for x := 0  to 7 do
        begin
          TempBin := ByteToBin(PixelArr[y]);
          CurBit := TempBin[x + 1];
          TempBin := ByteToBin(PixelArr[y + 8]);
          CurBit2 := TempBin[x + 1];

          TempBin := CurBit + CurBit2;

          if TempBin = '00' Then
          begin
            if PaletteData[pPal,0] <> 15 then
            begin
              pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,0]];
            end
          end
          else if TempBin = '10' Then
          begin
            if PaletteData[pPal,1] <> 15 then
            begin
              pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,1]];
            end
          end
          else if TempBin = '01' Then
          begin
            if PaletteData[pPal,2] <> 15 then
            begin
              pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,2]];
            end
          end
          else if TempBin = '11' Then
          begin
            if PaletteData[pPal,3] <> 15 then
            begin
              pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,3]];
            end;
          end;
        end;
      end;
    end;
  end;
end;

// This function draws 2BPP tiles to a Bitmap32
// very speedily. Hopefully!
procedure TfrmWreckingCrew.Draw3x2NESTile(pBitmap : TBitmap32; pX, pY : Integer; pPal : Integer; pOffset : Integer; pPatternTable : Integer);
var
  PixelArr : Array [0..15] of Byte;
  i,Height, Width, x,y : Integer;
  curBit, curBit2 : Char;
  TempBin : String;
begin
  for Height := 0 to 2 do
  begin
    for width := 0 to 1 do
    begin
      // Load in the pixel array
      for i := 0 to 15 do
        PixelArr[i] := ROM[(ROM[pOffset + ((Height*2) + Width)]*16) + pPatternTable + i];

      for y := 0 to 7 do
      begin
        for x := 0  to 7 do
        begin
          TempBin := ByteToBin(PixelArr[y]);
          CurBit := TempBin[x + 1];
          TempBin := ByteToBin(PixelArr[y + 8]);
          CurBit2 := TempBin[x + 1];

          TempBin := CurBit + CurBit2;

          if TempBin = '00' Then
          begin
            if PaletteData[pPal,0] <> 15 then
            begin
              pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,0]];
            end
          end
          else if TempBin = '10' Then
          begin
            if PaletteData[pPal,1] <> 15 then
            begin
              pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,1]];
            end
          end
          else if TempBin = '01' Then
          begin
            if PaletteData[pPal,2] <> 15 then
            begin
              pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,2]];
            end
          end
          else if TempBin = '11' Then
          begin
            if PaletteData[pPal,3] <> 15 then
            begin
              pBitmap.Pixel[pX + x + (Width * 8),pY + y + (Height * 8)] := NESPal[PaletteData[pPal,3]];
            end;
          end;
        end;
      end;
    end;
  end;
end;


Function TfrmWreckingCrew.ByteToBin(OneByte : Byte) : String;
var
BinaryString : String;
begin

  BinaryString := IntToBin(OneByte);

  ByteToBin := copy(BinaryString,25, 8);

end;



procedure TfrmWreckingCrew.LoadNESPalette;
begin
  NESPal[0] := WinColor(StringToColor('$808080'));
  NESPal[1] := WinColor(StringToColor('$A63D00'));
  NESPal[2] := WinColor(StringToColor('$B01200'));
  NESPal[3] := WinColor(StringToColor('$960044'));
  NESPal[4] := WinColor(StringToColor('$5E00A1'));
  NESPal[5] := WinColor(StringToColor('$2800C7'));
  NESPal[6] := WinColor(StringToColor('$0006BA'));
  NESPal[7] := WinColor(StringToColor('$00178C'));
  NESPal[8] := WinColor(StringToColor('$002F5C'));
  NESPal[9] := WinColor(StringToColor('$004510'));
  NESPal[10] := WinColor(StringToColor('$004A05'));
  NESPal[11] := WinColor(StringToColor('$2E4700'));
  NESPal[12] := WinColor(StringToColor('$664100'));
  NESPal[13] := WinColor(StringToColor('$000000'));
  NESPal[14] := WinColor(StringToColor('$050505'));
  NESPal[15] := WinColor(StringToColor('$050505'));
  NESPal[16] := WinColor(StringToColor('$C7C7C7'));
  NESPal[17] := WinColor(StringToColor('$FF7700'));
  NESPal[18] := WinColor(StringToColor('$FF5521'));
  NESPal[19] := WinColor(StringToColor('$FA3782'));
  NESPal[20] := WinColor(StringToColor('$B52FEB'));
  NESPal[21] := WinColor(StringToColor('$5029FF'));
  NESPal[22] := WinColor(StringToColor('$0022FF'));
  NESPal[23] := WinColor(StringToColor('$0032D6'));
  NESPal[24] := WinColor(StringToColor('$0062C4'));
  NESPal[25] := WinColor(StringToColor('$008035'));
  NESPal[26] := WinColor(StringToColor('$008F05'));
  NESPal[27] := WinColor(StringToColor('$558A00'));
  NESPal[28] := WinColor(StringToColor('$CC9900'));
  NESPal[29] := WinColor(StringToColor('$212121'));
  NESPal[30] := WinColor(StringToColor('$090909'));
  NESPal[31] := WinColor(StringToColor('$090909'));
  NESPal[32] := WinColor(StringToColor('$FFFFFF'));
  NESPal[33] := WinColor(StringToColor('$FFD70F'));
  NESPal[34] := WinColor(StringToColor('$FFA269'));
  NESPal[35] := WinColor(StringToColor('$FF80D4'));
  NESPal[36] := WinColor(StringToColor('$F345FF'));
  NESPal[37] := WinColor(StringToColor('$8B61FF'));
  NESPal[38] := WinColor(StringToColor('$3388FF'));
  NESPal[39] := WinColor(StringToColor('$129CFF'));
  NESPal[40] := WinColor(StringToColor('$20BCFA'));
  NESPal[41] := WinColor(StringToColor('$0EE39F'));
  NESPal[42] := WinColor(StringToColor('$35F02B'));
  NESPal[43] := WinColor(StringToColor('$A4F00C'));
  NESPal[44] := WinColor(StringToColor('$FFFB05'));
  NESPal[45] := WinColor(StringToColor('$5E5E5E'));
  NESPal[46] := WinColor(StringToColor('$0D0D0D'));
  NESPal[47] := WinColor(StringToColor('$0D0D0D'));
  NESPal[48] := WinColor(StringToColor('$FFFFFF'));
  NESPal[49] := WinColor(StringToColor('$FFFCA6'));
  NESPal[50] := WinColor(StringToColor('$FFECB3'));
  NESPal[51] := WinColor(StringToColor('$EBABDA'));
  NESPal[52] := WinColor(StringToColor('$F9A8FF'));
  NESPal[53] := WinColor(StringToColor('$B3ABFF'));
  NESPal[54] := WinColor(StringToColor('$B0D2FF'));
  NESPal[55] := WinColor(StringToColor('$A6EFFF'));
  NESPal[56] := WinColor(StringToColor('$9CF7FF'));
  NESPal[57] := WinColor(StringToColor('$95E8D7'));
  NESPal[58] := WinColor(StringToColor('$AFEDA6'));
  NESPal[59] := WinColor(StringToColor('$DAF2A2'));
  NESPal[60] := WinColor(StringToColor('$FCFF99'));
  NESPal[61] := WinColor(StringToColor('$DDDDDD'));
  NESPal[62] := WinColor(StringToColor('$111111'));
  NESPal[63] := WinColor(StringToColor('$111111'));

end;

procedure TfrmWreckingCrew.LoadPaletteData;
var
  i,x : Integer;
begin
  for i := 0 to 7 do
    for x := 0 to 3 do
      PaletteData[i,x]:=ROM[PALETTESTART + (i*4) + x];
end;

procedure TfrmWreckingCrew.SaveLevelData;
var
  i,x : Integer;
begin
  for i := 0 to 7 do
  begin
    for x := 0 to 5 do
    begin
      ROM[LevelLoc[CurrentLevel] + i*6 + x] := StrToInt('$' + IntToHex(LevelData[i,x*2],1) + IntToHex(LevelData[i,x*2+1],1));
    end;
  end;
end;

procedure TfrmWreckingCrew.LoadLevelData;
var
  i,x : Integer;
begin
  for i := 0 to 7 do
  begin
    for x := 0 to 5 do
    begin
      LevelData[i,x*2] := StrToInt('$' + copy(IntToHex(ROM[LevelLoc[CurrentLevel] + i*6 + x],2),1,1));
      LevelData[i,x*2+1] := StrToInt('$' + copy(IntToHex(ROM[LevelLoc[CurrentLevel] + i*6 + x],2),2,1));
    end;
  end;
end;

procedure TfrmWreckingCrew.SaveNESROM(pFilename : String);
var
  Mem : TMemoryStream;
  i : Integer;
begin

  Mem := TMemoryStream.Create;
  try
    Mem.SetSize(high(ROM));

    Mem.Position :=0;

    for i := 0 to mem.Size do
      Mem.Write(ROM[i],1);

    Mem.SaveToFile(pFilename);
  finally
    FreeAndNil(Mem);
  end;

end;


procedure TfrmWreckingCrew.LoadNESROM(pFilename: String);
var
  Mem : TMemoryStream;
  i : Integer;
begin

  Mem := TMemoryStream.Create;
  try
    Mem.LoadFromFile(pFilename);

    Mem.Position :=0;
    setlength(ROM, Mem.Size);
    for i := 0 to mem.Size do
      Mem.Read(ROM[i],1);

  finally
    FreeAndNil(Mem);
  end;

end;

procedure TfrmWreckingCrew.LoadDataFile(pDataFile : String);
var
  ini : TMemINIFile;
  LevelCounter, TSACounter : Integer;
begin
  ini := TMemINIFile.Create(pDataFile);
//  ini := TSECURITYINI.Create(pDataFile,'DEMOLITION','CONTACTLENSES');
  try
    // Load the number of levels into memory
    NumberOfLevels := ini.ReadInteger('General','NumberOfLevels',0);

    // If the number of levels is 0, then don't bother to
    // loop through loading all the level locations into memory
    if NumberOfLevels >0 then
      for LevelCounter := 0 to NumberOfLevels -1 do
        LevelLoc[LevelCounter] := StrToInt('$' + INI.ReadString('Level' + IntToStr(LevelCounter),'Offset','0'));

    // Now load the palette location into memory
    PaletteStart := StrToInt('$' + INI.ReadString('Palette','LevelPalette','0'));
    // Load the pattern table location into memory
    PatternTable := StrToInt('$' + INI.ReadString('PatternTable','PatternTableStart','9010'));
    // Load the sprite pattern table location into memory
    SpritePatternTable := StrToInt('$' + INI.ReadString('PatternTable','SpritePatternTable','8010'));
    // Load the starting lives location into memory
    StartingLives := StrToInt('$' + INI.ReadString('General','StartingLives','8010'));
    // Now load all the TSA data into memory.
    for TSACounter := 0 to 15 do
    begin
      // Load the bog-standard offset
      TSADataLoc[TSACounter].Normal := StrToInt('$' +
        INI.ReadString('Block' + IntToStr(TSACounter), 'Normal','0'));
      // Load the ladder below offset
      TSADataLoc[TSACounter].LadderBelow := StrToInt('$' +
        INI.ReadString('Block' + IntToStr(TSACounter), 'LadderBelow',IntToHex(TSADataLoc[TSACounter].Normal,4)));
      // Load the ladder below byte 1
      TSADataLoc[TSACounter].LadderBelowByte1 := StrToInt('$' +
        INI.ReadString('Block' + IntToStr(TSACounter), 'LadderBelowByte1', '0'));
      // Load the ladder below byte 2
      TSADataLoc[TSACounter].LadderBelowByte2 := StrToInt('$' +
        INI.ReadString('Block' + IntToStr(TSACounter), 'LadderBelowByte2', '0'));
      // Load the whole TSA below
      TSADataLoc[TSACounter].UseWholeTSABelow :=
        INI.ReadBool('Block' + IntToStr(TSACounter), 'UseWholeTSABelow', False);
      // Load the ladder above offset
      TSADataLoc[TSACounter].LadderAboveBelow := StrToInt('$' +
        INI.ReadString('Block' + IntToStr(TSACounter), 'LadderAboveBelow',IntToHex(TSADataLoc[TSACounter].Normal,4)));
      // Load the ladder above offset
      TSADataLoc[TSACounter].LadderAbove := StrToInt('$' +
        INI.ReadString('Block' + IntToStr(TSACounter), 'LadderAbove',IntToHex(TSADataLoc[TSACounter].Normal,4)));
      // Load the palette for the tsa
      TSADataLoc[TSACounter].Palette := StrToInt('$' +
        INI.ReadString('Block' + IntToStr(TSACounter), 'Palette','0'));
      // Load the character overlay data
      TSADataLoc[TSACounter].CharacterOverlay := StrToInt('$' +
        INI.ReadString( 'Block' + IntToStr(TSACounter), 'CharacterOverlay',IntToHex(TSADataLoc[TSACounter].Normal,4)));
      // Load the palette for the character
      TSADataLoc[TSACounter].CharacterPal :=
        INI.ReadInteger('Block' + IntToStr(TSACounter), 'CharacterPal',0);
    end;
  finally
    FreeAndNil(INI);
  end;
end;

procedure TfrmWreckingCrew.imgTilesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  CurrentTile := (X div 32) + ((Y div 64)*2);
  DrawTileSelector();
end;

procedure TfrmWreckingCrew.imgLevelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  if Button = mbRight then
  begin
    CurrentTile := LevelData[ y div 64,x div 32];
    DrawTileSelector();
  end
  else
  begin
    LevelData[ y div 64,x div 32] := CurrentTile;
    DrawLevelData();
  end;
end;

procedure TfrmWreckingCrew.imgLevelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  if (ssLeft in Shift) then
  begin
    LevelData[ y div 64,x div 32] := CurrentTile;
    DrawLevelData();
  end;
end;

procedure TfrmWreckingCrew.imgLevelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  if Button = mbRight then
  begin
    CurrentTile := LevelData[ y div 64,x div 32];
    DrawTileSelector();
  end
  else
  begin
    LevelData[ y div 64,x div 32] := CurrentTile;
    DrawLevelData();
  end;
end;

procedure TfrmWreckingCrew.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // If the level is available, run all the key checks listed
  // below.
  if imgLevel.Visible = True then
  begin
    // Save the level data
    SaveLevelData();
    // If the key pressed is the Page Up key,
    // check if the current Level variable is 23.
    // 23 is the last level, so loop round to the
    // beginning (0). If it is not 23, increment the
    // current level variable by 1.
    if Key = VK_PRIOR	then
    begin
      if CurrentLevel = NumberOfLevels-1 then
        CurrentLevel := 0
      else
        inc(CurrentLevel);
    end
    // If the key pressed is the Page Down key,
    // check if the current Level variable is 0.
    // If it is, then set the current Level variable
    // to 23. If it is not 0, decrement the current
    // level variable by 1.
    else if Key = VK_NEXT	then
    begin
      if CurrentLevel = 0 then
        CurrentLevel := NumberOfLevels-1
      else
        dec(CurrentLevel);
    end
    // If the key pressed is neither Page Up or Page Down
    // exit the subroutine.
    else
      exit;
    // Set the caption of the form to say Demolition v1.0 plus
    // the level name.
    frmWreckingCrew.Caption := 'Demolition v1.0 - Phase ' + IntToStr(CurrentLevel + 1);
    // Reload the level data for new level.
    LoadLevelData();
    // Draw the new level.
    DrawLevelData();
  end;
end;

procedure TfrmWreckingCrew.mnuExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmWreckingCrew.tlbGridlinesClick(Sender: TObject);
begin
  EnableGridlines := not(EnableGridlines);
  tlbGridlines.Down := enablegridlines;
  DrawLevelData();
end;

procedure TfrmWreckingCrew.FormShow(Sender: TObject);
begin
  if FileExists(ExtractFileDir(ParamStr(0)) + '\Palettes\pal.dat') = true then
  begin
    LoadPalettes(ExtractFileDir(ParamStr(0)) + '\Palettes\pal.dat');
  end;
//  showmessage(Palettes.Strings[0]);
  if FileExists(ExtractFileDir(ParamStr(0)) + '\options.ini') = true then
  begin
    LoadOptions(ExtractFileDir(ParamStr(0)) + '\options.ini');
  end
  else
  begin
    LoadDefaultOptions();
    SaveOptions(ExtractFileDir(ParamStr(0)) + '\options.ini');
  end;
  EnableGridlines := EnableGridlinesDef;
  tlbGridlines.Down := enablegridlines;
end;

procedure TfrmWreckingCrew.actCreateAboutExecute(Sender: TObject);
var
  About : TfrmAbout;
begin
  About := TfrmAbout.Create(frmWreckingCrew);
  try
    About.ShowModal;
  finally
    FreeAndNil(About);
  end;
end;

procedure TfrmWreckingCrew.actCreateExportExecute(Sender: TObject);
var
  frmExport : TfrmExportLevel;
begin
  frmExport := TfrmExportLevel.Create(frmWreckingCrew);
  try
    frmExport.ShowModal;
  finally
    FreeAndNil(frmExport);
  end;

end;

procedure TfrmWreckingCrew.actCreateImportExecute(Sender: TObject);
var
  frmImport : TfrmImportLevel;
begin
  frmImport := TfrmImportLevel.Create(frmWreckingCrew);
  try
    frmImport.ShowModal;
  finally
    FreeAndNil(frmImport);
  end;

end;

procedure TfrmWreckingCrew.actCreateJumpToExecute(Sender: TObject);
var
  JumpTo : TfrmJumpTo;
begin
  JumpTo := TfrmJumpTo.Create(frmWreckingCrew);
  try
    JumpTo.ShowModal;
  finally
    FreeAndNil(JumpTo);
  end;

end;

procedure TfrmWreckingCrew.actCreatePreferencesExecute(Sender: TObject);
var
  Preferences : TfrmPreferences;
  TempPalette : String;
begin
  TempPalette := CurrentPaletteStr;

  Preferences := TfrmPreferences.Create(frmWreckingCrew);
  try
    Preferences.ShowModal;
  finally
    FreeAndNil(Preferences);
  end;
  if TempPalette <> CurrentPaletteStr then
  begin
    if imgLevel.Visible = true then
    begin
      DrawTiles();
      DrawLevelData();
      DrawTileSelector();
    end
  end;
end;

procedure TfrmWreckingCrew.actOpenROMExecute(Sender: TObject);
begin
  if (LastROMLoaded <> '') and (FileExists(LastROMLoaded) = True) then
  begin
    OpenDialog.InitialDir := ExtractFileDir(LastROMLoaded);
  end;

  // Bring up the open dialog
  if OpenDialog.Execute Then
  begin
    Filename := OpenDialog.Filename;
    LastROMLoaded := Filename;
    SaveOptions(ExtractFileDir(ParamStr(0)) + '\options.ini');
    // First, we load the NES rom into memory
    LoadNESROM(Filename);
    // Next we load the datafile into memory
    LoadDataFile(ExtractFileDir(ParamStr(0)) + '\Data\WreckingCrewJUE.ini');
    // Now, we load the palette to be used for the NES
//    LoadNESPalette();
    // Then, we load the palette that is used by the game
    LoadPaletteData();
    // Now, we draw the tiles
    DrawTiles();
    // Set the current level to be the first level
    CurrentLevel :=0;
    // Set the visibility of the images to true
    imgLevel.Visible := true;
    imgTiles.Visible := true;
    // Next we enable saving and the other menu items disabled
    actSaveROM.Enabled := true;
    actCloseROM.Enabled := true;
    actCreateImport.Enabled := true;
    actCreateExport.Enabled := true;
    actCreateExportSaveState.Enabled := true;
    tlbGridlines.Enabled := True;
    actCreateJumpTo.Enabled := True;
    actCreateExportSaveState.Enabled := True;
    actCreateStartingLives.Enabled := True;
    // Set the caption of the form to say Demolition v1.0 plus
    // the level name.
    frmWreckingCrew.Caption := 'Demolition v1.0 - Phase ' + IntToStr(CurrentLevel + 1);
    // Then, we load the level data into a special array
    // for level data
    LoadLevelData();
    // Finally, we draw the level data onto the image32 control.
    DrawLevelData();
    DrawTileSelector();
  end;
end;

procedure TfrmWreckingCrew.actCreateExportSaveStateExecute(
  Sender: TObject);
var
  SSEImport : TfrmSaveStateImport;
begin
  SSEImport := TfrmSaveStateImport.Create(frmWreckingCrew);
  try
    SSEImport.ShowModal;
  finally
    FreeAndNil(SSEImport);
  end;

end;

procedure TfrmWreckingCrew.actCreateStartingLivesExecute(Sender: TObject);
var
  Lives : TfrmLives;
begin
  Lives := TfrmLives.Create(frmWreckingCrew);
  try
    Lives.ShowModal;
  finally
    FreeAndNil(Lives);
  end;

end;

procedure TfrmWreckingCrew.actCloseROMExecute(Sender: TObject);
var
  MsgRes : Integer;
begin

  MsgRes := messagebox(Handle,'Do you want to save the ROM before closing?',PChar(Application.Title),MB_YESNOCANCEL);
  if (MsgRes = IDYES) or (MsgRes = IDNO) then
  begin
    if MsgRes = IDYES then
      actSaveROMExecute(Application);

    imgLevel.Visible := False;
    imgTiles.Visible := False;
    FreeAndNil(Tiles);
    SetLength(ROM,0);
    actSaveROM.Enabled := False;
    actCloseROM.Enabled := False;
    actCreateImport.Enabled := False;
    actCreateExport.Enabled := False;
    actCreateExportSaveState.Enabled := False;
    tlbGridlines.Enabled := False;
    actCreateJumpTo.Enabled := False;
    actCreateExportSaveState.Enabled := False;
    actCreateStartingLives.Enabled := False;
  end;
end;

procedure TfrmWreckingCrew.actSaveROMExecute(Sender: TObject);
begin
  SaveLevelData();
  SaveNESROM(FileName);
  messagebox(Handle,'Changes Saved.',PChar(Application.Title),0);
end;

procedure TfrmWreckingCrew.FormCreate(Sender: TObject);
begin
//  MemCheckLogFileName := 'C:\memory.log';
//  MemChk();
end;

procedure TfrmWreckingCrew.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FreeAndNil(Tiles);
  FreeAndNil(Palettes);
end;

end.
