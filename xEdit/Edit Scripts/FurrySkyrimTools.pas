{
}
unit FurrySkyrimTools;

interface
implementation
uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

var
    // List of vanilla race names; values are the furry equivalent IwbMainRecord.
    raceAssignments: TStringList;

    // List of furry race names; values are the vanilla IWbMainRecord they furrify.
    furryRaces: TStringList;

    // List of vanilla headpart names; values are a list of equivalent furry headpart
    // names.
    headpartEquivalents: TStringList;

    // List of headpart names; values are a list of labels for that headpart.
    headpartLabels: TStringList;

    // List of headpart names; values are the IWbMainRecord of the headpart.
    headpartRecords: TStringList;

    // List of headpart names; values are the names of allowed races.
    headpartRaces: TStringList;

    NPCaliases: TStringList;
    sexnames: TStringList;
    tintlayerpaths: TStringList;
    multivalueMasks: TStringList;

    // Race tints, a stringlist of stringlists. Structure is:
    // list of tint presets = raceTints.objects[racename].objects[sex].objects[tintname]
    raceTints: TStringList;

    targetFile: IwbFile;
    targetFileIndex: integer;

    // Information about the NPC being furrified. Global variables because we can't 
    // pass structures in procedure calls.
    curNPCrace: IwbMainRecord;
    curNPCsex: string;
    curNPCTintLayerOptions: IwbMainRecord;
    curNPClabels: TStringList;
    curNPCalias: string;


Procedure PreferencesInit;
begin
    if LOGGING then LogEntry(20, 'PreferencesInit');
    raceAssignments := TStringList.Create;
    raceAssignments.Duplicates := dupIgnore;
    raceAssignments.Sorted := true;

    furryRaces := TStringList.Create;
    furryRaces.Duplicates := dupIgnore;
    furryRaces.Sorted := true;

    headpartEquivalents := TStringList.Create;
    headpartEquivalents.Duplicates := dupIgnore;
    headpartEquivalents.Sorted := true;

    headpartLabels := TStringList.Create;
    headpartLabels.Duplicates := dupIgnore;
    headpartLabels.Sorted := true;

    headpartRecords := TStringList.Create;
    headpartRecords.Duplicates := dupIgnore;

    headpartRaces := TStringList.Create;
    headpartRaces.Duplicates := dupIgnore;

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
    furryRaces.Free;

    for i := 0 to headpartEquivalents.Count-1 do
        headpartEquivalents.objects[i].Free;
    headpartEquivalents.Free;

    for i := 0 to headpartLabels.Count-1 do
        headpartLabels.objects[i].Free;
    headpartLabels.Free;

    headpartRecords.Free;

    for i := 0 to headpartRaces.Count-1 do
        headpartRaces.objects[i].Free;
    headpartRaces.Free;

    NPCaliases.Free;

    for i := 0 to raceTints.count-1 do begin // iterate over races
        for j := 0 to raceTints.objects[i].count-1 do begin // iterate over age/sex
            for k := 0 to raceTints.objects[i].objects[j].count-1 do begin // iterate over tint layers
                if MatchText(raceTints.Objects[i].objects[j].strings[k], multivalueMasks) then begin
                    raceTints.Objects[i].objects[j].objects[k].Free;
                end;
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
        furryRaces.AddObject(furryRaceName, WinningOverride(vanillaRace));
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
Add any races on the vanilla headpart to the furry headpart list. Remove the vanilla race
from the vanilla heapart list.
}
procedure FurrifyHeadpartRace(vanillaHP, furryHP: IwbMainRecord);
var
    vanillaHPlist: IwbMainRecord;
    furryHPlist: IwbMainRecord;
begin
    vanillaHPlist := WinningOverride(LinksTo(ElementByPath(vanillaHP, 'RNAM')));
    vl := ElementByPath(vanillaHPlist, 'FormIDs');
    furryHPlistOriginal := WinningOverride(LinksTo(ElementByPath(furryHP, 'RNAM')));
    furryHPlist := MakeOverride(furryHPlistOriginal, furryHP);
    fl := ElementByPath(furryHPlist, 'FormIDs');
    for i := 0 to vl.ElementCount-1 do begin
        ElementAssign(fl, HighInteger, ElementByIndex(vl, i), false);
    end;
end;


{===================================================================== 
Go through all headparts and remove furrified vanilla races from their headpart lists.
Also add the vanilla to the furry headpart lists.
}
procedure FurrifyHeadpartLists;
var
    furrifiedHPlists: TStringList;
    haveChanges: boolean;
    headpartList: IwbMainRecord;
    hp: IwbMainRecord;
    hpFormlist: IwbMainRecord;
    hpFormlistOvr: IwbElement;
    hpIter, raceIter: integer;
    hpNewList: TString;
    hpOverride: IwbMainRecord;
    i: integer;
    race: IwbMainRecord;
    racename: string;
    vanillaRaceIdx, furryRaceIdx: integer;
begin
    if LOGGING then LogEntry(5, 'FurrifyHeadpartLists');

    furrifiedHPlists := TStringList.Create;
    furrifiedHPlists.Duplicates := dupIgnore;
    furrifiedHPlists.Sorted := true;

    // All headparts we know about can be assumed to have either vanilla furrified races or furry races.
    for hpIter := 0 to headpartRecords.Count-1 do begin
        haveChanges := false;
        hp := ObjectToElement(headpartRecords.objects[hpIter]);
        if LOGGING then LogT(Format('Checking headpart %s', [Name(hp)]));
        
        headpartList := WinningOverride(LinksTo(ElementByPath(hp, 'RNAM')));

        if furrifiedHPlists.IndexOf(EditorID(headpartList)) >= 0 then continue;
        furrifiedHPlists.Add(EditorID(headpartList));

        hpFormlist := ElementByPath(headpartList, 'FormIDs');
        hpNewList := TStringList.Create;
        hpnewlist.Duplicates := dupIgnore;
        hpnewlist.Sorted := true;
        for raceIter := 0 to ElementCount(hpFormList)-1 do begin
            race := WinningOverride(LinksTo(ElementByIndex(hpFormList, raceIter)));
            vanillaRaceIdx := raceAssignments.IndexOf(EditorID(race));
            if vanillaRaceIdx >= 0 then begin
                // We have a vanilla race that has been furrified. Leave it off the
                // vanilla race.
                    if LOGGING then LogT(Format('Contains vanilla race %s', 
                        [raceAssignments.strings[vanillaRaceIdx]]));
                    // hpNewList.AddObject(EditorID(ObjectToElement(raceAssignments.objects[vanillaRaceIdx])), 
                    //     raceAssignments.objects[vanillaRaceIdx]);
                haveChanges := true;
            end
            else begin
                // If a furry race, or an unaffected race, just copy to new list.
                hpNewList.AddObject(EditorID(race), race);

                furryRaceIdx := furryRaces.IndexOf(EditorID(race));
                if furryRaceIdx >= 0 then begin
                    // We have a furry race, so add its vanilla race to the list. 
                    if LOGGING then LogT(Format('Contains furry race %s', 
                        [furryRaces.strings[furryRaceIdx]])); 
                    hpNewList.addobject(EditorID(ObjectToElement(furryRaces.objects[furryRaceIdx])), 
                        furryRaces.objects[furryRaceIdx]);
                end;
                haveChanges := true;
            end;
        end;

        if LOGGING then LogT(Format('Headpart %s has new races %s', [Name(headpartList), hpNewList.CommaText]));

        // If we made changes, update the headpart list.
        if haveChanges then begin
            hpOverride := MakeOverride(headpartList, targetFile);
            Remove(ElementByPath(hpOverride, 'FormIDs'));
            if hpNewList.Count > 0 then begin
                hpFormlistOvr := Add(hpOverride, 'FormIDs', true);
                for i := 0 to hpNewList.Count-1 do begin
                    ElementAssign(hpFormlistOvr, i, ObjectToElement(hpNewList.objects[i]), false);
                end;
            end;
        end;

        hpNewList.Free;
    end;

    furrifiedHPlists.Free;

    if logging then LogExitT('FurrifyHeadpartLists');
end;


{=====================================================================
Cache key information about a headapart.
}
procedure CacheHeadpart(hp: IwbMainRecord);
var
    idx: integer;
    i: integer;
    lst: IwbElement;
    fl: IwbMainRecord;
begin
    if LOGGING then LogEntry1(15, 'CacheHeadpart', Name(hp));
    headpartRecords.AddObject(EditorID(hp), hp);
    idx := headpartRaces.IndexOf(EditorID(hp));
    if idx < 0 then begin
        headpartRaces.AddObject(EditorID(hp), TStringList.Create);
        idx := headpartRaces.IndexOf(EditorID(hp));
        headpartRaces.objects[idx].Duplicates := dupIgnore;
        headpartRaces.objects[idx].Sorted := true;
    end;
    fl := WinningOverride(LinksTo(ElementByPath(hp, 'RNAM')));
    lst := ElementByPath(fl, 'FormIDs');
    if LOGGING then LogT(Format('Found %s size %s', [PathName(lst), IntToStr(ElementCount(lst))]));
    for i := 0 to ElementCount(lst)-1 do begin
        if LOGGING then LogT(Format('Caching headpart %s at %d', [EditorID(LinksTo(ElementByIndex(lst, i))), idx]));
        headpartRaces.objects[idx].Add(EditorID(LinksTo(ElementByIndex(lst, i))));
    end;
    if LOGGING then LogExitT('CacheHeadpart');
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
        CacheHeadpart(vanillaHP);
        CacheHeadpart(furryHP);
        headpartEquivalents.objects[hpi].AddObject(vanillaHPName, WinningOverride(furryHP));
    end; 

    if LOGGING then LogExitT1('AssignHeadpart', EditorID(furryHP));
end;


{=====================================================================
Assign a label to a headpart. Labels are used to identify appropriate furry headparts for
a NPC.
}
procedure LabelHeadpart(headpartName, labelName: string);
var
    hpi: integer;
    hpRecord: IwbMainRecord;
begin
    if LOGGING then LogEntry2(1, 'LabelHeadpart', headpartName, labelName);
    hpRecord := FindAsset(Nil, 'HDPT', headpartName);
    if not Assigned(hpRecord) then Err(Format('Headpart %s not found', [headpartName]));
    hpi := headpartLabels.IndexOf(headpartName);
    if hpi < 0 then begin
        headpartLabels.AddObject(headpartName, TStringList.Create);
        hpi := headpartLabels.IndexOf(headpartName);
        headpartLabels.objects[hpi].duplicates := dupIgnore;
    end;
    headpartLabels.objects[hpi].Add(labelName);
    CacheHeadpart(hpRecord);
    if LOGGING then LogExitT('LabelHeadpart');
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
    AddMessage('--HEADPART EQUIVALENTS--');
    AddMessage('==HEADPART LABELS==');
    for i := 0 to headpartLabels.Count-1 do begin
        AddMessage(headpartLabels.strings[i] + ': ' + headpartLabels.objects[i].CommaText);
    end;
    AddMessage('--HEADPART LABELS--');
    AddMessage('==HEADPART RACES==');
    for i := 0 to headpartRaces.Count-1 do begin
        AddMessage(headpartRaces.strings[i] + ': ' + headpartRaces.objects[i].CommaText);
    end;
    AddMessage('--HEADPART RACES--');
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
    curNPCrace := LinksTo(ElementByPath(npc, 'RNAM'));
    LogT('Race is ' + EditorID(curNPCrace));
    LogT('Sex is ' + GetElementEditValues(npc, 'ACBS - Configuration\Flags\Female'));
    LogT('Age is ' + GetElementEditValues(curNPCrace, 'DATA - DATA\Flags\Child'));
    curNPCsex := IfThen(GetElementEditValues(npc, 'ACBS - Configuration\Flags\Female') = '1',
        'FEMALE', 'MALE') 
        + IfThen(GetElementEditValues(curNPCrace, 'DATA - DATA\Flags\Child') = '1',
            'CHILD', 'ADULT');
    curNPCalias := Unalias(Name(npc));
    if LOGGING then LogExitT1('LoadNPC', Format('%s %s', [Name(curNPCrace), curNPCsex]));
end;


{============================================================================
Find the available skin tones for the given NPC. The skin tone presets are returned in
curNPCTintLayerOptions. Doesn't handle skin tones that can have multiple presets.
}
procedure LoadNPCSkinTones(npc: IwbMainRecord);
var 
    raceIdx, sexIdx, presetsIdx: integer;
begin
    if LOGGING then LogEntry3(10, 'LoadNPCSkinTones', Name(npc), EditorID(curNPCrace), curNPCsex);
    raceIdx := raceTints.IndexOf(EditorID(curNPCrace));
    sexIdx := raceTints.objects[raceIdx].IndexOf(curNPCsex);
    curNPCTintLayerOptions := raceTints.objects[raceIdx].objects[sexIdx];
    if LOGGING then LogExitT('LoadNPCSkinTones');
end;

end.