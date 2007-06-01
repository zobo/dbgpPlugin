library dbgpPlugin;
{$R 'dbgpPluginRes.res' 'dbgpPluginRes.rc'}

uses
  SysUtils,
  Classes,
  Types,
  Windows,
  Dialogs,
  Messages,
  nppplugin in 'nppplugin.pas',
  dbgpnppplugin in 'dbgpnppplugin.pas',
  scisupport in 'SciSupport.pas',
  NppDockingForm in 'NppDockingForm.pas',
  MainForm in 'MainForm.pas' {Form1},
  DbgpWinSocket in 'DbgpWinSocket.pas',
  ConfigForm in 'ConfigForm.pas' {ConfigForm1},
  DebugStackForm in 'DebugStackForm.pas' {DebugStackForm1},
  DebugVarForm in 'DebugVarForm.pas' {DebugVarForm1},
  DebugEvalForm in 'DebugEvalForm.pas' {DebugEvalForm1},
  Base64 in 'Base64.pas',
  DebugInspectorForm in 'DebugInspectorForm.pas' {DebugInspectorForm1},
  DebugRawForm in 'DebugRawForm.pas' {DebugRawForm1};

{$R *.res}

procedure DLLEntryPoint(dwReason: DWord);
begin
  case dwReason of
  DLL_PROCESS_ATTACH:
  begin
    // create the main object
    Npp := TDbgpNppPlugin.Create;
  end;
  DLL_PROCESS_DETACH:
  begin
  end;
  //DLL_THREAD_ATTACH: MessageBeep(0);
  //DLL_THREAD_DETACH: MessageBeep(0);
  end;
end;

procedure setInfo(NppData: TNppData); cdecl; export;
begin
  Npp.NppData := NppData;
end;

function getName(): Pchar; cdecl; export;
begin
  Result := Npp.GetName;
end;

function getFuncsArray(var nFuncs:integer):Pointer;cdecl; export;
begin
  Result := Npp.GetFuncsArray(nFuncs);
end;


procedure beNotified(sn: PSCNotification); cdecl; export;
begin
  Npp.BeNotified(sn);
end;

function messageProc(msg: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; cdecl; export;
var xmsg:TMessage;
begin
  xmsg.Msg := msg;
  xmsg.WParam := wParam;
  xmsg.LParam := lParam;
  xmsg.Result := 0;
  Npp.MessageProc(xmsg);
  Result := xmsg.Result;
end;

exports
  setInfo, getName, getFuncsArray, beNotified, messageProc;

begin
  { First, assign the procedure to the DLLProc variable }
  DllProc := @DLLEntryPoint;
  { Now invoke the procedure to reflect that the DLL is attaching to the process }
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.

