unit DebugStackForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, JvDockTree, JvDockControlForm, JvDockVCStyle,
  JvComponentBase, JvDockVIDStyle, JvDockVSNetStyle, DbgpWinSocket;

type
  TDebugStackForm1 = class(TForm)
    VirtualStringTree1: TVirtualStringTree;
    JvDockClient1: TJvDockClient;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure VirtualStringTree1DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetStack(Stack: TStackList);
    procedure ClearStack;
  end;

var
  DebugStackForm1: TDebugStackForm1;

implementation

uses
  MainForm;
{$R *.dfm}

procedure TDebugStackForm1.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //MessageBeep(0);
end;

procedure TDebugStackForm1.SetStack(Stack: TStackList);
var
  i: Integer;
  Node: PVirtualNode;
  StackItem: PStackItem;
begin
  //
  self.VirtualStringTree1.Clear;
  self.VirtualStringTree1.BeginUpdate;

  for i:=0 to Length(Stack)-1 do
  begin
    Node := self.VirtualStringTree1.AddChild(nil);
    //self.VirtualStringTree1.NodeDataSize := SizeOf(TStackItem);
    StackItem := self.VirtualStringTree1.GetNodeData(Node);
    StackItem^.level := Stack[i].level;
    StackItem^.stacktype := Stack[i].stacktype;
    StackItem^.filename := Stack[i].filename;
    StackItem^.lineno := Stack[i].lineno;
    StackItem^.where := Stack[i].where;
 end;

  self.VirtualStringTree1.EndUpdate;
end;

procedure TDebugStackForm1.VirtualStringTree1GetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: WideString);
var
  si: PStackItem;
begin
  si := PStackItem(Sender.GetNodeData(Node));
  //
  case (Column) of
  0: CellText := IntToStr(si^.level);
  1: CellText := si^.filename;
  2: CellText := IntToStr(si^.lineno);
  3: CellText := si^.where;
  4: CellText := si^.stacktype;
  end;
end;

procedure TDebugStackForm1.VirtualStringTree1DblClick(Sender: TObject);
var
  si: PStackItem;
begin
//  self.VirtualStringTree1.se
  if (self.VirtualStringTree1.FocusedNode = nil) then exit;
  si := self.VirtualStringTree1.GetNodeData(self.VirtualStringTree1.FocusedNode);

//  si^.filename;
//  si^.lineno;
  TNppDockingForm1(self.Owner).GotoLineCB(si^.filename,si^.lineno);

end;

procedure TDebugStackForm1.FormCreate(Sender: TObject);
begin
  self.VirtualStringTree1.NodeDataSize := SizeOf(TStackItem);
end;

procedure TDebugStackForm1.ClearStack;
begin
  self.VirtualStringTree1.Clear;
end;

end.
