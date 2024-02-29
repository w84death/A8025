unit Level;

interface

procedure Load(const LevelID: Byte);
procedure Render;
procedure SetCell(X,Y: Byte; Data: Byte);
function GetCell(X,Y: Byte): Byte;

implementation

uses
  Config, Renderer;

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
  FileName: string[2];
begin
  Str(LevelID, FileName);
  Assign(AscFile, 'Level' + FileName + '.asc');
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
  f,b:Byte;
begin
  f:=15;
  b:=0;
 for i := 1 to ScreenSize do
  begin
    if LevelData[i] <> Ord(' ') then
    begin
      if Config.Colors then
      begin
      f:=8;
      b:=0;
      Case LevelData[i] of
        Ord('ß'): f:=15;
        Ord('Ã'): f:=5;
        Ord('Ä'): f:=5;
        Ord('´'): f:=5;
        Ord('$'):
          begin
            f:=0;
            b:=2;
          end;
      end;
      end;
      OffScreenBuffer[i] := (b shl 12) or (f shl 8) or Ord(LevelData[i]);
    end;
  end;
end;

procedure SetCell(X,Y: Byte; Data: Byte);
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