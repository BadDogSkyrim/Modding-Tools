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
==============================================================}
Procedure FurrifySchlongLists(raceCompat, raceProb, raceSize: IwbMainRecord);
var
    idx: integer;
    raceEntry: IInterface;
    raceName: string;
    fi: integer;
    listEntries: IwbContainer;
begin
    if LOGGING then LogEntry3(5, 'FurrifySchlongLists', Name(raceCompat), Name(raceProb), Name(raceSize));

    listEntries := ElementByPath(raceCompat, 'FormIDs');
    for idx := ElementCount(listEntries)-1 downto 0 do begin
        raceEntry := ElementByIndex(listEntries, idx);
        raceName := EditorID(LinksTo(raceEntry));
        fi := furryRaces.IndexOf(raceName);
        if LOGGING then LogD(Format('Checking %s: %d', [raceName, fi]));
        if fi >= 0 then 
        begin
            // Schlong is good for a furry race, furrified vanilla race must be added.
            AddVanillaRace(idx, ObjectToElement(furryRaces.objects[fi]), raceCompat, raceProb, raceSize);
        end;
    end;

    if LOGGING then LogExitT('FurrifySchlongLists');
end;

{==============================================================
Add a race to the SOS race form lists.
==============================================================}
Procedure AddVanillaRace(entry: integer; furrifiedRace, raceCompat, raceProb, raceSize: IwbMainRecord);
var
    newElement: IwbElement;
    newProb, newSize: IwbMainRecord;
    rc, rp, rs: IwbMainRecord;
begin
    if LOGGING then LogEntry4(5, 'AddVanillaRace', Name(furrifiedRace), Name(raceCompat), Name(raceProb), Name(raceSize));

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
        WinningOverride(LinksTo(ElementByIndex(ElementByPath(raceProb, 'FormIDs'), entry))), 
        EditorID(furrifiedRace));
    newElement := ElementAssign(ElementByPath(rs, 'FormIDs'), HighInteger, nil, False);
    AssignElementRef(newElement, newSize);

    if LOGGING then LogExitT('AddVanillaRace');
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