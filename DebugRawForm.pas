unit DebugRawForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvComponentBase, JvDockControlForm, StdCtrls;

type
  TDebugRawForm1 = class(TForm)
    JvDockClient1: TJvDockClient;
    Memo1: TMemo;
    Edit1: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DebugRawForm1: TDebugRawForm1;

implementation

uses
  MainForm;
{$R *.dfm}

procedure TDebugRawForm1.Button1Click(Sender: TObject);
var
  mf: TNppDockingForm1;
begin
  // send raw
  mf := self.Owner as TNppDockingForm1;
  if Assigned(mf.sock) then
  begin
    mf.sock.SendText(self.Edit1.Text+#0);
    mf.sock.debugdata.Add('Raw: '+self.Edit1.Text);
  end;
end;

end.
