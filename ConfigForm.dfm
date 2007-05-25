object ConfigForm1: TConfigForm1
  Left = 253
  Top = 132
  AutoSize = True
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'DBGp configuration'
  ClientHeight = 313
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 497
    Height = 313
    Caption = 'File Mapping'
    TabOrder = 0
    object Button1: TButton
      Left = 16
      Top = 272
      Width = 75
      Height = 25
      Caption = 'Add'
      TabOrder = 0
      OnClick = Button1Click
    end
    object DeleteButton: TButton
      Left = 104
      Top = 272
      Width = 75
      Height = 25
      Caption = 'Delete'
      TabOrder = 1
      OnClick = DeleteButtonClick
    end
    object Button3: TButton
      Left = 192
      Top = 272
      Width = 75
      Height = 25
      Caption = 'Ok'
      Default = True
      TabOrder = 2
      OnClick = Button3Click
    end
    object StringGrid1: TStringGrid
      Left = 16
      Top = 24
      Width = 465
      Height = 239
      ColCount = 3
      DefaultColWidth = 150
      DefaultRowHeight = 20
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goEditing, goAlwaysShowEditor, goThumbTracking]
      TabOrder = 3
    end
  end
end
