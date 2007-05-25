unit DbgpWinSocket;

interface

uses
  Windows, Messages, SysUtils, Classes, ScktComp, WinSock, XMLDoc, XMLDOM, XMLIntf,
  IdCoder3To4, StrUtils, Dialogs, Variants;

type
//  TDbgpWinSocket = class;
//  TDbgpRawEvent = procedure (Sender: TObject; Socket: TDbgpWinSocket; Data:String) of object;

  TDbgpWinSocket = class;
  TRun = (Run, StepInto, StepOver, StepOut, Stop, Detach);
  TMaps = array of TStringList;
  TStackItem = record
    level: Integer;
    stacktype: String;
    filename: String;
    lineno: Integer;
    where: String;
    {...}
  end;
  PStackItem = ^TStackItem;
  TInit = record
    filename: String;
    language: String;
    appid: String;
    idekey: String;
  end;
  PPropertyItems = ^TPropertyItems;
  PPropertyItem = ^TPropertyItem;
  TPropertyItem = record
    name: String;
    fullname: String;
    datatype: String;
    classname: String;
    constant: Boolean;
    haschildren: Boolean;
    size: String;
    page: String;
    pagesize: String;
    address: String;
    key: String;
    numchildren: String;
    data: String; // actual decoded data;
    children: PPropertyItems;
  end;
  TPropertyItems = array of TPropertyItem;
//  TBreak = ();
  TStackList = array of TStackItem;
  TStackCB = procedure(Sender: TDbgpWinSocket; Stack: TStackList) of Object;
  TBreakCB = procedure(Sender: TDbgpWinSocket{; Break: TBreak}) of Object;
  TStreamCB = procedure(Sender: TDbgpWinSocket; stream, data:String) of Object;
  TInitCB = procedure(Sender: TDbgpWinSocket; init: TInit) of Object;
  TVarsCB = procedure(Sender: TDbgpWinSocket; context: Integer; list: TPropertyItems) of Object;

  TDbgpWinSocket = class(TServerClientWinSocket)
  private
    { Private declarations }
    xml: IXMLDocument;
    buffer: String;
  protected
    { Protected declarations }
    FOnDbgpStack: TStackCB;
    FOnDbgpBreak: TBreakCB;
    FOnDbgpStream: TStreamCB;
    FOnDbgpInit: TInitCB;
    FOnDbgpEval: TVarsCB;
    FOnDbgpContext: TVarsCB;
    function MapRemoteToLocal(Remote:String): String;
    function MapLocalToRemote(Local:String): String;
    function ProcessInit: String;
    function ProcessStream: String;
    function ProcessResponse_stack: String;
    function ProcessResponse_eval: String;
    function ProcessResponse_context_get: String;
    function ProcessResponse: String;

    procedure ProcessProperty(varxml:IXMLNodeList; var list:TPropertyItems);
  public
    { Public declarations }
    TransID: Integer;
    maps: TMaps;
    debugdata: String;
    stack: TStackList;
    function ReadDBGP: String;
    procedure GetFeature(FeatureName: String);
    procedure SetFeature(FeatureName: String; Value: String);
    procedure GetStack;
    procedure SetStream(Str: string; Mode: Integer);
    procedure SetBreakpoint(Filename:String; Line:Integer);

    procedure SetBreakpointLine(filename: String; Line: Integer);

    procedure Resume(runtype: TRun);
    procedure SendEval(data:String);
    procedure SendCommand(Cmd: String; Args: String; Base64:String); overload;
    procedure SendCommand(Cmd: String; Args: String); overload;
    procedure SendCommand(Cmd: String); overload;
  published
    { Published declarations }
    property OnDbgpStack: TStackCB read FOnDbgpStack write FOnDbgpStack;
    property OnDbgpBreak: TBreakCB read FOnDbgpBreak write FOnDbgpBreak;
    property OnDbgpStream: TStreamCB read FOnDbgpStream write FOnDbgpStream;
    property OnDbgpInit: TInitCB read FOnDbgpInit write FOnDbgpInit;
    property OnDbgpEval: TVarsCB read FOnDbgpEval write FOnDbgpEval;
    property OnDbgpContext: TVarsCB read FOnDbgpContext write FOnDbgpContext;
  end;

implementation

const
  //Codes64 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';
  Codes64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function Encode64(S: string): string;
var
  i: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
begin
  Result := '';
  a := 0;
  b := 0;
  for i := 1 to Length(s) do
  begin
    x := Ord(s[i]);
    b := b * 256 + x;
    a := a + 8;
    while a >= 6 do
    begin
      a := a - 6;
      x := b div (1 shl a);
      b := b mod (1 shl a);
      Result := Result + Codes64[x + 1];
    end;
  end;
  if a > 0 then
  begin
    x := b shl (6 - a);
    Result := Result + Codes64[x + 1];
  end;
end;

function Decode64(S: string): string;
var
  i: Integer;
  a: Integer;
  x: Integer;
  b: Integer;
begin
  Result := '';
  a := 0;
  b := 0;
  for i := 1 to Length(s) do
  begin
    x := Pos(s[i], codes64) - 1;
    if x >= 0 then
    begin
      b := b * 64 + x;
      a := a + 6;
      if a >= 8 then
      begin
        a := a - 8;
        x := b shr a;
        b := b mod (1 shl a);
        x := x mod 256;
        Result := Result + chr(x);
      end;
    end
    else
      Exit;
  end;
end;

{ TDbgpWinSocket }

 // predvidevamo praviln XML
procedure TDbgpWinSocket.GetFeature(FeatureName: String);
begin
  self.SendCommand('feture-get','-n '+FeatureName);
  inc(self.TransID);
end;

{ Maps a remote filename 'file://..' to a local file 'd:\xxx...' }
procedure TDbgpWinSocket.GetStack;
begin
  self.SendCommand('stack_get');
end;

function TDbgpWinSocket.MapLocalToRemote(Local: String): String;
var
  i: integer;
  r: string;
begin
  Result := 'file://'+Local;
  if (not Assigned(self.maps)) then
  begin
    exit;
  end;
  for i:=0 to Length(self.maps) do
  begin
    //if (self.maps[i][0] == 'remote ip') then continue;
    if (self.maps[i][2] = LeftStr(Local, Length(self.maps[i][2]))) then
    begin
      r := 'file://'+self.maps[i][1];
      r := r + Copy(Local, Length(self.maps[i][2])+1, MaxInt);
      r := StringReplace(r, '\', '/', [rfReplaceAll]);
      Result := r;
      exit;
    end;
  end;
end;

function TDbgpWinSocket.MapRemoteToLocal(Remote: String): String;
var
  i: integer;
  r: string;
begin
  if (LeftStr(Remote, 7)='file://') then Remote := Copy(Remote,8,MaxInt);
  Result := Remote;

  if (not Assigned(self.maps)) then
  begin
    exit;
  end;
  for i:=0 to Length(self.maps) do
  begin
    //if (self.maps[i][0] == 'remote ip') then continue;
    if (self.maps[i][1] = LeftStr(Remote, Length(self.maps[i][1]))) then
    begin
      r := self.maps[i][2];
      r := r + Copy(Remote, Length(self.maps[i][1])+1, MaxInt);
      r := StringReplace(r, '/', '\', [rfReplaceAll]);
      Result := r;
      exit;
    end;
  end;
end;

{ procesiramo init}
function TDbgpWinSocket.ProcessInit: String;
var
  init: TInit;
begin
{
Data(404): <?xml version="1.0" encoding="iso-8859-1"?>
<init
        fileuri="file:///var/www/spike.krneki.org/dbgp/phpinfo.php"
        language="PHP"
        protocol_version="1.0"
        appid="13462"
        idekey="session_name">

<engine version="2.0.0RC3">
<![CDATA[Xdebug]]>
</engine><author>
<![CDATA[Derick Rethans]]></author>
<url>
<![CDATA[http://xdebug.org]]></url><copyright><![CDATA[Copyright (c) 2002-2007 by Derick Rethans]]></copyright>

</init>
}
  // callback?
  init.filename := self.MapRemoteToLocal(self.xml.ChildNodes[1].Attributes['fileuri']);
  init.language := self.xml.ChildNodes[1].Attributes['language'];
  init.appid := self.xml.ChildNodes[1].Attributes['appid'];
  init.idekey := self.xml.ChildNodes[1].Attributes['idekey'];

  if (Assigned(self.FOnDbgpInit)) then self.FOnDbgpInit(self, init);

  Result := 'init file: '+self.MapRemoteToLocal(self.xml.ChildNodes[1].Attributes['fileuri']);
end;

{ splisna funkcija za rekurzivno procesiranje varov}
procedure TDbgpWinSocket.ProcessProperty(varxml: IXMLNodeList;
  var list: TPropertyItems);
var
  i: Integer;
  c: Integer;
  x: IXMLNode;
begin
(*
Recv(672): <?xml version="1.0" encoding="iso-8859-1"?>
<response command="context_get" transaction_id="778">

<property name="omg" fullname="$omg" address="-1215305772" type="string" size="3" encoding="base64">
<![CDATA[ZGRz]]>
</property>
<property name="a" fullname="$a" address="-1215305268" type="array" children="1" numchildren="2">
        <property name="2" fullname="$a[2]" address="-1215298680" type="string" size="3" encoding="base64">
                <![CDATA[ZGRk]]>
        </property>
        <property name="f" fullname="$a[&apos;f&apos;]" address="-1215305388" type="string" size="1" encoding="base64">
                <![CDATA[Zw==]]>
        </property>
</property>
<property name="x" fullname="$x" type="uninitialized">
</property>

</response>
*)
  SetLength(list, varxml.Count);

  for i:=0 to varxml.Count-1 do
  begin
    x := varxml[i];
    Assert((x.NodeName = 'property'),'Property node actually not "property"!!');

    list[i].name := x.Attributes['name'];
    if (list[i].name = '') then list[i].name := '?';
    list[i].fullname := x.Attributes['fullname'];
    if (list[i].fullname = '') then list[i].fullname := list[i].name;
    list[i].datatype := x.Attributes['type'];
    list[i].classname := x.Attributes['classname'];
    list[i].constant := (x.Attributes['constant'] = '1');
    list[i].haschildren := (x.Attributes['children'] = '1');
    list[i].size := x.Attributes['size'];
    list[i].page := x.Attributes['page'];
    list[i].pagesize := x.Attributes['pagesize'];
    list[i].address := x.Attributes['address'];
    list[i].key := x.Attributes['key'];
    list[i].numchildren := x.Attributes['numchildren'];
    list[i].data := '';
    if (x.Attributes['encoding'] = 'base64') then
      if ((VarType(x.ChildNodes[0].NodeValue) and VarTypeMask) = varOleStr) then
        list[i].data := Decode64(x.ChildNodes[0].NodeValue);
    //else
      //list[i].data := x.NodeValue;
    list[i].children := nil;
    if (list[i].haschildren) then
    begin
      New(list[i].children); // where to dispose?
      self.ProcessProperty(x.ChildNodes, list[i].children^);
    end;
    // todo process children.. recurs
  end;

end;

function TDbgpWinSocket.ProcessResponse: String;
begin
  // is response.status=break?
  {Recv(131): <?xml version="1.0" encoding="iso-8859-1"?>
<response command="step_over" transaction_id="0" status="break" reason="ok"></response>
----}
  if (self.xml.ChildNodes[1].Attributes['status'] = 'break') then
  begin
    if (Assigned(self.FOnDbgpBreak)) then
      self.FOnDbgpBreak(self)
    else
      self.GetStack;
  end
  else
  if (self.xml.ChildNodes[1].Attributes['status'] = 'stopped') then
  begin
    if (Assigned(self.FOnDbgpBreak)) then
    begin
      // when finished...
    end;
  end;

end;

procedure FreePropertyItems(list: TPropertyItems);
var
  i: Integer;
begin
  for i:=0 to Length(list)-1 do
  begin
    if (list[i].children <> nil) then
    begin
      FreePropertyItems(list[i].children^);
      SetLength(list[i].children^, 0);
      Dispose(list[i].children);
    end;
  end;
end;

function TDbgpWinSocket.ProcessResponse_context_get: String;
var
  list: TPropertyItems;
begin
  //process context
  self.ProcessProperty(self.xml.ChildNodes[1].ChildNodes, list);
  if (Assigned(self.FOnDbgpContext)) then
    self.FOnDbgpContext(self,0,list);
  //free data
  FreePropertyItems(list);
  Result := '';
end;


function TDbgpWinSocket.ProcessResponse_eval: String;
var
  t, r, data: String;
  list: TPropertyItems;
begin
  self.ProcessProperty(self.xml.ChildNodes[1].ChildNodes, list);
  if (Assigned(self.FOnDbgpEval)) then
    self.FOnDbgpEval(self,-1,list);
  FreePropertyItems(list);
  Result := '';
end;

function TDbgpWinSocket.ProcessResponse_stack: String;
var
  i: integer;
  x: IXMLNode;
  r: String;
  stack: TStackList;
begin
//    res := self.xml.ChildNodes[1].NodeName;
  r := '';
  Result := '';
  if (not self.xml.ChildNodes[1].HasChildNodes) then exit; // bad?
  x := nil;
  if (self.xml.ChildNodes[1].HasChildNodes) then
    x := self.xml.ChildNodes[1].ChildNodes[0];
  i := 0;
  while (x <> nil) do
  begin
    inc(i);
    SetLength(stack, i);
    stack[i-1].level := StrToInt(x.Attributes['level']);
    stack[i-1].stacktype := x.Attributes['type'];
    stack[i-1].filename := self.MapRemoteToLocal(x.Attributes['filename']);
    stack[i-1].lineno := StrToInt(x.Attributes['lineno']);
    stack[i-1].where := x.Attributes['where'];
    stack[i-1].stacktype := x.Attributes['type'];
    x:= x.NextSibling;
  end;
  Result := r;

  self.stack := stack;
  if (Assigned(self.FOnDbgpStack)) then self.FOnDbgpStack(self, stack);

end;

function TDbgpWinSocket.ProcessStream: String;
var
  str,data: String;
begin
{
<?xml version="1.0" encoding="iso-8859-1"?>
<stream type="stdout" encoding="base64">
        <![CDATA[U2V0LUNvb2tpZTogWERFQlVHX1NFU1NJT049c2Vzc2lvbl9uYW1lOyBleHBpcmVzPVN1biwgMTMtTWF5LTIwMDcgMTk6MDA6MzEgR01UOyBwYXRoPS8=]]>
</stream>
}
  str := self.xml.ChildNodes[1].Attributes['type'];
  data := self.xml.ChildNodes[1].ChildNodes[0].NodeValue;

  if (self.xml.ChildNodes[1].Attributes['encoding'] = 'base64') then
  begin
    data := Decode64(data);
  end;

  if (Assigned(self.FOnDbgpStream)) then self.FOnDbgpStream(self, str, data);

  Result := 'Stream('+str+'): '+data;
end;

function TDbgpWinSocket.ReadDBGP: String;
var
 res,s,r,s2:String;
 c:char;
 len:Integer;
begin
  r := '';
  s := self.ReceiveText;

  len := Length(s);
  c := s[len];

  s2 := c;
  s2 := '';

  if (s[Length(s)] <> #0) then
  begin
    self.buffer := self.buffer + s;
    exit;
  end;

  s := self.buffer + s;


  len := StrToInt(s);
  if (Length(s)<len) then
  begin
    // v najvec primerih to pomeni razbit response
    self.debugdata := 'Error in len: '+IntToStr(Length(s))+'<'+IntToStr(len);
    exit;
  end;
  s2 := Copy(s, StrLen(PChar(s))+2, len);
  if (Length(s2) < 200) then self.debugdata := 'Recv('+IntToStr(len)+'): '+s2;

  self.xml := TXMLDocument.Create(nil);
  self.xml.Options := [];
  self.xml.XML.Add(s2);
  self.xml.Active := true;


  res := self.xml.ChildNodes[1].NodeName;
  if (res = 'init') then
  begin
    r := self.ProcessInit;
  end
  else if (res = 'response') then
  begin
    if (self.xml.ChildNodes[1].Attributes['command'] = 'stack_get') then
    r := self.ProcessResponse_stack
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'eval') then
    r := self.ProcessResponse_eval
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'context_get') then
    r := self.ProcessResponse_context_get
    else
    r := self.ProcessResponse;
  end
  else if (res = 'notify') then
  begin
  end
  else if (res = 'stream') then
  begin
    r := self.ProcessStream;
  end;

  Result := r;

  self.xml.Active := false;
  self.xml := nil;
  self.buffer := '';
end;

procedure TDbgpWinSocket.Resume(runtype: TRun);
var
  cmd: String;
begin
  cmd := '';
  case runtype of
  Run: cmd := 'run';
  StepInto: cmd := 'step_into';
  StepOver: cmd := 'step_over';
  StepOut: cmd := 'step_out';
  Stop: cmd := 'stop';
  end;
  if (cmd = '') then exit;
  self.SendCommand(cmd);

end;

procedure TDbgpWinSocket.SendCommand(Cmd, Args, Base64: String);
var d:String;
begin
  if (not self.Connected) then exit;

  d := Cmd + ' -i '+IntToStr(self.TransID);
  inc(self.TransID);
  if (Args <> '') then
    d := d + ' '+Args;
  if (Base64 <> '') then
    d := d + ' -- '+Base64Encode(Base64);
  self.SendText(d+#0);
  self.debugdata := 'Send: '+d;
end;

procedure TDbgpWinSocket.SendCommand(Cmd, Args: String);
begin
  self.SendCommand(Cmd, Args, '');
end;

procedure TDbgpWinSocket.SendCommand(Cmd: String);
begin
  self.SendCommand(Cmd, '', '');
end;

{ Set a line breakpoint }
procedure TDbgpWinSocket.SendEval(data: String);
begin
  self.SendCommand('eval','',data);
end;

procedure TDbgpWinSocket.SetBreakpoint(Filename: String; Line: Integer);
begin
  self.SendCommand('breakpoint_set', '-t line -f '+self.MapLocalToRemote(Filename)+
    ' -n '+IntToStr(Line));
end;

procedure TDbgpWinSocket.SetBreakpointLine(filename: String;
  Line: Integer);
begin
  self.SendCommand('breakpoint_set', '-t line -f '+self.MapLocalToRemote(filename)+
                        ' -n '+IntToStr(Line) );
end;

procedure TDbgpWinSocket.SetFeature(FeatureName, Value: String);
begin
  self.SendCommand('feature_set','-n '+FeatureName+' -v '+Value);
end;


{ put stdout or stderr and 0,1,2 (disaled,copy,redirect) }
procedure TDbgpWinSocket.SetStream(Str: string; Mode: Integer);
begin
  self.SendCommand(Str,'-c '+IntToStr(Mode));
end;

end.
