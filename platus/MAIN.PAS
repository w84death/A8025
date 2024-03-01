{ --- PLATUS THE GAME --- }
{ Created by Krzysztof Krystian Jankowski }
{ On ThinkPad X220, FreeDOS, TurboPascal 7 }
{ At Feb 2024 }
{ http://smol.p1x.in/platus }
{ http://krzysztofjankowski.com }

program PlatusGame;

uses
  Crt, Dos, Config, State, Menu, Sound, Renderer, Player, Level, Rainbow, Fire, Platform;

var
  DemoTime: Real;


procedure Quit;
begin
  Sound.Stop;
  halt;
end;

procedure CursorPressed(X,Y:Integer);
begin
  Case State.IsCurrent of
    State_Settings: Menu.MainCursorPressed(X,Y);
    State_Menu: Menu.SettingsCursorPressed(X,Y);
    State_Game: Platform.CursorPressed(X,Y);
  end;
  if Config.SoundEffects then
    Sound.Play(500);
end;

procedure EnterPressed;
begin
  Case State.IsCurrent of
    State_Menu: Menu.MainEnterPressed;
    State_Settings: Menu.SettingsEnterPressed;
    State_Intro: State.Change(State_Next);
    State_Game: Platform.EnterPressed;
  end;
  if Config.SoundEffects then
    Sound.Play(1000);
end;

procedure EscPressed;
begin
  if Config.SoundEffects then
    Sound.Play(1200);
  if State.Test(State_Menu) then
    Quit;
  State.Change(State_Menu);
  Menu.Init;
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

procedure GameReset;
begin
  DemoTime := 0.0;
  FColor := 15;
  BColor := 0;
end;

begin
  ClrScr;
  GameReset;
  Menu.Init;

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
      State_Menu: Menu.MainRender(DemoTime);
      State_Settings: Menu.SettingsRender(DemoTime);
      State_Game: Platform.Loop(DemoTime);
      State_Quit: Quit;
    end;

    WaitForVerticalRetrace;
    Sound.Stop;
    CopyBufferToScreen;
    CheckForKeyPress;
    DemoTime := DemoTime + 0.5;
  Until False;

end.
