unit Rainbow;
interface
var
   RowNo: Integer;
procedure Render(DemoTime: Real);

implementation
uses Renderer, Config;

procedure Render(DemoTime: Real);
var
  X,Y,Value: Integer;
  speed: Real;
  VX,VY: Real;
  c:Byte;
begin
  speed := 0.4;
  c := 15;
  for Y := 0 to ScreenHeight-1 do
  begin
    if Config.Colors then
    begin
      c := 1 + (Y+Round(DemoTime*speed)) mod 5;
    end
    else
    begin
     if (Round(DemoTime*speed)) mod 5 = 0 then
       c := 0;
    end;

    for X := 1 to ScreenWidth  do
    begin
      OffscreenBuffer[Y * ScreenWidth + X] := (0 shl 12) or (c shl 8) or Ord(254);
    end;
  end;
end;


procedure RenderSlow(DemoTime: Real);
var
  X,Y,Value: Integer;
  zoom,speed: Real;
  VX,VY: Real;
  c:Byte;
begin
  zoom := 0.006;

  for Y := 0 to ScreenHeight-1 do
  for X := 1 to ScreenWidth  do
  begin
    VX := ((X+64)*(4+cos(DemoTime*0.06)*3))*zoom ;
    VY := ((Y)*(4+sin(DemoTime*0.07)*3))*zoom;
    Value := Round(VX+VY);
    c:=8;
    if Value mod 2 = 0 then c:=7;
    if Value mod 3 = 0 then c:=4;

    OffscreenBuffer[Y * ScreenWidth + X] := (0 shl 12) or (c shl 8) or Ord(219);
  end;
end;

end.