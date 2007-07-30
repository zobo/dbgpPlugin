object DebugBreakpointsForm1: TDebugBreakpointsForm1
  Left = 776
  Top = 112
  Width = 264
  Height = 206
  BorderStyle = bsSizeToolWin
  Caption = 'Breakpoints'
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
  OnCreate = FormCreate
  DesignSize = (
    256
    172)
  PixelsPerInch = 96
  TextHeight = 13
  object VirtualStringTree1: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 256
    Height = 172
    Anchors = [akLeft, akTop, akRight, akBottom]
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'MS Sans Serif'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoVisible]
    HintMode = hmTooltip
    ParentShowHint = False
    PopupMenu = PopupMenu1
    ShowHint = True
    TabOrder = 0
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    TreeOptions.StringOptions = [toSaveCaptions]
    OnGetText = VirtualStringTree1GetText
    Columns = <
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 0
        Width = 25
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 1
        Width = 60
        WideText = 'Type'
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 2
        Width = 200
        WideText = 'Breakpoint data'
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 3
        Width = 40
        WideText = 'Hits'
      end>
  end
  object JvDockClient1: TJvDockClient
    DirectDrag = False
    EnableCloseButton = False
    LeftDock = False
    TopDock = False
    RightDock = False
    DockStyle = NppDockingForm1.JvDockVSNetStyle1
    CustomDock = False
    Left = 8
    Top = 24
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 40
    Top = 24
    object Addbreakpoint1: TMenuItem
      Caption = 'Add breakpoint...'
      OnClick = Addbreakpoint1Click
    end
    object Editbreakpoint1: TMenuItem
      Caption = 'Edit breakpoint...'
      OnClick = Editbreakpoint1Click
    end
    object Removebreakpoint1: TMenuItem
      Caption = 'Remove breakpoint'
      OnClick = Removebreakpoint1Click
    end
  end
end
