unit ClassStructArray;

{$mode objfpc}{$H+}

interface

type
	t_value = integer;
  t_size = dword;
  StackArrayInt = specialize StackArray<integer>;
  StackArrayChar = specialize StackArray<char>;
  
  //Now we can use a: StackArrayInt in VAR section

	//Класс стека [на основе массива]
	generic StackArray<t_value> = class
	private
    currentsize: t_size;
    maxsize: t_size;
    ARR: array of t_value;
	public
		function add_head(const value: t_value): boolean;
		function del_head(): boolean;
		function get_head(var value: t_value): boolean;
		function get_size(): dword;
		procedure print();
		constructor create(size: t_size);
		destructor destroy(); override;
	end;

	//Класс очереди [на основе массива]
	QueueArray = class
	  protected
		  pStart: t_size;
      pEnd: t_size;
      currentsize: t_size;
		  maxsize: t_size;
      ARR: array of t_value;
	  public
      function add_head(const value: t_value): boolean;
      function del_tail(): boolean;
      function get_tail(var value: t_value): boolean;
      function get_size(): t_size;
      procedure print();
      constructor create(size: t_size);
      destructor destroy(); override;
	end;


  //Класс ДЕКА [на основе массива]
	DQueueArray = class (QueueArray)
	  public
      function add_tail(const value: t_value): boolean;
      function del_head(): boolean;
      function get_head(var value: t_value): boolean;
	end;

implementation

{
    StackArray methods
    ==================
}
  constructor StackArray.create(size: t_size);
    begin
      self.currentsize := 0;
	    self.maxsize := size;
      setLength(ARR, size);
    end;

  destructor StackArray.destroy();
    begin
  	  finalize(self.ARR);
    end;

  function StackArray.add_head(const value: t_value): boolean;
    begin
      if(self.get_size() >= self.maxsize) then begin
        Result := False;
        exit;
      end;
      if(self.currentsize = self.maxsize - 1) then begin
        self.ARR[self.currentsize] := value;
        inc(self.currentsize);
        Result := True;
        exit;
      end;
      self.ARR[self.currentsize] := value;
      inc(self.currentsize);
      Result := True;
    end;

  function StackArray.del_head(): boolean;
    begin
      if(self.get_size() = 0) then begin
        Result := False;
        exit;
      end;
      dec(self.currentsize);
      Result := True;
    end;

	function StackArray.get_head(var value: t_value): boolean;
    begin
      if(self.get_size() = 0) then begin
        Result := False;
        exit;
      end;
      value := self.ARR[currentsize - 1];
      self.del_head();
      Result := True;
    end;

	function StackArray.get_size(): t_size;
    begin
      Result := self.currentsize;
    end;

	procedure StackArray.print();
    var
      i: t_size;
    begin
      for i := 0 to self.currentsize - 1 do write(self.ARR[i], ' ');
    end;


{
    QueueArray methods
    ==================
}
  constructor QueueArray.create(size: t_size);
    begin
      self.pStart := 0;
      self.pEnd := 0;
      self.currentsize := 0;
 	    self.maxsize := size;
      setLength(self.ARR, size);
     end;

  destructor QueueArray.destroy();
    begin
      finalize(self.ARR);
    end;

  function QueueArray.add_head(const value: t_value): boolean;
    begin
      if(self.get_size() >= self.maxsize) then begin
        Result := False;
        exit;
      end;
      if(self.get_size() = 0) then begin
        self.pStart := 0;
        self.ARR[self.pStart] := value;
        inc(self.currentsize);
        Result := True;
        exit;
      end;
      if(self.pStart = 0) then self.pStart := self.maxsize - 1 else dec(self.pStart);
      self.ARR[self.pStart] := value;
      inc(self.currentsize);
      Result := True;
    end;

  function QueueArray.del_tail(): boolean;
    begin
      if(self.get_size() = 0) then begin
        Result := False;
        exit;
      end;
      if(self.pEnd = 0) then self.pEnd := self.maxsize - 1 else dec(self.pEnd);
      dec(self.currentsize);
    end;

  function QueueArray.get_tail(var value: t_value): boolean;
    begin
      if(self.get_size() = 0) then begin
        Result := False;
        exit;
      end;
      value := self.ARR[pEnd];
      Result := self.del_tail();
    end;

  function QueueArray.get_size(): t_size;
    begin
      Result := self.currentsize;
    end;

  procedure QueueArray.print();
    var
      i, j: t_size;
    begin
      if(self.get_size() = 0) then exit;
      if(self.pStart <= self.pEnd) then
        for i := self.pStart to self.pEnd do write(self.ARR[i], ' ')
      else begin
        j := self.pStart;
        while j <> self.pEnd do begin
          write(self.ARR[j], ' ');
          inc(j);
          if(j >= self.maxsize) then j := 0;
        end;
        write(self.ARR[j], ' ');
      end;
    end;

{
    DQueueArray methods
    ===================
}
  function DQueueArray.add_tail(const value: t_value): boolean;
    begin
      if(self.get_size() >= self.maxsize) then begin
        Result := False;
        exit;
      end;
      if(self.get_size() = 0) then begin
        self.ARR[self.pEnd] := value;
        inc(self.currentsize);
        Result := True;
        exit;
      end;
      inc(self.pEnd);
      if(self.pEnd = self.maxsize) then self.pEnd := self.pEnd mod self.maxsize;
      self.ARR[self.pEnd] := value;
      inc(self.currentsize);
      Result := True;
    end;

  function DQueueArray.del_head(): boolean;
  begin
    if(self.get_size() = 0) then begin
      Result := False;
      exit;
    end;
    if(self.pStart + 1 = self.maxsize) then self.pStart := 0 else inc(self.pStart);
    dec(self.currentsize);
    Result := True;
  end;

  function DQueueArray.get_head(var value: t_value): boolean;
    begin end;

end.

