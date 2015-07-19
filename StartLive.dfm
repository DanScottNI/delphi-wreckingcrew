object frmLives: TfrmLives
  Left = 488
  Top = 408
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Starting Lives'
  ClientHeight = 71
  ClientWidth = 192
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblLives: TLabel
    Left = 8
    Top = 8
    Width = 28
    Height = 13
    Caption = 'Lives:'
  end
  object txtLives: TMdNumEdit
    Left = 64
    Top = 8
    Width = 121
    Height = 21
    MaxLength = 1
    TabOrder = 0
  end
  object cmdOK: TButton
    Left = 32
    Top = 40
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 112
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 1
    TabOrder = 2
  end
end
