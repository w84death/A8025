unit Fire;
interface

procedure ClearBuffer;
procedure Render(DemoTime: Real);

implementation
uses Renderer, Config;
type
  TFireBuffer = array[1..ScreenSize] of Byte;

var
  FireBuffer: TFireBuffer;

procedure ClearBuffer;
var
  i: Integer;
begin
  for i := 1 to ScreenSize do
    FireBuffer[i] := 0;
end;

procedure Render(DemoTime:Real);
var
  x, y: Integer;
  randI, new: Integer;
  fireChars: array[0..7] of Char;
  fireColors: array[0..7] of Byte;
begin
  fireChars[0] := ' ';
  fireChars[1] := '.';
  fireChars[2] := ',';
  fireChars[3] := '%';
  fireChars[4] := 'O';
  fireChars[5] := '@';
  fireChars[6] := '8';
  fireChars[7] := '#';
  fireColors[0] := 8;
  fireColors[1] := 8;
  fireColors[2] := 4;
  fireColors[3] := 4;
  fireColors[4] := 4;
  fireColors[5] := 12;
  fireColors[6] := 14;
  fireColors[7] := 15;

  if Round(DemoTime*100) mod 100 = 0 then
  begin

  if Round(DemoTime) mod 8 = 0 then
  begin
    FireBuffer[1920+Random(80)]:=0;
    FireBuffer[1920+Random(80)]:=4+Random(4);
  end;

  for y := 0 to ScreenHeight - 2 do
    for x := 0 to ScreenWidth - 1 do
    begin
      randI := (y + 1) * ScreenWidth + x + Random(3) - 1;
      new := FireBuffer[randI] - (Random(2) and 1);
      if new < 0 then new := 0;
      FireBuffer[y * ScreenWidth + x] := new;
      OffscreenBuffer[y * ScreenWidth + x] := (0 shl 12) or (fireColors[new] shl 8) or Ord(fireChars[new]);
    end;
  end;
end;

begin
  Renderer.ClearBuffer;
  ClearBuffer;
end.