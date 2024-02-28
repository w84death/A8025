uses Dos;

procedure WaitForVerticalRetrace;
var
  Status: Byte;
begin
  { Wait for vertical retrace to end }
  repeat
    Status := Port[ $3DA ] and 8;
  until Status = 8;

  { Wait for vertical retrace to start }
  repeat
    Status := Port[ $3DA ] and 8;
  until Status = 0;
end;

begin
  while not KeyPressed do
  begin
    WaitForVerticalRetrace;
    { Your drawing code here }
  end;
end.





uses Dos;

var
  LastTime, DeltaTime, CurrentTime: LongInt;

function GetTickCount: LongInt; assembler;
asm
  { Access the DOS tick count, which is updated approximately 18.2 times per second }
  mov ah, 00h
  int 1Ah
  { DX:AX contains the tick count, convert it to a single LongInt }
  mov dx, cx
  mov ax, dx
end;

begin
  LastTime := GetTickCount;

  { Main loop }
  while not KeyPressed do
  begin
    { Update current time }
    CurrentTime := GetTickCount;

    { Calculate delta time in seconds }
    DeltaTime := CurrentTime - LastTime;
    LastTime := CurrentTime;

    { Adjust your animations or movements based on DeltaTime }
    { Example: MoveSprite(DeltaTime); }

    { Rest of your game loop goes here... }
  end;
end.

