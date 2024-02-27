{ --- PLATUS THE GAME --- }
{ Created by Krzysztof Krystian Jankowski }
{ On ThinkPad X220, FreeDOS, TurboPascal 7 }
{ At Feb 2024 }
{ http://smol.p1x.in/platus }
{ http://krzysztofjankowski.com }

program PlatusGame;

uses
  Crt, Dos;

const

  ScreenWidth = 80;
  ScreenHeight = 25;
  ScreenSize = ScreenWidth * ScreenHeight;

  State_Quit = 0;
  State_Next = 1;

  State_Intro = 10;
  State_Menu = 11;
  State_Game = 12;
  State_GameOver = 13;

  JUMP = 255;

type
  TScreenBuffer = array[1..ScreenSize] of Word;
  TFireBuffer = array[1..ScreenSize] of Byte;
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
  OffScreenBuffer: TScreenBuffer;
  FireBuffer: TFireBuffer;

  State: Byte;
  DemoTime: Real;
  RowNo: Integer;
  MenuPosition: Byte;
  FColor,BColor: Byte;
  AscFile: Text;
  AscLine: string;
  Level: TLevel;
  Player: TPlayer;

procedure ClearBuffer;
var
  i: Integer;
begin
  for i := 1 to ScreenSize do
    OffScreenBuffer[i] := (Black shl 12) or (White shl 8) or ord(' ');
end;

procedure CopyBufferToScreen;
var
  i: Integer;
begin
  for i := 1 to ScreenSize do
    MemW[$B800:0 + (i-1) * 2] := OffScreenBuffer[i];
end;

procedure ChangeState(target: Byte);
begin
  if target = State_Next then
  begin
    Inc(State);
  end
  else
  begin
    State := target;
  end;

  ClearBuffer;
end;

procedure WriteBuf(Text: string; PosX, PosY: Integer);
var
  i, n: Integer;
begin
  n := PosY * ScreenWidth + PosX;
  for i := 1 to Length(Text) do
  begin
    if n + i - 1 < High(OffScreenBuffer) then
      if Text[i] <> ' ' then
        OffScreenBuffer[n + i - 1] := (BColor shl 12) or (FColor shl 8) or Ord(Text[i]);
  end;
end;

procedure WriteAscFile(const FileName: string; PosX,PosY: Byte);
var
  X, Y, AscWidth, AscHeight: Byte;
begin
  Assign(AscFile, FileName);
  Reset(AscFile);

  ReadLn(AscFile, AscWidth, AscHeight);

  for y := PosY to PosY+AscHeight do
  begin
    ReadLn(AscFile, AscLine);
    WriteBuf(AscLine, PosX, PosY+y);
  end;

  Close(AscFile);
end;


procedure LoadLevelFile(const FileName: string);
var
  X, Y, AscWidth, AscHeight: Byte;
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
  Case State of
    State_Menu:
      begin
        if (MenuPosition + Y >= 0) and (MenuPosition+Y<5) then
          MenuPosition := (MenuPosition + Y)
      end;
    State_Game:
      begin
          if (Player.X + X > 1) and (Player.X+X < ScreenWidth) then
            Player.X := Player.X + X;
          if (Player.OnGround = False) and (Player.X + X > 1) and (Player.X+X < ScreenWidth) then
            Player.X := Player.X + X;
          if (Y<0) and (Player.OnGround) then Player.Jump := 255;
          if Y>0 then Inc(Player.Y);
      end;
  end;
end;

procedure EnterPressed;
begin
  Case State of
    State_Menu:
      begin
        Case MenuPosition of
          0: ChangeState(State_Game);
          1: ChangeState(State_Game);
          2: ChangeState(State_Quit);
        end;
      end;
    State_Intro: ChangeState(State_Next);
  end;
end;

procedure EscPressed;
begin
  if State = State_Menu then
    halt;
  ChangeState(State_Menu);
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

procedure RenderRainbow;
var
  X,Y,Value: Integer;
  zoom,speed: Real;
  VX,VY: Real;
  c:Byte;
begin
  zoom := 0.006;

  Y:= Round(RowNo) mod ScreenHeight;
  for X := 1 to ScreenWidth  do
  begin
    VX := ((X+64)*(4+cos(DemoTime*0.06)*3))*zoom ;
    VY := ((Y)*(4+sin(DemoTime*0.07)*3))*zoom;
    Value := Round(VX+VY);
    c:=8;
    if Value mod 2 = 0 then c:=7;
    if Value mod 3 = 0 then c:=4;

    OffscreenBuffer[Y * ScreenWidth + X] := (Black shl 12) or (c shl 8) or Ord(219);
  end;
end;

procedure ClearFireBuffer;
var
  i: Integer;
begin
  for i := 1 to ScreenSize do
    FireBuffer[i] := 0;
end;

procedure RenderFire;
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
    FireBuffer[1930+Random(60)]:=4+Random(4);
    FireBuffer[1920+Random(80)]:=0;
  end;

  for y := 0 to ScreenHeight - 2 do
    for x := 0 to ScreenWidth - 1 do
    begin
      randI := (y + 1) * ScreenWidth + x + Random(3) - 1;
      new := FireBuffer[randI] - (Random(2) and 1);
      if new < 0 then new := 0;
      FireBuffer[y * ScreenWidth + x] := new;
      OffscreenBuffer[y * ScreenWidth + x] := (Black shl 12) or (fireColors[new] shl 8) or Ord(fireChars[new]);
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
begin
  FColor:=0;
  BColor:=15;
  WriteBuf('___PLAYER:1___HP:10___SCORE:000___TIME:000___',17,0);
  BColor:=0;
  FColor:=15;
end;

procedure GameMock;
var
  block:Byte;
begin
  RenderFire;
  RenderLevel;
  WriteStatus;

  FColor := 14;
  WriteBuf(Player.Sprites[1+3*Player.Frame], Player.X-1, Player.Y-2);
  WriteBuf(Player.Sprites[2+3*Player.Frame], Player.X-1, Player.Y-1);
  WriteBuf(Player.Sprites[3+3*Player.Frame], Player.X-1, Player.Y);
  if Round(DemoTime*10) mod 50 = 0 then Inc(Player.Frame);
  if Player.Frame > 2 then Player.Frame := 0;

  block := Level[(Player.Y+1)*ScreenWidth + Player.X];

  if (block <>  Ord('ß')) and (block <> Ord('Ä')) and (block <> Ord('Ã')) and (block <> Ord('´')) then
  begin
    if (Player.Jump = 0) and (Round(DemoTime*10) mod 50 = 0) then
      Player.Y := Player.Y + 1;
      Player.OnGround := False;
  end
  else
  begin
    Player.OnGround := True;
  end;

  if (Player.Jump > 0) then
  begin
    if Player.Jump > 255-3 then
      Dec(Player.Y);
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
  ClearBuffer;
  ClearFireBuffer;
  State := State_Intro;
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

    Case State of
      State_Intro:
        begin
          OffScreenBuffer[Round(1000+Sin(DemoTime)*1000)] := (Black shl 12) or (7 shl 8) or ord(176+Random(3));
          FColor := 15;
          WriteBuf('P1X',40,12);
          FColor := 8;
          WriteBuf('Press [ENTER]', 35,23);
          if DemoTime>100 then ChangeState(State_next);
        end;
      State_Menu:
        begin
          RenderRainbow;
          FColor := 15;
          WriteBuf('   ¿ P L A T U S  Ú    ',10,5);
          WriteBuf('  ¿³Ú the game ¿ ¿³Ú   ',10,6);
          WriteBuf('ßßßßßßßßßßßßßßßßßßßßßßß',10,7);

          WriteMenu(0,'Start new game',10,9);
          WriteMenu(1,'Load level',10,10);
          WriteMenu(2,'Quit',10,11);
          WriteMenuPos(10,9);


          FColor := 8;
          WriteBuf('(c)2024 Krzysztof Krystian Jankowski',10,23);
          WriteBuf('Use [ARROWS] and [ENTER] for selecton or [ESC] to Quit.',10,22);
        end;
      State_Game: GameMock;
      State_Quit: halt;
    end;

    CopyBufferToScreen;
    CheckForKeyPress;
    DemoTime := DemoTime + 0.025;
    Inc(RowNo);
    if RowNo>ScreenHeight then RowNo := 0;
    delay(100);
  Until False;

end.
