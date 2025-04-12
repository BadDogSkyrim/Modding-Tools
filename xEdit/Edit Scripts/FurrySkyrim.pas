
unit FurrySkyrim;

interface

uses
  xEditAPI;

function CurNPCBestHeadpartMatch(const oldHeadpart: IwbMainRecord): IwbMainRecord;

implementation

uses FurrySkyrim_Preferences, FurrySkyrimTools, BDScriptTools, Classes, SysUtils, StrUtils, Windows;

const
    FURRIFIER_VERSION = '1.00';
    SHOW_OPTIONS_DIALOG = False;
    PATCH_FILE_NAME = 'YANPCPatch.esp'; // Set to whatever
    USE_SELECTION = FALSE;           // FALSE or TRUE
    SHOW_HAIR_ASSIGNMENT = TRUE;
    MAX_TINT_LAYERS = 8; // Max tint layers to apply to a NPC

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

    LogD(Format('Found race %s in file %s', [Name(vanillaRace), GetFileName(GetFile(vanillaRace))]));
    LogD('Overriding in ' + GetFileName(targetFile));
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
    v: single;
begin
    if LOGGING then LogEntry2(10, 'SetNPCTintLayer', Name(npc), FullPath(skintonePreset));

    tintAsset := GetContainer(GetContainer(skintonePreset));
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
    v := HashVal(curNPCalias + FullPath(skintonePreset), 6804, 0, GetElementNativeValues(skintonePreset, 'TINV'));
    if LOGGING then LogD(Format('Tint HashVal %s = %f', [curNPCalias, v]));
    SetElementNativeValues(sktLayer, 'TINV', v);
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
        Add(npc, 'QNAM', true);
        SetElementNativeValues(npc, 'QNAM\Red', GetElementNativeValues(color, 'CNAM\Red'));
        SetElementNativeValues(npc, 'QNAM\Green', GetElementNativeValues(color, 'CNAM\Green'));
        SetElementNativeValues(npc, 'QNAM\Blue', GetElementNativeValues(color, 'CNAM\Blue'));
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
        Name(npc), IfThen(skipfirst, 'SKIPFIRST', 'USEFIRST'), Pathname(presetList));
    
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
Determine whether a tint layer has to be assigned to NPCs.
If the first tint preset has an alpha of 0 the layer is assumed to be optional, otherwise required.
}
function RaceTintIsRequired(tintAsset: IwbElement): boolean;
begin
    if LOGGING then LogEntry1(10, 'RaceTintIsRequired', GetElementEditValues(tintAsset, 'Tint Layer\Texture\TINP'));
    result := (GetElementEditValues(tintAsset, 'Tint Layer\Texture\TINP') = 'Skin Tone')
        or (GetElementNativeValues(tintAsset, 'Presets\[0]\TINV') > 0.01);
    if LOGGING then LogExitT1('RaceTintIsRequired', IfThen(result, 'REQUIRED', 'OPTIONAL'));
end;


{==================================================================
Set all the furry tint layers on the npc, choosing presets randomly from the furrified race.
}
Procedure CurNPCChooseFurryTints;
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
    tintOK: Boolean;
begin
    if LOGGING then LogEntry1(10, 'CurNPCChooseFurryTints', Name(curNPC));

    optLayers := TStringList.Create;
    appliedLayers := TStringList.Create;

    // for t := 0 to TINT_COUNT-1 do begin
    //     r := raceTintPresets[t, curNPCsex].IndexOf(EditorID(curNPCFurryRace));
    //     if r >= 0 then begin
    //         If LOGGING then LogD(Format('Have tint %s / %s / %s / %s at %s', 
    //             [TintlayerToStr(t), SexToStr(curNPCsex), EditorID(curNPCRace),
    //             IfThen(RaceTintIsRequired(t, curNPCsex, curNPCrace), 'REQUIRED', 'OPTIONAL'),
    //             PathName(ObjectToElement(raceTintPresets[t, curNPCsex].objects[r]))]));
    
    // Go through tint layers in "random" order so we pick up different layers for different NPCs.
    tintMasks := ElementByPath(curNPCrace, tintMaskPaths[curNPCsex]);
    RandomizeIndexList(curNPCAlias, 5345, ElementCount(tintMasks));
    for t := 0 to indexList.Count-1 do begin
        thisTintAsset := ElementByIndex(tintMasks, Integer(indexList.objects[t]));
        // layername := GetElementEditValues(thisTintAsset, 'Tint Layer\Texture\TINP');
        // layerID := tintlayerNames.IndexOf(layername);
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
                appliedLayers.Add(layername);
            end
            else begin
                if appliedLayers.IndexOf(layername) < 0 then begin
                    // Special layers only applied if original has them.
                    tintOK := (layerID < TINT_SPECIAL_LO);
                    if not tintOK then tintOK := CurNPCHasTintlayer(layerID);
                    if tintOK then begin
                        optLayers.AddObject(layername, ElementByPath(thisTintAsset, 'Presets'));
                        appliedLayers.Add(layername);
                        if LOGGING then LogD(Format('Found optional layer %s at %d', [layername, Integer(indexList.objects[t])]))
                    end;
                end;
            end;
        end
        else Warn('Unknown tint layer: ' + PathName(thisTintAsset));
    end;

    // Assign up to 4 optional layers
    i := Hash(curNPCalias, 487, MAX_TINT_LAYERS);
    while (optLayers.count > 0) do begin
        
        h := Hash(curNPCalias, 0879, optLayers.count);
        thisLayer := optLayers.strings[h];
        thisLayerID := tintlayerNames.IndexOf(thisLayer); 
        if (thisLayerID >= TINT_SPECIAL_LO) or (i >= 0) then
            ChooseFurryTintLayer(curNPC, ObjectToElement(optLayers.objects[h]), True);
        optLayers.Delete(h);

        // Only non-special layers count against the tint layer maximum.
        if thisLayerID < TINT_SPECIAL_LO then i := i - 1;
        if LOGGING then LogD(Format('Added layer of type %s, %d/%d remaining', [thisLayer, optLayers.count, i]));
    end;

    optLayers.Free;
    if LOGGING then LogExitT('CurNPCChooseFurryTints');
end;


{==================================================================
Furrify an NPC by changing head parts, tints, and morphs to the furry race.
}
function FurrifyNPC(npc: IwbMainRecord): IwbMainRecord;
var
    furryNPC: IwbMainRecord;
begin
    if LOGGING then LogEntry1(1, 'FurrifyNPC', Name(npc));

    result := Nil;
    if raceAssignments.IndexOf(EditorID(LinksTo(ElementByPath(npc, 'RNAM')))) >= 0 then begin
        furryNPC := MakeOverride(WinningOverride(npc), targetFile);
        Remove(ElementByPath(furryNPC, 'FTST - Head texture'));
        Remove(ElementByPath(furryNPC, 'QNAM - Texture lighting'));
        Remove(ElementByPath(furryNPC, 'NAM9 - Face morph'));
        Remove(ElementByPath(furryNPC, 'Tint Layers'));

        LoadNPC(furryNPC, npc);

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


{===================================================================
Determine whether the given armor addon needs to be furrified: It's a furrifiable bodypart
and is valid for races that are being furrified. Returns the furrified races on this addon
in addonFurrifiedRaces (which the caller must initialze).
}
function AAIsFurrifiable(addon: IwbMainRecord): boolean;
var
    i: integer;
    addlRaces: IwbElement;
    raceName: string;
begin
    if LOGGING then LogEntry1(15, 'AAIsFurrifiable', EditorID(addon));
    result := false;

    // Is it a furrifiable bodypart?
    bipedFlags := ElementByPath(addon, 'BOD2 - Biped Body Template\First Person Flags');
    if Assigned(bipedFlags) then begin
        result := (GetElementNativeValues(bipedFlags, 'Hair') <> 0)
            or (GetElementNativeValues(bipedFlags, 'LongHair') <> 0)
            or (GetElementNativeValues(bipedFlags, 'Hands') <> 0);
    end;

    // If it is, does it cover a furrified race?
    addlRaces := ElementByPath(addon, 'Additional Races');
    for i := -1 to ElementCount(addlRaces)-1 do begin
        if i < 0 then raceName := EditorID(LinksTo(ElementByPath(addon, 'RNAM')))
        else raceName := EditorID(LinksTo(ElementByIndex(addlRaces, i)));
        if raceAssignments.IndexOf(raceName) >= 0 then begin
            addonFurrifiedRaces.AddObject(raceName, vanillaRaces.objects[vanillaRaces.IndexOf(raceName)]);
            result := True;
        end;
    end;

    if LOGGING then LogExitT1('AAIsFurrifiable', BoolToStr(result));
end;


{===================================================================
Determine whether the given addon is valid for the given race.
}
function AARacesMatch(addon: IwbMainRecord; race: IwbMainRecord): boolean;
var
    addList: IwbElement;
    i: integer;
    rn: string;
begin
    if LOGGING then LogEntry2(15, 'AARacesMatch', EditorID(addon), EditorID(race));
    result := false;
    rn := EditorID(LinksTo(ElementByPath(addon, 'RNAM')));
    if LOGGING then LogD(Format('Comparing %s =? %s', [rn, EditorID(race)]));
    if rn = EditorID(race) then result := true;
    if not result then begin
        addList := ElementByPath(addon, 'Additional Races');
        for i := 0 to ElementCount(addList)-1 do begin
            rn := EditorID(LinksTo(ElementByIndex(addList, i)));
            result := (rn = EditorID(race));
            if result then break;
        end;
    end;
    if LOGGING then LogExitT1('AARacesMatch', BoolToStr(result));
end;


// {===================================================================
// Compare bodypart flags and return true if any flags match.
// }
// function AABodypartsMatch(addon1, addon2: IwbMainRecord): boolean;
// var
//     addonBodyparts1, addonBodyparts2: IwbMainRecord;
// begin
//     if LOGGING then LogEntry2(15, 'AABodypartsMatch', PathName(addon1), PathName(addon2));
//     // result := true;
//     // addonBodyparts1 := ElementByPath(addon1, '[2]\[0]');
//     // addonBodyparts2 := ElementByPath(addon2, '[2]\[0]');
//     // result := ((GetNativeValue(addonBodyparts1) and GetNativeValue(addonBodyparts2)) <> 0);
//     result := ((GetBodypartFags(addon1) and GetBodypartFags(addon2)) <> 0);
//     if LOGGING then LogExitT1('AABodypartsMatch', BoolToStr(result));
// end;


{===================================================================
Find the armor addon listed in an armor record that matches a given race and covers the
given bodyparts.
}
function FindMatchingAddon(armor: IwbMainRecord; targetAddon: IwbMainRecord; race: IwbMainRecord): IwbMainRecord;
var
    aaList: IwbElement;
    i: integer;
    addon: IwbMainRecord;
begin
    if LOGGING then LogEntry3(10, 'FindMatchingAddon', EditorID(armor), EditorID(targetAddon), EditorID(race));
    result := nil;
    aaList := ElementByPath(armor, 'Armature');
    for i := 0 to ElementCount(aaList) - 1 do begin
        addon := WinningOverride(LinksTo(ElementByIndex(aaList, i)));
        if EditorID(addon) <> EditorID(targetAddon) then begin
            if AARacesMatch(addon, race) 
                and ((GetBodypartFags(addon) and GetBodypartFags(targetAddon)) <> 0)
            then begin
                result := addon;
                break;
            end;
        end;
    end;
    if LOGGING then LogExitT1('FindMatchingAddon', EditorID(result));
end;


{===================================================================
Find the armor addon with the shortest name for the given armor record. If multiple addons
have the same shortest name length, return the one that comes first alphabetically.
}
function AddonRootName(armor: IwbMainRecord): string;
var
    aaList: IwbElement;
    i: integer;
    addon: IwbMainRecord;
    shortestAddon: IwbMainRecord;
    shortestName: string;
begin
    if LOGGING then LogEntry1(5, 'AddonRootName', Name(armor));
    result := nil;
    shortestAddon := nil;
    shortestName := '';

    aaList := ElementByPath(armor, 'Armature');
    for i := 0 to ElementCount(aaList) - 1 do begin
        addon := WinningOverride(LinksTo(ElementByIndex(aaList, i)));
        if Assigned(addon) then begin
            if (not Assigned(shortestAddon)) or 
               (Length(EditorID(addon)) < Length(shortestName)) or 
               ((Length(EditorID(addon)) = Length(shortestName)) 
                    and (CompareText(EditorID(addon), shortestName) < 0)) 
            then begin
                shortestAddon := addon;
                shortestName := EditorID(addon);
            end;
        end;
    end;

    result := shortestName;
    if LOGGING then LogExitT1('AddonRootName', result);
end;


{===================================================================
Find the furry armor addon that works for the given race and is a valid replacement for
the given addon (same bodyparts).

    Return the furry version of the AA specific to this race
        or a furry version specific to the race class (DOG)
        or a khajiit addon already on the armor
}
function FindFurryAddon(race: IwbMainRecord; armor, addon: IwbMainRecord): IwbMainRecord;
var
    classIdx: integer;
    defIdx: Integer;
    furRace: IwbMainRecord;
    furRaceName: string;
    racei: integer;
    rootName: string;
    targetName: string;
    targIdx: integer;
begin
    if LOGGING then LogEntry3(5, 'FindFurryAddon', EditorID(race), EditorID(armor), EditorID(addon));
    result := nil;
    
    rootName := AddonRootName(armor);

    // Find an addon for this race specifically
    targetName := 'YA_' + rootname + '_' + EditorID(race);
    targIdx := allAddons.IndexOf(targetName);
    if LOGGING then LogD('Found specific addon: ' + targetName + ' at ' + IntToStr(targIdx));
    if targIdx >= 0 then begin
        result := ObjectToElement(allAddons.objects[targIdx]);
    end;
    if not Assigned(result) then begin
        // Find an addon for this race class
        racei := raceAssignments.IndexOf(EditorID(race));
        furRace := ObjectToElement(raceAssignments.objects[racei]);
        furRaceName := EditorID(furRace);
        if LOGGING then LogD(Format('Associated furry race: [%d] %s', [racei, furRaceName]));
        classIdx := furryRaceClass.IndexOfName(furRaceName);
        if classIdx >= 0 then begin
            targetName := 'YA_' + rootname + '_' + furryRaceClass.ValueFromIndex[classIdx];
            targIdx := allAddons.IndexOf(targetName);
            if LOGGING then LogD('Found class addon: ' + targetName + ' at ' + IntToStr(targIdx));
            if targIdx >= 0 then begin
                result := ObjectToElement(allAddons.objects[targIdx]);
            end;
        end;
    end;
    if not Assigned(result) then begin
        defIdx := furryRaces.IndexOf(armorRaces.values[furRaceName]);
        if LOGGING then LogD(Format('Found armor race: [%d] %s', [defIdx, armorRaces.values[furRaceName]]));
        if defIdx >= 0 then begin
            result := FindMatchingAddon(armor, addon, ObjectToElement(furryRaces.objects[defIdx]));
        end;
    end;

    if LOGGING then LogExitT1('FindFurryAddon', EditorID(result));
end;


{===================================================================
Remove a race from an armor addon. Returns the addon as modified (may be an override).
}
function RemoveAddonRace(addon: IwbMainRecord; race: IwbMainRecord): IwbMainRecord;
var
    addList: IwbElement;
    r: IwbMainRecord;
    i: integer;
    j: integer;
begin
    if LOGGING then LogEntry2(10, 'RemoveAddonRace', EditorID(addon), EditorID(race));
    addList := ElementByPath(addon, 'Additional Races');
    
    if GetLoadOrder(GetFile(addon)) < targetFileIndex then begin
        for i := ElementCount(addList)-1 downto -1 do begin
            if i < 0 then r := LinksTo(ElementByPath(addon, 'RNAM'))
            else r := LinksTo(ElementByIndex(addList, i));
            if LOGGING then LogD(Format('[%d] Checking addon race %s %s', [
                i, EditorID(r), IfThen(EditorID(r) = EditorID(race), '(remove)', '')]));

            if EditorID(r) = EditorID(race) then begin
                // Need to override 
                addon := MakeOverride(addon, targetFile);
                j := allAddons.IndexOf(EditorID(addon));
                if j < 0 then begin
                    Err(Format('Addon %s not found in addon list', [Name(addon)]));
                    allAddons.AddObject(EditorID(addon), addon);
                end
                else
                    allAddons.objects[j] := addon;
                addlist := ElementByPath(addon, 'Additional Races');

                if i < 0 then AssignElementRef(ElementByPath(addon, 'RNAM'), defaultRace)
                else RemoveByIndex(addList, i, false);
            end;
        end;
    end;

    result := addon;
    if LOGGING then LogExitT1('RemoveAddonRace', FullPath(result));
end;


{===================================================================
Add a race to an armor addon if it's not already there.
}
function AddAddonRace(addon: IwbMainRecord; race: IwbMainRecord): IwbMainRecord;
    var
        addList, newEle: IwbElement;
        i: integer;
begin
    if LOGGING then LogEntry2(10, 'AddAddonRace', EditorID(addon), EditorID(race));

    addon := AddToList(addon, 'Additional Races', race, targetFile);
    i := allAddons.IndexOf(EditorID(addon));
    if i < 0 then begin
        Err(Format('Addon %s not found in addon list', [Name(addon)]));
        allAddons.AddObject(EditorID(addon), addon);
    end
    else
        allAddons.objects[i] := addon;

    result := addon;
    if LOGGING then LogExitT1('AddAddonRace', FullPath(result));
end;


{===================================================================
Add an armor addon to an armor record if it's not already there.
}
function AddArmorAddon(armor: IwbMainRecord; addon: IwbMainRecord): IwbMainRecord;
var
    aaList: IwbElement;
    i: integer;
    exists: boolean;
begin
    if LOGGING then LogEntry2(5, 'AddArmorAddon', Name(armor), Name(addon));
    begin
        exists := false;
        aaList := ElementByPath(armor, 'Armature');
        for i := 0 to ElementCount(aaList)-1 do begin
            if EditorID(LinksTo(ElementByIndex(aaList, i))) = EditorID(addon) then begin
                exists := true;
                break;
            end;
        end;

        if not exists then begin
            if GetLoadOrder(GetFile(armor)) < targetFileIndex then begin
                armor := MakeOverride(armor, targetFile);
                furrifiableArmors.objects[furrifiableArmors.IndexOf(EditorID(armor))] := armor;
                aaList := ElementByPath(armor, 'Armature');
            end;
            ElementAssign(aaList, HighInteger, nil, false);
            // SetEditValue(ElementByIndex(aaList, ElementCount(aaList)-1), Name(addon));
            AssignElementRef(ElementByIndex(aaList, ElementCount(aaList)-1), addon);
        end;
        result := armor;
    end;
    if LOGGING then LogExitT1('AddArmorAddon', Name(addon));
end;


{===================================================================
Furrify a single armor record.
}
procedure FurrifyArmorRecord(armorIdx: cardinal);
var
    aaIdx: cardinal;
    aaList: IwbContainer;
    addlRaces: IwbElement;
    altAA: IwbMainRecord;
    faIdx: cardinal;
    i: integer;
    raceIdx: cardinal;
    raceName: string;
    thisAA: IwbMainRecord;
    thisArmor: IwbMainRecord;
    thisRace: IwbMainRecord;
begin
    if LOGGING then LogEntry2(5, 'FurrifyArmorRecord', IntToStr(armorIdx), furrifiableArmors[armorIdx]);
    thisArmor := ObjectToElement(furrifiableArmors.objects[armorIdx]);

    // Walk through the armor's addons looking for furrifiable addons.
    aaList := ElementByPath(thisArmor, 'Armature');
    for aaIdx := ElementCount(aaList)-1 downto 0 do begin
        thisAA := WinningOverride(LinksTo(ElementByIndex(aaList, aaIdx)));
        if LOGGING then LogD('Checking addon ' + EditorID(thisAA));

        faIdx := addonRaces.IndexOf(EditorID(thisAA));
        if Assigned(thisAA) and (faIdx >= 0) then begin

            for raceIdx := 0 to addonRaces.objects[faIdx].count-1 do begin
                thisRace := ObjectToElement(addonRaces.objects[faIdx].objects[raceIdx]);

                if raceAssignments.IndexOf(EditorID(thisRace)) >= 0 then begin
                    // Furry races are in the list too, so ignore them.
                    if LOGGING then LogD(Format('[%d] %s has race %s', [
                        raceIdx, EditorID(thisAA), EditorID(thisRace)]));

                    altAA := FindFurryAddon(thisRace, thisArmor, thisAA);
                    if Assigned(altAA) then begin
                        if LOGGING then LogD(Format('Substituting AA %s with %s for race %s', 
                            [EditorID(thisAA), EditorID(altAA), EditorID(thisRace)]));
                        thisAA := RemoveAddonRace(thisAA, thisRace);
                        altAA := AddAddonRace(altAA, thisRace);
                        thisArmor := AddArmorAddon(thisArmor, altAA);
                    end;
                end;
            end;
        end;
    end;
    if LOGGING then LogExitT('FurrifyArmorRecord');
end;


{===================================================================
Add the winning override of the given armor addon to allAddons if not already present.
}
procedure RecordAddon(addon: IwbMainRecord);
var
    e: string;
begin
    if LOGGING then LogEntry1(20, 'RecordAddon', Name(addon));

    addon := WinningOverride(addon);
    e := EditorID(addon);

    if allAddons.IndexOf(e) < 0 then begin
        allAddons.AddObject(e, addon);
        if LOGGING then LogD(Format('Added addon %s to allAddons', [e]));
    end
    else 
        if LOGGING then LogD(Format('Addon %s already exists in allAddons', [e]));

    if LOGGING then LogExitT1('RecordAddon', IntToStr(allAddons.count));
end;


{===================================================================
Determine whether the given addon is furrifiable or furry. Furrifiable if it is valid for
a race being furrified; furry if it is valid for a furry race.
}
function IsFurryAddon(addon: IwbMainRecord): integer;
var
    racesList: IwbElement;
    raceIdx: integer;
    race: IwbMainRecord;
begin
    if LOGGING then LogEntry1(20, 'IsFurryAddon', Name(addon));

    addon := WinningOverride(addon);

    if allAddons.IndexOf(EditorID(addon)) < 0 then begin
        if LOGGING then LogD('Not checked already');
        result := IS_NONE;

        // if LOGGING then LogD(Format('%s is hair: %d', [EditorID(addon), Integer(GetElementNativeValues(addon, 'BODT\First Person Flags\31 - Hair'))]));
        // if LOGGING then LogD(Format('%s is hands: %d', [EditorID(addon), Integer(GetElementNativeValues(addon, 'BODT\First Person Flags\33 - Hands'))]));
        
        if ((GetBodypartFlags(addon) and BP_HAIR) <> 0) 
            or ((GetBodypartFlags(addon) and BP_HANDS) <> 0) 
        then begin
            // Hands and hair are furrifiable bodyparts.
            if LOGGING then LogD('Is hands or hair');
            allAddons.AddObject(EditorID(addon), addon);

            racesList := ElementByPath(addon, 'Additional Races');
            for raceIdx := -1 to ElementCount(racesList)-1 do begin
                if raceIdx < 0 then race := WinningOverride(LinksTo(ElementByPath(addon, 'RNAM')))
                else race := WinningOverride(LinksTo(ElementByIndex(racesList, raceIdx)));

                if raceAssignments.IndexOf(EditorID(race)) >= 0 then begin
                    // Is a furried race, so is furrifiable addon.
                    if LOGGING then LogD('Is furrifiable: ' + EditorID(race));
                    result := result or IS_FURRIFIABLE;
                end;

                if furryRaces.IndexOf(EditorID(race)) >= 0 then begin
                    if LOGGING then LogD('Is furry: ' + EditorID(race));
                    result := result or IS_FURRY;
                end;

                if (result and (IS_FURRY or IS_FURRIFIABLE)) = (IS_FURRY or IS_FURRIFIABLE) then
                    // Once we've set both bits no need to look farther.
                    break;
            end;
        end;
    end
    else
        result := IS_ALREADY_TESTED;
        
    if LOGGING then LogExitT1('IsFurryAddon', IntToStr(result));
end;


{===================================================================
Check the addon for furrified races; if it has any then add it to the list of
furrifiable addons, along with the furrified races it's good for.
}
function RecordFurryAddon(addon: IwbMainRecord): boolean;
var
    racesList: IwbElement;
    raceIdx: integer;
    race: IwbMainRecord;
    isf: integer;
begin
    if LOGGING then LogEntry1(20, 'RecordFurryAddon', Name(addon));
    addon := WinningOverride(addon);

    isf := IsFurryAddon(addon);
    if (isf and (IS_FURRIFIABLE or IS_FURRY)) <> 0 then begin
        // Record addon and all races it is valid for.
        racesList := ElementByPath(addon, 'Additional Races');
        for raceIdx := -1 to ElementCount(racesList)-1 do begin
            if raceIdx < 0 then race := WinningOverride(LinksTo(ElementByPath(addon, 'RNAM')))
            else race := WinningOverride(LinksTo(ElementByIndex(racesList, raceIdx)));
            if LOGGING then LogD(Format('Found race %s', [EditorID(race)]));

            if Assigned(race) then begin
                // Only add the race if it's relevant to furrification
                if (raceAssignments.IndexOf(EditorID(race)) >= 0)
                    or (furryRaces.IndexOf(EditorID(race)) >= 0)
                then begin
                    if addonRaces.IndexOf(EditorID(addon)) < 0 then begin
                        addonRaces.AddObject(EditorID(addon), TStringList.Create);
                    end;
                    addonRaces.objects[addonRaces.IndexOf(EditorID(addon))].AddObject(EditorID(race), race);
                end;
            end;
        end;
    end;

    if (isf and (IS_FURRIFIABLE or IS_FURRY)) <> 0 then result := true
    else if addonRaces.IndexOf(EditorID(addon)) >= 0 then result := true
    else result := false;

    if LOGGING then LogExitT('RecordFurryAddon');
end;


{===================================================================
Collect all armor addons good for furry races.
}
procedure CollectFurryAddons;
var
    f, n, i: integer;
    addonList: IwbElement;
    addon: IwbMainRecord;
    racesList: IwbElement;
    race: IwbMainRecord;
    raceName: string;
    isFurryRace: boolean;
begin
    if LOGGING then LogEntry1(15, 'CollectFurryAddonRaces', Format('0 - %d', [targetFileIndex-1]));

    // Walk through all files
    for f := 0 to targetFileIndex - 1 do begin
        if LOGGING then LogD('Processing file: ' + GetFileName(FileByIndex(f)));

        // Walk through all armor addons in the file
        addonList := GroupBySignature(FileByIndex(f), 'ARMA');
        for n := 0 to ElementCount(addonList) - 1 do begin
            addon := ElementByIndex(addonList, n);
            if IsWinningOverride(addon) then 
                RecordFurryAddon(addon);
        end;
    end;

    if LOGGING then LogExitT('CollectFurryAddonRaces');
end;


{===================================================================
Collect all armor and armor addon records in the current load order and store them in
furrifiableArmors and addonRaces.
}
procedure CollectArmor;
var
    f: integer;
    n: integer;
    armorList: IwbElement;
    armor: IwbMainRecord;
    isFurrifiable: boolean;
    aaList: IwbElement;
    aaIdx: integer;
    addon: IwbMainRecord;
    racesList: IwbElement;
    raceIdx: integer;
    race: IwbMainRecord;
    sl: TStringList;
begin
    if LOGGING then LogEntry1(15, 'CollectArmor', Format('0 - %d', [targetFileIndex-1]));

    // Walk through all files
    for f := 0 to targetFileIndex - 1 do begin
        if LOGGING Then LogD(Format('File %s with %s armors, %s addons', 
            [GetFileName(FileByIndex(f)), IntToStr(furrifiableArmors.Count), IntToStr(addonRaces.count)]));

        // Walk through all armors in the file
        armorList := GroupBySignature(FileByIndex(f), 'ARMO');
        for n := 0 to ElementCount(armorList) - 1 do begin

            // Only process the winning override of the armor record
            armor := ElementByIndex(armorList, n);
            if IsWinningOverride(armor) then begin
                // Furrifiable armors are those that have a hair or hand bodypart flag set.
                isFurrifiable := false;
                if LOGGING then LogD(Format('Armor %s hair: %s hands %s:', 
                    [Name(armor),
                        GetElementEditValues(armor, 'BOD2\First Person Flags\31 - Hair'),
                        GetElementEditValues(armor, 'BOD2\First Person Flags\33 - Hands')]));
                if (GetElementNativeValues(armor, 'BOD2\First Person Flags\31 - Hair') <> 0) 
                    or (GetElementNativeValues(armor, 'BOD2\First Person Flags\33 - Hands') <> 0) 
                then begin
                    // Furrifiable armors must have an addon that is good for a furrified race.
                    aaList := ElementByPath(armor, 'Armature');
                    for aaIdx := 0 to ElementCount(aaList)-1 do begin
                        isFurrifiable := isFurrifiable or RecordFurryAddon(LinksTo(ElementByIndex(aaList, aaIdx)));
                    end;
                end;

                if LOGGING and isFurrifiable then LogD('Have furrifiable armor: ' + Name(armor));
                if isFurrifiable then furrifiableArmors.AddObject(EditorID(armor), armor);
            end;
        end;
    end;
    CollectFurryAddons;
    if LOGGING then LogExitT('CollectArmor');
end;


procedure ShowArmor;
var i, j: integer;
begin
    AddMessage('++++ Addon Races ++++');
    for i := 0 to addonRaces.Count-1 do begin
        if Assigned(addonRaces.objects[i]) then begin
            for j := 0 to addonRaces.objects[i].Count-1 do 
                AddMessage(Format('%s == %s', [addonRaces.strings[i], addonRaces.objects[i].strings[j]]));
        end
        else
            AddMessage(Format('%s == %s', [addonRaces.strings[i], '<NONE>']));
    end;
    AddMessage('---- Addon Races ----');
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
        FurrifyArmorRecord(i);
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
    AddMessage(' ');
    AddMessage('Version ' + FURRIFIER_VERSION);
    AddMessage('xEdit Version ' + GetXEditVersion());

    InitializeLogging;
    LOGGING := False;
    LOGLEVEL := 1;
    if LOGGING then LogEntry(1, 'Initialize');

    hairAssignments := TStringList.Create;

    PreferencesInit;
    CollectArmor;
    // CollectAddons;
    SetPreferences;
    ShowRaceAssignments;

    targetFileIndex := FindFile(PATCH_FILE_NAME);
    LogD(Format('Found target file at %d', [targetFileIndex]));
    if targetFileIndex < 0 then begin
        targetFile := AddNewFileName(PATCH_FILE_NAME);
        LogT('Creating file ' + GetFileName(targetFile));
        targetFileIndex := GetLoadOrder(targetFile);
    end
    else 
        targetFile := FileByIndex(targetFileIndex);

    FurrifyAllRaces;
    FurrifyHeadpartLists;
    // ShowHeadparts;
    // ShowRaceTints;

    processedNPCcount := 0;
    result := 0;
    if LOGGING then LogExitT('Initialize');
end;

function Process(entity: IwbMainRecord): integer;
var
    win: IwbMainRecord;
begin
    if USE_SELECTION and (Signature(entity) = 'NPC_') then begin
        processedNPCcount := processedNPCcount + 1;
        FurrifyNPC(entity);
    end;
    
    result := 0;
end;

function Finalize: integer;
begin
    if LOGGING then LogEntry(1, 'Finalize');

    if not USE_SELECTION then begin
        FurrifyAllNPCs;
    end;

    FurrifyArmor;

    if SHOW_HAIR_ASSIGNMENT then ShowHair;

    PreferencesFree;
    hairAssignments.Free;
    result := 0;
    if LOGGING then LogExitT('Finalize');
end;

end.
