{
  Fixes up armor records to handle new races.
	Hotkey: Ctrl+Alt+Q
}

unit BDFurryArmorFixup;

interface

implementation

uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    TEST_FILE_NAME = 'TEST.esp';

//================================================================
// Check an ARMA record and determine if the target race is allowed.
Function ARMAHasRace(arma, targetRace: IwbMainRecord): boolean;
var 
    extraList: IwbElement;
    i: integer;
    racename: string;
begin
    if LOGGING then LogEntry1(11, 'ARMAHasRace', Format('%s, %s', [EditorID(arma), EditorID(targetRace)]));
    result := false;
    racename := EditorID(targetRace);
    if EditorID(LinksTo(ElementByPath(arma, 'RNAM'))) = racename then
        result := true
    else begin
        extraList := ElementByPath(arma, 'Additional Races');
        for i := 0 to ElementCount(extraList)-1 do begin
            if LOGGING then LogD('Checking additional race entry ' + EditorID(LinksTo(ElementByIndex(extraList, i))));
            if EditorID(LinksTo(ElementByIndex(extraList, i))) = racename then begin
                result := true;
                break;
            end;
        end;
    end;
    if LOGGING then LogExitT1('ARMAHasRace', BoolToStr(result)); 
end;

//================================================================
// Add the given race to an ARMA's list of extra races.
// Creates an override for the ARMA in the given file. 
// Returns the new override record.
Function AddRaceToARMA(targetFile: IwbFile; arma, race: IwbMainRecord): IwbMainRecord;
var
    extras: IwbContainer;
    entry: IwbElement;
begin
    if LOGGING then LogEntry3(11, 'AddRaceToARMA', GetFileName(targetFile), Name(arma), Name(race));

    if ARMAHasRace(arma, race) then 
        result := arma
    else begin
        AddRecursiveMaster(targetFile, GetFile(arma));
        AddRecursiveMaster(targetFile, GetFile(race));

        result := wbCopyElementToFile(arma, targetFile, False, True);
        extras := Add(result, 'Additional Races', true); 
        entry := ElementAssign(extras, HighInteger, Nil, false);
        if LOGGING then LogT('Have load order form ID ' + IntToHex(GetLoadOrderFormID(race), 8));
        SetNativeValue(entry,
            LoadOrderFormIDtoFileFormID(targetFile, GetLoadOrderFormID(race)));
    end;
    if LOGGING then LogExitT('AddRaceToArma');
end;

//================================================================
// Add the new race to all armor records that specify the existing race,
// for the entire load order.
Procedure AddRaceToAllArmor(targetFile: IwbFile; newRace, existingRace: IwbMainRecord);
var
    aa: IwbElement;
    armaList: IwbContainer;
    f: integer;
    i: integer;
begin
    if LOGGING then LogEntry3(5, 'AddRaceToAllArmor', GetFileName(targetFile), Name(newRace), Name(existingRace));
    // Walk the file list backwards so we hit winning overrides first.
    for f := FileCount-1 downto 0 do begin
        armaList := GroupBySignature(FileByIndex(f), 'ARMA');
        for i := 0 to ElementCount(armaList)-1 do begin
            aa := ElementByIndex(armaList, i);
            if IsWinningOverride(aa) then 
                if ARMAHasRace(aa, existingRace) then 
                    AddRaceToARMA(targetFile, aa, newRace);
        end;
    end;
    if LOGGING then LogExitT('AddRaceToAllArmor');
end;

//================================================================
// Determine whether f is a FFO file.
Function IsFurryFile(f: IwbFile): Boolean;
var 
    fn: string;
begin
    if LOGGING then LogEntry1(11, 'IsFurryFile', GetFileName(f));
    fn := GetFileName(f);
    result :=
        SameText(fn, 'FurryFallout.esp') 
        or SameText(fn, 'FurryFalloutWorld.esp') 
        or SameText(fn, 'FurryFalloutDLC.esp') 
        or SameText(fn, 'FurryFalloutWorldDLC.esp') 
        or StartsText(fn, 'FFO') // Patches for other mods
        ;
    if LOGGING then LogExitT1('IsFurryFile', BoolToStr(result));
end;

//================================================================
// Determine whether f is a vanilla file.
Function IsVanillaFile(f: IwbFile): Boolean;
var 
    fn: string;
begin
    if LOGGING then LogEntry1(11, 'IsVanillaFile', GetFileName(f));
    fn := GetFileName(f);
    result :=
        SameText(fn, 'Fallout4.esp') 
        or SameText(fn, 'DLCRobot.esp') 
        or SameText(fn, 'DLCWorkshop01.esp') 
        or SameText(fn, 'DLCWorkshop02.esp') 
        or SameText(fn, 'DLCWorkshop03.esp') 
        or SameText(fn, 'DLCCoast.esp') 
        or SameText(fn, 'DLCNukaWorld.esp') 
        ;
    if LOGGING then LogExitT1('IsVanillaFile', BoolToStr(result));
end;

//================================================================
// Return the highest override prior to "mr" that is not in a furry file.
Function GetPriorOverride(mr: IwbMainRecord): IwbMainRecord;
var
    found: boolean;
    m: IwbMainRecord;
    mrFormID: Cardinal;
    oIndex: integer;
    ovr: IwbMainRecord;
begin
    if LOGGING then LogEntry1(5, 'GetPriorOverride', FullPath(mr));
    result := nil;
    found := False;
    mrFormID := GetLoadOrderFormID(mr);
    m := MasterOrSelf(mr);

    for oIndex := OverrideCount(m)-1 downto 0 do begin
        ovr := OverrideByIndex(m, oIndex);
        if LOGGING then LogT('Checking override in file ' + GetFileName(GetFile(ovr)));
        if found then begin
            if not IsFurryFile(GetFile(ovr)) then begin
                result := ovr;
                break;
            end;
        end
        else begin
            found := found or (GetLoadOrderFormID(OverrideByIndex(m, oIndex)) = mrFormID);
        end;
    end;  

    if LOGGING then LogExitT('GetPriorOverride');
end;

//================================================================
// Merge two armor records into the target file. First armor provides the races, second
// provides the rest.
// Returns the new override.
Function MergeArmor(targetFile: IwbFile; armor1, armor2: IwbMainRecord): IwbMainRecord;
var
    e: IwbElement;
    entryList1, entryList2: TStringList;
    i, j: integer;
    id: Cardinal;
    inList: boolean;
    models1, models2, modelsNew: IwbElement;
    n: integer;
    targetName: string;
begin
    if LOGGING then LogEntry3(10, 'MergeArmor', GetFileName(targetFile), Name(armor1), Name(armor2));

    entryList1 := TStringList.Create;
    entryList1.Sorted := False;
    entryList2 := TStringList.Create;
    entryList2.Sorted := False;
    
    models1 := ElementByPath(armor1, 'Models');
    for i := 0 to ElementCount(models1)-1 do begin
        e := ElementByIndex(models1, i);
        targetName := EditorID(LinksTo(ElementByPath(e, 'MODL')));
        if LOGGING then LogT(Format('Found %s at %s', [targetName, FullPath(e)]));
        entryList1.AddObject(EditorID(LinksTo(ElementByPath(e, 'MODL'))), e);
    end;
    
    models2 := ElementByPath(armor2, 'Models');
    for i := 0 to ElementCount(models2)-1 do begin
        e := ElementByIndex(models2, i);
        targetName := EditorID(LinksTo(ElementByPath(e, 'MODL')));
        if LOGGING then LogT(Format('Found %s at %s', [targetName, FUllPath(e)]));
        if entryList1.IndexOf(targetName) < 0 then
            entryList2.AddObject(targetName, e);
    end;

    // Create the override with the consolidated list.
    AddRecursiveMaster(targetFile, GetFile(armor1));
    AddRecursiveMaster(targetFile, GetFile(armor2));

    result := wbCopyElementToFile(armor2, targetFile, False, True);
    RemoveElement(result, 'Models');
    modelsNew := Add(result, 'Models', true); 
    n := 0;
    for i := 0 to entryList1.Count-1 do begin
        e := ObjectToElement(entryList1.Objects[i]);
        if LOGGING then LogT('Copying ' + FullPath(e));
        ElementAssign(modelsNew, n, e, false);
        inc(n);
    end;
    for i := 0 to entryList2.Count-1 do begin
        e := ObjectToElement(entryList2.Objects[i]);
        if LOGGING then LogT('Copying ' + FullPath(e));
        ElementAssign(modelsNew, n, e, false);
        inc(n);
    end;

    entryList1.Free;
    entryList2.Free;
    if LOGGING then LogExitT('MergeArmor');
end;

//================================================================
// "armor" may be overridden by FFO and that override may mask an earlier override by
// another mod. If so, merge the FFO changes with the other mod's changes.
// "armor" must be the winning override.
Function MergeOverride(targetFile: IwbFile; armor: IwbMainRecord): IwbMainRecord;
var
    armorFile: IwbFile;
    priorOverride: IwbMainRecord;
    priorOverrideFile: IwbFile;
begin
    if LOGGING then LogEntry2(5, 'MergeOverride', GetFileName(targetFile), Name(armor));
    result := armor;
    armorFile := GetFile(armor);
    if IsFurryFile(armorFile) then begin
        priorOverride := GetPriorOverride(armor);
        if Assigned(priorOverride) then begin
            priorOverrideFile := GetFile(priorOverride);
            if not IsVanillaFile(priorOverrideFile) then begin
                if LOGGING then LogT(Format('Merging %s from %s and %s', [
                    Name(armor), GetFileName(armorFile), GetFileName(priorOverrideFile)]));
                result := MergeArmor(targetFile, armor, priorOverride);
            end;
        end;
    end;
    if LOGGING then LogExitT('MergeOverride')
end;

//================================================================
// Create an armor override record that merges FFO race additions with any other changes
// in the load order.
Procedure MergeFurryChanges(targetFile: IwbFile);
var
    armor: IwbElement;
    armorList: IwbContainer;
    f: integer;
    i: integer;
begin
    if LOGGING then LogEntry(5, 'MergeFurryChanges');
    // CalcFileEntries;

    for f := 0 to FileCount-1 do begin
        armorList := GroupBySignature(FileByIndex(f), 'ARMO');
        for i := 0 to ElementCount(armorList)-1 do begin
            armor := ElementByIndex(armorList, i);
            if IsWinningOverride(armor) then 
                MergeOverride(targetFile, armor);
        end;
    end;
    if LOGGING then LogExitT('MergeFurryChanges');
end;


end.