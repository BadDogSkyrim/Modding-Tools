{
}
unit FurrySkyrimTools;

interface
implementation
uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

var
    // List of vanilla race names; values are the furry equivalent IwbMainRecord.
    raceAssignments: TStringList;

    // List of vanilla races being furrified. Values are the IwbMainRecord of the race.
    vanillaRaces: TStringList;

    // List of furry race names; values are the vanilla IWbMainRecord they furrify.
    furryRaces: TStringList;

    // Name/value list of furry race classes. Values are the race's class. Only furry races with defind classes are in the list.
    furryRaceClass: TStringList;

    // List of vanilla headpart names; values are a list of equivalent furry headpart
    // names.
    headpartEquivalents: TStringList;

    // List of headpart names; values are a list of labels for that headpart.
    headpartLabels: TStringList;

    // List of labels that conflict with each other. Format is 'label1/label2'.
    labelConflicts: TStringList;

    // List of headpart names; values are the IWbMainRecord of the headpart.
    headpartRecords: TStringList;

    // List of headpart names; values are the names of allowed races.
    headpartRaces: TStringList;

    NPCaliases: TStringList;
    sexnames: TStringList;
    tintlayerpaths: TStringList;

    // Race tints, a stringlist of stringlists. Structure is:
    // list of tint presets = raceTints.objects[racename].objects[sex].objects[type].objects[tintname]
    // where type is 'REQUIRED', 'OPTIONAL'.
    // list of tint presets = raceTints.objects[racename].objects[sex].objects[type]
    // where type is 'PAINT', 'DIRT', or 'SPECIAL'.
    raceTints: TStringList;
    tintTypes: TStringList;

    targetFile: IwbFile;
    targetFileIndex: integer;

    // All furrifiable armors (furrifiable bodyparts)
    furrifiableArmors: TStringList;

    // All armor addons. Key: name, value: IwbMainRecord
    allAddons: TStringList;

    // Races associated with furrifiable addons. Key: addon name, value: TStringList of races.
    addonRaces: TStringList;

    khajiitRace: IwbMainRecord;

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

    furryRaceClass := TStringList.Create;
    furryRaceClass.Duplicates := dupIgnore;
    furryRaceClass.Sorted := true;

    vanillaRaces := TStringList.Create;
    vanillaRaces.Duplicates := dupIgnore;
    vanillaRaces.Sorted := true;

    headpartEquivalents := TStringList.Create;
    headpartEquivalents.Duplicates := dupIgnore;
    headpartEquivalents.Sorted := true;

    headpartLabels := TStringList.Create;
    headpartLabels.Duplicates := dupIgnore;
    headpartLabels.Sorted := true;

    labelConflicts := TStringList.Create;
    labelConflicts.Duplicates := dupIgnore;
    labelConflicts.Sorted := true;

    headpartRecords := TStringList.Create;
    headpartRecords.Duplicates := dupIgnore;
    headpartRecords.Sorted := true;

    headpartRaces := TStringList.Create;
    headpartRaces.Duplicates := dupIgnore;
    headpartRaces.Sorted := true;

    NPCaliases := TStringList.Create;
    NPCaliases.Duplicates := dupIgnore;
    NPCaliases.Sorted := true;

    tintTypes := TStringList.Create;
    tintTypes.add('REQUIRED');
    tintTypes.add('OPTIONAL');
    tintTypes.add('Paint');
    tintTypes.add('Dirt');
    tintTypes.add('SPECIAL');

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

    furrifiableArmors := TStringList.Create;
    furrifiableArmors.Duplicates := dupIgnore;
    furrifiableArmors.Sorted := true;

    addonRaces := TStringList.Create;
    addonRaces.Duplicates := dupIgnore;
    addonRaces.Sorted := true;

    allAddons := TStringList.Create;
    allAddons.Duplicates := dupIgnore;
    allAddons.Sorted := true;

    if LOGGING then LogExitT('PreferencesInit');
end;

Procedure PreferencesFree;
var raceIdx, sexIdx, typeIdx, m: Cardinal;
begin
    raceAssignments.Free;
    furryRaces.Free;
    furryRaceClass.Free;
    vanillaRaces.free;

    for i := 0 to headpartEquivalents.Count-1 do
        headpartEquivalents.objects[i].Free;
    headpartEquivalents.Free;

    for i := 0 to headpartLabels.Count-1 do
        headpartLabels.objects[i].Free;
    headpartLabels.Free;
    labelConflicts.Free;

    headpartRecords.Free;

    for i := 0 to headpartRaces.Count-1 do
        headpartRaces.objects[i].Free;
    headpartRaces.Free;

    NPCaliases.Free;

    for raceIdx := 0 to raceTints.count-1 do begin // iterate over races
        for sexIdx := 0 to raceTints.objects[raceIdx].count-1 do begin // iterate over age/sex
            for typeIdx := 0 to raceTints.objects[raceIdx].objects[sexIdx].count-1 do begin // iterate over types
                raceTints.objects[raceIdx].objects[sexIdx].objects[typeIdx].Free;
            end;
            raceTints.Objects[raceIdx].objects[sexIdx].Free;
        end;
        raceTints.Objects[raceIdx].Free;
    end;
    raceTints.Free;

    tintTypes.Free;
    sexnames.Free;
    tintlayerpaths.Free;
    furrifiableArmors.free;
    allAddons.free;

    for i := 0 to addonRaces.count-1 do 
        addonRaces.objects[i].free;
    addonRaces.free;
end;


{========================================================================
Record a vanilla to furry race equivalent. 
}
Procedure SetRace(vanillaRaceName, furryRaceName, frClass: String);
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
        vanillaRaces.AddObject(vanillaRaceName, WinningOverride(vanillaRace));
        if frClass <> '' then furryRaceClass.add(furryRaceName + '=' + frClass);
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
    layerIdx: Cardinal;
    layername: string;
    masklist: TStringList;
    p: Cardinal;
    presetlist: IwbElement;
    raceIdx: cardinal;
    racetintmasks: IwbElement;
    sexIdx: Cardinal;
    sexList: TStringList;
    t: IwbElement;
    tintlayerTypeList: TStringList;
    typeIdx: Cardinal;
    typeList: TStringList;
    typename: string;
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
        for sexIdx := 0 to sexnames.Count-1 do begin
            typeList := TStringList.Create;
            typeList.Duplicates := dupIgnore;
            typeList.Sorted := false;
            for typeIdx := 0 to tintTypes.Count-1 do begin
                typeList.AddObject(tintTypes.strings[typeIdx], TStringList.Create);
            end;
            sexList.AddObject(sexnames.strings[sexIdx], typeList);
        end;
        raceTints.AddObject(EditorID(theRace), sexList);
    end;

    for i := 0 to 1 do begin
        tintlayerTypeList := sexList.objects[i];
        racetintmasks := ElementByPath(theRace, tintlayerpaths.strings[i]);
        for j := 0 to ElementCount(racetintmasks)-1 do begin
            t := ElementByIndex(racetintmasks, j);
            presetlist := ElementByPath(t, 'Presets');
            layername := GetElementEditValues(t, 'Tint Layer\Texture\TINP - Mask Type');

            if layername = '' then typename := 'SPECIAL'
            else if layername = 'Dirt' then typename  := 'Dirt'
            else if layername = 'Paint' then typename := 'Paint'
            else if layername = 'Skin Tone' then typename := 'REQUIRED'
            else if GetElementNativeValues(presetlist, '[0]\TINV') = 0.0 then typename := 'OPTIONAL'
            else typename := 'REQUIRED';

            if LOGGING then LogD(Format('Preset 0 alpha for %s = %s',  
                [PathName(ElementByIndex(presetlist, 0)), GetElementEditValues(ElementByIndex(presetlist, 0), 'TINV')]
                ));
            layerIdx := tintlayerTypeList.IndexOf(typename);
            tintlayerTypeList.objects[layerIdx].addobject(layername, presetList);
        end;
    end;
    if LOGGING then LogExitT('LoadRaceTints');
end;

procedure ShowRaceTints;
var
    r, s, l, t: Cardinal;
begin
    AddMessage(Format('==Race Tint Presets (%d)==', [raceTints.Count]));
    for r := 0 to raceTints.Count-1 do begin
        AddMessage(raceTints.strings[r]);
        for s := 0 to raceTints.objects[r].count-1 do begin
            AddMessage('|   ' + raceTints.objects[r].strings[s]);
            for l := 0 to raceTints.objects[r].objects[s].count-1 do begin
                AddMessage('|   |   ' + raceTints.objects[r].objects[s].strings[l]);
                for t := 0 to raceTints.objects[r].objects[s].objects[l].count-1 do begin
                    AddMessage(Format('|   |   |   "%s" @ %s', [
                        raceTints.objects[r].objects[s].objects[l].strings[t],
                        PathName(ObjectToElement(raceTints.objects[r].objects[s].objects[l].objects[t]))]));
                end;
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
    thisHP: IwbMainRecord;
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

            // Also update the cached headpart races for any headpart referencing this formlist.
            for i := 0 to headpartRecords.count-1 do begin
                thisHP := ObjectToElement(headpartRecords.objects[i]);
                if EditorID(LinksTo(ElementByPath(thisHP, 'RNAM'))) = EditorID(hpOverride) 
                then begin
                    if LOGGING then LogT(Format('Updating cached headpart races for %s = %s', 
                        [Name(thisHP), hpNewList.CommaText]));
                    headpartRaces.objects[headpartRaces.IndexOf(EditorID(thisHP))].commaText
                        := hpNewList.CommaText;
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
Define label conflicts
}
procedure LabelConflict(label1, label2: string);
begin
    labelConflicts.Add(label1 + '/' + label2);
    labelConflicts.Add(label2 + '/' + label1);
end;


function LabelsConflict(const label1, label2: string): boolean;
begin
    result := (labelConflicts.IndexOf(label1 + '/' + label2) >= 0);
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


{=====================================================================
Assign a comma-separated list of labels to a headpart. Labels are used to identify
appropriate furry headparts for a NPC.
}
procedure LabelHeadpartList(headpartName, labelNames: string);
var
    hpi: integer;
    hpRecord: IwbMainRecord;
begin
    if LOGGING then LogEntry2(1, 'LabelHeadpartList', headpartName, labelNames);
    hpRecord := FindAsset(Nil, 'HDPT', headpartName);
    if not Assigned(hpRecord) then Err(Format('Headpart %s not found', [headpartName]));
    hpi := headpartLabels.IndexOf(headpartName);
    if hpi < 0 then begin
        headpartLabels.AddObject(headpartName, TStringList.Create);
        hpi := headpartLabels.IndexOf(headpartName);
        headpartLabels.objects[hpi].duplicates := dupIgnore;
        headpartLabels.objects[hpi].sorted := true;
    end;
    headpartLabels.objects[hpi].commaText := labelNames;
    CacheHeadpart(hpRecord);
    if LOGGING then LogExitT('LabelHeadpartList');
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
curNPCTintLayer*. 
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