unit DebugEvalForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TDebugEvalForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DebugEvalForm1: TDebugEvalForm1;

implementation

{$R *.dfm}

procedure TDebugEvalForm1.Button1Click(Sender: TObject);
begin
  self.ComboBox1.Items.Add(self.ComboBox1.Text);
end;

end.
