unit Platform;
interface

procedure Loop(DemoTime: Real);
procedure EnterPressed;
procedure CursorPressed(X,Y:Integer);
procedure BuildLadder;

implementation
uses
  Config, Renderer, Sound, Player, Fire, Level;

procedure EnterPressed;
begin
  BuildLadder;
end;

procedure CursorPressed(X,Y:Integer);
      begin
          if (Player.One.X + X > 1) and (Player.One.X+X < ScreenWidth) then
            begin
              if Level.GetCell(Player.One.X+X,Player.One.Y) <> Ord('ß') then
                begin
                  Player.One.X := Player.One.X + X;
                  Player.One.Direction := 4;
                  if X > 0 then
                    Player.One.Direction := 2;
                end;
            end;
          if (Player.One.OnGround = False) and (Player.One.X + X > 1) and (Player.One.X+X < ScreenWidth) then
            if Player.One.Jump = 16 then
              Player.One.X := Player.One.X + X;
          if (Y<0) and (Player.One.OnGround) then
          begin
            Player.One.Jump := 16;
            Player.One.Direction := 1;
          end;
          {if Y>0 then Inc(Player.One.Y);}
      end;

procedure BuildLadder;
begin
  if Player.One.OnGround and CanBuildLadder then
  begin
    Level.SetCell(Player.One.X-1, Player.One.Y, Ord('Ã'));
    Level.SetCell(Player.One.X, Player.One.Y, Ord('Ä'));
    Level.SetCell(Player.One.X+1, Player.One.Y, Ord('´'));
  end;
end;

procedure WriteStatus;
var
   VPos: Byte;
begin
  VPos:=ScreenHeight-1;
  ClearLine(VPos);

  FColor:=7;
  WriteBuf('PLAYER',1,VPos);
  WriteBuf('HP',11,VPos);
  WriteBuf('SCORE',18,VPos);
  WriteBuf('MONEY',29,VPos);
  WriteBuf('TIME LEFT',35,1);
  FColor := 15;
  WriteBuf('1',8,VPos);
  WriteBuf('10',14,VPos);
  WriteBuf('99',24,VPos);
  WriteBuf('99',35,VPos);
  WriteBuf('999',45,1);
end;

procedure Loop(DemoTime: Real);
var
  X,Y: Integer;
begin
  if Config.BackgroundEffects then
  begin
    Fire.Render(DemoTime);
  end
  else
    Renderer.ClearBuffer;

  Level.Render;
  WriteStatus;

  Player.Render(DemoTime);

  for Y:= 0 to 2 do
  for X:= -1 to 1 do
    if Level.GetCell(Player.One.X+X, Player.One.Y-Y) = Ord('$') then
      begin
        level.SetCell(Player.One.X+X, Player.One.Y-Y, 0);
        Inc(One.Resource);
        if Config.SoundEffects then
        begin
          Sound.Stop;
          Sound.Play(300);
        end;
      end;

  if StandsOnGround then
  begin
    if (Player.One.Jump = 0) then
      Player.One.Y := Player.One.Y + 1;
    Player.One.OnGround := False;
  end
  else
  begin
    Player.One.OnGround := True;
  end;

  if (Player.One.Jump > 0) then
  begin
    if Player.One.Jump > 16-3 then
      Dec(Player.One.Y);
    Dec(Player.One.Jump);
    Dec(Player.One.Jump);
  end;

  if Player.One.Y + 1 > ScreenHeight then
  begin
    Player.One.X := 10;
    Player.One.Y := 1;
  end;

end;

end.