unit Player;

interface

type
  TPlayer = record
    X,Y: Integer;
    Frames: array[1..9] of String;
    Width, Height: Byte;
    Frame: Byte;
    HP: Byte;
    Jump: Byte;
    OnGround: Boolean;
    Score: Byte;
    Resource: Byte;
    Direction: Byte;
  end;

var
  One, Two: TPlayer;

function StandsOnGround: Boolean;
function CanBuildLadder: Boolean;
procedure Render(DemoTime: Real);

implementation
uses
  Config, Renderer, Level;

function CanBuildLadder: Boolean;
var
 block:Byte;
begin
 block := Level.GetCell(One.X, One.Y);
 if (block <>  Ord('ß')) and (block <> Ord('Ã')) and (block <> Ord('´')) then
 begin
   CanBuildLadder := True;
 end
 else
 begin
   CanBuildLadder := False;
 end;
end;

function StandsOnGround: Boolean;
var
  block:Byte;
begin
 block := Level.GetCell(One.X, One.Y + 1);
 if (block <>  Ord('ß')) and (block <> Ord('Ã')) and (block <> Ord('Ä')) and (block <> Ord('´')) then
 begin
   StandsOnGround := True;
 end
 else
 begin
   StandsOnGround := False;
 end;
end;

procedure Render(DemoTime: Real);
var
  X,Y:Byte;
begin
  if Config.Colors then
    FColor := 14;
  for Y:=0 to One.Height-1 do
    for X:=0 to One.Width-1 do
      WriteBuf(One.Frames[One.Frame][1+X+One.Width*Y], X + One.X-1, Y + One.Y-2);

  case One.Direction of
    1: WriteBuf('^',One.X, One.Y-3);
    2: WriteBuf('>',One.X+2, One.Y-1);
    4: WriteBuf('<',One.X-2, One.Y-1);
  end;

  if Round(DemoTime) mod 2 = 0 then
    Inc(One.Frame);
  if One.Frame > 3 then One.Frame := 1;
end;

begin
  One.X := 10;
  One.Y := 1;
  One.HP := 100;
  One.Frame := 1;
  One.Jump := 0;
  One.OnGround := False;
  One.Width := 3;
  One.Height := 3;
  One.Frames[1] := ' @ .#./~\';
  One.Frames[2] := ' @ ''#,[~\';
  One.Frames[3] := ' @ .#''/~[';
  One.Resource := 5;
  One.Score := 0;
  One.Direction := 1;
end.