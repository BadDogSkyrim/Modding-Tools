{
  NPC Furry Patch Builder
  Author: Bad Dog 
  
  Creates a NPC furry patch for a load order.

  By default, all NPCs are changed to furry races, children included. Ghouls are changed to 
  Nightstalkers. 

  Script allows customization of race assignments and what NPCs to affect.

	Hotkey: Ctrl+Alt+D

}

unit FFO_Furrifier;

interface

implementation

uses BDFurryArmorFixup, BDScriptTools, BDAssetLoaderFO4, xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    patchfileName = 'FFOPatch.esp'; // Set to whatever
    USE_SELECTION = FALSE;          // FALSE or TRUE
    TARGET_RACE = '';               // Use this race for everything
    GHOUL_RACE = 'FFOSnekdogRace';  // '' to leave ghouls alone

var
    patchFile: IwbFile;
    patchFileCreated: boolean;

    playerIDs: TStringList;
    furrifiedNPCs: TStringList;
    furryCount: integer;

//======================================================
// Define race probabilities for the different NPC classes,
// also for some specific NPCs. Must be called early because 
// this routine defines the furry races.
// TARGET_RACE overrides all these.
Procedure SetRaceProbabilities();
begin
    furrifyMales := True;
    furrifyFems := True;
    scalifyGhouls := True;

    // Probabilities are relative to each other and need not add up to 100.
    // So if all the predator races add up to 180, setting the horse race
    // to 18 means 1 NPC in 10 will be a horse.

    // Good fighters
    SetClassProb(CLASS_MINUTEMEN, 'FFOLykaiosRace', 30);
    SetClassProb(CLASS_MINUTEMEN, 'FFOFoxRace', 20);
    SetClassProb(CLASS_MINUTEMEN, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_MINUTEMEN, 'FFOLionRace', 30);
    SetClassProb(CLASS_MINUTEMEN, 'FFOTigerRace', 40);
    SetClassProb(CLASS_MINUTEMEN, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_MINUTEMEN, 'FFOHorseRace', 40);
    SetClassProb(CLASS_MINUTEMEN, 'FFODeerRace', 20);
    // SetClassProb(CLASS_BOS, 'FFOHumanRace', 10);

    SetClassProb(CLASS_BOS, 'FFOLykaiosRace', 40);
    SetClassProb(CLASS_BOS, 'FFOFoxRace', 20);
    SetClassProb(CLASS_BOS, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_BOS, 'FFOLionRace', 20);
    SetClassProb(CLASS_BOS, 'FFOTigerRace', 20);
    SetClassProb(CLASS_BOS, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_BOS, 'FFOHorseRace', 30);
    SetClassProb(CLASS_BOS, 'FFODeerRace', 10);

    SetClassProb(CLASS_RR, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_RR, 'FFOFoxRace', 20);
    SetClassProb(CLASS_RR, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_RR, 'FFOLionRace', 30);
    SetClassProb(CLASS_RR, 'FFOTigerRace', 20);
    SetClassProb(CLASS_RR, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_RR, 'FFOHorseRace', 60);
    SetClassProb(CLASS_RR, 'FFODeerRace', 30);

    // Enemies

    SetClassProb(CLASS_GUNNER, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOFoxRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOLionRace', 60);
    SetClassProb(CLASS_GUNNER, 'FFOTigerRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOHorseRace', 10);
    SetClassProb(CLASS_GUNNER, 'FFODeerRace', 5);

    SetClassProb(CLASS_DISCIPLES, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOFoxRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOHyenaRace', 60);
    SetClassProb(CLASS_DISCIPLES, 'FFOLionRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOTigerRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOHorseRace', 8);
    SetClassProb(CLASS_DISCIPLES, 'FFODeerRace', 4);

    SetClassProb(CLASS_OPERATOR, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_OPERATOR, 'FFOFoxRace', 60);
    SetClassProb(CLASS_OPERATOR, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_OPERATOR, 'FFOLionRace', 10);
    SetClassProb(CLASS_OPERATOR, 'FFOTigerRace', 10);
    SetClassProb(CLASS_OPERATOR, 'FFOCheetahRace', 10);
    SetClassProb(CLASS_OPERATOR, 'FFOHorseRace', 5);
    SetClassProb(CLASS_OPERATOR, 'FFODeerRace', 5);

    SetClassProb(CLASS_PACK, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_PACK, 'FFOFoxRace', 20);
    SetClassProb(CLASS_PACK, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_PACK, 'FFOLionRace', 20);
    SetClassProb(CLASS_PACK, 'FFOTigerRace', 20);
    SetClassProb(CLASS_PACK, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_PACK, 'FFOHorseRace', 5);
    SetClassProb(CLASS_PACK, 'FFODeerRace', 5);

    SetClassProb(CLASS_RAIDER, 'FFOLykaiosRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOFoxRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOHyenaRace', 50);
    SetClassProb(CLASS_RAIDER, 'FFOLionRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOTigerRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOCheetahRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOHorseRace', 16);
    SetClassProb(CLASS_RAIDER, 'FFODeerRace', 8);

    SetClassProb(CLASS_TRAPPER, 'FFOOtterRace', 100);
    SetClassProb(CLASS_TRAPPER, 'FFOLykaiosRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOFoxRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOLionRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOTigerRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOCheetahRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOHorseRace', 5);
    SetClassProb(CLASS_TRAPPER, 'FFODeerRace', 5);

    // Neutrals 

    SetClassProb(CLASS_INSTITUTE, 'FFOLykaiosRace', 30);
    SetClassProb(CLASS_INSTITUTE, 'FFOFoxRace', 20);
    SetClassProb(CLASS_INSTITUTE, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_INSTITUTE, 'FFOLionRace', 30);
    SetClassProb(CLASS_INSTITUTE, 'FFOTigerRace', 40);
    SetClassProb(CLASS_INSTITUTE, 'FFOCheetahRace', 40);
    SetClassProb(CLASS_INSTITUTE, 'FFOHorseRace', 50);
    SetClassProb(CLASS_INSTITUTE, 'FFODeerRace', 50);

    SetClassProb(CLASS_FARHARBOR, 'FFOLykaiosRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOFoxRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOHyenaRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOLionRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOTigerRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOCheetahRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOHorseRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFODeerRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOOtterRace', 90);

    SetClassProb(CLASS_ATOM, 'FFOLykaiosRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOFoxRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOHyenaRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOLionRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOTigerRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOCheetahRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOHorseRace', 5);
    SetClassProb(CLASS_ATOM, 'FFODeerRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOSnekdogRace', 40);

    SetClassProb(NONE, 'FFOLykaiosRace', 10);
    SetClassProb(NONE, 'FFOFoxRace', 10);
    SetClassProb(NONE, 'FFOHyenaRace', 10);
    SetClassProb(NONE, 'FFOLionRace', 10);
    SetClassProb(NONE, 'FFOTigerRace', 10);
    SetClassProb(NONE, 'FFOCheetahRace', 10);
    SetClassProb(NONE, 'FFOHorseRace', 15);
    SetClassProb(NONE, 'FFODeerRace', 15);
    SetClassProb(NONE, 'FFOOtterRace', 3);

    // Followers. There's at least one follower of each race.
    SetClassProb(CLASS_GARVEY, 'FFOLionRace', 100);
    SetClassProb(CLASS_CAIT, 'FFOFoxRace', 100);
    SetClassProb(CLASS_DANSE, 'FFOLykaiosRace', 100);
    SetClassProb(CLASS_DEACON, 'FFOHorseRace', 100);
    SetClassProb(CLASS_GAGE, 'FFOHyenaRace', 100);
    SetClassProb(CLASS_LONGFELLOW, 'FFOOtterRace', 100);
    SetClassProb(CLASS_MACCREADY, 'FFOCheetahRace', 100);
    SetClassProb(CLASS_PIPER, 'FFODeerRace', 100);
    SetClassProb(CLASS_X688, 'FFOTigerRace', 100);

    // Specific NPCs or families. Ensures relatives and older/younger
    // versions of the same NPC have the same race.
    SetClassProb(CLASS_BOBROV, 'FFODeerRace', 100);
    SetClassProb(CLASS_CABOT, 'FFOCheetahRace', 100);
    SetClassProb(CLASS_DELUCA, 'FFODeerRace', 100);
    SetClassProb(CLASS_KELLOGG, 'FFOTigerRace', 100);
    SetClassProb(CLASS_KYLE, 'FFOFoxRace', 100);
    SetClassProb(CLASS_PEMBROKE, 'FFOHorseRace', 100);

    // Ghouls. All ghouls have to be the same race (because headgear has to be altered to
    // fit them).
    SetClassProb(CLASS_GHOUL, 'FFOSnekdogRace', 100);

    // Specific NPCs
    // These override TARGET_RACE.
    AssignNPCRace('MamaMurphy', 'FFOLionRace'); // Her hat is tailored to the lioness head
    AssignNPCRace('DLC04Mason', 'FFOHorseRace'); // I just like him this way

    CalcClassTotals();
end;

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
    SkinLayerTranslation('Face Mask 1', TL_Mask);
    SkinLayerTranslation('Face Mask 2', TL_Mask);
    SkinLayerTranslation('Face Mask 3', TL_Mask);
    SkinLayerTranslation('Face Mask 4', TL_Mask);
    SkinLayerTranslation('Face Plate', TL_MASK);
    SkinLayerTranslation('Forehead', TL_FOREHEAD);
    SkinLayerTranslation('Head Scales', TL_FOREHEAD);
    SkinLayerTranslation('Lips', TL_LIP_COLOR);
    SkinLayerTranslation('Lower Jaw', TL_CHIN);
    SkinLayerTranslation('Mask', TL_Mask);
    SkinLayerTranslation('Mouche', TL_CHIN);
    SkinLayerTranslation('Muzzle Stripe', TL_NOSE); // Check on deer
    SkinLayerTranslation('Muzzle Upper', TL_NOSE); // CHeck on deer
    SkinLayerTranslation('Muzzle', TL_MUZZLE);
    SkinLayerTranslation('Nose Stripe 1', TL_MUZZLE); // Fox
    SkinLayerTranslation('Nose Stripe 2', TL_MUZZLE); // Fox
    SkinLayerTranslation('Nose Stripe', TL_MUZZLE); // Check on deer
    SkinLayerTranslation('Nose', TL_NOSE);
    SkinLayerTranslation('Old', TL_OLD);
    SkinLayerTranslation('Skin tone', TL_SKIN_TONE);
    SkinLayerTranslation('Star', TL_FOREHEAD);
    SkinLayerTranslation('Upper Head', TL_FOREHEAD);
end;

//==================================================================================
// Do any special tailoring for specific races.
Procedure TailorRaces(); 
begin
    // Probability of using different tints
    raceInfo[RacenameIndex('FFODeerRace'), MALE].tintProbability[TL_MASK] := 70;
    raceInfo[RacenameIndex('FFODeerRace'), FEMALE].tintProbability[TL_MASK] := 70;

    raceInfo[RacenameIndex('FFOHorseRace'), MALE].tintProbability[TL_MUZZLE] := 60;
    raceInfo[RacenameIndex('FFOHorseRace'), FEMALE].tintProbability[TL_MUZZLE] := 60;
    raceInfo[RacenameIndex('FFOHorseRace'), MALE].tintProbability[TL_NOSE] := 50;
    raceInfo[RacenameIndex('FFOHorseRace'), FEMALE].tintProbability[TL_NOSE] := 50;
  
    AddChildRace('FFOCheetahRace', 'FFOCheetahChildRace');
    AddChildRace('FFODeerRace', 'FFODeerChildRace');
    AddChildRace('FFOFoxRace', 'FFOFoxChildRace');
    AddChildRace('FFOHorseRace', 'FFOHorseChildRace');
    AddChildRace('FFOHyenaRace', 'FFOHyenaChildRace');
    AddChildRace('FFOLionRace', 'FFOLionChildRace');
    AddChildRace('FFOLykaiosRace', 'FFOLykaiosChildRace');
    AddChildRace('FFOOtterRace', 'FFOOtterChildRace');
    AddChildRace('FFOSnekdogRace', 'FFOSnekdogChildRace');
    AddChildRace('FFOTigerRace', 'FFOTigerChildRace');

    CorrelateChildren;
end;

//=========================================================================
// By default, use all layers of all races. Why is it there if not to use?
// Except we may limit the number of layers per NPC so they don't get stupid.
Procedure SetRaceDefaults;
    var el, r: integer;
begin
    // Log(10, '<SetRaceDefaults');
    for r := 0 to masterRaceList.Count-1 do begin
        for el := 0 to tintlayerName.Count-1 do begin
            // Log(10, Format('Setting race default for %s %s', [masterRaceList[r], tintlayerName[el]]));
            raceInfo[r, MALE].tintProbability[el] := 100;
            raceInfo[r, FEMALE].tintProbability[el] := 100;
            raceInfo[r, MALECHILD].tintProbability[el] := 100;
            raceInfo[r, FEMALECHILD].tintProbability[el] := 100;
        end;
    end;
    // Log(10, '>SetRaceDefaults');
end;

//======================================================
// Choose a race for the NPC.
// NPC is not altered.
Function ChooseNPCRace(npc: IwbMainRecord): integer;
var
    assignIndex: integer;
    charClass: integer;
    charRace: string;
    h: integer;
    pointTotal: integer;
    r: integer;
    racename: string;
    theRace: IwbMainElement;
begin
    // Log(5, '<ChooseNPCRace on ' + EditorID(npc));

    Result := -1;

    // Use the assigned race if any.
    assignIndex := npcRaceAssignments.IndexOf(EditorID(npc));
    if assignIndex >= 0 then begin
        theRace := ObjectToElement(npcRaceAssignments.Objects[assignIndex]);
        // Log(5, EditorID(npc) + ' assigned to race ' + EditorID(theRace));
        Result := RaceIndex(theRace);
    end
    else begin
        // Use the target race, if specified.
        Result := masterRaceList.IndexOf(TARGET_RACE);
        if Result < 0 then begin
            // Pick a random race.
            charRace := EditorID(LinksTo(ElementByPath(npc, 'RNAM')));
            charClass := GetNPCClass(npc);

            pointTotal := classProbs[charClass, masterRaceList.Count];
            h := Hash(EditorID(npc), 6795, pointTotal);
            // Log(6, 'Range = ' + IntToStr(pointTotal) + ', hash = ' + IntToStr(h));
            for r := 0 to masterRaceList.Count do begin
                if (h >= classProbsMin[charClass, r]) and (h <= classProbsMax[charClass, r]) then begin
                    Result := r;
                    break;
                end;
            end;
        end;
    end;

    // Log(5, Format('>ChooseNPCRace on %s <- %s',  [EditorID(npc), IfThen(Result >= 0, masterRaceList[Result], 'NO RACE')]));
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
// If the NPC is a child, the actual race set will be the associated child race.
// Returns FALSE if it's a child and there is no associated child race.
Function SetNPCRace(npc: IwbMainRecord; raceIndex: integer): boolean;
var
    race: IwbMainRecord;
    skin: IwbMainRecord;
    raceID: integer;
    sex: integer;
    targFile: IwbFile;
begin
    // Log(5, '<SetNPCRace: ' + EditorID(npc));
    sex := GetNPCSex(npc);
    race := raceInfo[raceIndex, sex].mainRecord;
    if Assigned(race) then begin
        raceID := GetLoadOrderFormID(race);
        
        targFile := GetFile(npc);
        // Log(5, Format('Target race is %s %s / %.8x in file %s', [EditorID(race), SexToStr(sex), raceID, GetFileName(GetFile(race))]));

        SetNativeValue(ElementByPath(npc, 'RNAM'), LoadOrderFormIDtoFileFormID(targFile, raceID));

        skin := LinksTo(ElementByPath(race, 'WNAM'));
        // Log(5, Format('Setting skin to %.8x/%.8x', [integer(GetLoadOrderFormID(skin)), integer(LoadOrderFormIDtoFileFormID(targFile, GetLoadOrderFormID(skin)))]));
        Add(npc, 'WNAM', true);
        SetNativeValue(ElementByPath(npc, 'WNAM'),
            LoadOrderFormIDtoFileFormID(targFile, GetLoadOrderFormID(skin)));

        // Log(5, Format('Set race to %s', [GetElementEditValues(npc, 'RNAM')]));
        result := true;
    end
    else begin
        Err(Format('Cannot set race for %s to %s', [EditorID(npc), masterRaceList[i]]));
        result := false;
    end;

    // Log(5, '>SetNPCRace ->' + EditorID(npc));
end;


//==============================================================
// Choose a random headpart of the given type. 
// Hair is handled separately.
Procedure ChooseHeadpart(npc: IwbMainRecord; hpType: integer);
var 
    hp: IwbMainRecord;
    targFile: IwbFile;
    headparts: IwbContainer;
    slot: IwbElement;
begin
    // Log(4, Format('<ChooseHeadpart: %s - [%d] %s', [EditorID(npc), GetNPCRaceID(npc), EditorID(GetNPCRace(npc))]));
    targFile := GetFile(npc);

    hp := PickRandomHeadpart(EditorID(npc), 113, GetNPCRaceID(npc), GetNPCSex(npc), hpType);

    headparts := ElementByPath(npc, 'Head Parts');
    slot := ElementAssign(headparts, HighInteger, nil, false);
    SetNativeValue(slot, 
        LoadOrderFormIDtoFileFormID(targFile, GetLoadOrderFormID(hp)));

    // Log(4, Format('>ChooseHeadpart: %s <- %s', [EditorID(npc), EditorID(hp)]));
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
    // Log(5, Format('<FindPriorHair: %s in %s', [EditorID(npc), GetFileName(GetFile(npc))]));
    npcMaster := MasterOrSelf(npc);
    npcFileIndex := GetLoadOrder(GetFile(npc));
    // Log(5, 'Found master for NPC in ' + GetFileName(GetFile(npcMaster)));

    priorOverride := Nil;
    // Log(5, Format('Have %d overrides', [integer(OverrideCount(npcMaster))]));
    for i := OverrideCount(npcMaster)-1 downto 0 do begin
        thisOverride := OverrideByIndex(npcMaster, i);
        // Log(5, 'Found override in file ' + GetFileName(GetFile(thisOverride)));
        // Log(5, Format('Checking %d < %d', [GetLoadOrder(GetFile(thisOverride)), npcFileIndex]));
        if GetLoadOrder(GetFile(thisOverride)) < npcFileIndex then begin
            // Log(5, 'Using override in file ' + GetFileName(GetFile(thisOverride)));
            priorOverride := thisOverride;
            break;
        end;
    end;

    if not Assigned(priorOverride) then priorOverride := npcMaster;
    // Log(5, Format('Checking hair in override in file %s', [GetFileName(GetFile(priorOverride))]));

    result := Nil;
    hplist := ElementByPath(priorOverride, 'Head Parts');
    for i := 0 to ElementCount(hplist)-1 do begin
        hp := LinksTo(ElementByIndex(hplist, i));
        // Log(5, Format('Checking for hair %s [%d] %s', [EditorID(hp), i, GetElementEditValues(hp, 'PNAM')]));
        if GetElementEditValues(hp, 'PNAM') = 'Hair' then begin
            result := hp;
            break;
        end;
    end;

    // Log(5, '>FindPriorHair: ' + EditorID(result));
end;

//==============================================================
// Choose hair for a NPC. If possible, hair is matched to the NPC's current hair.
Procedure ChooseHair(npc, oldHair: IwbMainRecord);
var 
    hp: IwbMainRecord;
begin
    // Log(5, Format('<ChooseHair: %s %s', [EditorID(npc), EditorID(oldHair)]));
    if (not Assigned(oldHair)) or StartsText('FFO', EditorID(oldHair)) then begin
        // Log(5, 'Current hair is furry or missing, finding prior hair');
        oldHair := FindPriorHair(npc);
    end;
    if Assigned(oldHair) then begin
        hp := GetFurryHair(GetNPCRaceID(npc), EditorID(oldHair));
        if not Assigned(hp) then
            hp := PickRandomHeadpart(EditorID(npc), 5269, 
                GetNPCRaceID(npc), GetNPCSex(npc), HEADPART_HAIR);

        AssignHeadpart(npc, hp);
    end
    else begin
        // Log(5, 'No old hair, leaving hair alone.');
    end;
    // Log(5, Format('>ChooseHair: %s %s', [EditorID(npc), EditorID(hp)]));
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
    // Log(5, Format('<AssignTint: %s [%s] [%s]', [EditorID(npc), Path(tintOption), Path(tintColor)]));

    color := LinksTo(ElementByPath(tintColor, 'Color'));
    // Log(5, 'Have color ' + EditorID(color));

    facetintLayers := Add(npc, 'Face Tinting Layers', true); // Make sure face tinting layers exists
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
    
    // Log(5, '>AssignTint');
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
    // Log(5, Format('<ChooseTint: %s, %s', [EditorID(npc) , tintlayerName[tintlayer]]));

    race := GetNPCRaceID(npc);
    sex := GetNPCSex(npc);
    prob := raceInfo[race, sex].tintProbability[tintlayer];
    probCheck := Hash(EditorID(npc), seed, 101);
    ind := IfThen(tintlayer = TL_SKIN_TONE, 0, 1);

    if (probCheck <= prob) and (raceInfo[race, sex].tintCount[tintlayer] > 0) then begin

        t := PickRandomTintOption(EditorID(npc), seed, race, sex, tintlayer);
        p := PickRandomColorPreset(EditorID(npc), seed+7989, t, ind);
        // Log(5, 'Selected tint preset ' + Path(p));
        AssignTint(npc, t, p);
    end
    else begin
        // Log(5, Format('Probability check failed, no assignment: %d > %d, layer count %d', [integer(probCheck), integer(prob), integer(raceInfo[race, sex].tintCount[tintlayer])]));
    end;
    
    // Log(5, '>ChooseTint');
end;

//=================================================================================
// Set the tint layer to the named color.
// If the tint layer has several options (e.g. TL_MASK), choose one at random.
Procedure SetTintlayerColor(npc: IwbMainRecord; tintLayer: integer; targetColor: string; seed: integer);
var
    color: IwbMainRecord;
    colorList: IwbElement;
    colorPreset: IwbElement;
    i: integer;
    layerOption: integer;
    race: integer;
    sex: integer;
begin
    // Log(5, Format('<SetTintlayerColor: %s %s <- %s', [EditorID(npc), tintlayerName[tintLayer], targetColor]));
    race := GetNPCRaceID(npc);
    sex := GetNPCSex(npc);
    layerOption := Hash(EditorID(npc), seed, raceInfo[race, sex].tintCount[tintLayer]);
    colorList := ElementByPath(
        raceInfo[race, sex].tints[tintLayer, layerOption].element, 'TTEC'
    );

    for i := 0 to ElementCount(colorList) do begin
        colorPreset := ElementByIndex(colorList, i);
        color := LinksTo(ElementByPath(colorPreset, 'Color'));
        if EditorID(color) = targetColor then begin
            AssignTint(npc, raceInfo[race, sex].tints[tintLayer, layerOption].element, colorPreset);
            break;
        end;
    end;
    // Log(5, '>SetTintlayerColor');
end;


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
    // // Log(9, DisplayName(npc) + ' size = ' 
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

//================================================================
// Whitetail deer.
Procedure MakeDeerWhitetail(npc: IwbMainRecord);
var
    h: integer;
begin
    h := Hash(EditorID(npc), 8484, 6);
    case h of
        0: SetTintlayerColor(npc, TL_SKIN_TONE, 'FFOFurGingerL', 2988);
        1: SetTintlayerColor(npc, TL_SKIN_TONE, 'FFOFurBrown', 510);
        2: SetTintlayerColor(npc, TL_SKIN_TONE, 'FFOFurTan', 7114);
        3: SetTintlayerColor(npc, TL_SKIN_TONE, 'FFOFurGinger', 1874);
        4: SetTintlayerColor(npc, TL_SKIN_TONE, 'FFOFurBrownL', 3223);
        5: SetTintlayerColor(npc, TL_SKIN_TONE, 'FFOFurRusset', 5237);
    end;
end;

//================================================================
// Set up a realistic deer.
Procedure FurrifyDeer(npc, hair: IwbMainRecord);
var
    deerType: integer;
begin
    SetWeight(npc, 2, 1, 1);
    ChooseHair(npc, hair);
    ChooseHeadpart(npc, HEADPART_EYES);
    ChooseHeadpart(npc, HEADPART_FACE);

    deerType := Hash(EditorID(npc), 9477, 5);
    case deerType of
        0: MakeDeerWhitetail(npc);
        1: MakeDeerWhitetail(npc);
        2: MakeDeerWhitetail(npc);
        3: MakeDeerWhitetail(npc);
        4: MakeDeerWhitetail(npc);
    end;
    // ChooseHeadpart(npc, HEADPART_EYEBROWS);
    // ChooseTint(npc, TL_SKIN_TONE, 9523);
    // ChooseTint(npc, TL_MASK, 2188);
    // ChooseTint(npc, TL_MUZZLE, 9487);
    // ChooseTint(npc, TL_EAR, 552);
    // ChooseTint(npc, TL_NOSE, 6529);
end;
//================================================================
// Special tailoring for lions. 50% of the males get manes.
Procedure FurrifyLion(npc, hair: IwbMainRecord);
begin
    // Log(4, '<FurrifyLion: ' + EditorID(npc));
    SetWeight(npc, 1, 2, 1);
    ChooseHeadpart(npc, HEADPART_FACE);
    ChooseHeadpart(npc, HEADPART_EYES);

    if Assigned(lionMane) and 
            ((Hash(EditorID(npc), 9203, 100) > 50) 
                or ContainsText(EditorID(npc), 'PrestonGarvey')
            ) then begin
        // Log(4, Format('Assigning mane: "%s"', [EditorID(lionMane)]));
        AssignHeadpart(npc, lionMane);
    end
    else
        ChooseHair(npc, hair);

    ChooseHeadpart(npc, HEADPART_EYEBROWS);
    ChooseTint(npc, TL_SKIN_TONE, 6351);
    ChooseTint(npc, TL_NOSE, 1140);
    // Log(4, '>FurrifyLion');
end;

Procedure FurrifyNPC(npc, hair: IwbMainRecord);
var
    r: integer;
begin
    // Log(4, '<FurrifyNPC: ' + EditorID(npc));
    r := ChooseNPCRace(npc);
    if SetNPCRace(npc, r) then begin
        case r of 
            RACE_DEER: FurrifyDeer(npc, hair);
            RACE_LION: FurrifyLion(npc, hair);
        else 
            begin
            ChooseHeadpart(npc, HEADPART_FACE);
            ChooseHeadpart(npc, HEADPART_EYES);
            ChooseHair(npc, hair);
            ChooseHeadpart(npc, HEADPART_EYEBROWS);
            ChooseTint(npc, TL_SKIN_TONE, 9523);
            ChooseTint(npc, TL_MASK, 2188);
            ChooseTint(npc, TL_MUZZLE, 9487);
            ChooseTint(npc, TL_EAR, 552);
            ChooseTint(npc, TL_NOSE, 6529);
            end;
        end;
    end;

    // Log(4, '>FurrifyNPC');
end;

//======================================================================
// Furrify a single NPC.
// This is assumed to be the winning override prior to FFO. (To do all NPCs
// start with the last file in the load order and work backwards, skipping NPCs
// that have overrides.)
// If the NPC already exists in the target mod, that definition will be overwritten.
// Returns the new furry npc.
Function MakeFurryNPC(npc: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
var
    furryNPC: IwbMainRecord;
    npcHair: IwbMainRecord;
begin
    // Log(5, Format('<MakeFurryNPC %s -> %s', [EditorID(npc), GetFileName(targetFile)]));

    if furrifiedNPCs.IndexOf(EditorID(npc)) < 0 then begin
        furryNPC := CreateNPCOverride(npc, targetFile);
        npcHair := CleanNPC(furryNPC);
        FurrifyNPC(furryNPC, npcHair);
        furrifiedNPCs.Add(EditorID(npc));
        Result := furryNPC;
    end
    else
        Result := WinningOverride(npc);

    // Log(5, '>MakeFurryNPC');
end;


//=========================================================================
// Create the new patch mod if it doesn't exist alerady.
Function CreateOverrideMod(filename: string): IwbFile;
var
    f: integer;
    fn: string;
    i: integer;
begin
    // Log(3, '<CreateOverrideMod ' + filename);
    f := -1;
    for i := 0 to FileCount-1 do begin
        if SameText(GetFileName(FileByIndex(i)), filename) then begin
            f := i;
            break;
        end;
    end;
    if f >= 0 then
        Result := FileByIndex(f)
    else begin
        Result := AddNewFileName(filename);
        patchFileCreated := true;
    end;

    if patchFileCreated then begin
        AddRecursiveMaster(Result, FileByIndex(0));

        for i := 0 to FileCount-1 do begin
            fn := GetFileName(FileByIndex(i));
            if StartsText('DLC', fn) then 
                AddRecursiveMaster(Result, FileByIndex(i))
            else if SameTExt(fn, 'FurryFallout.esp') then 
                AddRecursiveMaster(Result, FileByIndex(i))
            else if SameText(fn, 'FurryFalloutDLC.esp') then
                AddRecursiveMaster(Result, FileByIndex(i));
        end;
    end;
    // Log(3, '>CreateOverrideMod');

end;

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
    // Log(5, '<IsValidNPC: ' + EditorID(npc));
    result := 1;
    // Must be an NPC
    // Log(5, 'Signature: ' + Signature(npc));
    if Signature(npc) <> 'NPC_' then
        result := 0;

    if result > 0 then begin
        // Must not be overridden--we only work with the latest version
        // Log(5, 'Overrides: ' + IntToStr(OverrideCount(npc)));
        if OverrideCount(npc) > 0 then 
            result := 0;
    end;

    if result > 0 then begin
        // Must be a furrifiable race
        race := GetNPCRace(npc);
        if (masterRaceList.IndexOf(EditorID(race)) < 0) and (EditorID(race) <> 'HumanRace') then
            result := 0;
    end;
    
    if result > 0 then begin
        // Must not be any of the player records, or Shaun--those are in the player race files
        // Log(5, 'Is player: ' + IntToStr(playerIDs.IndexOf(EditorID(npc))));
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
        if GetElementEditValues(npc, 'ACBS - Configuration\Use Template Actors\Traits') = '1' then
            result := 2;
    end;

    // Log(5, '>IsValidNPC: ' + IntToStr(result));
end;

//========================================================
// Set everything up.
Procedure InitializeFurrifier;
begin
    InitializeAssetLoader;
    SetTintLayerTranslations;
    SetRaceProbabilities;

    LoadRaceAssets;
    SetRaceDefaults;
    TailorRaces;

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

    patchFileCreated := false;
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
    AddMessage('Running on ' + wbAppName);
	AddMessage('----------------------------------------------------------');
	AddMessage('');

	AddMessage('----------------------------------------------------------');
    if USE_SELECTION then 
        AddMessage('Furrifying selected NPCs only')
    else 
        AddMessage('Furrifying selected NPCs only');
    
    if length(TARGET_RACE) > 0 then
        AddMessage('All affected NPCs will be changed to ' + TARGET_RACE);

    if length(GHOUL_RACE) > 0 then
        AddMessage('Ghouls will be changed to ' + GHOUL_RACE)
    else
        AddMessage('Ghouls will not be changed');

    AddMessage('Patch file is ' + patchfileName);
	AddMessage('----------------------------------------------------------');

    LOGLEVEL := 1;

    patchFile := CreateOverrideMod(patchfileName);
    furryCount := 0;

    InitializeFurrifier;
end;

// Process selected NPCs.
// If we are using the selection, they get furrified here.
function Process(entity: IwbMainRecord): integer;
var
    win: IwbMainRecord;
begin
    LOGLEVEL := 5;

    if not USE_SELECTION then exit;
    win := WinningOverride(entity);

    // Log(2, Format('Furrifying %s in %s', [EditorID(win), GetFileName(GetFile(win))]));

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
    f, n: integer;
    npc: IwbMainRecord;
    npcList: IwbContainer;
begin
    if not USE_SELECTION then begin
        for f := 0 to FileCount-1 do begin
            if (f < FileCount-1) or (not patchFileCreated) then begin
                // Don't check the NPCs in the patch file if we created it on this run.
                // Log(2, 'File ' + GetFileName(FileByIndex(f)));
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
        end;
    end;

    LOGLEVEL := 1;

    // If we furrified the ghouls, then any headgear added by FFO that supports Snekdogs (or
    // whatever race we are turning ghouls into) needs to be modified to add the ghoul race.
    if length(GHOUL_RACE) > 0 then begin
        AddRaceToAllArmor(patchFile, 
            FindAsset(Nil, 'RACE', 'GhoulRace'), // this race must be added to
            FindAsset(Nil, 'RACE', GHOUL_RACE)); // ARMA records that allow this race
    end;

    ShutdownFurrifier;
end;
end.