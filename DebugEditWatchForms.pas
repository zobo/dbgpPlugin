unit DebugEditWatchForms;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NppForms, StdCtrls;

type
  TDebugEditWatchForm = class(TNppForm)
    Expression: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  DebugEditWatchForm: TDebugEditWatchForm;

implementation

{$R *.dfm}

end.
