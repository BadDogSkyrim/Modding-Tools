{
  NPC Furry Patch Builder
  Author: Bad Dog 
  
  Creates a NPC furry patch for a load order.

  By default, all NPCs are changed to furry races, children included. Ghouls are changed to 
  Nightstalkers. 

  Script allows customization of race assignments and what NPCs to affect.

  Documentation: https://github.com/BadDogSkyrim/Modding-Tools/wiki

	Hotkey: Ctrl+Alt+D

}

unit FFO_Furrifier;

interface

implementation

uses FFO_RaceProbabilities, BDFurryArmorFixup, FFOGenerateNPCs, BDScriptTools,
BDAssetLoaderFO4, xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    patchfileName = 'FFOPatch.esp'; // Set to whatever
    USE_SELECTION = FALSE;           // FALSE or TRUE
    TARGET_RACE = '';    // Use this race for everything

    // Ghouls. All ghouls have to be the same race (because they're one separate race in
    // vanilla, also headgear has to be altered to fit them).
    GHOUL_RACE = 'FFOSnekdogRace';
    GHOUL_CHILD_RACE = 'FFOSnekdogChildRace';

    SHOW_RACE_DISTRIBUTION = TRUE; // Show me what it did
    DO_FURRIFICATION = TRUE;

var
    patchFile: IwbFile;

    ffoFile: IwbFile;

    playerIDs: TStringList;
    furrifiedNPCs: TStringList;
    furryCount: integer;
    preFurryCount: integer;
    startTime: TDateTime;

    classCounts: array[0..40 {CLASS_COUNT}, 0..50 {MAX_RACES}] of integer;

//==================================================================================
// Do any special tailoring for specific races.
Procedure SetTintLayerTranslations(); 
begin
    InitializeTintLayers;

    // What the parts of the face are called in different races
    SkinLayerTranslation('Blaze Narrow', TL_MUZZLE);
    SkinLayerTranslation('Blaze Wide', TL_MUZZLE);
    SkinLayerTranslation('Cap', TL_FOREHEAD);
    SkinLayerTranslation('Cheek Color Lower', TL_CHEEK_COLOR_LOWER);
    SkinLayerTranslation('Cheek Color', TL_CHEEK_COLOR);
    SkinLayerTranslation('Cheeks', TL_CHEEK_COLOR);
    SkinLayerTranslation('Chin', TL_CHIN);
    SkinLayerTranslation('Ears', TL_EAR);
    SkinLayerTranslation('Eye Lower', TL_EYESOCKET_LOWER);
    SkinLayerTranslation('Eye Shadow', TL_EYELINER);
    SkinLayerTranslation('Eye Socket', TL_EYELINER);
    SkinLayerTranslation('Eye Socket Upper', TL_EYESOCKET_UPPER);
    SkinLayerTranslation('Eye Stripe', TL_Mask);
    SkinLayerTranslation('Eye Tear', TL_MASK); // Snekdogs
    SkinLayerTranslation('Eye Upper', TL_EYESOCKET_UPPER);
    SkinLayerTranslation('Eyebrow Spot', TL_EYEBROW);
    SkinLayerTranslation('Eyebrow', TL_EYEBROW);
    SkinLayerTranslation('Eyeliner', TL_EYELINER);
    SkinLayerTranslation('Face Mask 1', TL_MASK);
    SkinLayerTranslation('Face Mask 2', TL_MASK);
    SkinLayerTranslation('Face Mask 3', TL_MASK);
    SkinLayerTranslation('Face Mask 4', TL_MASK);
    SkinLayerTranslation('Face Plate', TL_MASK);
    SkinLayerTranslation('Forehead', TL_FOREHEAD);
    SkinLayerTranslation('Head Scales', TL_FOREHEAD);
    SkinLayerTranslation('Lips', TL_LIP_COLOR);
    SkinLayerTranslation('Lower Jaw', TL_CHIN);
    SkinLayerTranslation('Mask', TL_Mask);
    SkinLayerTranslation('Mouche', TL_CHIN);
    SkinLayerTranslation('Muzzle Stripe', TL_MUZZLE_STRIPE); 
    SkinLayerTranslation('Muzzle Upper', TL_MUZZLE); 
    SkinLayerTranslation('Muzzle', TL_MUZZLE);
    SkinLayerTranslation('Nose Stripe 1', TL_MUZZLE_STRIPE); // Fox
    SkinLayerTranslation('Nose Stripe 2', TL_MUZZLE_STRIPE); // Fox
    SkinLayerTranslation('Nose Stripe', TL_MUZZLE_STRIPE); 
    SkinLayerTranslation('Nose', TL_NOSE);
    SkinLayerTranslation('Old', TL_OLD);
    SkinLayerTranslation('Skin tone', TL_SKIN_TONE);
    SkinLayerTranslation('Star', TL_FOREHEAD);
    SkinLayerTranslation('Upper Head', TL_FOREHEAD);
    SkinLayerTranslation('Scar - Left Long', TL_PAINT);
    SkinLayerTranslation('Fishbones', TL_PAINT);
    SkinLayerTranslation('Skull', TL_PAINT);
	//SHARK
	SkinLayerTranslation('Snout Smear', TL_PAINT);
	SkinLayerTranslation('Eye Stripes', TL_EYELINER);
	SkinLayerTranslation('Mouth Smear', TL_MUZZLE);
	SkinLayerTranslation('Cheek Dots', TL_PAINT);
	SkinLayerTranslation('Eye Brush', TL_EYELINER);
	SkinLayerTranslation('Eye Goggles', TL_EYELINER);
	SkinLayerTranslation('Eye Smear', TL_EYELINER);
	SkinLayerTranslation('Face Stripe', TL_EYELINER);
	SkinLayerTranslation('Face Top', TL_PAINT);
	SkinLayerTranslation('Eye Socket Soft', TL_EYELINER);
    SkinLayerTranslation('Freckles', TL_MUZZLE_STRIPE);
	SkinLayerTranslation('Eye Bar Code', TL_EYELINER);
	SkinLayerTranslation('Face Stripes', TL_PAINT);
	SkinLayerTranslation('Lower Eye Dots', TL_EYELINER);
	SkinLayerTranslation('Neck Stripes', TL_CHIN);
	SkinLayerTranslation('Nose Tip Shade', TL_NOSE);
	SkinLayerTranslation('Eye Drip', TL_EYELINER);
	SkinLayerTranslation('Eyeliner (Thick)', TL_EYELINER);
	SkinLayerTranslation('Eyeliner (Thin)', TL_EYELINER);
	SkinLayerTranslation('Eye of Selachis', TL_EYELINER);
	SkinLayerTranslation('Facial Freckles', TL_FOREHEAD);
	SkinLayerTranslation('Lateral Slice', TL_PAINT);
	SkinLayerTranslation('Mark of the Abyss', TL_PAINT);
	SkinLayerTranslation('Raider 1 (Layer #1)', TL_MASK);
	SkinLayerTranslation('Raider 1 (Layer #2)', TL_PAINT);
	SkinLayerTranslation('Raider 2 (Layer #1)', TL_MASK);
	SkinLayerTranslation('Raider 2 (Layer #2)', TL_PAINT);
	SkinLayerTranslation('Raider 3', TL_MASK);
	SkinLayerTranslation('Slugger', TL_PAINT);
	SkinLayerTranslation('Stripes', TL_PAINT);
	SkinLayerTranslation('Void Taint', TL_PAINT);
	//K9
	SkinLayerTranslation('Muzzle Scar', TL_PAINT);
	SkinLayerTranslation('Muzzle Scar (Mirror)', TL_PAINT);
	SkinLayerTranslation('Scars #1', TL_PAINT);
	SkinLayerTranslation('Scars #2', TL_PAINT);
	SkinLayerTranslation('Dogmeat Scar #1', TL_PAINT);
end;

//=========================================================================
// Some hair looks terrible (intentionally) or is too extreme for regular NPCs. Make sure
// that hair isn't assigned by default.
Procedure HairExclusions;
begin
    ExcludeHair('DLC03_HairFemale36'); // Acid Rain
    ExcludeHair('DLC03_HairFemale37'); // Beta Rays
    ExcludeHair('DLC03_HairMale46'); // Gamma Dream
    ExcludeHair('DLC03_HairMale47'); // Chemical Storm
    ExcludeHair('HairMale44'); // Megaton
    ExcludeHair('HairMale45'); // Hornet's Nest
end;

//=========================================================================
// By default, use all layers of all races. Why is it there if not to use?
// Except we may limit the number of layers per NPC so they don't get stupid.
Procedure SetRaceDefaults;
    var el, r: integer;
begin
    LogEntry(10, 'SetRaceDefaults');
    for r := RACE_LO to RACE_HI do begin
        for el := 0 to tintlayerName.Count-1 do begin
            Log(10, Format('Setting race default for %s %s', [masterRaceList[r], tintlayerName[el]]));
            raceInfo[r, MALE].tintProbability[el] := 100;
            raceInfo[r, FEMALE].tintProbability[el] := 100;
            raceInfo[r, MALECHILD].tintProbability[el] := 100;
            raceInfo[r, FEMALECHILD].tintProbability[el] := 100;
        end;
    end;
    LogExit(10, 'SetRaceDefaults');
end;

//======================================================
// Choose a race for the NPC.
// NPC is not altered.
// Guaranteed that the NPC can and should be changed to the given race.
Function ChooseNPCRace(npc: IwbMainRecord): integer;
var
    assignIndex: integer;
    charClass: integer;
    h: integer;
    mother: IwbMainRecord;
    pointTotal: integer;
    r: integer;
    racename: string;
    sex: integer;
    theRace: IwbMainElement;
begin
    LogEntry1(5, 'ChooseNPCRace', EditorID(npc));

    Result := -1;
    
    // Ghouls stay ghouls
    if (EditorID(GetNPCRace(npc)) = 'GhoulRace') or (EditorID(GetNPCRace(npc)) = 'GhoulChildRace') then 
        result := RACE_GHOUL;

    charClass := GetNPCClass(npc);

    if result < 0 then begin
        // Use the assigned race if any.
        assignIndex := npcRaceAssignments.IndexOf(EditorID(npc));
        if assignIndex >= 0 then begin
            theRace := ObjectToElement(npcRaceAssignments.Objects[assignIndex]);
            LogT(EditorID(npc) + ' assigned to race ' + EditorID(theRace));
            Result := RaceIndex(theRace);
        end
    end;

    if result < 0 then begin
        // Use the target race, if specified.
        Result := masterRaceList.IndexOf(TARGET_RACE);
    end;

    if Result < 0 then begin
        // Use the mother's/parent's race if any.
        mother := GetMother(npc);
        if Assigned(mother) then Result := ChooseNPCRace(mother);
    end;

    if result < 0 then begin
        // Pick a random race.
        pointTotal := classProbs[charClass, masterRaceList.Count];
        LogT(Format('classProbs has pre-summed value: %d', [classProbs[charClass, masterRaceList.Count]]));
        h := Hash(EditorID(npc), 6795, pointTotal);
        LogT(Format('Picking random race for class %s, Range = %d, hash = %d', [GetNPCClassName(charClass), pointTotal, h]));
        for r := RACE_LO to RACE_HI do begin
            LogT(Format('Testing race %s [%d - %d]', [masterRaceList[r], classProbsMin[charClass, r], classProbsMax[charClass, r]]));
            if (h >= classProbsMin[charClass, r]) and (h <= classProbsMax[charClass, r]) then begin
                Result := r;
                break;
            end;
        end;
    end;

    // If we have a child, make sure there's a child race.
    if (result >= 0) and (result <> RACE_GHOUL) then begin
        sex := GetNPCSex(npc);
        if not Assigned(raceInfo[result, sex].mainRecord) then begin
            result := -1;
        end;
    end;

    LogT(Format('Logging character: %d, %d', [charClass, result]));
    if (charClass >= 0) and (result >= 0) and (result <> RACE_GHOUL) then
        classCounts[charClass, result] := classCounts[charClass, result] + 1;

    LogExitT1('ChooseNPCRace', RaceIDtoStr(Result));
end;


//================================================================
// Remove any head morphs.
Procedure ZeroMorphs(npc: IwbMainRecord);
begin
    Remove(ElementByPath(npc, 'MSDK - Morph Keys'));
    Remove(ElementByPath(npc, 'MSDV - Morph Values'));
    Remove(ElementByPath(npc, 'Face Morphs'));  
end;

//=====================================================================
// Clean NPC of any of the elements we will furrify.
// Return the NPC's current hair. We will try to match it.
Function CleanNPC(npc: IwbMainRecord): IwbMainRecord;
var
    elemList: IwbContainer;
    hp: IwbMainRecord;
    i: integer;
begin
    result := Nil;
    ZeroMorphs(npc);

    Remove(ElementByPath(npc, 'FTST'));
    Remove(ElementByPath(npc, 'WNAM'));

    elemList := ElementByPath(npc, 'Head Parts');
    for i := ElementCount(elemList)-1 downto 0 do begin
            hp := LinksTo(ElementByIndex(elemList, i));
            if GetElementEditValues(hp, 'PNAM') = 'Hair' then 
                result := hp;
            RemoveByIndex(elemList, i, true);
    end;

    elemList := ElementByPath(npc, 'Face Tinting Layers');
    for i := ElementCount(elemList)-1 downto 0 do begin
            RemoveByIndex(elemList, i, true);
    end;

    // Set morph intensity to 1 for all furries
    SetNativeValue(ElementByPath(npc, 'FMIN - Facial Morph Intensity'), 1.0);
end;

//=============================================================================
// Set the NPC's race.
// furryNPC is the furry override record
// raceIndex is the index of the new race.
// If the NPC is a child, the actual race set will be the associated child race.
// Returns the hair record for the NPC, if any.
Function SetNPCRace(furryNPC: IwbMainRecord; raceIndex: integer): IwbMainRecord;
var
    race: IwbMainRecord;
    raceFormID: integer;
    sex: integer;
    skin: IwbMainRecord;
    targetFile: IwbFile;
begin
    LogEntry2(5, 'SetNPCRace', Name(furryNPC), IntToStr(raceIndex));

    result := CleanNPC(furryNPC);
    targetFile := GetFile(furryNPC);

    sex := GetNPCSex(furryNPC);
    if raceIndex = RACE_GHOUL then begin
        race := raceInfo[RacenameIndex(GHOUL_RACE), sex].mainRecord
    end
    else begin
        race := raceInfo[raceIndex, sex].mainRecord;
        raceFormID := GetLoadOrderFormID(race);
        Log(7, 'Setting race to ' + Name(race));
        SetNativeValue(ElementByPath(furryNPC, 'RNAM'), LoadOrderFormIDtoFileFormID(targetFile, raceFormID));
    end;

    skin := LinksTo(ElementByPath(race, 'WNAM'));
    Log(5, Format('Setting skin to %.8x/%.8x', [integer(GetLoadOrderFormID(skin)), integer(LoadOrderFormIDtoFileFormID(targetFile, GetLoadOrderFormID(skin)))]));
    Add(furryNPC, 'WNAM', true);
    SetNativeValue(ElementByPath(furryNPC, 'WNAM'),
        LoadOrderFormIDtoFileFormID(targetFile, GetLoadOrderFormID(skin)));

    Log(5, Format('Set race to %s', [GetElementEditValues(furryNPC, 'RNAM')]));

    LogExit1(5, 'SetNPCRace', Name(race));
end;

//================================================================
// Get the effective race ID of the NPC. This is the same as the race ID except for
// ghouls--for them, it's the race they're being furrified to.
Function GetNPCEffectiveRaceID(npc: IwbMainRecord): integer;
var
    rn: string;
begin
    result := GetNPCRaceID(npc);
    if result < 0 then begin
        rn := EditorID(GetNPCRace(npc));
        if (rn = 'GhoulRace') or (rn = 'GhoulChildRace') then
            result := masterRaceList.IndexOf(GHOUL_RACE);
    end;
end;

//================================================================
// Assign the given headpart to the character
Procedure AssignHeadpart(npc, hp: IwbMainRecord);
var
    headparts: IwbContainer;
    slot: IwbElement;
    targFile: IwbFile;
begin
    targFile := GetFile(npc);
    headparts := ElementByPath(npc, 'Head Parts');
    slot := ElementAssign(headparts, HighInteger, nil, false);
    SetNativeValue(slot, 
        LoadOrderFormIDtoFileFormID(targFile, GetLoadOrderFormID(hp)));
end;

//==============================================================
// Choose a random headpart of the given type. 
// Hair is handled separately.
Procedure ChooseHeadpart(npc: IwbMainRecord; hpType: integer);
var 
    headparts: IwbContainer;
    hp: IwbMainRecord;
    hpChance: integer;
    r: integer;
    s: integer;
    slot: IwbElement;
begin
    LogEntry2(4, 'ChooseHeadpart', Name(npc), IntToStr(hpType));

    r := GetNPCEffectiveRaceID(npc);
    s := GetNPCSex(npc);

    hpChance := Hash(EditorID(npc), 3632, 100);
    if hpChance < raceInfo[r, s].headpartProb[hpType] then begin
        hp := PickRandomHeadpart(
            EditorID(npc), 113, 
            r, s, hpType);
        if Assigned(hp) then
            AssignHeadpart(npc, hp);
    end;

    LogExit1(4, 'ChooseHeadpart', EditorID(npc));
end;

//==============================================================
// Assign the named headpart to the NPC.
Procedure SetHeadpart(npc: IwbMainRecord; hpType: integer; hpName: string);
var 
    hp: IwbMainRecord;
    i: integer;
    raceID: integer;
    sex: integer;
    thisHP: IwbMainRecord;
begin
    LogEntry3(5, 'SetHeadpart', EditorID(npc), IntToStr(hpType), hpName);
    raceID := GetNPCRaceID(npc);
    sex := GetNPCSex(npc);
    hp := Nil;
    for i := 0 to raceInfo[raceID, sex].headparts[hpType].Count-1 do begin
        thisHP := 
            ObjectToElement(
                raceInfo[GetNPCRaceID(npc), GetNPCSex(npc)]
                    .headparts[hpType]
                        .Objects[i]);
        Log(5, 'Checking ' + EditorID(thisHP));
        if EditorID(thisHP) = hpName then begin
            hp := thisHP;
            break;
        end;
    end;

    if Assigned(hp) then 
        AssignHeadpart(npc, hp)
    else
        Err(Format('Requested headpart %s not found for %s', [hpName, EditorID(npc)]));

    LogExit1(5, 'SetHeadpart', Name(hp));
end;

//==============================================================
// Look for the hair this NPC had before it was overridden.
Function FindPriorHair(npc: IwbMainRecord): IwbMainRecord;
var
    hp: IwbMainRecord;
    hplist: IwbElement;
    i: integer;
    npcFileIndex: integer;
    npcMaster: IwbMainRecord;
    priorOverride: IwbMainRecord;
    thisOverride: IwbMainRecord;
begin
    Log(5, Format('<FindPriorHair: %s in %s', [EditorID(npc), GetFileName(GetFile(npc))]));
    npcMaster := MasterOrSelf(npc);
    npcFileIndex := GetLoadOrder(GetFile(npc));
    Log(5, 'Found master for NPC in ' + GetFileName(GetFile(npcMaster)));

    priorOverride := Nil;
    Log(5, Format('Have %d overrides', [integer(OverrideCount(npcMaster))]));
    for i := OverrideCount(npcMaster)-1 downto 0 do begin
        thisOverride := OverrideByIndex(npcMaster, i);
        Log(5, 'Found override in file ' + GetFileName(GetFile(thisOverride)));
        Log(5, Format('Checking %d < %d', [GetLoadOrder(GetFile(thisOverride)), npcFileIndex]));
        if GetLoadOrder(GetFile(thisOverride)) < npcFileIndex then begin
            Log(5, 'Using override in file ' + GetFileName(GetFile(thisOverride)));
            priorOverride := thisOverride;
            break;
        end;
    end;

    if not Assigned(priorOverride) then priorOverride := npcMaster;
    Log(5, Format('Checking hair in override in file %s', [GetFileName(GetFile(priorOverride))]));

    result := Nil;
    hplist := ElementByPath(priorOverride, 'Head Parts');
    for i := 0 to ElementCount(hplist)-1 do begin
        hp := LinksTo(ElementByIndex(hplist, i));
        Log(5, Format('Checking for hair %s [%d] %s', [EditorID(hp), i, GetElementEditValues(hp, 'PNAM')]));
        if GetElementEditValues(hp, 'PNAM') = 'Hair' then begin
            result := hp;
            break;
        end;
    end;

    Log(5, '>FindPriorHair: ' + EditorID(result));
end;

//==============================================================
// Choose hair for a NPC. If possible, hair is matched to the NPC's current hair.
Procedure ChooseHair(npc, oldHair: IwbMainRecord);
var 
    hp: IwbMainRecord;
begin
    LogEntry2(5, 'ChooseHair', Name(npc), Name(oldHair));
    if (not Assigned(oldHair)) then begin
        Log(5, 'No old hair, leaving hair alone.');
    end
    else if StartsText('FFO', EditorID(oldHair)) then begin
        Log(5, 'Current hair is furry, using it');
        AssignHeadpart(npc, oldHair);
    end
    else begin
        hp := GetFurryHair(EditorID(npc), 3146, GetNPCEffectiveRaceID(npc), EditorID(oldHair));

        // Since most vanilla hair has been furrified, if this one hasn't then
        // just leave it off. They're mostly variations of shaved heads anyway.
        if Assigned(hp) then  AssignHeadpart(npc, hp);
    end;
    LogExit1(5, 'ChooseHair', Name(hp));
end;

//============================================================
// Assign a tint for a NPC.
Procedure AssignTint(npc: IwbMainRecord; tintOption, tintColor: IwbElement);
var
    color: IwbMainRecord;
    colorval: UInt32;
    facetintLayers: IwbElement;
    layer: IwbElement;
    tend: IwbElement;
    teti: IwbElement;
begin
    Log(5, Format('<AssignTint: %s [%s] [%s]', [EditorID(npc), Path(tintOption), Path(tintColor)]));

    color := LinksTo(ElementByPath(tintColor, 'Color'));
    Log(5, 'Have color ' + EditorID(color));

    // Depending on circumstances 'Add' may or may not create an empty entry.
    facetintLayers := Add(npc, 'Face Tinting Layers', true); // Make sure face tinting layers exists
    if ElementCount(ElementByPath(npc, 'Face Tinting Layers')) = 0 then
        layer := ElementAssign(facetintLayers, HighInteger, Nil, false)
    else if GetElementNativeValues(ElementByIndex(facetintLayers, 0), 'TETI\Index') = 0 then
        layer := ElementByIndex(facetintLayers, 0)
    else
        layer := ElementAssign(facetintLayers, HighInteger, Nil, false);
    
    teti := Add(layer, 'TETI', True);
    SetElementEditValues(teti, 'Data Type', 'Value/Color');
    SetElementNativeValues(teti, 'Index', integer(GetElementNativeValues(tintOption, 'TETI\Index')));
        
    tend := Add(layer, 'TEND', true);
    SetElementEditValues(tend, 'Value', GetElementEditValues(tintColor, 'Alpha'));

    colorval := GetElementNativeValues(color, 'CNAM');
    SetElementNativeValues(tend, 'Color\Red', RedPart(colorval));
    SetElementNativeValues(tend, 'Color\Green', GreenPart(colorval));
    SetElementNativeValues(tend, 'Color\Blue', BluePart(colorval));
    SetElementNativeValues(tend, 'Template Color Index', GetElementNativeValues(tintColor, 'Template Index'));

    if GetElementEditValues(tintOption, 'TETI\Slot') = 'Skin Tone' then begin
        SetElementNativeValues(npc, 'QNAM - Texture lighting\Red', RedPart(colorval));
        SetElementNativeValues(npc, 'QNAM - Texture lighting\Green', GreenPart(colorval));
        SetElementNativeValues(npc, 'QNAM - Texture lighting\Blue', BluePart(colorval));
        SetElementNativeValues(npc, 'QNAM - Texture lighting\Alpha', 
            GetElementNativeValues(tintColor, 'Alpha'));
    end;
    
    Log(5, '>AssignTint');
end;

//============================================================
// Choose and assign a tint for a NPC.
Procedure ChooseTint(npc: IwbMainRecord; tintlayer: integer; seed: integer);
var
    color: IwbMainRecord;
    ind: integer;
    p: IwbElement;
    prob: integer;
    probCheck: integer;
    race: integer;
    sex: integer;
    t: IwbElement;
begin
    LogEntry2(5, 'ChooseTint', Name(npc) , tintlayerName[tintlayer]);

    race := GetNPCEffectiveRaceID(npc);
    sex := GetNPCSex(npc);
    prob := raceInfo[race, sex].tintProbability[tintlayer];
    probCheck := Hash(EditorID(npc), seed, 101);
    ind := IfThen(tintlayer = TL_SKIN_TONE, 0, 1);

    Log(5, Format('Probability check: hash=%d, prob=%d, layer count=%d', [probCheck, prob, integer(raceInfo[race, sex].tintCount[tintlayer])]));
    if (probCheck <= prob) and (raceInfo[race, sex].tintCount[tintlayer] > 0) then begin

        t := PickRandomTintOption(EditorID(npc), seed, race, sex, tintlayer);
        p := PickRandomColorPreset(EditorID(npc), seed+7989, t, ind,
            raceInfo[race, sex].tintColors[tintLayer]);
        Log(5, 'Selected tint preset ' + Path(p));
        AssignTint(npc, t, p);
    end
    else begin
        Log(5, Format('Probability check failed, no assignment: %d <= %d, layer count %d', [integer(probCheck), integer(prob), integer(raceInfo[race, sex].tintCount[tintlayer])]));
    end;
    
    LogExit(5, 'ChooseTint');
end;

//============================================================
// If the NPC is old, give them the 'old' face tint layer.
Procedure ChooseOldTint(npc: IwbMainRecord; seed: integer);
begin
    if NPCisOld(npc) then ChooseTint(npc, TL_OLD, seed);
end;

//=============================================================================
// Select a random color from the color options.
// targetColor = '' if any color will do
// targetColor = color name if one color is wanted
// targetColor = list of color names separated by '|' if one of several colors is wanted.
//
// We might have the same color at different opacity levels, or multiple colors in
// the target list. So loop through the colors skipping the matching color some
// random number of times before selecting it.
Procedure SelectRandomColor(npc: IwbMainRecord; seed: integer; 
    layerOption: integer; tintLayer: integer; targetColor: string);
var 
    alpha: float;
    color: IwbMainRecord;
    colorList: IwbElement;
    colorPreset: IwbElement;
    i: integer;
    race: integer;
    sex: integer;
    tc: string;
    tintSkip: integer;
begin
    tintSkip := Hash(EditorID(npc), seed, ElementCount(colorList));
    race := GetNPCEffectiveRaceID(npc);
    sex := GetNPCSex(npc);
    colorList := ElementByPath(
        raceInfo[race, sex].tints[tintLayer, layerOption].element, 'TTEC'
    );
    tc := '|' + targetColor + '|';
    i := 0;
    while true do begin
        colorPreset := ElementByIndex(colorList, i);
        color := LinksTo(ElementByPath(colorPreset, 'Color'));
        alpha := GetNativeValue(ElementByPath(colorPreset, 'Alpha'));
        if alpha > 0.0001 
            and (ContainsText(tc, '|' + EditorID(color) + '|') 
                or (targetColor = '')) 
        then begin
            if tintSkip = 0 then begin
                AssignTint(npc, 
                    raceInfo[race, sex].tints[tintLayer, layerOption].element, colorPreset);
                break;
            end;
            tintSkip := tintSkip-1;
        end;
        i := i + 1;
        if i >= ElementCount(colorList) then 
            if tintSkip = 0 then
                break
            else
                i := 0;
    end;
end;

//=================================================================================
// Set the tint layer to the named color.
// If the tint layer has several options choose one at random.
// Color may be a single color or a list of colors separated by "|". 
Procedure SetTintlayerColor(npc: IwbMainRecord; seed: integer; 
    tintLayer: integer; targetColor: string);
var
    i: integer;
    layerOption: integer;
    race: integer;
    sex: integer;
begin
    Log(5, Format('<SetTintlayerColor: %s %s <- %s', [EditorID(npc), tintlayerName[tintLayer], targetColor]));
    
    race := GetNPCRaceID(npc);
    sex := GetNPCSex(npc);
    layerOption := Hash(EditorID(npc), seed, raceInfo[race, sex].tintCount[tintLayer]);
    SelectRandomColor(npc, seed, layerOption, tintLayer, targetColor);

    Log(5, '>SetTintlayerColor');
end;

//=================================================================================
// Set the tint layer to the named color, with a probability of prob out of 100.
Procedure SetTintlayerColorProb(probability: integer; npc: IwbMainRecord; seed: integer; 
    tintLayer: integer; targetColor: string);
var
    h: integer;
    i: integer;
    layerOption: integer;
    race: integer;
    sex: integer;
begin
    h := Hash(EditorID(npc), seed, 100);
    if h < probability then SetTintLayerColor(npc, seed, tintLayer, targetColor);
end;

//==============================================================================
// Set the tint layer to the named option.
// tintLayer = TL_ tint layer
// layerName = Name of the particular layer option wanted
// targetColor = Color to pick. May be '', one, or multiple colors.
Procedure PickTintColor(npc: IwbMainRecord; seed: integer; 
    tintLayer: integer; layerName: string; targetColor: string);
var
    i: integer;
    layerOption: integer;
    race: integer;
    sex: integer;
begin
    LogEntry3(5, 'PickTintColor', Name(npc), tintlayerName[tintLayer], targetColor);
    
    race := GetNPCEffectiveRaceID(npc);
    sex := GetNPCSex(npc);
    // layerOption := Hash(EditorID(npc), seed, raceInfo[race, sex].tintCount[tintLayer]);
    for layerOption := 0 to raceInfo[race, sex].tintCount[tintLayer]-1 do begin
        if GetElementEditValues(raceInfo[race, sex].tints[tintLayer, layerOption].element, 
                    'TTGP')
                = layerName then begin
            SelectRandomColor(npc, seed, layerOption, tintLayer, targetColor);
            break;
        end;
    end;

    LogExit(5, 'PickTintColor');
end;


//=========================================================================
// Set the given morph.
Procedure SetMorph(npc: IwbMainRecord; seed: integer; 
    morphGroup: string; presetName: string);
var
    r: integer;
    s: integer;
    preset: IwbElement;
begin
    LogEntry2(5, 'SetMorph', Name(npc), presetName);
    r := GetNPCEffectiveRaceID(npc);
    s := GetNPCSex(npc);
    if (s = MALE) or (s = FEMALE) then begin
        preset := GetMorphPreset(
            ObjectToElement(raceInfo[r, s].morphGroups.objects[
                raceInfo[r, s].morphGroups.IndexOf(morphGroup)
                ]),
            presetName);
        if Assigned(preset) then begin
            SetMorphValue(npc, 
                GetElementNativeValues(preset, 'MPPI'),
                HashVal(EditorID(npc), seed, 0.5, 1.0));
        end;
    end;
    LogExit(5, 'SetMorph');
end;

//=========================================================================
// Choose a random value for the given morph.
Procedure SetRandomMorph(npc: IwbMainRecord; morphGroup: string; seed: integer);
var
    h: integer;
    hashstr: string;
    mg: integer;
    mhi: integer;
    mhiIndex: integer;
    mlo: integer;
    mloIndex: integer;
    mp: integer;
    mskewIndex: integer;
    mval: float;
    p: integer;
    preset: IwbElement;
    r: integer;
    s: integer;
begin
    LogEntry2(5, 'SetRandomMorph', Name(npc), morphGroup);

    r := GetNPCEffectiveRaceID(npc);
    s := GetNPCSex(npc);

    // Decide whether to apply a morph from this group.
    hashstr := EditorID(npc) + morphGroup;
    h := Hash(hashstr, seed, 100);
    p := 100;
    mp := raceInfo[r, s].morphProbability.IndexOf(morphGroup);
    if mp >= 0 then
        p := raceInfo[r, s].morphProbability.objects[mp];

    // If it's not a child and we passed the probability test then do it.
    if (h <= p) and ((s = MALE) or (s = FEMALE)) then begin
        mg := raceInfo[r, s].morphGroups.IndexOf(morphGroup);
        preset := GetMorphRandomPreset(
            ObjectToElement(raceInfo[r, s].morphGroups.objects[mg]),
            hashstr,
            seed+31);
        if Assigned(preset) then begin
            mlo := 0;
            mhi := 100;
            mloIndex := raceInfo[r, s].morphLo.IndexOf(morphGroup);
            mhiIndex := raceInfo[r, s].morphHi.IndexOf(morphGroup);
            if (mloIndex >= 0) and (mhiIndex >= 0) then begin
                mlo := raceInfo[r, s].morphLo.objects[mloIndex];
                mhi := raceInfo[r, s].morphHi.objects[mhiIndex];
            end;
            mval := HashVal(hashstr, seed + 29, mlo/100, mhi/100);

            mskewIndex := raceInfo[r, s].morphSkew.IndexOf(morphGroup);
            if mskewIndex >= 0 then 
                case integer(raceInfo[r, s].morphSkew.objects[mskewIndex]) of
                    SKEW0: mval := mval * mval;
                    SKEW1: mval := 1 - (1-mval) * (1-mval);
                end;
            
            SetMorphValue(npc, GetElementNativeValues(preset, 'MPPI'), mval);
        end;
    end;
    LogExit(5, 'SetRandomMorph');
end;

//=========================================================
// Set a morph bone given by FMRI to the given values.
Procedure SetMorphBone(npc: IwbMainRecord; morphBoneIndex: integer;
    x, y, z: float;
    pitch, roll, yaw: float;
    sc: float);
var
    fm, thisMorph, vals: IwbElement;
begin
    Log(5, Format('<SetMorphBone(%s, %d)', [EditorID(npc), integer(morphBoneIndex)]));
    fm := Add(npc, 'Face Morphs', true);
    thisMorph := nil;
    if (ElementCount(fm) > 0)
        and (GetElementNativeValues(ElementByIndex(fm, 0), 'FMRI') = 0) then
            thisMorph := ElementByIndex(fm, 0)
    else
        thisMorph := ElementAssign(fm, HighInteger, nil, false);

    SetElementNativeValues(thisMorph, 'FMRI', morphBoneIndex);
    vals := Add(thisMorph, 'FMRS', true);
    SetElementNativeValues(vals, 'Position - X', x);
    SetElementNativeValues(vals, 'Position - Y', y);
    SetElementNativeValues(vals, 'Position - Z', z);
    SetElementNativeValues(vals, 'Rotation - X', pitch);
    SetElementNativeValues(vals, 'Rotation - Y', roll);
    SetElementNativeValues(vals, 'Rotation - Z', yaw);
    SetElementNativeValues(vals, 'Scale', sc);
    Log(5, '>');
end;

//=========================================================
// Set a morph bone given by name to the given values.
Procedure SetMorphBoneName(npc: IwbMainRecord; morphBone: string;
    x, y, z: float;
    pitch, roll, yaw: float;
    sc: float);
var
    i: integer;
    r: integer;
    s: integer;
begin
    LogEntry2(5, 'SetMorphBoneName', Name(npc), morphBone);
    s := GetNPCSex(npc);
    if ((s = MALE) or (s = FEMALE)) and Assigned(raceInfo[r, s].faceBoneList) then begin
        r := GetNPCEffectiveRaceID(npc);
        Log(5, Format('%s %s', [masterRaceList[r], sextostr(s)]));
        Log(5, Format('Have %d faceBones', [raceInfo[r, s].faceBoneList.Count]));
        i := raceInfo[r, s].faceBoneList.IndexOf(morphBone);
        if i < 0 then 
            Err(Format('Requested face morph not found for race %s/%s: %s', [
                masterRaceList[r], SexToStr(s), morphBone]))
        else begin
            Log(5, Format(' Calling SetMorphBone(%s, %s, [f, f, f], [f, f, f], f)', [
                EditorID(npc), IntToStr(raceInfo[r, s].faceBones[i].FMRI){, x, y, z, pitch, roll, yaw, sc}
            ]));
            SetMorphBone(npc, raceInfo[r, s].faceBones[i].FMRI, 
                x, y, z, pitch, roll, yaw, sc);
        end;
    end;
    LogExit(5, 'SetMorphBoneName');
end;

//================================================================================
// Set all availble morphs on the target NPC, randomly.
procedure SetAllRandomMorphs(npc: IwbMainRecord);
var
    fm: TTransform;
    hstr: string;
    i: integer;
    mname: string;
    r: integer;
    s: integer;
begin
    r := GetNPCEffectiveRaceID(npc);
    s := GetNPCSex(npc);
    if Assigned(raceInfo[r, s].morphGroups) then begin
        for i := 0 to raceInfo[r, s].morphGroups.Count-1 do begin
            mname := raceInfo[r, s].morphGroups[i];
            if raceInfo[r, s].morphExcludes.IndexOf(mname) < 0 then
                SetRandomMorph(npc, mname, 1781 + i*47);
        end;
    end;

    // Do the facebone morphs
    if Assigned(raceInfo[r, s].faceBoneList) then begin
        for i := 0 to raceInfo[r, s].faceBoneList.Count-1 do begin
            hstr := EditorID(npc) + raceInfo[r, s].faceBoneList[i];
            fm.x := HashVal(hstr, 9377, raceInfo[r, s].faceBones[i].min.x, raceInfo[r, s].faceBones[i].max.x);
            fm.y := HashVal(hstr, 9432, raceInfo[r, s].faceBones[i].min.y, raceInfo[r, s].faceBones[i].max.y);
            fm.z := HashVal(hstr, 2529, raceInfo[r, s].faceBones[i].min.z, raceInfo[r, s].faceBones[i].max.z);
            fm.xRot := HashVal(hstr, 9377, raceInfo[r, s].faceBones[i].min.xRot, raceInfo[r, s].faceBones[i].max.xRot);
            fm.yRot := HashVal(hstr, 9432, raceInfo[r, s].faceBones[i].min.yRot, raceInfo[r, s].faceBones[i].max.yRot);
            fm.zRot := HashVal(hstr, 2529, raceInfo[r, s].faceBones[i].min.zRot, raceInfo[r, s].faceBones[i].max.zRot);
            fm.scale := HashVal(hstr, 2529, raceInfo[r, s].faceBones[i].min.scale, raceInfo[r, s].faceBones[i].max.scale);
            SetMorphBone(npc, raceInfo[r, s].faceBones[i].FMRI,
                fm.x, fm.y, fm.z,
                fm.xRot, fm.yRot, fm.zRot,
                fm.scale);
        end;
    end;
end;

//============================================================================
// Create an override record for the NPC.
Function CreateNPCOverride(npc: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
begin
    AddRecursiveMaster(targetFile, GetFile(npc));
    result := wbCopyElementToFile(npc, targetFile, False, True);
end;

Function OverrideAndZeroMorphs(npc: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
var
    newNPC: IwbMainRecord;
begin
    newNPC := CreateNPCOverride(npc, targetFile);
    ZeroMorphs(newNPC);
    result := newNPC;
end;

//==============================================================
// Set an NPC's weight. Weight is the NPC's original weight modified by
// the weight passed in.
Procedure SetWeight(npc: IwbMainElement; thinFac, muscFac, fatFac: double);
Var
    thin, musc, fat, scaleFac: double;
    baseNPC: IwbMainRecord;
Begin
    baseNPC := MasterOrSelf(npc);
    thin := GetElementNativeValues(baseNPC, 'MWGT\Thin');
    musc := GetElementNativeValues(baseNPC, 'MWGT\Muscular');
    fat := GetElementNativeValues(baseNPC, 'MWGT\Fat');
    // Log(9, DisplayName(npc) + ' size = ' 
    //     + FloatToStr(thin) + '/' + FloatToStr(musc) + '/' + FloatToStr(fat));
        
    thin := (1 - 1/thinFac) + (thin/thinFac);
    musc := (1 - 1/muscFac) + (musc/muscFac);
    fat := (1 - 1/fatFac) + (fat/fatFac);
    scaleFac := thin + musc + fat;
    if scaleFac > 0.01 then begin
        SetElementNativeValues(npc, 'MWGT\Thin', thin / scaleFac); 
        SetElementNativeValues(npc, 'MWGT\Muscular', musc / scaleFac); 
        SetElementNativeValues(npc, 'MWGT\Fat', fat / scaleFac); 
    end;
End;

//============================================================================
// Give the NPC the given morph value
Procedure SetMorphValue(npc: IwbMainRecord; key: integer; value: float);
var
    keyval: IwbElement;
    morphval: IwbElement;
    msdk: IwbElement;
    msdv: IwbElement;
begin
    Log(5, Format('<SetMorphValue(%s, %s, %s) ', [EditorID(npc), IntToHex(key, 8), FloatToStr(value)]));
    msdk := Add(npc, 'MSDK', true);
    keyval := ElementAssign(msdk, HighInteger, nil, false);
    SetNativeValue(keyval, key);
    msdv := Add(npc, 'MSDV', true);
    morphval := ElementAssign(msdv, HighInteger, nil, false);
    SetNativeValue(morphval, value);
    Log(5, '>');
end;

//================================================================
// Set up the various types of deer.
Procedure MakeDeerWhitetail(npc: IwbMainRecord);
var
    h: integer;
begin
    LogEntry(4, 'MakeDeerWhitetail');
    SetWeight(npc, 2, 1, 1);
    if GetNPCSex(npc) = MALE then SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns01');

    SetTintLayerColor(npc, 7114, TL_SKIN_TONE,  
        '|FFOFurGingerL|FFOFurBrown|FFOFurTan|FFOFurGinger|FFOFurBrownL|FFOFurRusset|');

    // Muzzle is white around nose
    PickTintColor(npc, 2988, TL_MUZZLE, 'Muzzle', 'FFOFurWhite'); 

    // Big or little nose stripe
    SetTintLayerColor(npc, 510 ,TL_MUZZLE_STRIPE, 'FFOFurBlack');

    // Chin and throat
    SetTintLayerColor(npc, 1874, TL_CHIN, 'FFOFurWhite');

    // Eyes
    SetTintLayerColor(npc, 4151, TL_EYESOCKET_LOWER, 'FFOFurWhite');
    SetTintLayerColor(npc, 7095, TL_EYEBROW, 'FFOFurWhite');

    SetMorph(npc, 8578, 'Nose Shape', 'Dish Face');
    LogExitT('MakeDeerWhitetail');
end;

Procedure MakeDeerElk(npc: IwbMainRecord);
var
    h: integer;
    s: integer;
begin
    s := GetNPCSex(npc);
    SetWeight(npc, 1, 2, 2);
    if s = MALE then begin
        SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns02');
    end;

    SetTintLayerColor(npc, 2110, TL_SKIN_TONE,  
        'FFOFurBrown|FFOFurBrownD|FFOFurRussetD|FFOFurGingerD|FFOFurRedBrown');
    SetTintLayerColorProb(60, npc, 5794, TL_MUZZLE, 'FFOFurBlack');

    // Eyes
    SetTintLayerColor(npc, 2666, TL_EYESOCKET_LOWER, 'FFOFurWhite');

    if (s = MALE or s = FEMALE) then begin
        if s = MALE then
            SetMorphBoneName(npc, 'Jaw', 
                0, 0, 0.75,
                0, 0, 0,
                0);
        SetMorphBoneName(npc, 'Nose - Full', 
            0, 0.25, -0.5, 
            0, 0, 0,
            0.8);
        SetMorphBoneName(npc, 'Cheekbones', 
            1.0, 0, 0,
            0, 0, 0,
            0);
        end;
end;

Procedure MakeDeerReindeer(npc: IwbMainRecord);
var
    h: integer;
    s: integer;
begin
    s := GetNPCSex(npc);
    SetWeight(npc, 1, 2, 2);

    if s = MALE then begin
        SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns05');
        SetHeadpart(npc, HEADPART_FACIAL_HAIR, 'FFOBeard01');
    end;

    SetTintLayerColor(npc, 4480, TL_SKIN_TONE,  
        'FFOFurBrown|FFOFurBrownD|FFOFurRussetD|FFOFurGingerD|FFOFurRedBrown');

    if (s = MALE) or (s = FEMALE) then begin
        SetMorph(npc, 4726, 'Nostrils', 'Broad');
        SetMorphBoneName(npc, IfThen(s=MALE, 'Ears', 'Ears - Full'),
            0,    0,    0, 
            0,    0,    0,
            -0.2);
        SetMorphBoneName(npc, 'Nose - Full',
            0,  1.0, -1.0, 
            0,    0,    0,
            0.5);
    end;
end;

Procedure MakeDeerMoose(npc: IwbMainRecord);
var
    h: integer;
    s: integer;
begin
    s := GetNPCSex(npc);
    SetWeight(npc, 1, 2, 2);
    if s = MALE then begin
        SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns08');
        SetHeadpart(npc, HEADPART_FACIAL_HAIR, 'FFOBeard01');
    end;

    SetTintLayerColor(npc, 6032, TL_SKIN_TONE,  
        'FFOFurBrown|FFOFurBrownD|FFOFurRussetD|FFOFurGingerD|FFOFurRedBrown');
    
    if (s = MALE) or (s = FEMALE) then begin
        SetMorph(npc, 4726, 'Nostrils', 'Broad');
        if s = MALE then
            SetMorphBoneName(npc, 'Jaw', 
                0, 0, 0.75, 
                0, 0, 0, 
                0);
        SetMorphBoneName(npc, 'Nose - Full',
            0, -0.4, 0.24, 
            0, 0, 0, 
            0.8);
        SetMorphBoneName(npc, 'Cheekbones', 
            1, 0, 0,
            0, 0, 0,
            0);
    end;
end;

Procedure MakeDeerAntelope(npc: IwbMainRecord);
var
    h: integer;
    s: integer;
begin
    s := GetNPCSex(npc);
    SetWeight(npc, 2, 2, 1);
    h := Hash(EditorID(npc), 6728, 2);
    case h of
        0: SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns03'); // Gazelle
        1: SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns10'); // PRonghorn
    end;

    SetTintLayerColor(npc, 1740, TL_SKIN_TONE,  
        '|FFOFurGingerL|FFOFurBrown|FFOFurTan|FFOFurGinger|FFOFurBrownL|FFOFurTanD|');
    SetTintLayerColor(npc, 8514, TL_EYESOCKET_LOWER, 'FFOFurWhite');
    SetTintLayerColor(npc, 2412, TL_EYEBROW, 'FFOFurWhite');
    SetTintLayerColorProb(60, npc, 5794, TL_MUZZLE, '');
    SetTintLayerColorProb(60, npc, 5273, TL_MUZZLE_STRIPE, '');
    SetTintLayerColorProb(60, npc, 6305, TL_CHIN, '');
    SetTintLayerColorProb(60, npc, 8560, TL_CHEEK_COLOR, '');
    SetTintLayerColorProb(60, npc, 8631, TL_CHEEK_COLOR_LOWER, '');

    if (s = MALE) or (s = FEMALE) then begin
        SetMorph(npc, 4726, 'Nostrils', 'Broad');
        SetMorphBoneName(npc, IfThen(s=MALE, 'Ears', 'Ears - Full'), 
            0, 0, 0,
            0, 0, 0,
            0.86);
        SetMorphBoneName(npc, 'Nose - Full', 
            0, -0.24, -0.54,
            -0.27, 0, 0,
            0.51);
        SetMorphBoneName(npc, 'Eyes', 
            -0.45, -0.56, 0,
            0, 0, 0,
            0.55);
        SetMorphBoneName(npc, 'Nose - Bridge',
            0, 0.6, 0.6, 
            0, 0, 0,
            0);
    end;
end;

Procedure MakeDeerRam(npc: IwbMainRecord);
var
    h: integer;
    s: integer;
begin
    s := GetNPCSex(npc);
    SetWeight(npc, 1, 2, 2);
    if s = MALE then begin
        SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns07'); 
        SetHeadpart(npc, HEADPART_FACIAL_HAIR, 'FFOBeard01');
    end;

    SetTintLayerColor(npc, 8312, TL_SKIN_TONE,  
        '|FFOFurGingerL|FFOFurBrown|FFOFurTan|FFOFurGinger|FFOFurBrownL|');
    SetTintLayerColorProb(50, npc, 7698, TL_MUZZLE, 'FFOFurWhite');

    if (s = MALE) or (s = FEMALE) then begin
        if s = MALE then
            SetMorphBoneName(npc, 'Jaw', 
                0, 0, 0.6,
                0, 0, 0,
                0);
        SetMorphBoneName(npc, 'Nose - Full',
            0, 0, -0.6, 
            0, 0, 0,
            0.6);
        SetMorphBoneName(npc, 'Cheekbones', 
            1, 0, 0,
            0, 0, 0,
            0);
    end;
end;

//================================================================
// Set up a realistic deer.
Procedure FurrifyDeer(npc, hair: IwbMainRecord);
var
    deerType: integer;
begin
    ChooseHair(npc, hair);
    ChooseHeadpart(npc, HEADPART_EYES);
    ChooseHeadpart(npc, HEADPART_FACE);

    if GetNPCClass(npc) = CLASS_BOBROV then 
        deerType := 4
    else
        deerType := Hash(EditorID(npc), 9477, 6);
    
    case deerType of
        0: MakeDeerWhitetail(npc);
        1: MakeDeerElk(npc);
        2: MakeDeerReindeer(npc);
        3: MakeDeerMoose(npc);
        4: MakeDeerAntelope(npc);
        5: MakeDeerRam(npc);
    end;

    ChooseOldTint(npc, 3041+deerType*13);
end;
//================================================================
// Special tailoring for lions. 50% of the males get manes.
Procedure FurrifyLion(npc, hair: IwbMainRecord);
begin
    Log(4, Format('<FurrifyLion(%s, %s)', [Name(npc), GetElementEditValues(npc, 'RNAM')]));
    SetWeight(npc, 1, 2, 1);
    Log(5, Format('Calling ChooseHeadpart with %s\%s (%s)', [GetFileName(GetFile(npc)), Name(npc), EditorID(GetNPCRace(npc))]));
    ChooseHeadpart(npc, HEADPART_FACE);
    ChooseHeadpart(npc, HEADPART_EYES);

    if GetNPCSex(npc) = MALE and 
            ((Hash(EditorID(npc), 9203, 100) > 50) 
                or ContainsText(EditorID(npc), 'PrestonGarvey')
            ) then begin
        SetHeadpart(npc, HEADPART_HAIR, 'FFO_HairMaleMane');
    end
    else
        ChooseHair(npc, hair);

    ChooseHeadpart(npc, HEADPART_EYEBROWS);
    ChooseTint(npc, TL_SKIN_TONE, 6351);
    ChooseTint(npc, TL_NOSE, 1140);
    ChooseOldTint(npc, 4850);

    Log(4, '>');
end;

//==========================================================
// Furrify the NPC, if possible.
// Returns the furry NPC
Function FurrifyNPC(npc: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
var
    r: integer;
    furryNPC: IwbMainRecord;
    hair: IwbMainRecord;
begin
    LogEntry1(4, 'FurrifyNPC', Name(npc));
    result := npc;
    r := ChooseNPCRace(npc);

    if (r >= 0) and (r <> RACE_HUMAN) then begin
        furryNPC := CreateNPCOverride(npc, targetFile);
        hair := SetNPCRace(furryNPC, r);
        case r of 
            RACE_DEER: FurrifyDeer(furryNPC, hair);
            RACE_LION: FurrifyLion(furryNPC, hair);
        else 
            begin
            ChooseHeadpart(furryNPC, HEADPART_FACE);
            ChooseHeadpart(furryNPC, HEADPART_EYES);
            ChooseHeadpart(furryNPC, HEADPART_MOUTH);
            ChooseHair(furryNPC, hair);
            ChooseHeadpart(furryNPC, HEADPART_EYEBROWS);
            ChooseHeadpart(furryNPC, HEADPART_SCAR);
            ChooseTint(furryNPC, TL_SKIN_TONE, 9523);
            ChooseTint(furryNPC, TL_MASK, 2188);
            ChooseTint(furryNPC, TL_MUZZLE, 9487);
            ChooseTint(furryNPC, TL_EAR, 552);
            ChooseTint(furryNPC, TL_NOSE, 6529);
            ChooseOldTint(furryNPC, 2351);
            SetAllRandomMorphs(furryNPC);
            end;
        end;
        result := furryNPC;
    end
    else
        result := npc;

    LogExit(4, 'FurrifyNPC');
end;

//======================================================================
// Furrify a single NPC.
// npc is the winning override prior to FFO. 
// If the NPC already exists in the target mod, that definition will be overwritten.
// Returns the new furry npc.
Function MakeFurryNPC(npc: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
var
    furryNPC: IwbMainRecord;
    npcHair: IwbMainRecord;
begin
    LogEntry2(5, 'MakeFurryNPC', EditorID(npc), GetFileName(targetFile));

    if furrifiedNPCs.IndexOf(EditorID(npc)) < 0 then begin
        furryNPC := FurrifyNPC(npc, targetFile);
        furrifiedNPCs.Add(EditorID(npc));
        Result := furryNPC;
    end
    else
        Result := WinningOverride(npc);

    LogExit(5, 'MakeFurryNPC');
end;


//=========================================================================
// Create the new patch mod if it doesn't exist alerady.
//=====================================================
// Determine if the NPC needs to be furrified.
// - Must be HumanRace or furry race (we redo any furry NPCs)
// - Must not get its race from a template
// - Must not be overridden (we'll do this NPC when we get to the last override).
// Returns
// 0 - No furrification required
// 1 - Furrify the sucker
// 2 - NPC is based on a template (need to zero its morphs)
Function IsValidNPC(npc: IwbMainRecord): integer;
var
    race: IwbMainRecord;
begin
    LogEntry1(5, 'IsValidNPC', EditorID(npc));
    result := 1;
    // Must be an NPC
    Log(10, 'Signature: ' + Signature(npc));
    if Signature(npc) <> 'NPC_' then
        result := 0;

    if result > 0 then begin
        // Must not be overridden--we only work with the latest version
        Log(10, 'Overrides: ' + IntToStr(OverrideCount(npc)));
        if OverrideCount(npc) > 0 then 
            result := 0;
    end;

    race := GetNPCRace(npc);
    if result > 0 then begin
        // If already furry, do nothing
        if (masterRaceList.IndexOf(EditorID(race)) >= 0) 
            or (childRaceList.IndexOf(EditorID(race)) >= 0)
        then
            result := 0;
    end;

    // We only know how to furrify humans (and ghouls when asked)
    if result > 0 then begin
        if (EditorID(race) <> 'HumanRace') 
            and (EditorID(race) <> 'HumanChildRace') 
        then
            if convertingGhouls then begin
                if (EditorID(race) <> 'GhoulRace') 
                    and (EditorID(race) <> 'GhoulChildRace') 
                then
                    // Not ghoul -- do nothing
                    result := 0;
            end
            else
                // Not human, not converting ghouls -- do nothing
                result := 0;
    end;
    
    if result > 0 then begin
        // Must not be any of the player records, or Shaun--those are in the player race files
        Log(10, 'Is player: ' + IntToStr(playerIDs.IndexOf(EditorID(npc))));
        if playerIDs.IndexOf(EditorID(npc)) >= 0 then
            result := 0;
    end;

    if result > 0 then begin
        // Must not be a preset--furry races have their own
        if GetElementEditValues(npc, 'ACBS - Configuration\Flags\Is Chargen Face Preset') = '1' then
            result := 0;
    end;
    
    if result > 0 then begin
        // If it gets traits from a template, just zero out the morphs.
        if NPCInheritsTraits(npc) then
            result := 2;
    end;

    LogExit1(5, 'IsValidNPC', IntToStr(result));
end;

//========================================================
// Furrify the given race from the template race
Procedure FurrifyRace(targetFile: IwbFile; targetRace, templateRace: IwbMainRecord);
var 
    newRace: IwbMainRecord;
begin
    LogEntry3(5, 'FurrifyRace', GetFileName(targetFile), EditorID(targetRace), EditorID(templateRace));

    AddRecursiveMaster(targetFile, GetFile(targetRace));
    newRace := wbCopyElementToFile(targetRace, targetFile, false, true);
    
    wbCopyElementToRecord(ElementByPath(templateRace, 'WNAM'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Male Head Parts'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Female Head Parts'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'HCLF'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Male Hair Colors'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Female Hair Colors'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Male Face Details'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Female Face Details'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'DFTM'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'DFTF'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Male Tint Layers'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Female Tint Layers'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Male Morph Groups'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Female Morph Groups'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Male Face Morphs'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Morph Values'), newRace, false, true);

    LogExit(5, 'FurrifyRace');
end;

//========================================================
// Furrify whatever race the user has chosen for ghouls.
Procedure FurrifyGhoulRace(targetFile: IwbFile);
begin
    LogEntry1(1, 'FurrifyGhoulRace', GetFileName(targetFile));
    Log(0, 'Furrifying the ghoul race...');

    FurrifyRace(targetFile, 
        FindAsset(FileByIndex(0), 'RACE', 'GhoulRace'), 
        FindAsset(nil, 'RACE', GHOUL_RACE));

    // AddRace('GhoulRace');

    FurrifyRace(targetFile, 
        FindAsset(FileByIndex(0), 'RACE', 'GhoulChildRace'), 
        FindAsset(nil, 'RACE', GHOUL_CHILD_RACE));

    // AddChildRace('GhoulRace', 'GhoulChildRace');

    LogExit(1, 'FurrifyGhoulRace');
end;

//========================================================
// Set everything up.
Procedure InitializeFurrifier(targetFile: IwbFile);
var i, j: integer;
begin
    for i := 0 to FileCount-1 do
        if GetFileName(FileByIndex(i)) = 'FurryFallout.esp' then
            ffoFile := FileByIndex(i);

    InitializeAssetLoader;
    SetTintLayerTranslations;
    if TARGET_RACE <> '' then AddRace(TARGET_RACE);
    SetRaceProbabilities;
    SetRaceDefaults;
    TailorRaces;

    if racesNotFound.Count > 0 then begin
        AddMessage('These races were not found in the load order and will not be assigned:');
        for i := 0 to racesNotFound.Count-1 do
            AddMessage('   ' + racesNotFound[i]);
    end;

    if convertingGhouls then begin 
        FurrifyGhoulRace(targetFile);
        // Any headgear added by FFO that supports Snekdogs (or whatever race we are
        // turning ghouls into) needs to be modified to add the ghoul race.
        AddRaceToAllArmor(targetFile, 
            FindAsset(FileByIndex(0), 'RACE', 'GhoulRace'), 
            raceInfo[RacenameIndex(GHOUL_RACE), MALE].mainRecord); 
    end;

    CorrelateChildren;

    Log(0, 'Loading race info...');
    LoadRaceAssets;
    
    furrifiedNPCs := TStringList.Create();
    furrifiedNPCs.Duplicates := dupIgnore;
    furrifiedNPCs.Sorted := true;

    playerIDs := TStringList.Create();
    playerIDs.Duplicates := dupIgnore;
    playerIDs.Sorted := true;
    playerIDs.Add('Player');
    playerIDs.Add('MQ101PlayerSpouseMale');
    playerIDs.Add('MQ101PlayerSpouseFemale');
    playerIDs.Add('Shaun');
    playerIDs.Add('shaun');
    playerIDs.Add('ShaunChild');
    playerIDs.Add('MQ203MemoryH_Shaun');
    playerIDs.Add('ShaunChildHologram');

    RACE_CHEETAH := masterRaceList.IndexOf('FFOCheetahRace');
    RACE_DEER := masterRaceList.IndexOf('FFODeerRace');
    RACE_FOX := masterRaceList.IndexOf('FFOFoxRace');
    RACE_HORSE := masterRaceList.IndexOf('FFOHorseRace');
    RACE_HYENA := masterRaceList.IndexOf('FFOHyenaRace');
    RACE_LION := masterRaceList.IndexOf('FFOLionRace');
    RACE_LYKAIOS := masterRaceList.IndexOf('FFOLykaiosRace');
    RACE_OTTER := masterRaceList.IndexOf('FFOOtterRace');
    RACE_SNEKDOG := masterRaceList.IndexOf('FFOSnekdogRace');
    RACE_TIGER := masterRaceList.IndexOf('FFOTigerRace');
    RACE_HUMAN := masterRaceList.IndexOf('HumanRace');

    // Ghouls aren't in the masterRaceList. Use an ID that will be obviously broken if we
    // try to use it that way.
    RACE_GHOUL := 100;

    AddMorphBone('FFODeerRace', MALE, 'Cheekbones');
    AddMorphBone('FFODeerRace', MALE, 'Ears');
    AddMorphBone('FFODeerRace', MALE, 'Eyes');
    AddMorphBone('FFODeerRace', MALE, 'Jaw');
    AddMorphBone('FFODeerRace', MALE, 'Nose - Bridge');
    AddMorphBone('FFODeerRace', MALE, 'Nose - Full');
    AddMorphBone('FFODeerRace', FEMALE, 'Cheekbones');
    AddMorphBone('FFODeerRace', FEMALE, 'Ears - Full');
    AddMorphBone('FFODeerRace', FEMALE, 'Eyes');
    AddMorphBone('FFODeerRace', FEMALE, 'Nose - Bridge');
    AddMorphBone('FFODeerRace', FEMALE, 'Nose - Full');

    CalcClassTotals();

    for i := CLASS_LO to CLASS_HI do
        for j := RACE_LO to RACE_HI do
            classCounts[i, j] := 0;

end;

//=========================================================
// Free up anything allocated in startup.
Procedure ShutdownFurrifier;
begin
    furrifiedNPCs.Free;
    playerIDs.Free;
    ShutdownAssetLoader;
end;

// initialize stuff
function Initialize: integer;
var
  i: Integer;
  j: Integer;
  coll: TCollection;
  s: string;
  f: IwbFile;
  haveTarget: boolean;
begin
	// welcome messages
	AddMessage(#13#10);
	AddMessage('==========================================================');
	AddMessage('Furry Fallout Furrifier');
    AddMessage('');
    AddMessage('Creating patch for ' + wbAppName);
	AddMessage('----------------------------------------------------------');
	AddMessage('');

	AddMessage('----------------------------------------------------------');
    if USE_SELECTION then 
        AddMessage('Furrifying selected NPCs only')
    else 
        AddMessage('Furrifying all NPCs');
    
    if length(TARGET_RACE) > 0 then
        AddMessage('All affected NPCs will be changed to ' + TARGET_RACE);

    AddMessage('Patch file is ' + patchfileName);
    startTime := Time;
    // AddMessage('Start time ' + TimeToStr(startTime));
	AddMessage('----------------------------------------------------------');

    LOGLEVEL := 0;
    errCount := 0;
    warnCount := 0;

    preFurryCount := FileCount;
    patchFile := CreateOverrideMod(patchfileName);
    furryCount := 0;
    convertingGhouls := (not USE_SELECTION);

    InitializeFurrifier(patchFile);

    for i := RACE_LO to RACE_HI do begin
        AddRecursiveMaster(patchFile, GetFile(raceInfo[i, MALE].mainRecord));
        AddRecursiveMaster(patchFile, GetFile(raceInfo[i, MALECHILD].mainRecord));
    end;
end;

// Process selected NPCs.
// If we are using the selection, they get furrified here.
function Process(entity: IwbMainRecord): integer;
var
    win: IwbMainRecord;
begin
    if (not USE_SELECTION) or (not DO_FURRIFICATION) then exit;
    win := WinningOverride(entity);

    Log(2, Format('Furrifying %s in %s', [EditorID(win), GetFileName(GetFile(win))]));

    if (furryCount mod 100) = 0 then
        AddMessage(Format('Furrifying %s: %d', [
            GetFileName(GetFile(win)), integer(furryCount)]));
    
    case IsValidNPC(win) of
        1: MakeFurryNPC(win, patchFile);
        2: OverrideAndZeroMorphs(win, patchFile);
    end;

    furryCount := furryCount + 1;
end;

// If not using the selection, furrify everything here. 
function Finalize: integer;
var
    f: integer;
    fn: string;
    i, j, k: integer;
    n: integer;
    npc: IwbMainRecord;
    npcClass: integer;
    npcGroup: IwbContainer;
    npcList: IwbContainer;
    raceID: inetger;
begin
    if DO_FURRIFICATION and (not USE_SELECTION) then begin
        for f := 0 to preFurryCount-1 do begin
            // Don't check the NPCs in the patch file if we created it on this run.
            fn := GetFileName(FileByIndex(f));
            if (fn <> patchFileName) and (fn <> 'FurryFallout.esp') then begin
                Log(2, 'File ' + GetFileName(FileByIndex(f)));
                furryCount := 0;
                npcList := GroupBySignature(FileByIndex(f), 'NPC_');
                for n := 0 to ElementCount(npcList)-1 do begin
                    if (furryCount mod 100) = 0 then
                        AddMessage(Format('Furrifying %s: %d', 
                            [GetFileName(FileByIndex(f)), furryCount]));

                    npc := ElementByIndex(npcList, n);
                    Case IsValidNPC(npc) of
                        1: MakeFurryNPC(npc, patchFile);
                        // Creating the override will zero the morphs, which we need because human
                        // morphs won't work on furry races. 
                        2: OverrideAndZeroMorphs(npc, patchFile);
                    end;
                    furryCount := furryCount + 1;
                end;
            end;
            AddMessage(Format('Furrified %s: %d', 
                [GetFileName(FileByIndex(f)), furryCount]));
        end;

        AddMessage('Generating additional furry NPCs...');
        GenerateFurryNPCs(patchFile);
        AddMessage('Merging armor record changes...');
        MergeFurryChanges(patchFile);
    end;

    // AddMessage(Format('End time %s, duration %s', [TimeToStr(Time), TimeToStr(Time-startTime)]));
	AddMessage('----------------------------------------------------------');
    if (errCount = 0) and (warnCount = 0) then
        AddMessage('Furrification completed SUCCESSFULLY')
    else
        AddMessage(Format('Furrification completed with %d ERROR%s and %d WARNING%s', [
            errCount, IfThen(errCount = 1, '', 'S'), 
            warnCount, IfThen(warnCount = 1, '', 'S')
        ]));
	AddMessage('----------------------------------------------------------');

    if SHOW_RACE_DISTRIBUTION then begin
        // Walk through the NPCs and collect stats on how many of each race there are
        // to make sure the random assignment is giving a range of races.
	    AddMessage('');
        // AddMessage('---Race Probabilities---');
        // for k := 0 to FileCount-1 do begin
        //     npcGroup := GroupBySignature(FileByIndex(k), 'NPC_');
        //     for i := 0 to ElementCount(npcGroup)-1 do begin
        //         npc := ElementByIndex(npcGroup, i);
        //         if IsWinningOverride(npc) then begin
        //             npcClass := GetNPCClass(npc);
        //             raceID := GetNPCEffectiveRaceID(npc);
        //             if (npcClass >= 0) and (raceID >= 0) then
        //                 classCounts[npcClass, raceID] := classCounts[npcClass, raceID] + 1;
        //         end;
        //     end;
        // end;

        AddMessage('Check that we have a reasonable distribution of races');
        for i := CLASS_LO to CLASS_HI do begin
            AddMessage(GetNPCClassName(i));
            for j := RACE_LO to RACE_HI do begin
                if classCounts[i, j] > 0 then begin
                    if TRUE {not Assigned(masterRaceList[j].mainRecord)} then
                        AddMessage(Format('    %s %s = %d', [
                            GetNPCClassName(i), masterRaceList[j], classCounts[i, j]]))
                    else
                        AddMessage(Format('    %s %s = %d', [
                            GetNPCClassName(i), masterRaceList[j], classCounts[i, j]]));
                end;
            end;
        end;
    end;

	AddMessage('==========================================================');

    ShutdownFurrifier;

end;
end.