unit Sound;
interface

procedure Play(freq: Word);
procedure Stop;

implementation

procedure Play(freq: Word);
begin
  Port[$61] := Port[$61] or 3;
  Port[$43] := $B6;
  Port[$42] := Lo(freq);
  Port[$42] := Hi(freq);
end;

procedure Stop;
begin
  Port[$61] := Port[$61] and $FC;
end;

end.