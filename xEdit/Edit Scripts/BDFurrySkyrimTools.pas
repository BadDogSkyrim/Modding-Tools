{
}
unit BDFurrySkyrimTools;

interface
implementation
uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    TINT_SKIN_TONE = 0;
    // Fur layers
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
    TINT_CHEEK = 11;
    TINT_MUZZLE = 12;
    TINT_STRIPES = 13;
    TINT_MASK = 14;
    TINT_BROW = 15;
    TINT_EAR = 16;
    // Decoration layers
    TINT_BLACKBLOOD = 17;
    TINT_BOTHIAH = 18;
    TINT_FORSWORN = 19;
    TINT_FREKLES = 20;
    TINT_NORD = 21;
    TINT_DARKELF = 22;
    TINT_IMPERIAL = 23;
    TINT_ORC = 24;
    TINT_REDGUARD = 25;
    TINT_WOODELF = 26;
    TINT_HAND = 27;
    TINT_SKULL = 28;
    TINT_PAINT = 29;
    TINT_DIRT = 30;
    TINT_COUNT = 31;

    // "Special" tint layers are only assigned if the NPC has them.
    TINT_SPECIAL_LO = 17;

    SEX_MALEADULT = 0;
    SEX_FEMADULT = 1;
    SEX_MALECHILD = 2;
    SEX_FEMCHILD = 3;
    SEX_COUNT = 4;
    SEX_MASK = 1;
    AGE_MASK = 2;
    SEX_MALE = 0;
    SEX_FEM = 1;
    SEX_CHILD = 2;
    SEX_LO = 0;
    SEX_HI = 0;

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

    // List of factions that force their owner's race: factionName = RaceName
    factionRaces: TStringList;

    // Name/value list of furry race classes. Values are the race's class. Only furry
    // races with defind classes are in the list.
    // NOT CURRENTLY USED.
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

    // // Index into tint asset layers. 
    // // tintAssets[sex].objects[racename].objects[TINI] 1:1 with tint asset layers.

    // tintAssets keeps tint information for a race, furry or vanilla.
    // Indexed by sex, race, and tint layer class -> list of race tint layer assets
    tintAssets: array[0..3 {SEX_COUNT}] of TStringList {[racename] -> TStringList:RaceTintDefinitions};
    // tintAssetClasses gives the tint class of each tint asset in a race.
    // [sex, race] -> TINI=class name
    tintAssetClasses: array[0..3 {SEX_COUNT}] of TStringList;

    tintClassRequired: TStringList; // [classname] = '1' if required, '0' if not.
    tintlayerNames: TStringList;
    decorationLayers: TStringList; 

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

    // Quick reference for vanilla plugins.
    vanillaPlugins: TStringList;

    npcForcedRace: TStringList;

    // Information about the NPC being furrified. Global variables because we can't 
    // pass structures in procedure calls.
    curNPC: IwbMainRecord;
    curNPCoriginal: IwbMainRecord;
    curNPCrace: IwbMainRecord;
    curNPCAssignedRace: IwbMainRecord;
    curNPCFurryRace: IwbMainRecord;
    curNPCsex: integer;
    // curNPCTintLayerOptions: IwbMainRecord;
    curNPClabels: TStringList;
    curNPCalias: string;
    curNPCHash: string;
    curNPCTintLayers: TStringList;

    indexList: TStringList;
    defaultRace: IwbMainRecord;
    firstModIndex: integer; // Index of the first mod following the vanilla plugins.


Procedure PreferencesInit;
var i, j, k: integer;
begin
    if LOGGING then LogEntry(20, 'PreferencesInit');
    raceAssignments := TStringList.Create;
    raceAssignments.Duplicates := dupIgnore;
    raceAssignments.Sorted := true;

    furryRaces := TStringList.Create;
    furryRaces.Duplicates := dupIgnore;
    furryRaces.Sorted := true;

    factionRaces := TStringList.Create;
    factionRaces.Duplicates := dupIgnore;
    factionRaces.Sorted := true;

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

    decorationLayers := TStringList.Create;
    decorationLayers.Duplicates := dupIgnore;
    decorationLayers.Sorted := true;
    decorationLayers.Add('Dirt');
    decorationLayers.Add('Frekles');
    decorationLayers.Add('Paint');
    decorationLayers.Add('WarpaintBlackblood');
    decorationLayers.Add('WarpaintBothiah');
    decorationLayers.Add('WarpaintBreton');
    decorationLayers.Add('WarpaintDarkElf');
    decorationLayers.Add('WarpaintForsworn');
    decorationLayers.Add('WarpaintHand');
    decorationLayers.Add('WarpaintImperial');
    decorationLayers.Add('WarpaintNord'); 
    decorationLayers.Add('WarpaintOrc');
    decorationLayers.Add('WarpaintRedguard');
    decorationLayers.Add('WarpaintSkull');
    decorationLayers.Add('WarpaintWoodElf');

    // OBSOLETE
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
    tintlayerNames.Add('Stripes');
    tintlayerNames.Add('Mask');
    tintlayerNames.Add('Brow');
    tintlayerNames.Add('Ear');
    tintlayerNames.Add('BlackBlood');
    tintlayerNames.Add('Bothiah');
    tintlayerNames.Add('Forsworn');
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
    tintClassRequired := TStringList.Create;

    for k := 0 to SEX_COUNT-1 do begin
        tintAssets[k] := TStringList.Create;
        tintAssets[k].Duplicates := dupIgnore;
        tintAssets[k].Sorted := True;
    end;

    for k := 0 to SEX_COUNT-1 do begin
        tintAssetClasses[k] := TStringList.Create;
        tintAssetClasses[k].Duplicates := dupIgnore;
        tintAssetClasses[k].Sorted := True;
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

    npcForcedRace := TStringList.Create;
    npcForcedRace.Duplicates := dupIgnore;
    npcForcedRace.Sorted := true;

    vanillaPlugins := TStringList.Create;
    vanillaPlugins.Add('Skyrim.esm');
    vanillaPlugins.Add('Update.esm');
    vanillaPlugins.Add('Dawnguard.esm');
    vanillaPlugins.Add('HearthFires.esm');
    vanillaPlugins.Add('Dragonborn.esm');
    for i := 0 to FileCount-1 do begin
        if vanillaPlugins.IndexOf(GetFileName(FileByIndex(i))) < 0 then begin
            firstModIndex := i;
            break;
        end;
    end;
            
    defaultRace := FindAsset(FileByIndex(0), 'RACE', 'DefaultRace');

    curNPClabels := nil;
    curNPCTintLayers := nil;
    if LOGGING then LogExitT('PreferencesInit');
end;

Procedure PreferencesFree;
var i, j, tintIdx, sexIdx, typeIdx, m: Cardinal;
begin
    if LOGGING then LogEntry(20, 'PreferencesFree');
    raceAssignments.Free;
    furryRaces.Free;
    factionRaces.Free;
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
        for i := 0 to tintAssets[sexIdx].count-1 do begin // all sexes
            for j := 0 to tintAssets[sexIdx].objects[i].count-1 do begin // all races
                for tintIdx := 0 to tintAssets[sexIdx].objects[i].objects[j].count-1 do begin // all classes
                    // if LOGGING then LogD(Format('Freeing %d tints for class %s', [
                    //     tintAssets[sexIdx].objects[i].objects[j].count,
                    //     tintAssets[sexIdx].objects[i].strings[j]
                    // ]));
                end;
                tintAssets[sexIdx].objects[i].objects[j].Free;
            end;
            tintAssets[sexIdx].objects[i].Free;
        end;
        tintAssets[sexIdx].Free;
    end;

    for sexIdx := 0 to SEX_COUNT-1 do begin
        for i := 0 to tintAssetClasses[sexIdx].count-1 do begin // all sexes
            for j := 0 to tintAssetClasses[sexIdx].objects[i].count-1 do begin // all races
                // for tintIdx := 0 to tintAssetClasses[sexIdx].objects[i].objects[j].count-1 
                // do begin // all classes
                //     // if LOGGING then LogD(Format('Freeing %d tints for class %s', [
                //     //     tintAssetClasses[sexIdx].objects[i].objects[j].count,
                //     //     tintAssetClasses[sexIdx].objects[i].strings[j]
                //     // ]));
                // end;
                if Assigned(tintAssetClasses[sexIdx].objects[i].objects[j]) then
                    tintAssetClasses[sexIdx].objects[i].objects[j].Free;
            end;
            tintAssetClasses[sexIdx].objects[i].Free;
        end;
        tintAssetClasses[sexIdx].Free;
    end;

    tintlayerNames.Free;
    decorationLayers.Free;
    tintMaskPaths.Free;
    tintFileTypes.Free;
    tintClassRequired.Free;
    furrifiableArmors.free;
    allAddons.free;
    npcForcedRace.free;
    if Assigned(indexList) then indexList.Free;
    vanillaPlugins.free;

    for i := 0 to addonRaces.count-1 do 
        addonRaces.objects[i].free;
    addonRaces.free;

    if Assigned(curNPCTintLayers) then curNPCTintLayers.Free();
    if Assigned(curNPClabels) then curNPClabels.Free();

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


function GetNPCSex(npc: IwbMainRecord): integer;
begin
    result := IfThen(
        GetElementEditValues(npc, 'ACBS - Configuration\Flags\Female') = '1',
            SEX_FEMADULT, SEX_MALEADULT) 
        + IfThen(GetElementEditValues(curNPCrace, 'DATA - DATA\Flags\Child') = '1', 
            SEX_CHILD, 0);
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


{===============================================================================
Record a tint layer class for a furry race.
TODO: Might need to separate tint layer types by race in the future.
}
procedure SetTintLayerClass(racename, filename: string; classname: string);
begin
    tintFileTypes.Add(filename + '=' + classname);
end;


{===============================================================================
Record .
TODO: Might need to separate tint layer types by race in the future.
}
procedure SetTintLayerRequired(classname: string; isRequired: boolean);
begin
    tintClassRequired.Add(classname + '=' + IfThen(isRequired, '1', '0'));
end;


{====================================================================
Preload skin tint info for a race.
}
procedure LoadRaceTints(theRace: IwbMainRecord);
var
    cIndex: integer;
    classLayers: TStringList; // List of tint layers for this class.
    classname: string;
    i, j, k, r, rc: integer;
    layerIdx: integer;
    layerindex: string;
    layername: string;
    raceTintAssets: IwbElement;
    raceTints: TStringList {RaceTintDefinitions};
    layerList: TStringList;
    required: string;
    sexIdx: integer;
    specialIdx: Integer;
    tintAsset: IwbElement;
    tintfile: string;
begin
    if LOGGING then LogEntry1(15, 'LoadRaceTints', Name(theRace));

    for sexIdx := SEX_LO to SEX_HI do begin
        r := tintAssets[sexIdx].IndexOf(EditorID(theRace));
        if LOGGING then LogT(Format('Race %s index %d', [Name(theRace), Integer(r)]));

        // If we don'tintAsset already have the tint assets for this race, load them now.
        if r < 0 then begin
            raceTints := TStringList.Create;
            tintAssets[sexIdx].AddObject(EditorID(theRace), raceTints);
            r := tintAssets[sexIdx].IndexOf(EditorID(theRace));

            layerList := TStringList.Create;
            layerList.Duplicates := dupIgnore;
            layerList.Sorted := True;
            tintAssetClasses[sexIdx].AddObject(EditorID(theRace), layerList);
            rc := tintAssets[sexIdx].IndexOf(EditorID(theRace));

            raceTintAssets := ElementByPath(theRace, tintMaskPaths.strings[sexIdx]);
            if LOGGING then LogT(Format('Loading %d race assets %s', [
                Integer(ElementCount(raceTintAssets)),
                PathName(raceTintAssets)
            ]));
            for j := 0 to ElementCount(raceTintAssets)-1 do begin
                tintAsset := ElementByIndex(raceTintAssets, j);
                classname := GetLayerClass(tintAsset);

                // Add to tintAssets
                cIndex := tintAssets[sexIdx].objects[r].IndexOf(classname);
                if cIndex < 0 then begin 
                    classLayers := TStringList.Create;
                    tintAssets[sexIdx].objects[r].AddObject(classname, classLayers);
                    cIndex := tintAssets[sexIdx].objects[r].IndexOf(classname);
                end;
                tintAssets[sexIdx].objects[r].objects[cIndex].AddObject(
                    GetElementEditValues(tintAsset, 'Tint Layer\Texture\TINI - Index'),
                    TObject(tintAsset));

                // Add to tintAssetClasses
                tintAssetClasses[sexIdx].objects[rc].Add(
                    GetElementEditValues(tintAsset, 'Tint Layer\Texture\TINI')
                    + '=' + GetLayerClass(tintAsset)
                );
            end;
        end
        else
            if LOGGING then LogT(Format('Race %s is already loaded', [Name(theRace)]));
    end;

    if LOGGING then LogExitT('LoadRaceTints');
end;


function TintLayerToStr(tint: integer): string;
begin
    if (tint >= 0) and (tint < tintlayerNames.Count) then result := tintlayerNames[tint]
    else result := 'UNKNOWN TINT ' + IntToStr(tint);
end;


function GetLayerClassByTINI(racename: string; sex: integer; tini: string): string;
var
    r: integer;
begin
    if LOGGING then LogEntry3(15, 'GetLayerClassByTINI', racename, SexToStr(sex), tini);
    result := '';
    r := tintAssetClasses[sex].IndexOf(racename);
    if r >= 0 then begin
        result := tintAssetClasses[sex].objects[r].values[tini];
        if result <> '' then begin
            if LOGGING then LogD(Format('Found tint asset [%s][%s][%s] = %s', [
                racename, SexToStr(sex), tini, result]))
        end
        else 
            Warn(Format('No known tint asset layer %s for race/sex %s/%s', [
                tini, racename, SexToStr(sex)
            ]));
    end
    else 
        Warn(Format('No known race %s/%s', [racename, SexToStr(sex)]));
    if LOGGING then LogExitT1('GetLayerClassByTINI', result);
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
            else if ContainsText(fn, 'Forsworn') then result := TINT_FORSWORN
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
Return the class of the given race tint layer. This is the mask name unless it's a special
layer-- one of the special paints or a dirt layer used for extra patterns.
}
function GetLayerClass(tintAsset: IwbElement): string;
var
    fp, fn, mn: string;
    fni, i: integer;
begin
    if LOGGING then LogEntry1(10, 'GetLayerClass', PathName(tintAsset));
    result := '';
    fp := GetElementEditValues(tintAsset, 'Tint Layer\Texture\TINT');
    fn := fp; // ExtractFileName(fp);

    // If the file name is in the tintFileTypes list, return the predefined class.
    result := tintFileTypes.values[fn];
    if result = '' then begin
        mn := GetElementEditValues(tintAsset, 'Tint Layer\Texture\TINP');
        if LOGGING then LogD(Format('Layer mask name "%s", file "%s"', [mn, fn]));
        if (mn <> '') and (mn <> 'Dirt') and (mn <> 'Paint') then
            result := mn
        else begin
            if ContainsText(fn, 'Frekles') then result := 'Frekles'
            else if ContainsText(fn, 'BlackBlood') then result := 'WarpaintBlackblood'
            else if ContainsText(fn, 'Bothiah') then result := 'WarpaintBothiah'
            else if ContainsText(fn, 'Forsworn') then result := 'WarpaintForsworn'
            else if ContainsText(fn, 'Muzzle') then result := 'Muzzle'
            else if ContainsText(fn, 'NordWarPaint') then result := 'WarpaintNord'
            else if ContainsText(fn, 'BretonWarPaint') then result := 'WarpaintBreton'
            else if ContainsText(fn, 'DarkElfWarPaint') then result := 'WarpaintDarkElf'
            else if ContainsText(fn, 'ImperialWarPaint') then result := 'WarpaintImperial'
            else if ContainsText(fn, 'OrcWarPaint') then result := 'WarpaintOrc'
            else if ContainsText(fn, 'RedguardWarPaint') then result := 'WarpaintRedguard'
            else if ContainsText(fn, 'WoodElfWarPaint') then result := 'WarpaintWoodElf'
            else result := mn;
        end;
    end;
    if LOGGING then LogExitT1('GetLayerClass', result);
end;


{================================================================================
Determine whether the original version of NPC currently being furrified had an active
layer with the given layer ID.
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
                If LOGGING then LogD(Format('Tint Layer Match Index:%s TINI:%s TINP:%s TINV:%s = %s', [
                    IntToStr(tintAssets[curNPCsex].objects[rti].IndexOf(tintLayerTINI)), 
                    tintLayerTINI, 
                    TintLayerToStr(maskTypeID), 
                    FloatToStr(tintLayerTINV),
                    BoolToStr(result)]));
            end;
            if result then break;
        end;
    end;
    if LOGGING then LogExitT1('CurNPCHasTintLayer', BoolToStr(Result));
end;


procedure ShowRaceTints;
var
    raceIndex, sexIndex, layerIndex, classIndex, tiniIndex: Cardinal;
    n: string;
    tintLayers: TStringList;
    tl: IwbElement;
begin
    AddMessage('==Race Tint Class Assignments==');
    for raceIndex := 0 to tintFileTypes.Count-1 do begin
        AddMessage('|   ' + tintFileTypes.names[raceIndex] + ' = ' + tintFileTypes.values[tintFileTypes.names[raceIndex]]);
    end;

    AddMessage('==Race Tint Layer Class Index==');
    for sexIndex := SEX_LO to SEX_HI do begin
        AddMessage('|   ' + SexToStr(sexIndex));
        for raceIndex := 0 to tintAssetClasses[sexIndex].count-1 do begin
            AddMessage('|   |   ' + tintAssetClasses[sexIndex].strings[raceIndex]); // Race
            for tiniIndex := 0 to tintAssetClasses[sexIndex].objects[raceIndex].count-1 do begin
                n := tintAssetClasses[sexIndex].objects[raceIndex].names[tiniIndex];
                AddMessage('|   |   |   ' 
                    + n + ' = ' + tintAssetClasses[sexIndex].objects[raceIndex].values[n]); 
            end;
        end;
    end;

    AddMessage('==Race Tint Layers==');
    for sexIndex := SEX_LO to SEX_HI do begin
        AddMessage('|   ' + SexToStr(sexIndex));
        for raceIndex := 0 to tintAssets[sexIndex].count-1 do begin
            AddMessage('|   |   ' + tintAssets[sexIndex].strings[raceIndex]); // Race
            for classIndex := 0 to tintAssets[sexIndex].objects[raceIndex].count-1 do begin
                AddMessage('|   |   |   ' 
                    + tintAssets[sexIndex].objects[raceIndex].strings[classIndex]); // Tint Layer Class
                tintlayers := tintAssets[sexIndex].objects[raceIndex].objects[classIndex];
                for layerIndex := 0 to tintLayers.count-1 do begin
                    tl := ObjectToElement(tintLayers.objects[layerIndex]); 
                    AddMessage('|   |   |   |   '
                        + tintLayers.strings[layerIndex] 
                        + ' = ' + GetElementEditValues(tl, 'Tint Layer\Texture\TINT')
                        + ' @ ' + PathName(tl)
                        ); // Tint Layer
                end;
            end;
        end;
    end;
    AddMessage('--Race Tint Layers--');
end;


Procedure SetFactionRace(factionName, activeRaceName: String);
begin
    factionRaces.Add(factionName + '=' + activeRaceName);
end;


Procedure SetTattooRace(tattooName, activeRaceName: String);
begin
    // TBD
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
        Warn(Format('Race %s not found, will not be assigned', [furryRaceName]))
    else if not Assigned(vanillaRace) then 
        Warn(Format('Race %s not found, will not be furrified', [vanillaRaceName]))
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
                Warn(Format('Race %s not found, race %s may have trouble wearing armor', [
                    defaultArmorRace, vanillaRaceName]))
            else begin
                // furryRaces.AddObject(defaultArmorRace, armorRace);
                armorRaces.add(furryRaceName + '=' + defaultArmorRace);
            End;
        end;
    end; 

    if LOGGING then LogExitT1('SetRace', EditorID(furryRace));
end;


{========================================================================
Assign a pseudorace (Reachmen or Skaal) to a furry race.
}
Procedure SetPseudoRace(pseudoRaceName, pseudoRaceUsername, vanillaRaceName, furryRaceName, raceClass, armorRace: string);
var
    vanillaRace: IwbMainRecord;
    pseudoRace: IwbMainRecord;
begin
    // Pseudorace is copied from the master vanilla race.
    vanillaRace := FindAsset(Nil, 'RACE', vanillaRaceName);
    if Assigned(vanillaRace) then begin
        AddRecursiveMaster(targetFile, Getfile(vanillaRace));
        pseudoRace := wbCopyElementToFile(vanillaRace, targetFile, True, True);
        if Assigned(pseudoRace) then begin
            SetEditorID(pseudoRace, pseudoRaceName);
            Add(pseudoRace, 'FULL', TRUE);
            SetElementEditValues(pseudoRace, 'FULL', pseudoRaceUsername);
            SetRace(pseudoRaceName, furryRaceName, raceClass, armorRace);
        end
        else
            Raise Exception.Create(Format(
                'Race %s could not be created for vanilla race %s in file %s', 
                [pseudoRaceName, vanillaRaceName, GetFileName(targetFile)]));
    end
    else 
        Raise Exception.Create(Format('Race %s not found, %s will not be assigned', [
            vanillaRaceName, pseudoRaceName]));
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
    if LOGGING then LogEntry(15, 'RecordHeadpartAssignments');

    for hpIter := 0 to headpartRecords.Count-1 do begin
        hp := ObjectToElement(headpartRecords.objects[hpIter]);
        hpType := StrToHeadpart(GetElementEditValues(hp, 'PNAM'));

        if LOGGING then LogT(Format('Processing headpart: %s (Type: %s)', [Name(hp), HeadpartToStr(hpType)]));

        for s := SEX_MALEADULT to SEX_FEMADULT do begin
            if SexMatchesHeadpart(hp, s) then begin
                if LOGGING then LogT(Format('Headpart %s matches sex: %s', [Name(hp), SexToStr(s)]));

                formlist := WinningOverride(LinksTo(ElementByPath(hp, 'RNAM')));
                racelist := ElementByPath(formlist, 'FormIDs');
                for rIdx := 0 to ElementCount(racelist)-1 do begin
                    racename := EditorID(LinksTo(ElementByIndex(racelist, rIdx)));
                    if LOGGING then LogT(Format('Processing race: %s for headpart: %s', [racename, Name(hp)]));

                    r := raceHeadparts[hpType, s].IndexOf(racename);
                    if r < 0 then begin
                        sl := TStringList.Create;
                        sl.Duplicates := dupIgnore;
                        sl.Sorted := true;
                        raceHeadparts[hpType, s].AddObject(racename, sl);
                        r := raceHeadparts[hpType, s].IndexOf(racename);
                        if LOGGING then LogT(Format('Added new race: %s to headpart type: %s', [racename, HeadpartToStr(hpType)]));
                    end;
                    raceHeadparts[hpType, s].objects[r].AddObject(EditorID(hp), hp);
                    if LOGGING then LogT(Format('Assigned headpart: %s to race: %s', [Name(hp), racename]));
                end;
            end;
        end;
    end;

    if LOGGING then LogExitT('RecordHeadpartAssignments');
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

        if LOGGING then LogT(Format('Checking headpart %s', [
            IfThen(Assigned(hp), Name(hp), headpartRecords.strings[hpIter] + ' [Unassigned]')]));
        
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
    if not Assigned(furryHP) then Warn(Format('Headpart %s not found', [furryHPName]));
    if not Assigned(vanillaHP) then Warn(Format('Headpart %s not found', [vanillaHPName]));
    if Assigned(furryHP) and Assigned(vanillaHP) then begin
        hpi := headpartEquivalents.IndexOf(vanillaHPName);
        if hpi < 0 then begin
            hplist := TStringList.Create;
            headpartEquivalents.AddObject(vanillaHPName, hplist);
            hpi := headpartEquivalents.IndexOf(vanillaHPName);
        end;
        if LOGGING then LogD(Format('Adding headpartRecord %s / %s', [vanillaHPName, Name(vanillaHP)]));
        headpartRecords.AddObject(vanillaHPName, vanillaHP);
        if LOGGING then LogD(Format('Adding headpartRecord %s / %s', [furryHPName, Name(furryHP)]));
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
    if LOGGING then LogD(Format('Adding headpartRecord %s / %s', [EditorID(hpRecord), Name(hpRecord)]));
    headpartRecords.AddObject(EditorID(hpRecord), hpRecord);
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
    if not Assigned(hpRecord) then 
        Warn(Format('Headpart %s not found', [headpartName]))
    else begin
        hpi := headpartLabels.IndexOf(headpartName);
        if hpi < 0 then begin
            headpartLabels.AddObject(headpartName, TStringList.Create);
            hpi := headpartLabels.IndexOf(headpartName);
            headpartLabels.objects[hpi].duplicates := dupIgnore;
            headpartLabels.objects[hpi].sorted := true;
        end;
        headpartLabels.objects[hpi].commaText := labelNames;
        if LOGGING then LogD(Format('Adding headpartRecord %s / %s', [headpartName, Name(hpRecord)]));
        headpartRecords.AddObject(headpartName, hpRecord);
        // CacheHeadpart(hpRecord);
    end;
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


{=========================================================================
Set an NPC to a particular race or pseudorace.
}
procedure SetNPCRace(npcName, raceName: string);
var
    i: integer;
begin
    if LOGGING then LogEntry2(10, 'SetNPCRace', npcName, raceName);
    i := vanillaRaces.IndexOf(raceName);
    if i < 0 then
        Warn(Format('Race %s not found, will not be assigned to %s', [raceName, npcName]))
    else begin
        npcForcedRace.addObject(npcName, vanillaRaces.objects[i]);
        if LOGGING then LogT(Format('Assigned race %s to NPC %s', [raceName, npcName]));
    end;
    if LOGGING then LogExitT('SetNPCRace');
end;


{==================================================================
Determine whether an NPC has the "Reachman" race.

In the base game, reachmen are  Bretons. We allow them to be assigned a different
look, without actually changing their race as the game sees it.
}
function IsReachman(npc: IwbMainRecord): Boolean;
begin
    if (NPCAssignedRace(npc) = 'ReachmanRace') then result := True
    else if EditorID(LinksTo(ElementByPath(npc, 'RNAM'))) <> 'BretonRace' then result := False 
    else if HasFaction(npc, 'ForswornFaction') then result := True
    else if HasFaction(npc, 'MS01TreasuryHouseForsworn') then result := True
    else if HasFaction(npc, 'DruadachRedoubtFaction') then result := True
    else if HasForswornTattoo(npc) then result :- True
    else result := False;
end;


{==================================================================
Determine whether an NPC has the "Reachman" race.

In the base game, reachmen are  Bretons. We allow them to be assigned a different
look, without actually changing their race as the game sees it.
}
function IsSkaal(npc: IwbMainRecord): Boolean;
begin
    if (NPCAssignedRace(npc) = 'SkaalRace') then result := True
    else if EditorID(LinksTo(ElementByPath(npc, 'RNAM'))) <> 'NordRace' then result := False
    else if HasRaceFaction(npc, 'ReachmanRace') then result := True 
    else result := False;
end;


{============================================================================
Some NPCs have multiple NPC records. This makes sure all records look the same.
}
procedure NPCAlias(basenpc, altnpc: string);
var
    alist: TStringList;
    i: integer;
begin
    NPCaliases.Add(altnpc + '=' + basenpc);
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


{=======================================================================
Find an elemeent in a compound list by the value of one of its parts.
Return the list element.
}
function NPCHasFaction(npc: iwbMainRecord; factionName: string): boolean;
var
    i: integer;
    ele: IwbElement;
    elist: IwbElement;
    val: string;
begin
    elist := ElementByPath(npc, 'Factions');
    result := false;
    for i := 0 to ElementCount(elist)-1 do begin
        ele := ElementByIndex(elist, i);
        val := EditorID(LinksTo(ElementByPath(ele, 'Faction')));
        if val = factionName then begin
            result := true;
            break;
        end;
    end;
end;


{============================================================================
Return any NPC race change.
}
function GetNpcRaceChange(npc: IwbMainRecord): IwbMainRecord;
var
    npcFactionList: IwbElement;
    fn: string;
    i, j, k: integer;
begin
    if LOGGING then LogEntry1(10, 'GetNpcRaceChange', Name(npc));
    result := nil;
    i := npcForcedRace.IndexOf(EditorID(npc));
    if i >= 0 then
        result := ObjectToElement(npcForcedRace.objects[i])
    else begin
        npcFactionList := ElementByPath(npc, 'Factions');
        for i := 0 to ElementCount(npcfactionList)-1 do begin
            fn := EditorID(LinksTo(ElementByPath(ElementByIndex(npcFactionList, i), 'Faction')));
            j := factionRaces.IndexOfName(fn);
            LogD(Format('Faction %s has index %d', [fn, j]));
            if j >= 0 then begin
            if LOGGING then LogD(Format('Faction %s -> race %s', [
                    fn, factionRaces.ValueFromIndex[j]]));
                k := vanillaRaces.IndexOf(factionRaces.ValueFromIndex[j]);
                result := ObjectToElement(vanillaRaces.objects[k]);
            end;
        end;
    end;
    if LOGGING then LogExitT1('GetNpcRaceChange', Name(result));
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
    try
        if Assigned(curNPClabels) then curNPClabels.Free();
    except
        on E: Exception do
            AddMessage('DEBUG: Exception freeing curNPClabels');
    end;

    curNPClabels := TStringList.Create();
    curNPClabels.Duplicates := dupIgnore;
    curNPClabels.Sorted := True;

    voice := GetElementEditValues(curNPC, 'VTCK');
    outfit := GetElementEditValues(curNPC, 'DOFT');

    if ContainsStr(voice, 'Emperor') or ContainsStr(voice, 'Ulfric') 
        or ContainsStr(outfit, 'Jarl') or ContainsStr(outfit, 'FineClothes')
    then CurNPCAddLabel('NOBLE');

    if ContainsStr(voice, 'Young') 
    then curNPClabels.Add('YOUNG');

    if ContainsStr(voice, 'Old') or (EditorID(curNPCrace) = 'ElderRace')
    then curNPClabels.Add('OLD');

    if ContainsStr(voice, 'Forsworn')
    then curNPClabels.Add('FEATHERS');

    if ContainsStr(voice, 'Commander') or ContainsStr(voice, 'Soldier') or ContainsStr(voice, 'Guard')
        or ContainsStr(outfit, 'PenitusOculatus')
    then curNPClabels.Add('MILITARY');

    if ContainsStr(outfit, 'Farmer') or ContainsStr(outfit, 'Forsworn') 
        or ContainsStr(outfit, 'Bandit') or ContainsStr(outfit, 'MinerClothes')
        // or CurNPCHasTintLayer('Dirt')
    then curNPClabels.Add('MESSY');

    if ContainsStr(outfit, 'Tavern') or ContainsStr(outfit, 'College') 
        or NPCHasFaction(curNPC, 'VigilantOfStendarrFaction')
    then curNPClabels.Add('NEAT');

    if ContainsStr(outfit, 'Warlock') or ContainsStr(outfit, 'Bandit') 
    then curNPClabels.Add('BOLD');

    // TODO: If wearing outfit with 'ClothingRich' keyword, add NOBLE
    // TODO: If wearing outfit with 'ClothingPoor [KYWD:000A865C]' keyword, add MESSY
    // TODO: If complexion is older, add OLD
end;


{============================================================================
Load up the curNPC* global variables with info from the current NPC.
}
procedure LoadNPC(npc, originalNPC: IwbMainRecord);
var 
    i, raceIdx, sexIdx, presetsIdx: integer;
    tintList: IwbElement;
    tintLayer: IwbElement;
    tini: string;
    tclass: string;
begin
    if LOGGING then LogEntry1(10, 'LoadNPC', Name(npc));
    curNPC := npc;
    curNPCoriginal := originalNPC;

    curNPCrace := LinksTo(ElementByPath(npc, 'RNAM'));
    curNPCAssignedRace := GetNpcRaceChange(npc);
    if Assigned(curNPCAssignedRace) then 
        curNPCFurryRace := ObjectToElement(raceAssignments.objects[
            raceAssignments.IndexOf(EditorID(curNPCAssignedRace))])
    else 
        curNPCFurryRace := ObjectToElement(raceAssignments.objects[
            raceAssignments.IndexOf(EditorID(curNPCrace))]);
    
    if Assigned(curNPCTintLayers) then curNPCTintLayers.Free;
    curNPCTintLayers := TStringList.Create;
    curNPCTintLayers.Duplicates := dupIgnore;
    curNPCTintLayers.Sorted := true;
    tintList := ElementByPath(originalNPC, 'Tint Layers');
    if LOGGING then LogD(Format('Loading %d tint Layers', [Integer(ElementCount(tintList))]));
    for i := 0 to ElementCount(tintList)-1 do begin
        tintLayer := ElementByIndex(tintList, i);

        // Add visible tint layers
        if GetElementNativeValues(tintLayer, 'TINV') > 0.01 then begin
            tini := GetElementEditValues(tintLayer, 'TINI');
            tclass := GetLayerClassByTINI(EditorID(curNPCrace), curNPCsex, tini);
            if decorationLayers.IndexOf(tclass) >= 0 then begin
                curNPCTintLayers.Add(tclass);
                if LOGGING then LogD(Format('Found tint layer %s, class %s', [
                    tini, tclass]));
            end;
        end;
    end;

    curNPCsex := GetNPCSex(npc); 
    curNPCalias := Unalias(Name(npc));
    curNPCHash := curNPCalias + GetElementEditValues(npc, 'Record Header\Data Size');
    CurNPCLoadLabels;

    if LOGGING then begin
        LogT('Race is ' + EditorID(curNPCrace));
        LogT('Assigned Race is ' + Name(curNPCAssignedRace));
        LogT('Furry Race is ' + EditorID(curNPCFurryrace));
        LogT('Sex is ' + SexToStr(curNPCSex));
        LogT('Age is ' + GetElementEditValues(curNPCrace, 'DATA - DATA\Flags\Child'));
        LogT('Decoration Layers: ' + curNPCTintLayers.CommaText);
        LogT(Format('Labels: (%d) %s', [curNPClabels.count, curNPClabels.CommaText]));
    end;
    
    if LOGGING then LogExitT1('LoadNPC', Format('%s %s', [Name(curNPCrace), SexToStr(curNPCsex)]));
end;

end.