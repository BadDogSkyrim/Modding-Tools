
{

  Hotkey: Ctrl+Alt+D

}
unit BDFurrySkyrim;
interface
implementation

uses BDFurrySkyrim_Preferences, BDArmorFixup, BDFurrySkyrimTools, BDScriptTools, xEditAPI, Classes,
    SysUtils, StrUtils, Windows;

const
    FURRIFIER_VERSION = 'X0.01';
    SHOW_OPTIONS_DIALOG = False;
    PATCH_FILE_NAME = 'YASNPCPatch.esp'; // Set to whatever
    USE_SELECTION = FALSE;           // FALSE or TRUE
    FURRIFY_ARMOR = FALSE;         
    FURRIFY_NPCS_MALE = TRUE;
    FURRIFY_NPCS_FEM = FALSE;
    SHOW_HAIR_ASSIGNMENT = TRUE;
    MAX_TINT_LAYERS = 8; // Max tint layers to apply to a NPC
    LOG_ARMOR = 0;
    LOG_NPCS = 15;

    IS_NONE = 0;
    IS_FURRIFIABLE = 1;
    IS_FURRY = 2;
    IS_ALREADY_TESTED = 4;

var
    processedNPCcount: Integer;
    addonFurrifiedRaces: TStringList;
    hairAssignments: TStringList;


{============================================================================
Copy an element from source to target if it exists in the source.
}
procedure CopyElementIf(dst, src: IwbElement; name: string);
begin
    if ElementExists(src, name) then begin
        Add(dst, name, True);
        ElementAssign(ElementByPath(dst, name), LowInteger, ElementByPath(src, name), false);
    end;
end;


{============================================================================
Make a vanilla race furry by copying over appearance data from the furry race.
Also pre-load race info.
}
procedure FurrifyRace(vanillaRaceName: string; furryRace: IwbMainRecord);
var
    furrifiedRace: IwbMainRecord;
    vanillaRace: IwbMainRecord;
begin
    if LOGGING then LogEntry2(1, 'FurrifyRace', vanillaRaceName, Name(furryRace));
    vanillaRace := WinningOverride(FindAsset(Nil, 'RACE', vanillaRaceName));
    // LoadRaceTints(vanillaRace);

    if LOGGING then LogD(Format('Found race %s in file %s', [Name(vanillaRace), GetFileName(GetFile(vanillaRace))]));
    if LOGGING then LogD('Overriding in ' + GetFileName(targetFile));
    AddRecursiveMaster(targetFile, GetFile(vanillaRace));
    AddRecursiveMaster(targetFile, GetFile(furryRace));
    
    if LOGGING then LogD('Source RNAM value is ' + GetElementEditValues(furryRace, 'RNAM'));
    furrifiedRace := wbCopyElementToFile(vanillaRace, targetFile, False, True);

    CopyElementIf(furrifiedRace, furryRace, 'RNAM'); 
    CopyElementIf(furrifiedRace, furryRace, 'NAM8');
    CopyElementIf(furrifiedRace, furryRace, 'WNAM');
    CopyElementIf(furrifiedRace, furryRace, 'Head Data');

    // ElementAssign(ElementByPath(furrifiedRace, 'Head Data\Male Head Data'), LowInteger, Nil, false);
    // ElementAssign(ElementByPath(furrifiedRace, 'WNAM'), LowInteger, ElementByPath(furryRace, 'WNAM'), false);
    // SetElementEditValues(furrifiedRace, 'RNAM', GetElementEditValues(furryRace, 'RNAM'));
    // ElementAssign(ElementByPath(furrifiedRace, 'Head Data\Male Head Data'), 
    //     LowInteger, 
    //     ElementByPath(furryRace, 'Head Data\Male Head Data'), 
    //     false);
    
    // LoadRaceTints(furryRace);

    if LOGGING then LogExitT('FurrifyRace');
end;


{==================================================================
Change all redefined races to their furry equivalent race.
}
procedure FurrifyAllRaces;
var i, j: integer;
begin
    for i := 0 to raceAssignments.Count-1 do begin
        FurrifyRace(raceAssignments[i], ObjectToElement(raceAssignments.objects[i]));
    end;
end;


{==================================================================
Add the given label to the curNPClabels IF it does not conflict with any existing labels.
}
procedure CurNPCAddLabel(newLabel: string);
var i: integer;
begin
    for i := 0 to curNPClabels.Count-1 do begin
        if LabelsConflict(newLabel, curNPClabels[i]) then
            exit;
    end;
    curNPClabels.Add(newLabel);
end;


{==================================================================
Add any labels that describe the current NPC--but don't add labels that conflict with
labels already there.
}
procedure CurNPCLoadLabels;
var
    voice: string;
    outfit: string;
begin
    voice := GetElementEditValues(curNPC, 'VTCK');
    outfit := GetElementEditValues(curNPC, 'DOFT');

    if ContainsStr(voice, 'Emperor') or ContainsStr(voice, 'Ulfric') 
        or ContainsStr(outfit, 'Jarl') or ContainsStr(outfit, 'FineClothes')
    then CurNPCAddLabel('NOBLE');

    if ContainsStr(voice, 'Young') 
    then curNPClabels.Add('YOUNG');

    if ContainsStr(voice, 'Old') 
    then curNPClabels.Add('OLD');

    if ContainsStr(voice, 'Forsworn')
    then curNPClabels.Add('FEATHERS');

    if ContainsStr(voice, 'Commander') or ContainsStr(voice, 'Soldier') or ContainsStr(voice, 'Guard')
        or ContainsStr(outfit, 'PenitusOculatus')
    then curNPClabels.Add('MILITARY');

    if ContainsStr(outfit, 'Farmer') or ContainsStr(outfit, 'Forsworn') or ContainsStr(outfit, 'Bandit')
        // or CurNPCHasTintLayer('Dirt')
    then curNPClabels.Add('MESSY');

    if ContainsStr(outfit, 'Tavern') or ContainsStr(outfit, 'College')
    then curNPClabels.Add('NEAT');

    if ContainsStr(outfit, 'Warlock') or ContainsStr(outfit, 'Bandit') 
    then curNPClabels.Add('BOLD');

    // TODO: If wearing outfit with 'ClothingRich' keyword, add NOBLE
    // TODO: If wearing outfit with 'ClothingPoor [KYWD:000A865C]' keyword, add MESSY
    // TODO: If complexion is older, add OLD
    // TODO: If race is Elder, add OLD
end;


{==================================================================
Determine whether the headpart given by index has any labels that conflict with the current NPC.
}
function HeadpartHasExcludedLabels(hpIdx: integer): boolean;
var
    haveNeat: boolean;
    haveMilitary: boolean;
    haveNoble: boolean;
    haveMessy: boolean;
    haveFunky: boolean;
    haveMane: boolean;
    haveFeathers: boolean;
    haveElaborate: boolean;
begin
    // TODO: Rewrite this to use the "LabelsConflict" routine
    haveNeat := (curNPClabels.IndexOf('NEAT') >= 0) or (headpartlabels.objects[hpIdx].IndexOf('NEAT') >= 0);
    haveMilitary := (curNPClabels.IndexOf('MILITARY') >= 0) or (headpartlabels.objects[hpIdx].IndexOf('MILITARY') >= 0);
    haveNoble := (curNPClabels.IndexOf('NOBLE') >= 0) or (headpartlabels.objects[hpIdx].IndexOf('NOBLE') >= 0);
    haveMessy := (curNPClabels.IndexOf('MESSY') >= 0) or (headpartlabels.objects[hpIdx].IndexOf('MESSY') >= 0);
    haveFunky := (curNPClabels.IndexOf('FUNKY') >= 0) or (headpartlabels.objects[hpIdx].IndexOf('FUNKY') >= 0);
    haveMane := (curNPClabels.IndexOf('MANE') >= 0) or (headpartlabels.objects[hpIdx].IndexOf('MANE') >= 0);
    haveFeathers := (curNPClabels.IndexOf('FEATHERS') >= 0) or (headpartlabels.objects[hpIdx].IndexOf('FEATHERS') >= 0);
    haveFeathers := (curNPClabels.IndexOf('ELABORATE') >= 0) or (headpartlabels.objects[hpIdx].IndexOf('ELABORATE') >= 0);

    result := (haveNeat and haveMessy) 
        or (haveMilitary and haveMessy)
        or (haveMilitary and haveFunky)
        or (haveMilitary and haveElaborate)
        or (haveMilitary and haveFeathers)
        or (haveNoble and haveMessy)
        or (haveNoble and haveFunky)
        or (haveMane and haveMessy);
end;


{==================================================================
Determine how well headpart labels match the current NPC labels.
Every match increases the score, every label that isn't matched decreases the score.
Conflicting labels generate a score of -1000.
}
function CalculateLabelMatchScore(hpLabelIdx: integer): integer;
var
    i, j: integer;
    score: integer;
begin
    score := 0;

    for i := 0 to curNPClabels.Count - 1 do begin
        if headpartLabels.objects[hpLabelIdx].IndexOf(curNPClabels[i]) >= 0 then
            Inc(score) // Increase score for each match
        else
            Dec(score); // Decrease score for each non-match
        for j := 0 to headpartLabels.objects[hpLabelIdx].Count -1 do begin
            if LabelsConflict(curNPClabels.strings[i], headpartLabels.objects[hpLabelIdx].strings[j]) then 
                score := -1000;
        end;
    end;

    if LOGGING then LogT(Format('CalculateLabelMatchScore %s ~ %s = %d', [curNPCalias, headpartLabels.strings[hpLabelIdx], score]));
    result := score;
end;


{====================================================================
Find the best headpart match using labels. Current NPC labels are in curNPClabels.
Headpart returned will be of same type as oldHeadpart and will work for the NPC's race.
}
function CurNPCBestHeadpartMatch(const oldHeadpart: IwbMainRecord): IwbMainRecord;
var
    bestMatches: TStringList;
    bestMatchScore: integer;
    equivIdx: integer;
    hpIdx: integer;
    hplist: TStringList;
    hpInRaceIdx: integer;
    hpRaceIdx: integer;
    hpType: string;
    i, j: integer;
    labelIdx: integer;
    matchScore: integer;
    newHP: IwbMainRecord;
    raceIdx: integer;
    thisHPname: string;
begin
    if LOGGING then LogEntry1(10, 'CurNPCBestHeadpartMatch', Name(oldHeadpart));

    result := Nil;
    bestMatchScore := -1000;
    bestMatches := TStringList.Create;
    hpType := StrToHeadpart(GetElementEditValues(oldHeadpart, 'PNAM'));

    equivIdx := headpartEquivalents.IndexOf(EditorID(oldHeadpart));
    if equivIdx >= 0 then begin
        // Have headpart equivalents. They all go on the options list and we don't use labels.
        hplist := headpartEquivalents.objects[equivIdx];
        for hpIdx := 0 to hplist.count-1 do begin
            thisHPName := EditorID(ObjectToElement(hplist.objects[hpIdx]));
            hpRaceIdx := raceHeadparts[hpType, curNPCsex].IndexOf(EditorID(curNPCRace));
            hpInRaceIdx := -1;
            if hpRaceIdx >= 0 then 
                hpInRaceIdx := raceHeadparts[hpType, curNPCsex].objects[hpRaceIdx].IndexOf(thisHPname);
            if LOGGING then LogD(Format('Found headpart equivalent %d: %s (%s, %s, %s)', 
                [hpInRaceIdx,
                thisHPname,
                HeadpartToStr(hpType), 
                SexToStr(curNPCsex),
                EditorID(curNPCrace)]));
                // Can use this headpart on this NPC.
            if hpInRaceIdx >= 0 then
                bestMatches.AddObject(EditorID(ObjectToElement(hplist.objects[hpIdx])), 
                    hplist.objects[hpIdx]);
        end;
        bestMatchScore := 1000;
    end
    else begin
        // No equivalents, find best match by labels.
        if LOGGING then LogD('NPC labels ' + curNPClabels.CommaText);
        hpRaceIdx := raceHeadparts[hpType, curNPCsex].IndexOf(EditorID(curNPCrace));
        if hpRaceIdx >= 0 then begin
            // Have at least one HP of this type for this sex and race.
            // Find the ones with the highest score.
            hplist := raceHeadparts[hpType, curNPCsex].objects[hpRaceIdx];
            for hpIdx := 0 to hplist.count-1 do begin
                thisHPname := hplist.strings[hpIdx];
                labelIdx := headpartLabels.IndexOf(thisHPname);
                if labelIdx < 0 then begin
                    // No assigned labels, just take a score of 0
                    if LOGGING then LogD(Format('Headpart not found in headpartLabels: %s', [thisHPname]));
                    matchScore := 0;
                end
                else begin
                    // Assigned labels, determine score
                    matchScore := CalculateLabelMatchScore(labelIdx);
                end;

                if matchScore > bestMatchScore then begin
                    bestMatches.Clear;
                    bestMatches.AddObject(thisHPname, hplist.objects[hpIdx]);
                    bestMatchScore := matchScore;
                    if LOGGING then LogD(Format('New best match %s with %d matches', 
                        [thisHPname, bestMatchScore]));
                end
                else if matchScore = bestMatchScore then begin
                    bestMatches.AddObject(thisHPname, hplist.objects[hpIdx]);
                    if LOGGING then LogD(Format('New equal match %s with %d matches', 
                        [thisHPname, bestMatchScore]));
                end;
            end;
        end;
    end;

    if (bestMatchScore > -10) and (bestMatches.count > 0) then begin
        if LOGGING then LogD(Format('Choosing from best matches: %s', [bestMatches.commatext]));
        hpIdx := Hash(curNPCalias, 0317, bestMatches.Count);
        result := ObjectToElement(bestMatches.objects[hpIdx]);
    end;

    bestMatches.Free;

    if LOGGING then LogExitT1('CurNPCBestHeadpartMatch', Format('%s w/ %d score', [Name(result), bestMatchScore]));
end;


{==================================================================
Choose an equivalent furry headpart for the given vanilla headpart using labels to
identify the most similar.
}
function CurNPCFindSimilarHeadpart(oldHeadpart: IwbMainRecord): IwbMainRecord;
var
    i, j: integer;
begin
    if LOGGING then LogEntry2(10, 'CurNPCFindSimilarHeadpart', Name(curNPC), Name(oldHeadpart));
    result := Nil;
    i := headpartLabels.IndexOf(EditorID(oldHeadpart));
    if i >= 0 then begin
        for j := 0 to headpartlabels.objects[i].Count-1 do begin
            CurNPCAddLabel(headpartlabels.objects[i].strings[j]);
        end;
    end;
    result := CurNPCBestHeadpartMatch(oldHeadpart);
    if LOGGING then LogExitT1('CurNPCFindSimilarHeadpart', Name(result));
end;


{==================================================================
Furrify an NPC's headparts by choosing furry equivalents for vanilla headparts.
}
procedure CurNPCFurrifyHeadparts(vanillaNPC: IwbMainRecord);
var
    oldHeadparts: IwbContainer;
    newHeadparts: IwbContainer;
    i: integer;
    oldHP: IwbMainRecord;
    newHP: IwbMainRecord;
    hpslot: IwbElement;
begin
    if LOGGING then LogEntry1(5, 'CurNPCFurrifyHeadparts', Name(curNPC));
    oldHeadparts := ElementByPath(vanillaNPC, 'Head Parts');
    for i := 0 to ElementCount(oldHeadparts)-1 do begin
        oldHP := LinksTo(ElementByIndex(oldHeadparts, i));
        newHP := CurNPCFindSimilarHeadpart(oldHP);
        if Assigned(newHP) then begin
            AddToList(curNPC, 'Head Parts', newHP, targetFile);
            if LOGGING then LogD(Format('Assigning new headpart %s: %s -> %s', 
                [GetElementEditValues(newHP, 'PNAM'), EditorID(newHP), EditorID(vanillaNPC)]));
        end;
    end;
    if LOGGING then LogExitT('CurNPCFurrifyHeadparts');
end;


{==================================================================
Create a skin tone layer from the given preset.
}
procedure SetNPCTintLayer(const npc: IwbMainRecord; const skintonePreset: IwbElement);
var
    color: IwbMainRecord;
    sktLayer: IwbElement;
    tintAsset: IwbContainer;
    tintLayerID: integer;
    tinv: single;
    cnam: IwbElement;
    qnam: IwbElement;
    i: integer;
    c: integer;
begin
    if LOGGING then LogEntry2(10, 'SetNPCTintLayer', Name(npc), FullPath(skintonePreset));

    tintAsset := GetContainer(GetContainer(skintonePreset));
    tintLayerID := GetLayerID(tintAsset);
    if not ElementExists(npc, 'Tint Layers') then begin
        Add(npc, 'Tint Layers', True);
        sktLayer := ElementByIndex(ElementByPath(npc, 'Tint Layers'), 0);
    end
    else
        sktLayer := ElementAssign(ElementByPath(npc, 'Tint Layers'), HighInteger, Nil, false);

    LogD('Created skin tone layer ' + PathName(sktLayer));
    
    SetElementNativeValues(sktLayer, 'TINI', 
        GetElementNativeValues(tintAsset, 'Tint Layer\Texture\TINI'));
    SetElementNativeValues(sktLayer, 'TIAS', GetElementNativeValues(skintonePreset, 'TIRS'));

    // // Warpaint and tattoos always use full strength.
    // if (tintLayerID < TINT_SPECIAL_LO) or (tintLayerID = TINT_DIRT) or (tintLayerID = TINT_FREKLES) then
    //     tinv := HashVal(curNPCalias + FullPath(skintonePreset), 6804, 0, 
    //         GetElementNativeValues(skintonePreset, 'TINV'))
    // else
    //     tinv := 1.0;

    // Use the tint intensity from the preset.
    tinv := GetElementNativeValues(skintonePreset, 'TINV');

    if LOGGING then LogD(Format('Tint HashVal %s = %f', [curNPCalias, tinv]));
    SetElementNativeValues(sktLayer, 'TINV', tinv);
    LogD(Format('Assigned TINI %s, TIAS %s, TINV %s',
        [GetElementEditValues(sktLayer, 'TINI'),
        GetElementEditValues(sktLayer, 'TIAS'),
        GetElementEditValues(sktLayer, 'TINV')]));

    color := WinningOverride(LinksTo(ElementByPath(skintonePreset, 'TINC')));
    if Assigned(color) then begin
        Add(sktLayer, 'TINC', True);
        ElementAssign(ElementByPath(sktLayer, 'TINC'), LowInteger, 
            ElementByPath(color, 'CNAM'), false);
    end;

    if SameText(GetElementEditValues(tintAsset, 'Tint Layer\Texture\TINP'), 'Skin Tone') then begin
        // Set QNAM to match the Skin Tone, scaled by TINV
        Add(npc, 'QNAM', true);
        cnam := ElementByPath(color, 'CNAM');
        qnam := ElementByPath(npc, 'QNAM');
        for i := 0 to 2 do begin
            c := GetNativeValue(ElementByIndex(cnam, i));
            SetNativeValue(ElementByIndex(qnam, i), round((127-(128-c)*tinv)));
        end;
    end;

    LogD('Tint layers: ' + IntToStr(ElementCount(ElementByPath(npc, 'Tint Layers'))));

    if LOGGING then LogExitT('SetNPCTintLayer');
end;


{==================================================================
Select a furry tint layer for the NPC from the tint layer's presets.
}
Procedure ChooseFurryTintLayer(npc: IwbMainRecord; presetList: IwbElement; skipfirst: boolean);
var 
    h: integer;
    p: IwbElement;
    lo, hi: integer;
begin
    if LOGGING then LogEntry3(10, 'ChooseFurryTintLayer', 
        Name(npc), Pathname(presetList), IfThen(skipfirst, 'SKIPFIRST', 'USEFIRST'));
    
    lo := 0;
    hi := ElementCount(presetList)-1;
    if skipfirst then begin
        lo := 1;
        hi := hi - 1;
    end;

    h := Hash(curNPCalias, 1455, hi) + lo;
    p := ElementByIndex(presetList, h);
    SetNPCTintLayer(npc, p);

    if LOGGING then LogExitT('ChooseFurryTintLayer');
end;


{==================================================================
Determine whether a tint layer has to be assigned to NPCs. If the first tint preset has an
alpha of 0 the layer is assumed to be optional, otherwise required.
}
function RaceTintIsRequired(tintAsset: IwbElement): boolean;
begin
    if LOGGING then LogEntry1(10, 'RaceTintIsRequired', GetElementEditValues(tintAsset, 'Tint Layer\Texture\TINP'));
    result := (GetElementEditValues(tintAsset, 'Tint Layer\Texture\TINP') = 'Skin Tone')
        or (GetElementNativeValues(tintAsset, 'Presets\[0]\TINV') > 0.01);
    if LOGGING then LogExitT1('RaceTintIsRequired', IfThen(result, 'REQUIRED', 'OPTIONAL'));
end;




{==================================================================
Set all the furry tint layers on the npc, choosing presets randomly from the furrified
race.
}
Procedure CurNPCChooseFurryTints;
var
    tintList: TStringList;
    raceIndex: integer;
    classIndex: integer;
    tintAssetIndex: integer;
    thisTintAsset: IwbElement;
begin
    if LOGGING then LogEntry1(10, 'CurNPCChooseFurryTints', Name(curNPC));

    // Assign skin tone layer
    raceIndex := tintAssets[curNPCsex].IndexOf(EditorID(curNPCFurryRace));
    classIndex := tintAssets[curNPCsex].objects[raceIndex].IndexOf('Skin Tone');
    tintList := tintAssets[curNPCsex].objects[raceIndex].objects[classIndex];

    tintAssetIndex := Hash(curNPCalias, 1234, tintList.Count);
    thisTintAsset := ObjectToElement(tintList.objects[tintAssetIndex]);
    ChooseFurryTintLayer(curNPC, ElementByPath(thisTintAsset, 'Presets'), False);

    exit;

    // XXXXXXXXXX
    // optLayers := TStringList.Create;
    // appliedLayers := TStringList.Create;

    // // Go through tint layers of the furry race in "random" order so we pick up different
    // // layers for different NPCs.
    // tintMasks := ElementByPath(curNPCFurryRace, tintMaskPaths[curNPCsex]);
    // RandomizeIndexList(curNPCAlias, 5345, ElementCount(tintMasks));

    // for t := 0 to indexList.Count-1 do begin
    //     thisTintAsset := ElementByIndex(tintMasks, Integer(indexList.objects[t]));
    //     layerID := GetLayerID(thisTintAsset);
    //     if (layerID >= 0) then begin
    //         layername := tintlayerNames[layerID];
    //         if RaceTintIsRequired(thisTintAsset) then begin
    //             // Some furry races depend on the skin tone layer having a color to look
    //             // good. Others have built-in color and the skin tone just changes the
    //             // shade. If the former, all the tint layers should have non-zero alphas;
    //             // if the latter it's fine for the first layer to have a 0 alpha as most
    //             // vanilla races do.
    //             ChooseFurryTintLayer(curNPC, ElementByPath(thisTintAsset, 'Presets'), False);
    //             if LOGGING then LogD(Format('Applied layer of type %s', [layername]));
    //             appliedLayers.Add(layername);
    //         end
    //         else begin
    //             if appliedLayers.IndexOf(layername) < 0 then begin
    //                 // Special layers only applied if original has them.
    //                 tintNPC := False;
    //                 tintOK := (layerID < TINT_SPECIAL_LO);
    //                 if not tintOK then tintNPC := CurNPCHasTintlayer(layerID);
    //                 if tintOK or tintNPC then begin
    //                     optLayers.AddObject(layername, ElementByPath(thisTintAsset, 'Presets'));
    //                     appliedLayers.Add(layername);
    //                     if LOGGING then LogD(Format('Added optional layer %s at %d', [layername, Integer(indexList.objects[t])]))
    //                 end;
    //             end
    //             else 
    //                 if LOGGING then LogD(Format('Skipping optional layer %s, already applied', [layername]));
    //         end;
    //     end
    //     else Warn('Unknown tint layer: ' + PathName(thisTintAsset));
    // end;

    // // Assign up to MAX_TINT_LAYERS optional layers
    // i := Hash(curNPCalias, 487, MAX_TINT_LAYERS);
    // while (optLayers.count > 0) do begin
        
    //     h := Hash(curNPCalias, 0879, optLayers.count);
    //     thisLayer := optLayers.strings[h];
    //     thisLayerID := tintlayerNames.IndexOf(thisLayer); 

    //     if LOGGING then LogD(Format('Considering layer %s (%d) for %s', 
    //         [thisLayer, thisLayerID, Name(curNPC)]));
    //     if (thisLayerID >= TINT_SPECIAL_LO) or (i > 0) then begin
    //         ChooseFurryTintLayer(curNPC, ObjectToElement(optLayers.objects[h]), True);
    //         if LOGGING then LogD(Format('Applied layer of type %s, %d/%d remaining', [thisLayer, optLayers.count, i]));
    //     end;
    //     optLayers.Delete(h);

    //     // Only non-special layers count against the tint layer maximum.
    //     if thisLayerID < TINT_SPECIAL_LO then i := i - 1;
    // end;

    // optLayers.Free;
    // appliedLayers.Free;
    if LOGGING then LogExitT('CurNPCChooseFurryTints');
end;


{==================================================================
Set all the furry tint layers on the npc, choosing presets randomly from the furrified
race.
}
Procedure CurNPCChooseFurryTintsOLD;
var
    t, r: integer;
    h, i, j: integer;
    appliedLayers: TStringList;
    optLayers: TStringList;
    tintMasks: IwbContainer;
    thisTintAsset: IwbElement;
    layername: string;
    layerID: integer;
    thisLayer: string;
    thisLayerID: integer;
    tintOK, tintNPC: Boolean;
begin
    if LOGGING then LogEntry1(10, 'CurNPCChooseFurryTints', Name(curNPC));

    optLayers := TStringList.Create;
    appliedLayers := TStringList.Create;

    // Go through tint layers of the furry race in "random" order so we pick up different
    // layers for different NPCs.
    tintMasks := ElementByPath(curNPCFurryRace, tintMaskPaths[curNPCsex]);
    RandomizeIndexList(curNPCAlias, 5345, ElementCount(tintMasks));

    for t := 0 to indexList.Count-1 do begin
        thisTintAsset := ElementByIndex(tintMasks, Integer(indexList.objects[t]));
        layerID := GetLayerID(thisTintAsset);
        if (layerID >= 0) then begin
            layername := tintlayerNames[layerID];
            if RaceTintIsRequired(thisTintAsset) then begin
                // Some furry races depend on the skin tone layer having a color to look
                // good. Others have built-in color and the skin tone just changes the
                // shade. If the former, all the tint layers should have non-zero alphas;
                // if the latter it's fine for the first layer to have a 0 alpha as most
                // vanilla races do.
                ChooseFurryTintLayer(curNPC, ElementByPath(thisTintAsset, 'Presets'), False);
                if LOGGING then LogD(Format('Applied layer of type %s', [layername]));
                appliedLayers.Add(layername);
            end
            else begin
                if appliedLayers.IndexOf(layername) < 0 then begin
                    // Special layers only applied if original has them.
                    tintNPC := False;
                    tintOK := (layerID < TINT_SPECIAL_LO);
                    if not tintOK then tintNPC := CurNPCHasTintlayer(layerID);
                    if tintOK or tintNPC then begin
                        optLayers.AddObject(layername, ElementByPath(thisTintAsset, 'Presets'));
                        appliedLayers.Add(layername);
                        if LOGGING then LogD(Format('Added optional layer %s at %d', [layername, Integer(indexList.objects[t])]))
                    end;
                end
                else 
                    if LOGGING then LogD(Format('Skipping optional layer %s, already applied', [layername]));
            end;
        end
        else Warn('Unknown tint layer: ' + PathName(thisTintAsset));
    end;

    // Assign up to MAX_TINT_LAYERS optional layers
    i := Hash(curNPCalias, 487, MAX_TINT_LAYERS);
    while (optLayers.count > 0) do begin
        
        h := Hash(curNPCalias, 0879, optLayers.count);
        thisLayer := optLayers.strings[h];
        thisLayerID := tintlayerNames.IndexOf(thisLayer); 

        if LOGGING then LogD(Format('Considering layer %s (%d) for %s', 
            [thisLayer, thisLayerID, Name(curNPC)]));
        if (thisLayerID >= TINT_SPECIAL_LO) or (i > 0) then begin
            ChooseFurryTintLayer(curNPC, ObjectToElement(optLayers.objects[h]), True);
            if LOGGING then LogD(Format('Applied layer of type %s, %d/%d remaining', [thisLayer, optLayers.count, i]));
        end;
        optLayers.Delete(h);

        // Only non-special layers count against the tint layer maximum.
        if thisLayerID < TINT_SPECIAL_LO then i := i - 1;
    end;

    optLayers.Free;
    appliedLayers.Free;
    if LOGGING then LogExitT('CurNPCChooseFurryTints');
end;


{==================================================================
Furrify an NPC by changing head parts, tints, and morphs to the furry race.
}
function FurrifyNPC(npc: IwbMainRecord): IwbMainRecord;
var
    furryNPC: IwbMainRecord;
    originalRace: IwbMainRecord;
    ispreset: boolean;
begin
    if LOGGING then LogEntry1(1, 'FurrifyNPC', Name(npc));

    result := Nil;
    ispreset := (GetElementEditValues(npc, 'ACBS - Configuration\Flags\Is CharGen Face Preset') = '1');

    originalRace := LinksTo(ElementByPath(npc, 'RNAM'));
    if (not ispreset) and (raceAssignments.IndexOf(EditorID(originalRace)) >= 0) then begin
        furryNPC := MakeOverride(WinningOverride(npc), targetFile);

        Remove(ElementByPath(furryNPC, 'FTST - Head texture'));
        Remove(ElementByPath(furryNPC, 'QNAM - Texture lighting'));
        Remove(ElementByPath(furryNPC, 'NAM9 - Face morph'));
        Remove(ElementByPath(furryNPC, 'Tint Layers'));

        LoadNPC(furryNPC, npc);

        if Assigned(curNPCAssignedRace) then 
            AssignElementRef(ElementByPath(furryNPC, 'RNAM'), curNPCAssignedRace);

        curNPClabels := TStringList.Create;
        curNPClabels.Duplicates := dupIgnore;
        curNPClabels.Sorted := True;
        CurNPCLoadLabels;

        // Clean out existing character customization
        Remove(ElementByPath(furryNPC, 'Head Parts'));
        CurNPCFurrifyHeadparts(npc);
        CurNPCChooseFurryTints;

        curNPClabels.Free;

        result := furryNPC;
    end;

    if LOGGING then LogExitT('FurrifyNPC');
end;


{==================================================================
Furrify all the NPCs in the load order up to Furry Skyrim.
}
procedure FurrifyAllNPCs;
var
    f: integer;
    n: integer;
    fn: string;
    npcList: IwbElement;
    npc: IwbMainRecord;
begin
    for f := 0 to targetFileIndex-1 do begin
        fn := GetFileName(FileByIndex(f));
        if LOGGING Then Log(2, 'File ' + GetFileName(FileByIndex(f)));
        processedNPCcount := 0;
        npcList := GroupBySignature(FileByIndex(f), 'NPC_');
        for n := 0 to ElementCount(npcList)-1 do begin
            if ((processedNPCcount mod 200) = 0) then
                AddMessage(Format('Furrifying %s: %.0f', 
                    [GetFileName(FileByIndex(f)), 100*processedNPCcount/ElementCount(npcList)]) + '%');

            npc := ElementByIndex(npcList, n);
            if IsWinningOverride(npc) then begin
                // Only furrify the winning override. We'll get to it unless it's in
                // FFO or later, in which case it doesn't need furrification.
                FurrifyNPC(npc);
            end;
            processedNPCcount := processedNPCcount + 1;
        end;
        AddMessage(Format('Furrified %s: %d', 
            [GetFileName(FileByIndex(f)), processedNPCcount]));
    end;
end;


{==================================================================
Show all hair assignments.
}
procedure ShowHair;
var
    npcList: IwbElement;
    npc: IwbMainRecord;
    headParts: IwbElement;
    headPart: IwbMainRecord;
    i, j: integer;
    partType, npcSex: string;
    maleHairCount, femaleHairCount: TStringList;
    totalMaleNPCs, totalFemaleNPCs: integer;
begin
    maleHairCount := TStringList.Create;
    femaleHairCount := TStringList.Create;
    maleHairCount.Sorted := True;
    femaleHairCount.Sorted := True;
    maleHairCount.Duplicates := dupIgnore;
    femaleHairCount.Duplicates := dupIgnore;

    npcList := GroupBySignature(targetFile, 'NPC_');
    totalMaleNPCs := 0;
    totalFemaleNPCs := 0;

    for i := 0 to ElementCount(npcList) - 1 do begin
        npc := ElementByIndex(npcList, i);
        npcSex := GetElementEditValues(npc, 'ACBS\Flags');
        headParts := ElementByPath(npc, 'Head Parts');
        for j := 0 to ElementCount(headParts) - 1 do begin
            headPart := LinksTo(ElementByIndex(headParts, j));
            partType := GetElementEditValues(headPart, 'PNAM');
            if partType = 'Hair' then begin
                if Pos('Female', npcSex) > 0 then begin
                    Inc(totalFemaleNPCs);
                    if femaleHairCount.IndexOf(EditorID(headPart)) = -1 then
                        femaleHairCount.AddObject(EditorID(headPart), TObject(1))
                    else
                        femaleHairCount.Objects[femaleHairCount.IndexOf(EditorID(headPart))] := TObject(Integer(femaleHairCount.Objects[femaleHairCount.IndexOf(EditorID(headPart))]) + 1);
                end else begin
                    Inc(totalMaleNPCs);
                    if maleHairCount.IndexOf(EditorID(headPart)) = -1 then
                        maleHairCount.AddObject(EditorID(headPart), TObject(1))
                    else
                        maleHairCount.Objects[maleHairCount.IndexOf(EditorID(headPart))] := TObject(Integer(maleHairCount.Objects[maleHairCount.IndexOf(EditorID(headPart))]) + 1);
                end;
                Break;
            end;
        end;
    end;

    AddMessage('Male Hair Summary:');
    for i := 0 to maleHairCount.Count - 1 do begin
        AddMessage(Format('Hair: %s, Count: %d, Percentage: %.2f%%', 
            [maleHairCount[i], Integer(maleHairCount.Objects[i]), (Integer(maleHairCount.Objects[i]) / totalMaleNPCs) * 100]));
    end;

    AddMessage('Female Hair Summary:');
    for i := 0 to femaleHairCount.Count - 1 do begin
        AddMessage(Format('Hair: %s, Count: %d, Percentage: %.2f%%', 
            [femaleHairCount[i], Integer(femaleHairCount.Objects[i]), (Integer(femaleHairCount.Objects[i]) / totalFemaleNPCs) * 100]));
    end;

    maleHairCount.Free;
    femaleHairCount.Free;
end;


{===================================================================
Furrify all armor. Walk through all armor in the load order and fix their armor addons to
be furrified.
}
procedure FurrifyArmor;
var
    i: integer;
begin
    CollectArmor;

    for i := 0 to furrifiableArmors.count-1 do begin
        FurrifyArmorRecord(ObjectToElement(furrifiableArmors.objects[i]));
    end;
end;


//==================================================================
//==================================================================
//
function Initialize: integer;
begin
    AddMessage(' ');
    AddMessage(' ');
    AddMessage('====================================================');
    AddMessage('================ SKYRIM FURRIFIER ==================');
    AddMessage('====================================================');
    AddMessage('Version ' + FURRIFIER_VERSION);
    AddMessage('xEdit Version ' + GetXEditVersion());
    AddMessage(' ');

    InitializeLogging;
    LOGGING := 0;
    LOGLEVEL := 1;
    if LOGGING then LogEntry(1, 'Initialize');

    hairAssignments := TStringList.Create;

    targetFileIndex := FindFile(PATCH_FILE_NAME);
    LogD(Format('Found target file at %d', [targetFileIndex]));
    if targetFileIndex < 0 then begin
        targetFile := AddNewFileName(PATCH_FILE_NAME);
        LogT('Creating file ' + GetFileName(targetFile));
        targetFileIndex := GetLoadOrder(targetFile);
    end
    else 
        targetFile := FileByIndex(targetFileIndex);

    PreferencesInit;
    CollectArmor;
    // CollectAddons;
    SetPreferences;
    ShowRaceAssignments;

    FurrifyAllRaces;
    FurrifyHeadpartLists;
    // ShowHeadparts;
    // ShowRaceTints;

    processedNPCcount := 0;
    result := 0;
    if LOGGING then LogExitT('Initialize');
    LOGLEVEL := LOG_NPCS;
    LOGGING := (LOG_NPCS > 0);
end;

function Process(entity: IwbMainRecord): integer;
var
    win: IwbMainRecord;
    s: integer;
begin
    if USE_SELECTION and (Signature(entity) = 'NPC_') then 
        s := IfThen(GetElementEditValues(entity, 'ACBS - Configuration\Flags\Female') = '1',
            SEX_FEM, SEX_MALE);
        if (FURRIFY_NPCS_MALE and (s = SEX_MALE)) or (FURRIFY_NPCS_FEM and (s = SEX_FEM)) then begin
            processedNPCcount := processedNPCcount + 1;
            FurrifyNPC(entity);
        end;
    
    result := 0;
end;

function Finalize: integer;
var
    errRpt: string;
begin
    if LOGGING then LogEntry(1, 'Finalize');

    if (FURRIFY_NPCS_MALE or FURRIFY_NPCS_FEM) and (not USE_SELECTION) then begin
        FurrifyAllNPCs;
    end;

    LOGGING := (LOG_ARMOR > 0);
    LOGLEVEL := LOG_ARMOR;
    if FURRIFY_ARMOR then FurrifyArmor;

    if (processedNPCcount > 0) and SHOW_HAIR_ASSIGNMENT then ShowHair;

    PreferencesFree;
    hairAssignments.Free;
    result := 0;
    if LOGGING then LogExitT('Finalize');

    errRpt := IfThen((errCount = 0) and (warnCount = 0), 
        'SUCCESS', 
        IfThen(warnCount = 0, 
            Format('WITH %d ERRORS', [errCount]),
            Format('WITH %d ERRORS, %d WARNINGS', [errCount, warnCount])));

    AddMessage(' ');
    AddMessage(' ');
    AddMessage('====================================================');
    AddMessage('============= SKYRIM FURRIFIER DONE ================');
    AddMessage('====================================================');
    AddMessage(errRpt);
    AddMessage('Version ' + FURRIFIER_VERSION);
    AddMessage('xEdit Version ' + GetXEditVersion());

end;

end.
