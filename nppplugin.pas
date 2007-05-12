unit nppplugin;

interface

uses
  Windows,Messages,SciSupport,SysUtils,
  Dialogs;

const
  FuncItemNameLen=64;
  MaxFuncs = 11;

type
  TNppData = record
    NppHandle: HWND;
    ScintillaMainHandle: HWND;
    ScintillaSecondHandle: HWND;
  end;

  TShortcutKey = record
    IsCtrl: Boolean;
    IsAlt: Boolean;
    IsShift: Boolean;
    Key: Char;
  end;

  PFUNCPLUGINCMD = procedure; cdecl;

  TFuncItem = record
    ItemName: String[FuncItemNameLen];
    Func: PFUNCPLUGINCMD;
    CmdID: Integer; // lahjo bi skinil
    Checked: Boolean;
    ShortcutKey: ^TShortcutKey;
  end;
  _TFuncItem = record
    ItemName: Array[0..FuncItemNameLen-1] of Char;
    Func: PFUNCPLUGINCMD;
    CmdID: Integer;
    Checked: Boolean;
    ShortcutKey: ^TShortcutKey;
  end;

  TToolbarData = record
    ClientHandle: HWND;
    Title: PChar;
    DlgId: Integer;
    Mask: Integer;
    IconTab: HICON; // still dont know how to use this...
    AdditionalInfo: PChar;
    FloatRect: TRect;  // internal
    PrevContainer: Integer; // internal
    ModuleName:PChar; // name of module GetModuleFileName(0...)
  end;

  TNppPlugin = class(TObject)
    private
      FFuncArray: array[1..MaxFuncs] of _TFuncItem;
      FFuncCount: Integer;

      //FCapacity: Longint;
      //procedure SetCapacity(NewCapacity: Longint);
    protected
      PluginName: String;
      //function Realloc(var NewCapacity: Longint): Pointer; virtual;
      //property Capacity: Longint read FCapacity write SetCapacity;

      procedure AddFunc(Func: TFuncItem);

    public
      NppData: TNppData;
      constructor Create;
      destructor Destroy; override;

      // needed for DLL export.. wrappers are in the main dll file.
      procedure SetInfo(NppData: TNppData);
      function GetName: PChar;
      function GetFuncsArray(var FuncsCount: Integer): Pointer;
      procedure BeNotified(CSNotification: PSCNotification);
      procedure MessageProc(var Msg: TMessage);

      // sefull stuff

  end;



implementation

{ TNppPlugin }

procedure TNppPlugin.AddFunc(Func: TFuncItem);
var sk: ^TShortcutKey;
begin
  if (self.FFuncCount = MaxFuncs) then
  begin
    ShowMessage('No more space for functions');
    exit;
  end;
  inc(self.FFuncCount);
  // copy shortcut key
  sk := nil;
  if (Func.ShortcutKey <> nil) then
  begin
    New(sk);
    sk^.IsCtrl := Func.ShortcutKey^.IsCtrl;
    sk^.IsAlt := Func.ShortcutKey^.IsAlt;
    sk^.IsShift := Func.ShortcutKey^.IsShift;
    sk^.Key := Func.ShortcutKey^.Key;
  end;

  StrLCopy(self.FFuncArray[self.FFuncCount].ItemName, Pchar(String(Func.ItemName)), FuncItemNameLen); // yet another WTF
  self.FFuncArray[self.FFuncCount].Func := Func.Func;
  self.FFuncArray[self.FFuncCount].CmdID := Func.CmdID; // could use FFuncCount
  self.FFuncArray[self.FFuncCount].Checked := Func.Checked;
  self.FFuncArray[self.FFuncCount].ShortcutKey := @sk; // wtf??

end;

procedure TNppPlugin.BeNotified(CSNotification: PSCNotification);
begin
  // @todo
end;

constructor TNppPlugin.Create;
begin
  inherited;
  self.FFuncCount := 0;
end;

destructor TNppPlugin.Destroy;
var i: Integer;
begin
  // unregister dialogs?
  // dispose FuncsArray?
  for i:=1 to self.FFuncCount do
  begin
    if (self.FFuncArray[i].ShortcutKey <> nil) then
    begin
      Dispose(self.FFuncArray[i].ShortcutKey);
    end;
  end;

  inherited;
end;

function TNppPlugin.GetFuncsArray(var FuncsCount: Integer): Pointer;
begin
  FuncsCount := self.FFuncCount;
  Result := @self.FFuncArray;
end;

function TNppPlugin.GetName: PChar;
begin
  Result := PChar(self.PluginName);
end;

procedure TNppPlugin.MessageProc(var Msg: TMessage);
begin

end;

procedure TNppPlugin.SetInfo(NppData: TNppData);
begin
  self.NppData := NppData;
end;

end.
