unit DebugVarForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvDockTree, JvDockControlForm, JvDockVIDStyle, JvDockVSNetStyle,
  JvComponentBase, VirtualTrees, DbgpWinSocket;

type
  TDebugVarForm1 = class(TForm)
    VirtualStringTree1: TVirtualStringTree;
    JvDockClient1: TJvDockClient;
    procedure FormCreate(Sender: TObject);
    procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
  private
    { Private declarations }
    procedure SubSetVars(ParentNode: PVirtualNode; list:TPropertyItems);
  public
    { Public declarations }
    procedure SetVars(list: TPropertyItems);
  end;

var
  DebugVarForm1: TDebugVarForm1;

implementation

uses
  MainForm;
{$R *.dfm}

procedure TDebugVarForm1.FormCreate(Sender: TObject);
begin
  self.VirtualStringTree1.NodeDataSize := SizeOf(TPropertyItem);
end;

procedure TDebugVarForm1.SetVars(list: TPropertyItems);
begin
  self.VirtualStringTree1.Clear;
  self.VirtualStringTree1.BeginUpdate;

  self.SubSetVars(nil, list);

  self.VirtualStringTree1.EndUpdate;
end;

procedure TDebugVarForm1.SubSetVars(ParentNode: PVirtualNode;
  list: TPropertyItems);
var
  i: Integer;
  Node: PVirtualNode;
  Item: PPropertyItem;
begin

  for i:=0 to Length(list)-1 do
  begin
    Node := self.VirtualStringTree1.AddChild(ParentNode);
    Item := self.VirtualStringTree1.GetNodeData(Node);

    Item^.name := list[i].name;
    Item^.fullname := list[i].fullname;
    Item^.datatype := list[i].datatype;
    Item^.classname := list[i].classname;
    Item^.constant := list[i].constant;
    Item^.haschildren := list[i].haschildren;
    Item^.size := list[i].size;
    Item^.page := list[i].page;
    Item^.pagesize := list[i].pagesize;
    Item^.address := list[i].address;
    Item^.key := list[i].key;
    Item^.numchildren := list[i].numchildren;
    Item^.data := list[i].data;
    Item^.children := nil;

    if ((list[i].numchildren <> '0') and (list[i].children <> nil)) then
    begin
      self.SubSetVars(Node, list[i].children^);
    end;
  end;

end;

procedure TDebugVarForm1.VirtualStringTree1GetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: WideString);
var
  Item: PPropertyItem;
begin

  Item := PPropertyItem(Sender.GetNodeData(Node));

  case Column of
  0: {if (Node.Parent<>nil) then CellText := Item^.name else }CellText := Item^.fullname;
  1: CellText := Item^.data;
  2: CellText := Item^.datatype;
  end;

end;

end.
