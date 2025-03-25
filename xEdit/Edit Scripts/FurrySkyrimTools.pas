{
}
unit FurrySkyrimTools;

interface
implementation
uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    TINT_CHEEK = 0;
    TINT_CHEEK_LOWER = 1;
    TINT_CHIN = 2;
    TINT_EYE_LOWER = 3;
    TINT_EYE_UPPER = 4;
    TINT_EYELINER = 5;
    TINT_FOREHEAD = 6;
    TINT_LAUGH = 7;
    TINT_LIP = 8;
    TINT_NECK = 9;
    TINT_NOSE = 10;
    TINT_SKIN_TONE = 11;
    TINT_MUZZLE = 12;
    TINT_MASK = 13;
    TINT_EAR = 14;
    TINT_BLACKBLOOD = 15;
    TINT_BOTHIAH = 16;
    TINT_FREKLES = 17;
    TINT_NORD = 18;
    TINT_DARKELF = 19;
    TINT_IMPERIAL = 20;
    TINT_ORC = 21;
    TINT_REDGUARD = 22;
    TINT_WOODELF = 23;
    TINT_HAND = 24;
    TINT_SKULL = 25;
    TINT_PAINT = 26;
    TINT_DIRT = 27;
    TINT_COUNT = 28;
    TINT_SPECIAL_LO = 15;

    SEX_MALEADULT = 0;
    SEX_FEMADULT = 1;
    SEX_MALECHILD = 2;
    SEX_FEMCHILD = 3;
    SEX_COUNT = 4;
    SEX_MASK = 1;
    AGE_MASK = 2;
    SEX_MALE = 0;
    SEX_FEM = 1;

    SPECIALTYPE_BLACKBLOOD = 0;
    SPECIALTYPE_BOTHIAH = 1;
    SPECIALTYPE_DIRT = 2;
    SPECIALTYPE_FREKLES = 3;
    SPECIALTYPE_PAINT = 4;
    SPECIALTYPE_COUNT = 5;

    HP_HAIR = 0;
    HP_SCAR = 1;
    HP_EYES = 2;
    HP_EYEBROWS = 3;
    HP_FACIALHAIR = 4;
    HP_UNKNOWN = 5;
    HP_COUNT = 6;


var
    // List of vanilla race names; values are the furry equivalent IwbMainRecord.
    raceAssignments: TStringList;

    // List of vanilla races being furrified. Values are the IwbMainRecord of the race.
    vanillaRaces: TStringList;

    // List of furry race names; values are the vanilla IWbMainRecord they furrify.
    furryRaces: TStringList;

    // Name/value list of furry race classes. Values are the race's class. Only furry
    // races with defind classes are in the list.
    furryRaceClass: TStringList;

    // Default armor races: key is furry race name, value is vanilla race record. When an
    // armor addon tailored to the furry race cannot be found, the armor addon for this
    // race will be used. 
    armorRaces: TStringList;

    // List of vanilla headpart names; values are a list of equivalent furry headpart
    // names. This is for when the user wants a 1:1 match (or 1:choices match) between
    // vanilla and furry headparts.
    headpartEquivalents: TStringList;

    // Array indexed by hp type, sex, and race (by stringlist). 
    // Values are a stringlist of headpart name : headpart record.
    raceHeadparts: array[0..5 {HP_COUNT}, 0..3 {SEX_COUNT}] of TStringList;

    // List of headpart names; values are a list of labels for that headpart.
    headpartLabels: TStringList;

    // List of labels that conflict with each other. Format is 'label1/label2'.
    labelConflicts: TStringList;

    // List of headpart names; values are the IWbMainRecord of the headpart.
    headpartRecords: TStringList;

    // // List of headpart names; values are a stringlist of allowed races.
    // headpartRaces: TStringList;

    // List of NPC aliases keyed to the NPC's base name.
    NPCaliases: TStringList;

    // Paths to male/female tint layers.
    tintMaskPaths: TStringList;

    // Index into tint asset layers. 
    // tintAssets[sex].objects[racename].objects[TINI] 1:1 with tint asset layers.
    tintAssets: array[0..3 {SEX_COUNT}] of TStringList;

    tintlayerNames: TStringList;

    // Index of tint layer file names to mask types.
    tintFileTypes: TStringList;

    targetFile: IwbFile;
    targetFileIndex: integer;

    // All furrifiable armors (furrifiable bodyparts)
    furrifiableArmors: TStringList;

    // All armor addons. Key: name, value: IwbMainRecord
    allAddons: TStringList;

    // Races associated with furrifiable addons. Key: addon name, value: TStringList of races.
    addonRaces: TStringList;

    // Information about the NPC being furrified. Global variables because we can't 
    // pass structures in procedure calls.
    curNPC: IwbMainRecord;
    curNPCoriginal: IwbMainRecord;
    curNPCrace: IwbMainRecord;
    curNPCFurryRace: IwbMainRecord;
    curNPCsex: integer;
    // curNPCTintLayerOptions: IwbMainRecord;
    curNPClabels: TStringList;
    curNPCalias: string;

    indexList: TStringList;


Procedure PreferencesInit;
var j, k: integer;
begin
    if LOGGING then LogEntry(20, 'PreferencesInit');
    raceAssignments := TStringList.Create;
    raceAssignments.Duplicates := dupIgnore;
    raceAssignments.Sorted := true;

    furryRaces := TStringList.Create;
    furryRaces.Duplicates := dupIgnore;
    furryRaces.Sorted := true;

    furryRaceClass := TStringList.Create;
    furryRaceClass.Duplicates := dupIgnore;
    furryRaceClass.Sorted := true;

    armorRaces := TStringList.Create;
    armorRaces.Duplicates := dupIgnore;
    armorRaces.Sorted := true;

    vanillaRaces := TStringList.Create;
    vanillaRaces.Duplicates := dupIgnore;
    vanillaRaces.Sorted := true;

    headpartEquivalents := TStringList.Create;
    headpartEquivalents.Duplicates := dupIgnore;
    headpartEquivalents.Sorted := true;

    headpartLabels := TStringList.Create;
    headpartLabels.Duplicates := dupIgnore;
    headpartLabels.Sorted := true;

    labelConflicts := TStringList.Create;
    labelConflicts.Duplicates := dupIgnore;
    labelConflicts.Sorted := true;

    headpartRecords := TStringList.Create;
    headpartRecords.Duplicates := dupIgnore;
    headpartRecords.Sorted := true;

    NPCaliases := TStringList.Create;
    NPCaliases.Duplicates := dupIgnore;
    NPCaliases.Sorted := true;

    tintlayerNames := TStringList.Create;
    tintlayerNames.sorted := false;
    // Order matches TINT constants
    tintlayerNames.Add('Cheek Color');
    tintlayerNames.Add('Cheek Color Lower');
    tintlayerNames.Add('Chin');
    tintlayerNames.Add('EyeSocket Lower');
    tintlayerNames.Add('EyeSocket Upper');
    tintlayerNames.Add('Eyeliner');
    tintlayerNames.Add('Forehead');
    tintlayerNames.Add('Laugh Lines');
    tintlayerNames.Add('Lip Color');
    tintlayerNames.Add('Neck');
    tintlayerNames.Add('Nose');
    tintlayerNames.Add('Skin Tone');
    tintlayerNames.Add('Muzzle');
    tintlayerNames.Add('Mask');
    tintlayerNames.Add('Ear');
    tintlayerNames.Add('BlackBlood');
    tintlayerNames.Add('Bothiah');
    tintlayerNames.Add('Frekles');
    tintlayerNames.Add('Nord Paint');
    tintlayerNames.Add('Dark Elf Paint');
    tintlayerNames.Add('Imperial Paint');
    tintlayerNames.Add('Orc Paint');
    tintlayerNames.Add('Redguard Paint');
    tintlayerNames.Add('Wood Elf Paint');
    tintlayerNames.Add('Hand Paint');
    tintlayerNames.Add('Skull Paint');
    tintlayerNames.Add('Paint');
    tintlayerNames.Add('Dirt');

    tintFileTypes := TStringList.Create;

    for k := 0 to SEX_COUNT-1 do begin
        tintAssets[k] := TStringList.Create;
        tintAssets[k].Duplicates := dupIgnore;
        tintAssets[k].Sorted := True;
    end;

    for j := 0 to HP_COUNT-1 do begin
        for k := 0 to SEX_COUNT-1 do begin
            raceHeadparts[j, k] := TStringList.Create;
            raceHeadparts[j, k].duplicates := dupIgnore;
            raceHeadparts[j, k].sorted := True;
        end;
    end;

    tintMaskPaths := TStringList.Create;
    tintMaskPaths.Add('Head Data\Male Head Data\Tint Masks');
    tintMaskPaths.Add('Head Data\Female Head Data\Tint Masks');
    tintMaskPaths.Add('Head Data\Male Head Data\Tint Masks');
    tintMaskPaths.Add('Head Data\Female Head Data\Tint Masks');

    furrifiableArmors := TStringList.Create;
    furrifiableArmors.Duplicates := dupIgnore;
    furrifiableArmors.Sorted := true;

    addonRaces := TStringList.Create;
    addonRaces.Duplicates := dupIgnore;
    addonRaces.Sorted := true;

    allAddons := TStringList.Create;
    allAddons.Duplicates := dupIgnore;
    allAddons.Sorted := true;

    if LOGGING then LogExitT('PreferencesInit');
end;

Procedure PreferencesFree;
var i, tintIdx, sexIdx, typeIdx, m: Cardinal;
begin
    if LOGGING then LogEntry(20, 'PreferencesFree');
    raceAssignments.Free;
    furryRaces.Free;
    furryRaceClass.Free;
    armorRaces.Free;
    vanillaRaces.free;

    for i := 0 to headpartEquivalents.Count-1 do
        headpartEquivalents.objects[i].Free;
    headpartEquivalents.Free;

    for i := 0 to headpartLabels.Count-1 do
        headpartLabels.objects[i].Free;
    headpartLabels.Free;
    labelConflicts.Free;

    headpartRecords.Free;

    for typeIdx := 0 to HP_COUNT-1 do begin
        for sexIdx := 0 to SEX_COUNT-1 do begin
            for i := 0 to raceHeadparts[typeIdx, sexIdx].Count-1 do begin
                raceHeadparts[typeIdx, sexIdx].objects[i].Free;
            end;
            raceHeadparts[typeIdx, sexIdx].Free;
        end;
    end;
    
    NPCaliases.Free;

    for sexIdx := 0 to SEX_COUNT-1 do begin
        for i := 0 to tintAssets[sexIdx].count-1 do begin
            tintAssets[sexIdx].objects[i].Free;
        end;
        tintAssets[sexIdx].Free;
    end;

    tintlayerNames.Free;
    tintMaskPaths.Free;
    tintFileTypes.Free;
    furrifiableArmors.free;
    allAddons.free;
    indexList.Free;

    for i := 0 to addonRaces.count-1 do 
        addonRaces.objects[i].free;
    addonRaces.free;
    if LOGGING then LogExitT('PreferencesFree');
end;


function SexToStr(s: integer): string;
begin
    result := IfThen(s and 1, 'FEM', 'MALE') + IfThen(s and 2, 'CHILD', 'ADULT');
end;


// function TintlayerToStr(tintLayerCode: integer): string;
// begin
//     if tintLayerCode = TINT_CHEEK then result := 'Cheek Color'
//     else if tintLayerCode = TINT_CHEEK_LOWER then result := 'Cheek Color Lower'
//     else if tintLayerCode = TINT_CHIN then result := 'Chin'
//     else if tintLayerCode = TINT_EYE_LOWER then result := 'EyeSocket Lower'
//     else if tintLayerCode = TINT_EYE_UPPER then result := 'EyeSocket Upper'
//     else if tintLayerCode = TINT_EYELINER then result := 'Eyeliner'
//     else if tintLayerCode = TINT_FOREHEAD then result := 'Forehead'
//     else if tintLayerCode = TINT_LAUGH then result := 'Laugh Lines'
//     else if tintLayerCode = TINT_LIP then result := 'Lip Color'
//     else if tintLayerCode = TINT_NECK then result := 'Neck'
//     else if tintLayerCode = TINT_NOSE then result := 'Nose'
//     else if tintLayerCode = TINT_SKIN_TONE then result := 'Skin Tone'
//     else result := 'Unknown';
// end;


function StrToHeadpart(s: string): integer;
begin
    if s = 'Hair' then result := HP_HAIR
    else if s = 'Scar' then result := HP_SCAR
    else if s = 'Eyes' then result := HP_EYES
    else if s = 'Eyebrows' then result := HP_EYEBROWS
    else if s = 'Facial Hair' then result := HP_FACIALHAIR
    else result := HP_UNKNOWN;
end;


function HeadpartToStr(headpartCode: integer): string;
begin
    if headpartCode = HP_HAIR then result := 'Hair'
    else if headpartCode = HP_SCAR then result := 'Scar'
    else if headpartCode = HP_EYES then result := 'Eyes'
    else if headpartCode = HP_EYEBROWS then result := 'Eyebrows'
    else if headpartCode = HP_FACIALHAIR then result := 'Facial Hair'
    else result := 'Unknown';
end;


{=======================================================================
Return the highest override prior to the furry plugin.
}
function PreFurry(aRecord: IwbMainRecord): IwbMainRecord;
var
    i: integer;
    masterRecord, overrideRecord: IwbMainRecord;
begin
    if LOGGING then LogEntry1(15, 'PreFurry', PathName(aRecord));
    masterRecord := MasterOrSelf(aRecord);
    Result := masterRecord;
    for i := 0 to Pred(OverrideCount(masterRecord)) do begin
        if i = 0 then overrideRecord := masterRecord
        else overrideRecord := OverrideByIndex(masterRecord, i-1);
        if GetLoadOrder(GetFile(overrideRecord)) < targetFileIndex then 
            Result := overrideRecord
        else
            break;
    end;
    if LOGGING then LogExitT1('PreFurry', PathName(result));
end;


{==================================================================
Randomize the IndexList with the given seed.
}
procedure RandomizeIndexList(hashstr:string; seed: integer; listlen: integer);
var
    hs: string;
    hv: integer;
    i: integer;
begin
    if LOGGING then LogEntry3(20, 'RandomizeIndexList', hashstr, IntToStr(seed), IntToStr(listlen));
    if Assigned(indexList) then indexList.Free;
    indexList := TStringList.Create;
    indexList.Duplicates := dupIgnore;
    indexList.Sorted := True;
    while indexList.Count < listlen do begin
        hs := hashstr + IntToHex(indexList.Count*1000, 8);
        hv := Hash(hs, seed, 1000);
        if LOGGING then LogD(Format('Hash: %s %s = %s', [hs, IntToStr(seed), IntToStr(hv)]));
        i := indexList.Count;
        indexList.AddObject(hv, i+0);
        if LOGGING then LogD(Format('Added [%s] %s - %s', [
            IntToStr(i), indexList[i], IntToStr(Integer(indexList.objects[i]))]));
    end;
    if LOGGING then LogExitT('RandomizeIndexList');
end;


{=======================================================================
Record the given race tint info.
}
procedure AddRaceTintIndex(sexIdx: integer;
                theRace: IwbMainRecord;
                layerindex: string;
                layername: string;
                filename: string);
var k: integer;
begin
    k := raceTintIndices[sexIdx].IndexOf(EditorID(theRace));
    if k < 0 then begin
        raceTintIndices[sexIdx].AddObject(EditorID(theRace), TStringList.Create);
        k := raceTintIndices[sexIdx].IndexOf(EditorID(theRace));
    end;
    raceTintIndices[sexIdx].Objects[k].Add(layerindex + '=' + layername + ':' + filename)
end;


{====================================================================
Preload skin tint info for a race.
}
procedure LoadRaceTints(theRace: IwbMainRecord);
var
    i, j, k, r: integer;
    layerIdx: integer;
    layername: string;
    layerindex: string;
    racetintmasks: IwbElement;
    required: string;
    sexIdx: integer;
    specialIdx: Integer;
    t: IwbElement;
    tintfile: string;
    raceTints: TStringList;
begin
    if LOGGING then LogEntry1(15, 'LoadRaceTints', Name(theRace));

    for sexIdx := SEX_MALEADULT to SEX_FEMADULT do begin
        r := tintAssets[sexIdx].IndexOf(EditorID(theRace));

        // If we don't already have the tint assets for this race, load them now.
        if r < 0 then begin
            raceTints := TStringList.Create;

            racetintmasks := ElementByPath(theRace, tintMaskPaths.strings[sexIdx]);
            for j := 0 to ElementCount(racetintmasks)-1 do begin
                t := ElementByIndex(racetintmasks, j);
                layerindex := GetElementEditValues(t, 'Tint Layer\Texture\TINI - Index');
                layername := GetElementEditValues(t, 'Tint Layer\Texture\TINP - Mask Type');
                tintfile := ExtractFilename(GetElementEditValues(t, 'Tint Layer\Texture\TINT'));

                raceTints.Add(layerindex);
            end;

            tintAssets[sexIdx].AddObject(EditorID(theRace), raceTints);
        end;
    end;

    if LOGGING then LogExitT('LoadRaceTints');
end;


function TintLayerToStr(tint: integer): string;
begin
    if (tint >= 0) and (tint < tintlayerNames.Count) then result := tintlayerNames[tint]
    else result := 'UNKNOWN TINT ' + IntToStr(tint);
end;


{===============================================================================
Record a tint layer type for a furry race.
TODO: Might need to separate tint layer types by race in the future.
}
procedure SetTintLayerType(racename, filename: string; masktype: integer);
begin
    tintFileTypes.AddObject(filename, masktype);
end;


{================================================================================
Return the layer ID of the given tint layer. This is the mask name unless it's a special layer--
one of the special paints or a dirt layer used for extra patterns.
}
function GetLayerID(tintAsset: IwbElement): integer;
var
    fp, fn, mn: string;
    fni, i: integer;
begin
    if LOGGING then LogEntry1(20, 'GetLayerID', PathName(tintAsset));
    result := -1;
    fp := GetElementEditValues(tintAsset, 'Tint Layer\Texture\TINT');
    fn := ExtractFileName(fp);
    fni := tintFileTypes.IndexOf(fn);
    if fni >= 0 then
        result := Integer(tintFileTypes.objects[fni])
    else begin
        mn := GetElementEditValues(tintAsset, 'Tint Layer\Texture\TINP');
        if LOGGING then LogD(Format('Layer mask name "%s", file "%s"', [mn, fn]));
        i := tintlayerNames.IndexOf(mn);
        if (i >= 0) and (i <> TINT_PAINT) and (i <> TINT_DIRT) then 
            result := i
        else begin
            if ContainsText(fn, 'Frekles') then result := TINT_FREKLES
            else if ContainsText(fn, 'BlackBlood') then result := TINT_BLACKBLOOD
            else if ContainsText(fn, 'Bothiah') then result := TINT_BOTHIAH
            else if ContainsText(fn, 'Mask') then result := TINT_MASK
            else if ContainsText(fn, 'Muzzle') then result := TINT_MUZZLE
            else if ContainsText(fn, 'NordWarPaint') then result := TINT_NORD
            else if ContainsText(fn, 'DarkElfWarPaint') then result := TINT_DARKELF
            else if ContainsText(fn, 'ImperialWarPaint') then result := TINT_IMPERIAL
            else if ContainsText(fn, 'OrcWarPaint') then result := TINT_ORC
            else if ContainsText(fn, 'RedguardWarPaint') then result := TINT_REDGUARD
            else if ContainsText(fn, 'WoodElfWarPaint') then result := TINT_WOODELF
            else result := i;
        end;
    end;
    if LOGGING then LogExitT1('GetLayerID', TintlayerToStr(result));
end;


{================================================================================
Determine whether the original version of NPC currently being furrified had a layer with
the given layer name.
}
function CurNPCHasTintLayer(layerID: integer): Boolean;
var
    i: integer;
    tintLayer: IwbElement;
    tintLayerTINI: string;
    tintLayerTINV: float;
    TINIi: integer;
    npcTintLayers: IwbElement;
    rti: integer;
    raceTintLayer: IwbElement;
    maskTypeID: integer;
begin
    if LOGGING then LogEntry1(10, 'CurNPCHasTintLayer', TintLayerToStr(layerID));
    Result := False;
    npcTintLayers := ElementByPath(curNPCoriginal, 'Tint Layers');
    if Assigned(npcTintLayers) then begin
        for i := 0 to ElementCount(npcTintLayers) - 1 do begin
            // Walk through each of the NPC's tint layers
            tintLayer := ElementByIndex(npcTintLayers, i);
            tintLayerTINV := GetElementNativeValues(tintLayer, 'TINV');
            if tintLayerTINV > 0.01 then begin
                // Tint layer actually is visible
                tintLayerTINI := GetElementEditValues(tintLayer, 'TINI');
                rti := tintAssets[curNPCsex].IndexOf(EditorID(curNPCrace));
                if rti >= 0 then begin
                    // We have tint layers for this race (should be always)
                    TINIi := tintAssets[curNPCsex].objects[rti].IndexOf(tintLayerTINI);
                    if TINIi >= 0 then begin
                        // NPC TInt layer is valid for this race
                        raceTintLayer := ElementByIndex(
                            ElementByPath(PreFurry(curNPCrace), tintMaskPaths[curNPCsex]),
                            TINIi);
                        if LOGGING then LogD('Have race tint layer ' + PathName(raceTintLayer));
                        maskTypeID := GetLayerID(raceTintlayer);
                        result := (maskTypeID = layerID);
                    end;
                end;
                If LOGGING then LogD(Format('Tint Layer Match Index:%s TINI:%s TINP:%s = %s', [
                    IntToStr(tintAssets[curNPCsex].objects[rti].IndexOf(tintLayerTINI)), 
                    tintLayerTINI, 
                    TintLayerToStr(maskTypeID), 
                    BoolToStr(result)]));
            end;
            if result then break;
        end;
    end;
    if LOGGING then LogExitT1('CurNPCHasTintLayer', BoolToStr(Result));
end;

procedure ShowRaceTints;
var
    r, s, l, t: Cardinal;
begin
    AddMessage('==Race Tint Layers==');
    for s := 0 to SEX_COUNT-1 do begin
        AddMessage('|   ' + SexToStr(s));
        for r := 0 to tintAssets[s].count-1 do begin
            AddMessage('|   |   ' + tintAssets[s].strings[r]);
            for t := 0 to tintAssets[s].objects[r].count-1 do begin
                AddMessage('|   |   |   ' + tintAssets[s].objects[r].strings[t] + ' = ' 
                    + IntToStr(t));
            end;
        end;
    end;
    AddMessage('--Race Tint Layers--');
end;


{========================================================================
Record a vanilla to furry race equivalent. 
}
Procedure SetRace(vanillaRaceName, furryRaceName, frClass, defaultArmorRace: String);
var
    vanillaRace: IwbMainRecord;
    furryRace: IwbMainRecord;
    armorRace: IwbMainRecord;
begin
    if LOGGING then LogEntry2(1, 'SetRace', vanillaRaceName, furryRaceName);
    vanillaRace := FindAsset(Nil, 'RACE', vanillaRaceName);
    furryRace := FindAsset(Nil, 'RACE', furryRaceName);
    if not Assigned(furryRace) then 
        Err(Format('Race %s not found', [furryRaceName]))
    else if not Assigned(vanillaRace) then 
        Err(Format('Race %s not found', [vanillaRaceName]))
    else begin
        raceAssignments.AddObject(vanillaRaceName, WinningOverride(furryRace));

        if furryRaces.IndexOf(furryRaceName) < 0 then begin
            furryRaces.AddObject(furryRaceName, WinningOverride(vanillaRace));
            LoadRaceTints(furryRace);
        end;

        if vanillaRaces.IndexOf(vanillaRaceName) < 0 then begin
            vanillaRaces.AddObject(vanillaRaceName, WinningOverride(vanillaRace));
            LoadRaceTints(vanillaRace);
        end;

        if frClass <> '' then furryRaceClass.add(furryRaceName + '=' + frClass);
        if defaultArmorRace <> '' then begin
            armorRace := FindAsset(nil, 'RACE', defaultArmorRace);
            if not Assigned(armorRace) then
                Err(Format('Race %s not found', [defaultArmorRace]))
            else begin
                furryRaces.AddObject(defaultArmorRace, armorRace);
                armorRaces.add(furryRaceName + '=' + defaultArmorRace);
            End;
        end;
    end; 
    if LOGGING then LogExitT1('SetRace', EditorID(furryRace));
end;


Procedure ShowRaceAssignments;
var i: integer;
begin
    AddMessage('==RACE ASSIGNMENTS==');
    for i := 0 to raceAssignments.Count-1 do begin
        AddMessage(Format('Race assignment %s -> %s', [
            raceAssignments[i], EditorID(ObjectToElement(raceAssignments.objects[i]))]));
    end;
    AddMessage('--RACE ASSIGNMENTS--');
end;


{=====================================================================
Add any races on the vanilla headpart to the furry headpart list. Remove the vanilla race
from the vanilla heapart list.
}
procedure FurrifyHeadpartRace(vanillaHP, furryHP: IwbMainRecord);
var
    vanillaHPlist: IwbMainRecord;
    furryHPlist: IwbMainRecord;
    i: integer;
begin
    vanillaHPlist := WinningOverride(LinksTo(ElementByPath(vanillaHP, 'RNAM')));
    vl := ElementByPath(vanillaHPlist, 'FormIDs');
    furryHPlistOriginal := WinningOverride(LinksTo(ElementByPath(furryHP, 'RNAM')));
    furryHPlist := MakeOverride(furryHPlistOriginal, furryHP);
    fl := ElementByPath(furryHPlist, 'FormIDs');
    for i := 0 to vl.ElementCount-1 do begin
        ElementAssign(fl, HighInteger, ElementByIndex(vl, i), false);
    end;
end;


{==================================================================
Determine whether the headpart sex works for the current NPC.
}
function SexMatchesHeadpart(hp: iwbMainRecord; sex: integer): boolean;
begin
    result := (
        (GetElementEditValues(hp, 'DATA - Flags\Male') and ((sex and SEX_MASK) = SEX_MALE))
        or (GetElementEditValues(hp, 'DATA - Flags\Female') and ((sex and SEX_MASK) = SEX_FEM))
    );
end;


{==================================================================
Record headpart assignments.
}
procedure RecordHeadpartAssignments;
var
    hpIter, s, rIdx, r: integer;
    hp: IwbMainRecord;
    hpType: integer;
    formlist: IwbMainRecord;
    racelist: IwbElement;
    racename: string;
    sl: TStringList;
begin
    for hpIter := 0 to headpartRecords.Count-1 do begin
        hp := ObjectToElement(headpartRecords.objects[hpIter]);
        hpType := StrToHeadpart(GetElementEditValues(hp, 'PNAM'));

        for s := SEX_MALEADULT to SEX_FEMADULT do begin
            if SexMatchesHeadpart(hp, s) then begin
                formlist := WinningOverride(LinksTo(ElementByPath(hp, 'RNAM')));
                racelist := ElementByName(formlist, 'FormIDs');
                for rIdx := 0 to ElementCount(racelist)-1 do begin
                    racename := EditorID(LinksTo(ElementByIndex(racelist, rIdx)));
                    r := raceHeadparts[hpType, s].IndexOf(racename);
                    if r < 0 then begin
                        sl := TStringList.Create;
                        sl.Duplicates := dupIgnore;
                        sl.Sorted := true;
                        raceHeadparts[hpType, s].AddObject(racename, sl);
                        r := raceHeadparts[hpType, s].IndexOf(racename);
                    end;
                    raceHeadparts[hpType, s].objects[r].AddObject(EditorID(hp), hp);
                end;
            end;
        end;
    end;
end;


{===================================================================== 
Go through all headparts and remove furrified vanilla races from their headpart lists.
Also add the vanilla to the furry headpart lists. 
Sets up raceHeadparts.
}
procedure FurrifyHeadpartLists;
var
    furrifiedHPlists: TStringList;
    haveChanges: boolean;
    headpartList: IwbMainRecord;
    hp: IwbMainRecord;
    hpFormlist: IwbElement;
    hpFormlistOvr: IwbElement;
    hpIter, raceIter: integer;
    hpNewList: TStringList;
    hpOverride: IwbMainRecord;
    hpType: integer;
    i: integer;
    r: integer;
    race: IwbMainRecord;
    racename: string;
    s: integer;
    sl: TStringList;
    vanillaRaceIdx, furryRaceIdx: integer;
begin
    if LOGGING then LogEntry(15, 'FurrifyHeadpartLists');

    furrifiedHPlists := TStringList.Create;
    furrifiedHPlists.Duplicates := dupIgnore;
    furrifiedHPlists.Sorted := true;

    // Only look at formlists associated with headparts we've been told about.
    for hpIter := 0 to headpartRecords.Count-1 do begin
        haveChanges := false;
        hp := ObjectToElement(headpartRecords.objects[hpIter]);
        hpType := StrToHeadpart(GetElementEditValues(hp, 'PNAM'));

        if LOGGING then LogT(Format('Checking headpart %s', [Name(hp)]));
        
        headpartList := WinningOverride(LinksTo(ElementByPath(hp, 'RNAM')));

        if furrifiedHPlists.IndexOf(EditorID(headpartList)) >= 0 then continue;
        furrifiedHPlists.Add(EditorID(headpartList));

        hpFormlist := ElementByPath(headpartList, 'FormIDs');
        hpNewList := TStringList.Create;
        for raceIter := 0 to ElementCount(hpFormList)-1 do begin
            race := WinningOverride(LinksTo(ElementByIndex(hpFormList, raceIter)));
            vanillaRaceIdx := raceAssignments.IndexOf(EditorID(race));
            if vanillaRaceIdx >= 0 then begin
                // We have a vanilla race that has been furrified. Leave it off the
                // vanilla race.
                if LOGGING then LogT(Format('Contains vanilla race %s', 
                    [raceAssignments.strings[vanillaRaceIdx]]));
                haveChanges := true;
            end
            else begin
                // If a furry race, or an unaffected race, just copy to new list.
                hpNewList.AddObject(EditorID(race), race);

                furryRaceIdx := furryRaces.IndexOf(EditorID(race));
                if furryRaceIdx >= 0 then begin
                    // We have a furry race, so add its vanilla race to the list. 
                    if LOGGING then LogT(Format('Contains furry race %s', 
                        [furryRaces.strings[furryRaceIdx]])); 
                    hpNewList.AddObject(EditorID(ObjectToElement(furryRaces.objects[furryRaceIdx])), 
                        furryRaces.objects[furryRaceIdx]);
                end;
                haveChanges := true;
            end;
        end;

        if LOGGING then LogT(Format('Headpart %s has new races %s', [Name(headpartList), hpNewList.CommaText]));

        // If we made changes, update the headpart list.
        if haveChanges then begin
            hpOverride := MakeOverride(headpartList, targetFile);
            Remove(ElementByPath(hpOverride, 'FormIDs'));
            if hpNewList.Count > 0 then begin
                hpFormlistOvr := Add(hpOverride, 'FormIDs', true);
                for i := 0 to hpNewList.Count-1 do begin
                    ElementAssign(hpFormlistOvr, i, ObjectToElement(hpNewList.objects[i]), false);
                end;
            end;
        end;

        hpNewList.Free;
    end;

    furrifiedHPlists.Free;
    RecordHeadpartAssignments;

    if LOGGING then LogExitT('FurrifyHeadpartLists');
end;


{=====================================================================
The given vanilla headpart is converted to the given furry headpart. There may be more
than one furry headpart; if so one will be chosen at random.
}
procedure AssignHeadpart(vanillaHPName, furryHPName: string);
var
    furryHP: IwbMainRecord;
    hpi: integer;
    hplist: TStringList;
    vanillaHP: IwbMainRecord;
begin
    if LOGGING then LogEntry2(1, 'AssignHeadpart', vanillaHPName, furryHPName);

    vanillaHP := FindAsset(Nil, 'HDPT', vanillaHPName);
    furryHP := FindAsset(Nil, 'HDPT', furryHPName);
    if not Assigned(furryHP) then Err(Format('Headpart %s not found', [furryHPName]));
    if not Assigned(vanillaHP) then Err(Format('Headpart %s not found', [vanillaHPName]));
    if Assigned(furryHP) and Assigned(vanillaHP) then begin
        hpi := headpartEquivalents.IndexOf(vanillaHPName);
        if hpi < 0 then begin
            hplist := TStringList.Create;
            headpartEquivalents.AddObject(vanillaHPName, hplist);
            hpi := headpartEquivalents.IndexOf(vanillaHPName);
        end;
        headpartRecords.AddObject(vanillaHPName, vanillaHP);
        headpartRecords.AddObject(furryHPName, furryHP);
        headpartEquivalents.objects[hpi].AddObject(vanillaHPName, WinningOverride(furryHP));
    end; 

    if LOGGING then LogExitT1('AssignHeadpart', EditorID(furryHP));
end;


{=====================================================================
Define label conflicts
}
procedure LabelConflict(label1, label2: string);
begin
    labelConflicts.Add(label1 + '/' + label2);
    labelConflicts.Add(label2 + '/' + label1);
end;


function LabelsConflict(const label1, label2: string): boolean;
begin
    result := (labelConflicts.IndexOf(label1 + '/' + label2) >= 0);
end;


{=====================================================================
Assign a label to a headpart. Labels are used to identify appropriate furry headparts for
a NPC.
}
procedure LabelHeadpart(headpartName, labelName: string);
var
    hpi: integer;
    hpRecord: IwbMainRecord;
begin
    if LOGGING then LogEntry2(1, 'LabelHeadpart', headpartName, labelName);
    hpRecord := FindAsset(Nil, 'HDPT', headpartName);
    if not Assigned(hpRecord) then Err(Format('Headpart %s not found', [headpartName]));
    hpi := headpartLabels.IndexOf(headpartName);
    if hpi < 0 then begin
        headpartLabels.AddObject(headpartName, TStringList.Create);
        hpi := headpartLabels.IndexOf(headpartName);
        headpartLabels.objects[hpi].duplicates := dupIgnore;
    end;
    headpartLabels.objects[hpi].Add(labelName);
    headpartRecords.AddObject(EditorID(hp), hp);
    // CacheHeadpart(hpRecord);
    if LOGGING then LogExitT('LabelHeadpart');
end;


{=====================================================================
Assign a comma-separated list of labels to a headpart. Labels are used to identify
appropriate furry headparts for a NPC.
}
procedure LabelHeadpartList(headpartName, labelNames: string);
var
    hpi: integer;
    hpRecord: IwbMainRecord;
begin
    if LOGGING then LogEntry2(1, 'LabelHeadpartList', headpartName, labelNames);
    hpRecord := FindAsset(Nil, 'HDPT', headpartName);
    if not Assigned(hpRecord) then Err(Format('Headpart %s not found', [headpartName]));
    hpi := headpartLabels.IndexOf(headpartName);
    if hpi < 0 then begin
        headpartLabels.AddObject(headpartName, TStringList.Create);
        hpi := headpartLabels.IndexOf(headpartName);
        headpartLabels.objects[hpi].duplicates := dupIgnore;
        headpartLabels.objects[hpi].sorted := true;
    end;
    headpartLabels.objects[hpi].commaText := labelNames;
    headpartRecords.AddObject(headpartName, hpRecord);
    // CacheHeadpart(hpRecord);
    if LOGGING then LogExitT('LabelHeadpartList');
end;


procedure ShowHeadparts;
var i, j, t, s, r, h: integer;
begin
    AddMessage('==HEADPART EQUIVALENTS==');
    for i := 0 to headpartEquivalents.Count-1 do begin
        AddMessage(headpartEquivalents.strings[i]);
        for j := 0 to headpartEquivalents.objects[i].Count-1 do begin
            AddMessage('|   ' + Name(ObjectToElement(headpartEquivalents.objects[i].objects[j])));
        end;
    end;
    AddMessage('--HEADPART EQUIVALENTS--');
    AddMessage('==HEADPART LABELS==');
    for i := 0 to headpartLabels.Count-1 do begin
        AddMessage(headpartLabels.strings[i] + ': ' + headpartLabels.objects[i].CommaText);
    end;
    AddMessage('--HEADPART LABELS--');
    AddMessage('==HEADPART RACES==');
    for t := 0 to HP_COUNT - 1 do begin
        AddMessage(HeadpartToStr(t));
        for s := 0 to SEX_COUNT-1 do begin
            AddMessage('|   ' + SexToStr(s));
            for r := 0 to raceHeadparts[t, s].Count - 1 do begin
                AddMessage('|   |   ' + raceHeadparts[t, s].strings[r]);
                for h := 0 to raceHeadparts[t, s].objects[r].Count - 1 do begin
                    AddMessage('|   |   |   ' + raceHeadparts[t, s].objects[r].strings[h]);
                end;
            end;
        end;
    end;
    AddMessage('--HEADPART RACES--');
end;


{============================================================================
Some NPCs have multiple NPC records. This makes sure all records look the same.
}
procedure NPCEquivalent(npcalias, basenpc: string);
var
    alist: TStringList;
    i: integer;
begin
    NPCaliases.Add(npcalias + '=' + basenpc);
end;


function Unalias(alias: string): string;
var i: integer;
begin
    result := NPCaliases.values[alias];
    if result = '' then result := alias;
end;


procedure ShowNPCAliases;
var i: integer;
begin
    AddMessage('==NPC ALIASES==');
    for i := 0 to NPCaliases.Count-1 do begin
        AddMessage(NPCaliases.names[i] + ' = ' + NPCaliases.values[NPCaliases.names[i]]);
    end;
    AddMessage('==NPC ALIASES==');
end;


{============================================================================
Load up the cur* global variables with info from the current NPC.
}
procedure LoadNPC(npc, originalNPC: IwbMainRecord);
var 
    raceIdx, sexIdx, presetsIdx: integer;
begin
    if LOGGING then LogEntry1(10, 'LoadNPC', Name(npc));
    curNPC := npc;
    curNPCoriginal := originalNPC;
    curNPCrace := LinksTo(ElementByPath(npc, 'RNAM'));
    curNPCFurryRace := ObjectToElement(raceAssignments.objects[raceAssignments.IndexOf(EditorID(curNPCrace))]);
    LogT('Race is ' + EditorID(curNPCrace));
    LogT('FUrry Race is ' + EditorID(curNPCFurryrace));
    LogT('Sex is ' + GetElementEditValues(npc, 'ACBS - Configuration\Flags\Female'));
    LogT('Age is ' + GetElementEditValues(curNPCrace, 'DATA - DATA\Flags\Child'));
    curNPCsex := IfThen(GetElementEditValues(npc, 'ACBS - Configuration\Flags\Female') = '1',
        SEX_FEMADULT, SEX_MALEADULT) 
        + IfThen(GetElementEditValues(curNPCrace, 'DATA - DATA\Flags\Child') = '1', 2, 0);
    curNPCalias := Unalias(Name(npc));
    if LOGGING then LogExitT1('LoadNPC', Format('%s %s', [Name(curNPCrace), SexToStr(curNPCsex)]));
end;

end.