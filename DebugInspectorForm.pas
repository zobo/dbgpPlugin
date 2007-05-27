unit DebugInspectorForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils;

type
  TDebugInspectorForm1 = class(TForm)
    Memo1: TMemo;
    CheckBox1: TCheckBox;
    procedure CheckBox1Click(Sender: TObject);
  private
    { Private declarations }
    data: String;
  public
    { Public declarations }
    procedure SetData(x: String);
  end;

var
  DebugInspectorForm1: TDebugInspectorForm1;

implementation

{$R *.dfm}

procedure TDebugInspectorForm1.CheckBox1Click(Sender: TObject);
begin
  self.SetData(self.data);
end;

procedure TDebugInspectorForm1.SetData(x: String);
begin
  self.data := x;
  self.Memo1.Lines.Clear;

  if (self.CheckBox1.Checked) then
  begin
    self.Memo1.Lines.Add('Not implemented...');
  end
  else
  begin
    // convert newlines?
    //self.Memo1.Text := self.data;
    self.Memo1.Text := AnsiReplaceStr(self.data, #10, #13+#10);
  end;
end;

end.
