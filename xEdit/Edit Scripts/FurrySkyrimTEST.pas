
unit FurrySkyrimTEST;

interface

implementation

uses FurrySkyrim, FurrySkyrim_Preferences, FurrySkyrimTools, BDScriptTools, BDTestTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    TEST_FILE_NAME = 'TEST.esp';


procedure DoTests;
var 
    e, old: IwbElement;
begin
    AddMessage('============ CHECKING ===============');

    //Aliases work
    AssertStr('Astrid', Unalias('AstridEnd'), 'Astrid alias works');
    AssertStr('AstridXXX', Unalias('AstridXXX'), 'Non-alias works');

    // Nord race should be lykaios race
    e := FindAsset(targetFile, 'RACE', 'NordRace');
    old := FindAsset(FileByIndex(0), 'RACE', 'NordRace');
    AssertStr(EditorID(LinksTo(ElementByPath(e, 'WNAM'))), 'SkinNakedLykaios',
        'Nord skin is now lykaios');
    AssertStr(EditorID(LinksTo(ElementByPath(e, 'RNAM'))), 'KhajiitRace',
        'Nord armor race is now Khajiit');
    AddMessage(GetFileName(GetFile(old)) + ' race has headpart 0: ' + GetElementEditValues(old, 'Head Data\Male Head Data\Head Parts\[0]\HEAD'));
    AddMessage(GetFileName(GetFile(e)) + ' race has headpart 0: ' + GetElementEditValues(e, 'Head Data\Male Head Data\Head Parts\[0]\HEAD'));
    AssertInCompoundList(ElementByPath(e, 'Head Data\Male Head Data\Head Parts'), 
        'HEAD',
        'LykaiosMaleHead');

    // Nord NPC is properly furrified
    old := FindAsset(FileByIndex(0), 'NPC_', 'BalgruuftheGreater');
    Assert(Assigned(old), 'Have BalgruuftheGreater');
    e := FurrifyNPC(old);
    Assert(GetFileName(GetFile(e)) = TEST_FILE_NAME, 'Override created');
    AssertNotInList(ElementByPath(e, 'Head Parts'), 'HumanBeard35');
    AssertNameInList(ElementByPath(e, 'Head Parts'), 'Hair');
    Assert(ElementCount(ElementByPath(e, 'Tint Layers')) > 1, 'At least one tint layer');
    
    old := FindAsset(FileByIndex(0), 'NPC_', 'BolgeirBearclaw');
    e := FurrifyNPC(old);
    AssertInList(ElementByPath(e, 'Head Parts'), '00LykaiosMaleEyesBlue');

    old := FindAsset(FileByIndex(0), 'NPC_', 'AcolyteJenssen');
    e := FurrifyNPC(old);
    AssertInList(ElementByPath(e, 'Head Parts'), '00LykaiosMaleEyesBase');

    old := FindAsset(FileByIndex(0), 'NPC_', 'Ingun');
    e := FurrifyNPC(old);
    AssertNameInList(ElementByPath(e, 'Head Parts'), 'LykaiosHair');

    AddMessage(Format('============ TESTS COMPLETED %s ===============',
        [IfThen(testErrorCount > 0, 
            'WITH ' + IntToStr(testErrorCount) + ' ERRORS',
            'SUCCESSFULLY')]));
end;


{ ======================================================================
Test system functions to demonstrate correct use.
}
Function TestByVar(var j: integer): integer;
begin
    j := 1;
end;

Procedure TestSystemFunc;
var
    sl1, slsub, sl2: TStringList;
    a: string;
    b: string;
    i: integer;
    teti: string;
    tend: float;
    sk: TSkinTintLayer;
    t, t2: TDateTime;
    xf: TTransform;
    fo4: IwbFile;
    ffo: IwbFile;
    armo, hr: IwbMainRecord;
    alpha: array[0..2] of string;
begin
    // can pass variables by var BUT NOT record by var.
    i := 0;
    TestByVar(i);
    AssertInt(i, 1, 'Can pass integer by reference');

    // DOES NOT COMPILE
    // TestRecByVar(xf);
    // AssertInt(xf.z, 3.0, 'Can pass record by reference');

    // Can write time values
    t := Now;
    AddMessage('Current time is ' + TimeToStr(Time));
    
    AddMessage(Format('Can format decimal values: %d', [10]));
    AddMessage(Format('Can format hex values: %.8x', [1023]));
    AddMessage(Format('Can format float values: %f', [10.23]));

    // MatchText throws an access violation
    // alpha[0] := 'A';
    // alpha[1] := 'B';
    // alpha[2] := 'C';
    // AddMessage(IfThen(MatchText('B', alpha), 'B Matches', 'B does not match'));
    // AddMessage(IfThen(MatchText('X', alpha), 'X Matches', 'X does not match'));

    // Can use StringLists of StringLists.
    AddMessage('Demo of stringlists');
    sl1 := TStringList.Create;

    slsub := TStringList.Create;
    slsub.Add('One');
    slsub.Add('Two');
    sl1.AddObject('Alpha', slsub);
    sl1.objects[0].Add('Three');
    slsub := TStringList.Create;

    slsub.Add('A');
    slsub.Add('B');
    sl1.AddObject('Beta', slsub);
    AddMessage(Format('Get SL strings: %s', [sl1.commatext]));
    AddMessage(Format('Index SL by text (Alpha): %d', [integer(sl1.values['Alpha'])])); // This does NOT work
    AddMessage(Format('Index SL by text (Beta): %d', [integer(sl1.values['Beta'])])); // This does NOT work

    sl2 := sl1.objects[0];
    AddMessage(Format('First list has sublist: %s', [sl2.commatext])); // This works
    AddMessage(Format('First subentry is %s', [sl2[0]]));
    AddMessage(Format('First entry in sl1: %s, size %d', [sl1[0], sl1.objects[0].count]));
    AddMessage(Format('First subentry in sl1: %s, "%s"', [sl1[0], TList(sl1.objects[0]).commatext])); // This works
    AddMessage(Format('First subentry in sl1: %s, "%s"', [sl1[0], TList(sl1.objects[0]).strings[0]])); // This works
    AddMessage(Format('First subentry in sl1[1]: %s, "%s"', [sl1[1], TList(sl1.objects[1]).strings[0]])); // This works

    // No way I can find to put records in a TStringList
    // sl1 := TStringList.Create;
    // sk.name := 'TEST';
    // sl1.AddObject('test', sk);
    // sk.name := 'FOO';
    // AddMessage(sk.name);
    // AddMessage(sl1[0]);
    // AddMessage(sl1.objects[0].name);

    // AddPair is not implemented.
    // sl1 := TStringList.Create;
    // sl1.AddPair('foo', 1);
    // sl1.AddPair('bar', 2);
    // AddMessage(Format('First pair: %s / %s', [sl1[0], sl1.values[0]]));
    // AddMessage(Format('Second pair: %s / %s', [sl1[1], sl1.values[1]]));

    // Can associate strings with values.
    sl1 := TStringList.Create;
    sl1.AddObject('foo', 1);
    sl1.AddObject('bar', 2);
    for i := 0 to sl1.Count-1 do begin
        AddMessage(Format('Integer value [%d]: %s / %s', [
            i, sl1[i], IntToStr(sl1.objects[i])]));
    end;

    // HighestOverrideOrSelf index use
    // Check behavior when there is an override
    fo4 := FileByIndex(0);
    armo := FindAsset(fo4, 'ARMO', 'ArmorFalmerBoots');
    AddMessage(Format('ArmorFalmerBoots HighestOverrideOrSelf[0] = %s', [GetFileName(GetFile(HighestOverrideOrSelf(armo, 0)))]));
    AddMessage(Format('ArmorFalmerBoots HighestOverrideOrSelf[1] = %s', [GetFileName(GetFile(HighestOverrideOrSelf(armo, 1)))]));
    AddMessage(Format('ArmorFalmerBoots HighestOverrideOrSelf[100] = %s', [GetFileName(GetFile(HighestOverrideOrSelf(armo, 100)))]));
    AddMessage(Format('ArmorFalmerBoots WinningOverride = %s', [GetFileName(GetFile(WinningOverride(armo)))]));
    AddMessage(Format('ArmorFalmerBoots IsWinningOverride = %s', [BoolToStr(IsWinningOverride(armo))]));
    Assert(not HasNoOverride(armo), 'ArmorFalmerBoots has an override');
    // Check behavior when no override
    hr := FindAsset(fo4, 'RACE', 'ChaurusRace');
    AddMessage(Format('ChaurusRace HighestOverrideOrSelf[0] = %s', [GetFileName(GetFile(HighestOverrideOrSelf(hr, 0)))]));
    AddMessage(Format('ChaurusRace HighestOverrideOrSelf[1] = %s', [GetFileName(GetFile(HighestOverrideOrSelf(hr, 1)))]));
    AddMessage(Format('ChaurusRace HighestOverrideOrSelf[100] = %s', [GetFileName(GetFile(HighestOverrideOrSelf(hr, 100)))]));
    AddMessage(Format('ChaurusRace WinningOverride = %s', [GetFileName(GetFile(WinningOverride(hr)))]));
    AddMessage(Format('ChaurusRace IsWinningOverride = %s', [BoolToStr(IsWinningOverride(armo))]));
    Assert(HasNoOverride(hr), 'ChaurusRace has no override');

    AddMessage('Version number checking');
    AddMessage(Format('xEdit Version %s.%s.%s.%s', [
        IntToStr(xEditMajor), IntToStr(xEditMinor), IntToStr(xEditUpdate), xEditUpdate2]));
    AddMessage(Format('4.0.7a <> xEdit: %s', [IntToStr(XEditVersionCompare(4, 0, 7, 'a'))]));
    AddMessage(Format('4.1.5t <> xEdit: %s', [IntToStr(XEditVersionCompare(4, 1, 5, 't'))]));
    AddMessage(Format('4.1.5m <> xEdit: %s', [IntToStr(XEditVersionCompare(4, 1, 5, 'm'))]));

    // How Hash operates
    AddMessage('Hash(EncBandit03Melee1HTankRedguardF) = ' + IntToStr(Hash('EncBandit03Melee1HTankRedguardF', 1234, 10)));
    AddMessage('Hash(EncBandit03Melee1HTankRedguardM) = ' + IntToStr(Hash('EncBandit03Melee1HTankRedguardM', 1234, 10)));
    AddMessage('Hash(EncBandit04Melee1HTankRedguardF) = ' + IntToStr(Hash('EncBandit04Melee1HTankRedguardF', 1234, 10)));
    AddMessage('Hash(EncBandit04Melee1HTankRedguardM) = ' + IntToStr(Hash('EncBandit04Melee1HTankRedguardM', 1234, 10)));
    AddMessage('Hash(EncBandit03) = ' + IntToStr(Hash('EncBandit03', 1234, 10)));
    AddMessage('Hash(EncBandit04) = ' + IntToStr(Hash('EncBandit04', 1234, 10)));
    AddMessage('Hash(EncBandit05) = ' + IntToStr(Hash('EncBandit05', 1234, 10)));
end;


//==================================================================
//==================================================================
//
function Initialize: integer;
begin
    AddMessage(' ');
    AddMessage(' ');
    AddMessage('====================================');
    AddMessage('============ TESTING ===============');
    AddMessage('====================================');
    AddMessage(' ');
    testErrorCount := 0;

    InitializeLogging;
    LOGGING := True;
    LOGLEVEL := 20;
    if LOGGING then LogEntry(1, 'Initialize');
    PreferencesInit;
    result := 0;
    if LOGGING then LogExitT('Initialize');
end;

function Process(entity: IwbMainRecord): integer;
begin
    result := 0;
end;


function Finalize: integer;
var
    targetFileIndex: integer;
begin
    if LOGGING then LogEntry(1, 'Finalize');
    LOGGING := false;
    TestSystemFunc;
    LOGGING := true;
    SetPreferences;
    ShowRaceAssignments;

    targetFileIndex := FindFile(TEST_FILE_NAME);
    LogD(Format('Found target file at %d', [targetFileIndex]));
    if targetFileIndex < 0 then begin
        targetFile := AddNewFileName(TEST_FILE_NAME);
        LogT('Creating file ' + GetFileName(targetFile));
    end
    else 
        targetFile := FileByIndex(targetFileIndex);

    FurrifyAllRaces;
    FurrifyHeadpartLists;
    ShowHeadparts;
    ShowRaceTints;

    DoTests;

    PreferencesFree;
    result := 0;
    if LOGGING then LogExitT('Finalize');
end;

end.
