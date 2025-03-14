
unit FurrySkyrim;

interface

uses
  xEditAPI;

procedure SetNPCTintLayer(const npc: IwbMainRecord; const skintonePreset: IwbElement);

function FindBestHeadpartMatch(const oldHeadpart: IwbMainRecord): IwbMainRecord;

implementation

uses FurrySkyrim_Preferences, FurrySkyrimTools, BDScriptTools, Classes, SysUtils, StrUtils, Windows;

const
    FURRIFIER_VERSION = '1.00';
    SHOW_OPTIONS_DIALOG = False;
    PATCH_FILE_NAME = 'YANPCPatch.esp'; // Set to whatever
    USE_SELECTION = FALSE;           // FALSE or TRUE

var
    processedNPCcount: Integer;
    addonFurrifiedRaces: TStringList;


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
    ElementAssign(ElementByPath(furrifiedRace, 'Head Data\Male Head Data'), 
        LowInteger, 
        ElementByPath(furryRace, 'Head Data\Male Head Data'), 
        false);

    LoadRaceTints(furrifiedRace);

    if LOGGING then LogExitT('FurrifyRace');
end;


{==================================================================
Change all redefined races to their furry equivalent race.
}
procedure FurrifyAllRaces;
var i: integer;
begin
    for i := 0 to raceAssignments.Count-1 do begin
        FurrifyRace(raceAssignments[i], ObjectToElement(raceAssignments.objects[i]));
    end;
end;


{==================================================================
Add the given label to the curNPClabels IF it does not conflict with any existing labels.
}
procedure AddNPCLabel(newLabel: string);
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
procedure LoadNPCLabels(npc: IwbMainRecord);
var
    voice: string;
    outfit: string;
begin
    voice := GetElementEditValues(npc, 'VTCK');
    outfit := GetElementEditValues(npc, 'DOFT');

    if ContainsStr(voice, 'Emperor') or ContainsStr(voice, 'Ulfric') 
        or ContainsStr(outfit, 'Jarl') or ContainsStr(outfit, 'FineClothes')
    then AddNPCLabel('NOBLE');

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
    then curNPClabels.Add('MESSY');

    if ContainsStr(outfit, 'Tavern') or ContainsStr(outfit, 'College')
    then curNPClabels.Add('NEAT');

    if ContainsStr(outfit, 'Warlock') or ContainsStr(outfit, 'Bandit') 
    then curNPClabels.Add('BOLD');
end;


{==================================================================
Determine whether the headpart sex works for the current NPC.
}
function NPCSexMatchesHeadpart(hp: iwbMainRecord): boolean;
begin
    result := (
        (GetElementEditValues(hp, 'DATA - Flags\Male') and StartsText('MALE', curNPCsex))
        or (GetElementEditValues(hp, 'DATA - Flags\Female') and StartsText('FEMALE', curNPCsex))
    );
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


{====================================================================
Find the best headpart match using labels. Current NPC labels are in curNPClabels.
Headpart returned will be of same type as oldHeadpart and will work for the NPC's race.
}
function FindBestHeadpartMatch(const oldHeadpart: IwbMainRecord): IwbMainRecord;
var
    bestMatchCount: integer;
    bestMatches: TStringList;
    hpIdx: integer;
    hpType: string;
    i, j: integer;
    matchCount: integer;
    nextHP: IwbMainRecord;
    nextHPname: string;
    nextHPraces: TStringList;
    raceIdx: integer;
begin
    if LOGGING then LogEntry1(10, 'FindBestHeadpartMatch', Name(oldHeadpart));
    if LOGGING then LogD('NPC labels ' + curNPClabels.CommaText);

    result := Nil;
    bestMatchCount := -1;
    bestMatches := TStringList.Create;
    hpType := GetElementEditValues(oldHeadpart, 'PNAM');
    for i := 0 to headpartLabels.Count-1 do begin
        nextHPname := headpartLabels.strings[i];
        raceIdx := headpartRaces.IndexOf(nextHPname);
        if raceIdx < 0 then begin
            if LOGGING then LogD(Format('Headpart not found in headpartRaces: %s', [nextHPname]));
            continue;
        end;
        nextHPraces := headpartRaces.objects[raceIdx];
        nextHP := ObjectToElement(headpartRecords.objects[headpartRecords.IndexOf(nextHPname)]);

        if //This is the same type of headpart
            (GetElementEditValues(nextHP, 'PNAM') = hpType) and
            // This headpart works for the current NPC's race
            (nextHPraces.IndexOf(EditorID(curNPCrace)) >= 0) and
            // This headpart works for the current NPC's sex
            NPCSexMatchesHeadpart(nextHP) and
            // This headpart has no labels that conflict with the current NPC
            (not HeadpartHasExcludedLabels(i))
        then begin
            if LOGGING then LogD(Format('Race %s in headpart %s', [EditorID(curNPCrace), PathName(nextHP)]));
            if LOGGING then LogD(Format('Checking %s with labels %s', 
                [headpartLabels.strings[i], headpartlabels.objects[i].CommaText]));
            matchCount := 0;
            for j := 0 to headpartLabels.objects[i].Count-1 do begin
                if curNPClabels.IndexOf(headpartLabels.objects[i].strings[j]) >= 0 then begin
                    if LOGGING then LogD('Matched ' + headpartLabels.objects[i].strings[j]);
                    matchCount := matchCount + 1;
                end;
            end;

            if matchCount = bestMatchCount then begin
                bestMatches.AddObject(nextHPname, nextHP);
                if LOGGING then LogD(Format('New equal match %s with %d matches', 
                    [nextHPname, bestMatchCount]));
            end
            else if matchCount > bestMatchCount then begin
                bestMatches.Clear;
                bestMatches.AddObject(nextHPname, nextHP);
                bestMatchCount := matchCount;
                if LOGGING then LogD(Format('New best match %s with %d matches', 
                    [nextHPname, bestMatchCount]));
            end;
        end;
    end;

    if bestMatches.count > 0 then begin
        if LOGGING then LogD(Format('Choosing from best matches: %s', [bestMatches.commatext]));
        hpIdx := Hash(curNPCalias, 1234, bestMatches.Count);
        result := ObjectToElement(bestMatches.objects[hpIdx]);
    end;

    bestMatches.Free;

    if LOGGING then LogExitT1('FindBestHeadpartMatch', Format('%s w/ %d matches', [Name(result), bestMatchCount]));
end;


{==================================================================
Choose an equivalent furry headpart for the given vanilla headpart using labels to
identify the most similar.
}
function FindSimilarHeadpart(npc: IwbMainRecord; oldHeadpart: IwbMainRecord): IwbMainRecord;
var
    i, j: integer;
begin
    if LOGGING then LogEntry2(5, 'FindSimilarHeadpart', Name(npc), Name(oldHeadpart));
    result := Nil;
    i := headpartLabels.IndexOf(EditorID(oldHeadpart));
    if i >= 0 then begin
        curNPClabels := TStringList.Create;
        curNPClabels.Duplicates := dupIgnore;
        curNPClabels.Sorted := True;
        LoadNPCLabels(npc);
        for j := 0 to headpartlabels.objects[i].Count-1 do begin
            AddNPCLabel(headpartlabels.objects[i].strings[j]);
        end;
        result := FindBestHeadpartMatch(oldHeadpart);
        curNPClabels.Free;
    end;
    if LOGGING then LogExitT1('FindSimilarHeadpart', Name(result));
end;


{==================================================================
Choose an equivalent furry headpart for the given vanilla headpart.
}
function FindEquivalentHP(npc: IwbMainRecord; oldHeadpart: IwbMainRecord): IwbMainRecord;
var
    h: integer;
    i: integer;
begin
    if LOGGING then LogEntry2(5, 'FindEquivalentHP', Name(npc), Name(oldHeadpart));
    i := headpartEquivalents.IndexOf(EditorID(oldHeadpart));
    if i >= 0 then begin
        h := Hash(curNPCalias, 2134, headpartEquivalents.objects[i].Count);
        result := ObjectToElement(headpartEquivalents.objects[i].objects[h]);
    end
    else
        result := FindSimilarHeadpart(npc, oldHeadpart);
    if LOGGING then LogExitT1('FindEquivalentHP', Name(result));
end;


{==================================================================
Furrify an NPC's headparts by choosing furry equivalents for vanilla headparts.
}
procedure FurrifyAllHeadparts(furryNPC, npc: IwbMainRecord);
var
    oldHeadparts: IwbContainer;
    newHeadparts: IwbContainer;
    i: integer;
    oldHP: IwbMainRecord;
    newHP: IwbMainRecord;
    hpslot: IwbElement;
begin
    if LOGGING then LogEntry1(5, 'FurrifyAllHeadparts', Name(npc));
    oldHeadparts := ElementByPath(npc, 'Head Parts');
    for i := 0 to ElementCount(oldHeadparts)-1 do begin
        oldHP := LinksTo(ElementByIndex(oldHeadparts, i));
        newHP := FindEquivalentHP(npc, oldHP);
        if Assigned(newHP) then begin
            if not ElementExists(furryNPC, 'Head Parts') then begin
                LogD('Creating Head Parts list');
                Add(furryNPC, 'Head Parts', true);
                newHeadparts := ElementByPath(furryNPC, 'Head Parts');
                hpslot := ElementByIndex(newHeadparts, 0);
            end
            else begin
                newHeadparts := ElementByPath(furryNPC, 'Head Parts');
                hpslot := ElementAssign(newHeadparts, HighInteger, Nil, false);
            end;
            if LOGGING then LogD(Format('Assigning new headpart %s at %s', 
                [EditorID(newHP), PathName(hpslot)]));
            AssignElementRef(hpslot, newHP);
        end;
    end;
    if LOGGING then LogExitT('FurrifyAllHeadparts');
end;


{==================================================================
Create a skin tone layer from the given preset.
}
procedure SetNPCTintLayer(const npc: IwbMainRecord; const skintonePreset: IwbElement);
var
    color: IwbMainRecord;
    sktLayer: IwbElement;
    tintAsset: IwbContainer;
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
        GetElementNativeValues(tintAsset, 'Tint Layer\Texture\TINI'));
    SetElementNativeValues(sktLayer, 'TIAS', GetElementNativeValues(skintonePreset, 'TIRS'));
    SetElementNativeValues(sktLayer, 'TINV', GetElementNativeValues(skintonePreset, 'TINV'));
    LogD('Assigned TINI, TIAS, TINV ' + 
        GetElementEditValues(sktLayer, 'TINI') + ', ' + 
        GetElementEditValues(sktLayer, 'TIAS') + ', ' + 
        GetElementEditValues(sktLayer, 'TINV'));

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
Select a furry tint layer for the NPC from presets in curNPCTintLayerOptions.
}
Procedure ChooseFurryTintLayer(npc: IwbMainRecord; typeIndex:integer; layerIndex: integer);
var 
    h: integer;
    presetList: IwbElement;
    skintonePreset: IwbElement;
begin
    if LOGGING then LogEntry2(5, 'ChooseFurryTintLayer', Name(npc), curNPCTintLayerOptions.objects[typeIndex].strings[layerIndex]);
    
    presetList := ObjectToElement(curNPCTintLayerOptions.objects[typeIndex].objects[layerIndex]);
    h := Hash(curNPCalias, 1455, ElementCount(presetList));
    skintonePreset := ElementByIndex(presetList, h);
    SetNPCTintLayer(npc, skintonePreset);

    if LOGGING then LogExitT('ChooseFurryTintLayer');
end;


{==================================================================
Set all the furry tint layers on the npc, choosing presets randomly.
}
Procedure ChooseFurryTints(npc: IwbMainRecord);
var
    i: integer;
    idx: Cardinal;
    h: integer;
begin
    LoadNPCSkinTones(npc);
    idx := curNPCtintLayerOptions.IndexOf('REQUIRED');
    for i := 0 to curNPCTintLayerOptions.objects[idx].Count-1 do begin
        ChooseFurryTintLayer(npc, idx, i);
    end;

    idx := curNPCTintLayerOptions.IndexOf('OPTIONAL');
    for i := 1 to 3 do begin
        h := Hash(curNPCalias, 0879+i, curNPCTintLayerOptions.objects[idx].Count*3);
        if h < curNPCTintLayerOptions.objects[idx].Count then begin
            ChooseFurryTintLayer(npc, idx, h);
        end;
    end;
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

        LoadNPC(furryNPC);

        // Clean out existing character customization
        Remove(ElementByPath(furryNPC, 'Head Parts'));
        FurrifyAllHeadparts(furryNPC, npc);
        ChooseFurryTints(furryNPC);

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
Furrify a single armor record.

    for each furrified race
        for each AA in the armor record
            if the AA is good for the furrifed race
                alternative_armor := the furry version of the AA specific to this race
                    or a furry version specific to the race class (DOG)
                    or a khajiit version
                if we found an alternative armor (which is not the AA)
                    remove the furrified race from the AA
                    add the alternative armor to the armor record
                    add the furrified race to the alternative armor
}


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
    if LOGGING then LogEntry1(5, 'AAIsFurrifiable', EditorID(addon));
    result := false;

    // Is it a furrifiable bodypart?
    bipedFlags := ElementByPath(addon, 'BOD2 - Biped Body Template\First Person Flags');
    if Assigned(bipedFlags) then begin
        result := (GetElementNativeValues(bipedFlags, 'Hair') <> 0)
            or (GetElementNativeValues(bipedFlags, 'LongHair') <> 0)
            or (GetElementNativeValues(bipedFlags, 'Hands') <> 0);
    end;

    // If it is, does it cover a furrified race?
    addlRaces := ElementByName(addon, 'Additional Races');
    for i := -1 to ElementCount(addlRaces)-1 do begin
        if i < 0 then raceName := EditorID(LinksTo(ElementByName(addon, 'RNAM')))
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
begin
    if LOGGING then LogEntry2(5, 'AARacesMatch', EditorID(addon), EditorID(race));
    result := false;
    if EditorID(LinksTo(ElementByName(addon, 'RNAM'))) = EditorID(race) then result := true;
    addList := ElementByName(addon, 'Additional Races');
    for i := 0 to ElementCount(addList)-1 do begin
        result := (EditorID(LinksTo(ElementByIndex(addList, i))) = EditorID(race));
        if result then break;
    end;
    if LOGGING then LogExitT1('AARacesMatch', BoolToStr(result));
end;

{===================================================================
Find the armor addon listed in an armor record that matches a given race.
}
function FindMatchingAddon(armor: IwbMainRecord; race: IwbMainRecord): IwbMainRecord;
var
    aaList: IwbElement;
    i: integer;
    addon: IwbMainRecord;
begin
    result := nil;
    aaList := ElementByName(armor, 'Armature');
    for i := 0 to ElementCount(aaList) - 1 do begin
        addon := WinningOverride(LinksTo(ElementByIndex(aaList, i)));
        if AARacesMatch(addon, race) then begin
            result := addon;
            exit;
        end;
    end;
end;


{===================================================================
Find the furry armor addon that works for the given race.

    Return the furry version of the AA specific to this race
        or a furry version specific to the race class (DOG)
        or a khajiit addon already on the armor
}
function FindFurryAddon(race: IwbMainRecord; armor: IwbMainRecord; rootname: string): IwbMainRecord;
var
    targetName: string;
    targIdx: integer;
    furRace: IwbMainRecord;
    classIdx: integer;
begin
    if LOGGING then LogEntry2(5, 'FindFurryAddon', EditorID(race), EditorID(armor));
    result := nil;

    // Find an addon for this race specifically
    targetName := 'YA_' + rootname + '_' + EditorID(race);
    targIdx := allAddons.IndexOf(targetName);
    if LOGGING then LogD('Found specific addon: ' + targetName + ' at ' + IntToStr(targIdx));
    if targIdx >= 0 then begin
        result := ObjectToElement(allAddons.objects[targIdx]);
    end;
    if not Assigned(result) then begin
        // Find an addon for this race class
        furRace := ObjectToElement(raceAssignments.objects[raceAssignments.IndexOf(EditorID(race))]);
        classIdx := furryRaceClass.IndexOfName(EditorID(furRace));
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
        result := FindMatchingAddon(armor, khajiitRace);
        if LOGGING and Assigned(result) then LogD('Found Khajiit addon: ' + EditorID(result));
    end;

    if LOGGING then LogExitT1('FindFurryAddon', EditorID(result));
end;


{===================================================================
Remove a race from an armor addon. Returns the addon as modified (may be an override).
}
function RemoveAddonRace(addon: IwbMainRecord; race: IwbMainRecord): IwbMainRecord;
var
    addList: IwbElement;
    i: integer;
begin
    if LOGGING then LogEntry2(5, 'RemoveAddonRace', EditorID(addon), EditorID(race));
    addList := ElementByName(addon, 'Additional Races');
    
    for i := 0 to ElementCount(addList)-1 do begin
        if EditorID(LinksTo(ElementByIndex(addList, i))) = EditorID(race) then begin
            if GetLoadOrder(GetFile(addon)) < targetFileIndex then begin
                // Need to override
                addon := MakeOverride(addon, targetFile);
                allAddons.objects[allAddons.IndexOf(EditorID(addon))] := addon;
                addlist := ElementByName(addon, 'Additional Races');
            end;
            RemoveByIndex(addList, i, false);
            break;
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
        addList: IwbElement;
        i: integer;
begin
    if LOGGING then LogEntry2(5, 'AddAddonRace', EditorID(addon), EditorID(race));
    if not AARacesMatch(addon, race) then begin
        if GetLoadOrder(GetFile(addon)) < targetFileIndex then begin
            addon := MakeOverride(addon, targetFile);
            allAddons.objects[allAddons.IndexOf(EditorID(addon))] := addon;
        end;

        if not ElementExists(addon, 'Additional Races') then Begin 
            Add(addon, 'Additional Races', true);
            i := 0;
            addList := ElementByName(addon, 'Additional Races');
        end
        else begin
            addList := ElementByName(addon, 'Additional Races');
            i := ElementCount(addList);
            ElementAssign(addList, HighInteger, nil, false);
        end;
        if LOGGING then LogD('Adding new element at index ' + IntToStr(i));
        AssignElementRef(ElementByIndex(addList, i), race);
    end;
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
        aaList := ElementByName(armor, 'Armature');
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
                aaList := ElementByName(armor, 'Armature');
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

    aaList := ElementByName(armor, 'Armature');
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
    rootName: string;
    thisAA: IwbMainRecord;
    thisArmor: IwbMainRecord;
    thisRace: IwbMainRecord;
begin
    if LOGGING then LogEntry2(5, 'FurrifyArmorRecord', IntToStr(armorIdx), furrifiableArmors[armorIdx]);
    thisArmor := ObjectToElement(furrifiableArmors.objects[armorIdx]);

    // Walk through the armor's addons looking for furrifiable addons.
    aaList := ElementByName(thisArmor, 'Armature');
    for aaIdx := 0 to ElementCount(aaList)-1 do begin
        thisAA := WinningOverride(LinksTo(ElementByIndex(aaList, aaIdx)));
        if LOGGING then LogD('Checking addon ' + EditorID(thisAA));

        faIdx := addonRaces.IndexOf(EditorID(thisAA));
        if Assigned(thisAA) and (faIdx >= 0) then begin
            rootName := AddonRootName(thisArmor);

            for raceIdx := 0 to addonRaces.objects[faIdx].count-1 do begin
                thisRace := ObjectToElement(addonRaces.objects[faIdx].objects[raceIdx]);
                if LOGGING then LogD('Checking race ' + EditorID(thisRace));

                altAA := FindFurryAddon(thisRace, thisArmor, rootName);
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
    if LOGGING then LogExitT('FurrifyArmorRecord');
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
    for f := 0 to targetFileIndex - 1 do begin
        if LOGGING Then LogD(Format('File %s with %s armors, %s addons', 
            [GetFileName(FileByIndex(f)), IntToStr(furrifiableArmors.Count), IntToStr(addonRaces.count)]));
        armorList := GroupBySignature(FileByIndex(f), 'ARMO');
        for n := 0 to ElementCount(armorList) - 1 do begin
            armor := ElementByIndex(armorList, n);
            if IsWinningOverride(armor) then begin
                isFurrifiable := false;
                if LOGGING then LogD(Format('Armor %s hair: %s hands %s:', 
                    [Name(armor),
                        GetElementEditValues(armor, 'BOD2\First Person Flags\31 - Hair'),
                        GetElementEditValues(armor, 'BOD2\First Person Flags\33 - Hands')]));
                if (GetElementNativeValues(armor, 'BOD2\First Person Flags\31 - Hair') <> 0) 
                    or (GetElementNativeValues(armor, 'BOD2\First Person Flags\33 - Hands') <> 0) 
                then begin
                    aaList := ElementByName(armor, 'Armature');
                    for aaIdx := 0 to ElementCount(aaList)-1 do begin
                        addon := WinningOverride(LinksTo(ElementByIndex(aalist, aaIdx)));
                        racesList := ElementByName(addon, 'Additional Races');
                        for raceIdx := -1 to ElementCount(racesList)-1 do begin
                            if raceIdx < 0 then race := WinningOverride(LinksTo(ElementByName(addon, 'RNAM')))
                            else race := WinningOverride(LinksTo(ElementByIndex(racesList, raceIdx)));
                            if raceAssignments.IndexOf(EditorID(race)) >= 0 then begin
                                // Is a furrifiable addon
                                isFurrifiable := true;
                                if LOGGING then LogD('Have furrifiable addon: ' + Name(addon));
                                if addonRaces.IndexOf(EditorID(addon)) < 0 then begin
                                    // furrifiableAddons.AddObject(EditorID(addon), addon);
                                    addonRaces.AddObject(EditorID(addon), TStringList.Create);
                                end;
                                addonRaces.objects[addonRaces.IndexOf(EditorID(addon))].AddObject(EditorID(race), race);
                            end;
                        end;
                    end;
                end;
                if isFurrifiable then furrifiableArmors.AddObject(EditorID(armor), armor);
            end;
        end;
    end;
    if LOGGING then LogExitT('CollectArmor');
end;


{===================================================================
Collect all armor addon records in the current load order and store them in a TStringList.
}
procedure CollectAddons;
var
    f: integer;
    n: integer;
    addonList: IwbElement;
    addon: IwbMainRecord;
begin
    if LOGGING then LogEntry(15, 'CollectAddons');
    for f := 0 to targetFileIndex - 1 do begin
        if LOGGING Then LogD('File ' + GetFileName(FileByIndex(f)));
        addonList := GroupBySignature(FileByIndex(f), 'ARMA');
        for n := 0 to ElementCount(addonList) - 1 do begin
            addon := ElementByIndex(addonList, n);
            if IsWinningOverride(addon) then begin
                allAddons.AddObject(EditorID(addon), addon);
            end;
        end;
    end;
    if LOGGING then LogExitT('CollectAddons');
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
    AddMessage('====================================');
    AddMessage('======== SKYRIM FURRIFIER ==========');
    AddMessage('====================================');
    AddMessage(' ');
    AddMessage('Version ' + FURRIFIER_VERSION);
    AddMessage('xEdit Version ' + GetXEditVersion());

    InitializeLogging;
    LOGGING := True;
    LOGLEVEL := 10;
    if LOGGING then LogEntry(1, 'Initialize');

    PreferencesInit;
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
    ShowHeadparts;
    ShowRaceTints;

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

    PreferencesFree;
    result := 0;
    if LOGGING then LogExitT('Finalize');
end;

end.