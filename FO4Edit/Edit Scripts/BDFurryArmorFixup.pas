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
    Log(11, Format('<ARMAHasRace: %s, %s', [EditorID(arma), EditorID(targetRace)]));
    result := false;
    racename := EditorID(targetRace);
    if EditorID(LinksTo(ElementByPath(arma, 'RNAM'))) = racename then
        result := true
    else begin
        extraList := ElementByPath(arma, 'Additional Races');
        for i := 0 to ElementCount(extraList)-1 do begin
            Log(11, 'Checking additional race entry ' + EditorID(LinksTo(ElementByIndex(extraList, i))));
            if EditorID(LinksTo(ElementByIndex(extraList, i))) = racename then begin
                result := true;
                break;
            end;
        end;
    end;
    Log(11, '>ARMAHasRace: ' + IfThen(result, 'T', 'F'));
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
    LogEntry3(11, 'AddRaceToARMA', GetFileName(targetFile), Name(arma), Name(race));

    if ARMAHasRace(arma, race) then 
        result := arma
    else begin
        AddRecursiveMaster(targetFile, GetFile(arma));
        AddRecursiveMaster(targetFile, GetFile(race));

        result := wbCopyElementToFile(arma, targetFile, False, True);
        extras := Add(result, 'Additional Races', true); 
        entry := ElementAssign(extras, HighInteger, Nil, false);
        Log(11, 'Have load order form ID ' + IntToHex(GetLoadOrderFormID(race), 8));
        SetNativeValue(entry,
            LoadOrderFormIDtoFileFormID(targetFile, GetLoadOrderFormID(race)));
    end;
    LogExit(11, 'AddRaceToArma');
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
    LogEntry3(11, 'AddRaceToAllArmor', GetFileName(targetFile), Name(newRace), Name(existingRace));
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
    LogExit(11, 'AddRaceToAllArmor');
end;

//===========================================================
// Test this functionality.
// Assumes FurryFallout.
Procedure TESTME;
var
    i: integer;
    testFile: IwbFile;
    arma: IwbMainRecord;
    armawin: IwbMainRecord;
    ghoulRace: IwbMainRecord;
    snekRace: IwbMainRecord;
begin
    for i := 0 to FileCount-1 do
        if GetFileName(FileByIndex(i)) = TEST_FILE_NAME then
            testFile := FileByIndex(i);
    if not Assigned(testFile) then
        testFile := AddNewFileName(TEST_FILE_NAME);

    arma := FindAsset(Nil, 'ARMA', 'FFO_AAClothesHardHat');
    armawin := WinningOverride(arma);
    ghoulRace := FindAsset(Nil, 'RACE', 'GhoulRace');
    snekRace := FindAsset(Nil, 'RACE', 'FFOSnekdogRace');
    if ARMAHasRace(armawin, snekRace) then
        AddRaceToARMA(testFile, armawin, ghoulRace);

    // Visual check: ARMA has ghoul race. If run again, still has 
    // ghoul race only once.
end;

Function Finalize(e: IwbMainRecord): integer;
begin
    TESTME;
end;
end.