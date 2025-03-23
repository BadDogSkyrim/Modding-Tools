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
    TINT_COUNT = 12;

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
    tintlayerpaths: TStringList;

    // Race tint layers, PRE-FURRIFICATION. 
    // raceTintPresets[LAYER, SEX].objects[racename] = preset IwbElement
    // raceTintPresets: array[0..11 {TINT_COUNT}, 0..3 {SEX_COUNT}] of TStringList;

    // Whether a race tint layer is required. raceTintRequired[LAYER, SEX].objects[racename] = T/F
    // raceTintRequired: array[0..11 {TINT_COUNT}, 0..3 {SEX_COUNT}] of TStringList;

    // Special race tint layers that may have multiple values.
    // raceTintSpecial[LAYER, SEX].objects[racename] = TStringList of (layername, preset) pairs.
    // raceTintSpecial: array[0..4 {SPECIALTYPE_COUNT}, 0..3 {SEX_COUNT}] of TStringList;

    // Tint index (TINI) values so we can look at an NPC and figure out what layers it uses. 
    // racaeTintIndices[tintlayer, sex][racename][TINI] = 'TINP - Mask Type:TINT - Filename'
    // raceTintIndices: array[0..3 {SEX_COUNT}] of TStringList;

    tintlayerNames: TStringList;

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

    // headpartRaces := TStringList.Create;
    // headpartRaces.Duplicates := dupIgnore;
    // headpartRaces.Sorted := true;

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

    // for j := 0 to TINT_COUNT-1 do begin
    //     for k := 0 to SEX_COUNT-1 do begin
    //         raceTintPresets[j, k] := TStringList.Create;
    //         raceTintPresets[j, k].duplicates := dupIgnore;
    //         raceTintPresets[j, k].sorted := True;
    //         raceTintRequired[j, k] := TStringList.Create;
    //         raceTintRequired[j, k].duplicates := dupIgnore;
    //         raceTintRequired[j, k].sorted := True;
    //     end;
    // end;
    // for j := 0 to SPECIALTYPE_COUNT-1 do begin
    //     for k := 0 to SEX_COUNT-1 do begin
    //         raceTintSpecial[j, k] := TStringList.Create;
    //         raceTintSpecial[j, k].duplicates := dupIgnore;
    //         raceTintSpecial[j, k].sorted := True;
    //     end;
    // end;
    // for k := 0 to SEX_COUNT-1 do begin
    //     raceTintIndices[k] := TStringList.Create;
    //     raceTintIndices[k].duplicates := dupIgnore;
    //     raceTintIndices[k].sorted := True;
    // end;
    for j := 0 to HP_COUNT-1 do begin
        for k := 0 to SEX_COUNT-1 do begin
            raceHeadparts[j, k] := TStringList.Create;
            raceHeadparts[j, k].duplicates := dupIgnore;
            raceHeadparts[j, k].sorted := True;
        end;
    end;

    tintlayerpaths := TStringList.Create;
    tintlayerpaths.Add('Head Data\Male Head Data\Tint Masks');
    tintlayerpaths.Add('Head Data\Female Head Data\Tint Masks');
    tintlayerpaths.Add('Head Data\Male Head Data\Tint Masks');
    tintlayerpaths.Add('Head Data\Female Head Data\Tint Masks');

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

    // for tintIdx := 0 to TINT_COUNT-1 do begin // iterate over tint layers
    //     for sexIdx := 0 to SEX_COUNT-1 do begin // iterate over age/sex
    //         raceTintPresets[tintIdx, sexIdx].Free;
    //         raceTintRequired[tintIdx, sexIdx].Free;
    //     end;
    // end;

    // for tintIdx := 0 to SPECIALTYPE_COUNT-1 do begin // iterate over tint layers
    //     for sexIdx := 0 to SEX_COUNT-1 do begin // iterate over age/sex
    //         for i := 0 to raceTintSpecial[tintIdx, sexIdx].Count-1 do begin
    //             LogT(Format('Freeing %s/%s/%s', [IntToStr(tintIdx), SexToStr(sexIdx), 
    //                 raceTintSpecial[tintIdx, sexIdx].strings[i]]));
    //             raceTintSpecial[tintIdx, sexIdx].objects[i].Free;
    //         end;
    //         raceTintSpecial[tintIdx, sexIdx].Free;
    //     end;
    // end;
    // for sexIdx := 0 to SEX_COUNT-1 do begin // iterate over age/sex
    //     for i := 0 to raceTintIndices[sexIdx].Count-1 do begin
    //         raceTintIndices[sexIdx].objects[i].Free;
    //     end;
    //     raceTintIndices[sexIdx].Free;
    // end;
    tintlayerNames.Free;
    tintlayerpaths.Free;
    furrifiableArmors.free;
    allAddons.free;

    for i := 0 to addonRaces.count-1 do 
        addonRaces.objects[i].free;
    addonRaces.free;
    if LOGGING then LogExitT('PreferencesFree');
end;


function SexToStr(s: integer): string;
begin
    result := IfThen(s and 1, 'FEM', 'MALE') + IfThen(s and 2, 'CHILD', 'ADULT');
end;


function TintlayerToStr(tintLayerCode: integer): string;
begin
    if tintLayerCode = TINT_CHEEK then result := 'Cheek Color'
    else if tintLayerCode = TINT_CHEEK_LOWER then result := 'Cheek Color Lower'
    else if tintLayerCode = TINT_CHIN then result := 'Chin'
    else if tintLayerCode = TINT_EYE_LOWER then result := 'EyeSocket Lower'
    else if tintLayerCode = TINT_EYE_UPPER then result := 'EyeSocket Upper'
    else if tintLayerCode = TINT_EYELINER then result := 'Eyeliner'
    else if tintLayerCode = TINT_FOREHEAD then result := 'Forehead'
    else if tintLayerCode = TINT_LAUGH then result := 'Laugh Lines'
    else if tintLayerCode = TINT_LIP then result := 'Lip Color'
    else if tintLayerCode = TINT_NECK then result := 'Neck'
    else if tintLayerCode = TINT_NOSE then result := 'Nose'
    else if tintLayerCode = TINT_SKIN_TONE then result := 'Skin Tone'
    else result := 'Unknown';
end;


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


// function NPCHasTint(npc: IwbMainRecord; tint: string): Boolean;
// var
//     tintLayers: IwbElement;
//     tintLayer: IwbElement;
//     tintLayerName: string;
//     i: integer;
// begin
//     Result := False;
//     tintLayers := ElementByPath(npc, 'Tint Layers');
//     if not Assigned(tintLayers) then Exit;

//     for i := 0 to ElementCount(tintLayers) - 1 do
//     begin
//         tintLayer := ElementByIndex(tintLayers, i);
//         tintLayerName := GetElementEditValues(tintLayer, 'Tint Layer\Texture\TINI');
//         if ContainsText(tintLayerName, tint) then
//         begin
//             Result := True;
//             break;
//         end;
//     end;
// end;


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
    i, j, k, m: integer;
    layerIdx: integer;
    layername: string;
    layerindex: string;
    racetintmasks: IwbElement;
    required: string;
    sexIdx: integer;
    specialIdx: Integer;
    t: IwbElement;
    tintfile: string;
begin
    if LOGGING then LogEntry1(15, 'LoadRaceTints', Name(theRace));

    for sexIdx := SEX_MALEADULT to SEX_FEMADULT do begin
        racetintmasks := ElementByPath(theRace, tintlayerpaths.strings[sexIdx]);
        for j := 0 to ElementCount(racetintmasks)-1 do begin
            t := ElementByIndex(racetintmasks, j);
            layerindex := GetElementEditValues(t, 'Tint Layer\Texture\TINI - Index');
            layername := GetElementEditValues(t, 'Tint Layer\Texture\TINP - Mask Type');
            tintfile := ExtractFilename(GetElementEditValues(t, 'Tint Layer\Texture\TINT'));

            layerIdx := tintlayerNames.IndexOf(layername);

            if LOGGING then LogD(Format('Layer "%s", tint layer file %s', [layername, GetElementEditValues(t, 'Tint Layer\Texture\TINT')]));
            if layerIdx >= 0 then begin
                if raceTintPresets[layerIdx, sexIdx].IndexOf(EditorID(theRace)) < 0 then begin
                    required := 'F';
                    if (layername = 'Skin Tone')
                        or (GetElementNativeValues(t, 'Presets\[0]\TINV') > 0.0)
                    then required := 'T';
                    if LOGGING then LogD(Format('Adding Layer "%s", presets at %s', [layername, PathName(ElementByPath(t, 'Presets'))]));
                    raceTintPresets[layerIdx, sexIdx].AddObject(EditorID(theRace), ElementByPath(t, 'Presets'));
                    raceTintRequired[layerIdx, sexIdx].Add(EditorID(theRace) + '=' + required);
                end
            end
            else begin
                // specialIdx := -1;
                // if layername = 'Dirt' then begin
                //     specialIDx := SPECIALTYPE_DIRT;
                // end
                // else if layername = 'Paint' then begin 
                //     specialIDx := SPECIALTYPE_PAINT;
                // end
                // else if ContainsText(tintfile, 'BlackBlood') then begin
                //     specialIdx := SPECIALTYPE_BLACKBLOOD;
                //     layername := 'BlackBlood';
                // end
                // else if ContainsText(tintfile, 'Bothiah') then begin
                //     specialIDx := SPECIALTYPE_BOTHIAH;
                //     layername := 'Bothiah';
                // end
                // else if ContainsText(tintfile, 'Frekles') then begin
                //     specialIDx := SPECIALTYPE_FREKLES;
                //     layername := 'Frekles';
                // end
                // else Err('Unknown tint type: ' + tintfile);

                // if specialIdx >= 0 then begin
                //     k := raceTintSpecial[specialIdx, sexIdx].IndexOf(EditorID(theRace));
                //     if k < 0 then begin
                //         raceTintSpecial[specialIdx, sexIdx].AddObject(EditorID(theRace), TStringList.create);
                //         k := raceTintSpecial[specialIdx, sexIdx].IndexOf(EditorID(theRace));
                //     end;
                //     raceTintSpecial[specialIdx, sexIdx].objects[k].AddObject(layername, presetList);
                // end;
            end;
            // AddRaceTintIndex(sexIdx, theRace, layerindex, layername, tintfile);
        end;
    end;
    if LOGGING and (raceTintPresets[TINT_SKIN_TONE, SEX_MALEADULT].IndexOf('NordRace') >= 0) then
        LogD('(LoadRaceTints) NordRace skin tone: ' 
            + PathName(ObjectToElement(raceTintPresets[TINT_SKIN_TONE, SEX_MALEADULT]
                .objects[raceTintPresets[TINT_SKIN_TONE, SEX_MALEADULT].IndexOf('NordRace')])));

    if LOGGING then LogExitT('LoadRaceTints');
end;


// function RaceTintIsRequired(tinttype, sex: integer; race: IwbMainRecord): Boolean;
// var rtr: integer;
// begin
//     if tinttype = TINT_SKIN_TONE then
//         result := True
//     else begin
//         result := false;
//         rtr := raceTintRequired[tinttype, sex].IndexOf(EditorID(curNPCFurryRace));
//         if rtr >= 0 then result := (raceTintRequired.ValueFromIndex[rtr] = 'T');
//     end;
// end;


{================================================================================
Determine whether the original version of NPC currently being furrified had a layer with
the given layer name.
}
function CurNPCHasTintLayer(layername: string): Boolean;
var
    i: integer;
    ni: integer;
    rti: integer;
    tintLayer: IwbElement;
    tintLayerIndex: string;
    tintLayers: IwbElement;
    val: string;
begin
    if LOGGING then LogEntry1(10, 'CurNPCHasTintLayer', layername);
    Result := False;
    tintLayers := ElementByPath(curNPCoriginal, 'Tint Layers');
    if Assigned(tintLayers) then begin
        for i := 0 to ElementCount(tintLayers) - 1 do
        begin
            tintLayer := ElementByIndex(tintLayers, i);
            tintLayerIndex := GetElementEditValues(tintLayer, 'TINI');
            rti := raceTintIndices[curNPCsex].IndexOf(EditorID(curNPCrace));
            if rti >= 0 then begin
                // ni := raceTintIndices[curNPCsex].objects[rti].IndexOfName(tintLayerIndex);
                // if ni >= 0 then begin
                    val := raceTintIndices[curNPCsex].objects[rti].values[tintLayerIndex];
                    if LOGGING then LogD(Format('Checking tint layer TINI %s (%s) at %s', 
                        [tintLayerIndex, val, PathName(tintlayer)]));
                    result := StartsText(layername, val + ':');
                    if result then break;
                // end;
            end;
        end;
    end;
    if LOGGING then LogExitT1('CurNPCHasTintLayer', BoolToStr(Result));
end;

procedure ShowRaceTints;
var
    r, s, l, t: Cardinal;
begin
    AddMessage('==Race Tint Presets==');

    for l := 0 to TINT_COUNT-1 do begin
        AddMessage(tintlayerNames.strings[l]);
        for s := 0 to SEX_COUNT-1 do begin
            AddMessage('|   ' + IfThen((s and 1), 'FEMALE', 'MALE') + IfThen((s and 2), ' CHILD', ' ADULT'));
            for r := 0 to raceTintPresets[l, s].Count-1 do begin
                AddMessage(Format('|   |   "%s" %s @ %s', [
                    raceTintPresets[l, s].strings[r],
                    raceTintRequired[l, s].values[raceTintPresets[l, s].strings[r]],
                    PathName(ObjectToElement(raceTintPresets[l, s].objects[r]))]));
            end;
        end;
    end;
    for l := 0 to SPECIALTYPE_COUNT-1 do begin
        if l = SPECIALTYPE_BLACKBLOOD then AddMessage('BlackBlood')
        else if l = SPECIALTYPE_BOTHIAH then AddMessage('Bothiah')
        else if l = SPECIALTYPE_DIRT then AddMessage('Dirt')
        else if l = SPECIALTYPE_FREKLES then AddMessage('Frekles')
        else if l = SPECIALTYPE_PAINT then AddMessage('Paint');
        for s := 0 to SEX_COUNT-1 do begin
            AddMessage('|   ' + SexToStr(s));
            for r := 0 to raceTintSpecial[l, s].Count-1 do begin
                AddMessage('|   |   ' + raceTintSpecial[l, s].strings[r]);
                for t := 0 to raceTintSpecial[l, s].objects[r].Count-1 do begin
                    AddMessage('|   |   |   ' + raceTintSpecial[l, s].objects[r].strings[t]
                        + ' = ' + PathName(ObjectToElement(raceTintSpecial[l, s].objects[r].objects[t])));
                end;
            end;
        end;
    end;
    AddMessage('--Race Tint Presets--');

    AddMessage('==Race Tint Layers==');
    for s := 0 to SEX_COUNT-1 do begin
        AddMessage('|   ' + SexToStr(s));
        for r := 0 to raceTintIndices[s].count-1 do begin
            AddMessage('|   |   ' + raceTintIndices[s].strings[r]);
            for t := 0 to raceTintIndices[s].objects[r].count-1 do begin
                AddMessage('|   |   |   ' + raceTintIndices[s].objects[r].strings[t]);
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
            // LoadRaceTints(furryRace);
        end;

        if vanillaRaces.IndexOf(vanillaRaceName) < 0 then begin
            vanillaRaces.AddObject(vanillaRaceName, WinningOverride(vanillaRace));
            // LoadRaceTints(vanillaRace);
        end;

        // if LOGGING and (raceTintPresets[TINT_SKIN_TONE, SEX_MALEADULT].IndexOf('NordRace') >= 0) then
        //     LogD('(SetRace) NordRace skin tone: ' 
        //         + PathName(ObjectToElement(raceTintPresets[TINT_SKIN_TONE, SEX_MALEADULT]
        //             .objects[raceTintPresets[TINT_SKIN_TONE, SEX_MALEADULT].IndexOf('NordRace')])));


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
        hpNewList.Duplicates := dupIgnore;
        hpNewList.Sorted := true;
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
Cache key information about a headapart.
}
// procedure CacheHeadpart(hp: IwbMainRecord);
// var
//     idx: integer;
//     i: integer;
//     lst: IwbElement;
//     fl: IwbMainRecord;
// begin
//     if LOGGING then LogEntry1(15, 'CacheHeadpart', Name(hp));
//     idx := headpartRaces.IndexOf(EditorID(hp));
//     if idx < 0 then begin
//         headpartRaces.AddObject(EditorID(hp), TStringList.Create);
//         idx := headpartRaces.IndexOf(EditorID(hp));
//         headpartRaces.objects[idx].Duplicates := dupIgnore;
//         headpartRaces.objects[idx].Sorted := true;
//     end;
//     fl := WinningOverride(LinksTo(ElementByPath(hp, 'RNAM')));
//     lst := ElementByPath(fl, 'FormIDs');
//     if LOGGING then LogT(Format('Found %s size %s', [PathName(lst), IntToStr(ElementCount(lst))]));
//     for i := 0 to ElementCount(lst)-1 do begin
//         if LOGGING then LogT(Format('Caching headpart %s at %d', [EditorID(LinksTo(ElementByIndex(lst, i))), idx]));
//         headpartRaces.objects[idx].Add(EditorID(LinksTo(ElementByIndex(lst, i))));
//     end;
//     if LOGGING then LogExitT('CacheHeadpart');
// end;


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
        // CacheHeadpart(vanillaHP);
        // CacheHeadpart(furryHP);
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


// {============================================================================
// Find the available skin tones for the given NPC. The skin tone presets are returned in
// curNPCTintLayer*. 
// }
// procedure LoadNPCSkinTones(npc: IwbMainRecord);
// var 
//     raceIdx, sexIdx, presetsIdx: integer;
// begin
//     if LOGGING then LogEntry3(10, 'LoadNPCSkinTones', Name(npc), EditorID(curNPCrace), curNPCsex);
//     // raceIdx := raceTintPresets.IndexOf(EditorID(curNPCrace));
//     // sexIdx := raceTintPresets.objects[raceIdx].IndexOf(curNPCsex);
//     // curNPCTintLayerOptions := raceTintPresets.objects[raceIdx].objects[sexIdx];
//     curNPCTintLayerOptions := raceTintPresets[]
//     if LOGGING then LogExitT('LoadNPCSkinTones');
// end;

end.