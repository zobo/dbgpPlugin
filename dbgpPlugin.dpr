library dbgpPlugin;

uses
  SysUtils,
  Classes,
  Types,
  Windows,
  Messages,
  nppplugin in 'nppplugin.pas',
  dbgpnppplugin in 'dbgpnppplugin.pas',
  scisupport in 'SciSupport.pas';

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
  DLL_THREAD_ATTACH: MessageBeep(0);
  DLL_THREAD_DETACH: MessageBeep(0);
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

procedure beNotified(x: Pointer); cdecl; export;
begin
  Npp.BeNotified(x);
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

