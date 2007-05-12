unit dbgpnppplugin;
{
  This file "extends" the NppPlugin unit and implemets
  the startup routines... The main dll handler calls these routines...
}
interface

uses
  NppPlugin,
  Dialogs;

type
  TDbgpNppPlugin = class(TNppPlugin)
    public
      constructor Create;

  end;

var Npp: TDbgpNppPlugin;

procedure Func1; cdecl;


implementation

{ TDbgpNppPlugin }

constructor TDbgpNppPlugin.Create;
var f: TFuncItem;
begin
  inherited;

  self.PluginName := 'DBGp';

  f.ItemName := 'Func1';
  f.Func := Func1;
  f.CmdID := 0;
  f.Checked := false;
  f.ShortcutKey := nil;

  self.AddFunc(f);
end;

procedure Func1; cdecl;
begin
  ShowMessage('omg');
end;

end.
