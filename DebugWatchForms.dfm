inherited DebugWatchFrom: TDebugWatchFrom
  Caption = 'Watches'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited VirtualStringTree1: TVirtualStringTree
    PopupMenu = PopupMenu1
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 40
    Top = 24
    object AddWatch1: TMenuItem
      Caption = 'Add watch'
      OnClick = AddWatch1Click
    end
    object DeleteWatch1: TMenuItem
      Caption = 'Delete Watch'
      OnClick = DeleteWatch1Click
    end
  end
end
