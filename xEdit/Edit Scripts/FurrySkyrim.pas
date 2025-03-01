
unit FurrySkyrim;

interface

implementation

uses FurrySkyrim_Preferences, FurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    FURRIFIER_VERSION = '1.00';
    SHOW_OPTIONS_DIALOG = False;
    PATCH_FILE_NAME = 'YAPatch.esp'; // Set to whatever
    USE_SELECTION = FALSE;           // FALSE or TRUE

var
    targetFile: IwbFile;


procedure ChangeRace(vanillaRaceName: string; furryRace: IwbMainRecord);
var
    furrifiedRace: IwbMainRecord;
    vanillaRace: IwbMainRecord;
begin
    if LOGGING then LogEntry2(1, 'ChangeRace', vanillaRaceName, Name(furryRace));
    vanillaRace := WinningOverride(FindAsset(Nil, 'RACE', vanillaRaceName));
    LogD(Format('Found race %s in file %s', [Name(vanillaRace), GetFileName(GetFile(vanillaRace))]));
    LogD('Overriding in ' + GetFileName(targetFile));
    AddRecursiveMaster(targetFile, GetFile(vanillaRace));
    AddRecursiveMaster(targetFile, GetFile(furryRace));
    // AddMasterIfMissing(targetFile, FileByIndex(0));
    // AddMasterIfMissing(targetFile, GetFileName(vanillaRace));
    // AddRecursiveMaster(targetFile, GetFile(furryRace));
    furrifiedRace := wbCopyElementToFile(vanillaRace, targetFile, False, True);
    ElementAssign(ElementByPath(furrifiedRace, 'WNAM'), 0, ElementByPath(furryRace, 'WNAM'), false);
    if LOGGING then LogExitT('ChangeRace');
end;


procedure ChangeAllRaces;
// Change all redefined races to their furry equivalent race.
var i: integer;
begin
    for i := 0 to raceAssignments.Count-1 do begin
        ChangeRace(raceAssignments[i], ObjectToElement(raceAssignments.objects[i]));
    end;
end;


//==================================================================
//==================================================================
//
function Initialize: integer;
begin
    LOGGING := True;
    LOGLEVEL := 20;
    if LOGGING then LogEntry(1, 'Initialize');
    PreferencesInit;
    result := 0;
    if LOGGING then LogExitT('Initialize');
end;

function Process(entity: IwbMainRecord): integer;
var
    win: IwbMainRecord;
begin
    result := 0;
end;

function Finalize: integer;
var
    targetFileIndex: integer;
begin
    if LOGGING then LogEntry(1, 'Finalize');
    SetPreferences;
    ShowRaceAssignments;

    targetFileIndex := FindFile(PATCH_FILE_NAME);
    LogD(Format('Found target file at %d', [targetFileIndex]));
    if targetFileIndex < 0 then begin
        targetFile := AddNewFileName(PATCH_FILE_NAME);
        LogT('Creating file ' + GetFileName(targetFile));
    end
    else 
        targetFile := FileByIndex(targetFileIndex);

    ChangeAllRaces;

    PreferencesFree;
    result := 0;
    if LOGGING then LogExitT('Finalize');
end;

end.