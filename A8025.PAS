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
  State_Demo = 12;
  State_Outro = 13;
  State_Quit = 14;

type
  TScreenBuffer = array[1..ScreenSize] of Word;

var
  OffScreenBuffer: TScreenBuffer;
  LastFrameTime: LongInt;
  State: Byte;
  DemoTime: Real;
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

procedure CursorMove(X,Y:Integer);
begin
  Case State of
    State_Menu:
      begin
        if (MenuPosition + Y >= 0) and (MenuPosition+Y<3) then
          MenuPosition := (MenuPosition + Y)
      end;
    end;
end;

procedure ReturnHit;
begin
  Case State of
    State_Menu:
      begin
        Case MenuPosition of
          0: ChangeState(State_Demo);
          2: ChangeState(State_Quit);
        end;
      end;
    State_Intro: ChangeState(State_Next);
  end;
end;

procedure CheckForKeyPress;
var
  key: char;
begin
  if KeyPressed then
  begin
    key := ReadKey;
    Case key of
      #27:
        begin
          if State = State_Menu then
             halt;
          ChangeState(State_Menu);
        end;
      #13: ReturnHit;
      #72: CursorMove(0,-1);
      #80: CursorMove(0,1);
      #75: CursorMove(-1,0);
      #77: CursorMove(1,0);
    end;
  end;
end;

begin
  ClrScr;
  ClearBuffer;
  State := State_Intro;
  DemoTime := 0.0;
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
          WriteBuf('   Start DEMO', 10, 9);
          FColor := 3;
          if MenuPosition = 1 then FColor := 13;
          Writebuf('   Empty',10,10);
          FColor := 3;
          if MenuPosition = 2 then FColor := 13;
          Writebuf('   Quit',10,11);

          FColor := 13;
          Writebuf(Chr(196)+Chr(175),10,9+MenuPosition);

          FColor := 3;
          WriteBuf('Use [ARROWS] and [ENTER] for selecton or [ESC] to Quit.',10,23);

        end;
      State_Outro:  WriteBuf('Bye! Have a nice day.',10,5);
      State_Demo:
        begin
          OffScreenBuffer[Random(ScreenSize)] := (Black shl 12) or (White shl 8) or ord(176+Random(48));
          FColor := 8;
          WriteBuf('FreeDOS rocks!', 35 + Round(Sin((DemoTime-0.1)*0.6)*25),12 + Round(Cos((DemoTime-0.1)*0.7)*10));

          FColor := 12;
          WriteAscFile('A.ASC', 5+30+Round(Sin((DemoTime-0.1)*0.6)*30), 5);
          

          FColor := 14;
          WriteBuf('FreeDOS rocks!', 35 + Round(Sin(DemoTime*0.6)*25),12 + Round(Cos(DemoTime*0.7)*10));
        end;
      State_Quit: halt;
    end;

    CopyBufferToScreen;
    CheckForKeyPress;
    DemoTime := DemoTime + 0.025;
  Until False;

end.
