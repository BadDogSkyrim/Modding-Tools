{
}
unit FurrySkyrimTools;

interface
implementation
uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

var
    raceAssignments: TStringList;


Procedure PreferencesInit;
begin
    if LOGGING then LogEntry(20, 'PreferencesInit');
    raceAssignments := TStringList.Create;
    if LOGGING then LogExitT('PreferencesInit');
end;


Procedure PreferencesFree;
begin
    raceAssignments.Free;
end;


Procedure SetRace(vanillaRaceName, furryRaceName: String);
var
    vanillaRace: IwbMainRecord;
    furryRace: IwbMainRecord;
begin
    if LOGGING then LogEntry2(1, 'SetRace', vanillaRaceName, furryRaceName);
    vanillaRace := FindAsset(Nil, 'RACE', vanillaRaceName);
    furryRace := FindAsset(Nil, 'RACE', furryRaceName);
    if not Assigned(furryRace) then 
        Err(Format('Race %s not found', [furryRaceName]))
    else if not Assigned(vanillaRace) then 
        Err(Format('Race %s not found', [vanillaRaceName]))
    else begin
        raceAssignments.AddObject(vanillaRaceName, WinningOverride(furryRace));
    end; 
    if LOGGING then LogExitT1('SetRace', EditorID(furryRace));
end;

Procedure ShowRaceAssignments;
var i: integer;
begin
    AddMessage('==RACE ASSIGNMENTS==');
    for i := 0 to raceAssignments.Count-1 do begin
        AddMessage(Format('Race assignment %s -> %s', [
            raceAssignments[i], EditorID(ObjectToElement(raceAssignments.objects[i]))]));
    end;
    AddMessage('==RACE ASSIGNMENTS==');
end;

end.