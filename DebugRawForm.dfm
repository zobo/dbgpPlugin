object DebugRawForm1: TDebugRawForm1
  Left = 308
  Top = 114
  Width = 315
  Height = 235
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'Raw DBGP'
  Color = clBtnFace
  DockSite = True
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  DesignSize = (
    307
    201)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 305
    Height = 169
    Anchors = [akLeft, akTop, akRight, akBottom]
    PopupMenu = PopupMenu1
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Edit1: TEdit
    Left = 0
    Top = 176
    Width = 249
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 1
  end
  object Button1: TButton
    Left = 256
    Top = 176
    Width = 51
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Send'
    Default = True
    TabOrder = 2
    OnClick = Button1Click
  end
  object JvDockClient1: TJvDockClient
    DirectDrag = False
    LeftDock = False
    TopDock = False
    RightDock = False
    DockStyle = NppDockingForm1.JvDockVSNetStyle1
    CustomDock = False
    Left = 8
    Top = 8
  end
  object PopupMenu1: TPopupMenu
    Left = 40
    Top = 8
    object Clear1: TMenuItem
      Caption = 'Clear'
      OnClick = Clear1Click
    end
  end
end
