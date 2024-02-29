unit Config;
interface
const
  ScreenWidth = 80;
  ScreenHeight = 25;
  ScreenSize = ScreenWidth * ScreenHeight;
var
  BackgroundEffects,SoundEffects,Colors: Boolean;

implementation

begin
  BackgroundEffects := True;
  SoundEffects := True;
  Colors := True;
end.