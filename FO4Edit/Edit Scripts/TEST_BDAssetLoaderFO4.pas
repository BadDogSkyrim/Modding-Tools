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

//-------------------------------------------------------------------------
// Test the furrifier
function Finalize: integer;
var
    classCounts: array[0..40 {CLASS_COUNT}, 0..50 {MAX_RACES}] of integer;
    elem: IwbElement;
    elist: IwbContainer;
    f: IwbFile;
    fl: TStringList;
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
    npcClass: integer;
    npcDesdemona: IwbMainRecord;
    npcGroup: IwbGroupRecord;
    npcMason: IwbMainRecord;
    npcPiper: IwbMainRecord;
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

    // ---------- NPC info
    AddMessage('---Can find particular NPCs');
    npc := FindAsset(FileByIndex(0), 'NPC_', 'Desdemona');
    Assert(EditorID(GetNPCRace(npc)) = 'HumanRace', 
        Format('Have human race for Desdemona: "%s"', [EditorID(GetNPCRace(npc))]));
    npc := FindAsset(FileByIndex(0), 'NPC_', 'RECheckpoint_LvlGunnerSniper');
    Assert(EditorID(GetNPCRace(npc)) = 'HumanRace', 
        Format('Have human race for gunner: "%s"', [EditorID(GetNPCRace(npc))]));

    InitializeFurrifier;

    // ----------- masterRaceList
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
                for k := MALE to FEMALE do
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
                            AddMessage(Format('%s %s%s "%s" [%d/%d] "%s" [%s]', [
                                masterRaceList[i],
                                IfThen((j and 1) == 0, 'M', 'F'),
                                IfThen((j and 2) == 0, ' ', 'C'),
                                tintlayerName[k],
                                integer(k),
                                integer(m),
                                raceInfo[i, j].tints[k, m].name,
                                GetElementEditValues(ObjectToElement(raceInfo[i, j].tints[k, m].element), 'Textures\TTET')
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
    LOGLEVEL := 14;
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

    AddMessage('---Cait');
    npc := FindAsset(Nil, 'NPC_', 'CompanionCait');
    modFile := CreateOverrideMod('TEST.esp');
    npcPiper := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(npcPiper)), 'FFOFoxRace', 'Changed Cait`s race');
    elist := ElementByPath(npcPiper, 'Head Parts');
    Assert(ElementCount(elist) >= 3, 'Have head parts');
    Assert(GetFileName(LinksTo(ElementByIndex(elist, 0))) = 'FurryFallout.esp', 
        'Have head parts from FFO');
    Assert(GetFileName(LinksTo(ElementByPath(npcPiper, 'WNAM'))) = 'FurryFallout.esp', 
        'Have skin from FFO');
    elist := ElementByPath(npcPiper, 'Face Tinting Layers');
    teti := 0;
    for i := 0 to ElementCount(elist)-1 do begin
        teti := GetElementEditValues(ElementByIndex(elist, i), 'TETI\Index');
        AddMessage('Found TETI ' + teti);
        if teti = '2701' then begin
            tend := GetElementNativeValues(ElementByIndex(elist, i), 'TEND\Value');
            Assert(tend > 0.1, 'Cait`s face mask is visible: ' + FloatToStr(tend));
            break;
        end;
    end;
    Assert(teti = '2701', 'Found a face mask for Cait.');
    hair := Nil;
    elist := ElementByPath(npcPiper, 'Head Parts');
    for i := 0 to ElementCount(elist)-1 do begin
        headpart := LinksTo(ElementByIndex(elist, i));
        if GetElementEditValues(headpart, 'PNAM') = 'Hair' then
            hair := headpart;
    end;
    AssertStr(EditorID(hair), 'FFO_HairFemale23_Dog', 'Have correct hair for Cait');

    AddMessage('---Nat');
    npc := FindAsset(Nil, 'NPC_', 'Natalie');
    modFile := CreateOverrideMod('TEST.esp');
    npcPiper := MakeFurryNPC(npc, modFile);
    AssertStr(EditorID(GetNPCRace(npcPiper)), 'FFODeerChildRace', 'Changed Natalie`s race');

    // --------- Race distribution 
    if {Testing race distribution} false then begin
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
        for i := 0 to CLASS_COUNT-1 do begin
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
