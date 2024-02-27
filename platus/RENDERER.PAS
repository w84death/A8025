unit Renderer;
interface

Uses Config;
type
  TScreenBuffer = array[1..ScreenSize] of Word;

var
  OffScreenBuffer: TScreenBuffer;
  FColor,BColor: Byte;

procedure WaitForVerticalRetrace;
procedure ClearBuffer;
procedure ClearLine(LineNo:Byte);
procedure CopyBufferToScreen;
procedure WriteAscFile(const FileName: string; PosX,PosY: Byte);
procedure WriteBuf(Text: string; PosX, PosY: Integer);

implementation


procedure WaitForVerticalRetrace;
var
  Status: Byte;
begin
  repeat
    Status := Port[ $3DA ] and 8;
  until Status = 8;
  repeat
    Status := Port[ $3DA ] and 8;
  until Status = 0;
end;

procedure ClearBuffer;
var
  i: Integer;
begin
  for i := 1 to ScreenSize do
    OffScreenBuffer[i] := (0 shl 12) or (15 shl 8) or ord(' ');
end;

procedure ClearLine(LineNo:Byte);
var
  i: Integer;
begin
  for i := 1+LineNo*ScreenWidth to LineNo*ScreenWidth+ScreenWidth do
    OffScreenBuffer[i] := (0 shl 12) or (15 shl 8) or ord(' ');
end;

procedure CopyBufferToScreen;
var
  i: Integer;
begin
  for i := 1 to ScreenSize do
    MemW[$B800:0 + (i-1) * 2] := OffScreenBuffer[i];
end;

procedure WriteBuf(Text: string; PosX, PosY: Integer);
var
  i, n, p: Integer;
begin
  n := PosY * ScreenWidth + PosX;
  for i := 1 to Length(Text) do
  begin
    p := n + i - 1;
    if (p < High(OffScreenBuffer)) and (p>0) then
      if Text[i] <> ' ' then
        OffScreenBuffer[p] := (BColor shl 12) or (FColor shl 8) or Ord(Text[i]);
  end;
end;

procedure WriteAscFile(const FileName: string; PosX,PosY: Byte);
var
  X, Y, AscWidth, AscHeight: Byte;
  AscFile: Text;
  AscLine: string;

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

begin
  ClearBuffer;
end.