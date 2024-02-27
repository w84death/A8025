{ --- ASCII 8x25 Engine --------- }
{ by Krzysztof Krystian Jankowski }
{ FreeDOS/TurboPascal 7, Feb 2024 }
{  http://krzysztofjankowski.com  }

program ASCII8025Engine;

uses
  Crt, Dos;

const
  ScreenWidth = 80;
  ScreenHeight = 25;
  ScreenSize = ScreenWidth * ScreenHeight;
  State_Next = 0; { 0..9 control states }
  State_Intro = 10; { 10..99 app states }
  State_Menu = 11;
  State_Demo1 = 12;
  State_Rainbow = 13;
  State_Fire = 14;
  State_Quit = 15;

type
  TScreenBuffer = array[1..ScreenSize] of Word;
  TFireBuffer = array[1..ScreenSize] of Byte;
var
  OffScreenBuffer: TScreenBuffer;
  FireBuffer: TFireBuffer;
  LastFrameTime: LongInt;
  State: Byte;
  DemoTime: Real;
  RowNo: Integer;
  MenuPosition: Byte;
  FColor,BColor: Byte;
  AscFile: Text;
  AscLine: string;


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

procedure CursorPressed(X,Y:Integer);
begin
  Case State of
    State_Menu:
      begin
        if (MenuPosition + Y >= 0) and (MenuPosition+Y<4) then
          MenuPosition := (MenuPosition + Y)
      end;
  end;
end;

procedure EnterPressed;
begin
  Case State of
    State_Menu:
      begin
        Case MenuPosition of
          0: ChangeState(State_Demo1);
          1: ChangeState(State_Rainbow);
          2: ChangeState(State_Fire);
          3: ChangeState(State_Quit);
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
begin
  zoom := 0.006;
  speed := 4;
  Y:=Round(RowNo*16) mod ScreenHeight;
  for X := 1 to ScreenWidth  do
  begin
    if X mod 2 = 0 then
    begin
    Value := Round( (X)*(32+(Y+DemoTime)*speed)*zoom) mod 16;
    OffscreenBuffer[Y * ScreenWidth + X] := (Black shl 12) or (8+(Value mod 8) shl 8) or Ord(219);
  end;
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


  if Round(DemoTime*100) mod 10 = 0 then
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


begin
  ClrScr;
  ClearBuffer;
  ClearFireBuffer;
  State := State_Intro;
  DemoTime := 0.0;
  RowNo:=0;
  MenuPosition := 0;
  FColor := 15;
  BColor := 0;

  Repeat

    Case State of
      State_Intro:
        begin
          OffScreenBuffer[Round(1000+Sin(DemoTime)*1000)] := (Black shl 12) or (Green shl 8) or ord(176+Random(3));
          FColor := 15;
          WriteBuf('P1X',40,12);
          FColor := 2;
          WriteBuf('Press [ENTER]', 35,23);
          if DemoTime>30 then ChangeState(State_next);
        end;
      State_Menu:
        begin
          FColor := 15;
          WriteBuf('Welcome to the ASCII 80x25 Engine',10,5);
          WriteBuf('=================================',10,6);

          FColor := 3;
          if MenuPosition = 0 then FColor := 13;
          WriteBuf('   Start DEMO 1', 10, 9);
          FColor := 3;
          if MenuPosition = 1 then FColor := 13;
          Writebuf('   RAINBOW',10,10);
          FColor := 3;
          if MenuPosition = 2 then FColor := 13;
          Writebuf('   FIRE',10,11);
          FColor := 3;
          if MenuPosition = 3 then FColor := 13;
          Writebuf('   Quit',10,12);
          FColor := 13;
          Writebuf(Chr(196)+Chr(175),10,9+MenuPosition);

          FColor := 3;
          WriteBuf('Use [ARROWS] and [ENTER] for selecton or [ESC] to Quit.',10,23);
        end;
      State_Demo1:
        begin
          OffScreenBuffer[Random(ScreenSize)] := (Black shl 12) or (White shl 8) or ord(176+Random(48));
          FColor := 8;
          WriteBuf('FreeDOS rocks!', 35 + Round(Sin((DemoTime-0.1)*0.6)*25),12 + Round(Cos((DemoTime-0.1)*0.7)*10));

          FColor := 12;
          WriteAscFile('A.ASC', 5+30+Round(Sin((DemoTime-0.1)*0.6)*30), 5);


          FColor := 14;
          WriteBuf('FreeDOS rocks!', 35 + Round(Sin(DemoTime*0.6)*25),12 + Round(Cos(DemoTime*0.7)*10));
        end;
      State_Rainbow: RenderRainbow;
      State_Fire: RenderFire;
      State_Quit: halt;
    end;

    CopyBufferToScreen;
    CheckForKeyPress;
    DemoTime := DemoTime + 0.025;
    Inc(RowNo);
  Until False;

end.
