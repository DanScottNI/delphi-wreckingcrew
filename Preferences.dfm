object frmPreferences: TfrmPreferences
  Left = 393
  Top = 322
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Options'
  ClientHeight = 231
  ClientWidth = 342
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblPalettes: TLabel
    Left = 8
    Top = 8
    Width = 43
    Height = 13
    Caption = 'Palettes:'
  end
  object lblGridlinesColour: TLabel
    Left = 8
    Top = 170
    Width = 78
    Height = 13
    Caption = 'Gridlines Colour:'
  end
  object lblPaletteDescription: TLabel
    Left = 184
    Top = 8
    Width = 153
    Height = 97
    AutoSize = False
    Caption = 'Palette Description:'
    WordWrap = True
  end
  object lstPalettes: TListBox
    Left = 56
    Top = 8
    Width = 121
    Height = 129
    ItemHeight = 13
    TabOrder = 0
    OnClick = lstPalettesClick
  end
  object chkEnableGridlinesByDefault: TCheckBox
    Left = 8
    Top = 146
    Width = 153
    Height = 17
    Caption = 'Enable Gridlines By Default'
    TabOrder = 1
  end
  object cmdOK: TButton
    Left = 184
    Top = 200
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 264
    Top = 200
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 1
    TabOrder = 3
  end
  object cbGridlineColours: TComboBox
    Left = 96
    Top = 170
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 4
    Text = 'Black'
    Items.Strings = (
      'Black'
      'Dim Grey'
      'Grey'
      'Light Grey'
      'White'
      'Maroon'
      'Green'
      'Olive'
      'Navy'
      'Purple'
      'Teal'
      'Red'
      'Lime'
      'Yellow'
      'Blue'
      'Fuchsia'
      'Aqua')
  end
end
