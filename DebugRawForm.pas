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

unit DebugRawForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvComponentBase, JvDockControlForm, StdCtrls, Menus;

type
  TDebugRawForm1 = class(TForm)
    JvDockClient1: TJvDockClient;
    Memo1: TMemo;
    Edit1: TEdit;
    Button1: TButton;
    PopupMenu1: TPopupMenu;
    Clear1: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
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

procedure TDebugRawForm1.Clear1Click(Sender: TObject);
begin
  self.Memo1.Clear;
end;

end.
