{
  NPC Furry Patch Builder
  Author: Bad Dog 
  Version: 2.6
  
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

    ffoIndex: integer;
    ffoFile: IwbFile;

    // playerIDs: TStringList;

    // Holds furrified NPCs. Object array is the hash value of the editor ID.
    furrifiedNPCs: TStringList;
    furryCount: integer;
    preFurryCount: integer;
    startTime: TDateTime;
    ghoulRaceHandle, ghoulChildRaceHandle: IwbMainRecord;

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
    SkinLayerTranslation('Scar - Left Long', TL_SCAR);
    SkinLayerTranslation('Fishbones', TL_PAINT);
    SkinLayerTranslation('Skull', TL_PAINT);

	//SHARK
	SkinLayerTranslation('QR Code', TL_MISC);
	SkinLayerTranslation('Selachii Stripes (Neck)', TL_MISC);
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
	SkinLayerTranslation('Mirror''s Edge', TL_EYELINER);
	SkinLayerTranslation('Mirror''s Edge (Alt)', TL_EYELINER);
	SkinLayerTranslation('Freckles', TL_MUZZLE_STRIPE);
	SkinLayerTranslation('Face Mask', TL_MASK);
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
	SkinLayerTranslation('Battle Worn', TL_SCAR);
	SkinLayerTranslation('Blade Scar #1', TL_SCAR);
	SkinLayerTranslation('Blade Scar #2', TL_SCAR);
	SkinLayerTranslation('Burn Left', TL_SCAR);
	SkinLayerTranslation('Burn Right', TL_SCAR);
	SkinLayerTranslation('Clawed', TL_SCAR);
	SkinLayerTranslation('Dry Lips', TL_SCAR);
	SkinLayerTranslation('Eye Scar', TL_SCAR);
	SkinLayerTranslation('Killer Shark', TL_SCAR);
	SkinLayerTranslation('Scratch #1', TL_SCAR);
	SkinLayerTranslation('Scratch #2', TL_SCAR);
	SkinLayerTranslation('Snout Scratch', TL_SCAR);
	SkinLayerTranslation('Tribal Scar', TL_SCAR);
	SkinLayerTranslation('X', TL_SCAR);

	//K9
	SkinLayerTranslation('Muzzle Scar', TL_SCAR);
	SkinLayerTranslation('Muzzle Scar (Mirror)', TL_SCAR);
	SkinLayerTranslation('Scars #1', TL_SCAR);
	SkinLayerTranslation('Scars #2', TL_SCAR);
	SkinLayerTranslation('Dogmeat Scar #1', TL_SCAR);
	SkinLayerTranslation('Dogmeat Scar #2', TL_SCAR);

	//PROTO-ARGONIAN
	SkinLayerTranslation('Eyeliner 1', TL_EYELINER);
	SkinLayerTranslation('Eyeliner 2', TL_EYELINER);
	SkinLayerTranslation('Eyeliner 3', TL_EYELINER);
	SkinLayerTranslation('Eyeliner 4', TL_EYELINER);
	SkinLayerTranslation('Eyeliner 5', TL_EYELINER);
	SkinLayerTranslation('Eyeliner 6', TL_EYELINER);
	SkinLayerTranslation('Eyeliner 7', TL_EYELINER);
	SkinLayerTranslation('Eyeliner 8', TL_EYELINER);
	SkinLayerTranslation('Eyes', TL_EYELINER);
	SkinLayerTranslation('Muzzle Stripes', TL_MUZZLE_STRIPE);
	SkinLayerTranslation('Eye Smudge', TL_EYELINER);
	SkinLayerTranslation('Cheeckbone Bars', TL_CHEEK_COLOR); // sic
	SkinLayerTranslation('Cheekbone Bars', TL_CHEEK_COLOR);
	SkinLayerTranslation('Spray', TL_MASK);
	SkinLayerTranslation('Eye Strokes', TL_MASK);
	SkinLayerTranslation('Forehead Paint', TL_FOREHEAD);
	SkinLayerTranslation('Eye Stripe', TL_EYELINER);
	SkinLayerTranslation('Throat Smudge', TL_NECK);
	SkinLayerTranslation('Scale Highlights', TL_MASK);
	SkinLayerTranslation('Head Stripes', TL_PAINT);
	SkinLayerTranslation('Head Stripes Fuzzy', TL_PAINT);
	SkinLayerTranslation('Eye Curve', TL_EYELINER);
	SkinLayerTranslation('The Reaper', TL_MASK);
	SkinLayerTranslation('Throat', TL_NECK);
	SkinLayerTranslation('Head Paint', TL_MASK);
	SkinLayerTranslation('Lightning', TL_MISC);
	SkinLayerTranslation('Lightning Forhead', TL_MISC);
	SkinLayerTranslation('Dots', TL_MISC);
	SkinLayerTranslation('Scale Dots', TL_EYEBROW);
	SkinLayerTranslation('Brow Dots', TL_EYEBROW);
	SkinLayerTranslation('Inset', TL_EYELINER);
	SkinLayerTranslation('Bold Stripe', TL_EYELINER);
	SkinLayerTranslation('The Point', TL_MASK);
	SkinLayerTranslation('We Know', TL_PAINT);
	SkinLayerTranslation('Celtic', TL_PAINT);
	SkinLayerTranslation('Scar 1', TL_SCAR);
	SkinLayerTranslation('Scar 2', TL_SCAR);
	SkinLayerTranslation('Scar 3', TL_SCAR);
	SkinLayerTranslation('Scar 4', TL_SCAR);
	SkinLayerTranslation('Scar 5', TL_SCAR);

	//DINOSAUR T-REX
	SkinLayerTranslation('Snout Bar Code (Left)', TL_NOSE);
	SkinLayerTranslation('Snout QR Code (Right)', TL_NOSE);
	SkinLayerTranslation('Basic', TL_EYELINER);
	SkinLayerTranslation('All Around', TL_EYELINER);
	SkinLayerTranslation('Foxy', TL_EYELINER);
	SkinLayerTranslation('Winged', TL_EYELINER);
	SkinLayerTranslation('Undereye Wing', TL_EYELINER);
	SkinLayerTranslation('Wild', TL_EYELINER);
	//DINOSAUR TRICERATOPS
	SkinLayerTranslation('Upper', TL_EYELINER);
	SkinLayerTranslation('High Wing', TL_EYELINER);
	SkinLayerTranslation('Longlash', TL_EYELINER);
	//DINOSAUR PARASAUROLOPHUS
	SkinLayerTranslation('Crest Mask', TL_MASK);
	SkinLayerTranslation('Face Texture Mask', TL_MASK);
	SkinLayerTranslation('Neck Band', TL_NECK);
	SkinLayerTranslation('Blood Smear', TL_MUZZLE);
	SkinLayerTranslation('Crest', TL_NOSE);
	SkinLayerTranslation('Arabic', TL_EYELINER);
	SkinLayerTranslation('Big Wing', TL_EYELINER);
	SkinLayerTranslation('Gianfranco', TL_EYELINER);
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
    ExcludeHair('HairFemale33'); // Megaton
    ExcludeHair('HairMale44'); // Megaton
    ExcludeHair('HairMale45'); // Hornet's Nest
    ExcludeHair('HairFemale34'); // Hornet's Nest
end;

//=========================================================================
// By default, use all layers of all races. Why is it there if not to use?
// Except we may limit the number of layers per NPC so they don't get stupid.
Procedure SetRaceDefaults;
    var el, r: integer;
begin
    if LOGGING Then LogEntry(10, 'SetRaceDefaults');
    for r := RACE_LO to RACE_HI do begin
        for el := 0 to tintlayerName.Count-1 do begin
            if LOGGING then LogT(Format('Setting race default for %s %s', [masterRaceList[r], tintlayerName[el]]));
            raceInfo[r, MALE].tintProbability[el] := 100;
            raceInfo[r, FEMALE].tintProbability[el] := 100;
            raceInfo[r, MALECHILD].tintProbability[el] := 100;
            raceInfo[r, FEMALECHILD].tintProbability[el] := 100;
        end;
    end;
    if LOGGING Then LogExit(10, 'SetRaceDefaults');
end;

//=========================================================================
// Record that an NPC is being furrified, remembering the signature to use for hashing.
//
// npcsignature is the unique signature for this NPC--either the editor ID or
// for NPCs with multiple records, a signature which is the same for all variants.
Procedure RecordNPC(npc: IwbMainRecord; npcsignature: string);
var
    h: integer;
begin
    h := Hash(npcsignature, 0, HighInteger);
    furrifiedNPCs.AddObject(EditorID(npc), npcsignature);
    curNPC.sig := npcsignature;
end;

//=========================================================================
// Returns a hash for an NPC based on seed and modulo. 
// Uses furrifiedNPCs to hash based on NPC signature rather than EditorID.
Function NPChash(npc: IwbMainRecord; seed: integer; m: integer): integer;
var
    n: integer;
begin
    if m = 0 then begin
        Err(Format('NPChash given no choices: %s, %s, %s', [Name(npc), IntToStr(seed), IntToStr(m)]));
        result := 0;
    end
    else if m = 1 then
        result := 0
    else begin
        n := furrifiedNPCs.IndexOf(EditorID(npc));
        if n >= 0 then
            Result := Hash(furrifiedNPCs.Objects[n], seed, m)
        else begin
            Err(Format('Furrification on NPC %s has apparently not started.', [Name(npc)]));
            Result := 0;
        end;
    end;
end;

//=========================================================================
// Returns a hash for the current NPC based on seed and modulo. 
Function NPC_Hash(seed: integer; m: integer): integer;
var
    n: integer;
begin
    if m = 0 then begin
        Err(Format('NPC_Hash given no choices: %s, %s, %s', [Name(curNPC.handle), IntToStr(seed), IntToStr(m)]));
        result := 0;
    end
    else if m = 1 then
        result := 0
    else 
        Result := Hash(curNPC.sig, seed, m);
end;

//======================================================
// Choose a race for the NPC. Also set up key values in curNPC. NPC_Setup must already
// have been run.
// NPC is not altered.
// Guaranteed that the NPC can and should be changed to the given race.
Procedure NPC_ChooseRace;
var
    assignIndex: integer;
    h: integer;
    mother: IwbMainRecord;
    player: IwbMainRecord;
    playerRace: IwbMainRecord;
    playerRaceID: integer;
    pointTotal: integer;
    r: integer;
    racename: string;
    theRace: IwbMainElement;
begin
    if LOGGING Then LogEntry1(5, 'NPC_ChooseRace', curNPC.id);

    curNPC.race := -1;
    
    // Ghouls stay ghouls
    if (EditorID(GetNPCRace(curNPC.handle)) = 'GhoulRace') 
        or (EditorID(GetNPCRace(curNPC.handle)) = 'GhoulChildRace') 
    then 
        curNPC.race := RACE_GHOUL;

    NPC_GetClass;

    if ContainsText(curNPC.id, 'Kellogg') then curNPC.sig := 'Kellogg'
    else if curNPC.npcclass = CLASS_DEACON then curNPC.sig := 'CompanionDeacon'
    else if ContainsText(curNPC.id, 'Emogene') then curNPC.sig := 'EmogeneCabotOld'
    else if SameText(curNPC.name, 'Sergeant Lee') then curNPC.sig := 'MS05_SgtLee'
    else if SameText(curNPC.name, 'Sully Mathis') then curNPC.sig := 'DN138Sully'
    else if ContainsText(curNPC.id, 'Shaun') then curNPC.sig := 'Shaun';
    
    RecordNPC(curNPC.handle, curNPC.sig);

    if curNPC.race < 0 then begin
        // Use the assigned race if any.
        assignIndex := npcRaceAssignments.IndexOf(curNPC.id);
        if assignIndex >= 0 then begin
            theRace := ObjectToElement(npcRaceAssignments.Objects[assignIndex]);
            if LOGGING Then LogD(curNPC.id + ' assigned to race ' + EditorID(theRace));
            curNPC.race := RaceIndex(theRace);
        end
    end;

    if curNPC.npcclass = CLASS_PLAYER then begin
        // This is one of Shaun's variants or another NPC that should follow the race of
        // the player.
        player := WinningOverride(RecordByFormID(FileByIndex(0), 07, False));
        playerRace := LinksTo(ElementByPath(player, 'RNAM'));
        playerRaceID := masterRaceList.IndexOf(EditorID(playerRace));
        if playerRaceID >= 0 then curNPC.race := playerRaceID;
    end;

    if (curNPC.race < 0) and (length(TARGET_RACE) > 0) then begin
        // Use the target race, if specified.
        curNPC.race := masterRaceList.IndexOf(TARGET_RACE);
    end;

    if curNPC.race < 0 then begin
        // Use the mother's/parent's race if any.
        mother := GetMother(curNPC.handle);
        if Assigned(mother) then begin
            NPC_Push;
            NPC_Setup(mother);
            NPC_ChooseRace;
            r := curNPC.race;
            NPC_Pop;
            curNPC.race := r;
        end;
    end;

    if curNPC.race < 0 then begin
        // Pick a random race.
        pointTotal := classProbs[curNPC.npcclass, masterRaceList.Count];
        if LOGGING Then LogD(Format('classProbs has pre-summed value: %d', [classProbs[curNPC.npcclass, masterRaceList.Count]]));
        h := NPC_Hash(6795, pointTotal);
        if LOGGING Then LogD(Format('Picking random race for class %s, Range = %d, hash = %d', [GetNPCClassName(curNPC.npcclass), pointTotal, h]));
        for r := RACE_LO to RACE_HI do begin
            if LOGGING Then LogD(Format('Testing race %s [%d - %d]', [masterRaceList[r], classProbsMin[curNPC.npcclass, r], classProbsMax[curNPC.npcclass, r]]));
            if (h >= classProbsMin[curNPC.npcclass, r]) and (h <= classProbsMax[curNPC.npcclass, r]) then begin
                curNPC.race := r;
                break;
            end;
        end;
    end;

    // If we have a child, make sure there's a child race.
    if (curNPC.race >= 0) and (curNPC.race <> RACE_GHOUL) and (curNPC.race <> RACE_HUMAN) 
    then begin
        if not Assigned(raceInfo[curNPC.race, curNPC.sex].mainRecord) then begin
            Warn(Format('Have no available race for %s, using Lykaios: %s, %s', [
                curNPC.id, SexToStr(curNPC.sex), RaceIDToStr(curNPC.race)
            ]));
            curNPC.race = RACE_LYKAIOS;
        end;
    end;

    if LOGGING Then LogD(Format('Logging character: %d, %d', [curNPC.npcclass, curNPC.race]));
    if (curNPC.npcclass >= 0) and (curNPC.race >= 0) and (curNPC.race <> RACE_GHOUL) then
        classCounts[curNPC.npcclass, curNPC.race] := classCounts[curNPC.npcclass, curNPC.race] + 1;

    if LOGGING Then LogExitT1('NPC_ChooseRace', RaceIDtoStr(curNPC.race));
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
// Save the NPC's current hair. We will try to match it.
Procedure NPC_Clean;
var
    elemList: IwbContainer;
    hp: IwbMainRecord;
    i: integer;
begin
    curNPC.old_hair := Nil;
    ZeroMorphs(curNPC.handle);

    Remove(ElementByPath(curNPC.handle, 'FTST'));
    Remove(ElementByPath(curNPC.handle, 'WNAM'));

    elemList := ElementByPath(curNPC.handle, 'Head Parts');
    for i := ElementCount(elemList)-1 downto 0 do begin
            hp := LinksTo(ElementByIndex(elemList, i));
            if GetElementEditValues(hp, 'PNAM') = 'Hair' then 
                curNPC.old_hair := hp;
            RemoveByIndex(elemList, i, true);
    end;

    elemList := ElementByPath(curNPC.handle, 'Face Tinting Layers');
    for i := ElementCount(elemList)-1 downto 0 do begin
            RemoveByIndex(elemList, i, true);
    end;

    // Set morph intensity to 1 for all furries
    SetNativeValue(ElementByPath(curNPC.handle, 'FMIN - Facial Morph Intensity'), 1.0);
end;

//=============================================================================
// Set the NPC's race.
// furryNPC is the furry override record
// raceIndex is the index of the new race.
// If the NPC is a child, the actual race set will be the associated child race.
// Saves the old hair record for the NPC, if any.
Procedure NPC_SetRace(raceIndex: integer);
var
    race: IwbMainRecord;
    raceFormID: integer;
    racename: string;
    skin: IwbMainRecord;
begin
    if LOGGING Then LogEntry2(5, 'NPC_SetRace', curNPC.id, IntToStr(raceIndex));

    NPC_Clean;
    curNPC.plugin := GetFile(curNPC.handle);

    if raceIndex = RACE_GHOUL then begin
        racename := EditorID(LinksTo(ElementByPath(curNPC.handle, 'RNAM')));
        if  (racename <> 'GhoulRace') and (racename <> 'GhoulChildRace') then begin
            raceFormID := GetLoadOrderFormID(ghoulRaceHandle);
            SetNativeValue(ElementByPath(curNPC.handle, 'RNAM'), 
                LoadOrderFormIDtoFileFormID(curNPC.plugin, raceFormID));
        end;
        curNPC.furry_race := RacenameIndex(GHOUL_RACE);
        race := raceInfo[curNPC.furry_race, curNPC.sex].mainRecord;
    end
    else begin
        race := raceInfo[raceIndex, curNPC.sex].mainRecord;
        raceFormID := GetLoadOrderFormID(race);
        if LOGGING then LogT('Setting race to ' + Name(race));
        SetNativeValue(ElementByPath(curNPC.handle, 'RNAM'), 
            LoadOrderFormIDtoFileFormID(curNPC.plugin, raceFormID));
        curNPC.furry_race := raceIndex;
    end;

    skin := LinksTo(ElementByPath(race, 'WNAM'));
    if LOGGING then LogT(Format('Setting skin in file %s to %.8x/%.8x', [
        GetFileName(curNPC.plugin),
        integer(GetLoadOrderFormID(skin)), 
        integer(LoadOrderFormIDtoFileFormID(curNPC.plugin, GetLoadOrderFormID(skin)))]));
    Add(curNPC.handle, 'WNAM', true);
    SetNativeValue(ElementByPath(curNPC.handle, 'WNAM'),
        LoadOrderFormIDtoFileFormID(curNPC.plugin, GetLoadOrderFormID(skin)));

    if LOGGING then LogT(NPC_ToStr);

    if LOGGING Then LogExitT1('NPC_SetRace', Name(race));
end;

//================================================================
// Get the effective race ID of the NPC. This is the same as the race ID except for
// ghouls--for them, it's the race they're being furrified to.
//
// If the NPC gets its traits from a template, we use the NPC's own race if it's 
// furry. If not, we check the template.
Function xxxGetNPCEffectiveRaceID(npc: IwbMainRecord): integer;
var
    ch: integer;
    raceRecord: IwbMainRecord;
    rn: string;
begin
    if LOGGING Then LogEntry1(0, 'GetNPCEffectiveRaceID', FullPath(npc));
    raceRecord := LinksTo(ElementByPath(npc, 'RNAM'));
    result := masterRaceList.IndexOf(EditorID(raceRecord));
    if LOGGING Then LogD(Format('NPC''s own race is %s %s', [RaceIDToStr(result), EditorID(raceRecord)]));
    if (result < 0) then begin
        result := childRaceList.IndexOf(EditorID(raceRecord));
        if LOGGING Then LogD(Format('Race %s found in child races: %d', [EditorID(raceRecord), result]));
        // if ch >= 0 then result := masterRaceList.IndexOf(childRaceList[ch]);
    end;
    if LOGGING Then LogD(Format('...after checking child records: %s', [RaceIDToStr(result)]));
    // result := GetNPCRaceID(npc);
    if result < 0 then begin
        rn := EditorID(GetNPCRace(npc));
        if (rn = 'GhoulRace') or (rn = 'GhoulChildRace') then
            result := masterRaceList.IndexOf(GHOUL_RACE);
    end;
    if LOGGING Then LogD(Format('...after checking ghouls: %s', [RaceIDToStr(result)]));
    if result < 0 then result := GetNPCRaceID(npc);
    if LOGGING Then LogExitT1('GetNPCEffectiveRaceID', RaceIDToStr(result));
end;

//================================================================
// Assign the given headpart to the character
Procedure NPC_AssignHeadpart(hp: IwbMainRecord);
var
    headparts: IwbContainer;
    slot: IwbElement;
begin
    if LOGGING Then LogEntry1(10, 'NPC_AssignHeadpart', Name(hp));
    headparts := ElementByPath(curNPC.handle, 'Head Parts');
    if not Assigned(headparts) then begin
        if LOGGING then LogT('No headparts on record, creating them for ' + Name(curNPC.handle));
        headparts := Add(curNPC.handle, 'Head Parts', True);
        slot := ElementByIndex(headparts, 0);
    end
    else
        slot := ElementAssign(headparts, HighInteger, nil, false);
    
    SetNativeValue(slot, 
        LoadOrderFormIDtoFileFormID(curNPC.plugin, GetLoadOrderFormID(hp)));

    if LOGGING Then LogExitT('NPC_AssignHeadpart');
end;

//==============================================================
// Choose a random headpart of the given type. 
// Hair is handled separately.
Procedure NPC_ChooseHeadpart(hpType: integer);
var 
    headparts: IwbContainer;
    hp: IwbMainRecord;
    hpChance: integer;
    slot: IwbElement;
begin
    if LOGGING Then LogEntry2(5, 'NPC_ChooseHeadpart', curNPC.id, HpToStr(hpType));
    if LOGGING Then LogD(Format('NPC race is %s', [RaceIDToStr(curNPC.furry_race)]));

    hpChance := NPC_Hash(3632, 100);
    if LOGGING Then LogD(Format('NPC info: %s, %s', [RaceIDToStr(curNPC.furry_race), SexToStr(curNPC.sex)]));
    if hpChance < raceInfo[curNPC.furry_race, curNPC.sex].headpartProb[hpType] then begin
        hp := PickRandomHeadpart(
            curNPC.sig, 113, 
            curNPC.furry_race, curNPC.sex, hpType);
        if Assigned(hp) then begin
            if LOGGING Then LogT('Assigning headpart ' + EditorID(hp));
            NPC_AssignHeadpart(hp);
        end;
    end;

    if LOGGING Then LogExitT('NPC_ChooseHeadpart');
end;

//==============================================================
// Assign the named headpart to the NPC.
Procedure NPC_SetHeadpart(hpType: integer; hpName: string);
var 
    hp: IwbMainRecord;
    i: integer;
    thisHP: IwbMainRecord;
begin
    if LOGGING Then LogEntry3(5, 'NPC_SetHeadpart', curNPC.id, HPtoStr(hpType), hpName);
    if LOGGING Then LogD(Format('Have race/sex %s/%s', [RaceIDToStr(curNPC.furry_race), SexToStr(curNPC.sex)]));
    hp := Nil;
    for i := 0 to raceInfo[curNPC.furry_race, curNPC.sex].headparts[hpType].Count-1 do begin
        thisHP := 
            ObjectToElement(
                raceInfo[curNPC.furry_race, curNPC.sex]
                    .headparts[hpType]
                        .Objects[i]);
        if LOGGING Then LogD('Checking ' + EditorID(thisHP));
        if EditorID(thisHP) = hpName then begin
            hp := thisHP;
            break;
        end;
    end;

    if Assigned(hp) then 
        NPC_AssignHeadpart(hp)
    else
        Err(Format('Requested headpart %s not found for %s', [hpName, Name(curNPC.handle)]));

    if LOGGING Then LogExit1(5, 'NPC_SetHeadpart', Name(hp));
end;

//==============================================================
// Look for the hair this NPC had before it was overridden.
Function xxxFindPriorHair(npc: IwbMainRecord): IwbMainRecord;
var
    hp: IwbMainRecord;
    hplist: IwbElement;
    i: integer;
    npcFileIndex: integer;
    npcMaster: IwbMainRecord;
    priorOverride: IwbMainRecord;
    thisOverride: IwbMainRecord;
begin
    If LOGGING then LogEntry1(5, 'FindPriorHair', FullPath(npc));
    npcMaster := MasterOrSelf(npc);
    npcFileIndex := GetLoadOrder(GetFile(npc));
    If LOGGING then LogD('Found master for NPC in ' + GetFileName(GetFile(npcMaster)));

    priorOverride := Nil;
    If LOGGING then LogD(Format('Have %d overrides', [integer(OverrideCount(npcMaster))]));
    for i := OverrideCount(npcMaster)-1 downto 0 do begin
        thisOverride := OverrideByIndex(npcMaster, i);
        If LOGGING then LogD('Found override in file ' + GetFileName(GetFile(thisOverride)));
        If LOGGING then LogD(Format('Checking %d < %d', [GetLoadOrder(GetFile(thisOverride)), npcFileIndex]));
        if GetLoadOrder(GetFile(thisOverride)) < npcFileIndex then begin
            If LOGGING then LogD('Using override in file ' + GetFileName(GetFile(thisOverride)));
            priorOverride := thisOverride;
            break;
        end;
    end;

    if not Assigned(priorOverride) then priorOverride := npcMaster;
    If LOGGING then LogD(Format('Checking hair in override in file %s', [GetFileName(GetFile(priorOverride))]));

    result := Nil;
    hplist := ElementByPath(priorOverride, 'Head Parts');
    for i := 0 to ElementCount(hplist)-1 do begin
        hp := LinksTo(ElementByIndex(hplist, i));
        If LOGGING then LogD(Format('Checking for hair %s [%d] %s', [EditorID(hp), i, GetElementEditValues(hp, 'PNAM')]));
        if GetElementEditValues(hp, 'PNAM') = 'Hair' then begin
            result := hp;
            break;
        end;
    end;

    If LOGGING then LogExitT1('FindPriorHair', EditorID(result));
end;

//==============================================================
// Choose hair for a NPC. If possible, hair is matched to the NPC's current hair.
Procedure NPC_ChooseHair;
var 
    hp: IwbMainRecord;
begin
    if LOGGING Then LogEntry2(5, 'NPC_ChooseHair', Name(curNPC.handle), Name(curNPC.old_hair));
    if (not Assigned(curNPC.old_hair)) then begin
        If LOGGING then LogT('No old hair, leaving hair alone.');
    end
    else if StartsText('FFO', EditorID(curNPC.old_hair)) then begin
        If LOGGING then LogT('Current hair is furry, using it');
        NPC_AssignHeadpart(curNPC.old_hair);
    end
    else begin
        hp := GetFurryHair(curNPC.sig, 3146, 
            curNPC.furry_race, curNPC.sex, EditorID(curNPC.old_hair));

        // Since most vanilla hair has been furrified, if this one hasn't then
        // just leave it off. They're mostly variations of shaved heads anyway.
        if Assigned(hp) then  NPC_AssignHeadpart(hp);
    end;
    if LOGGING Then LogExit1(5, 'NPC_ChooseHair', Name(hp));
end;

//============================================================
// Assign a tint for a NPC.
Procedure NPC_AssignTint(tintOption, tintColor: IwbElement);
var
    color: IwbMainRecord;
    colorval: UInt32;
    facetintLayers: IwbElement;
    layer: IwbElement;
    tend: IwbElement;
    teti: IwbElement;
begin
    If LOGGING then LogEntry3(5, 'NPC_AssignTint', curNPC.id, Path(tintOption), Path(tintColor));

    color := LinksTo(ElementByPath(tintColor, 'Color'));
    If LOGGING then LogD('Have color ' + EditorID(color));

    // Depending on circumstances 'Add' may or may not create an empty entry.
    facetintLayers := Add(curNPC.handle, 'Face Tinting Layers', true); // Make sure face tinting layers exists
    if ElementCount(ElementByPath(curNPC.handle, 'Face Tinting Layers')) = 0 then
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
        SetElementNativeValues(curNPC.handle, 'QNAM - Texture lighting\Red', RedPart(colorval));
        SetElementNativeValues(curNPC.handle, 'QNAM - Texture lighting\Green', GreenPart(colorval));
        SetElementNativeValues(curNPC.handle, 'QNAM - Texture lighting\Blue', BluePart(colorval));
        SetElementNativeValues(curNPC.handle, 'QNAM - Texture lighting\Alpha', 
            GetElementNativeValues(tintColor, 'Alpha'));
    end;
    
    If LOGGING then LogExitT('NPC_AssignTint');
end;

//============================================================
// Choose and assign a tint for a NPC.
Procedure NPC_ChooseTint(tintlayer: integer; seed: integer);
var
    color: IwbMainRecord;
    ind: integer;
    p: IwbElement;
    prob: integer;
    probCheck: integer;
    t: IwbElement;
begin
    if LOGGING Then LogEntry2(5, 'NPC_ChooseTint', Name(curNPC.handle) , tintlayerName[tintlayer]);

    prob := raceInfo[curNPC.furry_race, curNPC.sex].tintProbability[tintlayer];
    probCheck := NPC_Hash(seed, 101);
    ind := IfThen(tintlayer = TL_SKIN_TONE, 0, 1);

    if LOGGING then LogD(Format('Probability check: hash=%d, prob=%d, layer count=%d', [probCheck, prob, integer(raceInfo[curNPC.furry_race, curNPC.sex].tintCount[tintlayer])]));
    if (probCheck <= prob) and (raceInfo[curNPC.furry_race, curNPC.sex].tintCount[tintlayer] > 0) then begin

        t := PickRandomTintOption(curNPC.sig, seed, curNPC.furry_race, curNPC.sex, tintlayer);
        p := PickRandomColorPreset(curNPC.sig, seed+7989, t, ind,
            raceInfo[curNPC.furry_race, curNPC.sex].tintColors[tintLayer]);
        If LOGGING then LogT('Selected tint preset ' + Path(p));
        NPC_AssignTint(t, p);
    end
    else begin
        If LOGGING then LogT(Format('Probability check failed, no assignment: %d <= %d, layer count %d', [integer(probCheck), integer(prob), integer(raceInfo[curNPC.furry_race, curNPC.sex].tintCount[tintlayer])]));
    end;
    
    if LOGGING Then LogExitT('NPC_ChooseTint');
end;

//============================================================
// If the NPC is old, give them the 'old' face tint layer.
Procedure NPC_ChooseOldTint(seed: integer);
begin
    if curNPC.is_old then NPC_ChooseTint(TL_OLD, seed);
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
Procedure NPC_SelectRandomColor(seed: integer; 
    layerOption: integer; tintLayer: integer; targetColor: string);
var 
    alpha: float;
    color: IwbMainRecord;
    colorList: IwbElement;
    colorPreset: IwbElement;
    i: integer;
    tc: string;
    tintSkip: integer;
begin
    if LOGGING then LogEntry1(10, 'NPC_SelectRandomColor', curNPC.id);
    colorList := ElementByPath(
        raceInfo[curNPC.furry_race, curNPC.sex].tints[tintLayer, layerOption].element, 'TTEC'
    );
    tintSkip := NPC_Hash(seed, ElementCount(colorList));
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
                NPC_AssignTint(raceInfo[curNPC.furry_race, curNPC.sex].tints[tintLayer, layerOption].element, colorPreset);
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
    if LOGGING then LogExitT('NPC_SelectRandomColor');
end;

//=================================================================================
// Set the tint layer to the named color.
// If the tint layer has several options choose one at random.
// Color may be a single color or a list of colors separated by "|". 
Procedure NPC_SetTintlayerColor(seed: integer; tintLayer: integer; targetColor: string);
var
    i: integer;
    layerOption: integer;
    m: integer;
begin
    if LOGGING Then LogEntry3(5, 'NPC_SetTintlayerColor', curNPC.id, TintLayerToStr(tintLayer), targetColor);
    
    m := raceInfo[curNPC.furry_race, curNPC.sex].tintCount[tintLayer];
    layerOption := NPC_Hash(seed, m);
    NPC_SelectRandomColor(seed, layerOption, tintLayer, targetColor);

    if LOGGING Then LogExitT('NPC_SetTintlayerColor');
end;

//=================================================================================
// Set the tint layer to the named color, with a probability of prob out of 100.
Procedure NPC_SetTintlayerColorProb(probability: integer; seed: integer; 
    tintLayer: integer; targetColor: string);
var
    h: integer;
begin
    h := NPC_Hash(seed, 100);
    if h < probability then NPC_SetTintlayerColor(seed, tintLayer, targetColor);
end;

//==============================================================================
// Set the tint layer to the named option.
// tintLayer = TL_ tint layer
// layerName = Name of the particular layer option wanted
// targetColor = Color to pick. May be '', one, or multiple colors.
Procedure NPC_PickTintColor(seed: integer; tintLayer: integer; layerName: string; targetColor: string);
var
    i: integer;
    layerOption: integer;
begin
    if LOGGING Then LogEntry3(5, 'NPC_PickTintColor', curNPC.id, tintlayerName[tintLayer], targetColor);
    
    for layerOption := 0 to raceInfo[curNPC.furry_race, curNPC.sex].tintCount[tintLayer]-1 do begin
        if GetElementEditValues(
                    raceInfo[curNPC.furry_race, curNPC.sex].tints[tintLayer, layerOption].element, 
                    'TTGP')
                = layerName then begin
            NPC_SelectRandomColor(seed, layerOption, tintLayer, targetColor);
            break;
        end;
    end;

    if LOGGING Then LogExit(5, 'NPC_PickTintColor');
end;


//=========================================================================
// Set the given morph.
Procedure NPC_SetMorph(seed: integer; morphGroup: string; presetName: string);
var
    preset: IwbElement;
begin
    if LOGGING Then LogEntry2(5, 'NPC_SetMorph', Name(curNPC.handle), presetName);
    if (curNPC.sex = MALE) or (curNPC.sex = FEMALE) then begin
        preset := GetMorphPreset(
            ObjectToElement(raceInfo[curNPC.furry_race, curNPC.sex].morphGroups.objects[
                raceInfo[curNPC.furry_race, curNPC.sex].morphGroups.IndexOf(morphGroup)
                ]),
            presetName);
        if Assigned(preset) then begin
            NPC_SetMorphValue(
                GetElementNativeValues(preset, 'MPPI'),
                HashVal(curNPC.sig, seed, 0.5, 1.0));
        end;
    end;
    if LOGGING Then LogExit(5, 'NPC_SetMorph');
end;

//=========================================================================
// Choose a random value for the given morph.
Procedure NPC_SetRandomMorph(morphGroup: string; seed: integer);
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
begin
    if LOGGING Then LogEntry2(5, 'NPC_SetRandomMorph', Name(curNPC.handle), morphGroup);

    // Decide whether to apply a morph from this group.
    // hashstr := NPChash(npc) + Hash(morphGroup, 0, HighInteger;
    h := (NPC_Hash(seed, HighInteger) + Hash(morphGroup, 0, HighInteger)) mod 100 ;
    p := 100;
    mp := raceInfo[curNPC.furry_race, curNPC.sex].morphProbability.IndexOf(morphGroup);
    if mp >= 0 then
        p := raceInfo[curNPC.furry_race, curNPC.sex].morphProbability.objects[mp];

    // If it'curNPC.sex not a child and we passed the probability test then do it.
    if (h <= p) and ((curNPC.sex = MALE) or (curNPC.sex = FEMALE)) then begin
        mg := raceInfo[curNPC.furry_race, curNPC.sex].morphGroups.IndexOf(morphGroup);
        preset := GetMorphRandomPreset(
            ObjectToElement(raceInfo[curNPC.furry_race, curNPC.sex].morphGroups.objects[mg]),
            hashstr,
            seed+31);
        if Assigned(preset) then begin
            mlo := 0;
            mhi := 100;
            mloIndex := raceInfo[curNPC.furry_race, curNPC.sex].morphLo.IndexOf(morphGroup);
            mhiIndex := raceInfo[curNPC.furry_race, curNPC.sex].morphHi.IndexOf(morphGroup);
            if (mloIndex >= 0) and (mhiIndex >= 0) then begin
                mlo := raceInfo[curNPC.furry_race, curNPC.sex].morphLo.objects[mloIndex];
                mhi := raceInfo[curNPC.furry_race, curNPC.sex].morphHi.objects[mhiIndex];
            end;
            mval := HashVal(hashstr, seed + 29, mlo/100, mhi/100);

            mskewIndex := raceInfo[curNPC.furry_race, curNPC.sex].morphSkew.IndexOf(morphGroup);
            if mskewIndex >= 0 then 
                case integer(raceInfo[curNPC.furry_race, curNPC.sex].morphSkew.objects[mskewIndex]) of
                    SKEW0: mval := mval * mval;
                    SKEW1: mval := 1 - (1-mval) * (1-mval);
                end;
            
            NPC_SetMorphValue(GetElementNativeValues(preset, 'MPPI'), mval);
        end;
    end;
    if LOGGING Then LogExit(5, 'NPC_SetRandomMorph');
end;

//=========================================================
// Set a morph bone given by FMRI to the given values.
Procedure NPC_SetMorphBone(morphBoneIndex: integer;
    x, y, z: float;
    pitch, roll, yaw: float;
    sc: float);
var
    fm, thisMorph, vals: IwbElement;
begin
    If LOGGING then LogEntry2(5, 'NPC_SetMorphBone', curNPC.id, IntToStr(morphBoneIndex));
    fm := Add(curNPC.handle, 'Face Morphs', true);
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
    If LOGGING then LogExitT('NPC_SetMorphBone');
end;

//=========================================================
// Set a morph bone given by name to the given values.
Procedure NPC_SetMorphBoneName(morphBone: string;
    x, y, z: float;
    pitch, roll, yaw: float;
    sc: float);
var
    i: integer;
begin
    if LOGGING Then LogEntry2(5, 'NPC_SetMorphBoneName', Name(curNPC.handle), morphBone);
    if ((curNPC.sex = MALE) or (curNPC.sex = FEMALE)) 
        and Assigned(raceInfo[curNPC.furry_race, curNPC.sex].faceBoneList) 
    then begin
        if LOGGING Then LogD(Format('%s %s', [masterRaceList[curNPC.furry_race], sextostr(curNPC.sex)]));
        if LOGGING Then LogD(Format('Have %d faceBones', [raceInfo[curNPC.furry_race, curNPC.sex].faceBoneList.Count]));
        i := raceInfo[curNPC.furry_race, curNPC.sex].faceBoneList.IndexOf(morphBone);
        if i < 0 then 
            Err(Format('Requested face morph not found for race %s/%s: %s', [
                masterRaceList[curNPC.furry_race], SexToStr(curNPC.sex), morphBone]))
        else begin
            NPC_SetMorphBone(raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].FMRI, 
                x, y, z, pitch, roll, yaw, sc);
        end;
    end;
    if LOGGING Then LogExit(5, 'NPC_SetMorphBoneName');
end;

//================================================================================
// Set all availble morphs on the target NPC, randomly.
procedure NPC_SetAllRandomMorphs;
var
    fm: TTransform;
    hstr: string;
    i: integer;
    mname: string;
begin
    if Assigned(raceInfo[curNPC.furry_race, curNPC.sex].morphGroups) then begin
        for i := 0 to raceInfo[curNPC.furry_race, curNPC.sex].morphGroups.Count-1 do begin
            mname := raceInfo[curNPC.furry_race, curNPC.sex].morphGroups[i];
            if raceInfo[curNPC.furry_race, curNPC.sex].morphExcludes.IndexOf(mname) < 0 then
                NPC_SetRandomMorph(mname, 1781 + i*47);
        end;
    end;

    // Do the facebone morphs
    if Assigned(raceInfo[curNPC.furry_race, curNPC.sex].faceBoneList) then begin
        for i := 0 to raceInfo[curNPC.furry_race, curNPC.sex].faceBoneList.Count-1 do begin
            hstr := curNPC.sig + raceInfo[curNPC.furry_race, curNPC.sex].faceBoneList[i];
            fm.x := HashVal(hstr, 9377, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].min.x, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].max.x);
            fm.y := HashVal(hstr, 9432, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].min.y, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].max.y);
            fm.z := HashVal(hstr, 2529, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].min.z, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].max.z);
            fm.xRot := HashVal(hstr, 9377, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].min.xRot, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].max.xRot);
            fm.yRot := HashVal(hstr, 9432, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].min.yRot, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].max.yRot);
            fm.zRot := HashVal(hstr, 2529, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].min.zRot, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].max.zRot);
            fm.scale := HashVal(hstr, 2529, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].min.scale, raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].max.scale);
            NPC_SetMorphBone(raceInfo[curNPC.furry_race, curNPC.sex].faceBones[i].FMRI,
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
Procedure NPC_SetWeight(thinFac, muscFac, fatFac: double);
Var
    thin, musc, fat, scaleFac: double;
    baseNPC: IwbMainRecord;
Begin
    baseNPC := MasterOrSelf(curNPC.handle);
    thin := GetElementNativeValues(baseNPC, 'MWGT\Thin');
    musc := GetElementNativeValues(baseNPC, 'MWGT\Muscular');
    fat := GetElementNativeValues(baseNPC, 'MWGT\Fat');
        
    thin := (1 - 1/thinFac) + (thin/thinFac);
    musc := (1 - 1/muscFac) + (musc/muscFac);
    fat := (1 - 1/fatFac) + (fat/fatFac);
    scaleFac := thin + musc + fat;
    if scaleFac > 0.01 then begin
        SetElementNativeValues(curNPC.handle, 'MWGT\Thin', thin / scaleFac); 
        SetElementNativeValues(curNPC.handle, 'MWGT\Muscular', musc / scaleFac); 
        SetElementNativeValues(curNPC.handle, 'MWGT\Fat', fat / scaleFac); 
    end;
End;

//============================================================================
// Give the NPC the given morph value
Procedure NPC_SetMorphValue(key: integer; value: float);
var
    keyval: IwbElement;
    morphval: IwbElement;
    msdk: IwbElement;
    msdv: IwbElement;
begin
    if LOGGING Then LogEntry3(5, 'NPC_SetMorphValue', curNPC.id, IntToHex(key, 8), FloatToStr(value));
    msdk := Add(curNPC.handle, 'MSDK', true);
    keyval := ElementAssign(msdk, HighInteger, nil, false);
    SetNativeValue(keyval, key);
    msdv := Add(curNPC.handle, 'MSDV', true);
    morphval := ElementAssign(msdv, HighInteger, nil, false);
    SetNativeValue(morphval, value);
    if LOGGING Then LogExitT('NPC_SetMorphValue');
end;

//================================================================
// Set up the various types of deer.
Procedure NPC_MakeDeerWhitetail;
var
    h: integer;
begin
    if LOGGING Then LogEntry(4, 'NPC_MakeDeerWhitetail');
    NPC_SetWeight(2, 1, 1);
    if curNPC.sex = MALE then NPC_SetHeadpart(HEADPART_EYEBROWS, 'FFODeerHorns01');

    NPC_SetTintlayerColor(7114, TL_SKIN_TONE,  
        '|FFOFurGingerL|FFOFurBrown|FFOFurTan|FFOFurGinger|FFOFurBrownL|FFOFurRusset|');

    // Muzzle is white around nose
    NPC_PickTintColor(2988, TL_MUZZLE, 'Muzzle', 'FFOFurWhite'); 

    // Big or little nose stripe
    NPC_SetTintlayerColor(510 ,TL_MUZZLE_STRIPE, 'FFOFurBlack');

    // Chin and throat
    NPC_SetTintlayerColor(1874, TL_CHIN, 'FFOFurWhite');

    // Eyes
    NPC_SetTintlayerColor(4151, TL_EYESOCKET_LOWER, 'FFOFurWhite');
    NPC_SetTintlayerColor(7095, TL_EYEBROW, 'FFOFurWhite');

    NPC_SetMorph(8578, 'Nose Shape', 'Dish Face');
    if LOGGING Then LogExitT('NPC_MakeDeerWhitetail');
end;

Procedure NPC_MakeDeerElk;
var
    h: integer;
begin
    if LOGGING Then LogEntry1(4, 'NPC_MakeDeerElk', Name(curNPC.handle));
    NPC_SetWeight(1, 2, 2);
    if curNPC.sex = MALE then begin
        NPC_SetHeadpart(HEADPART_EYEBROWS, 'FFODeerHorns02');
    end;

    NPC_SetTintlayerColor(2110, TL_SKIN_TONE,  
        'FFOFurBrown|FFOFurBrownD|FFOFurRussetD|FFOFurGingerD|FFOFurRedBrown');
    NPC_SetTintlayerColorProb(60, 5794, TL_MUZZLE, 'FFOFurBlack');

    // Eyes
    NPC_SetTintlayerColor(2666, TL_EYESOCKET_LOWER, 'FFOFurWhite');

    if (curNPC.sex = MALE or curNPC.sex = FEMALE) then begin
        if curNPC.sex = MALE then
            NPC_SetMorphBoneName('Jaw', 
                0, 0, 0.75,
                0, 0, 0,
                0);
        NPC_SetMorphBoneName('Nose - Full', 
            0, 0.25, -0.5, 
            0, 0, 0,
            0.8);
        NPC_SetMorphBoneName('Cheekbones', 
            1.0, 0, 0,
            0, 0, 0,
            0);
        end;
    if LOGGING Then LogExitT('NPC_MakeDeerElk');
end;

Procedure NPC_MakeDeerReindeer;
var
    h: integer;
begin
    if LOGGING Then LogEntry1(4, 'NPC_MakeDeerReindeer', Name(curNPC.handle));
    NPC_SetWeight(1, 2, 2);

    if curNPC.sex = MALE then begin
        NPC_SetHeadpart(HEADPART_EYEBROWS, 'FFODeerHorns05');
        NPC_SetHeadpart(HEADPART_FACIAL_HAIR, 'FFOBeard01');
    end;

    NPC_SetTintlayerColor(4480, TL_SKIN_TONE,  
        'FFOFurBrown|FFOFurBrownD|FFOFurRussetD|FFOFurGingerD|FFOFurRedBrown');

    if (curNPC.sex = MALE) or (curNPC.sex = FEMALE) then begin
        NPC_SetMorph(4726, 'Nostrils', 'Broad');
        NPC_SetMorphBoneName(IfThen(curNPC.sex=MALE, 'Ears', 'Ears - Full'),
            0,    0,    0, 
            0,    0,    0,
            -0.2);
        NPC_SetMorphBoneName('Nose - Full',
            0,  1.0, -1.0, 
            0,    0,    0,
            0.5);
    end;
    if LOGGING Then LogExitT('NPC_MakeDeerReindeer');
end;

Procedure NPC_MakeDeerMoose;
var
    h: integer;
begin
    if LOGGING Then LogEntry1(4, 'NPC_MakeDeerMoose', Name(curNPC.handle));
    NPC_SetWeight(1, 2, 2);
    if curNPC.sex = MALE then begin
        NPC_SetHeadpart(HEADPART_EYEBROWS, 'FFODeerHorns08');
        NPC_SetHeadpart(HEADPART_FACIAL_HAIR, 'FFOBeard01');
    end;

    NPC_SetTintlayerColor(6032, TL_SKIN_TONE,  
        'FFOFurBrown|FFOFurBrownD|FFOFurRussetD|FFOFurGingerD|FFOFurRedBrown');
    
    if (curNPC.sex = MALE) or (curNPC.sex = FEMALE) then begin
        NPC_SetMorph(4726, 'Nostrils', 'Broad');
        if curNPC.sex = MALE then
            NPC_SetMorphBoneName('Jaw', 
                0, 0, 0.75, 
                0, 0, 0, 
                0);
        NPC_SetMorphBoneName('Nose - Full',
            0, -0.4, 0.24, 
            0, 0, 0, 
            0.8);
        NPC_SetMorphBoneName('Cheekbones', 
            1, 0, 0,
            0, 0, 0,
            0);
    end;
    if LOGGING Then LogExitT('NPC_MakeDeerMoose');
end;

Procedure NPC_MakeDeerAntelope;
var
    h: integer;
begin
    if LOGGING Then LogEntry1(4, 'NPC_MakeDeerAntelope', Name(curNPC.handle));

    NPC_SetWeight(2, 2, 1);
    if curNPC.npcclass = CLASS_BOBROV then 
        h := 0 // Bobrovs match
    else
        h := NPC_Hash(6728, 2);
    
    case h of
        0: NPC_SetHeadpart(HEADPART_EYEBROWS, 'FFODeerHorns03'); // Gazelle
        1: NPC_SetHeadpart(HEADPART_EYEBROWS, 'FFODeerHorns10'); // PRonghorn
    end;

    NPC_SetTintlayerColor(1740, TL_SKIN_TONE,  
        '|FFOFurGingerL|FFOFurBrown|FFOFurTan|FFOFurGinger|FFOFurBrownL|FFOFurTanD|');
    NPC_SetTintlayerColor(8514, TL_EYESOCKET_LOWER, 'FFOFurWhite');
    NPC_SetTintlayerColor(2412, TL_EYEBROW, 'FFOFurWhite');
    NPC_SetTintlayerColorProb(60, 5794, TL_MUZZLE, '');
    NPC_SetTintlayerColorProb(60, 5273, TL_MUZZLE_STRIPE, '');
    NPC_SetTintlayerColorProb(60, 6305, TL_CHIN, '');
    NPC_SetTintlayerColorProb(60, 8560, TL_CHEEK_COLOR, '');
    NPC_SetTintlayerColorProb(60, 8631, TL_CHEEK_COLOR_LOWER, '');

    if (curNPC.sex = MALE) or (curNPC.sex = FEMALE) then begin
        NPC_SetMorph(4726, 'Nostrils', 'Broad');
        NPC_SetMorphBoneName(IfThen(curNPC.sex=MALE, 'Ears', 'Ears - Full'), 
            0, 0, 0,
            0, 0, 0,
            0.86);
        NPC_SetMorphBoneName('Nose - Full', 
            0, -0.24, -0.54,
            -0.27, 0, 0,
            0.51);
        NPC_SetMorphBoneName('Eyes', 
            -0.45, -0.56, 0,
            0, 0, 0,
            0.55);
        NPC_SetMorphBoneName('Nose - Bridge',
            0, 0.6, 0.6, 
            0, 0, 0,
            0);
    end;
    if LOGGING Then LogExitT('NPC_MakeDeerAntelope');
end;

Procedure NPC_MakeDeerRam;
var
    h: integer;
begin
    if LOGGING Then LogEntry1(4, 'NPC_MakeDeerRam', Name(curNPC.handle));

    NPC_SetWeight(1, 2, 2);
    if curNPC.sex = MALE then begin
        NPC_SetHeadpart(HEADPART_EYEBROWS, 'FFODeerHorns07'); 
        NPC_SetHeadpart(HEADPART_FACIAL_HAIR, 'FFOBeard01');
    end;

    NPC_SetTintlayerColor(8312, TL_SKIN_TONE,  
        '|FFOFurGingerL|FFOFurBrown|FFOFurTan|FFOFurGinger|FFOFurBrownL|');
    NPC_SetTintlayerColorProb(50, 7698, TL_MUZZLE, 'FFOFurWhite');

    if (curNPC.sex = MALE) or (curNPC.sex = FEMALE) then begin
        if curNPC.sex = MALE then
            NPC_SetMorphBoneName('Jaw', 
                0, 0, 0.6,
                0, 0, 0,
                0);
        NPC_SetMorphBoneName('Nose - Full',
            0, 0, -0.6, 
            0, 0, 0,
            0.6);
        NPC_SetMorphBoneName('Cheekbones', 
            1, 0, 0,
            0, 0, 0,
            0);
    end;
    if LOGGING Then LogExitT('NPC_MakeDeerRam');
end;

//================================================================
// Set up a realistic deer.
Procedure NPC_FurrifyDeer;
var
    deerType: integer;
begin
    NPC_ChooseHair;
    NPC_ChooseHeadpart(HEADPART_EYES);
    NPC_ChooseHeadpart(HEADPART_FACE);

    case curNPC.npcclass of
        CLASS_BOBROV: deerType := 4;
        CLASS_PIPER: deerType := 0;
    else 
        deerType := NPC_Hash(9477, 6);
    end;
    
    case deerType of
        0: NPC_MakeDeerWhitetail;
        1: NPC_MakeDeerElk;
        2: NPC_MakeDeerReindeer;
        3: NPC_MakeDeerMoose;
        4: NPC_MakeDeerAntelope;
        5: NPC_MakeDeerRam;
    end;

    NPC_ChooseOldTint(3041+deerType*13);
end;
//================================================================
// Special tailoring for lions. 50% of the males get manes.
Procedure NPC_FurrifyLion;
begin
    if LOGGING Then LogEntry2(5, 'NPC_FurrifyLion', Name(curNPC.handle), EditorID(curNPC.old_hair));
    NPC_SetWeight(1, 2, 1);
    if LOGGING Then LogD(Format('Calling NPC_ChooseHeadpart with race %s', [EditorID(LinksTo(ElementByPath(curNPC.handle, 'RNAM')))]));
    NPC_ChooseHeadpart(HEADPART_FACE);
    NPC_ChooseHeadpart(HEADPART_EYES);

    if curNPC.sex = MALE and 
            ((NPC_Hash(9203, 100) > 50) 
                or ContainsText(curNPC.id, 'PrestonGarvey')
            ) 
    then begin
        NPC_SetHeadpart(HEADPART_HAIR, 'FFO_HairMaleMane');
    end
    else
        NPC_ChooseHair;

    NPC_ChooseHeadpart(HEADPART_EYEBROWS);
    NPC_ChooseTint(TL_SKIN_TONE, 6351);
    NPC_ChooseTint(TL_NOSE, 1140);
    NPC_ChooseOldTint(4850);

    if LOGGING Then LogExitT('NPC_FurrifyLion');
end;

//==========================================================
// Furrify the NPC, if possible.
// NPC must be the winning override.
// Returns the furry NPC.
Function FurrifyNPC(npc: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
begin
    if LOGGING Then LogEntry1(4, 'FurrifyNPC', Name(npc));
    result := npc;
    NPC_Setup(npc);
    NPC_ChooseRace;

    if (curNPC.race >= 0) and (curNPC.race <> RACE_HUMAN) then begin
        curNPC.handle := CreateNPCOverride(npc, targetFile);
        NPC_SetRace(curNPC.race);
        case curNPC.race of 
            RACE_DEER: NPC_FurrifyDeer;
            RACE_LION: NPC_FurrifyLion;
        else 
            begin
            NPC_ChooseHeadpart(HEADPART_FACE);
            NPC_ChooseHeadpart(HEADPART_EYES);
            NPC_ChooseHeadpart(HEADPART_MOUTH);
            NPC_ChooseHair;
            NPC_ChooseHeadpart(HEADPART_EYEBROWS);
            NPC_ChooseHeadpart(HEADPART_SCAR);
            NPC_ChooseTint(TL_SKIN_TONE, 9523);
            NPC_ChooseTint(TL_MASK, 2188);
            NPC_ChooseTint(TL_MUZZLE, 9487);
            NPC_ChooseTint(TL_EAR, 552);
            NPC_ChooseTint(TL_NOSE, 6529);
            NPC_ChooseOldTint(2351);
            NPC_SetAllRandomMorphs;
            end;
        end;
        result := curNPC.handle;
    end
    else
        result := npc;

    if LOGGING Then LogExit(4, 'FurrifyNPC');
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
    if LOGGING Then LogEntry2(5, 'MakeFurryNPC', EditorID(npc), GetFileName(targetFile));

    if furrifiedNPCs.IndexOf(EditorID(npc)) < 0 then begin
        furryNPC := FurrifyNPC(npc, targetFile);
        // furrifiedNPCs.Add(EditorID(npc));
        Result := furryNPC;
    end
    else
        Result := WinningOverride(npc);

    if LOGGING Then LogExit(5, 'MakeFurryNPC');
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
    if LOGGING Then LogEntry1(5, 'IsValidNPC', EditorID(npc));
    result := 1;
    // Must be an NPC
    if LOGGING Then LogD('Signature: ' + Signature(npc));
    if Signature(npc) <> 'NPC_' then
        result := 0;

    if result > 0 then begin
        // Must not be overridden--we only work with the latest version
        if LOGGING Then LogD('Overrides: ' + IntToStr(OverrideCount(npc)));
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

    // ***Now furrifying player family just like anything else
    //    
    // if result > 0 then begin
    //     // Must not be any of the player records, or Shaun--those are in the player race files
    //     if LOGGING Then LogD('Is player: ' + IntToStr(playerIDs.IndexOf(EditorID(npc))));
    //     if playerIDs.IndexOf(EditorID(npc)) >= 0 then
    //         result := 0;
    // end;

    ///// We now furrify presets because some mods depend on them.
    // if result > 0 then begin
    //     // Must not be a preset--furry races have their own
    //     if GetElementEditValues(npc, 'ACBS - Configuration\Flags\Is Chargen Face Preset') = '1' then
    //         result := 0;
    // end;
    
    ///// If it's a human race (tested above) we furrify even if it gets its traits
    ///// from a template. Seems like some dead NPCs don't follow the traits.
    // if result > 0 then begin
    //     // If it gets traits from a template, just zero out the morphs.
    //     if NPCInheritsTraits(npc) then
    //         result := 2;
    // end;

    if LOGGING Then LogExit1(5, 'IsValidNPC', IntToStr(result));
end;

//========================================================
// Furrify the given race from the template race
Procedure FurrifyRace(targetFile: IwbFile; targetRace, templateRace: IwbMainRecord);
var 
    newRace: IwbMainRecord;
begin
    if LOGGING Then LogEntry3(5, 'FurrifyRace', GetFileName(targetFile), EditorID(targetRace), EditorID(templateRace));

    AddRecursiveMaster(targetFile, GetFile(targetRace));
    newRace := wbCopyElementToFile(targetRace, targetFile, false, true);
    
    wbCopyElementToRecord(ElementByPath(templateRace, 'Bone Data'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'DFTF'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'DFTM'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Female Face Details'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Female Hair Colors'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Female Head Parts'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Female Morph Groups'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Female Tint Layers'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'HCLF'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Male Face Details'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Male Face Morphs'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Male Hair Colors'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Male Head Parts'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Male Morph Groups'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Male Tint Layers'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'Morph Values'), newRace, false, true);
    wbCopyElementToRecord(ElementByPath(templateRace, 'WNAM'), newRace, false, true);

    if LOGGING Then LogExit(5, 'FurrifyRace');
end;

//========================================================
// Furrify whatever race the user has chosen for ghouls.
Procedure FurrifyGhoulRace(targetFile: IwbFile);
begin
   if LOGGING Then  LogEntry1(1, 'FurrifyGhoulRace', GetFileName(targetFile));
    AddMessage('Furrifying the ghoul race...');

    FurrifyRace(targetFile, 
        FindAsset(FileByIndex(0), 'RACE', 'GhoulRace'), 
        FindAsset(nil, 'RACE', GHOUL_RACE));

    // AddRace('GhoulRace');

    FurrifyRace(targetFile, 
        FindAsset(FileByIndex(0), 'RACE', 'GhoulChildRace'), 
        FindAsset(nil, 'RACE', GHOUL_CHILD_RACE));

    // AddChildRace('GhoulRace', 'GhoulChildRace');

    if LOGGING Then LogExit(1, 'FurrifyGhoulRace');
end;

//========================================================
// Set everything up.
Procedure InitializeFurrifier(targetFile: IwbFile);
var i, j: integer;
begin
    for i := 0 to FileCount-1 do
        if GetFileName(FileByIndex(i)) = 'FurryFallout.esp' then begin
            ffoFile := FileByIndex(i);
            ffoIndex := i;
        end;

    InitializeAssetLoader;
    SetTintLayerTranslations;
    if TARGET_RACE <> '' then AddRace(TARGET_RACE);
    SetRaceProbabilities;
    SetRaceDefaults;
    TailorRaces;
    ghoulRaceHandle := FindAsset(NIL, 'RACE', 'GhoulRace');
    ghoulChildRaceHandle := FindAsset(NIL, 'RACE', 'GhoulChildRace');

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
        AddRaceToAllArmor(targetFile, 
            FindAsset(FileByIndex(0), 'RACE', 'GhoulChildRace'), 
            raceInfo[RacenameIndex(GHOUL_RACE), MALECHILD].mainRecord); 
    end;

    CorrelateChildren;

    AddMessage('Loading race info...');
    LoadRaceAssets;
    
    furrifiedNPCs := TStringList.Create();
    furrifiedNPCs.Duplicates := dupIgnore;
    furrifiedNPCs.Sorted := true;

    // playerIDs := TStringList.Create();
    // playerIDs.Duplicates := dupIgnore;
    // playerIDs.Sorted := true;
    // playerIDs.Add('Player');
    // playerIDs.Add('MQ101PlayerSpouseMale');
    // playerIDs.Add('MQ101PlayerSpouseFemale');
    // playerIDs.Add('Shaun');
    // playerIDs.Add('shaun');
    // playerIDs.Add('ShaunChild');
    // playerIDs.Add('MQ203MemoryH_Shaun');
    // playerIDs.Add('ShaunChildHologram');

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
    // playerIDs.Free;
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

    for i := 0 to FileCount-1 do begin

        preFurryCount := FileCount;
    end;
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

    if LOGGING then Log(2, Format('Furrifying %s in %s', [EditorID(win), GetFileName(GetFile(win))]));

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
        // Walk all files up to and including FFO. Nothing after FFO will be furrified.
        for f := 0 to ffoIndex do begin
            fn := GetFileName(FileByIndex(f));
            if (fn <> patchFileName) then begin
                if LOGGING Then Log(2, 'File ' + GetFileName(FileByIndex(f)));
                furryCount := 0;
                npcList := GroupBySignature(FileByIndex(f), 'NPC_');
                for n := 0 to ElementCount(npcList)-1 do begin
                    if (furryCount mod 100) = 0 then
                        AddMessage(Format('Furrifying %s: %d', 
                            [GetFileName(FileByIndex(f)), furryCount]));

                    npc := ElementByIndex(npcList, n);
                    if IsWinningOverride(npc) then begin
                        // Only furrify the winning override. We'll get to it unless it's in
                        // FFO or later, in which case it doesn't need furrification.
                        Case IsValidNPC(npc) of
                            1: MakeFurryNPC(npc, patchFile);
                            // Creating the override will zero the morphs, which we need because human
                            // morphs won't work on furry races. 
                            2: OverrideAndZeroMorphs(npc, patchFile);
                        end;
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
        //             npcClass := NPC_GetClass(npc);
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