{
	Hotkey: Ctrl+Alt+T
}
unit TEST_BDAssetLoaderFO4;

interface
implementation
uses FFO_Furrifier, BDAssetLoaderFO4, xEditAPI, Classes, SysUtils, StrUtils, Windows;

var
    testErrorCount: integer;

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

procedure AssertStr(actual, expected: string; msg: string);
begin
    Assert(actual = expected, Format(msg + ': "%s" = "%s"', [actual, expected]));
end;

Function Initialize: integer;
begin
  
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

//-------------------------------------------------------------------------
// Test the furrifier
function Finalize: integer;
var
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
    i: integer;
    j: integer;
    k: integer;
    lykaiosIndex: integer;
    lykaiosRace: IwbMainRecord;
    m: integer;
    modFile: IwbFile;
    n: integer;
    name: string;
    npc: IwbMainRecord;
    npcCathy: IwbMainRecord;
    npcJohn: IwbMainRecord;
    npcClass: integer;
    npcDesdemona: IwbMainRecord;
    npcGroup: IwbGroupRecord;
    npcMason: IwbMainRecord;
    npcPiper: IwbMainRecord;
    npcHancock: IwbMainRecord;
    npcRace: integer;
    race: IwbMainRecord;
    raceID: Cardinal;
    racename: string;
    racepnam: float;
    teti: string;
    tend: float;
begin
    LOGLEVEL := 5;
    f := FileByIndex(0);

    // Asset loader has to be iniitialized before use.
    AddMessage('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    Log(10, 'Starting tests');
    testErrorCount := 0;

    AddMessage(Format('Can format hex values: %.8x', [1023]));
    AddMessage(Format('Can format float values: %f', [10.23]));

    if {Testing random numbers} FALSE then begin
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
    end;

    InitializeFurrifier;

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

    AddMessage('---Can iterate through the masterRaceList');
    for i := 0 to masterRaceList.Count-1 do 
        for j := 0 to 3 do 
            AddMessage(Format('[%d %d %s] %s', [
                i, j, masterRaceList[i], EditorID(raceInfo[i, j].mainRecord)]));

    AddMessage('---Can iterate through childRaceList');
    for i := 0 to masterRaceList.Count-1 do
        AddMessage(masterRaceList[i] + ' / ' + childRaceList[i]);

    // ---------- Child Races
    AssertStr(EditorID(raceInfo[lykaiosIndex, MALECHILD].mainRecord), 'FFOLykaiosChildRace',
        'Found child race for Lykaios');
    Assert(childRaceList.IndexOf('FFOLykaiosChildRace') >= 0, 'Have lykaios child race');

    // ---------- Race Assets
    for i := 0 to masterRaceList.Count-1 do 
        AddMessage('[' + IntToStr(i) + '] ' + masterRaceList[i]);

    AddMessage('---Can iterate through the tint list');
    for i := 0 to tintlayerName.Count-1 do
        AddMessage(Format('[%d] %s', [i, tintlayerName[i]]));

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

    If {showing all morphs} TRUE then begin
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

    // Can access particular morphs
    elem := GetMorphPreset(
        ObjectToElement(raceInfo[RACE_DEER, MALE].morphGroups.objects[
            raceInfo[RACE_DEER, MALE].morphGroups.IndexOf('Nostrils')
            ]), 
        'Broad');
    AssertStr(GetElementEditValues(elem, 'MPPN'), 'Broad', 'Can read the morph presets');

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
    if {List all tint layers} FALSE then begin
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
    elem := PickRandomColorPreset('Desdemona', 280, elem, 1);
    Assert(ContainsText(Path(elem), 'Template Color #'), 'Have pathname for tint preset: ' + Path(elem));

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
        'Have hair records: ' + IntToStr(vanillaHairRecords.Count));
    if {are list all hair translations} FALSE then begin
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
    // Can turn vanilla hair into corresponding furry hair
    race := FindAsset(Nil, 'RACE', 'FFOLykaiosRace');
    headpart := GetFurryHair(RaceIndex(race), 'HairFemale21');
    AssertStr(EditorID(headpart), 'FFO_HairFemale21_Dog', 'Found canine hair');

    //-----------------------------------------------------------------------
    //
    //      NPCs
    //
    // --------- Classes
    // Class probabilities are as expected.
    Assert(classProbs[CLASS_MINUTEMEN, lykaiosIndex] > 10, 'Lykaios can be minutemen');

    // Classes can be derived from factions, so it's easy to read those.
    fl := TStringList.Create;
    GetNPCFactions(npc, fl);
    for i := 0 to fl.Count-1 do
        AddMessage('Has faction ' + fl[i]);
    fl.Free;
    
    // -------- NPC classes and races
    // NPCs are given classes to help with furrification.
    npc := FindAsset(f, 'NPC_', 'BlakeAbernathy');
    npcClass := GetNPCClass(npc);
    Assert(npcClass = NONE, 'Expected no specific class for BlakeAbernathy');
    npcRace := ChooseNPCRace(npc);
    Assert(npcRace >= 0, 'Expected to choose a race');
    AddMessage('Race is ' + masterRaceList[npcRace]);

    AddMessage('-Desdemona-');
    npcDesdemona := FindAsset(f, 'NPC_', 'Desdemona');
    Assert(Assigned(npcDesdemona), 'Found Desdemona');
    npcClass := GetNPCClass(npcDesdemona);
    Assert(npcClass = CLASS_RR, 'Expected RR for Desdemona; have ' + IntToStr(npcClass));
    npcRace := ChooseNPCRace(npcDesdemona);
    AddMessage('Race is ' + masterRaceList[npcRace]);

    AddMessage('-Cabots-');
    npc := FindAsset(f, 'NPC_', 'LorenzoCabot');
    Assert(Assigned(npc), 'Expected to find LorenzoCabot');
    Assert(SameText(EditorID(npc), 'LorenzoCabot'), 'Expected to find LorenzoCabot');
    name := GetElementEditValues(npc, 'FULL');
    AddMessage('Name = ' + name);
    npcClass := GetNPCClass(npc);
    Assert(npcClass = CLASS_CABOT, 'Expected CLASS_CABOT for LorenzoCabot; have ' + IntToStr(npcClass));
    npcRace := ChooseNPCRace(npc);
    AddMessage('Race is ' + masterRaceList[npcRace]);

    AddMessage('-Children of Atom-');
    npc := FindAsset(f, 'NPC_', 'EncChildrenOfAtom01Template');
    Assert(npc <> Nil, 'Found EncChildrenOfAtom01Template');
    npcClass := GetNPCClass(npc);
    Assert(npcClass = CLASS_ATOM, 'Expected CLASS_ATOM for EncChildrenOfAtom01Template; have ' + IntToStr(npcClass));
    npcRace := ChooseNPCRace(npc);
    AddMessage('Race is ' + masterRaceList[npcRace]);

    AddMessage('-Pack-');
    // Mason's race is forced to Horse
    npcMason := FindAsset(Nil, 'NPC_', 'DLC04Mason');
    Assert(npcMason <> Nil, 'Found DLC04Mason');
    npcClass := GetNPCClass(npcMason);
    Assert(npcClass = CLASS_PACK, 'Expected CLASS_PACK for DLC04Mason; have ' + IntToStr(npcClass));
    npcRace := ChooseNPCRace(npcMason);
    Assert(SameText(masterRaceList[npcRace], 'FFOHorseRace'), 'Mason given horse race.');

    // -------- NPC race assignment
    // Can create overwrite records.
    AddMessage('---Mason');
    npc := FindAsset(Nil, 'NPC_', 'DLC04Mason');
    modFile := CreateOverrideMod('TEST.esp');
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

    AddMessage('---Hancock');
    npc := FindAsset(Nil, 'NPC_', 'Hancock');
    npc := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(npc)), 'FFOSnekdogRace', 'Changed Hancock`s race');
    AssertGoodTintLayers(npc, 1156);

    AddMessage('---Billy');
    npc := FindAsset(Nil, 'NPC_', 'Billy');
    npc := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(npc)), 'FFOSnekdogChildRace', 'Changed Billy`s race');
    AssertGoodTintLayers(npc, 1156);

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

    AddMessage('---BoS301BrotherHenri');
    npc := FindAsset(Nil, 'NPC_', 'BoS301BrotherHenri');
    furryNPC := CreateNPCOverride(npc, modFile);
    hair := SetNPCRace(furryNPC, RACE_DEER);
    ChooseHair(furryNPC, hair);
    ChooseHeadpart(furryNPC, HEADPART_EYES);
    ChooseHeadpart(furryNPC, HEADPART_FACE);
    MakeDeerReindeer(furryNPC);
    AssertStr(EditorID(GetNPCRace(furryNPC)), 'FFODeerRace', 'Changed BoS301BrotherHenri`s race');
    AssertGoodHeadparts(furryNPC, 'Eyebrows', 'FFODeerHorns05');
    AssertMorph(furryNPC, $36EF36E0);
    

    // --------- Race distribution 
    if {Testing race distribution} FALSE then begin
        // Walk through the NPCs and collect stats on how many of each race there are
        // to make sure the random assignment is giving a range of races.
        AddMessage('---Race Probabilities---');
        for k := 0 to FileCount-1 do begin
            f := FileByIndex(k);
            npcGroup := GroupBySignature(f, 'NPC_');
            for i := 0 to ElementCount(npcGroup)-1 do begin
                npc := ElementByIndex(npcGroup, i);
                if StartsText('HumanRace', GetElementEditValues(npc, 'RNAM')) then begin
                    npcClass := GetNPCClass(npc);
                    raceID := ChooseNPCRace(npc);
                    classCounts[npcClass, raceID] := classCounts[npcClass, raceID] + 1;
                end;
            end;
        end;

        AddMessage('Check that we have a reasonable distribution of races');
        for i := CLASS_LO to CLASS_HI do begin
            AddMessage('-');
            for j := 0 to masterRaceList.Count-1 do begin
                if classCounts[i, j] > 0 then 
                    AddMessage(GetClassName(i) + ' ' + masterRaceList[j] + ' = ' + IntToStr(classCounts[i, j]));
            end;
        end;
    end;

    AddMessage(Format('Tests completed with %d errors', [testErrorCount]));
    AddMessage(IfThen(testErrorCount = 0, 
        '++++++++++++SUCCESS++++++++++',
        '-------------FAIL----------'));
    ShutdownAssetLoader;
end;

end.
