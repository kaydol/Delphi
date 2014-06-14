{

  Тетрино
    Игрушка создана студентом направления Прикладная математика и информатика
    Карпов Денис, 2014.
}



unit Tetrino_Main;
{$mode objfpc}{$H+}

interface

uses
  LCLType, Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, EditBtn, LResources,
  Tetrino_Grid;

const
  TIMER_START_VALUE = 500;
  PLAYER_SCORE_FOR_GODLIKE = 18000;
  PLAYER_HARD_FOR_GODLIKE = 80;

type
  TForm1 = class(TetrinoGrid)
    Timer1: TTimer;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
    procedure DrawHUD();
    procedure Create_Grid();
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure CheckScore();
    procedure GameOver();
  private
    { private declarations }
  public
    { public declarations }
  end;


var
  Form1: TForm1;
  Bitmap: TBitmap;
  isGodlike, isPause: boolean;
  Start, StartPreview: tPoint;
  A: integer; //размер клеток поля
  TimeSpeed: word;
  PlayerScore, Lines: dword;

implementation

procedure TForm1.Create_Grid();
var
  TempPoint: tPoint;
  x, y: byte;
begin
  Create_Figure();
  BitMap.Canvas.Brush.Color := clBlack;
  BitMap.Canvas.FillRect(Canvas.ClipRect);
  TempPoint := Start;
  for y := 5 to 25 do begin
    for x := 1 to 10 do begin
      case GRID[x,y] mod 10 of
        0 : BitMap.Canvas.Brush.Color := clBlack;       // Empty Square
        1 : BitMap.Canvas.Brush.Color := clAqua;        // I
        2 : BitMap.Canvas.Brush.Color := clBlue;        // J
        3 : BitMap.Canvas.Brush.Color := $00ffff;       // L
        4 : BitMap.Canvas.Brush.Color := clYellow;      // O
        5 : BitMap.Canvas.Brush.Color := clGreen;       // S
        6 : BitMap.Canvas.Brush.Color := clPurple;      // T
        7 : BitMap.Canvas.Brush.Color := clRed;         // Z
      end;
      Bitmap.Canvas.Rectangle(round(TempPoint.x), round(TempPoint.y), round(TempPoint.x)+A, round(TempPoint.y)+A);
      TempPoint.x += A;
    end;
    TempPoint.x := Start.x;
    TempPoint.y += A;
  end;
  TempPoint := StartPreview;
  for y := 1 to 4 do begin
    for x := 1 to 4 do begin
      case Preview[x,y] of
        0 : BitMap.Canvas.Brush.Color := clBlack;       // Empty Square
        1 : BitMap.Canvas.Brush.Color := clAqua;        // I
        2 : BitMap.Canvas.Brush.Color := clBlue;        // J
        3 : BitMap.Canvas.Brush.Color := $00ffff;       // L
        4 : BitMap.Canvas.Brush.Color := clYellow;      // O
        5 : BitMap.Canvas.Brush.Color := clGreen;       // S
        6 : BitMap.Canvas.Brush.Color := clPurple;      // T
        7 : BitMap.Canvas.Brush.Color := clRed;         // Z
      end;
      Bitmap.Canvas.Rectangle(round(TempPoint.x), round(TempPoint.y), round(TempPoint.x)+A, round(TempPoint.y)+A);
      TempPoint.x += A;
    end;
    TempPoint.x := StartPreview.x;
    TempPoint.y += A;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  A := 30;
  Start.x := A;
  Start.y := A + 20;
  StartPreview.x := A*12;
  StartPreview.y := A + 70;
  PlayerScore := 0;
  isGodlike := False;
  isPause := False;
  Lines := 0;
  TimeSpeed := TIMER_START_VALUE;
  Timer1.Interval := TIMER_START_VALUE;
  BitMap := TBitmap.Create;
  BitMap.SetSize(Screen.DesktopWidth, Screen.DesktopHeight);
  BitMap.Canvas.Pen.Color := clGray;
  BitMap.Canvas.Brush.Color := clBlack;
  BitMap.Canvas.FillRect(Canvas.ClipRect);

  randomize;
  CurrentFigure := random(7)+1;
  Spawn(CurrentFigure);
  FutureFigure := random(7)+1;
  UpdatePreview(FutureFigure);
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  //перерисовка изображения при изменении параметров окна
  Form1.Canvas.Draw(0, 0, Bitmap);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  x, y, i, j: integer;
begin
  if Key = VK_SPACE then begin
    if isGameOver() then exit;
    if not isPause then begin
      if PlayerScore > 100 then PlayerScore -= 100;
      PlayRezSound('Pause');
      TTimer(Timer1).Enabled := False;
      TTimer(Timer2).Enabled := False;

      Bitmap.Canvas.Font.Size := 20;
      Bitmap.Canvas.Font.Color := clAQUA;
      Bitmap.Canvas.TextOut(Form1.Width div 2 - 100, Form1.Height div 2, 'PAUSED');
      Form1.Canvas.Draw(0, 0, Bitmap);

      isPause := True;
    end else begin
      TTimer(Timer1).Enabled := True;
      TTimer(Timer2).Enabled := True;
      isPause := False;
    end;
  end;

  if isPause then exit;
  Create_Figure();
  if Key = VK_RIGHT then begin
    i := 0;
    j := 0;
    //finding figure
    for x := 10 downto 1 do begin
      for y := 25 downto 1 do
        if GRID[x,y] > 10 then begin
          i := x;
          j := y;
          break;
        end;
      if (i = x) and (j = y) then break;
    end;
    //if not found
    if i + j = 0 then exit;
    if Check_right(i,j,GRID[i,j]) then Here.x += 1;
  end;

  if Key = VK_LEFT then begin
    i := 0;
    j := 0;
    //finding figure
    for x := 1 to 10 do begin
      for y := 25 downto 1 do
        if GRID[x,y] > 10 then begin
          i := x;
          j := y;
          break;
        end;
      if (i = x) and (j = y) then break;
    end;
    //if not found
    if i + j = 0 then exit;

    if Check_left(i,j,GRID[i,j]) then Here.x -= 1;
  end;

  if Key = VK_UP then begin
    if CurrentFigure = 1 then { === I === }
      if CurrentState = 1 then begin
        if (Here.x < 1) or (Here.x > 7) then exit;
        if not isClear(
          Here.x+4-1,Here.y+3-1,
          Here.x+2-1,Here.y+3-1,
          Here.x+1-1,Here.y+3-1,
          Square[3,3]
        ) then exit;
        Square[3,1] := 0;
        Square[3,2] := 0;
        Square[3,4] := 0;
        Square[4,3] := Square[3,3];
        Square[2,3] := Square[3,3];
        Square[1,3] := Square[3,3];
        CurrentState := 0;
        exit;
      end else begin
        if (Here.x < 1) or (Here.x > 7) then exit;
        if not isClear(
          Here.x+3-1,Here.y+1-1,
          Here.x+3-1,Here.y+2-1,
          Here.x+3-1,Here.y+4-1,
          Square[3,3]
        ) then exit;
        Square[3,1] := Square[3,3];
        Square[3,2] := Square[3,3];
        Square[3,4] := Square[3,3];
        Square[4,3] := 0;
        Square[2,3] := 0;
        Square[1,3] := 0;
        CurrentState := 1;
        exit;
      end;
    if CurrentFigure = 2 then { === J === }
      case CurrentState of
        0 : begin
          if not isClear(
            Here.x+2-1,Here.y+1-1,
            Here.x+3-1,Here.y+1-1,
            Here.x+2-1,Here.y+3-1,
            Square[2,2]
          ) then exit;
          Square[1,1] := 0;
          Square[1,2] := 0;
          Square[3,2] := 0;
          Square[2,1] := Square[2,2];
          Square[3,1] := Square[2,2];
          Square[2,3] := Square[2,2];
          CurrentState := 1;
          exit;
        end;
        1 : begin
          if not isClear(
            Here.x+1-1,Here.y+2-1,
            Here.x+3-1,Here.y+2-1,
            Here.x+3-1,Here.y+3-1,
            Square[2,2]
          ) then exit;
          Square[2,1] := 0;
          Square[3,1] := 0;
          Square[2,3] := 0;
          Square[1,2] := Square[2,2];
          Square[3,2] := Square[2,2];
          Square[3,3] := Square[2,2];
          CurrentState := 2;
          exit;
        end;
        2 : begin
          if not isClear(
            Here.x+2-1,Here.y+1-1,
            Here.x+1-1,Here.y+3-1,
            Here.x+2-1,Here.y+3-1,
            Square[2,2]
          ) then exit;
          Square[1,2] := 0;
          Square[3,2] := 0;
          Square[3,3] := 0;
          Square[2,1] := Square[2,2];
          Square[1,3] := Square[2,2];
          Square[2,3] := Square[2,2];
          CurrentState := 3;
          exit;
        end;
        3 :  begin
          if not isClear(
            Here.x+1-1,Here.y+1-1,
            Here.x+1-1,Here.y+2-1,
            Here.x+3-1,Here.y+2-1,
            Square[2,2]
          ) then exit;
          Square[2,1] := 0;
          Square[1,3] := 0;
          Square[2,3] := 0;
          Square[1,1] := Square[2,2];
          Square[1,2] := Square[2,2];
          Square[3,2] := Square[2,2];
          CurrentState := 0;
          exit;
        end;
      end;
    if CurrentFigure = 3 then { === L === }
      case CurrentState of
        0 : begin
          if not isClear(
            Here.x+2-1,Here.y+1-1,
            Here.x+3-1,Here.y+3-1,
            Here.x+2-1,Here.y+3-1,
            Square[2,2]
          ) then exit;
          Square[1,2] := 0;
          Square[3,1] := 0;
          Square[3,2] := 0;
          Square[2,1] := Square[2,2];
          Square[3,3] := Square[2,2];
          Square[2,3] := Square[2,2];
          CurrentState := 1;
          exit;
        end;
        1 : begin
          if not isClear(
            Here.x+1-1,Here.y+2-1,
            Here.x+3-1,Here.y+2-1,
            Here.x+1-1,Here.y+3-1,
            Square[2,2]
          ) then exit;
          Square[2,1] := 0;
          Square[2,3] := 0;
          Square[3,3] := 0;
          Square[1,2] := Square[2,2];
          Square[3,2] := Square[2,2];
          Square[1,3] := Square[2,2];
          CurrentState := 2;
          exit;
        end;
        2 : begin
          if not isClear(
            Here.x+2-1,Here.y+1-1,
            Here.x+1-1,Here.y+1-1,
            Here.x+2-1,Here.y+3-1,
            Square[2,2]
          ) then exit;
          Square[1,2] := 0;
          Square[3,2] := 0;
          Square[1,3] := 0;
          Square[2,1] := Square[2,2];
          Square[1,1] := Square[2,2];
          Square[2,3] := Square[2,2];
          CurrentState := 3;
          exit;
        end;
        3 :  begin
          if not isClear(
            Here.x+1-1,Here.y+2-1,
            Here.x+3-1,Here.y+1-1,
            Here.x+3-1,Here.y+2-1,
            Square[2,2]
          ) then exit;
          Square[1,1] := 0;
          Square[2,1] := 0;
          Square[2,3] := 0;
          Square[1,2] := Square[2,2];
          Square[3,1] := Square[2,2];
          Square[3,2] := Square[2,2];
          CurrentState := 0;
          exit;
        end;
      end;
    if CurrentFigure = 4 then { === O === }
      exit;
    if CurrentFigure = 5 then { === S === }
      case CurrentState of
        0 : begin
          if not isClear(
            Here.x+1-1,Here.y+1-1,
            Here.x+2-1,Here.y+3-1,
            1,1,
            Square[2,2]
          ) then exit;
          Square[2,1] := 0;
          Square[3,1] := 0;
          Square[1,1] := Square[2,2];
          Square[2,3] := Square[2,2];
          CurrentState := 1;
          exit;
        end;
        1 : begin
          if not isClear(
            Here.x+2-1,Here.y+1-1,
            Here.x+3-1,Here.y+1-1,
            1,1,
            Square[2,2]
          ) then exit;
          Square[1,1] := 0;
          Square[2,3] := 0;
          Square[2,1] := Square[2,2];
          Square[3,1] := Square[2,2];
          CurrentState := 0;
          exit;
        end;
      end;
    if CurrentFigure = 6 then { === T === }
      case CurrentState of
        0 : begin
          if (Here.x < 1) or (Here.x > 8) then exit;
          if not isClear(
            Here.x+2-1,Here.y+3-1,
            1,1,
            1,1,
            Square[2,2]
          ) then exit;
          Square[1,2] := 0;
          Square[2,3] := Square[2,2];
          CurrentState := 1;
          exit;
        end;
        1 : begin
         if (Here.x < 1) or (Here.x > 8) then exit;
          if not isClear(
            Here.x+1-1,Here.y+2-1,
            1,1,
            1,1,
            Square[2,2]
          ) then exit;
          Square[2,1] := 0;
          Square[1,2] := Square[2,2];
          CurrentState := 2;
          exit;
        end;
        2 : begin
          if not isClear(
            Here.x+2-1,Here.y+1-1,
            1,1,
            1,1,
            Square[2,2]
          ) then exit;
          Square[3,2] := 0;
          Square[2,1] := Square[2,2];
          CurrentState := 3;
          exit;
        end;
        3 :  begin
          if not isClear(
            Here.x+3-1,Here.y+2-1,
            1,1,
            1,1,
            Square[2,2]
          ) then exit;
          Square[2,3] := 0;
          Square[3,2] := Square[2,2];
          CurrentState := 0;
          exit;
        end;
      end;
    if CurrentFigure = 7 then { === Z === }
      case CurrentState of
        0 : begin
          if not isClear(
            Here.x+1-1,Here.y+2-1,
            Here.x+1-1,Here.y+3-1,
            1,1,
            Square[2,2]
          ) then exit;
          Square[1,1] := 0;
          Square[3,2] := 0;
          Square[1,2] := Square[2,2];
          Square[1,3] := Square[2,2];
          CurrentState := 1;
          exit;
        end;
        1 : begin
          if not isClear(
            Here.x+1-1,Here.y+1-1,
            Here.x+3-1,Here.y+2-1,
            1,1,
            Square[2,2]
          ) then exit;
          Square[1,2] := 0;
          Square[1,3] := 0;
          Square[1,1] := Square[2,2];
          Square[3,2] := Square[2,2];
          CurrentState := 0;
          exit;
        end;
      end;
  end;

  if Key = VK_DOWN then begin
    Timer1.Interval := TIMER_START_VALUE div 10;
  end;

  if Key = VK_R then begin
    for y := 1 to 25 do
      for x := 1 to 10 do
        GRID[x,y] := 0;
    Spawn(FutureFigure);
    CurrentFigure := FutureFigure;
    FutureFigure := random(7)+1;
    UpdatePreview(FutureFigure);
    Lines := 0;
    PlayerScore := 0;
    TimeSpeed := TIMER_START_VALUE;
    Timer1.Interval := TIMER_START_VALUE;
    TTimer(Timer1).Enabled := True;
    TTimer(Timer2).Enabled := True;
  end;
end;

{
    ACTIONS
    =======
}

procedure TForm1.GameOver();
begin
  Bitmap.Canvas.Font.Color := clRed;
  Bitmap.Canvas.Font.Size := 18;
  Bitmap.Canvas.TextOut(6*A, Form1.Height div 2, 'GAME OVER!' );
  Bitmap.Canvas.Font.Size := 16;
  Bitmap.Canvas.TextOut(5*A, Form1.Height div 2 + 2*A, 'PRESS R TO RESTART' );
  Form1.Canvas.Draw(0, 0, Bitmap);
  Timer1.Interval := TIMER_START_VALUE;
  Timer1.Enabled := False;
  Timer2.Enabled := False;
  PlayRezSound('Gameover');
end;

{
    USER INTERFACE
    ==============
}

procedure TForm1.DrawHUD();
begin
  Bitmap.Canvas.Font.Color := clWhite;
  Bitmap.Canvas.Font.Name := 'Tahoma';
  Bitmap.Canvas.Font.Size := 20;
  Bitmap.Canvas.Font.Style := [fsitalic, fSBold];
  Bitmap.Canvas.TextOut(30, 10, 'TETRINO 2014' );
  Bitmap.Canvas.TextOut(80 + 10*A, 2*A, 'NEXT:' );
  Bitmap.Canvas.TextOut(70 + 10*A, 8*A + 10, 'SCORE:' );
  Bitmap.Canvas.TextOut(70 + 10*A, 11*A + 10, 'LINES:' );
  Bitmap.Canvas.TextOut(70 + 10*A, 14*A + 10, 'HARD:' );
  Bitmap.Canvas.Font.Size := 16;
  Bitmap.Canvas.TextOut(60 + 11*A, 9*A + 20, IntToStr(PlayerScore) );
  Bitmap.Canvas.TextOut(60 + 11*A, 12*A + 20, IntToStr(Lines) );
  Bitmap.Canvas.TextOut(60 + 11*A, 15*A + 20, IntToStr( round( (TIMER_START_VALUE-TimeSpeed)/TIMER_START_VALUE*100 )) + '%');

  Bitmap.Canvas.Font.Size := 10;
  Bitmap.Canvas.TextOut(80 + 9*A, 20*A, 'Pause - Space' );
  Bitmap.Canvas.TextOut(80 + 9*A, 21*A, 'Restart - R' );
  Bitmap.Canvas.TextOut(80 + 9*A, 22*A, 'Control - Arrows' );

  if ((TIMER_START_VALUE-TimeSpeed)/TIMER_START_VALUE*100 > PLAYER_HARD_FOR_GODLIKE) and (PlayerScore > PLAYER_SCORE_FOR_GODLIKE) then begin
    if not isGodlike then begin
      PlayRezSound('Achievement');
      isGodlike := True;
    end;
    Bitmap.Canvas.Font.Size := 20;
    Bitmap.Canvas.Font.Color := clYELLOW;
    Bitmap.Canvas.TextOut(50 + 10*A, 17*A, ' YOU''RE');
    Bitmap.Canvas.TextOut(50 + 10*A, 18*A, 'GODLIKE');
  end;
end;


{
    TIMERS
    ======
}

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  Create_Grid();
  DrawHUD();
  Form1.Canvas.Draw(0, 0, Bitmap);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  x, y: byte;
  i, j: byte;
begin
  Create_Figure();
  i := 0;
  j := 0;
  //finding figure
  for y := 25 downto 1 do begin
    for x := 1 to 10 do
      if GRID[x,y] > 10 then begin
        i := x;
        j := y;
        break;
      end;
    if (i = x) and (j = y) then break;
  end;
  //if not found
  if i + j = 0 then exit;

  //if we touched another figure OR bottom is reached
  if not Check(i,j,GRID[i,j]) then begin
    Freeze();
    if isGameOver then GameOver;
    Timer1.Interval := TimeSpeed;
    CheckScore();
    TimeSpeed := Timer1.Interval;
    Spawn(FutureFigure);
    CurrentFigure := FutureFigure;
    FutureFigure := random(7)+1;
    UpdatePreview(FutureFigure);
  end else
  //moving figure down
  HERE.y += 1;
end;

procedure TForm1.CheckScore();
var
  x, y: byte;
  Bool: Boolean;
  kombo: integer;
begin
  y := 25;
  kombo := 0;
  while y > 5 do begin
    Bool := True;
    for x := 1 to 10 do
      if GRID[x,y] = 0 then begin
        Bool := False;
        break;
      end;
    if Bool then begin
      Inc(kombo);
      for x := 1 to 10 do
        GRID[x,y] := 0;
      MoveDownGrid(y);
      PlayerScore += (100 + (TIMER_START_VALUE-TimeSpeed))*kombo;
      if TimeSpeed >= 10 then begin
        TimeSpeed -= 10;
        Timer1.Interval := TimeSpeed;
      end;
      inc(Lines);
      PlayRezSound('Bonus');
      Continue;
    end;
    Dec(y);
  end;
end;


end.
