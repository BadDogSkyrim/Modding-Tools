{
  xEdit routine to "furrify" all schlongs.
  - Walks through all quests in the load order
  - Finds all quests with ScriptName="SOS_AddonQuest_Script"
  - For each, finds the properties: SOS_Addon_CompatibleRaces, SOS_Addon_RaceProbabilities, SOS_Addon_RaceSizes
  - Adds one empty element to each property array
}

unit BDFurrifySchlongs;
interface
implementation

uses BDFurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils;


{==============================================================
Walk through the whole load order furrifying any schlongs.
==============================================================}
procedure FurrifyAllSchlongs;
var
    i: integer;
    quest: IWBMainRecord;
    group: IWBMainRecord;
    j: integer;
begin
    if LOGGING then LogEntry(0, 'FurrifyAllSchlongs');
    for i := 0 to Pred(FileCount) do begin
        group := GroupBySignature(FileByIndex(i), 'QUST');
        if not Assigned(group) then Continue;

        if LOGGING then LogD(Format('Processing file %s with %d quests', [GetFileName(FileByIndex(i)), ElementCount(group)]));
        for j := 0 to ElementCount(group) - 1 do begin
            quest := ElementByIndex(group, j);
            FurrifyQuest(quest);
        end;
    end;
    if LOGGING then LogExitT('FurrifyAllSchlongs');
end;



{==============================================================
If the given quest is for SOS, furrify the parts.
==============================================================}
procedure FurrifyQuest(quest: IInterface);
var
    i, j: integer;
    script, prop, arr: IInterface;
    scripts, properties: IInterface;
    scriptName: string;
    raceCompat, raceSize, raceProb: IwbMainRecord;
begin
    // Get VMAD/scripts
    scripts := ElementByPath(quest, 'VMAD\Scripts');
    if not Assigned(scripts) then
        Exit;

    // Loop through all scripts
    for i := 0 to ElementCount(scripts) - 1 do begin
        script := ElementByIndex(scripts, i);
        scriptName := GetEditValue(ElementByPath(script, 'ScriptName'));
        if scriptName <> 'SOS_AddonQuest_Script' then
            Continue;
        if LOGGING then LogD(Format('Furrifying SOS quest %s', [EditorID(quest)]));

        // Get properties
        properties := ElementByPath(script, 'Properties');
        if not Assigned(properties) then
            Continue;

        // Loop through properties
        for j := 0 to ElementCount(properties) - 1 do begin
            prop := ElementByIndex(properties, j);
            If GetEditValue(ElementByPath(prop, 'propertyName')) = 'SOS_Addon_CompatibleRaces' then 
                raceCompat := WinningOverride(LinksTo(
                    ElementByPath(prop, 'Value\Object Union\Object v2\FormID')))
            else If GetEditValue(ElementByPath(prop, 'propertyName')) = 'SOS_Addon_RaceProbabilities' then 
                raceProb := WinningOverride(LinksTo(
                    ElementByPath(prop, 'Value\Object Union\Object v2\FormID')))
            else If GetEditValue(ElementByPath(prop, 'propertyName')) = 'SOS_Addon_RaceSizes' then 
                raceSize := WinningOverride(LinksTo(
                    ElementByPath(prop, 'Value\Object Union\Object v2\FormID')));
            
            if Assigned(raceCompat) and Assigned(raceProb) and Assigned(raceSize) then begin
                FurrifySchlongLists(raceCompat, raceProb, raceSize);
                Break;
            end;
        end;
    end;
end;

{==============================================================
Furrify the three SOS lists.

If the lists contain a furry race, add the furrified race if not already there.

If the lists contain a furrified race and not its associated furry race, remove the
furrified race.
==============================================================}
Procedure FurrifySchlongLists(raceCompat, raceProb, raceSize: IwbMainRecord);
var
    addRaces: TStringList;
    e: IwbElement;
    fi, fi2: integer;
    furryList: TStringList;
    i, j: integer;
    idx: integer;
    listEntries: IwbContainer;
    raceEntry: IInterface;
    raceName: string;
    removeRaces: TStringList;
    schlongRaces: TStringList;
    fr: IwbMainRecord;
    frName: string;
    furryRaceAssignments: TStringList;
begin
    if LOGGING then LogEntry3(5, 'FurrifySchlongLists', Name(raceCompat), Name(raceProb), Name(raceSize));

    listEntries := ElementByPath(raceCompat, 'FormIDs');
    schlongRaces := TStringList.Create;
    schlongRaces.Duplicates := dupIgnore;
    schlongRaces.Sorted := TRUE;
    addRaces := TStringList.Create;
    addRaces.Duplicates := dupIgnore;
    addRaces.Sorted := TRUE;
    removeRaces := TStringList.Create;
    removeRaces.Duplicates := dupIgnore;
    removeRaces.Sorted := TRUE;
    // Collect all races already on the schlong
    for i := 0 to ElementCount(listEntries)-1 do begin
        raceEntry := WinningOverride(LinksTo(ElementByIndex(listEntries, i)));
        schlongRaces.AddObject(EditorID(raceEntry), raceEntry);
    end;
    if LOGGING then LogD('Found races: ' + schlongRaces.CommaText);

    for i := 0 to schlongRaces.Count-1 do begin
        // If it's a furry race, add furrified races
        fi := furryRaces.IndexOf(schlongRaces[i]);
        if fi >= 0 then begin
            furryRaceAssignments := furryRaces.Objects[fi];
            for j := 0 to furryRaceAssignments.Count-1 do begin
                fr := ObjectToElement(furryRaceAssignments.Objects[j]);
                frName := EditorID(fr);
                if LOGGING then LogD(Format('Have furry race %s assigned to race %s', [
                    schlongRaces[i], EditorID(fr)
                ]));
                if schlongRaces.IndexOf(frName) < 0 then begin
                    addRaces.AddObject(frName, fr);
                    if LOGGING then LogD(Format('Adding to compatible schlongs: %s', [Name(fr)]));
                end;
            end;
        end
        else begin
            // Check if the list entry is furrified
            fi := raceAssignments.IndexOf(schlongRaces.strings[i]);
            if fi >= 0 then begin
                // This entry has been furrified. Get the furry race.
                fr := ObjectToElement(raceAssignments.Objects[fi]);
                // If the furry race is not in the list, remove the furrified race
                fi2 := schlongRaces.IndexOf(EditorID(fr));
                if LOGGING then LogD(Format('Have furrifed race %s / furry race %s in schlong list at %d', [
                    schlongRaces.strings[i], EditorID(fr), Integer(fi2)
                ]));
                if fi2 < 0 then begin
                    removeRaces.AddObject(schlongRaces.strings[i], schlongRaces.objects[i]);
                    if LOGGING then LogD(Format('Removing from compatible schlongs: %s', [
                        Name(ObjectToElement(schlongRaces.objects[i]))]));
                end;
            end;
        end;
    end;

    if removeRaces.Count > 0 then begin
        for i := ElementCount(listEntries)-1 downto 0 do begin
            e := ElementByIndex(listEntries, i);
            if LOGGING then LogD(Format('Checking for removal: %s at index %d', [
                EditorID(LinksTo(e)), i
            ]));
            if removeRaces.IndexOf(EditorID(LinksTo(e))) >= 0 then begin
                RemoveFurrifiedRace(i, raceCompat, raceProb, raceSize);
                if LOGGING then LogD(Format('Removed %s at index %d', [
                    EditorID(LinksTo(e)), i
                ]));
            end;
        end;
    end;

    for i := 0 to addRaces.Count-1 do begin 
        AddFurrifiedRace(
            ObjectToElement(addRaces.objects[i]), 
            raceCompat, raceProb, raceSize);
        if LOGGING then LogD(Format('Added %s', [
            EditorID(ObjectToElement(addRaces.objects[i]))
        ]));
    end;

    schlongRaces.Free;
    addRaces.Free;
    removeRaces.Free;
    
    // for idx := ElementCount(listEntries)-1 downto 0 do begin
    //     raceEntry := ElementByIndex(listEntries, idx);
    //     raceName := EditorID(LinksTo(raceEntry));
    //     fi := furryRaces.IndexOf(raceName);
    //     if LOGGING then LogD(Format('Checking %s: %d', [raceName, fi]));
    //     if fi >= 0 then 
    //     begin
    //         furryList := furryRaces.objects[fi];
    //         for i := 0 to furryList.Count-1 do begin
    //             // Schlong is good for a furry race, furrified vanilla race must be added.
    //             AddFurrifiedRace(idx, ObjectToElement(furryList.objects[i]), 
    //                 raceCompat, raceProb, raceSize);
    //         end;
    //     end;
    // end;

    if LOGGING then LogExitT('FurrifySchlongLists');
end;


{==============================================================
Remove a race from the SOS form lists.
===============================================================}
Procedure RemoveFurrifiedRace(entryIndex: integer; raceCompat, raceProb, raceSize: IwbMainRecord);
var
    rec: IwbMainRecord;
    e: IwbElement;
begin
    if LOGGING then LogEntry4(5, 'RemoveFurrifiedRace', IntToStr(entryIndex), Name(raceCompat), Name(raceProb), Name(raceSize));
    rec := MakeOverride(raceCompat, targetFile);
    e := ElementByIndex(ElementByPath(rec, 'FormIDs'), entryIndex);
    Remove(e);

    rec := MakeOverride(raceProb, targetFile);
    e := ElementByIndex(ElementByPath(rec, 'FormIDs'), entryIndex);
    Remove(e);

    rec := MakeOverride(raceSize, targetFile);
    e := ElementByIndex(ElementByPath(rec, 'FormIDs'), entryIndex);
    Remove(e);

    if LOGGING then LogExitT('RemoveFurrifiedRace');
end;


{==============================================================
Add a race to the SOS race form lists.

entry -> The index of the furry race entry to copy thte new furrified entry from.
==============================================================}
Procedure AddFurrifiedRace(furrifiedRace, raceCompat, raceProb, raceSize: IwbMainRecord);
var
    newElement: IwbElement;
    newProb, newSize: IwbMainRecord;
    rc, rp, rs: IwbMainRecord;
    entry: integer; 
    frRaceIdx: integer;
    frRace: IwbMainRecord;
    frList: IwbContainer;
begin
    if LOGGING then LogEntry4(5, 'AddFurrifiedRace', Name(furrifiedRace), Name(raceCompat), Name(raceProb), Name(raceSize));

    // Figure out where we will copy probs and sizes from
    frRaceIdx := raceAssignments.indexOf(EditorID(furrifiedRace));
    frRace := ObjectToElement(raceAssignments.objects[frRaceIdx]);
    frList := ElementByPath(raceCompat, 'FormIDs');
    entry := ElementListNameIndex(frlist, EditorID(frRace));
    if entry < 0 then begin
        Warn('No furry race in list to copy from');
        entry := HighInteger;
    end;

    // Adds a new element to the form list with the given FormID
    rc := MakeOverride(raceCompat, targetFile);
    newElement := ElementAssign(ElementByPath(rc, 'FormIDs'), HighInteger, nil, False);
    AssignElementRef(newElement, furrifiedRace);

    rp := MakeOverride(raceProb, targetFile);
    newProb := CopyGlobal(
        WinningOverride(LinksTo(ElementByIndex(ElementByPath(raceProb, 'FormIDs'), entry))), 
        EditorID(furrifiedRace));
    newElement := ElementAssign(ElementByPath(rp, 'FormIDs'), HighInteger, nil, False);
    AssignElementRef(newElement, newProb);

    rs := MakeOverride(raceSize, targetFile);
    newSize := CopyGlobal(
        WinningOverride(LinksTo(ElementByIndex(ElementByPath(raceSize, 'FormIDs'), entry))), 
        EditorID(furrifiedRace));
    newElement := ElementAssign(ElementByPath(rs, 'FormIDs'), HighInteger, nil, False);
    AssignElementRef(newElement, newSize);

    if LOGGING then LogExitT('AddFurrifiedRace');
end;

{==============================================================
Create a copy of the given record in the furry patch file, with a new EditorID.
==============================================================}
function CopyGlobal(orig: IwbMainRecord; furrifiedRaceEditorID: string): IwbMainRecord;
var
    newRecord: IwbMainRecord;
    newEditorID: string;
begin
    if LOGGING then LogEntry2(5, 'CopyGlobal', Name(orig), furrifiedRaceEditorID);

    newRecord := wbCopyElementToFile(orig, targetFile, True, True);
    if Assigned(newRecord) then 
    begin
        // Set new EditorID
        newEditorID := EditorID(orig) + '_' + furrifiedRaceEditorID;
        SetElementEditValues(newRecord, 'EDID', newEditorID);
    end
    else 
        Warn(Format('Failed to create copy of %s in %s', [EditorID(orig), GetFileName(targetFile)]));
    Result := newRecord;

    if LOGGING then LogExitT1('CopyGlobal', Name(newRecord));
end;

end.