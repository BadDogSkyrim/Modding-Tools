{
  NPC Furry Patch Builder
  Created by Bad Dog based on code by matortheeternal
  
  Creates a NPC furry patch for a load order.
  
  
}

unit FFO_Furrifier;

interface

implementation

uses BDScriptTools, BDAssetLoaderFO4, xEditAPI, Classes, SysUtils, StrUtils, Windows, mteFunctions;


//======================================================
// Define race probabilities for the different NPC classes,
// also for some specific NPCs. Must be called early because 
// this routine defines the furry races.
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
    SetClassProb(CLASS_CAIT, 'FFODeerRace', 100);
    SetClassProb(CLASS_DANSE, 'FFOLykaiosRace', 100);
    SetClassProb(CLASS_DEACON, 'FFOHorseRace', 100);
    SetClassProb(CLASS_GAGE, 'FFOHyenaRace', 100);
    SetClassProb(CLASS_LONGFELLOW, 'FFOOtterRace', 100);
    SetClassProb(CLASS_MACCREADY, 'FFOCheetahRace', 100);
    SetClassProb(CLASS_PIPER, 'FFOFoxRace', 100);
    SetClassProb(CLASS_X688, 'FFOTigerRace', 100);

    // Specific NPCs or families. Ensures relatives and older/younger
    // versions of the same NPC have the same race.
    SetClassProb(CLASS_BOBROV, 'FFODeerRace', 100);
    SetClassProb(CLASS_CABOT, 'FFOCheetahRace', 100);
    SetClassProb(CLASS_DELUCA, 'FFODeerRace', 100);
    SetClassProb(CLASS_KELLOGG, 'FFOTigerRace', 100);
    SetClassProb(CLASS_KYLE, 'FFOFoxRace', 100);
    SetClassProb(CLASS_PEMBROKE, 'FFOHorseRace', 100);

    // Specific NPCs
    AssignNPCRace('MamaMurphy', 'FFOLionRace'); // Her hat is tailored to the lioness head
    AssignNPCRace('DLC04Mason', 'FFOHorseRace'); // I just like him this way

    CalcClassTotals();
end;

//==================================================================================
// Do any special tailoring of probabilities for specific races.
Procedure TailorRaces(); 
begin
    // raceInfo[RacenameIndex('FFODeerRace'), MALE].tintProbability[TL_MASK] := 70;
    // raceInfo[RacenameIndex('FFODeerRace'), FEMALE].tintProbability[TL_MASK] := 70;

    // raceInfo[RacenameIndex('FFOHorseRace'), MALE].tintProbability[TL_MUZZLE] := 60;
    // raceInfo[RacenameIndex('FFOHorseRace'), FEMALE].tintProbability[TL_MUZZLE] := 60;
    // raceInfo[RacenameIndex('FFOHorseRace'), MALE].tintProbability[TL_NOSE] := 50;
    // raceInfo[RacenameIndex('FFOHorseRace'), FEMALE].tintProbability[TL_NOSE] := 50;
  
end;

//=========================================================================
// By default, use all layers of all races. Why is it there if not to use?
// Except we may limit the number of layers per NPC so they don't get stupid.
Procedure SetRaceDefaults;
    var el, r: integer;
begin
    Log(10, '<SetRaceDefaults');
    for r := 0 to masterRaceList.Count-1 do begin
        for el := 0 to tintlayerName.Count-1 do begin
            Log(10, Format('Setting race default for %s %s', [masterRaceList[r], tintlayerName[el]]));
            raceInfo[r, MALE].tintProbability[el] := 100;
            raceInfo[r, FEMALE].tintProbability[el] := 100;
        end;
    end;
    Log(10, '>SetRaceDefaults');
end;

//======================================================
// Choose a race for the NPC.
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
    Log(5, '<ChooseNPCRace on ' + EditorID(npc));

    Result := -1;

    assignIndex := npcRaceAssignments.IndexOf(EditorID(npc));
    if assignIndex >= 0 then begin
        theRace := ObjectToElement(npcRaceAssignments.Objects[assignIndex]);
        Log(5, EditorID(npc) + ' assigned to race ' + EditorID(theRace));
        Result := RaceIndex(theRace);
    end
    else begin
        charRace := EditorID(LinksTo(ElementByPath(npc, 'RNAM')));
        charClass := GetNPCClass(npc);

        pointTotal := classProbs[charClass, masterRaceList.Count];
        h := Hash(EditorID(npc), 1979, pointTotal);
        Log(6, 'Range = ' + IntToStr(pointTotal) + ', hash = ' + IntToStr(h));
        for r := 0 to masterRaceList.Count do begin
            if (h >= classProbsMin[charClass, r]) and (h <= classProbsMax[charClass, r]) then begin
                Result := r;
                break;
            end;
        end;
    end;
    if (Result >= 0) and (Result < masterRaceList.Count) then 
        racename := masterRaceList[Result]
    else
        racename := 'NO RACE';
    Log(5, '>ChooseNPCRace on ' + EditorID(npc) + ' = ' + racename);
end;


//=====================================================================
// Clean NPC of any of the elements we will furrify.
Procedure CleanNPC(npc: IwbMainRecord);
var
    elemList: IwbContainer;
    i: integer;
begin
    Remove(ElementByPath(npc, 'MSDK - Morph Keys'));
    Remove(ElementByPath(npc, 'MSDV - Morph Values'));
    Remove(ElementByPath(npc, 'Face Morphs'));

    Remove(ElementByPath(npc, 'FTST'));
    Remove(ElementByPath(npc, 'WNAM'));

    elemList := ElementByPath(npc, 'Head Parts');
    for i := ElementCount(elemList)-1 downto 0 do begin
            RemoveByIndex(elemList, i, true);
    end;

    elemList := ElementByPath(npc, 'Face Tinting Layers');
    for i := ElementCount(elemList)-1 downto 0 do begin
            RemoveByIndex(elemList, i, true);
    end;

    // Set morph intensity to 1 for all furries
    SetNativeValue(ElementByPath(npc, 'FMIN - Facial Morph Intensity'), 1.0);
end;

Procedure SetNPCRace(npc: IwbMainRecord; raceIndex: integer);
var
    race: IwbMainRecord;
    skin: IwbMainRecord;
    raceID: integer;
    targFile: IwbFile;
begin
    Log(5, '<SetNPCRace' + EditorID(npc));
    race := ObjectToElement(masterRaceList.Objects[raceIndex]);
    raceID := GetLoadOrderFormID(race);
    targFile := GetFile(npc);
    Log(5, Format('Target race is %s / %.8x in file %s', 
        [EditorID(race), raceID, GetFileName(GetFile(race))]));

    SetNativeValue(ElementByPath(npc, 'RNAM'), LoadOrderFormIDtoFileFormID(targFile, raceID));

    skin := LinksTo(ElementByPath(race, 'WNAM'));
    Log(5, Format('Setting skin to %.8x/%.8x', [
        integer(GetLoadOrderFormID(skin)), 
        integer(LoadOrderFormIDtoFileFormID(targFile, GetLoadOrderFormID(skin)))
        ]));
    Add(npc, 'WNAM', true);
    SetNativeValue(ElementByPath(npc, 'WNAM'),
        LoadOrderFormIDtoFileFormID(targFile, GetLoadOrderFormID(skin)));

    Log(5, Format('Set race to %s', [GetElementEditValues(npc, 'RNAM')]));
    
    Log(5, '>SetNPCRace' + EditorID(npc));
end;


Procedure ChooseHeadpart(npc: IwbMainRecord; hpType: integer);
var 
    hp: IwbMainRecord;
    targFile: IwbFile;
    headparts: IwbContainer;
    slot: IwbElement;
begin
    targFile := GetFile(npc);
    hp := PickRandomHeadpart(EditorID(npc), 113, GetNPCRaceID(npc), GetNPCSex(npc), hpType);

    headparts := ElementByPath(npc, 'Head Parts');
    slot := ElementAssign(headparts, HighInteger, nil, false);
    SetNativeValue(slot, 
        LoadOrderFormIDtoFileFormID(targFile, GetLoadOrderFormID(hp)));
end;

//=================================================================
// Pick apart a color value
Function RedPart(rgbVal: UInt32): UInt32;
begin
    result := rgbVal and $FF;
end;

Function GreenPart(rgbVal: UInt32): UInt32;
begin
    result := (rgbVal shr 8) and $FF;
end;

Function BluePart(rgbVal: UInt32): UInt32;
begin
    result := (rgbVal shr 16) and $FF;
end;

Function AlphaPart(rgbVal: UInt32): single;
begin
    result := ((rgbVal shr 24) and $FF)/255.0;
end;

//============================================================
// Choose and assign a tint for a NPC.
// prob is the probability (0-100) that a tint will be picked.
Procedure ChooseTint(npc: IwbMainRecord; tintlayer: integer; seed: integer);
var
    color: IwbMainRecord;
    colorval: UInt32;
    facetintLayers: IwbElement;
    layer: IwbElement;
    p: IwbElement;
    prob: integer;
    probCheck: integer;
    race: integer;
    sex: integer;
    t: integer;
    tend: IwbElement;
    teti: IwbElement;
begin
    Log(5, Format('<ChooseTint: %s, %s', [EditorID(npc) , tintlayerName[tintlayer]]));

    race := GetNPCRaceID(npc);
    sex := GetNPCSex(npc);
    prob := raceInfo[race, sex].tintProbability[tintlayer];
    probCheck := Hash(EditorID(npc), seed, 101);

    if (probCheck <= prob) and (raceInfo[race, sex].tintCount[tintlayer] > 0) then begin

        p := PickRandomTintPreset(EditorID(npc), seed, race, sex, tintlayer, 0);
        Log(5, 'Selected tint preset ' + PathName(p));
        t := Hash(EditorID(npc), seed, raceInfo[race, sex].tintCount[tintLayer]);
        color := LinksTo(ElementByPath(p, 'Color'));
        Log(5, 'Have color ' + EditorID(color));

        facetintLayers := Add(npc, 'Face Tinting Layers', true); // Make sure face tinting layers exists
        // facetintLayers := ElementByPath(npc, 'Face Tinting Layers');
        layer := ElementAssign(facetintLayers, HighInteger, Nil, false);
        teti := Add(layer, 'TETI', True);
        SetElementEditValues(teti, 'Data Type', 'Value/Color');
        SetElementNativeValues(teti, 'Index', 
            GetElementNativeValues(raceInfo[race, sex].tints[tintLayer, t].element, 
                'TETI\Index'));
        
        tend := Add(layer, 'TEND', true);
        SetElementEditValues(tend, 'Value', GetElementEditValues(p, 'Alpha'));

        colorval := GetElementNativeValues(color, 'CNAM');
        SetElementNativeValues(tend, 'Color\Red', RedPart(colorval));
        SetElementNativeValues(tend, 'Color\Green', GreenPart(colorval));
        SetElementNativeValues(tend, 'Color\Blue', BluePart(colorval));
        SetElementNativeValues(tend, 'Template Color Index', GetElementNativeValues(p, 'Template Index'));

        if tintlayer = TL_SKIN_TONE then begin
            SetElementNativeValues(npc, 'QNAM - Texture lighting\Red', RedPart(colorval));
            SetElementNativeValues(npc, 'QNAM - Texture lighting\Green', GreenPart(colorval));
            SetElementNativeValues(npc, 'QNAM - Texture lighting\Blue', BluePart(colorval));
            SetElementNativeValues(npc, 'QNAM - Texture lighting\Alpha', GetElementNativeValues(p, 'Alpha'));
        end;
    end
    else
        Log(5, Format('Probability check failed, no assignment: %d > %d', 
            [integer(probCheck), integer(prob)]));
    
    Log(5, '>ChooseTint');
end;


//======================================================================
// Furrify a single NPC.
// This is assumed to be the winning override prior to FFO. (To do all NPCs
// start with the last file in the load order and work backwards, skipping NPCs
// that have overrides.)
// If the NPC already exists in the target mod, that definition will be overwritten.
// Returns the new furry npc.
Function FurrifyNPC(npc: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
var
    furryNPC: IwbMainRecord;
    r: integer;
    // s: integer;
begin
    Log(5, Format('<FurrifyNPC %s -> %s', [EditorID(npc), GetFileName(targetFile)]));

    AddRecursiveMaster(targetFile, GetFile(npc));
    furryNPC := wbCopyElementToFile(npc, targetFile, False, True);
    CleanNPC(furryNPC);

    // s := GetNPCSex(npc);
    r := ChooseNPCRace(npc);
    SetNPCRace(furryNPC, r);
    ChooseHeadpart(furryNPC, HEADPART_FACE);
    ChooseHeadpart(furryNPC, HEADPART_EYES);
    ChooseHeadpart(furryNPC, HEADPART_HAIR);
    ChooseHeadpart(furryNPC, HEADPART_EYEBROWS);
    ChooseTint(furryNPC, TL_SKIN_TONE, 9523);
    ChooseTint(furryNPC, TL_MASK, 2188);
    ChooseTint(furryNPC, TL_MUZZLE, 9487);
    ChooseTint(furryNPC, TL_EAR, 552);
    ChooseTint(furryNPC, TL_NOSE, 6529);
    Result := furryNPC;
    Log(5, '>FurrifyNPC')
end;

//=========================================================================
// Create the new patch mod.
Function CreateOverrideMod(filename: string): IwbFile;
var
    f: integer;
    fn: string;
    i: integer;
begin
    Log(3, '<CreateOverrideMod ' + filename);
    f := -1;
    for i := 0 to FileCount-1 do begin
        if SameText(GetFileName(FileByIndex(i)), filename) then begin
            f := i;
            break;
        end;
    end;
    if f >= 0 then
        Result := FileByIndex(f)
    else 
        Result := AddNewFileName(filename);

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
    Log(3, '>CreateOverrideMod');

end;

Procedure InitializeFurrifier;
begin
    InitializeAssetLoader;
    SetRaceProbabilities;
    LoadRaceAssets;
    SetRaceDefaults;
    TailorRaces;
end;

end.