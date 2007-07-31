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

unit nppplugin;

interface

uses
  Windows,Messages,SciSupport,SysUtils,
  Dialogs,Classes,Forms{,NppDockingForm};

const
  FuncItemNameLen=64;
  MaxFuncs = 11;

  { Most of this defs are outdated... But there is no consistant N++ doc... }
  NOTEPADPLUS_USER = (WM_USER + 1000);
  WM_GETCURRENTSCINTILLA = (NOTEPADPLUS_USER + 4);
  WM_GETCURRENTLANGTYPE = (NOTEPADPLUS_USER + 5);
  WM_SETCURRENTLANGTYPE = (NOTEPADPLUS_USER + 6);
  WM_NBOPENFILES = (NOTEPADPLUS_USER + 7);
    ALL_OPEN_FILES = 0;
    PRIMARY_VIEW = 1;
    SECOND_VIEW	= 2;
  WM_GETOPENFILENAMES = (NOTEPADPLUS_USER + 8);
  WM_CANCEL_SCINTILLAKEY = (NOTEPADPLUS_USER + 9);
  WM_BIND_SCINTILLAKEY = (NOTEPADPLUS_USER + 10);
  WM_SCINTILLAKEY_MODIFIED = (NOTEPADPLUS_USER + 11);
  WM_MODELESSDIALOG = (NOTEPADPLUS_USER + 12);
    MODELESSDIALOGADD = 0;
    MODELESSDIALOGREMOVE = 1;

  WM_NBSESSIONFILES = (NOTEPADPLUS_USER + 13);
  WM_GETSESSIONFILES = (NOTEPADPLUS_USER + 14);
  WM_SAVESESSION = (NOTEPADPLUS_USER + 15);
  WM_SAVECURRENTSESSION  =(NOTEPADPLUS_USER + 16);  // see TSessionInfo
  WM_GETOPENFILENAMES_PRIMARY = (NOTEPADPLUS_USER + 17);
  WM_GETOPENFILENAMES_SECOND = (NOTEPADPLUS_USER + 18);
  WM_GETPARENTOF = (NOTEPADPLUS_USER + 19);
  WM_CREATESCINTILLAHANDLE = (NOTEPADPLUS_USER + 20);
  WM_DESTROYSCINTILLAHANDLE = (NOTEPADPLUS_USER + 21);
  WM_GETNBUSERLANG = (NOTEPADPLUS_USER + 22);
  WM_GETCURRENTDOCINDEX = (NOTEPADPLUS_USER + 23);
    MAIN_VIEW = 0;
    SUB_VIEW = 1;

  WM_SETSTATUSBAR = (NOTEPADPLUS_USER + 24);
    STATUSBAR_DOC_TYPE = 0;
    STATUSBAR_DOC_SIZE = 1;
    STATUSBAR_CUR_POS = 2;
    STATUSBAR_EOF_FORMAT = 3;
    STATUSBAR_UNICODE_TYPE = 4;
    STATUSBAR_TYPING_MODE = 5;

  WM_GETMENUHANDLE = (NOTEPADPLUS_USER + 25);
    NPPPLUGINMENU = 0;

  WM_ENCODE_SCI = (NOTEPADPLUS_USER + 26);
  //ascii file to unicode
  //int WM_ENCODE_SCI(MAIN_VIEW/SUB_VIEW, 0)
  //return new unicodeMode

  WM_DECODE_SCI = (NOTEPADPLUS_USER + 27);
  //unicode file to ascii
  //int WM_DECODE_SCI(MAIN_VIEW/SUB_VIEW, 0)
  //return old unicodeMode

  WM_ACTIVATE_DOC = (NOTEPADPLUS_USER + 28);
  //void WM_ACTIVATE_DOC(int index2Activate, int view)

  WM_LAUNCH_FINDINFILESDLG = (NOTEPADPLUS_USER + 29);
  //void WM_LAUNCH_FINDINFILESDLG(char * dir2Search, char * filtre)

  WM_DMM_SHOW = (NOTEPADPLUS_USER + 30);
  WM_DMM_HIDE	= (NOTEPADPLUS_USER + 31);
  WM_DMM_UPDATEDISPINFO = (NOTEPADPLUS_USER + 32);
  //void WM_DMM_xxx(0, tTbData->hClient)

  WM_DMM_REGASDCKDLG = (NOTEPADPLUS_USER + 33);
  //void WM_DMM_REGASDCKDLG(0, &tTbData)

  WM_LOADSESSION = (NOTEPADPLUS_USER + 34);
  //void WM_LOADSESSION(0, const char* file name)
  WM_DMM_VIEWOTHERTAB = (NOTEPADPLUS_USER + 35);
  //void WM_DMM_VIEWOTHERTAB(0, tTbData->hClient)
  WM_RELOADFILE = (NOTEPADPLUS_USER + 36);
  //BOOL WM_RELOADFILE(BOOL withAlert, char *filePathName2Reload)
  WM_SWITCHTOFILE = (NOTEPADPLUS_USER + 37);
  //BOOL WM_SWITCHTOFILE(0, char *filePathName2switch)
  WM_SAVECURRENTFILE = (NOTEPADPLUS_USER + 38);
  //BOOL WM_SWITCHTOFILE(0, 0)
  WM_SAVEALLFILES	= (NOTEPADPLUS_USER + 39);
  //BOOL WM_SAVEALLFILES(0, 0)
  WM_PIMENU_CHECK	= (NOTEPADPLUS_USER + 40);
  //void WM_PIMENU_CHECK(UINT	funcItem[X]._cmdID, TRUE/FALSE)

  WM_ADDTOOLBARICON = (NOTEPADPLUS_USER + 41); // see TToolbarIcons
  //void WM_ADDTOOLBARICON(UINT funcItem[X]._cmdID, toolbarIcons icon)

  WM_GETWINDOWSVERSION = (NOTEPADPLUS_USER + 42);
  //winVer WM_GETWINDOWSVERSION(0, 0)

  // Notification code
  NPPN_FIRST = 1000;
  NPPN_READY = (NPPN_FIRST + 1);
  //scnNotification->nmhdr.code = NPPN_READY;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;

  NPPN_TB_MODIFICATION = (NPPN_FIRST + 2);
  //scnNotification->nmhdr.code = NPPN_TB_MODIFICATION;
  //scnNotification->nmhdr.hwndFrom = hwndNpp;
  //scnNotification->nmhdr.idFrom = 0;

   RUNCOMMAND_USER    = (WM_USER + 3000);
    VAR_NOT_RECOGNIZED = 0;
    FULL_CURRENT_PATH = 1;
    CURRENT_DIRECTORY = 2;
    FILE_NAME = 3;
    NAME_PART = 4;
    EXT_PART = 5;
    CURRENT_WORD = 6;
    NPP_DIRECTORY = 7;
  WM_GET_FULLCURRENTPATH = (RUNCOMMAND_USER + FULL_CURRENT_PATH);
  WM_GET_CURRENTDIRECTORY = (RUNCOMMAND_USER + CURRENT_DIRECTORY);
  WM_GET_FILENAME = (RUNCOMMAND_USER + FILE_NAME);
  WM_GET_NAMEPART = (RUNCOMMAND_USER + NAME_PART);
  WM_GET_EXTPART = (RUNCOMMAND_USER + EXT_PART);
  WM_GET_CURRENTWORD = (RUNCOMMAND_USER + CURRENT_WORD);
  WM_GET_NPPDIRECTORY = (RUNCOMMAND_USER + NPP_DIRECTORY);

  MACRO_USER    = (WM_USER + 4000);
  WM_ISCURRENTMACRORECORDED = (MACRO_USER + 01);
  WM_MACRODLGRUNMACRO       = (MACRO_USER + 02);





{ Humm.. is tis npp specific? }
  SCINTILLA_USER = (WM_USER + 2000);
{
#define WM_DOCK_USERDEFINE_DLG      (SCINTILLA_USER + 1)
#define WM_UNDOCK_USERDEFINE_DLG    (SCINTILLA_USER + 2)
#define WM_CLOSE_USERDEFINE_DLG		(SCINTILLA_USER + 3)
#define WM_REMOVE_USERLANG		    (SCINTILLA_USER + 4)
#define WM_RENAME_USERLANG			(SCINTILLA_USER + 5)
#define WM_REPLACEALL_INOPENEDDOC	(SCINTILLA_USER + 6)
#define WM_FINDALL_INOPENEDDOC  	(SCINTILLA_USER + 7)
}
  WM_DOOPEN = (SCINTILLA_USER + 8);
{
#define WM_FINDINFILES			  	(SCINTILLA_USER + 9)
}


{ docking.h }
//   defines for docking manager
  CONT_LEFT = 0;
  CONT_RIGHT = 1;
  CONT_TOP = 2;
  CONT_BOTTOM = 3;
  DOCKCONT_MAX = 4;

// mask params for plugins of internal dialogs
  DWS_ICONTAB = 1; // Icon for tabs are available
  DWS_ICONBAR = 2; // Icon for icon bar are available (currently not supported)
  DWS_ADDINFO = 4; // Additional information are in use

// default docking values for first call of plugin
  DWS_DF_CONT_LEFT = CONT_LEFT shl 28;	        // default docking on left
  DWS_DF_CONT_RIGHT = CONT_RIGHT shl 28;	// default docking on right
  DWS_DF_CONT_TOP = CONT_TOP shl 28;	        // default docking on top
  DWS_DF_CONT_BOTTOM = CONT_BOTTOM shl 28;	// default docking on bottom
  DWS_DF_FLOATING = $80000000;			// default state is floating

{ dockingResource.h }
  DMN_FIRST = 1050;
  DMN_CLOSE = (DMN_FIRST + 1); //nmhdr.code = DWORD(DMN_CLOSE, 0)); //nmhdr.hwndFrom = hwndNpp; //nmhdr.idFrom = ctrlIdNpp;
  DMN_DOCK = (DMN_FIRST + 2);
  DMN_FLOAT = (DMN_FIRST + 3); //nmhdr.code = DWORD(DMN_XXX, int newContainer);	//nmhdr.hwndFrom = hwndNpp; //nmhdr.idFrom = ctrlIdNpp;


type
  TNppLang = (L_TXT, L_PHP , L_C, L_CPP, L_CS, L_OBJC, L_JAVA, L_RC,
              L_HTML, L_XML, L_MAKEFILE, L_PASCAL, L_BATCH, L_INI, L_NFO, L_USER,
              L_ASP, L_SQL, L_VB, L_JS, L_CSS, L_PERL, L_PYTHON, L_LUA,
              L_TEX, L_FORTRAN, L_BASH, L_FLASH, L_NSIS, L_TCL, L_LISP, L_SCHEME,
              L_ASM, L_DIFF, L_PROPS, L_PS, L_RUBY, L_SMALLTALK, L_VHDL, L_KIX, L_AU3,
              L_CAML, L_ADA, L_VERILOG, L_MATLAB, L_HASKELL, L_INNO,
              // The end of enumated language type, so it should be always at the end
              L_END);

  TSessionInfo = record
    SessionFilePathName: PChar;
    NumFiles: Integer;
    Files: array of PChar;
  end;

  TToolbarIcons = record
    ToolbarBmp: HBITMAP;
    ToolbarIcon: HICON;
  end;

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
  PShortcutKey = ^TShortcutKey;

  PFUNCPLUGINCMD = procedure; cdecl;

  TFuncItem = record
    ItemName: String[FuncItemNameLen];
    Func: PFUNCPLUGINCMD;
    CmdID: Integer; // lahjo bi skinil
    Checked: Boolean;
    ShortcutKey: PShortcutKey;
  end;
  _TFuncItem = record
    ItemName: Array[0..FuncItemNameLen-1] of Char;
    Func: PFUNCPLUGINCMD;
    CmdID: Integer;
    Checked: Boolean;
    ShortcutKey: PShortcutKey;
  end;
  PFuncItem = ^_TFuncItem;

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
    protected
      PluginName: String;
      FuncArray: array of _TFuncItem;
      //FuncCount: Integer;
      //procedure AddFunc(Func: TFuncItem);
      //function GetFunc(i: Integer): PFuncItem;
    public
      NppData: TNppData;
      constructor Create;
      destructor Destroy; override;

      // needed for DLL export.. wrappers are in the main dll file.
      procedure SetInfo(NppData: TNppData);
      function GetName: PChar;
      function GetFuncsArray(var FuncsCount: Integer): Pointer;
      procedure BeNotified(sn: PSCNotification); virtual;
      procedure MessageProc(var Msg: TMessage); virtual;

      // usefull stuff
      procedure RegisterForm(var form: TForm);
      procedure UnregisterForm(var form: TForm);
      procedure RegisterDockingForm(form: TForm{TNppDockingForm});

      // df
      function DoOpen(filename: String): boolean; overload;
      function DoOpen(filename: String; Line: Integer): boolean; overload;
      procedure GetFileLine(var filename: String; var Line: Integer);
      function GetWord: string;

  end;

implementation

uses
  NppDockingForm;
{ TNppPlugin }
{
procedure TNppPlugin.AddFunc(Func: TFuncItem);
var sk: PShortcutKey;
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
  self.FFuncArray[self.FFuncCount].ShortcutKey := sk; // wtf??

end;
}
procedure TNppPlugin.BeNotified(sn: PSCNotification);
begin
  // @todo
end;

constructor TNppPlugin.Create;
begin
  inherited;
  //self.FuncCount := 0;
end;

destructor TNppPlugin.Destroy;
var i: Integer;
begin
  // unregister dialogs?
  // dispose FuncsArray?
  for i:=0 to Length(self.FuncArray)-1 do
  begin
    if (self.FuncArray[i].ShortcutKey <> nil) then
    begin
      Dispose(self.FuncArray[i].ShortcutKey);
    end;
  end;

  inherited;
end;

function TNppPlugin.DoOpen(filename: String): boolean;
var
  r: integer;
begin
  r := SendMessage(self.NppData.NppHandle, WM_DOOPEN, 0, LPARAM(PChar(filename)));
  Result := (r=0);
end;

function TNppPlugin.DoOpen(filename: String; Line: Integer): boolean;
var
  r: boolean;
begin
  r := self.DoOpen(filename);
  if (r) then
    SendMessage(self.NppData.ScintillaMainHandle, SciSupport.SCI_GOTOLINE, Line,0);
  Result := r;
end;

procedure TNppPlugin.GetFileLine(var filename: String; var Line: Integer);
var
  s: String;
  r: Integer;
begin
  s := '';
  SetLength(s, 300);
  SendMessage(self.NppData.NppHandle, WM_GET_FULLCURRENTPATH,0, LPARAM(PChar(s)));
  SetLength(s, StrLen(PChar(s)));
  filename := s;

  r := SendMessage(self.NppData.ScintillaMainHandle, SciSupport.SCI_GETCURRENTPOS, 0, 0);
  Line := SendMessage(self.NppData.ScintillaMainHandle, SciSupport.SCI_LINEFROMPOSITION, r, 0);

end;
{
function TNppPlugin.GetFunc(i: Integer): PFuncItem;
begin

end;
}
function TNppPlugin.GetFuncsArray(var FuncsCount: Integer): Pointer;
begin
  FuncsCount := Length(self.FuncArray);
  Result := self.FuncArray;
end;

function TNppPlugin.GetName: PChar;
begin
  Result := PChar(self.PluginName);
end;

function TNppPlugin.GetWord: string;
var
  s: string;
begin
  SetLength(s, 800);
  SendMessage(self.NppData.NppHandle, WM_GET_CURRENTWORD,0,LPARAM(PChar(s)));
  Result := s;
end;

procedure TNppPlugin.MessageProc(var Msg: TMessage);
begin

end;

procedure TNppPlugin.RegisterDockingForm(form: TForm{TNppDockingForm});
var
  r:Integer;
  td: TToolbarData;
  tmp: Array[0..1000] of Char;
  cap: ^String;
  _form: TNppDockingForm;
begin
  // register form
  self.RegisterForm(TForm(form));

  _form := form as TNppDockingForm;
  FillChar(td,sizeof(td),0);

  td.ClientHandle := form.Handle;

  // this is just crap.. we need to keep this string in memory.. no way to destroy it tho..  screw this for now
  // If we'd wanted to change the caption or additional info, we'd need to change the memory these pointer point to now... blody hell for pascal!@#%#@
  New(cap);
  cap^ := form.Caption; // Why would caption get deallocated anyway?!.. Is it better to show the form before register?
  td.Title := PChar(cap^);

  td.DlgId := _form.DlgId;
  td.Mask := DWS_DF_CONT_BOTTOM;{DWS_DF_FLOATING;} // change
//  td.IconTab := nil;
//  td.AdditionalInfo := Pchar('lala');

  GetModuleFileName(0, tmp, 1000);
  td.ModuleName := tmp;

  r:=SendMessage(self.NppData.NppHandle, WM_DMM_REGASDCKDLG, 0, Integer(@td));
end;

procedure TNppPlugin.RegisterForm(var form: TForm);
var
  r: Integer;
begin
  r:=SendMessage(self.NppData.NppHandle, WM_MODELESSDIALOG, MODELESSDIALOGADD, form.Handle);
  if (r = 0) then
  begin
    ShowMessage('Failed reg of form '+form.Name);
    exit;
  end;
end;

procedure TNppPlugin.SetInfo(NppData: TNppData);
begin
  self.NppData := NppData;
end;

procedure TNppPlugin.UnregisterForm(var form: TForm);
var
  r: Integer;
begin
  r:=SendMessage(self.NppData.NppHandle, WM_MODELESSDIALOG, MODELESSDIALOGREMOVE, form.Handle);
  if (r = 0) then
  begin
    ShowMessage('Failed unreg form '+form.Name);
    exit;
  end;
end;

end.
