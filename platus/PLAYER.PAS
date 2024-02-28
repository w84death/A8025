unit Player;

interface


implementation
type
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
  One, Two: TPlayer;
  
begin
  One.X := 40;
  One.Y := 1;
  One.HP := 100;
  One.Frame := 0;
  One.Jump := 0;
  One.OnGround := False;
  One.Width := 3;
  One.Height := 3;
  One.Sprites[1] := ' @ ';
  One.Sprites[2] := '.#.';
  One.Sprites[3] := '/~\';
  One.Sprites[4] := ' @ ';
  One.Sprites[5] := '''#,';
  One.Sprites[6] := '[~\';
  One.Sprites[7] := ' @ ';
  One.Sprites[8] := '.#''';
  One.Sprites[9] := '/~[';
end.