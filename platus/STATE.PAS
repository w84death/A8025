unit State;
interface
const
  State_Quit = 0;
  State_Next = 1;

  State_Intro = 10;
  State_Menu = 11;
  State_Settings = 12;
  State_Game = 13;
  State_GameOver = 14;

function Test(TestState: Byte): Boolean;
function IsCurrent: Byte;
procedure Change(target: Byte);

implementation
var
  Current: Byte;

function Test(TestState: Byte): Boolean;
begin
  if TestState = Current then
  begin
    Test := True;
  end
  else
  begin
    Test := False;
  end;
end;

function IsCurrent: Byte;
begin
  IsCurrent := Current;
end;

procedure Change(target: Byte);
begin
  if target = State_Next then
  begin
    Inc(Current);
  end
  else
  begin
    Current := target;
  end;
end;

begin
  Change(State_Intro);
end.