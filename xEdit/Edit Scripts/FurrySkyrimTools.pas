{
}
unit FurrySkyrimTools;

interface
implementation
uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

var
    raceAssignments: TStringList;
    headpartEquivalents: TStringList;
    NPCaliases: TStringList;
    sexnames: TStringList;
    tintlayerpaths: TStringList;
    multivalueMasks: TStringList;

    // Race tints, a stringlist of stringlists. Structure is:
    // list of tint presets = raceTints.objects[racename].objects[sex].objects[tintname]
    raceTints: TStringList;

    // Information about the NPC being furrified. Global variables because we can't 
    // pass structures in procedure calls.
    curRace: IwbMainRecord;
    curSex: string;
    curNPCTintLayerOptions: IwbMainRecord;


Procedure PreferencesInit;
begin
    if LOGGING then LogEntry(20, 'PreferencesInit');
    raceAssignments := TStringList.Create;
    raceAssignments.Duplicates := dupIgnore;
    raceAssignments.Sorted := true;

    headpartEquivalents := TStringList.Create;
    headpartEquivalents.Duplicates := dupIgnore;
    headpartEquivalents.Sorted := true;

    NPCaliases := TStringList.Create;
    NPCaliases.Duplicates := dupIgnore;
    NPCaliases.Sorted := true;

    raceTints := TStringList.Create;
    raceTints.Duplicates := dupIgnore;
    raceTints.Sorted := true;

    sexnames := TStringList.Create;
    sexnames.add('MALEADULT');
    sexnames.add('FEMALEADULT');
    sexnames.add('MALECHILD');
    sexnames.add('FEMALECHILD');

    tintlayerpaths := TStringList.Create;
    tintlayerpaths.Add('Head Data\Male Head Data\Tint Masks');
    tintlayerpaths.Add('Head Data\Female Head Data\Tint Masks');
    tintlayerpaths.Add('Head Data\Male Head Data\Tint Masks');
    tintlayerpaths.Add('Head Data\Female Head Data\Tint Masks');

    multivalueMasks := TStringList.Create;
    multivalueMasks.Add('Paint');
    multivalueMasks.Add('Dirt');
    multivalueMasks.Add('SPECIAL');

    if LOGGING then LogExitT('PreferencesInit');
end;

Procedure PreferencesFree;
var i, j, k, m: Cardinal;
begin
    raceAssignments.Free;
    for i := 0 to headpartEquivalents.Count-1 do
        headpartEquivalents.objects[i].Free;
    headpartEquivalents.Free;

    for i := 0 to NPCaliases.Count-1 do
        NPCaliases.objects[i].Free;
    NPCaliases.Free;

    for i := 0 to raceTints.count-1 do begin // iterate over races
        for j := to raceTints.objects[i].count-1 do begin // iterate over age/sex
            for k := 0 to raceTints.objects[i].objects[j] do begin // iterate over tint layers
                if MatchText(raceTints.Objects[i].objects[j].strings[k], multivalueMasks) then begin
                    for m := 0 to raceTints.Objects[i].objects[j].objects[k].count-1 do begin
                        raceTints.Objects[i].objects[j].objects[k].objects[m].Free;
                    end
                end
                else
                    raceTints.Objects[i].objects[j].objects[k].Free; // free tint layer presets
            end;
            raceTints.Objects[i].objects[j].Free;
        end;
        raceTints.Objects[i].Free;
    end;
    raceTints.Free;
    multivalueMasks.Free;

    sexnames.Free;
    tintlayerpaths.Free;
end;


{========================================================================
Record a vanilla to furry race equivalent. 
}
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
    AddMessage('--RACE ASSIGNMENTS--');
end;


{====================================================================
Preload skin tint info for a race.
}
procedure LoadRaceTints(theRace: IwbMainRecord);
var
    i, j: Cardinal;
    layername: string;
    masklist: TStringList;
    p: Cardinal;
    presetlist: IwbElement;
    raceIdx: cardinal;
    racetintmasks: IwbElement;
    sexList: TStringList;
    t: IwbElement;
    tintlayerList: TStringList;
begin
    if LOGGING then LogEntry1(10, 'LoadRaceTints', Name(theRace));

    raceIdx := raceTints.IndexOf(EditorID(theRace));
    if raceIdx >= 0 then begin
        sexList := raceTints.objects[raceIdx];
    end
    else begin
        sexList := TStringList.Create;
        sexList.Duplicates := dupIgnore;
        sexList.Sorted := false;
        sexList.AddObject('MALEADULT', TStringList.Create);
        sexList.AddObject('FEMALEADULT', TStringList.Create);
        raceTints.AddObject(EditorID(theRace), sexList);
    end;
    for i := 0 to 1 do begin
        tintlayerList := sexList.objects[i];
        racetintmasks := ElementByPath(theRace, tintlayerpaths.strings[i]);
        for j := 0 to ElementCount(racetintmasks)-1 do begin
            t := ElementByIndex(racetintmasks, j);
            layername := GetElementEditValues(t, 'Tint Layer\Texture\TINP - Mask Type');
            if layername = '' then layername := 'SPECIAL';
            presetlist := ElementByPath(t, 'Presets');
            if multivalueMasks.IndexOf(layername) >= 0 then begin
                // These mask types can have multiple layers definitions.
                p := tintlayerList.IndexOf(layername);
                if p >= 0 then 
                    masklist := tintlayerList.objects[p]
                else begin
                    masklist := TStringList.Create;
                    tintlayerList.AddObject(layername, masklist);
                end;
                masklist.AddObject('', presetlist);
            end
            else
                tintlayerList.AddObject(layername, presetlist);
        end;
    end;
    if LOGGING then LogExitT('LoadRaceTints');
end;

procedure ShowRaceTints;
var
    r, s, t: Cardinal;
begin
    AddMessage(Format('==Race Tint Presets (%d)==', [raceTints.Count]));
    for r := 0 to raceTints.Count-1 do begin
        AddMessage(raceTints.strings[r]);
        for s := 0 to raceTints.objects[r].count-1 do begin
            AddMessage('|   ' + raceTints.objects[r].strings[s]);
            for t := 0 to raceTints.objects[r].objects[s].count-1 do begin
                if multivalueMasks.IndexOf(raceTints.objects[r].objects[s].strings[t]) >= 0 then
                    AddMessage(Format('|   |   %s @ %d', [
                        raceTints.objects[r].objects[s].strings[t],
                        raceTints.objects[r].objects[s].objects[t].count]))
                else
                    AddMessage(Format('|   |   %s @ %s', [
                        raceTints.objects[r].objects[s].strings[t],
                        PathName(ObjectToElement(raceTints.objects[r].objects[s].objects[t]))]));
            end;
        end;
    end;
    AddMessage('--Race Tint Presets--');
end;


{=====================================================================
The given vanilla headpart is converted to the given furry headpart. There may be more
than one furry headpart; if so one is chosen at random.
}
procedure AssignHeadpart(vanillaHPName, furryHPName: string);
var
    furryHP: IwbMainRecord;
    hpi: integer;
    hplist: TStringList;
    vanillaHP: IwbMainRecord;
begin
    if LOGGING then LogEntry2(1, 'AssignHeadpart', vanillaHPName, furryHPName);

    vanillaHP := FindAsset(Nil, 'HDPT', vanillaHPName);
    furryHP := FindAsset(Nil, 'HDPT', furryHPName);
    if not Assigned(furryHP) then Err(Format('Headpart %s not found', [furryHPName]));
    if not Assigned(vanillaHP) then Err(Format('Headpart %s not found', [vanillaHPName]));
    if Assigned(furryHP) and Assigned(vanillaHP) then begin
        hpi := headpartEquivalents.IndexOf(vanillaHPName);
        if hpi < 0 then begin
            hplist := TStringList.Create;
            headpartEquivalents.AddObject(vanillaHPName, hplist);
            hpi := headpartEquivalents.IndexOf(vanillaHPName);
        end;
        headpartEquivalents.objects[hpi].AddObject(vanillaHPName, WinningOverride(furryHP));
    end; 
    
    if LOGGING then LogExitT1('AssignHeadpart', EditorID(furryHP));
end;


procedure ShowHeadparts;
var i, j: integer;
begin
    AddMessage('==HEADPART EQUIVALENTS==');
    for i := 0 to headpartEquivalents.Count-1 do begin
        AddMessage(headpartEquivalents.strings[i]);
        for j := 0 to headpartEquivalents.objects[i].Count-1 do begin
            AddMessage('|   ' + Name(ObjectToElement(headpartEquivalents.objects[i].objects[j])));
        end;
    end;
    AddMessage('--HEADPART EQUIVALENTS==');
end;


{============================================================================
Some NPCs have multiple NPC records. This makes sure all records look the same.
}
procedure NPCEquivalent(npcalias, basenpc: string);
var
    alist: TStringList;
    i: integer;
begin
    NPCaliases.Add(npcalias + '=' + basenpc);
end;


function Unalias(alias: string): string;
var i: integer;
begin
    result := NPCaliases.values[alias];
    if result = '' then result := alias;
end;


procedure ShowNPCAliases;
var i: integer;
begin
    AddMessage('==NPC ALIASES==');
    for i := 0 to NPCaliases.Count-1 do begin
        AddMessage(NPCaliases.names[i] + ' = ' + NPCaliases.values[NPCaliases.names[i]]);
    end;
    AddMessage('==NPC ALIASES==');
end;


{============================================================================
Load up the cur* global variables with info from the current NPC.
}
procedure LoadNPC(npc: IwbMainRecord);
var 
    raceIdx, sexIdx, presetsIdx: integer;
begin
    if LOGGING then LogEntry1(10, 'LoadNPC', Name(npc));
    curRace := LinksTo(ElementByPath(npc, 'RNAM'));
    LogT('Sex is ' + GetElementEditValues(npc, 'ACBS - Configuration\Flags\Female'));
    LogT('Age is ' + GetElementEditValues(curRace, 'DATA - DATA\Flags\Child'));
    curSex := IfThen(GetElementEditValues(npc, 'ACBS - Configuration\Flags\Female') = '1',
        'FEMALE', 'MALE') 
        + IfThen(GetElementEditValues(curRace, 'DATA - DATA\Flags\Child') = '1',
            'CHILD', 'ADULT');
    if LOGGING then LogExitT1('LoadNPC', Format('%s %s', [Name(curRace), curSex]));
end;


{============================================================================
Find the available skin tones for the given NPC. The skin tone presets are returned in
curNPCTintLayerOptions. Doesn't handle skin tones that can have multiple presets.
}
procedure LoadNPCSkinTones(npc: IwbMainRecord);
var 
    raceIdx, sexIdx, presetsIdx: integer;
begin
    if LOGGING then LogEntry3(10, 'LoadNPCSkinTones', Name(npc), EditorID(curRace), curSex);
    raceIdx := raceTints.IndexOf(EditorID(curRace));
    sexIdx := raceTints.objects[raceIdx].IndexOf(curSex);
    curNPCTintLayerOptions := raceTints.objects[raceIdx].objects[sexIdx];
    if LOGGING then LogExitT('LoadNPCSkinTones');
end;

end.