unit DebugContextForms;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DebugVarForms, Menus, JvComponentBase, JvDockControlForm,
  VirtualTrees;

type
  TRefreshCB = procedure(Sender: TObject) of Object;
  TDebugContextForm = class(TDebugVarForm)
    PopupMenu1: TPopupMenu;
    Refresh1: TMenuItem;
    procedure Refresh1Click(Sender: TObject);
  private
    { Private declarations }
    FOnRefresh: TRefreshCB;
  public
    { Public declarations }
  published
    property OnRefresh: TRefreshCB read FOnRefresh write FOnRefresh;
  end;

var
  DebugContextForm: TDebugContextForm;

implementation

{$R *.dfm}

procedure TDebugContextForm.Refresh1Click(Sender: TObject);
begin
  //inherited;
  if (Assigned(FOnRefresh)) then
    self.FOnRefresh(self);
end;

end.
