unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NppDockingForm, StdCtrls, ScktComp, DbgpWinSocket, ComCtrls,
  Buttons, ExtCtrls, Grids, JvDockTree, JvDockControlForm, JvDockVCStyle,
  JvComponentBase, DebugStackForm, DebugVarForm, JvDockVIDStyle, JvDockVSNetStyle,
  DebugEvalForm;

type
  TNppDockingForm1 = class(TNppDockingForm)
    ServerSocket1: TServerSocket;
    Memo1: TMemo;
    Button3: TButton;
    Button1: TButton;
    Edit1: TEdit;
    Button6: TButton;
    Button7: TButton;
    JvDockServer1: TJvDockServer;
    JvDockVSNetStyle1: TJvDockVSNetStyle;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ServerSocket1Accept(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1GetSocket(Sender: TObject; Socket: Integer;
      var ClientSocket: TServerClientWinSocket);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure Button2Click(Sender: TObject);
    procedure ServerSocket1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
    procedure sockDbgpStack(Sender:TDbgpWinSocket; Stack: TStackList);
    procedure sockDbgpInit(Sender:TDbgpWinSocket; init: TInit);
    procedure sockDbgpEval(Sender: TDbgpWinSocket; context: Integer; list: TPropertyItems);
    procedure sockDbgpContext(Sender: TDbgpWinSocket; context: Integer; list: TPropertyItems);

  public
    { Public declarations }
    sock: TDbgpWinSocket;
    DebugStackForm1: TDebugStackForm1;
    DebugVarForm1: TDebugVarForm1;
    DebugEvalForm1: TDebugEvalForm1;
    procedure GotoLineCB(filename: string; Lineno:Integer);
    procedure DoResume(runtype: TRun);
    procedure DoEval;
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
  self.DlgId := 0; // for now.. set this manually
  // laho bi tle zacel poslusat za dwell
  self.DebugStackForm1 := TDebugStackForm1.Create(self);
  //self.DebugStackForm1.Show;
  self.Npp.RegisterForm(TForm(self.DebugStackForm1));

  self.DebugVarForm1 := TDebugVarForm1.Create(self);
  //self.DebugVarForm1.Show;
  self.Npp.RegisterForm(TForm(self.DebugVarForm1));

  self.DebugStackForm1.ManualDock(self.JvDockServer1.BottomDockPanel);
  self.DebugVarForm1.ManualDock(self.JvDockServer1.BottomDockPanel);

  self.JvDockServer1.BottomDockPanel.ShowDockPanel(true, self.DebugStackForm1);
  self.JvDockServer1.BottomDockPanel.ShowDockPanel(true, self.DebugVarForm1);

end;

procedure TNppDockingForm1.Button1Click(Sender: TObject);
begin
  // tmp hack
  if Assigned(self.sock) then self.sock.SendText(self.Edit1.Text+#0);
end;

procedure TNppDockingForm1.ServerSocket1Accept(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  self.Show;
  self.Memo1.Lines.Add('Accept: '+Socket.RemoteAddress);
  //if Assigned(self.sock) then self.sock.GetFeature('support_async');
  if Assigned(self.sock) then
  begin
    //self.sock.SetFeature('notify_ok', '1');
    self.Memo1.Lines.Append(self.sock.debugdata);
  end;
end;

procedure TNppDockingForm1.ServerSocket1GetSocket(Sender: TObject;
  Socket: Integer; var ClientSocket: TServerClientWinSocket);
begin
  self.Memo1.Lines.Add('GetSocket');
  ClientSocket := TDbgpWinSocket.Create(Socket,Sender as TServerWinSocket);
  self.sock := ClientSocket as TDbgpWinSocket;
  self.sock.maps := (self.Npp as TDbgpNppPlugin).maps;
  self.sock.OnDbgpStack := self.sockDbgpStack;
  self.sock.OnDbgpInit := self.sockDbgpInit;
  self.sock.OnDbgpEval := self.sockDbgpEval;
  self.sock.OnDbgpContext := self.sockDbgpContext;
end;

procedure TNppDockingForm1.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var r: String;
begin
  r:=(Socket as TDbgpWinSocket).ReadDBGP;
  self.Memo1.Lines.Append(self.sock.debugdata);
  self.Memo1.Lines.Append('----');
  self.Memo1.Lines.Append(r);
  self.Memo1.Lines.Append('====');
end;

procedure TNppDockingForm1.Button2Click(Sender: TObject);
begin
  if Assigned(self.sock) then self.sock.Resume(Run);
end;

procedure TNppDockingForm1.ServerSocket1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  self.Memo1.Lines.Add('Disconnect: '+Socket.RemoteAddress);
  self.sock := nil;
  self.DebugStackForm1.ClearStack;
  //SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_SETMOUSEDWELLTIME, SC_TIME_FOREVER,0);
end;

procedure TNppDockingForm1.Button3Click(Sender: TObject);
var
  s: String;
  //f: TextFile;
  i: Integer;
begin
{
  // test
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
}

//  self.sock.GetStack;

  self.Npp.GetFileLine(s,i);
  self.sock.SetBreakpoint(s,i+1);
end;

procedure TNppDockingForm1.sockDbgpStack(Sender: TDbgpWinSocket; Stack: TStackList);
var
  i: Integer;
begin
  self.DebugStackForm1.SetStack(Stack);
  if (Length(Stack)>0) {and (Stack[0].stacktype = 'file')} then
    GotoLineCB(Stack[0].filename, Stack[0].lineno);

  // to bi moral it v on context ali kej tazga
  //SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_SETMOUSEDWELLTIME, 1000,0);
end;

procedure TNppDockingForm1.Button4Click(Sender: TObject);
begin
  self.sock.Resume(DbgpWinSocket.StepInto);
end;

procedure TNppDockingForm1.Button5Click(Sender: TObject);
begin
  self.sock.Resume(DbgpWinSocket.StepOver);
end;

procedure TNppDockingForm1.Button6Click(Sender: TObject);
begin
  self.sock.SendEval(self.Edit1.Text);
end;

procedure TNppDockingForm1.sockDbgpInit(Sender: TDbgpWinSocket; init: TInit);
begin
  self.Memo1.Lines.Add('OnInit');
end;

procedure TNppDockingForm1.Button7Click(Sender: TObject);
begin
  //DebugStackForm1 := TDebugStackForm1.Create(self);
  DebugStackForm1.Show;
  //self.DebugStackForm1.ManualDock(self);

  //self.DebugStackForm1.ManualDock(self.JvDockServer1.BottomDockPanel);
  //self.DebugVarForm1.ManualDock(self.JvDockServer1.BottomDockPanel);

  //ManualTabDock(self.JvDockServer1.BottomDockPanel,
  //      self.DebugStackForm1, self.DebugVarForm1);{: TJvDockTabHostForm;}



end;

// callback.. much less code than events.. lazy ass... q:)
procedure TNppDockingForm1.GotoLineCB(filename: string; Lineno: Integer);
begin
  self.Npp.DoOpen(filename, lineno-1);
  // test
  //SCI_MARKERDEFINE(int markerNumber, int markerSymbols)
  //SC_MARK_ARROW
  //SCI_MARKERSETFORE(int markerNumber, int colour)
  //SCI_MARKERSETBACK(int markerNumber, int colour)
  //SCI_MARKERADD(int line, int markerNumber)

//  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDEFINE, 5, SC_MARK_ARROW);
//  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERSETFORE, 5, $00ff00);
//  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERSETBACK, 5, $00ff00);
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEALL, 5, 0);
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERADD, lineno-1, 5);

end;

procedure TNppDockingForm1.sockDbgpContext(Sender: TDbgpWinSocket;
  context: Integer; list: TPropertyItems);
begin
  self.DebugVarForm1.SetVars(list);
end;

procedure TNppDockingForm1.sockDbgpEval(Sender: TDbgpWinSocket;
  context: Integer; list: TPropertyItems);
var
  x: TDebugVarForm1;
begin
  x:= TDebugVarForm1.Create(self);
  x.SetVars(list);
  x.Caption := 'Eval';
  x.Show;
end;

procedure TNppDockingForm1.DoResume(runtype: TRun);
begin
  if (Assigned(self.sock)) then self.sock.Resume(runtype);
end;

// show eval dlg and send eval cmd
procedure TNppDockingForm1.DoEval;
var
  r: Integer;
begin
  if (not Assigned(self.DebugEvalForm1)) then
  begin
    self.DebugEvalForm1 := TDebugEvalForm1.Create(self);
  end;
  r := self.DebugEvalForm1.ShowModal;
  if (r = mrOk) and Assigned(self.sock) then
  begin
    self.sock.SendEval(self.DebugEvalForm1.ComboBox1.Text);
  end;
end;

end.
