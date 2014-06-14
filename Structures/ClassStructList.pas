unit ClassStructList;

{$mode objfpc}{$H+}

interface

type
  t_value = integer;
  t_size = dword;

  //Указатель на узел в списке
  p_stack = ^t_stack;
  //Структура узла односвязного списка
  t_stack = record
    Data: t_value; //Значение в узле
    Next: p_stack; //Указатель на следующий узел
  end;
  //Класс стека [на основе связных списков]
  StackList = class
  private
    pStart: p_stack;
    currentsize: t_size;
    maxsize: t_size;
  public
    function add_head(const Value: t_value): boolean;
    function del_head(): boolean;
    function get_head(var Value: t_value): boolean;
    function get_size(): t_size;
    procedure print();
    constructor Create(size: t_size);
    destructor Destroy(); override;
  end;

  //Указатель на узел в списке
  p_queue = ^t_queue;
  //Структура узла двусвязного списка
  t_queue = record
    Data: t_value; //Значение в узле
    Next: p_queue; //Указатель на следующий узел
    prev: p_queue; //Указатель на предыдущий узел
  end;
  //Класс очереди [на основе связных списков]
  QueueList = class
  protected
    pStart: p_queue;
    pEnd: p_queue;
    currentsize: t_size;
    maxsize: t_size;
  public
    function add_head(const Value: t_value): boolean;
    function del_tail(): boolean;
    function get_tail(var Value: t_value): boolean;
    function get_size(): t_size;
    procedure print();
    constructor Create(size: t_size);
    destructor Destroy(); override;
  end;

  //Класс ДЕКА [на основе связных списков]
  DQueueList = class(QueueList)
  public
    function add_tail(const Value: t_value): boolean;
    function del_head(): boolean;
    function get_head(var Value: t_value): boolean;
  end;

implementation


{
    StackList methods
    =================
}

constructor StackList.Create(size: t_size);
begin
  self.pStart := nil;
  self.currentsize := 0;
  self.maxsize := size;
end;

destructor StackList.Destroy();
var
  nextelem: p_stack;
begin
  nextelem := self.pStart;
  while self.get_size() <> 0 do
  begin
    self.del_head();
  end;
  dispose(nextelem);
  nextelem := nil;
end;

function StackList.add_head(const Value: t_value): boolean;
var
  new_elem: p_stack;
begin
  if (self.get_size() >= self.maxsize) then
  begin
    Result := False;
    exit;
  end;
  new(new_elem);
  if (self.pStart = nil) then
  begin
    self.pStart := new_elem;
    new_elem^.Data := Value;
    new_elem^.Next := nil;
  end
  else
  begin
    new_elem^.Next := self.pStart;
    self.pStart := new_elem;
    new_elem^.Data := Value;
  end;
  Inc(self.currentsize);
  Result := True;
end;

function StackList.del_head(): boolean;
var
  tempelem: p_stack;
begin
  if (self.get_size() = 0) then
  begin
    Result := False;
    exit;
  end;
  tempelem := self.pStart;
  if (self.pStart <> nil) then
    self.pStart := self.pStart^.Next^.Next
  else
    self.pStart := nil;
  dispose(tempelem);
  Dec(self.currentsize);
  Result := True;
end;

function StackList.get_head(var Value: t_value): boolean;
var
  new_elem: p_stack;
begin
  if (self.get_size() = 0) then
  begin
    Result := False;
    exit;
  end;
  Value := pStart^.Data;
  new_elem := pStart;
  if (new_elem^.Next = nil) then
  begin
    pStart := nil;
    dispose(new_elem);
  end
  else
  begin
    pStart := new_elem^.Next;
    dispose(new_elem);
  end;
  Dec(self.currentsize);
  Result := True;
end;

function StackList.get_size(): t_size;
begin
  Result := self.currentsize;
end;

procedure StackList.print();
var
  tempelem: p_stack;
begin
  if (self.get_size() = 0) then
    exit;
  tempelem := pStart;
  while tempelem^.Next <> nil do
  begin
    Write(tempelem^.Data, ' ');
    tempelem := tempelem^.Next;
  end;
  Write(tempelem^.Data, ' ');
end;

{
    QueueList methods
    =================
}

constructor QueueList.Create(size: t_size);
begin
  self.pStart := nil;
  self.pEnd := nil;
  self.currentsize := 0;
  self.maxsize := size;
end;

destructor QueueList.Destroy();
var
  nextelem: p_queue;
begin
  nextelem := self.pStart;
  while self.get_size() <> 0 do
  begin
    self.del_tail();
  end;
  dispose(nextelem);
  nextelem := nil;
end;

function QueueList.add_head(const Value: t_value): boolean;
var
  new_elem: p_queue;
begin
  if (self.get_size() >= self.maxsize) then
  begin
    Result := False;
    exit;
  end;

  new(new_elem);
  new_elem^.Data := Value;

  if (self.pStart = nil) then
  begin
    self.pStart := new_elem;
    self.pEnd := new_elem;
    new_elem^.Next := nil;
    new_elem^.prev := nil;
  end
  else
  begin
    self.pStart^.prev := new_elem;
    new_elem^.Next := self.pStart;
    new_elem^.prev := nil;
    self.pStart := new_elem;
  end;
  Inc(self.currentsize);
  Result := True;
end;

function QueueList.del_tail(): boolean;
var
  tempelem: p_queue;
begin
  if (self.get_size() = 0) then
  begin
    Result := False;
    exit;
  end;
  tempelem := self.pEnd;
  if (self.get_size() = 1) then
  begin
    self.pEnd := nil;
    self.pStart := nil;
    dispose(tempelem);
    Dec(self.currentsize);
    Result := True;
    exit;
  end;
  self.pEnd^.prev^.Next := nil;
  self.pEnd := self.pEnd^.prev;
  dispose(tempelem);
  Dec(self.currentsize);
  Result := True;
end;

function QueueList.get_tail(var Value: t_value): boolean;
begin
  if (self.get_size() = 0) then
  begin
    Result := False;
    exit;
  end;
  Value := self.pEnd^.Data;
  Result := self.del_tail();
end;

function QueueList.get_size(): t_size;
begin
  Result := self.currentsize;
end;

procedure QueueList.print();
var
  tempelem: p_queue;
begin
  if (self.get_size() = 0) then
    exit;
  tempelem := self.pStart;
  while tempelem^.Next <> nil do
  begin
    Write(tempelem^.Data, ' ');
    tempelem := tempelem^.Next;
  end;
  Write(tempelem^.Data, ' ');
end;

{
    DQueueList methods (inherits QueueList methods)
    ===============================================
}

function DQueueList.add_tail(const Value: t_value): boolean;
var
  new_elem: p_queue;
begin
  if (self.get_size() >= self.maxsize) then
  begin
    Result := False;
    exit;
  end;
  if (self.get_size() = 0) then
  begin
    self.add_head(Value);
    exit;
  end;
  new(new_elem);
  new_elem^.Data := Value;
  new_elem^.prev := self.pEnd;
  new_elem^.Next := nil;
  self.pEnd^.Next := new_elem;
  self.pEnd := new_elem;
  Inc(self.currentsize);
  Result := True;
end;

function DQueueList.del_head(): boolean;
var
  tempelem: p_queue;
begin
  if (get_size() = 0) then
  begin
    Result := False;
    exit;
  end;
  tempelem := self.pStart;
  if (self.pStart^.Next <> nil) then
  begin
    self.pStart^.Next^.prev := nil;
    self.pStart := self.pStart^.Next;
  end
  else
  begin
    self.pStart := nil;
    self.pEnd := nil;
  end;
  dispose(tempelem);
  Dec(self.currentsize);
  Result := True;
end;

function DQueueList.get_head(var Value: t_value): boolean;
begin
  if (get_size() = 0) then
  begin
    Result := False;
    exit;
  end;
  Value := self.pStart^.Data;
  Result := self.del_head();
end;

end.
