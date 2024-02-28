{ --- PLATUS THE GAME --- }
{ Created by Krzysztof Krystian Jankowski }
{ On ThinkPad X220, FreeDOS, TurboPascal 7 }
{ At Feb 2024 }
{ http://smol.p1x.in/platus }
{ http://krzysztofjankowski.com }

program PlatusGame;

uses
  Crt, Dos, Config, State, Menu, Renderer, Player, Level, Rainbow, Fire;

var
  DemoTime: Real;

procedure PlaySound(freq: Word);
begin
  Port[$61] := Port[$61] or 3;
  Port[$43] := $B6;
  Port[$42] := Lo(freq);
  Port[$42] := Hi(freq);
  Delay(10);
  Port[$61] := Port[$61] and $FC;
end;

procedure BuildLadder;
begin
  if Player.One.OnGround then
  begin
    Level.SetCell(Player.One.X-1, Player.One.Y, Ord('Ã'));
    Level.SetCell(Player.One.X, Player.One.Y, Ord('Ä'));
    Level.SetCell(Player.One.X+1, Player.One.Y, Ord('´'));
  end;
end;

procedure CursorPressed(X,Y:Integer);
begin
  Case State.IsCurrent of
    State_Settings: Menu.MainCursorPressed;
    State_Menu: Menu.SettingsCursorPressed;
    State_Game:
      begin
          if (Player.One.X + X > 1) and (Player.One.X+X < ScreenWidth) then
            Player.One.X := Player.One.X + X;
          if (Player.One.OnGround = False) and (Player.One.X + X > 1) and (Player.One.X+X < ScreenWidth) then
            if Player.One.Jump = 16 then
              Player.One.X := Player.One.X + X;
          if (Y<0) and (Player.One.OnGround) then Player.One.Jump := 16;
          if Y>0 then Inc(Player.One.Y);
      end;
  end;
  if Config.SoundEffects then
    PlaySound(500);
end;


procedure EnterPressed;
begin
  Case State.IsCurrent of
    State_Menu: Menu.MainEnterPressed;
    State_Settings: Menu.SettingsEnterPressed;
    State_Intro: State.Change(State_Next);
    State_Game: BuildLadder;
  end;
  if Config.SoundEffects then
    PlaySound(1000);
end;

procedure EscPressed;
begin
  if Config.SoundEffects then
    PlaySound(1200);
  if State.Test(State_Menu) then
    halt;
  State.Change(State_Menu);
end;

procedure CheckForKeyPress;
var
  key: char;
begin
  if KeyPressed then
  begin
    key := ReadKey;
    Case key of
      #27: EscPressed;
      #13: EnterPressed;
      #72: CursorPressed(0,-1);
      #80: CursorPressed(0,1);
      #75: CursorPressed(-1,0);
      #77: CursorPressed(1,0);
    end;
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
  WriteBuf('TIME LEFT',35,VPos);
  FColor := 15;
  WriteBuf('1',8,VPos);
  WriteBuf('10',14,VPos);
  WriteBuf('999',24,VPos);
  WriteBuf('99',45,VPos);

end;

procedure GameMock;
var
  block:Byte;
begin
  if Config.BackgroundEffects then
  begin
    Fire.Render(DemoTime);
  end
  else
    Renderer.ClearBuffer;

  Level.Render;
  WriteStatus;

  FColor := 14;
  WriteBuf(Player.One.Sprites[1+3*Player.One.Frame], Player.One.X-1, Player.One.Y-2);
  WriteBuf(Player.One.Sprites[2+3*Player.One.Frame], Player.One.X-1, Player.One.Y-1);
  WriteBuf(Player.One.Sprites[3+3*Player.One.Frame], Player.One.X-1, Player.One.Y);
  if Round(DemoTime*10) mod 5 = 0 then Inc(Player.One.Frame);
  if Player.One.Frame > 2 then Player.One.Frame := 0;

  block := Level.GetCell(Player.One.X, Player.One.Y + 1);

  if (block <>  Ord('ï¿½')) and (block <> Ord('ï¿½')) and (block <> Ord('ï¿½')) and (block <> Ord('ï¿½')) then
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

  if Player.One.Y > ScreenHeight then
  begin
    Player.One.X := 40;
    Player.One.Y := 1;
  end;

end;

procedure GameReset;
begin
  DemoTime := 0.0;
  RowNo:=0;
  MenuPosition := 0;
  FColor := 15;
  BColor := 0;
end;

begin
  ClrScr;
  GameReset;

  Repeat

    Case State.IsCurrent of
      State_Intro:
        begin
          OffScreenBuffer[Round(1000+Sin(DemoTime)*1000)] := (Black shl 12) or (7 shl 8) or ord(176+Random(3));
          FColor := 15;
          WriteBuf('P1X',40,12);
          FColor := 8;
          WriteBuf('Press [ENTER]', 35,23);
          if DemoTime>10 then State.Change(State_next);
        end;
      State_Menu: Menu.MainRender;        
      State_Settings: Menu.SettingsRender;
      State_Game: GameMock;
      State_Quit: halt;
    end;

    WaitForVerticalRetrace;
    CopyBufferToScreen;
    CheckForKeyPress;
    DemoTime := DemoTime + 0.5;
  Until False;

end.
