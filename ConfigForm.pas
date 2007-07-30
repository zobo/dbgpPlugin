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

unit ConfigForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, NppDockingForm, DbgpWinSocket, JvDockTree,
  JvDockControlForm, JvDockVCStyle, JvComponentBase;

type
  TConfigForm1 = class(TNppDockingForm)
    GroupBox1: TGroupBox;
    Button1: TButton;
    DeleteButton: TButton;
    StringGrid1: TStringGrid;
    GroupBox2: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConfigForm1: TConfigForm1;

implementation

uses DbgpNppPlugin;
{$R *.dfm}

procedure TConfigForm1.Button1Click(Sender: TObject);
begin
  self.StringGrid1.RowCount := self.StringGrid1.RowCount + 1;
end;

procedure TConfigForm1.DeleteButtonClick(Sender: TObject);
var i: Integer;
begin
  if self.StringGrid1.RowCount = 2 then exit;
  for i := self.StringGrid1.Row to self.StringGrid1.RowCount-2 do
    self.StringGrid1.Rows[i].Assign(self.StringGrid1.Rows[i+1]);
  self.StringGrid1.RowCount := self.StringGrid1.RowCount - 1;
  self.StringGrid1.Refresh;
end;

procedure TConfigForm1.FormCreate(Sender: TObject);
var
  maps: TMaps;
  i: integer;
begin
  self.StringGrid1.RowCount := 2;
  self.StringGrid1.ColCount := 4;
  self.StringGrid1.Cells[0,0] := 'Remote Server IP';
  self.StringGrid1.Cells[1,0] := 'IDE KEY';
  self.StringGrid1.Cells[2,0] := 'Remote Path';
  self.StringGrid1.Cells[3,0] := 'Local Path';

  (self.Npp as TDbgpNppPlugin).ReadMaps(maps);

  self.StringGrid1.RowCount := Length(maps)+2;

  for i:=0 to Length(maps)-1 do
  begin
    self.StringGrid1.Rows[i+1] := maps[i];
  end;

  self.CheckBox1.Checked := (self.Npp as TDbgpNppPlugin).config.refresh_local;
  self.CheckBox2.Checked := (self.Npp as TDbgpNppPlugin).config.refresh_remote;
end;


procedure TConfigForm1.Button3Click(Sender: TObject);
var
  maps: TMaps;
  i: integer;
  conf: TDbgpNppPluginConfig;
begin
  // save maps
  SetLength(maps, self.StringGrid1.RowCount-1);
  for i:=0 to Length(maps)-1 do
  begin
    maps[i] := TStringList.Create;
    maps[i].AddStrings(self.StringGrid1.Rows[i+1]);
  end;

  conf.maps := maps;
  conf.refresh_local := self.CheckBox1.Checked;
  conf.refresh_remote := self.CheckBox2.Checked;
  (self.Npp as TDbgpNppPlugin).WriteMaps(conf);

  self.Close;
end;

procedure TConfigForm1.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
