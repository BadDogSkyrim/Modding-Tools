{
	Hotkey: Ctrl+Alt+T
}
unit TEST_BDAssetLoaderFO4;

interface
implementation
uses FFO_Furrifier, FFOGenerateNPCs, BDAssetLoaderFO4, xEditAPI, Classes, SysUtils, StrUtils, Windows;

var
    testErrorCount: integer;
    modFile: IwbFile;
    LIST_ALL_TINT_LAYERS: Boolean;
    LIST_HAIR_TRANSLATIONS: Boolean;
    LIST_RACE_DISTRIBUTION: Boolean;

procedure Assert(v: Boolean; msg: string);
begin
    if v then 
        AddMessage('OK: ' + msg)
    else
    begin
        AddMessage('XXXXXX Error: ' + msg);
        testErrorCount := testErrorCount + 1;
        Raise Exception.Create('Assert fail');
    end;
end;

procedure AssertInt(actual, expected: integer; msg: string);
begin
    Assert(actual = expected, Format(msg + ': %d = %d', 
        [integer(actual), integer(expected)]));
end;

procedure AssertFloat(actual, expected: float; msg: string);
begin
    Assert(actual = expected, Format(msg + ': %f = %f', 
        [actual, expected]));
end;

procedure AssertStr(actual, expected: string; msg: string);
begin
    Assert(actual = expected, Format(msg + ': "%s" = "%s"', [actual, expected]));
end;

Function Initialize: integer;
begin
  
end;

//=======================================================================
// Check to ensure the given IwbContainer contains the record referenced by editor ID.
// Also ensures all elements of the list are valid.
Procedure AssertInList(elist: IwbContainer; target: string);
var
    i: integer;
    ref: IwbMainRecord;
    found: boolean;
begin
    found := false;
    for i := 0 to ElementCount(elist)-1 do begin
        Assert(Assigned(ElementByIndex(elist, i)), Format('List element at [%d] assigned', [i]));
        ref := LinksTo(ElementByIndex(elist, i));
        if (target <> '') and (EditorID(ref) = target) then found := true;
    end;
    if target <> '' then
        Assert(found, Format('Found target element %s in %s', [target, Path(elist)]));
end;

//=======================================================================
// Check for errors in a NPC's headparts.
// If provided, must have a headpart of the given type and name.
Procedure AssertNoZeroTints(npc: IwbMainRecord);
var
    e: IwbElement;
    elist: IwbElement;
    i: integer;
    v: float;
begin
    elist := ElementByPath(npc, 'Face Tinting Layers');
    for i := 0 to ElementCount(elist)-1 do begin
        e := ElementByIndex(elist, i);
        v := GetNativeValue(ElementByPath(e, 'TEND\Value'));
        Assert(v > 0.0001, Format('Have non-zero alpha for [%s]: %s', [FullPath(e), FloatToStr(v)]));
    end;
end;

//=======================================================================
// Check for errors in a NPC's headparts.
// If provided, must have a headpart of the given type and name.
Procedure AssertGoodHeadparts(npc: IwbMainRecord; targetType: string; targetHeadpart: string);
var
    elist: IwbElement;
    headpart: IwbMainRecord;
    hp: IwbMainRecord;
    i: integer;
begin
    hp := Nil;
    elist := ElementByPath(npc, 'Head Parts');
    for i := 0 to ElementCount(elist)-1 do begin
        Assert(Assigned(ElementByIndex(elist, i)), Format('Headpart at [%d] assigned', [i]));
        headpart := LinksTo(ElementByIndex(elist, i));
        if targetType <> '' then begin
            if GetElementEditValues(headpart, 'PNAM') = targetType then
                hp := headpart;
        end;
    end;
    Assert(Assigned(hp), Format('Assert have %s as %s', [targetHeadpart, targetType]));
    if targetHeadpart <> '' then
        AssertStr(EditorID(hp), targetHeadpart, 'Have correct headpart for ' + targetType);
end;

//=======================================================================
// Check for errors in a NPC's morphs.
// If provided, must have a morph of the given name.
Procedure AssertMorph(npc: IwbMainRecord; targetMorph: integer);
var
    elist: IwbElement;
    val: integer;
    found: boolean;
    i: integer;
begin
    found := false;
    elist := ElementByPath(npc, 'MSDK');
    for i := 0 to ElementCount(elist)-1 do begin
        Assert(Assigned(ElementByIndex(elist, i)), Format('Morph at [%d] assigned', [i]));
        val := GetNativeValue(ElementByIndex(elist, i));
        if val = targetMorph then found := true;
    end;
    Assert(found, Format('Found target value %.8x', [targetMorph]));
    // Assert(Assigned(hp), Format('Assert have %s as %s', [targetHeadpart, targetType]));
    // if targetHeadpart <> '' then
    //     AssertStr(EditorID(hp), targetHeadpart, 'Have correct headpart for ' + targetType);
end;

// =========================================================================
// Check for errors in a NPC's tint layers.
// If non-zero, targetLayerIndex must be in the list.
Procedure AssertGoodTintLayers(npc: IwbMainRecord; targetLayerIndex: integer);
var
    ftl: IwbElement;
    i: integer;
    ele: IwbElement;
    tetiIndex: integer;
    tetiStr: string;
    foundTarget: boolean;
begin
    ftl := ElementByPath(npc, 'Face Tinting Layers');
    foundTarget := (targetLayerIndex = 0);
    Assert(ElementCount(ftl) > 0, 'Have tints for ' + EditorID(npc));
    for i := 0 to ElementCount(ftl)-1 do begin
        ele := ElementByIndex(ftl, i);
        tetiIndex := GetElementNativeValues(ele, 'TETI\Index');
        tetiStr := GetElementEditValues(ele, 'TETI\Index');
        Assert(tetiIndex <> 0, Format('%s`s TETI Index [%d] (%s) not 0: %d', [EditorID(npc), i, tetiStr, tetiIndex]));
        foundTarget := foundTarget or (tetiIndex = targetLayerIndex);
    end;
    if targetLayerIndex <> 0 then 
        Assert(foundTarget, Format('Found target tint layer %d', [targetLayerIndex]));
end;

// =========================================================================
// Check for errors in a NPC's tint layers.
// If non-zero, targetLayerIndex must NOT be in the list.
Procedure AssertGoodTintLayersNeg(npc: IwbMainRecord; targetLayerIndex: integer);
var
    ftl: IwbElement;
    i: integer;
    ele: IwbElement;
    tetiIndex: integer;
    tetiStr: string;
    foundTarget: boolean;
begin
    ftl := ElementByPath(npc, 'Face Tinting Layers');
    foundTarget := false;
    Assert(ElementCount(ftl) > 0, 'Have tints for ' + EditorID(npc));
    for i := 0 to ElementCount(ftl)-1 do begin
        ele := ElementByIndex(ftl, i);
        tetiIndex := GetElementNativeValues(ele, 'TETI\Index');
        tetiStr := GetElementEditValues(ele, 'TETI\Index');
        Assert(tetiIndex <> 0, Format('%s`s TETI Index [%d] (%s) not 0: %d', [EditorID(npc), i, tetiStr, tetiIndex]));
        if (targetLayerIndex <> 0) and (targetLayerIndex = tetiIndex) then foundTarget := true;
    end;
    if targetLayerIndex <> 0 then 
        Assert(not foundTarget, Format('Did not find target tint layer %d', [targetLayerIndex]));
end;

//===========================================================
// Test this functionality.
// Assumes FFOTESTPre.esp, FurryFallout.esp.
Procedure TestFurryArmorFixup;
var
    arma: IwbMainRecord;
    armawin: IwbMainRecord;
    fn: string;
    ghoulRace: IwbMainRecord;
    haveTestESP: Boolean;
    i: integer;
    modelsNew: IwbElement;
    mr, mrNew: IwbMainRecord;
    snekRace: IwbMainRecord;
    testFile: IwbFile;
begin
    LogEntry(0, 'TestFurryArmorFixup');
    haveTestESP := False;
    for i := 0 to FileCount-1 do begin
        fn := GetFileName(FileByIndex(i));
        if fn = TEST_FILE_NAME then
            testFile := FileByIndex(i)
        else if fn = 'FFOTESTPre.esp' then
            haveTestESP := True;
    end;
    if not Assigned(testFile) then
        testFile := AddNewFileName(TEST_FILE_NAME);

    if not haveTestESP then exit;

    arma := FindAsset(Nil, 'ARMA', 'FFO_AAClothesHardHat');
    armawin := WinningOverride(arma);
    ghoulRace := FindAsset(Nil, 'RACE', 'GhoulRace');
    snekRace := FindAsset(Nil, 'RACE', 'FFOSnekdogRace');
    if ARMAHasRace(armawin, snekRace) then
        AddRaceToARMA(testFile, armawin, ghoulRace);

    // Visual check: ARMA has ghoul race. If run again, still has 
    // ghoul race only once.

    // Check that armors are correctly merged.
    mr := FindAsset(Nil, 'ARMO', 'ClothesResident7Hat');
    mrNew := MergeOverride(modFIle, WinningOverride(mr));
    AssertStr(GetFileName(GetFile(mrNew)), TEST_FILE_NAME, 'Created override in test file');
    AssertStr(GetElementEditValues(mrNew, 'FULL'), 'Newsboy Cap TEST', 'Armor correctly renamed');
    modelsNew := ElementByPath(mrNew, 'Models');
    AssertStr(EditorID(RecordAtIndex(modelsNew, 0, 'MODL')), 'FFO_AAClothesResident7Hat',
        'FFO addon is first');
    AssertStr(EditorID(RecordAtIndex(modelsNew, 1, 'MODL')), 'AAClothesResident7Hat',
        'Vanilla addon is second');
    AssertStr(EditorID(RecordAtIndex(modelsNew, 2, 'MODL')), 'AAClothesBaseballHat',
        'Order is preserved');

    AssertInt(ElementCount(modelsNew), 3, 'Lists properly merged'); 
    LogExitT('TestFurryArmorFixup');
end;

// DOES NOT COMPILE
// procedure TestArray(s: string; const Args: array of const);
// begin
// end;

Function TestByVar(var j: integer): integer;
begin
    j := 1;
end;

// DOES NOT COMPILE
Procedure TestRecByVar(var r: TTransform);
begin
    r.x := 1.0;
    r.y := 2.0;
    r.z := 3.0;
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
begin
    // can pass by var
    i := 0;
    TestByVar(i);
    AssertInt(i, 1, 'Can pass integer by reference');

    // DOES NOT COMPILE
    // TestRecByVar(xf);
    // AssertInt(xf.z, 3.0, 'Can pass record by reference');

    // Can write time values
    t := Now;
    AddMessage('Current time is ' + TimeToStr(Time));
    
    AddMessage(Format('Can format hex values: %.8x', [1023]));
    AddMessage(Format('Can format float values: %f', [10.23]));

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

end;

//-------------------------------------------------------------------------
// Test our hashing mchanism
Procedure TestHashing;
var
    f: IwbFile;
    h1: array [1..10] of integer;
    h2: array [1..10] of integer;
    i: integer;
    npc1, npc2: IwbMainRecord;
begin
    AddMessage('Same hash, different seeds');
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 4039, 100)]));
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 3828, 100)]));
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 2493, 100)]));
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 5141, 100)]));
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 5939, 100)]));
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 1663, 100)]));
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 6337, 100)]));

    AddMessage('Consecutive hash, same seed');
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate01', 8707, 100)]));
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate02', 8707, 100)]));
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate03', 8707, 100)]));
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate04', 8707, 100)]));
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate05', 8707, 100)]));
    AddMessage(Format('Hash = %d', [Hash('RaderMeleeTemplate06', 8707, 100)]));

    f := FileByIndex(0);

    furrifiedNPCs := TStringList.Create;
    AddMessage('Hashing NPCs by signature');
    npc1 := FindAsset(f, 'NPC_', 'DiamondCityResidentTemplate00');
    NPC_Setup(npc1);
    RecordNPC(npc1, 'TestSig');
    NPC_Print;
    for i := 1 to 10 do begin
        h1[i] := NPC_Hash(i*7, 5);
        AddMessage(Format('NPC1: %d = %d', [i, h1[i]]));
    end;
    npc2 := FindAsset(f, 'NPC_', 'EncRaider01Boss');
    NPC_Setup(npc2);
    RecordNPC(npc2, 'TestSig');
    NPC_Print;
    for i := 1 to 10 do begin
        h2[i] := NPC_Hash(i*7, 5);
        AddMessage(Format('NPC2: %d = %d', [i, h2[i]]));
    end;

    for i := 1 to 10 do begin
        AssertInt(h1[i], h2[i], 'Signatures cause different NPCs to get same hash value');
    end;
    furrifiedNPCs.Free;
end;

Procedure ShowClassProbabilities;
var
    i, j: integer;
    n: integer;
    f: float;
begin
    AddMessage('---Class probabilities---');
    for i := CLASS_LO to CLASS_HI do begin
        for j := RACE_LO to RACE_HI do begin
            n := classProbsMax[i, j] - classProbsMin[i, j] + 1;
            n := max(n, 0);
            // AddMessage('Adjusted num choices: ' + IntToStr(n));
            // AddMessage(': ' + FloatToStr(f));
            // AddMessage('Proabability: ' + FloatToStr(f));
            // AddMessage('Percent: ' + IntToStr(int(100*f)));
            if (n > 0) and (classProbs[i, masterRaceList.Count] > 0) then begin
                f := n / classProbs[i, masterRaceList.Count];
                AddMessage('Probability '
                    + GetNPCClassName(i) + ' '
                    + masterRaceList[j] + ': '
                    + IntToStr(int(100 * f))
                );
                // // *** Show raw values
                // AddMessage(Format('Probability %s %s [%d - %d] of %d', [
                //     GetNPCClassName(i),
                //     masterRaceList[j],
                //     classProbsMin[i, j],
                //     classProbsMax[i, j],
                //     classProbs[i, masterRaceList.Count]
                // ]));
            end;
        end;
        AddMessage('-');
    end;
end;

//-------------------------------------------------------------------------
// Test the furrifier
Procedure TestFFOFurrifier;
var
    a: string;
    b: string;
    classCounts: array[0..40 {CLASS_COUNT}, 0..50 {MAX_RACES}] of integer;
    elem: IwbElement;
    elem2: IwbElement;
    elist: IwbContainer;
    f: IwbFile;
    fl: TStringList;
    furryNPC: IwbMainRecord;
    g: IwbContainer;
    hair: IwbMainRecord;
    headpart: IwbMainRecord;
    hr: Word;
    i: integer;
    j: integer;
    k: integer;
    lykaiosIndex: integer;
    lykaiosRace: IwbMainRecord;
    m: integer;
    min: Word;
    msec: Word;
    n: integer;
    name: string;
    npc: IwbMainRecord;
    npcCathy: IwbMainRecord;
    npcClass: integer;
    npcDesdemona: IwbMainRecord;
    npcGroup: IwbGroupRecord;
    npcHancock: IwbMainRecord;
    npcJohn: IwbMainRecord;
    npcList: array [1..10] of IwbMainRecord;
    npcMason: IwbMainRecord;
    npcPiper: IwbMainRecord;
    npcRace: integer;
    npcRaceList: array [1..10] of integer;
    race: IwbMainRecord;
    raceID: Cardinal;
    racename: string;
    racepnam: float;
    rec: IwbMainRecord;
    sec: Word;
    sk: TSkinTintLayer;
    sl1, slsub, sl2: TStringList;
    t, t2: TDateTime;
    tend: float;
    teti: string;
begin
    LOGLEVEL := 1;
    f := FileByIndex(0);

    // ------------------------------------------------------------------------------
    //
    //      Ghoul Gear
    //
    // Any AA's that reference snekdogs should now support ghouls.
    rec := WinningOverride(FindAsset(nil, 'ARMA', 'FFO_AAClothesHancocksHat'));
    AssertInList(ElementByPath(rec, 'Additional Races'), 'GhoulRace');
    
    rec := WinningOverride(FindAsset(nil, 'ARMA', 'FFOSnekNakedChildHands'));
    AssertInList(ElementByPath(rec, 'Additional Races'), 'GhoulChildRace');

    // ------------------------------------------------------------------------------
    //
    //      TESTING RACE INFO
    //
    // masterRaceList has a list of all the furry races that were found.
    // A particular race can be found by name.

    Assert(masterRaceList.Count > 8, 'Found furry races: ' + IntToStr(masterRaceList.Count));
    lykaiosIndex := RacenameIndex('FFOLykaiosRace');
    Assert(lykaiosIndex >= 0, 'Found the Lykaios race.');
    lykaiosRace := ObjectToElement(masterRaceList.Objects[lykaiosIndex]);
    Assert(SameText(EditorID(lykaiosRace), 'FFOLykaiosRace'), 'Recovered the Lykaios race record');

    if {listing races} FALSE then begin
        AddMessage('---Can iterate through the masterRaceList');
        for i := 0 to masterRaceList.Count-1 do 
            for j := 0 to 3 do 
                AddMessage(Format('[%d %d %s] %s', [
                    i, j, masterRaceList[i], EditorID(raceInfo[i, j].mainRecord)]));

        AddMessage('---Can iterate through childRaceList');
        for i := 0 to childRaceList.Count-1 do
            AddMessage(Format('Child Race [%d] %s', [i, childRaceList[i]]));
        end;
    AssertInt(childRaceList.Count, masterRaceList.Count, 'Child race list same length as master');

    // ---------- Child Races
    AssertStr(EditorID(raceInfo[lykaiosIndex, MALECHILD].mainRecord), 'FFOLykaiosChildRace',
        'Found child race for Lykaios');
    Assert(childRaceList.IndexOf('FFOLykaiosChildRace') >= 0, 'Have lykaios child race');

    // ---------- Race Assets
    if {listing race assets} FALSE then begin
        for i := 0 to masterRaceList.Count-1 do 
            AddMessage('[' + IntToStr(i) + '] ' + masterRaceList[i]);

        AddMessage('---Can iterate through the tint list');
        for i := 0 to tintlayerName.Count-1 do
            AddMessage(Format('[%d] %s', [i, tintlayerName[i]]));
        end;

    if {Showing race/tint probabilities} FALSE then begin
        AddMessage('---Can iterate through tint probabilities');
        for i := 0 to masterRaceList.Count-1 do 
            for j := 0 to tintlayerName.Count-1 do
                for k := SEX_LO to SEX_HI do
                    AddMessage(Format('Probability [%d/%d] %s %s %s = %d', [
                        integer(i),
                        integer(j),
                        masterRaceList[i], 
                        tintlayerName[j], 
                        IfThen(k=MALE, 'M', 'F'), 
                        integer(raceInfo[i, k].tintProbability[j])
                        ]));
        end;
    Assert(raceInfo[RacenameIndex('FFOHorseRace'), MALE].tintProbability[TL_MASK] = 100, 'Have tint probability');

    // Can access particular morphs
    elem := GetMorphPreset(
        ObjectToElement(raceInfo[RACE_DEER, MALE].morphGroups.objects[
            raceInfo[RACE_DEER, MALE].morphGroups.IndexOf('Nostrils')
            ]), 
        'Broad');
    AssertStr(GetElementEditValues(elem, 'MPPN'), 'Broad', 'Can read the morph presets');

    Assert(raceInfo[RACE_HORSE, MALE].morphExcludes.Count > 0, 
        Format('Have morph exclusions for horse: %s', 
            [raceInfo[RACE_HORSE, MALE].morphExcludes.commatext]));

    Assert(raceInfo[RACE_HORSE, FEMALE].morphSkew.Count > 0, 
        Format('Have morph skews for horse: %d: %s', [
                raceInfo[RACE_HORSE, FEMALE].morphSkew.Count,
                raceInfo[RACE_HORSE, FEMALE].morphSkew.commatext
        ])
    );
    Assert(raceInfo[RACE_HORSE, FEMALE].morphSkew.objects[0] = SKEW0, 
        Format('Have morph skew value for horse "%s" = %d', [
                raceInfo[RACE_HORSE, FEMALE].morphSkew[0],
                integer(raceInfo[RACE_HORSE, FEMALE].morphSkew.objects[0])
        ])
    );

    n := raceInfo[RACE_HORSE, FEMALE].morphProbability.IndexOf('Horse - Ears');
    Assert(n >= 0, 'Have morph setting for "Horse - Ears"');
    AssertInt(raceInfo[RACE_HORSE, FEMALE].morphProbability.objects[n], 80, 'Have correct probability for "Horse - Ears"');

    If {showing all morphs} FALSE then begin
        AddMessage('-------Morphs--------');
        for i := RACE_LO to RACE_HI do begin
            for j := SEX_LO to SEX_HI do begin
                if Assigned(raceInfo[i, j].morphGroups) then begin
                    for k := 0 to raceInfo[i, j].morphGroups.Count-1 do begin
                        elem := ObjectToElement(raceInfo[i, j].morphGroups.objects[k]);
                        elist := ElementByPath(elem, 'Morph Presets');
                        for n := 0 to ElementCount(elist)-1 do begin
                            elem2 := ElementByIndex(elist, n);
                            AddMessage(Format('%s %s [%s] [%s - %s] ', [
                                EditorID(raceInfo[i, MALE].mainRecord),
                                SexToStr(j),
                                raceInfo[i, j].morphGroups[k],
                                GetElementEditValues(elem2, 'MPPI'), 
                                GetElementEditValues(elem2, 'MPPN')
                                ]));
                        end;
                    end;
                end;
            end;
        end;
        end;

    // We don't get the face morphs from the race record--we have to 
    // be told about them.
    Assert(raceInfo[RACE_HORSE, MALE].faceBoneList.Count > 0, Format(
        'Have facebones for horse: %s',
        [raceInfo[RACE_HORSE, MALE].faceBoneList.commatext]
    ));
    AssertInt(raceInfo[RACE_HORSE, MALE].faceBones[0].FMRI, 09, 
        'Horse "Nose - Full" FMRI value correct');
    AssertFloat(raceInfo[RACE_HORSE, MALE].faceBones[0].min.scale, -0.4, 
        'Horse "Nose - Full" min scale value correct');
    if {showing face morphs} FALSE then begin
        AddMessage('-------Face Morphs-----');
        for i := RACE_LO to RACE_HI do begin
            Log(0, '<' + masterRaceList[i]);
            for j := MALE to FEMALE do begin
                Log(0, '<' + SexToStr(j));
                for k := 0 to raceInfo[i,j].faceBoneList.Count-1 do begin
                    Log(0, Format('%s FMRI=%.8x, scale=[%f, %f]', [
                        raceInfo[i,j].faceBoneList.strings[k],
                        integer(raceInfo[i,j].faceBones[k].FMRI),
                        1.0*raceInfo[i,j].faceBones[k].min.scale,
                        1.0*raceInfo[i,j].faceBones[k].max.scale // Coerce to float
                    ]));
                end;
                Log(0, '>');
            end;
            Log(0, '>');
        end;
    end;

    AddMessage('------Tint Layers--------');
    // Have translations between layer names in the plugin and layers we understand.
    if {Showing tint translations} FALSE then begin
        for i := 0 to knownTTGP.Count-1 do 
            AddMessage(Format('%s == %d/%s', [
                knownTTGP[i], 
                translateTTGP[i],
                tintlayerName[translateTTGP[i]]
            ]));
    end;
    AssertInt(DetermineTintType('Nose Stripe 1'), TL_MUZZLE, 'Have nose stripe');

    // Can select skin tints of the different races.
    if LIST_ALL_TINT_LAYERS then begin
        AddMessage('---Can list the tint layers for all race/sex combos');
        for i := 0 to masterRaceList.Count-1 do 
            for j := SEX_LO to SEX_HI do
                for k := 0 to tintlayerName.Count-1 do
                    for m := 0 to raceInfo[i, j].tintCount[k]-1 do
                        if length(raceInfo[i, j].tints[k, m].name) > 0 then // Assigned(raceInfo[i, j].tints[k, m].element) then
                            AddMessage(Format('%s %s "%s" [%d/%d] "%s" [%s] [%s \ %s]', [
                                masterRaceList[i],
                                SexToStr(j),
                                tintlayerName[k],
                                integer(k),
                                integer(m),
                                raceInfo[i, j].tints[k, m].name,
                                GetElementEditValues(ObjectToElement(raceInfo[i, j].tints[k, m].element), 'Textures\TTET'),
                                EditorID(ContainingMainRecord(ObjectToElement(raceInfo[i, j].tints[k, m].element))),
                                Path(ObjectToElement(raceInfo[i, j].tints[k, m].element))
                            ]));
    end;
    AssertInt(tintlayerName.IndexOf('Skin Tone'), TL_SKIN_TONE, 'Skin tone index correct');
    Assert(SameText(raceInfo[RacenameIndex('FFOHyenaRace'), MALE].tints[TL_SKIN_TONE, 0].name, 'Skin tone'), 
        'Hyena has skin tone ' + raceInfo[RacenameIndex('FFOHyenaRace'), MALE].tints[TL_SKIN_TONE, 0].name);
    Assert(raceInfo[RacenameIndex('FFOFoxRace'), FEMALE].tintCount[TL_MASK] = 3, 
        'Fox Fem has 3 masks: ' + IntToStr(raceInfo[RacenameIndex('FFOFoxRace'), FEMALE].tintCount[TL_MASK]));
    Assert(StartsText('Face Mask', raceInfo[RacenameIndex('FFOFoxRace'), MALE].tints[TL_MASK, 0].name), 
        'Fox has face mask ' + raceInfo[RacenameIndex('FFOFoxRace'), MALE].tints[TL_MASK, 0].name);
    Assert(SameText(raceInfo[RacenameIndex('FFOFoxRace'), MALE].tints[TL_EAR, 0].name, 'Ears'), 
        'Fox has ear ' + raceInfo[RacenameIndex('FFOFoxRace'), MALE].tints[TL_EAR, 0].name);

    // Can find tint presets for the different races.
    elem := PickRandomTintOption('Desdemona', 6684, RacenameIndex('FFOHorseRace'), FEMALE, TL_MUZZLE);
    elem := PickRandomColorPreset('Desdemona', 280, elem, 1, '|FFOFurWhite|');
    Assert(ContainsText(Path(elem), 'Template Color #'), 'Have pathname for tint preset: ' + Path(elem));
    elem := PickRandomColorPreset('Desdemona', 280, elem, 1, '|FFOFurBlack|');
    Assert(not Assigned(elem), 'Have no white tint preset');

    // -----------------------------------------------------------------------------
    //
    //      HEADPARTS
    //
    // Can find headparts for the different races.
    i := masterRaceList.IndexOf('FFOFoxRace');
    AssertInt(raceInfo[i, FEMALE].headparts[HEADPART_FACE].Count, 1, 'Have a head for foxes');
    AssertStr(EditorID(ObjectToElement(raceInfo[i, FEMALE].headparts[HEADPART_FACE].Objects[0])), 'FFOFoxFemHead', 'Have fox head');
    Assert(raceInfo[i, FEMALE].headparts[HEADPART_HAIR].Count > 10, 'Have many hair for foxes: ' + IntToStr(raceInfo[i, FEMALE].headparts[HEADPART_HAIR].Count));

    if {Listing all headparts} FALSE then begin
        Log(0, '<<<All headparts');
        for i := 0 to masterRaceList.Count-1 do begin
            Log(0, '<' + masterRaceList[i]);
            for j := SEX_LO to SEX_HI do begin
                Log(0, '<' + SexToStr(j));
                for k := 0 to headpartsList.Count-1 do begin
                    if Assigned(raceInfo[i, j].headparts[k]) then begin
                        Log(0, '<' + headpartsList[k]);
                            for n := 0 to raceInfo[i, j].headparts[k].Count-1 do begin
                                log(0, EditorID(ObjectToElement(raceInfo[i, j].headparts[k].Objects[n])));
                            end;
                        Log(0, '>');
                    end;
                end;
                Log(0, '>');
            end;
            Log(0, '>');
        end;
        Log(0, '>>>');
    end;
    headpart := FindAsset(Nil, 'HDPT', 'FFO_HairFemale21_Dog');
    Assert(HeadpartValidForRace(headpart, RacenameIndex('FFOLykaiosRace'), FEMALE, HEADPART_HAIR), 
        'Dog female hair works on Lykaios');
    Assert(not HeadpartValidForRace(headpart, RacenameIndex('FFOCheetahRace'), FEMALE, HEADPART_HAIR), 
        'Dog female hair does not work on Cheetah');
    headpart := PickRandomHeadpart('Desdemona', 4219, RacenameIndex('FFOHorseRace'), FEMALE, HEADPART_EYES);
    Assert(ContainsText(EditorID(headpart), 'Ungulate'), 'Found good eyes for Desdemona: ' + EditorID(headpart));

    // --------- Hair
    AddMessage('---------Hair---------');
    Assert(vanillaHairRecords.Count > 50, 
        'Have vanilla hair records: ' + IntToStr(vanillaHairRecords.Count));
    if LIST_HAIR_TRANSLATIONS then begin
        for i := 0 to vanillaHairRecords.Count-1 do begin
            for j := 0 to masterRaceList.Count-1 do begin
                if Assigned(furryHair[i, j]) then
                    AddMessage(Format('[%d] %s == %s (%s)', [
                        integer(i),
                        vanillaHairRecords[i],
                        EditorID(furryHair[i, j]),
                        masterRaceList[j]
                    ]));
            end;
        end;
    end;
    // Can turn vanilla hair into corresponding furry hair.
    race := FindAsset(Nil, 'RACE', 'FFOLykaiosRace');
    headpart := GetFurryHair('FOOBAR', 630, RaceIndex(race), FEMALE, 'HairFemale21');
    AssertStr(EditorID(headpart), 'FFO_HairFemale21_Dog', 'Found canine hair');

    race := FindAsset(Nil, 'RACE', 'FFOFoxRace');
    headpart := GetFurryHair('FOOBAR', 630, RaceIndex(race), FEMALE, 'HairFemale16');
    AssertStr(EditorID(headpart), 'FFO_HairFemale16_FoLy', 'Found canine hair');

    // Can find random hair if there's no vanilla hair.
    headpart := GetFurryHair('FOOBAR', 630, RaceIndex(race), MALE, 'NoHairHere');
    Assert(LeftStr(EditorID(headpart), 4) = 'FFO_', 'Chose random furry hair: ' + EditorID(headpart));

    //-----------------------------------------------------------------------
    //
    //      NPCs
    //
    // --------- Classes

    // Class probabilities are as expected.
    Assert(classProbs[CLASS_MINUTEMEN, lykaiosIndex] > 10, 'Lykaios can be minutemen');
    Assert(classProbs[CLASS_MINUTEMEN, RacenameIndex('FFOLionRace')] > 10, 'Lion can be minutemen');
    n := 0;
    for i := RACE_LO to RACE_HI do n := n + classProbs[CLASS_MINUTEMEN, i];
    AssertInt(classProbs[CLASS_MINUTEMEN, masterRaceList.Count], n, 'Minutemen classProbs has pre-summed value');

    // Classes can be derived from factions, so it's easy to read those.
    fl := TStringList.Create;
    GetNPCFactions(npc, fl);
    for i := 0 to fl.Count-1 do
        AddMessage('Has faction ' + fl[i]);
    fl.Free;
        
    // -------- NPC classes and races
    // Can figure out if NPC is based on a template.
    npc := FindAsset(f, 'NPC_', 'EddieLipkis');
    Assert(NPCInheritsTraits(npc), Format('Expected "%s" inherits traits', [BaseName(npc)]));

    // NPCs are given classes to help with furrification.
    npc := FindAsset(f, 'NPC_', 'BlakeAbernathy');
    NPC_Setup(npc);
    NPC_ChooseRace;
    Assert(curNPC.npcclass = CLASS_SETTLER, 'Expected no specific class for BlakeAbernathy');
    Assert(curNPC.race >= 0, 'Expected to choose a race');
    AddMessage('Race is ' + masterRaceList[npcRace]);

    AddMessage('-Desdemona-');
    npcDesdemona := FindAsset(f, 'NPC_', 'Desdemona');
    Assert(Assigned(npcDesdemona), 'Found Desdemona');
    NPC_Setup(npcDesdemona);
    NPC_ChooseRace;
    Assert(curNPC.npcclass = CLASS_RR, 'Expected RR for Desdemona; have ' + GetNPCClassName(curNPC.npcclass));
    AddMessage('Race is ' + masterRaceList[curNPC.race]);

    AddMessage('-Cabots-');
    npc := FindAsset(f, 'NPC_', 'LorenzoCabot');
    Assert(Assigned(npc), 'Expected to find LorenzoCabot');
    NPC_Setup(npc);
    NPC_ChooseRace;
    Assert(SameText(curNPC.id, 'LorenzoCabot'), 'Expected to find LorenzoCabot');
    AddMessage('Name = ' + curNPC.name);
    Assert(curNPC.npcclass = CLASS_CABOT, 'Expected CLASS_CABOT for LorenzoCabot; have ' + GetNPCClassName(curNPC.npcclass));
    AddMessage('Race is ' + masterRaceList[curNPC.race]);

    AddMessage('-Children of Atom-');
    npc := FindAsset(f, 'NPC_', 'EncChildrenOfAtom01Template');
    Assert(npc <> Nil, 'Found EncChildrenOfAtom01Template');
    NPC_Setup(npc);
    NPC_ChooseRace;
    Assert(curNPC.npcclass = CLASS_ATOM, 'Expected CLASS_ATOM for EncChildrenOfAtom01Template; have ' + GetNPCClassName(curNPC.npcclass));
    AddMessage('Race is ' + masterRaceList[curNPC.race]);

    AddMessage('-Pack-');
    // Mason's race is forced to Horse
    npc := FindAsset(Nil, 'NPC_', 'DLC04_encGangPackFaceF01');
    Assert(npc <> Nil, 'Found DLC04_encGangPackFaceF01');
    NPC_Setup(npc);
    NPC_ChooseRace;
    Assert(curNPC.npcclass = CLASS_PACK, 'Expected CLASS_PACK for DLC04_encGangPackFaceF01; have ' + GetNPCClassName(curNPC.npcclass));

    // -------- Specific NPC race assignment
    // Can create overwrite records.

    // Currently not handling template NPCs differently.
    // AddMessage('---EncMinutemen05');
    // npc := WinningOverride(FindAsset(Nil, 'NPC_', 'EncMinutemen05'));
    // AddMessage(Format('Found %s/%s', [FullPath(npc), Name(npc)]));
    // AssertInt(IsValidNPC(npc), 2, FullPath(npc) + ' identified as template');

    // Shaun and player spouse get furrified following the player.
    LOGLEVEL := 10;
    AddMessage('---Shaun');
    AssignNPCRace('Player', 'FFOCheetahRace');
    npc := FindAsset(Nil, 'NPC_', 'Player');
    furryNPC := MakeFurryNPC(npc, modFile);

    npc := FindAsset(Nil, 'NPC_', 'Shaun');
    furryNPC := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(furryNPC)), 'FFOCheetahRace', 'Shaun has correct race');

    npc := FindAsset(Nil, 'NPC_', 'MQ101PlayerSpouseFemale');
    furryNPC := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(furryNPC)), 'FFOCheetahRace', 'Female spouse has correct race');
    
    // When Ann's hair must be converted to furry hair.
    AddMessage('---AnnCodman');
    AssignNPCRace('AnnCodman', 'FFOFoxRace');
    npc := FindAsset(Nil, 'NPC_', 'AnnCodman');
    furryNPC := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(furryNPC)), 'FFOFoxRace', 'Have fox race');
    AssertGoodHeadparts(furryNPC, 'Hair', 'FFO_HairFemale16_FoLy');

    AddMessage('---Danse');
    npc := FindAsset(Nil, 'NPC_', 'BoSPaladinDanse');
    furryNPC := MakeFurryNPC(npc, modFile);
    Assert(EditorID(LinksTo(ElementByPath(furryNPC, 'RNAM'))) = 'FFOLykaiosRace', 
        'Changed Danse`s race');
    elist := ElementByPath(furryNPC, 'Head Parts');
    Assert(ElementCount(elist) >= 3, 'Have head parts');
    Assert(GetFileName(LinksTo(ElementByIndex(elist, 0))) = 'FurryFallout.esp', 
        'Have head parts from FFO');
    Assert(GetFileName(LinksTo(ElementByPath(furryNPC, 'WNAM'))) = 'FurryFallout.esp', 
        'Have skin from FFO');
    AssertGoodTintLayersNeg(furryNPC, 2703); // Does NOT have mask

    AddMessage('---Mason');
    npc := FindAsset(Nil, 'NPC_', 'DLC04Mason');
    if not Assigned(npc) then 
        AddMessage('DLCs not loaded')
    else begin
        npcMason := MakeFurryNPC(npc, modFile);
        Assert(EditorID(LinksTo(ElementByPath(npcMason, 'RNAM'))) = 'FFOHorseRace', 
            'Changed Mason`s race');
        elist := ElementByPath(npcMason, 'Head Parts');
        Assert(ElementCount(elist) >= 3, 'Have head parts');
        Assert(GetFileName(LinksTo(ElementByIndex(elist, 0))) = 'FurryFallout.esp', 
            'Have head parts from FFO');
        Assert(GetFileName(LinksTo(ElementByPath(npcMason, 'WNAM'))) = 'FurryFallout.esp', 
            'Have skin from FFO');
        AssertGoodTintLayers(npcMason, 1156);
    end;

    AddMessage('---Cait');
    npc := FindAsset(Nil, 'NPC_', 'CompanionCait');
    modFile := CreateOverrideMod('TEST.esp');
    npc := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(npc)), 'FFOFoxRace', 'Changed Cait`s race');
    AssertGoodHeadparts(npc, 'Face', 'FFOFoxFemHead');
    AssertGoodHeadparts(npc, 'Hair', 'FFO_HairFemale23_Dog');
    AssertStr(GetFileName(LinksTo(ElementByPath(npc, 'WNAM'))), 'FurryFallout.esp', 'Have skin from FFO');
    AssertGoodTintLayers(npc, 2701);

    AddMessage('---Nat');
    npc := WinningOverride(FindAsset(Nil, 'NPC_', 'Natalie'));
    AssertInt(IsValidNPC(npc), 1, 'Nat is valid');
    modFile := CreateOverrideMod('TEST.esp');
    npc := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(npc)), 'FFODeerChildRace', 'Changed Nat`s race');
    AssertGoodTintLayers(npc, 1168);

    AddMessage('---Cathy and John');
    npc := FindAsset(Nil, 'NPC_', 'Cathy');
    npcCathy := MakeFurryNPC(npc, modFile);
    npc := FindAsset(Nil, 'NPC_', 'John');
    npcJohn := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(npcCathy)), EditorID(GetNPCRace(npcJohn)), 
        'Cathy and John races match');

    AddMessage('---Preston');
    npc := FindAsset(Nil, 'NPC_', 'PrestonGarvey');
    npc := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(npc)), 'FFOLionRace', 'Changed Preston`s race');
    AssertGoodHeadparts(npc, 'Hair', 'FFO_HairMaleMane');

    // Testing a whitetail--should have no 0-alpha tints.
    AddMessage('---StanSlavin');
    npc := FindAsset(Nil, 'NPC_', 'StanSlavin');
    npc := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(npc)), 'FFODeerRace', 'Changed Stan Slavin`s race');
    AssertNoZeroTints(npc);

    // Set race and headparts by hand. 
    AddMessage('---BoS301BrotherHenri');
    npc := FindAsset(Nil, 'NPC_', 'BoS301BrotherHenri');
    NPC_Setup(npc);
    NPC_ChooseRace;
    curNPC.handle := CreateNPCOverride(npc, modFile);
    NPC_SetRace(RACE_DEER);
    NPC_ChooseHair;
    NPC_ChooseHeadpart(HEADPART_FACE);
    NPC_ChooseHeadpart(HEADPART_EYES);
    NPC_MakeDeerReindeer;
    AssertStr(EditorID(GetNPCRace(curNPC.handle)), 'FFODeerRace', 'Changed BoS301BrotherHenri`s race');
    AssertGoodHeadparts(curNPC.handle, 'Eyebrows', 'FFODeerHorns05');
    AssertMorph(curNPC.handle, $36EF36E0);
    
    // Old NPC has "old" tint layer. 
    AddMessage('---OldManStockton');
    // Must be the right race for the tint layer check to work.
    AssignNPCRace('OldManStockton', 'FFOLionRace');
    npc := FindAsset(Nil, 'NPC_', 'OldManStockton');
    furryNPC := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(furryNPC)), 'FFOLionRace', 'Stockton is lion');
    AssertGoodTintLayers(furryNPC, 2657); // Old

    //-----------------------------------------------------------------------
    //
    //      Ghouls
    //
    // --------- 
    AddMessage('---Ghouls---');
    race := WinningOverride(FindAsset(FileByIndex(0), 'RACE', 'GhoulRace'));
    AssertStr(GetFileName(GetFile(race)), GetFileName(modFile), 'Ghouls overridden in mod file');
    AssertInt(ElementCount(ElementByPath(race, 'Male Head Parts')), 3, 'Ghouls have 3 head parts');

    AddMessage('---Hancock');
    npc := FindAsset(Nil, 'NPC_', 'Hancock');
    npc := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(npc)), 'GhoulRace', 'Did not change Hancock`s race');
    AssertGoodTintLayers(npc, 1156);

    AddMessage('---Billy');
    npc := FindAsset(Nil, 'NPC_', 'Billy');
    npc := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(npc)), 'GhoulChildRace', 'Did not change Billy`s race');
    AssertGoodTintLayers(npc, 1156);

    // Leveled ghoul character gets furrified.
    AddMessage('---LvlTriggermanUnaggressiveMeleeGhoulOnly');
    npc := FindAsset(Nil, 'NPC_', 'LvlTriggermanUnaggressiveMeleeGhoulOnly');
    AddMessage('MakeFurry: ' + FullPath(npc));
    npc := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(LinksTo(ElementByPath(npc, 'RNAM'))), 
        'GhoulRace', 
        'Did not change LvlTriggermanUnaggressiveMeleeGhoulOnly`s race');
    AssertGoodTintLayers(npc, 1156);

    // --------- Race distribution (with humans)
    Assert(classProbs[CLASS_RAIDER, masterRaceList.Count] > 0, 
        Format('classProbs has pre-summed value: %d', [classProbs[CLASS_RAIDER, masterRaceList.Count]]));
    
    // Log(0, '<Race distribution for raiders is reasonable');
    // SetClassProb(CLASS_RAIDER, 'HumanRace', 300);
    // CalcClassTotals();
    // sl1 := TStringList.create;
    // sl1.Duplicates := false;
    // sl1.Sorted := true;
    // for i := 1 to 9 do begin
    //     npc := FindAsset(f, 'NPC_', 'EncRaiderFaceM0' + IntToStr(i));
    //     Log(0, Format('Minuteman has class: %s : %s', [EditorID(npc), GetNPCClassName(GetNPCClass(npc))]));
    //     if not Assigned(npc) then break;
    //     npcRaceList[i] := ChooseNPCRace(npc);
    //     sl1.Add(masterRaceList[npcRaceList[i]]);
    //     Log(0, Format('Race for %s (%s) is %s', [
    //         EditorID(npc), GetNPCClassName(GetNPCClass(npc)), masterRaceList[npcRaceList[i]]]));
    // end;
    // Log(0, '>');
    // Assert(ContainsText(sl1.CommaText, 'Human'), 
    //     'Humans assigned as raiders: ' + sl1.CommaText);
    // sl1.Free;

    // Log(0, '<Race distribution for settlers is reasonable');
    // sl1 := TStringList.create;
    // sl1.Duplicates := false;
    // sl1.Sorted := true;
    // for i := 1 to 6 do begin
    //     npc := FindAsset(f, 'NPC_', 'EncMinutemenFaceM0' + IntToStr(i));
    //     Log(0, Format('Minuteman has class: %s : %s', [EditorID(npc), GetNPCClassName(GetNPCClass(npc))]));
    //     if not Assigned(npc) then break;
    //     npcRaceList[i] := ChooseNPCRace(npc);
    //     sl1.Add(masterRaceList[npcRaceList[i]]);
    //     Log(0, Format('Race for %s (%s) is %s', [
    //         EditorID(npc), GetNPCClassName(GetNPCClass(npc)), masterRaceList[npcRaceList[i]]]));
    // end;
    // Log(0, '>');
    // Assert(sl1.count > 2, Format('Have range of races for settlers: %s', [sl1.CommaText]));
    // sl1.free;

    if LIST_RACE_DISTRIBUTION then begin
        // Walk through the NPCs and collect stats on how many of each race there are
        // to make sure the random assignment is giving a range of races.
        AddMessage('---Race Distribution---');
        for k := 0 to FileCount-1 do begin
            f := FileByIndex(k);
            npcGroup := GroupBySignature(f, 'NPC_');
            for i := 0 to ElementCount(npcGroup)-1 do begin
                npc := ElementByIndex(npcGroup, i);
                if StartsText('HumanRace', GetElementEditValues(npc, 'RNAM')) then begin
                    NPC_Setup(npc);
                    NPC_ChooseRace;
                    // Log(1, Format('Found %s / %s', [GetNPCClassName(curNPC.npcclass), RaceIDToStr(curNPC.race)]));
                    if curNPC.race < 100 then
                        classCounts[curNPC.npcclass, curNPC.race] 
                            := classCounts[curNPC.npcclass, curNPC.race] + 1;
                end;
            end;
        end;

        AddMessage('Check that we have a reasonable distribution of races');
        for i := CLASS_LO to CLASS_HI do begin
            AddMessage('-');
            for j := RACE_LO to RACE_HI do begin
                if classCounts[i, j] > 0 then 
                    AddMessage(GetNPCClassName(i) + ' ' + masterRaceList[j] + ' = ' + IntToStr(classCounts[i, j]));
            end;
        end;
    end;
end;

Procedure TestNPCGeneration;
var 
    i, j: integer;
    npc, newNPC: IwbMainRecord;
begin
    //-----------------------------------------------------------------------
    //
    //      NPC Generation
    //
    // --------- 
    InitializeNPCGenerator(modFile);
    if {showing all leveled lists} TRUE then begin
        AddMessage('---Leveled lists---');
        for i := CLASS_LO to CLASS_HI do
            for j := MALE to FEMALE do
                if Assigned(leveledList[i, j]) then
                    AddMessage(Format('leveledList %s %s -- %s', [GetNPCClassName(i), SexToStr(j), EditorID(leveledList[i, j])]));
    end;

    AddMessage('---Can generate NPCs');
    // npc := MakeFurryNPC(FindAsset(Nil, 'NPC_', 'EncGunner00'), modFile);
    npc := SetGenericTraits(modFile, FindAsset(nil, 'NPC_', 'EncGunner00'));
    AssertStr(Signature(NPCTraitsTemplate(npc)), 'LVLN', 'EncGunner00 Traits set to leveled list');

    npc := SetGenericTraits(modFile, FindAsset(nil, 'NPC_', 'DLC03EncTrapper02'));
    AssertStr(Signature(NPCTraitsTemplate(npc)), 'LVLN', 'DLC03EncTrapper02 Traits set to leveled list');
    AssertStr(EditorID(NPCTraitsTemplate(npc)), 'DLC03_LCharTrapperFace', 'DLC03EncTrapper02 Traits set to leveled list');

    npc := FindAsset(nil, 'NPC_', 'MQ102PlayerSpouseCorpseFemale');
    newNPC := SetGenericTraits(modFile, npc);
    AssertStr(EditorID(NPCTraitsTemplate(newNPC)), 'MQ101PlayerSpouseFemale', 
        Format('%s traits come from MQ101PlayerSpouseFemale', [Name(newNPC)]));

    ShutdownNPCGenerator;
end;

Function Finalize: integer;
begin
    AddMessage('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    Log(0, 'Starting tests');
    testErrorCount := 0;

    modFile := CreateOverrideMod('TEST.esp');

    LIST_ALL_TINT_LAYERS := FALSE;
    LIST_HAIR_TRANSLATIONS := FALSE;
    LIST_RACE_DISTRIBUTION := FALSE;

    // Asset loader has to be iniitialized before use.
    convertingGhouls := true;
    InitializeFurrifier(modFile);

    ShowClassProbabilities;

    // TestSystemFunc;
    // TestHashing;
    // TestFFOFurrifier;
    // TestNPCGeneration;
    // TestFurryArmorFixup;

    //------------------------------------------------------------------------

    ShutdownAssetLoader;

    AddMessage(Format('Tests completed with %d error%s', [integer(errCount), IfThen(errCount=1, '', 's')]));
    AddMessage(IfThen(errCount = 0, 
        '++++++++++++SUCCESS++++++++++',
        '-------------FAIL----------'));
end;
end.
