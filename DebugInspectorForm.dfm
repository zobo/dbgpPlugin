object DebugInspectorForm1: TDebugInspectorForm1
  Left = 192
  Top = 110
  Width = 400
  Height = 262
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'Inspector'
  Color = clBtnFace
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  Visible = True
  DesignSize = (
    392
    228)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 24
    Width = 392
    Height = 204
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 0
    Width = 65
    Height = 17
    Caption = 'Hex'
    TabOrder = 1
    OnClick = CheckBox1Click
  end
end