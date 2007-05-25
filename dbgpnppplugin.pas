unit dbgpnppplugin;
{
  This file "extends" the NppPlugin unit and implemets
  the startup routines... The main dll handler calls these routines...
}
interface

uses
  NppPlugin,
  MainForm, nppdockingform,
  data_form, ConfigForm, Forms, SciSupport,
  Classes, Dialogs, IniFiles, DbgpWinSocket, Messages;

type
  TDbgpNppPlugin = class(TNppPlugin)
    private
      MainForm: TNppDockingForm1;
      ConfigForm: TConfigForm1;
    public
      maps: TMaps;
      constructor Create;
      destructor Destroy; override;

      procedure BeNotified(sn: PSCNotification); override;
      procedure MessageProc(var Msg: TMessage); override;

      procedure Func1;
      procedure FuncConfig;
      procedure FuncStepInto;
      procedure FuncStepOver;
      procedure FuncStepOut;
      procedure FuncRun;
      procedure FuncEval;
      procedure ReadMaps(var maps: TMaps);
      procedure WriteMaps(maps: TMaps);

  end;

  var Npp: TDbgpNppPlugin;

procedure _Func1; cdecl;
procedure _FuncConfig; cdecl;
procedure _FuncStepInto; cdecl;
procedure _FuncStepOver; cdecl;
procedure _FuncStepOut; cdecl;
procedure _FuncRun; cdecl;
procedure _FuncEval; cdecl;


implementation

{ TDbgpNppPlugin }
uses Windows,Graphics,SysUtils;

procedure TDbgpNppPlugin.BeNotified(sn: PSCNotification);
begin
  if (sn^.nmhdr.code = SCN_DWELLSTART) then
  begin
    //if (Assigned(self.TestForm)) then self.TestForm.OnDwell();
    //ShowMessage('SCN_DWELLSTART '+IntToStr(sn^.position));
  end;
  //if (sn^.nmhdr.code = SCN_DOUBLECLICK) then ShowMessage('SCN_DOUBLECLICK');
end;

constructor TDbgpNppPlugin.Create;
var f: TFuncItem;
  //x:TToolbarIcons;
  //tbx:TBitmap;
  //ico:TIcon;
  sk: TShortcutKey;
begin
  inherited;
  // Setup menu items

  // #112 = F1... pojma nimam od kje...

  self.PluginName := 'DBGp';

  f.ItemName := 'Debugger';
  f.Func := _Func1;
  f.CmdID := 0;
  f.Checked := false;
  f.ShortcutKey := nil;
  self.AddFunc(f);

  f.ItemName := 'Step Into';
  f.Func := _FuncStepInto;
  f.CmdID := 1;
  sk.IsCtrl := false; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #118; // F7
  f.ShortcutKey := @sk;
  self.AddFunc(f);

  f.ItemName := 'Step Over';
  f.Func := _FuncStepOver;
  f.CmdID := 2;
  sk.IsCtrl := false; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #119; // F8
  f.ShortcutKey := @sk;
  self.AddFunc(f);

  f.ItemName := 'Step Out';
  f.Func := _FuncStepOut;
  f.CmdID := 3;
  sk.IsCtrl := false; sk.IsAlt := false; sk.IsShift := true;
  sk.Key := #119; // Shift+F8
  f.ShortcutKey := @sk;
  self.AddFunc(f);

  f.ItemName := 'Run';
  f.Func := _FuncRun;
  f.CmdID := 4;
  sk.IsCtrl := false; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #120; // F9
  f.ShortcutKey := @sk;
  self.AddFunc(f);

  f.ItemName := 'Eval';
  f.Func := _FuncEval;
  f.CmdID := 5;
  sk.IsCtrl := true; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #118; // Ctrl+F7
  f.ShortcutKey := @sk;
  self.AddFunc(f);


  f.ItemName := 'Config';
  f.Func := _FuncConfig;
  f.CmdID := 6;
  f.ShortcutKey := nil;
  self.AddFunc(f);

  self.ReadMaps(self.maps);

//  SendMessage(self.NppData.ScintillaMainHandle, SCI_SETMOUSEDWELLTIME, 500,500);

   // OBUP!!
  {


  // test za toolbar
  Form2 := TForm2.Create(nil);


  tbx := TBitmap.Create;
  ico := TIcon.Create;
  Form2.ImageList1.GetBitmap(0, tbx);
  Form2.ImageList1.GetIcon(0,ico);

  x.ToolbarBmp := tbx.ReleaseHandle;
  x.ToolbarIcon := 0;

  ShowMessage('bmp: '+IntToStr(x.ToolbarBmp));

  // id = 0
  SendMessage(Npp.NppData.NppHandle, WM_ADDTOOLBARICON, 0, LPARAM(@x));
  ShowMessage('ico: '+IntToStr(x.ToolbarIcon));
  }
end;


destructor TDbgpNppPlugin.Destroy;
begin
  ShowMessage('dbgpplugin.destroy');
  inherited;
end;

procedure TDbgpNppPlugin.Func1;
begin
  //ShowMessage('omg');
  if (Assigned(self.MainForm)) then
  begin
    self.MainForm.Show;
    exit;
  end;
  self.MainForm := TNppDockingForm1.Create(self);
  self.MainForm.DlgId := 0;
  self.MainForm.Show;
  self.RegisterDockingForm(TNppDockingForm(self.MainForm));
end;

{ hook }
procedure _Func1; cdecl;
begin
  Npp.Func1;
end;
procedure _FuncConfig; cdecl;
begin
  Npp.FuncConfig;
end;
procedure _FuncStepInto; cdecl;
begin
  Npp.FuncStepInto;
end;
procedure _FuncStepOver; cdecl;
begin
  Npp.FuncStepOver;
end;
procedure _FuncStepOut; cdecl;
begin
  Npp.FuncStepOut;
end;
procedure _FuncRun; cdecl;
begin
  Npp.FuncRun;
end;
procedure _FuncEval; cdecl;
begin
  Npp.FuncEval;
end;

procedure TDbgpNppPlugin.FuncConfig;
begin
  self.ConfigForm := TConfigForm1.Create(self);
  self.ConfigForm.DlgId := 6;
  self.RegisterForm(TForm(self.ConfigForm));
  self.ConfigForm.Show;
end;

procedure TDbgpNppPlugin.FuncEval;
begin
  // show eval dlg...
  if (Assigned(self.MainForm)) then self.MainForm.DoEval;
end;

procedure TDbgpNppPlugin.FuncRun;
begin
  if (Assigned(self.MainForm)) then self.MainForm.DoResume(Run);
end;

procedure TDbgpNppPlugin.FuncStepInto;
begin
  if (Assigned(self.MainForm)) then self.MainForm.DoResume(StepInto);
end;

procedure TDbgpNppPlugin.FuncStepOut;
begin
  if (Assigned(self.MainForm)) then self.MainForm.DoResume(StepOut);
end;

procedure TDbgpNppPlugin.FuncStepOver;
begin
  if (Assigned(self.MainForm)) then self.MainForm.DoResume(StepOver);
end;

procedure TDbgpNppPlugin.MessageProc(var Msg: TMessage);
begin
  inherited;
  if (Msg.Msg = WM_CREATE) then
  begin
  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERDEFINE, 5, SC_MARK_ARROW);
  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERSETFORE, 5, $000000);
  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERSETBACK, 5, $00ff00);

  end;
end;

procedure TDbgpNppPlugin.ReadMaps(var maps: TMaps);
var
  path: string;
  ini: TIniFile;
  xmaps: TStringList;
  i: integer;
begin
  SetLength(path, 1000);
  GetModuleFileName(0, PChar(path), 1000);
  path := ExtractFileDir(path);
  path := path + '\plugins\Config\dbgp.ini';

  ini := TIniFile.Create(path);
  xmaps := TStringList.Create();
  ini.ReadSection('Mapping',xmaps);

  SetLength(maps, xmaps.Count);
  for i:=0 to xmaps.Count-1 do
  begin
    maps[i] := TStringList.Create;
    maps[i].Delimiter := ';';
    maps[i].DelimitedText := ini.ReadString('Mapping',xmaps[i],';;');
  end;
  ini.Free;
  xmaps.Free;
end;

procedure TDbgpNppPlugin.WriteMaps(maps: TMaps);
var
  path: string;
  ini: TIniFile;
  xmaps: TStringList;
  i: integer;
begin
  path := '';
  SetLength(path, 200);
  GetModuleFileName(0, PChar(path), 199);
  path := Trim(path);
  path := ExtractFileDir(Trim(path));
  path := path + '\plugins\Config\dbgp.ini';

  ini := TIniFile.Create(path);

  xmaps := TStringList.Create();
  ini.ReadSection('Mapping',xmaps);

  for i:=0 to xmaps.Count-1 do
  begin
    ini.DeleteKey('Mapping',xmaps[i]);
  end;
  xmaps.Free;

  for i:=0 to Length(maps)-1 do
  begin
    maps[i].Delimiter := ';';
    ini.WriteString('Mapping','Map'+IntToStr(i),maps[i].DelimitedText);
  end;
  ini.Free;

  // reread config
  self.ReadMaps(self.maps);

end;

end.
