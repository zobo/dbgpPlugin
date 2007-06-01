unit dbgpnppplugin;
{
  This file "extends" the NppPlugin unit and implemets
  the startup routines... The main dll handler calls these routines...
}
interface

uses
  NppPlugin,
  MainForm, nppdockingform,
  ConfigForm, Forms, SciSupport,
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

//var   x:TToolbarIcons;

procedure TDbgpNppPlugin.BeNotified(sn: PSCNotification);
var
  x:TToolbarIcons;
begin
  if (sn^.nmhdr.code = SCN_DWELLSTART) then
  begin
    //if (Assigned(self.TestForm)) then self.TestForm.OnDwell();
    //ShowMessage('SCN_DWELLSTART '+IntToStr(sn^.position));
  end;
  //if (sn^.nmhdr.code = SCN_DOUBLECLICK) then ShowMessage('SCN_DOUBLECLICK');

  if (HWND(sn^.nmhdr.hwndFrom) = self.NppData.NppHandle) then
    if (sn^.nmhdr.code = NPPN_TB_MODIFICATION) then
    begin

      // test za toolbar
      x.ToolbarBmp := LoadImage(Hinstance, 'IDB_DBGP_TEST', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE or LR_LOADMAP3DCOLORS));
      SendMessage(Npp.NppData.NppHandle, WM_ADDTOOLBARICON, self.FuncArray[0].CmdID, LPARAM(@x));
    end;
end;

constructor TDbgpNppPlugin.Create;
var f: TFuncItem;
  //x:TToolbarIcons;
  //tbx:TBitmap;
  //ico:TIcon;
  sk: PShortcutKey;
  i: Integer;
begin
  inherited;
  // Setup menu items
  SetLength(self.FuncArray,10);

  // #112 = F1... pojma nimam od kje...
  self.PluginName := 'DBGp';

  i := 0;

  StrCopy(self.FuncArray[i].ItemName, 'Debugger');
  self.FuncArray[i].Func := _Func1;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StrCopy(self.FuncArray[i].ItemName, '-');
  self.FuncArray[i].Func := _Func1;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StrCopy(self.FuncArray[i].ItemName, 'Step Into');
  self.FuncArray[i].Func := _FuncStepInto;
  New(self.FuncArray[i].ShortcutKey);
  sk := self.FuncArray[i].ShortcutKey;
  sk.IsCtrl := false; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #118; // F7
  inc(i);

  StrCopy(self.FuncArray[i].ItemName, 'Step Over');
  self.FuncArray[i].Func := _FuncStepOver;
  New(self.FuncArray[i].ShortcutKey);
  sk := self.FuncArray[i].ShortcutKey;
  sk.IsCtrl := false; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #119; // F8
  inc(i);

  StrCopy(self.FuncArray[i].ItemName, 'Step Out');
  self.FuncArray[i].Func := _FuncStepOut;
  New(self.FuncArray[i].ShortcutKey);
  sk := self.FuncArray[i].ShortcutKey;
  sk.IsCtrl := false; sk.IsAlt := false; sk.IsShift := true;
  sk.Key := #119; // Shift+F8
  inc(i);

  StrCopy(self.FuncArray[i].ItemName, 'Run');
  self.FuncArray[i].Func := _FuncRun;
  New(self.FuncArray[i].ShortcutKey);
  sk := self.FuncArray[i].ShortcutKey;
  sk.IsCtrl := false; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #120; // F9
  inc(i);

  StrCopy(self.FuncArray[i].ItemName, '-');
  self.FuncArray[i].Func := _Func1;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StrCopy(self.FuncArray[i].ItemName, 'Eval');
  self.FuncArray[i].Func := _FuncEval;
  New(self.FuncArray[i].ShortcutKey);
  sk := self.FuncArray[i].ShortcutKey;
  sk.IsCtrl := true; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #118; // Ctrl+F7
  inc(i);

  // add stack and context items...

  StrCopy(self.FuncArray[i].ItemName, '-');
  self.FuncArray[i].Func := _Func1;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StrCopy(self.FuncArray[i].ItemName, 'Config');
  self.FuncArray[i].Func := _FuncConfig;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  self.ReadMaps(self.maps);

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
  self.MainForm.DlgId := self.FuncArray[0].CmdID;
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
  self.ConfigForm.DlgId := self.FuncArray[9].CmdID;
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
var hm: HMENU;
begin
  inherited;
  if (Msg.Msg = WM_CREATE) then
  begin
  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERDEFINE,  5, SC_MARK_SHORTARROW{SC_MARK_ARROW});
  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERSETFORE, 5, $000000);
  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERSETBACK, 5, $00ff00);

  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERDEFINE,  4, SC_MARK_ROUNDRECT);
  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERSETFORE, 4, $0000ff);
  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERSETBACK, 4, $000055);

  // menu test
  hm := GetMenu(self.NppData.NppHandle);
  ModifyMenu(hm, self.FuncArray[1].CmdID, MF_BYCOMMAND or MF_SEPARATOR, 0, nil);
  ModifyMenu(hm, self.FuncArray[6].CmdID, MF_BYCOMMAND or MF_SEPARATOR, 0, nil);
  ModifyMenu(hm, self.FuncArray[8].CmdID, MF_BYCOMMAND or MF_SEPARATOR, 0, nil);

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
