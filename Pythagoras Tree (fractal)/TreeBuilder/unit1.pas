unit Unit1;

{$mode objfpc}{$H+}{$R+}{$I+}

interface

{
_________________________________________________

Другой вариант реализации :

Дано векторы: x1, x2

1) t = x2 - x1 = (tx, ty)
2) n = (-ty, tx) (вектор повернутый на пи\2 влево относительно t)
3) x3 = x1 + n; x4 = x2 + n;
4) x5 = x3 + 0.5t + h * n\|n| , |n| = sqrt(x^2 + y^2)

  x_5
 /   \
x3___x4
|     |
x1___x2
 ----> t

5) Передаем точки x3, x5 в левую рекурсивную процедуру
6) Передаем x5, x4 в правую рекурсивную процедуру

|n| = sqrt(x^2 + y^2)
_________________________________________________

}

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Spin, StdCtrls, EditBtn, ButtonPanel;

type
  { TForm1 }
  tPoint = record
   x: double;
   y: double;
  end;

  TForm1 = class(TForm)
    BitMap: TBitmap;
    Button1: TButton;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Pif(Center: tPoint; A: double; fi, Deep: integer);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure Turn(var A, B: tPoint; fi: integer);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  A, fi, Maxdeep: integer;
  Start: tPoint;

implementation
{$R *.lfm}
{ TForm1 }
procedure TForm1.FormCreate(Sender: TObject);
begin
  fi := 0;
  A := TSpinEdit(SpinEdit2).Value;
  Maxdeep := 1;
  Start.x := Self.Width div 2 - A div 2;
  Start.y := Self.Height - (60 + A);
  BitMap := TBitmap.Create;
  BitMap.SetSize(Screen.DesktopWidth, Screen.DesktopHeight);
  BitMap.Canvas.Pen.Color := $00ffff;
  BitMap.Canvas.Brush.Color := clBlack;
  BitMap.Canvas.FillRect(Canvas.ClipRect);
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  //перерисовка изображения при изменении параметров окна
  Form1.Canvas.Draw(0, 0, Bitmap);
end;

procedure TForm1.Turn(var A, B: tPoint; fi: integer);
var
  C : tPoint;
begin
  //поворот точки A относительно точки B на угол fi
  C.x := B.x + (A.x - B.x) * cos(fi / 180 * pi) - (A.y - B.y) * sin(fi / 180 * pi);
  C.y := B.y + (A.x - B.x) * sin(fi / 180 * pi) + (A.y - B.y) * cos(fi / 180 * pi);
  A := C;
end;

procedure TForm1.Pif(Center: tPoint; A: double; fi, Deep: integer);
var
  Temp, RCenter, LCenter: tPoint;
begin
  if(Deep = 0) then exit else dec(Deep);
  BitMap.Canvas.MoveTo(round(Center.x), round(Center.y));
  // SQARE {1}
  Temp := Center;
  Temp.y += A;
  Turn(Temp, Center, fi);
  BitMap.Canvas.LineTo(round(Temp.x), round(Temp.y));
  {2}
  Temp := Center;
  Temp.x += A;
  Temp.y += A;
  Turn(Temp, Center, fi);
  BitMap.Canvas.LineTo(round(Temp.x), round(Temp.y));
  {3}
  Temp := Center;
  Temp.x += A;
  Turn(Temp, Center, fi);
  BitMap.Canvas.LineTo(round(Temp.x), round(Temp.y));
  {4}
  BitMap.Canvas.LineTo(round(Center.x), round(Center.y));
  // TREANGLE {1}
  A := A / 2;
  Temp := Center;
  Temp.x += A;
  Temp.y -= A;
  Turn(Temp, Center, fi);
  BitMap.Canvas.LineTo(round(Temp.x), round(Temp.y));
  {2}
  Temp := Center;
  Temp.x += 2*A;
  Turn(Temp, Center, fi);
  BitMap.Canvas.LineTo(round(Temp.x), round(Temp.y));
  // R CENTER
  RCenter.x := Center.x + 2*A;
  RCenter.y := Center.y - 2*A;
  Turn(RCenter, Center, fi);
  // L CENTER
  LCenter.x := Center.x - A;
  LCenter.y := Center.y - A;
  Turn(LCenter, Center, fi);
  // Repeat
  A := A*sqrt(2);
  Pif(RCenter, A, (fi + 45) mod 360, Deep);
  Pif(LCenter, A, (fi - 45) mod 360, Deep);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  TButton(Sender).Enabled := False;
  BitMap.Canvas.FillRect(Canvas.ClipRect);
  //Запуск Дерева Пифагора
  Pif(Start, A, fi, Maxdeep);
  Form1.Canvas.Draw(0,0,Bitmap);
  TButton(Sender).Enabled := True;
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
  Maxdeep := TSpinEdit(Sender).value;
end;

procedure TForm1.SpinEdit2Change(Sender: TObject);
begin
  A := TSpinEdit(Sender).value;
  Start.x := Self.Width div 2 - A div 2;
  Start.y := Self.Height - (60 + A);
end;


end.

