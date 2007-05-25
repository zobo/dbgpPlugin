object NppDockingForm1: TNppDockingForm1
  Left = 222
  Top = 503
  Width = 1003
  Height = 379
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'DBGp'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 20
    Width = 401
    Height = 277
    Lines.Strings = (
      '')
    TabOrder = 0
  end
  object Button3: TButton
    Left = 422
    Top = 44
    Width = 75
    Height = 25
    Caption = 'set line break'
    TabOrder = 1
    OnClick = Button3Click
  end
  object Button1: TButton
    Left = 422
    Top = 180
    Width = 75
    Height = 25
    Caption = 'raw'
    Default = True
    TabOrder = 2
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 8
    Top = 305
    Width = 401
    Height = 21
    TabOrder = 3
  end
  object Button6: TButton
    Left = 424
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Eval'
    TabOrder = 4
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 432
    Top = 296
    Width = 75
    Height = 25
    Caption = 'Button7'
    TabOrder = 5
    OnClick = Button7Click
  end
  object ServerSocket1: TServerSocket
    Active = True
    Port = 9000
    ServerType = stNonBlocking
    OnAccept = ServerSocket1Accept
    OnGetSocket = ServerSocket1GetSocket
    OnClientDisconnect = ServerSocket1ClientDisconnect
    OnClientRead = ServerSocket1ClientRead
    Left = 464
    Top = 8
  end
  object JvDockServer1: TJvDockServer
    LeftSplitterStyle.Cursor = crHSplit
    LeftSplitterStyle.ParentColor = False
    RightSplitterStyle.Cursor = crHSplit
    RightSplitterStyle.ParentColor = False
    TopSplitterStyle.Cursor = crVSplit
    TopSplitterStyle.ParentColor = False
    BottomSplitterStyle.Cursor = crVSplit
    BottomSplitterStyle.ParentColor = False
    AutoFocusDockedForm = False
    LeftDock = False
    TopDock = False
    RightDock = False
    DockStyle = JvDockVSNetStyle1
    CustomDock = False
  end
  object JvDockVSNetStyle1: TJvDockVSNetStyle
    AlwaysShowGrabber = False
    TabServerOption.ActiveFont.Charset = DEFAULT_CHARSET
    TabServerOption.ActiveFont.Color = clWindowText
    TabServerOption.ActiveFont.Height = -11
    TabServerOption.ActiveFont.Name = 'MS Sans Serif'
    TabServerOption.ActiveFont.Style = []
    TabServerOption.InactiveFont.Charset = DEFAULT_CHARSET
    TabServerOption.InactiveFont.Color = 5395794
    TabServerOption.InactiveFont.Height = -11
    TabServerOption.InactiveFont.Name = 'MS Sans Serif'
    TabServerOption.InactiveFont.Style = []
    TabServerOption.ShowCloseButtonOnTabs = False
    Left = 24
  end
end
