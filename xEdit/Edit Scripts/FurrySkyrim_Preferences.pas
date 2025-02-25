{
}
unit FurrySkyrim_Preferences;

interface
implementation
uses FurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;


Procedure SetPreferences;
begin
    SetRace('NordRace', 'LykaiosRace');
end;

end.