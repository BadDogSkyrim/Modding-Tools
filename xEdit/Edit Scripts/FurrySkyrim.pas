
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

    if (ContainsStr(voice, 'Emperor') or ContainsStr(voice, 'Ulfric') 
            or ContainsStr(outfit, 'Jarl') or ContainsStr(outfit, 'FineClothes')) 
        and (curNPClabels.IndexOf('MESSY') < 0) and (curNPClabels.IndexOf('FUNKY') < 0)
    then curNPClabels.Add('NOBLE');

    if ContainsStr(voice, 'Young') and (curNPClabels.IndexOf('OLD') < 0) 
    then curNPClabels.Add('YOUNG');

    if ContainsStr(voice, 'Old') and (curNPClabels.IndexOf('YOUNG') < 0) 
    then curNPClabels.Add('OLD');

    if ContainsStr(voice, 'Forsworn') and (curNPClabels.IndexOf('MILITARY') < 0) 
    then curNPClabels.Add('FEATHERS');

    if (ContainsStr(voice, 'Commander') or ContainsStr(voice, 'Soldier') or ContainsStr(voice, 'Guard')
            or ContainsStr(outfit, 'PenitusOculatus'))
        and (curNPClabels.IndexOf('FEATHERS') < 0) and (curNPClabels.IndexOf('MESSY') < 0) 
        and (curNPClabels.IndexOf('ELABORATE') < 0) and (curNPClabels.IndexOf('FUNKY') < 0)  
    then curNPClabels.Add('MILITARY');

    if (ContainsStr(outfit, 'Farmer') or ContainsStr(outfit, 'Forsworn') or ContainsStr(outfit, 'Bandit')) 
        and (curNPClabels.IndexOf('NEAT') < 0) and (curNPClabels.IndexOf('MILITARY') < 0) 
        and (curNPClabels.IndexOf('NOBLE') < 0) 
    then curNPClabels.Add('MESSY');

    if (ContainsStr(outfit, 'Tavern') or ContainsStr(outfit, 'College')) 
        and (curNPClabels.IndexOf('MESSY') < 0) 
    then curNPClabels.Add('NEAT');

    if (ContainsStr(outfit, 'Warlock') or ContainsStr(outfit, 'Bandit')) 
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
        for j := 0 to headpartlabels.objects[i].Count-1 do begin
            curNPClabels.Add(headpartlabels.objects[i].strings[j]);
        end;
        LoadNPCLabels(npc);
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
Procedure ChooseFurryTintLayer(npc: IwbMainRecord; layerIndex: integer);
var 
    h: integer;
    presetList: IwbElement;
    skintonePreset: IwbElement;
begin
    if LOGGING then LogEntry2(5, 'ChooseFurryTintLayer', Name(npc), curNPCTintLayerOptions.strings[layerIndex]);
    
    presetList := ObjectToElement(curNPCTintLayerOptions.objects[layerIndex]);
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
begin
    LoadNPCSkinTones(npc);
    for i := 0 to curNPCTintLayerOptions.Count-1 do begin
        if multivalueMasks.IndexOf(curNPCTintLayerOptions.strings[i]) < 0 then
            ChooseFurryTintLayer(npc, i);
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

    PreferencesFree;
    result := 0;
    if LOGGING then LogExitT('Finalize');
end;

end.