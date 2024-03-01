unit Menu;

interface
procedure MainRender(DemoTime: Real);
procedure SettingsRender(DemoTime: Real);
procedure MainCursorPressed(X,Y:Integer);
procedure SettingsCursorPressed(X,Y:Integer);
procedure MainEnterPressed;
procedure SettingsEnterPressed;
procedure Init;

implementation

uses
  Config, State, Renderer;

var
  MenuPosition: Byte;

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

procedure RenderHeader;
begin
    FColor := 3;
    WriteBuf('codename', 4,1);
    WriteBuf('P L A T U S   -   T H E   G A M E',4,2);
    FColor := 7;
    WriteBuf('Version 0.5',26,1);

end;

procedure MainRender(DemoTime: Real);
begin
    Renderer.ClearBuffer;
    RenderHeader;

    ClearLine(9+MenuPosition);

    WriteMenu(0,'Start new game',10,9);
    WriteMenu(1,'Select Level (1)',10,10);
    WriteMenu(2,'Settings',10,11);
    WriteMenu(3,'Quit',10,12);
    WriteMenuPos(10,9);

    FColor := 7;
    ClearLine(22);
    WriteBuf('Use [ARROWS] and [ENTER] for selecton or [ESC] to Back/Quit.',10,22);
    ClearLine(23);
    WriteBuf('(c)2024 Krzysztof Krystian Jankowski',10,23);
end;

procedure SettingsRender(DemoTime: Real);
begin
    Renderer.ClearBuffer;

    RenderHeader;

    ClearLine(9+MenuPosition);

    WriteMenu(0,'Background Effects',10,9);
    WriteMenu(1,'Sound Effects',10,10);
    WriteMenu(2,'Colors',10,11);
    WriteMenu(3,'Back to main menu',10,12);
    WriteMenuPos(10,9);
    FColor:=7;
    WriteBuf('No',35,9);
    WriteBuf('No',35,10);
    WriteBuf('No',35,11);
    FColor:=15;
    if Config.BackgroundEffects then WriteBuf('Yes',35,9);
    if Config.SoundEffects then WriteBuf('Yes',35,10);
    if Config.Colors then WriteBuf('Yes',35,11);

end;

procedure MainEnterPressed;
begin
  Case MenuPosition of
    0: State.Change(State_Game);
    2: State.Change(State_Settings);
    3: State.Change(State_Quit);
  end;
  MenuPosition := 0;
end;

procedure SettingsEnterPressed;
begin
  Case MenuPosition of
    0: Config.BackgroundEffects := not Config.BackgroundEffects;
    1: Config.SoundEffects := not Config.SoundEffects;
    2: Config.Colors := not Config.Colors;
    3:
      begin
        State.Change(State_Menu);
        MenuPosition := 0;
      end;
  end;
end;

procedure MainCursorPressed(X,Y:Integer);
begin
  if (MenuPosition + Y >= 0) and (MenuPosition+Y<4) then
    MenuPosition := (MenuPosition + Y)
end;

procedure SettingsCursorPressed(X,Y:Integer);
begin
  if (MenuPosition + Y >= 0) and (MenuPosition+Y<4) then
    MenuPosition := (MenuPosition + Y)
end;

procedure Init;
begin
  MenuPosition := 0;
end;

end.