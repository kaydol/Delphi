unit Tetrino_Grid;
{$mode objfpc}{$H+}

interface

uses
  LCLType, Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, EditBtn, LResources,
  Tetrino_Effects;

type
  tPoint = record
   x: integer;
   y: integer;
  end;

  TetrinoGrid = class(TetrinoEffects)
    public
    procedure Create_Figure();
    procedure MoveDownGrid(y: byte);
    procedure Spawn(figure: byte);
    procedure UpdatePreview(FutureFigure: byte);
    procedure Freeze();

    function isGameOver(): boolean;
    function check(x,y, col: byte): boolean;
    function check_left(x, y, col: byte): boolean;
    function check_right(x, y, col: byte): boolean;
    function isClear(a1,a2, b1,b2, c1,c2, colour: byte): boolean;

  end;

var
  GRID: array [1..10, 1..25] of byte =
    ((0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));
  Preview: array [1..4, 1..4] of byte =
    ((0,0,0,0),
    (0,0,0,0),
    (0,0,0,0),
    (0,0,0,0));
  Square: array [1..4, 1..4] of byte =
    ((0,0,0,0),
    (0,0,0,0),
    (0,0,0,0),
    (0,0,0,0));
  Here: tPoint;
  CurrentFigure, CurrentState, FutureFigure: byte;


implementation

procedure TetrinoGrid.Freeze();
var
  x, y, count: byte;
begin
  count := 0;
  for y := 25 downto 5 do
    for x := 1 to 10 do
      if GRID[x,y] > 10 then begin
        inc(count);
        GRID[x,y] := GRID[x,y] - 10;
        if count = 4 then exit;
      end;
end;

procedure TetrinoGrid.UpdatePreview(FutureFigure: byte);
var
  i, j: byte;
begin
  for i:= 1 to 4 do
    for j := 1 to 4 do
      Preview[i,j] := 0;

  case FutureFigure of
    1: begin // I
      Preview[1,3] := 1;
      Preview[2,3] := 1;
      Preview[3,3] := 1;
      Preview[4,3] := 1;
    end;
    2: begin // J
      Preview[1,1] := 2;
      Preview[1,2] := 2;
      Preview[2,2] := 2;
      Preview[3,2] := 2;
    end;
    3: begin // L
      Preview[3,1] := 3;
      Preview[1,2] := 3;
      Preview[2,2] := 3;
      Preview[3,2] := 3;
    end;
    4: begin // O
      Preview[1,1] := 4;
      Preview[2,1] := 4;
      Preview[1,2] := 4;
      Preview[2,2] := 4;
    end;
    5: begin // S
      Preview[2,1] := 5;
      Preview[3,1] := 5;
      Preview[1,2] := 5;
      Preview[2,2] := 5;
    end;
    6: begin // T
      Preview[2,1] := 6;
      Preview[1,2] := 6;
      Preview[2,2] := 6;
      Preview[3,2] := 6;
    end;
    7: begin // Z
      Preview[1,1] := 7;
      Preview[2,1] := 7;
      Preview[2,2] := 7;
      Preview[3,2] := 7;
    end;
  end;
end;

procedure TetrinoGrid.Spawn(figure: byte);
var
  x, y: byte;
begin
  for x := 1 to 4 do
    for y := 1 to 4 do
      Square[x,y] := 0;

  //initial state
  CurrentState := 0;
  Here.x := 4;
  Here.y := 2;

  case figure of
    1: begin // I
      Square[1,3] := 11;
      Square[2,3] := 11;
      Square[3,3] := 11;
      Square[4,3] := 11;
    end;
    2: begin // J
      Square[1,1] := 12;
      Square[1,2] := 12;
      Square[2,2] := 12;
      Square[3,2] := 12;
    end;
    3: begin // L
      Square[3,1] := 13;
      Square[1,2] := 13;
      Square[2,2] := 13;
      Square[3,2] := 13;
    end;
    4: begin // O
      Square[1,1] := 14;
      Square[2,1] := 14;
      Square[1,2] := 14;
      Square[2,2] := 14;
    end;
    5: begin // S
      Square[2,1] := 15;
      Square[3,1] := 15;
      Square[1,2] := 15;
      Square[2,2] := 15;
    end;
    6: begin // T
      Square[2,1] := 16;
      Square[1,2] := 16;
      Square[2,2] := 16;
      Square[3,2] := 16;
    end;
    7: begin // Z
      Square[1,1] := 17;
      Square[2,1] := 17;
      Square[2,2] := 17;
      Square[3,2] := 17;
    end;
  end;
end;

procedure TetrinoGrid.MoveDownGrid(y: byte);
var
  x: byte;
begin
  for y := y downto 6 do
    for x := 1 to 10 do
      GRID[x,y] := GRID[x,y-1];
end;

procedure TetrinoGrid.Create_Figure();
var
  x, y: byte;
begin
  //deleting the old figure
  for y := 1 to 25 do
    for x := 1 to 10 do
      if GRID[x,y] > 10 then GRID[x,y] := 0;
  //creating a new one
  for x := 1 to 4 do
    for y := 1 to 4 do begin
      if Square[x,y] <> 0 then
        GRID[HERE.x+x-1,HERE.y+y-1] := Square[x,y];
    end;
end;

function TetrinoGrid.isClear(a1,a2, b1,b2, c1,c2, colour: byte): boolean;
begin
  Result := True;
  if (a1 > 10) or (b1 > 10) or (c1 > 10)
  or (a1 < 1) or (b1 < 1) or (c1 < 1)
  or (a2 > 25) or (b2 > 25) or (c2 > 25)
  or ((GRID[a1,a2] <> 0) and (GRID[a1,a2] <> colour))
  or ((GRID[b1,b2] <> 0) and (GRID[b1,b2] <> colour))
  or ((GRID[c1,c2] <> 0) and (GRID[c1,c2] <> colour))
  then Result := False;
end;

function TetrinoGrid.Check(x,y, col: byte): boolean;
begin
  if (y = 25) then begin
    Result := False;
    exit;
  end;
  if (y < 5) then begin
    Result := True;
    exit;
  end;

  for y := y downto y-4 do
    for x := 1 to 10 do
      if (GRID[x,y] = col) then begin
        if (GRID[x,y+1] <> 0) and (GRID[x,y+1] <> col) then begin
          Result := False;
          exit;
        end;
      end;
  Result := True;
end;

function TetrinoGrid.Check_left(x,y, col: byte): boolean;
begin
  if (x = 1) then begin
    Result := False;
    exit;
  end;
  for x := x to 10 do
    for y := 25 downto 1 do
      if (GRID[x,y] = col) then begin
        if (GRID[x-1,y] <> 0) and (GRID[x-1,y] <> col) then begin
          Result := False;
          exit;
        end;
      end;
  Result := True;
end;

function TetrinoGrid.Check_right(x,y, col: byte): boolean;
begin
  if (x = 10) then begin
    Result := False;
    exit;
  end;
  for x := 10 downto x do
    for y := 25 downto 1 do
      if (GRID[x,y] = col) then begin
        if (GRID[x+1,y] <> 0) and (GRID[x+1,y] <> col) then begin
          Result := False;
          exit;
        end;
      end;
  Result := True;
end;

function TetrinoGrid.isGameOver(): boolean;
var
  x: byte;
begin
  for x := 1 to 10 do
    if (GRID[x,5] <> 0) and (GRID[x,5] < 10) then begin
      Result := True;
      exit;
    end;
  Result := False;
end;

end.

