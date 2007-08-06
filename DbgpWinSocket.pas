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

unit DbgpWinSocket;

interface

uses
  Windows, Messages, SysUtils, Classes, ScktComp, WinSock, XMLDoc, XMLDOM, XMLIntf,
  {IdCoder3To4, }StrUtils, Dialogs, Variants, Base64, IdGlobal;

type
//  TDbgpWinSocket = class;
//  TDbgpRawEvent = procedure (Sender: TObject; Socket: TDbgpWinSocket; Data:String) of object;

  TDbgpState = (dsStarting, dsStopping, dsStopped, dsRunning, dsBreak);
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
    server: String;
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
  TBreakpointType = (btLine, btCall, btReturn, btException, btConditional, btWatch);
  PBreakpoint = ^TBreakpoint;
  TBreakpoint = record
    id: string;
    breakpointtype: TBreakpointType;
    filename: string;
    lineno: integer;
    state: boolean;
    functionname: string;
    classname: string;
    temporary: boolean;
    hit_count: integer;
    hit_value: integer;
    hit_condition: string; {?}
    exception: string;
    expression: string;
  end;
  TBreakpoints = array of TBreakpoint;
//  TBreak = ();
  TStackList = array of TStackItem;
  TStackCB = procedure(Sender: TDbgpWinSocket; Stack: TStackList) of Object;
  TBreakCB = procedure(Sender: TDbgpWinSocket; Stopped: Boolean) of Object;
  TStreamCB = procedure(Sender: TDbgpWinSocket; stream, data:String) of Object;
  TInitCB = procedure(Sender: TDbgpWinSocket; init: TInit) of Object;
  TVarsCB = procedure(Sender: TDbgpWinSocket; context: Integer; list: TPropertyItems) of Object;
  TBreakpointsCB = procedure(Sender: TDbgpWinSocket; breakpoints: TBreakpoints) of Object;

  TDbgpWinSocket = class(TServerClientWinSocket)
  private
    { Private declarations }
    xml: IXMLDocument;
    buffer: String;
    TransID: Integer;
    lastEval: String;
    init: TInit;
    remote_unix: boolean;
    last_source_request: string;
    source_files: TStringList;
  protected
    { Protected declarations }
    FOnDbgpStack: TStackCB;
    FOnDbgpBreak: TBreakCB;
    FOnDbgpStream: TStreamCB;
    FOnDbgpInit: TInitCB;
    FOnDbgpEval: TVarsCB;
    FOnDbgpContext: TVarsCB;
    FOnDbgpBreakpoints: TBreakpointsCB;
    function MapRemoteToLocal(Remote:String): String;
    function MapLocalToRemote(Local:String): String;
    function MapSourceToLocal(Source:String): String;
    function MapLocalToSource(Local:String): String;
    function ProcessInit: String;
    function ProcessStream: String;
    function ProcessResponse_stack: String;
    function ProcessResponse_eval: String;
    function ProcessResponse_context_get: String;
    function ProcessResponse_breakpoint_set: String;
    function ProcessResponse_breakpoint_list: String;
    function ProcessResponse_source: String;
    function ProcessResponse: String;

    procedure ProcessProperty(varxml:IXMLNodeList; var list:TPropertyItems); overload;
    procedure ProcessProperty(varxml:IXMLNodeList; var list:TPropertyItems; ParentItem: PPropertyItem); overload;
  public
    { Public declarations }
    maps: TMaps;
    use_source: boolean;
    debugdata: TStringList;
    stack: TStackList;
    Transaction_id: String;
    constructor Create(Socket: TSocket; ServerWinSocket: TServerWinSocket);
    destructor Destroy; override;
    function ReadDBGP: String;
    procedure GetFeature(FeatureName: String);
    procedure SetFeature(FeatureName: String; Value: String);
    procedure GetStack;
    procedure GetContext(Context:integer); overload;
    procedure GetContext(Context:integer; Depth:Integer); overload;
    procedure GetBreakpoints;
    procedure SetStream(Str: string; Mode: Integer);
    procedure SetBreakpoint(Filename: String; Line:Integer); overload;
    procedure SetBreakpoint(bp: TBreakpoint); overload;
    procedure UpdateBreakpoint(bp: TBreakpoint);
    procedure RemoveBreakpoint(bp: TBreakpoint);
    procedure GetSource(filename: String);
    procedure Resume(runtype: TRun);
    procedure SendEval(data:String);
    function SendCommand(Cmd: String; Args: String; Base64:String): Integer; overload;
    function SendCommand(Cmd: String; Args: String): Integer; overload;
    function SendCommand(Cmd: String): Integer; overload;
  published
    { Published declarations }
    property OnDbgpStack: TStackCB read FOnDbgpStack write FOnDbgpStack;
    property OnDbgpBreak: TBreakCB read FOnDbgpBreak write FOnDbgpBreak;
    property OnDbgpStream: TStreamCB read FOnDbgpStream write FOnDbgpStream;
    property OnDbgpInit: TInitCB read FOnDbgpInit write FOnDbgpInit;
    property OnDbgpEval: TVarsCB read FOnDbgpEval write FOnDbgpEval;
    property OnDbgpContext: TVarsCB read FOnDbgpContext write FOnDbgpContext;
    property OnDbgpBreakpoints: TBreakpointsCB read FOnDbgpBreakpoints write FOnDbgpBreakpoints;
  end;

implementation

{ TDbgpWinSocket }

 // predvidevamo praviln XML
constructor TDbgpWinSocket.Create(Socket: TSocket;
  ServerWinSocket: TServerWinSocket);
begin
  inherited;
  self.TransID := 1; // internal counter
  self.debugdata := TStringList.Create;
  self.Transaction_id := ''; // return transaction
  self.remote_unix := true;
  self.source_files := TStringList.Create;
  self.source_files.CaseSensitive := true;
end;
destructor TDbgpWinSocket.Destroy;
var
  i: integer;
begin
  self.debugdata.Free;
  // delete the shit
  for i := 0 to self.source_files.Count-1 do
  begin
    FileSetReadOnly(self.MapSourceToLocal(self.source_files[i]),false);
    DeleteFile(self.MapSourceToLocal(self.source_files[i]));
  end;
  self.source_files.Free;
  inherited;
end;

procedure TDbgpWinSocket.GetContext(Context: integer);
begin
  self.SendCommand('context_get', '-c '+IntToStr(Context)); // todo depth
end;

procedure TDbgpWinSocket.GetBreakpoints;
begin
  self.SendCommand('breakpoint_list');
end;

procedure TDbgpWinSocket.GetContext(Context: integer; Depth: integer);
begin
  self.SendCommand('context_get', '-c '+IntToStr(Context)+' -d '+IntToStr(Depth)); // todo depth
end;

procedure TDbgpWinSocket.GetFeature(FeatureName: String);
begin
  self.SendCommand('feture-get','-n '+FeatureName);
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
  r := self.MapLocalToSource(Local);
  if (r <> '') then
  begin
    Result := r;
    exit;
  end;
  Result := 'file:///'+URLEncode(Local);
  if (not Assigned(self.maps)) then
  begin
    exit;
  end;
  for i:=0 to Length(self.maps)-1 do
  begin
    if (self.maps[i][0] <> '') and (self.maps[i][0] <> self.init.server) then continue;
    if (self.maps[i][1] <> '') and (self.maps[i][1] <> self.init.idekey) then continue;
    if (self.maps[i][3] = LeftStr(Local, Length(self.maps[i][3]))) then
    begin
      r := self.maps[i][2] + Copy(Local, Length(self.maps[i][3])+1, MaxInt);
      if (self.remote_unix) then
      begin
        r := StringReplace(r, '\', '/', [rfReplaceAll]);
        Result := 'file://' + URLEncode(r);
      end
      else
      begin
        Result := 'file:///' + URLEncode(r);
      end;
      exit;
    end;
  end;
  ShowMessage('Unable to map filename: '+Local+' (ip: '+self.init.server+' idekey: '+self.init.idekey+') unix: '+BoolToStr(self.remote_unix,true));
end;

function TDbgpWinSocket.MapRemoteToLocal(Remote: String): String;
var
  i: integer;
  r: string;
  Remote2: string;
begin
  Remote := URLDecode(Remote);
  Remote2 := Remote;
  if (LeftStr(Remote, 5)='dbgp:') or (self.use_source) then
  begin
    r := self.MapSourceToLocal(Remote);
    Result := r;
    exit;
  end;
  if (LeftStr(Remote, 8)='file:///') and (Pos(':',Remote)=10) then
  begin
    self.remote_unix := false;
    Remote := Copy(Remote,9,MaxInt);
  end
  else if (LeftStr(Remote, 7)='file://') then
  begin
    Remote := Copy(Remote,8,MaxInt);
  end;
  Result := Remote;

  if (not Assigned(self.maps)) then
  begin
    exit;
  end;
  for i:=0 to Length(self.maps)-1 do
  begin
    if (self.maps[i][0] <> '') and (self.maps[i][0] <> self.init.server) then continue;
    if (self.maps[i][1] <> '') and (self.maps[i][1] <> self.init.idekey) then continue;
    if (self.maps[i][2] = LeftStr(Remote, Length(self.maps[i][2]))) then
    begin
      r := self.maps[i][3];
      if (r = 'DBGP:') then
      begin
        Result := self.MapSourceToLocal(Remote2);
        exit;
      end;
      r := r + Copy(Remote, Length(self.maps[i][2])+1, MaxInt);
      if (self.remote_unix) then r := StringReplace(r, '/', '\', [rfReplaceAll]);
      Result := r;
      exit;
    end;
  end;
  // throw exception??
  //ShowMessage('Unable to map filename: '+Remote+' (ip: '+self.init.server+' idekey: '+self.init.idekey+') unix: '+BoolToStr(self.remote_unix,true));
  // fallback to source
  Result := self.MapSourceToLocal(Remote2);
end;

{ mappings for source command }
function TDbgpWinSocket.MapLocalToSource(Local: String): String;
var
  i: integer;
begin
  Result := '';
  for i:=0 to self.source_files.Count-1 do
  begin
    if (Local = self.MapSourceToLocal(self.source_files[i])) then
    begin
      Result := self.source_files[i];
      exit;
    end;
  end;
end;

function TDbgpWinSocket.MapSourceToLocal(Source: String): String;
var
  s: String;
  source2: String;
begin
  Result := '';
  s := '';
  SetLength(s, 200);
  GetTempPath(200, PChar(s));
  SetLength(s, StrLen(PChar(s)));
  source2 := UrlEncode(Source);
  source2 := StringReplace(source2, '/', '%2f', [rfReplaceAll]);
  source2 := StringReplace(source2, ':', '%3a', [rfReplaceAll]);
  s := s + 'dbgp_' + source2;
  if (self.source_files.IndexOf(Source)=-1) then
  begin
    self.source_files.Add(Source);
    self.GetSource(Source);
  end;
  Result := s;
end;

{ procesiramo init}
function TDbgpWinSocket.ProcessInit: String;
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
  self.init.language := self.xml.ChildNodes[1].Attributes['language'];
  self.init.appid := self.xml.ChildNodes[1].Attributes['appid'];
  self.init.idekey := self.xml.ChildNodes[1].Attributes['idekey'];
  self.init.server := self.xml.ChildNodes[1].Attributes['proxied'];
  if (self.init.server = '') then self.init.server := self.RemoteAddress;
  self.init := init; // need idekey before we can translate files...
  self.init.filename := self.MapRemoteToLocal(self.xml.ChildNodes[1].Attributes['fileuri']);

  if (Assigned(self.FOnDbgpInit)) then self.FOnDbgpInit(self, self.init);
end;

{ splisna funkcija za rekurzivno procesiranje varov}
procedure TDbgpWinSocket.ProcessProperty(varxml: IXMLNodeList;
  var list: TPropertyItems);
begin
  self.ProcessProperty(varxml, list, nil);
end;

procedure TDbgpWinSocket.ProcessProperty(varxml: IXMLNodeList;
  var list: TPropertyItems; ParentItem: PPropertyItem);
var
  i: Integer;
//  c: Integer;
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
    //Assert((x.NodeName = 'property'),'Property node actually not "property"!!')
    if (x.NodeName <> 'property') then
    begin
      ShowMessage('Property node actually not "property"!!');
      exit;
    end;

    list[i].name := x.Attributes['name'];
    if (list[i].name = '') then list[i].name := '?';
    list[i].fullname := x.Attributes['fullname'];
    //if (list[i].fullname = '') then list[i].fullname := list[i].name;
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

    // try to compensate for missing fullname attr...
    if (list[i].fullname = '') and (ParentItem <> nil) then
    begin
      if (ParentItem^.datatype = 'array') then list[i].fullname := ParentItem^.fullname+'["'+list[i].name+'"]';
      if (ParentItem^.datatype = 'object') then list[i].fullname := ParentItem^.fullname+'->'+list[i].name;
    end
    else if (list[i].fullname = '') and (self.lastEval <> '') and (self.lastEval[1] = '$') then
    begin
      list[i].fullname := self.lastEval;
    end;

    if (x.HasChildNodes) and (x.ChildNodes[0].NodeType in [ntText, ntCData]) then
    begin
      if (x.Attributes['encoding'] = 'base64') then
      begin
        list[i].data := Decode64(x.ChildNodes[0].Text);
      end
      else
      begin
        list[i].data := x.ChildNodes[0].Text;
      end;
    end;

    list[i].children := nil;
    if (list[i].haschildren) then
    begin
      New(list[i].children); // where to dispose?
      self.ProcessProperty(x.ChildNodes, list[i].children^, @list[i]);
    end;
  end;
end;

// Predvsem reakcije na status.. break in stop
function TDbgpWinSocket.ProcessResponse: String;
begin
  // is response.status=break?
  {Recv(131): <?xml version="1.0" encoding="iso-8859-1"?>
<response command="step_over" transaction_id="0" status="break" reason="ok"></response>
----}
  if (self.xml.ChildNodes[1].Attributes['status'] = 'break') then
  begin
    if (Assigned(self.FOnDbgpBreak)) then
      self.FOnDbgpBreak(self, false)
    else
      self.GetStack;
  end
  else
  if (self.xml.ChildNodes[1].Attributes['status'] = 'stopped') then
  begin
    if (Assigned(self.FOnDbgpBreak)) then
    begin
      // when finished...
      // send one last run so we can die?
    if (Assigned(self.FOnDbgpBreak)) then
      self.FOnDbgpBreak(self, true);
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

function TDbgpWinSocket.ProcessResponse_breakpoint_list: String;
var
  varxml: IXMLNodeList;
  i: integer;
  bps: TBreakpoints;
begin
{
<response xmlns="urn:debugger_protocol_v1" xmlns:xdebug="http://xdebug.org/dbgp/xdebug" command="breakpoint_list" transaction_id="33">
	<breakpoint type="line" filename="file:///home/zobo/stuff/test1.php" lineno="12" state="enabled" hit_count="0" hit_value="0" id="27980007"></breakpoint>
	<breakpoint type="return" function="phpinfo" state="enabled" hit_count="0" hit_value="0" id="27980009"></breakpoint>
	<breakpoint type="line" filename="file:///home/zobo/stuff/test1.php" lineno="14" state="enabled" hit_count="0" hit_value="0" id="27980008"></breakpoint>
	<breakpoint type="call" function="test2" class="test" state="enabled" hit_count="0" hit_value="0" id="27990002"></breakpoint>
</response>
}
  varxml := self.xml.ChildNodes[1].ChildNodes;
  if (varxml = nil) then exit;
  SetLength(bps, varxml.Count);
  for i:=0 to varxml.Count-1 do
  begin
    bps[i].id := varxml[i].Attributes['id'];
    if (varxml[i].Attributes['type'] = 'line') then bps[i].breakpointtype := btLine;
    if (varxml[i].Attributes['type'] = 'call') then bps[i].breakpointtype := btCall;
    if (varxml[i].Attributes['type'] = 'return') then bps[i].breakpointtype := btReturn;
    if (varxml[i].Attributes['type'] = 'exception') then bps[i].breakpointtype := btException;
    if (varxml[i].Attributes['type'] = 'conditional') then bps[i].breakpointtype := btConditional;
    if (varxml[i].Attributes['type'] = 'watch') then bps[i].breakpointtype := btWatch;
    bps[i].filename := '';
    if (varxml[i].Attributes['filename'] <> '') then
      bps[i].filename := self.MapRemoteToLocal(varxml[i].Attributes['filename']);
    try bps[i].lineno := StrToInt(varxml[i].Attributes['lineno']); except on EConvertError do bps[i].lineno := 0; end;
    bps[i].state := (varxml[i].Attributes['state']='enabled');
    bps[i].functionname := varxml[i].Attributes['function'];
    bps[i].classname := varxml[i].Attributes['class'];
    bps[i].temporary := (varxml[i].Attributes['temporary'] = '1');
    try bps[i].hit_count := StrToInt(varxml[i].Attributes['hit_count']); except on EConvertError do bps[i].hit_count := 0; end;
    try bps[i].hit_value := StrToInt(varxml[i].Attributes['hit_value']); except on EConvertError do bps[i].hit_value := 0; end;
    bps[i].hit_condition := varxml[i].Attributes['hit_condition'];
    if (bps[i].hit_condition = '') then bps[i].hit_condition := '>=';
    bps[i].exception := varxml[i].Attributes['exception'];
    { unimplemented }
    if (varxml[i].HasChildNodes and (varxml[i].ChildNodes[1].NodeName = 'expression') and (varxml[i].ChildNodes[1].ChildNodes[1] <> nil)) then
      bps[i].expression := varxml[i].ChildNodes[1].ChildNodes[1].Text;
  end;
  if (Assigned(self.FOnDbgpBreakpoints)) then
    self.FOnDbgpBreakpoints(self,bps);
end;

function TDbgpWinSocket.ProcessResponse_breakpoint_set: String;
var
  id: String;
begin
  id := self.xml.ChildNodes[1].Attributes['id'];
end;

function TDbgpWinSocket.ProcessResponse_context_get: String;
var
  list: TPropertyItems;
  context: Integer;
begin
  //process context
  if (self.xml.ChildNodes[1].HasChildNodes) and (self.xml.ChildNodes[1].ChildNodes[0].NodeName = 'error') then
  begin
    ShowMessage('Error ('+self.xml.ChildNodes[1].ChildNodes[0].Attributes['code']+'): '+
      self.xml.ChildNodes[1].ChildNodes[0].ChildNodes[0].ChildNodes[0].NodeValue);
    exit;
  end;

  self.ProcessProperty(self.xml.ChildNodes[1].ChildNodes, list);
  context := 0;
  try
    context := StrToInt(self.xml.ChildNodes[1].Attributes['context']);
  except
  end;
  if (Assigned(self.FOnDbgpContext)) then
    self.FOnDbgpContext(self,context,list);
  //free data
  FreePropertyItems(list);
  //Result := '';
end;


function TDbgpWinSocket.ProcessResponse_eval: String;
var
  list: TPropertyItems;
begin
  self.ProcessProperty(self.xml.ChildNodes[1].ChildNodes, list);
  if (Length(list)>0) and (self.lastEval <> '') then
    list[0].fullname := self.lastEval;
  if (Assigned(self.FOnDbgpEval)) then
    self.FOnDbgpEval(self,-1,list);
  FreePropertyItems(list);
  //Result := '';
end;

function TDbgpWinSocket.ProcessResponse_stack: String;
var
  i: integer;
  x: IXMLNode;
  r: String;
  stack: TStackList;
begin
  r := '';
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
  //Result := r;

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

  //Result := 'Stream('+str+'): '+data;
end;

function TDbgpWinSocket.ProcessResponse_source: String;
var
  ret: String;
  f: TextFile;
begin
{
<?xml version="1.0" encoding="iso-8859-1"?>
<response xmlns="urn:debugger_protocol_v1" xmlns:xdebug="http://xdebug.org/dbgp/xdebug"
  command="source" transaction_id="77" encoding="base64">
	<![CDATA[PD9waHANCg0KZW...cCgkY29kZSk7DQo=]]>
</response>}
  ret := '';

  if (self.xml.ChildNodes[1].HasChildNodes) and (self.xml.ChildNodes[1].ChildNodes[0]<>nil) then
    ret := self.xml.ChildNodes[1].ChildNodes[0].Text;

  if (self.xml.ChildNodes[1].Attributes['encoding'] = 'base64') then ret := Decode64(ret);

  if (self.last_source_request<>'') then
  begin
    AssignFile(f, self.MapSourceToLocal(self.last_source_request));
    Rewrite(f);
    WriteLn(f, ret);
    CloseFile(f);
    FileSetReadOnly(self.MapSourceToLocal(self.last_source_request), true);
    self.last_source_request := '';
  end;
end;

// returnes the read data and does all processing...
function TDbgpWinSocket.ReadDBGP: String;
var
 res,s,r,s2:String;
 len:Integer;
begin
  s := self.ReceiveText;
  s := self.buffer + s;
  if (s[Length(s)] <> #0) then // message not yet complete... return and wait for better times
  begin
    self.buffer := s;
    exit;
  end;

  len := StrToInt(s);
  if (Length(s)<len) then
  begin
    // Should not happen.. something is wronf with the message
    self.debugdata.Add('Error in len: '+IntToStr(Length(s))+'<'+IntToStr(len)+': '+s);
    exit;
  end;

  s2 := Copy(s, StrLen(PChar(s))+2, len);
  s := Copy(s, StrLen(PChar(s))+2+len+1, MaxInt);

  self.buffer := s; // ostanek

  // for raw log
   self.debugdata.Add('Recv: '+s2);

  self.Transaction_id := '';

  self.xml := TXMLDocument.Create(nil);
  self.xml.Options := [];
  self.xml.XML.Add(s2);
  self.xml.Active := true;

try
  res := self.xml.ChildNodes[1].NodeName;
  // handle error?
  if (self.xml.ChildNodes[1].HasChildNodes) and (self.xml.ChildNodes[1].ChildNodes[0].NodeName = 'error') then
  begin
  // better to do an onDbgpError!
    raise Exception.Create('DBGP Error: '+
      'Response type: '+res+' '+
      'Command: '+self.xml.ChildNodes[1].Attributes['command']+' '+
      'Error code: '+self.xml.ChildNodes[1].ChildNodes[0].Attributes['code']+' '+
      'Error: '+self.xml.ChildNodes[1].ChildNodes[0].Attributes['apperr']+' '+
      'Error message: '+self.xml.ChildNodes[1].ChildNodes[0].ChildNodes[0].ChildNodes[0].Text
    );
  end;
  if (res = 'init') then
  begin
    r := self.ProcessInit;
  end
  else if (res = 'response') then
  begin
    self.Transaction_id := self.xml.ChildNodes[1].Attributes['transaction_id'];
    if (self.xml.ChildNodes[1].Attributes['command'] = 'stack_get') then
    r := self.ProcessResponse_stack
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'eval') then
    r := self.ProcessResponse_eval
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'context_get') then
    r := self.ProcessResponse_context_get
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'breakpoint_set') then
    r := self.ProcessResponse_breakpoint_set
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'breakpoint_list') then
    r := self.ProcessResponse_breakpoint_list
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'source') then
    r := self.ProcessResponse_source
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
finally
  self.xml.Active := false;
  self.xml := nil;
end;
  if (self.buffer<>'') then self.ReadDBGP;
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

function TDbgpWinSocket.SendCommand(Cmd, Args, Base64: String): Integer;
var d:String;
begin
  Result := -1;
  if (not self.Connected) then exit;

  d := Cmd + ' -i '+IntToStr(self.TransID);
  Result := self.TransID;
  inc(self.TransID);
  if (Args <> '') then
    d := d + ' '+Args;
  if (Base64 <> '') then
    d := d + ' -- '+Encode64(Base64);
    //d := d + ' -- '+Base64Encode(Base64);
  self.SendText(d+#0);
  self.debugdata.Add('Send: '+d);
end;

function TDbgpWinSocket.SendCommand(Cmd, Args: String): Integer;
begin
  Result := self.SendCommand(Cmd, Args, '');
end;

function TDbgpWinSocket.SendCommand(Cmd: String): Integer;
begin
  Result := self.SendCommand(Cmd, '', '');
end;

{ Set a line breakpoint }
procedure TDbgpWinSocket.SendEval(data: String);
begin
  self.lastEval := data;
  self.SendCommand('eval','',data);
end;

procedure TDbgpWinSocket.SetBreakpoint(Filename: String; Line: Integer);
begin
  self.SendCommand('breakpoint_set', '-t line -f '+self.MapLocalToRemote(Filename)+
    ' -n '+IntToStr(Line));
end;

procedure TDbgpWinSocket.SetBreakpoint(bp: TBreakpoint);
var
  cmd: String;
begin
  case (bp.breakpointtype) of
    btLine: cmd := '-t line';
    btCall: cmd := '-t call';
    btReturn: cmd := '-t return';
    btException: cmd := '-t exception';
  end;
  if (bp.filename <> '') then
  begin
    cmd := cmd + ' -f '+self.MapLocalToRemote(bp.filename);
    cmd := cmd + ' -n '+IntToStr(bp.lineno);
  end;
  if (bp.state) then cmd := cmd + ' -s enabled' else cmd := cmd + ' -s disabled';
  if (bp.functionname <> '') then cmd := cmd + ' -m '+bp.functionname;
  if (bp.classname <> '') then cmd := cmd + ' -a '+bp.classname;
  if (bp.temporary) then cmd := cmd + ' -r 1';
  cmd := cmd + ' -h '+IntToStr(bp.hit_value)+' -o '+bp.hit_condition;
  if (bp.exception <> '') then cmd := cmd + ' -x '+bp.exception;
  self.SendCommand('breakpoint_set', cmd, bp.expression);
end;

procedure TDbgpWinSocket.RemoveBreakpoint(bp: TBreakpoint);
begin
  self.SendCommand('breakpoint_remove', '-d '+bp.id);
end;

procedure TDbgpWinSocket.UpdateBreakpoint(bp: TBreakpoint);
var
  cmd: String;
begin
  cmd := '-d ' + bp.id;
  if (bp.state) then cmd := cmd + ' -s enabled' else cmd := cmd + ' -s disabled';
  cmd := cmd + ' -n ' + IntToStr(bp.lineno);
  cmd := cmd + ' -h ' + IntToStr(bp.hit_value);
  cmd := cmd + ' -o ' + bp.hit_condition;

  self.SendCommand('breakpoint_update', cmd);
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

procedure TDbgpWinSocket.GetSource(filename: String);
begin
  // maps?
  self.last_source_request := filename;
  self.SendCommand('source', '-f '+filename);
end;

end.
