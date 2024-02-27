{ --- PLATUS THE GAME --- }
{ Created by Krzysztof Krystian Jankowski }
{ On ThinkPad X220, FreeDOS, TurboPascal 7 }
{ At Feb 2024 }
{ http://smol.p1x.in/platus }
{ http://krzysztofjankowski.com }

program PlatusGame;

uses
  Crt, Dos, Config, State, Renderer, Rainbow, Fire;


type
  TLevel = array[1..ScreenSize] of Byte;
  TPlayer = record
    X,Y: Integer;
    Sprites: array[1..9] of String;
    Width, Height: Byte;
    Frame: Byte;
    HP: Byte;
    Jump: Byte;
    OnGround: Boolean;
  end;

var
  DemoTime: Real;
  MenuPosition: Byte;

  Level: TLevel;
  Player: TPlayer;


procedure PlaySound(freq: Word);
begin
  Port[$61] := Port[$61] or 3;
  Port[$43] := $B6;
  Port[$42] := Lo(freq);
  Port[$42] := Hi(freq);
  Delay(10);
  Port[$61] := Port[$61] and $FC;
end;

procedure LoadLevelFile(const FileName: string);
var
  X, Y, AscWidth, AscHeight: Byte;
  AscFile: Text;
  AscLine: string;
begin
  Assign(AscFile, FileName);
  Reset(AscFile);

  for y := 0 to ScreenHeight do
  begin
    ReadLn(AscFile, AscLine);
    for x := 1 to High(AscLine) do
    begin
      Level[y*ScreenWidth+x] := Ord(AscLine[x]);
    end;
  end;
  Close(AscFile);
end;

procedure CursorPressed(X,Y:Integer);
begin
  Case State.IsCurrent of
    State_Settings:
      begin
        if (MenuPosition + Y >= 0) and (MenuPosition+Y<4) then
          MenuPosition := (MenuPosition + Y)
      end;
    State_Menu:
      begin
        if (MenuPosition + Y >= 0) and (MenuPosition+Y<4) then
          MenuPosition := (MenuPosition + Y)
      end;
    State_Game:
      begin
          if (Player.X + X > 1) and (Player.X+X < ScreenWidth) then
            Player.X := Player.X + X;
          if (Player.OnGround = False) and (Player.X + X > 1) and (Player.X+X < ScreenWidth) then
            if Player.Jump = 16 then
              Player.X := Player.X + X;
          if (Y<0) and (Player.OnGround) then Player.Jump := 16;
          if Y>0 then Inc(Player.Y);
      end;
  end;
  if Config.SoundEffects then
    PlaySound(500);
end;


procedure EnterPressed;
begin
  Case State.IsCurrent of
    State_Menu:
      begin
        Case MenuPosition of
          0: State.Change(State_Game);
          2: State.Change(State_Settings);
          3: State.Change(State_Quit);
        end;
        MenuPosition := 0;
      end;
    State_Settings:
      begin
        Case MenuPosition of
          0: Config.BackgroundEffects := not Config.BackgroundEffects;
          1: Config.SoundEffects := not Config.SoundEffects;
          2: Config.Particles := not Config.Particles;
          3:
            begin
              State.Change(State_Menu);
              MenuPosition := 0;
            end;
        end;
      end;
    State_Intro: State.Change(State_Next);
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

procedure RenderLevel;
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
        Ord('ß'): c:=15;
      end;
      OffScreenBuffer[i] := (Black shl 12) or (c shl 8) or Ord(Level[i]);
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

  RenderLevel;
  WriteStatus;

  FColor := 14;
  WriteBuf(Player.Sprites[1+3*Player.Frame], Player.X-1, Player.Y-2);
  WriteBuf(Player.Sprites[2+3*Player.Frame], Player.X-1, Player.Y-1);
  WriteBuf(Player.Sprites[3+3*Player.Frame], Player.X-1, Player.Y);
  if Round(DemoTime*10) mod 5 = 0 then Inc(Player.Frame);
  if Player.Frame > 2 then Player.Frame := 0;

  block := Level[(Player.Y+1)*ScreenWidth + Player.X];

  if (block <>  Ord('ß')) and (block <> Ord('Ä')) and (block <> Ord('Ã')) and (block <> Ord('´')) then
  begin
    if (Player.Jump = 0) then
      Player.Y := Player.Y + 1;
    Player.OnGround := False;
  end
  else
  begin
    Player.OnGround := True;
  end;

  if (Player.Jump > 0) then
  begin
    if Player.Jump > 16-3 then
      Dec(Player.Y);
    Dec(Player.Jump);
    Dec(Player.Jump);
  end;

  if Player.Y > ScreenHeight then
  begin
    Player.X := 40;
    Player.Y := 1;
  end;

end;

procedure WriteMenu(pos:Byte;title:String;X,Y:Byte);
begin
  FColor := 7;
  if MenuPosition = pos then FColor := 15;
  WriteBuf('   '+title, X, Y);
end;

procedure WriteMenuPos(X,Y:Byte);
begin
  FColor := 15;
  Writebuf(Chr(196)+Chr(175),X,Y+MenuPosition);
end;

procedure GameReset;
begin
  DemoTime := 0.0;
  RowNo:=0;
  MenuPosition := 0;
  FColor := 15;
  BColor := 0;

  Player.X := 40;
  Player.Y := 0;
  Player.HP := 100;
  Player.Frame := 0;
  Player.Jump := 0;
  Player.OnGround := False;
  Player.Width := 3;
  Player.Height := 3;
  Player.Sprites[1] := ' @ ';
  Player.Sprites[2] := '.#.';
  Player.Sprites[3] := '/~\';
  Player.Sprites[4] := ' @ ';
  Player.Sprites[5] := '''#,';
  Player.Sprites[6] := '[~\';
  Player.Sprites[7] := ' @ ';
  Player.Sprites[8] := '.#''';
  Player.Sprites[9] := '/~[';
end;

begin
  ClrScr;
  GameReset;
  LoadLevelFile('game.asc');

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
      State_Menu:
        begin
          if Config.BackgroundEffects then
          begin
            Rainbow.Render(DemoTime);
          end
          else
            Renderer.ClearBuffer;

          FColor := 15;
          WriteBuf('   ¿ P L A T U S  Ú V0.3',10,5);
          WriteBuf('  ¿³Ú the game ¿ ¿³Ú    ',10,6);
          WriteBuf('ßßßßßßßßßßßßßßßßßßßßßßßß',10,7);

          ClearLine(9+MenuPosition);

          WriteMenu(0,'Start new game',10,9);
          WriteMenu(1,'Load level',10,10);
          WriteMenu(2,'Settings',10,11);
          WriteMenu(3,'Quit',10,12);
          WriteMenuPos(10,9);

          FColor := 7;
          ClearLine(22);
          WriteBuf('Use [ARROWS] and [ENTER] for selecton or [ESC] to Back/Quit.',10,22);
          ClearLine(23);
          WriteBuf('(c)2024 Krzysztof Krystian Jankowski',10,23);
        end;
      State_Settings:
        begin
          if Config.BackgroundEffects then
          begin
            Rainbow.Render(DemoTime);
          end
          else
            Renderer.ClearBuffer;

          ClearLine(9+MenuPosition);

          WriteMenu(0,'Background Effects',10,9);
          WriteMenu(1,'Sound Effects',10,10);
          WriteMenu(2,'Particles',10,11);
          WriteMenu(3,'Back to main menu',10,12);
          WriteMenuPos(10,9);
          FColor:=7;
          WriteBuf('No',35,9);
          WriteBuf('No',35,10);
          WriteBuf('No',35,11);
          FColor:=15;
          if Config.BackgroundEffects then WriteBuf('Yes',35,9);
          if Config.SoundEffects then WriteBuf('Yes',35,10);
          if Config.Particles then WriteBuf('Yes',35,11);

        end;
      State_Game: GameMock;
      State_Quit: halt;
    end;

    WaitForVerticalRetrace;
    CopyBufferToScreen;
    CheckForKeyPress;
    DemoTime := DemoTime + 0.5;
  Until False;

end.
