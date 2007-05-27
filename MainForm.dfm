object NppDockingForm1: TNppDockingForm1
  Left = 255
  Top = 725
  Width = 515
  Height = 204
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Button3: TButton
    Left = 6
    Top = 4
    Width = 75
    Height = 25
    Caption = 'set line break'
    TabOrder = 0
    OnClick = Button3Click
  end
  object ServerSocket1: TServerSocket
    Active = True
    Port = 9000
    ServerType = stNonBlocking
    OnAccept = ServerSocket1Accept
    OnGetSocket = ServerSocket1GetSocket
    OnClientDisconnect = ServerSocket1ClientDisconnect
    OnClientRead = ServerSocket1ClientRead
    Left = 288
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
    Left = 224
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
    Left = 256
  end
end
