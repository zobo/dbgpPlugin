{
    This file is part of DBGP Plugin for Notepad++
    Copyright (C) 2007  Damjan Zobo Cvetko

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
}

unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NppDockingForm, StdCtrls, ScktComp, DbgpWinSocket, ComCtrls,
  Buttons, ExtCtrls, Grids, JvDockTree, JvDockControlForm, JvDockVCStyle,
  JvComponentBase, DebugStackForm, DebugVarForm, JvDockVIDStyle, JvDockVSNetStyle,
  DebugEvalForm, DebugRawForm, ImgList, ToolWin, DebugBreakpointsForm;

type
  TNppDockingForm1 = class(TNppDockingForm)
    ServerSocket1: TServerSocket;
    JvDockServer1: TJvDockServer;
    JvDockVSNetStyle1: TJvDockVSNetStyle;
    BitBtnStepInto: TBitBtn;
    BitBtnStepOver: TBitBtn;
    BitBtnStepOut: TBitBtn;
    BitBtnRun: TBitBtn;
    BitBtnBreakpoint: TBitBtn;
    BitBtnEval: TBitBtn;
    BitBtnClose: TBitBtn;
    BitBtnRaw: TBitBtn;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ServerSocket1Accept(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1GetSocket(Sender: TObject; Socket: Integer;
      var ClientSocket: TServerClientWinSocket);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure BitBtnStepIntoClick(Sender: TObject);
    procedure BitBtnStepOverClick(Sender: TObject);
    procedure BitBtnStepOutClick(Sender: TObject);
    procedure BitBtnRunClick(Sender: TObject);
    procedure BitBtnBreakpointClick(Sender: TObject);
    procedure BitBtnEvalClick(Sender: TObject);
    procedure BitBtnCloseClick(Sender: TObject);
    procedure BitBtnRawClick(Sender: TObject);
  private
    { Private declarations }
    state: TDbgpState;
    procedure sockDbgpStack(Sender:TDbgpWinSocket; Stack: TStackList);
    procedure sockDbgpInit(Sender:TDbgpWinSocket; init: TInit);
    procedure sockDbgpEval(Sender: TDbgpWinSocket; context: Integer; list: TPropertyItems);
    procedure sockDbgpContext(Sender: TDbgpWinSocket; context: Integer; list: TPropertyItems);
    procedure sockDbgpBreak(Sender: TDbgpWinSocket; Stopped: Boolean);
    procedure sockDbgpStream(Sender: TDbgpWinSocket; stream, data:String);
    procedure sockDbgpBreakpoints(Sender: TDbgpWinSocket; breakpoints: TBreakpoints);

    procedure ContextOnRefresh(Sender: TObject);
    procedure StackOnGetContext(Sender: TObject; Depth: Integer);

    procedure BreakpointAdd(Sender: TComponent; bp: TBreakpoint);
    procedure BreakpointEdit(Sender: TComponent; bp: TBreakpoint);
    procedure BreakpointDelete(Sender: TComponent; bp: TBreakpoint);
    procedure StackSelect(Sender: TObject; filename: String; lineno: integer);

  public
    { Public declarations }
    sock: TDbgpWinSocket;
    DebugStackForm1: TDebugStackForm1;
    ContextLocalForm1: TDebugVarForm1;
    ContextGlobalForm1: TDebugVarForm1;
    DebugEvalForm1: TDebugEvalForm1;
    DebugRawForm1: TDebugRawForm1;
    DebugBreakpointsForm1: TDebugBreakpointsForm1;
    procedure GotoLine(filename: string; Lineno:Integer);
    procedure DoResume(runtype: TRun);
    procedure DoEval; overload;
    procedure DoEval(data:string); overload;
    procedure SetState(state: TDbgpState);
  end;

var
  NppDockingForm1: TNppDockingForm1;
{  NppDockingForm1: TNppDockingForm1;}
{  Form1: TForm1;}

implementation

{$R *.dfm}
uses dbgpnppplugin, nppplugin, SciSupport;

procedure TNppDockingForm1.FormCreate(Sender: TObject);
begin
  // laho bi tle zacel poslusat za dwell
  self.DebugStackForm1 := TDebugStackForm1.Create(self);
  self.DebugStackForm1.OnGetContext := self.StackOnGetContext;
  self.DebugStackForm1.OnStackSelect := self.StackSelect;
  //self.DebugStackForm1.Npp := self.Npp;
  self.Npp.RegisterForm(TForm(self.DebugStackForm1));

  // local context...
  self.ContextLocalForm1 := TDebugVarForm1.Create(self);
  self.ContextLocalForm1.Npp := self.Npp;
  self.Npp.RegisterForm(TForm(self.ContextLocalForm1));
  self.ContextLocalForm1.OnRefresh := self.ContextOnRefresh;
  self.ContextLocalForm1.Tag := 0;
  self.ContextLocalForm1.Caption := 'Local context';
  // global context
  self.ContextGlobalForm1 := TDebugVarForm1.Create(self);
  self.ContextGlobalForm1.Npp := self.Npp;
  self.Npp.RegisterForm(TForm(self.ContextGlobalForm1));
  self.ContextGlobalForm1.OnRefresh := self.ContextOnRefresh;
  self.ContextGlobalForm1.Tag := 1;
  self.ContextGlobalForm1.Caption := 'Global context';

  ManualTabDock(self.JvDockServer1.BottomDockPanel, self.ContextLocalForm1, self.ContextGlobalForm1);

  self.DebugRawForm1 := TDebugRawForm1.Create(self);
  //self.DebugRawForm1.Npp := self.Npp;
  self.Npp.RegisterForm(TForm(self.DebugRawForm1));
  //self.DebugRawForm1.Show;

  //self.DebugStackForm1.ManualDock(self.JvDockServer1.BottomDockPanel);
  //self.JvDockServer1.BottomDockPanel.ShowDockPanel(true, self.DebugStackForm1);

  self.DebugBreakpointsForm1 := TDebugBreakpointsForm1.Create(self);
  self.DebugBreakpointsForm1.OnBreakpointAdd := self.BreakpointAdd;
  self.DebugBreakpointsForm1.OnBreakpointEdit := self.BreakpointEdit;
  self.DebugBreakpointsForm1.OnBreakpointDelete := self.BreakpointDelete;
  //self.DebugBreakpointsForm1.ManualDock(self.JvDockServer1.BottomDockPanel);
  //self.JvDockServer1.BottomDockPanel.ShowDockPanel(true, self.DebugBreakpointsForm1);

  ManualTabDock(self.JvDockServer1.BottomDockPanel, self.DebugStackForm1, self.DebugBreakpointsForm1);

  self.SetState(DbgpWinSocket.dsStopped);
end;

procedure TNppDockingForm1.ServerSocket1Accept(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  FlashWindow(self.Npp.NppData.NppHandle, true);
  self.Show;

  if (Assigned(self.DebugRawForm1)) then
  begin
    self.DebugRawForm1.Memo1.Lines.Add('Accept: '+Socket.RemoteAddress);
  end;
  self.SetState(DbgpWinSocket.dsStopped);
end;

procedure TNppDockingForm1.ServerSocket1GetSocket(Sender: TObject;
  Socket: Integer; var ClientSocket: TServerClientWinSocket);
begin
  ClientSocket := TDbgpWinSocket.Create(Socket,Sender as TServerWinSocket);
  self.sock := ClientSocket as TDbgpWinSocket;
  self.sock.maps := (self.Npp as TDbgpNppPlugin).config.maps;
  self.sock.use_source := (self.Npp as TDbgpNppPlugin).config.use_source;
  self.sock.OnDbgpStack := self.sockDbgpStack;
  self.sock.OnDbgpInit := self.sockDbgpInit;
  self.sock.OnDbgpEval := self.sockDbgpEval;
  self.sock.OnDbgpContext := self.sockDbgpContext;
  self.sock.OnDbgpBreak := self.sockDbgpBreak;
  self.sock.OnDbgpBreakpoints := self.sockDbgpBreakpoints;
end;

procedure TNppDockingForm1.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
  r: String;
  sock: TDbgpWinSocket;
begin
  sock := Socket as TDbgpWinSocket;
  r:=sock.ReadDBGP;
  if (Assigned(self.DebugRawForm1)) then
  begin
    self.DebugRawForm1.Memo1.Lines.AddStrings(sock.debugdata);
    self.DebugRawForm1.Memo1.Lines.Add('----');
  end;
  sock.debugdata.Clear;
end;

procedure TNppDockingForm1.ServerSocket1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  if (Assigned(self.DebugRawForm1)) then self.DebugRawForm1.Memo1.Lines.Add('Disconnect: '+Socket.RemoteAddress);
  self.Label1.Caption := 'Disconnected...';
  self.sock := nil;
  self.DebugStackForm1.ClearStack;
  self.ContextLocalForm1.ClearVars;
  self.ContextGlobalForm1.ClearVars;
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEALL, 5, 0);
  //SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEALL, 4, 0);
  //SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_SETMOUSEDWELLTIME, SC_TIME_FOREVER,0);

  self.SetState(dsStopped);
end;

procedure TNppDockingForm1.sockDbgpStack(Sender: TDbgpWinSocket; Stack: TStackList);
begin
  self.DebugStackForm1.SetStack(Stack);
  if (Length(Stack)>0) {and (Stack[0].stacktype = 'file')} then
  begin
    // test hack
    if (FileExists(Stack[0].filename)) then
      GotoLine(Stack[0].filename, Stack[0].lineno)
    else
      self.sock.GetStack; // let the file get processed and ask for stack again.. this can go really bad!
  end;

  // Do something usefull with this...
  //SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_SETMOUSEDWELLTIME, 1000,0);
end;

procedure TNppDockingForm1.sockDbgpInit(Sender: TDbgpWinSocket; init: TInit);
var
  i: integer;
begin
  self.SetState(DbgpWinSocket.dsStarting);
  self.sock.SetFeature('max_depth','3'); // make configurable
  self.Label1.Caption := 'Connected to '+self.sock.RemoteAddress+' idekey: '+init.idekey+' file: '+init.filename;
  {
  if Assigned(self.sock) then
  begin
    //self.sock.GetFeature('support_async');
    //self.sock.SetFeature('notify_ok', '1'); // unsupported by xdebug
  end;
  }
  for i:=0 to Length(self.DebugBreakpointsForm1.breakpoints)-1 do
  begin
    self.sock.SetBreakpoint(self.DebugBreakpointsForm1.breakpoints[i]);
  end;
  self.sock.GetBreakpoints;
end;

procedure TNppDockingForm1.GotoLine(filename: string; Lineno: Integer);
var
  i: integer;
  r: boolean;
begin
  // @todo: create some helper functions in NppPlugin
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEALL, 5, 0);
  r := self.Npp.DoOpen(filename, lineno-1);
  if (not r) then exit;
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEALL, 5, 0);
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERADD, lineno-1, 5);
  // redraw all line breakpoints
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEALL, 4, 0);
  for i := 0 to Length(self.DebugBreakpointsForm1.breakpoints)-1 do
  begin
    if (self.DebugBreakpointsForm1.breakpoints[i].breakpointtype <> btLine) then continue;
    if (self.DebugBreakpointsForm1.breakpoints[i].filename <> filename) then continue;
    SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERADD, self.DebugBreakpointsForm1.breakpoints[i].lineno-1, 4);
  end;
end;

procedure TNppDockingForm1.sockDbgpContext(Sender: TDbgpWinSocket;
  context: Integer; list: TPropertyItems);
begin
  if (context = 0) then self.ContextLocalForm1.SetVars(list);
  if (context = 1) then self.ContextGlobalForm1.SetVars(list);
end;

procedure TNppDockingForm1.sockDbgpEval(Sender: TDbgpWinSocket;
  context: Integer; list: TPropertyItems);
var
  x: TDebugVarForm1;
begin
  x := TDebugVarForm1.Create(self);
  x.Npp := self.Npp;
  x.UseMenu(false);
  x.SetVars(list);
  x.Caption := 'Eval';
  x.Show;
  self.Npp.RegisterForm(TForm(x));
end;

procedure TNppDockingForm1.sockDbgpBreakpoints(Sender: TDbgpWinSocket;
  breakpoints: TBreakpoints);
begin
  self.DebugBreakpointsForm1.SetBreakpoints(breakpoints);
end;


procedure TNppDockingForm1.DoResume(runtype: TRun);
begin
  if (Assigned(self.sock)) then
  begin
    self.SetState(DbgpWinSocket.dsRunning);
    self.sock.Resume(runtype);
  end;
end;

// show eval dlg and send eval cmd
procedure TNppDockingForm1.DoEval;
var
  r: Integer;
begin
  if (not Assigned(self.DebugEvalForm1)) then
  begin
    self.DebugEvalForm1 := TDebugEvalForm1.Create(self);
    self.Npp.RegisterForm(TForm(self.DebugEvalForm1));
  end;
  self.DebugEvalForm1.ComboBox1.Text := self.Npp.GetWord;
  r := self.DebugEvalForm1.ShowModal;
  if (r = mrOk) then
  begin
    self.DoEval(self.DebugEvalForm1.ComboBox1.Text);
  end;
end;

procedure TNppDockingForm1.DoEval(data: string);
begin
  if (Assigned(self.sock)) then
    self.sock.SendEval(data);
end;


procedure TNppDockingForm1.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  MessageBeep(1);
  Action := caNone;
end;

procedure TNppDockingForm1.sockDbgpBreak(Sender: TDbgpWinSocket;
  Stopped: Boolean);
begin
  if (not Stopped) then
  begin
    Sender.GetStack;
    self.SetState(DbgpWinSocket.dsBreak);
    // update stuff
    self.sock.GetBreakpoints;
    if (self.Npp as TDbgpNppPlugin).config.refresh_local then self.sock.GetContext(0);
    if (self.Npp as TDbgpNppPlugin).config.refresh_remote then self.sock.GetContext(1);
  end
  else
  begin
    SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEALL, 5, 0);
    Sender.Resume(Run);
  end;
end;

procedure TNppDockingForm1.FormResize(Sender: TObject);
begin
  if (self.Height > 60) then
  self.JvDockServer1.BottomDockPanel.Height := self.Height - 30;
end;

procedure TNppDockingForm1.ContextOnRefresh(Sender: TObject);
begin
 // send context refresh
 if (Assigned(self.sock)) then
   self.sock.GetContext(TForm(Sender).Tag);
end;

procedure TNppDockingForm1.StackOnGetContext(Sender: TObject;
  Depth: Integer);
begin
  // get context for depth
 if (Assigned(self.sock)) then
   self.sock.GetContext(0,Depth);
end;

{ "Toolbar" icons }
procedure TNppDockingForm1.BitBtnStepIntoClick(Sender: TObject);
begin
  self.DoResume(StepInto);
end;

procedure TNppDockingForm1.BitBtnStepOverClick(Sender: TObject);
begin
  self.DoResume(StepOver);
end;

procedure TNppDockingForm1.BitBtnStepOutClick(Sender: TObject);
begin
  self.DoResume(StepOut);
end;

procedure TNppDockingForm1.BitBtnRunClick(Sender: TObject);
begin
  self.DoResume(Run);
end;

procedure TNppDockingForm1.BitBtnBreakpointClick(Sender: TObject);
var
  s: string;
  i: integer;
  bp: TBreakpoint;
begin
  self.Npp.GetFileLine(s,i);
  if (self.state in [dsStarting, dsBreak]) then
  begin
    self.sock.SetBreakpoint(s,i+1);
    self.sock.GetBreakpoints;
  end
  else
  begin
    bp.id := '';
    bp.breakpointtype := btLine;
    bp.filename := s;
    bp.lineno := i+1;
    bp.state := true;
    bp.functionname := '';
    bp.classname := '';
    bp.temporary := false;
    bp.hit_count := 0;
    bp.hit_value := 0;
    bp.hit_condition := '>=';
    bp.exception := '';
    bp.expression := '';
    self.DebugBreakpointsForm1.AddBreakpoint(bp);
  end;

  // @todo: create some helper functions in NppPlugin
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERADD, i, 4);
end;

procedure TNppDockingForm1.BitBtnEvalClick(Sender: TObject);
begin
  TDbgpNppPlugin(self.Npp).FuncEval;
end;

{ ugasne debugger }
procedure TNppDockingForm1.BitBtnCloseClick(Sender: TObject);
begin
  if (Assigned(self.sock)) then self.sock.Close;
  if (self.ServerSocket1.Active) then self.BitBtnClose.Caption := 'Turn ON' else self.BitBtnClose.Caption := 'Turn OFF';
  if (self.ServerSocket1.Active) then self.ServerSocket1.Close else self.ServerSocket1.Open;
end;

procedure TNppDockingForm1.BitBtnRawClick(Sender: TObject);
begin
  self.DebugRawForm1.Show;
end;

{ test stream }
procedure TNppDockingForm1.sockDbgpStream(Sender: TDbgpWinSocket; stream,
  data: String);
begin
  self.DebugRawForm1.Memo1.Lines.Add(stream+': '+data);

end;

{ set enable buttons and stuff }
procedure TNppDockingForm1.SetState(state: TDbgpState);
var
  stepping, evaling, breaking: boolean;
begin
  self.state := state;

  stepping := false; evaling := false; breaking := false;

  case state of
  dsStarting: begin stepping := true; breaking := true; end;
  dsStopping: stepping := true;
  //dsStopped:
  //dsRunning:
  dsBreak: begin stepping := true; evaling := true; breaking := true; end;
  end;

  breaking := true; { always true, bp child }

  self.BitBtnStepInto.Enabled := stepping;
  self.BitBtnStepOver.Enabled := stepping;
  self.BitBtnStepOut.Enabled := stepping;
  self.BitBtnRun.Enabled := stepping;

  self.BitBtnEval.Enabled := evaling;
  self.BitBtnBreakpoint.Enabled := breaking;
end;



{
procedure TNppDockingForm1.Button3Click(Sender: TObject);
var
  s: String;
  //f: TextFile;
  i: Integer;
begin

  // test
  Output redirect...

  s := '';
  SetLength(s, 200);
  GetTempPath(200, PChar(s)); // stupid.. doda na koncu #0 in se ne da pripet vec stringa@#!@
  SetLength(s, StrLen(PChar(s)));
  s := s + 'STDOUT';
  //self.Memo1.Lines.Add('tmp: '+s);
  AssignFile(f, s);
  Rewrite(f);
  CloseFile(f);
  SendMessage(self.Npp.NppData.NppHandle, WM_DOOPEN, 0, LPARAM(PChar(s)));

  SendMessage(self.Npp.NppData.ScintillaMainHandle, SciSupport.SCI_CLEARALL,0,0);
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SciSupport.SCI_APPENDTEXT,10,LPARAM(PChar('123456789012')));

end;
}

{ breakpoint editing hooks }
procedure TNppDockingForm1.BreakpointAdd(Sender: TComponent;
  bp: TBreakpoint);
begin
  if Assigned(self.sock) and (self.state <> dsStopped) then
  begin
    self.sock.SetBreakpoint(bp);
    self.sock.GetBreakpoints;
  end;
end;

procedure TNppDockingForm1.BreakpointDelete(Sender: TComponent;
  bp: TBreakpoint);
begin
  if Assigned(self.sock) and (self.state <> dsStopped) then
  begin
    self.sock.RemoveBreakpoint(bp);
    self.sock.GetBreakpoints;
  end;
end;

procedure TNppDockingForm1.BreakpointEdit(Sender: TComponent;
  bp: TBreakpoint);
begin
  if Assigned(self.sock) and (self.state <> dsStopped) then
  begin
    self.sock.UpdateBreakpoint(bp);
    self.sock.GetBreakpoints;
  end;
end;

procedure TNppDockingForm1.StackSelect(Sender: TObject; filename: String;
  lineno: integer);
begin
  self.GotoLine(filename, lineno);
end;

end.
