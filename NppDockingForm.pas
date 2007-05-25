unit NppDockingForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, NppPlugin, Dialogs;

type
  TNppDockingForm = class(TForm) {TCustomForm}
  private
    { Private declarations }
  protected
    { Protected declarations }
    // @todo: change caption and stuff....
    procedure OnWM_NOTIFY(var msg: TWMNotify); message WM_NOTIFY;
    procedure DoClose(var Action: TCloseAction); dynamic; // humm

  public
    { Public declarations }
    DlgId: Integer;
    Npp: TNppPlugin;
    procedure Show;
  published
    { Published declarations }
    constructor Create(NppParent: TNppPlugin);
  end;


implementation

{ TNppDockingForm }
//uses
//  dbgpNppPlugin;

constructor TNppDockingForm.Create(NppParent: TNppPlugin);
begin
  self.Npp := NppParent;
  inherited Create(nil);
end;

procedure TNppDockingForm.DoClose(var Action: TCloseAction);
begin
  inherited;
  if (Action = caFree) then
    self.Npp.UnregisterForm(TForm(self));
end;

procedure TNppDockingForm.OnWM_NOTIFY(var msg: TWMNotify);
begin
  // not good.. bols ce bi vse spremenil v TComponent in uporablal Parenta..

  if (self.Npp.NppData.NppHandle <> msg.NMHdr.hwndFrom) then
  begin
    inherited;
    exit;
  end;
  msg.Result := 0;

  if (msg.NMHdr.code = DMN_CLOSE) then
  begin
    //ShowMessage('Close');
  end;

 //#define DMN_FIRST 1050
 //#define DMN_CLOSE (DMN_FIRST + 1)

 // undock 263197  =  x shl 16 + 1053
 // dock r 66588               + 1052
 // dock d 197660
 // close 1501

 inherited;
end;

procedure TNppDockingForm.Show;
begin
  SendMessage(self.Npp.NppData.NppHandle, WM_DMM_SHOW, 0, LPARAM(self.Handle));
  inherited;
end;

end.
