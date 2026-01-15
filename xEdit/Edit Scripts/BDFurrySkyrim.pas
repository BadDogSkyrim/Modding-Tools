
{

  Hotkey: Ctrl+Alt+D

}
unit BDFurrySkyrim;
interface
implementation

uses 
    BDFurrySkyrim_Preferences, BDArmorFixup, BDFurrifySchlongs, BDFurrySkyrimTools,
    BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    FURRIFIER_VERSION = 'X0.01';
    SHOW_OPTIONS_DIALOG = False;
    PATCH_FILE_NAME = 'YASNPCPatch.esp'; // Set to whatever
    USE_SELECTION = FALSE;           // FALSE or TRUE
    FURRIFY_ARMOR = TRUE;         
    FURRIFY_NPCS_MALE = TRUE;
    FURRIFY_NPCS_FEM = TRUE;
    SHOW_HAIR_ASSIGNMENT = TRUE;
    MAX_TINT_LAYERS = 200; // Max tint layers to apply to a NPC
    LOG_ARMOR = 0;
    LOG_NPCS = 0;
    LOG_SCHLONGS = 0;
    CLEAR_MESSAGE_WINDOW = TRUE;
    CLEAN_TARGET_FILE = TRUE;

    IS_NONE = 0;
    IS_FURRIFIABLE = 1;
    IS_FURRY = 2;
    IS_ALREADY_TESTED = 4;

var
    processedNPCcount: Integer;
    addonFurrifiedRaces: TStringList;
    hairAssignments: TStringList;
    cancelFurrification: boolean;


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
Determine how well headpart labels match the current NPC labels.
Every match increases the score, every label that isn't matched decreases the score.
Conflicting labels generate a score of -1000.
}
function CalculateLabelMatchScore(hpLabelIdx: integer): integer;
var
    i, j: integer;
    score: integer;
begin
    if LOGGING then LogEntry2(10, 'CalculateLabelMatchScore', 
        headpartLabels.strings[hpLabelIdx], headpartLabels.objects[hpLabelIdx].CommaText);
    score := 0;

    for i := 0 to curNPClabels.Count - 1 do begin
        if headpartLabels.objects[hpLabelIdx].IndexOf(curNPClabels[i]) >= 0 then begin
            Inc(score); // Increase score for each match
            // if LOGGING then LogD(Format('Label match: %s', [curNPClabels[i]]));
        end
        else begin
            Dec(score); // Decrease score for each non-match
            // if LOGGING then LogD(Format('Label mismatch: %s', [curNPClabels[i]]));
        end;
        for j := 0 to headpartLabels.objects[hpLabelIdx].Count -1 do begin
            if LabelsConflict(curNPClabels.strings[i], headpartLabels.objects[hpLabelIdx].strings[j]) then begin
                score := -1000;
                // if LOGGING then LogD(Format('Label conflict: %s/%s', [
                //     curNPClabels.strings[i], headpartLabels.objects[hpLabelIdx].strings[j]]));
            end;
        end;
    end;

    result := score;
    if LOGGING then LogExitT(Format('CalculateLabelMatchScore %s ~ %s = %d', [curNPCalias, headpartLabels.strings[hpLabelIdx], score]));
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
    if emptyHeadparts.IndexOf(EditorID(oldHeadpart)) >= 0 then begin
        if LOGGING then LogD(Format('Headpart %s means empty, skipping', [EditorID(oldHeadpart)]));
    end
    else begin
        i := headpartLabels.IndexOf(EditorID(oldHeadpart));
        if i >= 0 then begin
            for j := 0 to headpartlabels.objects[i].Count-1 do begin
                CurNPCAddLabel(headpartlabels.objects[i].strings[j]);
            end;
        end;
        result := CurNPCBestHeadpartMatch(oldHeadpart);
    end;
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
    tinv: float;
    cnam: IwbElement;
    qnam: IwbElement;
    i: integer;
    c: integer;
begin
    if LOGGING then LogEntry2(10, 'SetNPCTintLayer', Name(npc), PathName(skintonePreset));

    tintAsset := GetContainer(GetContainer(skintonePreset));
    if not ElementExists(npc, 'Tint Layers') then begin
        Add(npc, 'Tint Layers', True);
        sktLayer := ElementByIndex(ElementByPath(npc, 'Tint Layers'), 0);
    end
    else
        sktLayer := ElementAssign(ElementByPath(npc, 'Tint Layers'), HighInteger, Nil, false);

    LogD('Created skin tone layer ' + PathName(sktLayer));
    
    SetElementNativeValues(sktLayer, 'TINI', 
        GetElementNativeValues(tintAsset, 'Tint Layer\TINI'));
    SetElementNativeValues(sktLayer, 'TIAS', GetElementNativeValues(skintonePreset, 'TIRS'));

    // Use the tint intensity from the preset.
    tinv := GetElementNativeValues(skintonePreset, 'TINV');

    if LOGGING then LogD(Format('Tint HashVal %s = %s', [curNPCalias, FloatToStr(tinv)]));
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

        if SameText(GetElementEditValues(tintAsset, 'Tint Layer\TINP'), 'Skin Tone') then begin
            // Set QNAM to match the Skin Tone, scaled by TINV
            Add(npc, 'QNAM', true);
            cnam := ElementByPath(color, 'CNAM');
            qnam := ElementByPath(npc, 'QNAM');
            for i := 0 to 2 do begin
                c := GetNativeValue(ElementByIndex(cnam, i));
                SetNativeValue(ElementByIndex(qnam, i), round((127-(128-c)*tinv)));
            end;
        end;
    end
    else
        Warn(Format('No color found for %s preset %s', [Name(npc), FullPath(skintonePreset)]));

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
    if h >= ElementCount(presetList) then h := ElementCount(presetList) - 1;
    p := ElementByIndex(presetList, h);
    if ASSIGNED(p) then
        SetNPCTintLayer(npc, p)
    else
        Warn(Format('No preset found at index %d in %s', [h, PathName(presetList)]));

    if LOGGING then LogExitT('ChooseFurryTintLayer');
end;


{==================================================================
Determine whether a tint layer has to be assigned to NPCs. If the first tint preset has an
alpha of 0 the layer is assumed to be optional, otherwise required.
}
function RaceTintIsRequired(tintAsset: IwbElement): boolean;
begin
    if LOGGING then LogEntry1(10, 'RaceTintIsRequired', GetElementEditValues(tintAsset, 'Tint Layer\TINP'));
    result := (GetElementEditValues(tintAsset, 'Tint Layer\TINP') = 'Skin Tone')
        or (GetElementNativeValues(tintAsset, 'Presets\[0]\TINV') > 0.01);
    if LOGGING then LogExitT1('RaceTintIsRequired', IfThen(result, 'REQUIRED', 'OPTIONAL'));
end;


{==================================================================
Set all the furry tint layers on the npc, choosing presets randomly from the furrified
race.
}
Procedure CurNPCChooseFurryTints;
var
    skinToneIndex: integer;
    i: integer;
    cid: integer;
    cl: integer;
    cnam: string;
    creq: boolean;
    raceIndex: integer;
    thisTintAsset: IwbElement;
    tintAssetIndex: integer;
    tintList: TStringList;
    furLayerCount: integer;
    raceTintClasses: TStringList;
    p: IwbElement;
    s: string;
begin
    if LOGGING then LogEntry1(10, 'CurNPCChooseFurryTints', Name(curNPC));

    // Assign skin tone layer
    raceIndex := tintAssets[curNPCsex].IndexOf(EditorID(curNPCFurryRace));
    raceTintClasses := tintAssets[curNPCsex].objects[raceIndex];
    skinToneIndex := raceTintClasses.IndexOf('Skin Tone');
    tintList := raceTintClasses.objects[skinToneIndex];

    thisTintAsset := ObjectToElement(tintList.objects[0]);
    p := ElementByPath(thisTintAsset, 'Presets');
    if Assigned(p) then begin
        if LOGGING then LogD(Format('Assigning skin tone layer from %s', [PathName(thisTintAsset)]));
        ChooseFurryTintLayer(curNPC, ElementByPath(thisTintAsset, 'Presets'), False);
    end
    else
        Warn(Format('No presets found for tint layer %s', [PathName(thisTintAsset)]));

    // Go through fur tint layers of the furry race in pseudo-random order so we pick up
    // different layers for different NPCs.
    RandomizeIndexList(curNPCAlias, 5345, raceTintClasses.Count);
    furLayerCount := 0;

    if LOGGING then begin
        LogD(Format('raceTintClasses: %s', [raceTintClasses.CommaText]));
        s := '';
        for i := 0 to indexList.Count-1 do begin
            if Length(s) > 0 then s := s + ', ';
            s := s + raceTintClasses.strings[Integer(indexList.objects[i])];
        end;
        LogD(Format('Randomized tint class order: %s', [s]));
    end;

    for cl := 0 to indexList.Count-1 do begin
        i := Integer(indexList.objects[cl]);
        cnam := raceTintClasses.strings[i];
        cid := tintLayerNames.IndexOf(cnam);
        creq := tintClassRequired.values[cnam] = '1';
        if (cid > TINT_SKIN_TONE) or creq then begin
            if LOGGING then LogD(Format('Found tint class %d: %s', [cid, cnam]));

            if  // It's a fur layer and we haven't reached the max fur layers yet
                ((cid < TINT_DECORATION_LO) and (furLayerCount < MAX_TINT_LAYERS))
                // It's a decoration layer and the NPC has it
                or ((cid >= TINT_DECORATION_LO) and (curNPCTintLayers.IndexOf(cnam) >= 0))
                // It's required
                or creq
            then begin
                tintList := raceTintClasses.objects[i];
                If tintList.Count > 0 then 
                    tintAssetIndex := Hash(curNPCalias, 529, tintList.Count)
                else
                    tintAssetIndex := 0;
                thisTintAsset := ObjectToElement(tintList.objects[tintAssetIndex]);
                if LOGGING then LogD(Format('Assigning tint layer %s from %s', [cnam, PathName(thisTintAsset)]));
                ChooseFurryTintLayer(curNPC, ElementByPath(thisTintAsset, 'Presets'), True);
                if LOGGING then LogD(Format('Applied layer of type %s', [cnam]));

                // Keep track of applied fur layers 
                if cid < TINT_DECORATION_LO then Inc(furLayerCount);
            end;
        end;
    end;

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
                    tintOK := (layerID < TINT_DECORATION_LO);
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
        if (thisLayerID >= TINT_DECORATION_LO) or (i > 0) then begin
            ChooseFurryTintLayer(curNPC, ObjectToElement(optLayers.objects[h]), True);
            if LOGGING then LogD(Format('Applied layer of type %s, %d/%d remaining', [thisLayer, optLayers.count, i]));
        end;
        optLayers.Delete(h);

        // Only non-special layers count against the tint layer maximum.
        if thisLayerID < TINT_DECORATION_LO then i := i - 1;
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
            if ((processedNPCcount mod 500) = 0) then
                AddMessage(Format('Furrifying %s: %.0f', 
                    [GetFileName(FileByIndex(f)), 100*processedNPCcount/ElementCount(npcList)]) + '%');

            npc := ElementByIndex(npcList, n);
            if LOGGING then Log(10, 'Found NPC ' + Path(npc));
            if IsWinningOverride(npc) then begin
                // Only furrify the winning override. We'll get to it unless it's in
                // FFO or later, in which case it doesn't need furrification.
                FurrifyNPC(npc);
            end;
            processedNPCcount := processedNPCcount + 1;
        end;
        AddMessage(Format('Furrifying %s: 100', [GetFileName(FileByIndex(f))]) + '%');
        AddMessage(Format('Furrified %s: %d', 
            [GetFileName(FileByIndex(f)), processedNPCcount]));
    end;
end;


{==================================================================
Replace the race presets on a furrified race with copies of the presets from the template furry race,
setting their race to the furrified race.
}
procedure FurrifyRacePresets;
var
    i, j: integer;
    vanillaRaceName: string;
    furryRace, furrifiedRace: IwbMainRecord;
    furryPresets, furrifiedPresets: IwbElement;
    pn: string;
    preset, newPreset: IwbMainRecord;
    sex: Integer;
    e: IwbElement;
begin
    if LOGGING then LogEntry(1, 'FurrifyRacePresets');
    
    // For each furrified race assignment
    for i := 0 to raceAssignments.Count - 1 do begin
        vanillaRaceName := raceAssignments[i];
        furryRace := ObjectToElement(raceAssignments.Objects[i]);
        // Find the furrified race in the patch file
        furrifiedRace := WinningOverride(ObjectToElement(
            vanillaRaces.Objects[vanillaRaces.IndexOf(vanillaRaceName)]));
        if not Assigned(furrifiedRace) then begin
            if LOGGING then LogD('No furrified race found for ' + vanillaRaceName);
            Continue;
        end;

        if vanillaRaceName <> 'NordRace' then continue;

        for sex := SEX_MALE to SEX_FEM do begin
            pn := IfThen(sex = SEX_MALE, 
                'Head Data\Male Head Data\Race Presets Male',
                'Head Data\Female Head Data\Race Presets Female');

            // Walk through each preset, replacing it with a furry version of the preset. To
            // prevent modifying the list we're walking over, walk the furry race presets.
            // Should be the same.
            furryPresets := ElementByPath(furryRace, pn);
            furrifiedPresets := ElementByPath(furrifiedRace, pn);
            for j := ElementCount(furrifiedPresets)-1 downto 0 do begin
                Remove(ElementByIndex(furrifiedPresets, j));
            end;
            for j := 0 to ElementCount(furryPresets)-1 do begin
                preset := WinningOverride(LinksTo(ElementByIndex(furryPresets, j)));
                newPreset := wbCopyElementToFile(preset, targetFile, True, True);
                SetElementEditValues(newPreset, 'EDID', 
                    EditorID(preset) + '_' + EditorID(furrifiedRace));
                if LOGGING then LogD(Format('Created new preset %s from %s', [
                    Pathname(newPreset), Pathname(preset)
                ]));
                // Set the race of the new preset to the furrified race
                SetElementEditValues(newPreset, 'RNAM', Name(furrifiedRace));
                // Replace the preset
                ElementAssign(furrifiedPresets, HighInteger, nil, FALSE);
                AssignElementRef(ElementByIndex(furrifiedPresets, 0), newPreset);
                if LOGGING then LogD(Format('Added preset [%d] %s to race %s', [
                    ElementCount(furrifiedPresets)-1, EditorID(newPreset), EditorID(furrifiedRace)]));
            end;
        end;
    end;
    if LOGGING then LogExitT('FurrifyRacePresets');
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

{==================================================================
Remove all records from the target group.
}
procedure CleanTargetGroup(const sig: string);
var
    g: IwbElement;
    i: integer;
    rec: IwbMainRecord;
begin
    if LOGGING then LogEntry1(1, 'CleanTargetGroup', sig);

    g := GroupBySignature(targetFile, sig);
    for i := ElementCount(g) - 1 downto 0 do begin
        rec := ElementByIndex(g, i);
        Remove(rec);
    end;
    if LOGGING then LogExitT('CleanTargetGroup');
end;

procedure CleanTargetFile;
var
    i: integer;
    rec: IwbMainRecord;
begin
    if LOGGING then LogEntry(1, 'CleanTargetFile');
    AddMessage(Format('Cleaning old records from %s', [GetFileName(targetFile)]));
    CleanTargetGroup('ARMO');
    CleanTargetGroup('ARMA');
    CleanTargetGroup('FLST');
    CleanTargetGroup('GLOB');
    CleanTargetGroup('NPC_');
    CleanTargetGroup('RACE');
    if LOGGING then LogExitT('CleanTargetFile');
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

    cancelFurrification := FALSE;
    InitializeLogging;
    LOGGING := 0;
    LOGLEVEL := 5;
    if LOGGING then LogEntry(1, 'Initialize');

    targetFileIndex := FindFile(PATCH_FILE_NAME);
    LogD(Format('Found target file at %d', [targetFileIndex]));
    if targetFileIndex < 0 then begin
        targetFile := AddNewFileName(PATCH_FILE_NAME);
        LogT('Creating file ' + GetFileName(targetFile));
        targetFileIndex := GetLoadOrder(targetFile);
    end
    else 
        targetFile := FileByIndex(targetFileIndex);

    if CLEAN_TARGET_FILE then CleanTargetFile;
    if CLEAR_MESSAGE_WINDOW then ClearMessages;

    hairAssignments := TStringList.Create;

    PreferencesInit;
    SetPreferences;
    ShowRaceAssignments;

    FurrifyAllRaces;
    FurrifyAllHeadpartLists;
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
    s: integer;
begin
    if (not cancelFurrification) and USE_SELECTION and (Signature(entity) = 'NPC_') then begin
        s := IfThen(GetElementEditValues(entity, 'ACBS - Configuration\Flags\Female') = '1',
            SEX_FEM, SEX_MALE);
        if (FURRIFY_NPCS_MALE and (s = SEX_MALE)) or (FURRIFY_NPCS_FEM and (s = SEX_FEM)) then begin
            processedNPCcount := processedNPCcount + 1;
            FurrifyNPC(entity);
        end;
    end;
    
    result := 0;
end;

function Finalize: integer;
var
    errRpt: string;
    f, a: integer;
    armorList: IwbElement;
    armor: IwbMainRecord;
begin
    if LOGGING then LogEntry(1, 'Finalize');

    if (FURRIFY_NPCS_MALE or FURRIFY_NPCS_FEM) 
        and (not USE_SELECTION) 
        and (not cancelFurrification) 
    then begin
        FurrifyAllNPCs;
        FurrifyRacePresets;
    end;

    if FURRIFY_ARMOR and (not cancelFurrification) then begin
        LOGGING := (LOG_ARMOR > 0);
        LOGLEVEL := LOG_ARMOR;
        FurrifyAllArmors;
    end;

    if (not cancelFurrification) then begin
        LOGGING := (LOG_SCHLONGS > 0);
        LOGLEVEL := LOG_SCHLONGS;
        FurrifyAllSchlongs;
    end;

    if (processedNPCcount > 0) and SHOW_HAIR_ASSIGNMENT then ShowHair;

    PreferencesFree;
    if Assigned(hairAssignments) then hairAssignments.Free;
    result := 0;
    if LOGGING then LogExitT('Finalize');

    if cancelFurrification then
        errRpt := 'Furrification cancelled by user'
    else
        errRpt := IfThen((errCount = 0) and (warnCount = 0), 
            'SUCCESS', 
            IfThen(warnCount = 0, 
                Format('WITH %s ERRORS', [IntToStr(errCount)]),
                Format('WITH %s ERRORS, %s WARNINGS', [IntToStr(errCount), IntToStr(warnCount)])));

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
