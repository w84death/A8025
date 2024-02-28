unit Level;

interface

procedure Load(const LevelID: Byte);
procedure Render;
procedure SetCell(X,Y: Byte, Data: Byte);
function GetCell(X,Y: Byte): Byte;

implementataion
uses
  Config, Renderer
type
  TLevel = array[1..ScreenSize] of Byte;

var
  LevelData: TLevel;
  LastLevel: Byte;
  Current: Byte;
  
procedure Load(const LevelID: Byte);
var
  X, Y, AscWidth, AscHeight: Byte;
  AscFile: Text;
  AscLine: string;
begin
  Assign(AscFile, 'Level'+IntToStr(LevelID)+'.asc');
  Reset(AscFile);

  for y := 0 to ScreenHeight do
  begin
    ReadLn(AscFile, AscLine);
    for x := 1 to High(AscLine) do
    begin
      LevelData[y*ScreenWidth+x] := Ord(AscLine[x]);
    end;
  end;
  Close(AscFile);
end;

procedure Render;
var
  i,n:Integer;
  c:Byte;
begin
 for i := 1 to ScreenSize do
  begin
    if Level[i] <> Ord(' ') then
    begin
      c:=8;
      Case Level[i] of
        Ord('�'): c:=15;
      end;
      OffScreenBuffer[i] := (Black shl 12) or (c shl 8) or Ord(Level[i]);
    end;
  end;
end;

procedure SetCell(X,Y: Byte, Data: Byte);
begin
  LevelData[Y*ScreenWidth+X] := Data; 
end;

function GetCell(X,Y: Byte): Byte;
begin
  GetCell := LevelData[Y*ScreenWidth+X];
end;


begin
  LastLevel := 2;
  Current := 1;
  Level.Load(Current);
end.