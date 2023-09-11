{
}
unit BDAssetLoaderFO4;

interface
implementation
uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    LIMIT = HighInteger;

    // Max actor races supported. All the arrays holding race info use this.
    MAX_RACES = 50; 
    MAX_TEXTURES = 5; // Maximum texture alternatives for a tint layer.

    MALE = 0;
    FEMALE = 1;

    // Known NPC classes
    NONE = 0;
    CLASS_RAIDER = 1;
    CLASS_BOS = 2;
    CLASS_RR = 3;
    CLASS_MINUTEMEN = 4;
    CLASS_INSTITUTE = 5;
    CLASS_FARHARBOR = 6;
    CLASS_CABOT = 7;
    CLASS_OPERATOR = 8;
    CLASS_PACK = 9;
    CLASS_DISCIPLES = 10;
    CLASS_TRAPPER = 11;
    CLASS_ATOM = 12;
    CLASS_GUNNER = 13;
    CLASS_KELLOGG = 14;
    CLASS_KYLE = 15;
    CLASS_DELUCA = 16;
    CLASS_BOBROV = 17;
    CLASS_PEMBROKE = 18;
    CLASS_GARVEY = 19;
    CLASS_LONGFELLOW = 20;
    CLASS_CAIT = 21;
    CLASS_DANSE = 22;
    CLASS_DEACON = 23;
    CLASS_MACCREADY = 24;
    CLASS_PIPER = 25;
    CLASS_X688 = 26;
    CLASS_GAGE = 27;
    CLASS_GHOUL = 28;
    CLASS_COUNT = 29;

type TTintPreset = record
    presetColor: IwbMainRecord;
    defaultValue: float;
    presetIndex: integer;
    end;

//type TIntPresetArray = array of TTintPreset;

type TSkinTintLayer = Record
    name: string;
    maskType: string;
    element: IwbELement;
    end;

type TRaceInfo = Record
    mainRecord: IwbMainRecord;
    tintCount: array [0..12 {TINTLAYERS_COUNT}] of integer;
    tintProbability: array [0..12 {TINTLAYERS_COUNT}] of integer;
    tints: array [0..12 {TINTLAYERS_COUNT}, 0..5 {texture alternatives}] of TSkinTintLayer;
    headparts: array[{headpart count} 0..10] of TStringList;
    maskCount: integer;
    muzzleCount: integer;
    end;

var
    // Number of skin layers
    TINTLAYERS_COUNT: integer;

    // For each class, for each furry race, record the probability points.
    // classProbs[class, furry_race_count+1] is the total for that class.
    npcRaceAssignments: TStringList;
    classProbs: array [0..50 {CLASS_COUNT}, 0..50 {furry race count}] of integer;
    classProbsMin: array [0..50 {CLASS_COUNT}, 0..50 {furry race count}] of integer;
    classProbsMax: array [0..50 {CLASS_COUNT}, 0..50 {furry race count}] of integer;
    furrifyMales: boolean;
    furrifyFems: boolean;
    scalifyGhouls: boolean;

    // Store all race headparts. First index is 1:1 with the "races" stringlist.
    // There must not be more than MAX_RACES. Delphi won't let us make this a
    // dynamic array and won't let us use the Const in the array declaration, so
    // we're stuck with this. hp index is 1:1 with "headpartsList". 
    raceInfo: array[0..50 {MAX_RACES}, 0..2 {sex}] of TRaceInfo;

    // All actor races, collected from the load order.
    masterRaceList: TStringList;

    // Translates from CLASS as number to name
    classNames: TStringList;

    // All headpart types we can handle--translates between the headpart type string and 
    // an index.
    headpartsList: TStringList;

    // Add headpart names to this list and the Object will be set to the headpart
    // element for quick reference
    specialHeadparts: TStringList;

    // Initialized to be indices into headpartsList for text-to-index translations
    HEADPART_EYEBROWS: integer;
    HEADPART_EYES: integer;
    HEADPART_FACE: integer;
    HEADPART_FACIAL_HAIR: integer;
    HEADPART_HAIR: integer;
    HEADPART_MISC: integer;
    HEADPART_SCAR: integer;

    tintlayerName: TStringList;

    // Initialized to be indices into tintlayerName
    TL_CHEEK_COLOR_LOWER: integer;
    TL_CHEEK_COLOR: integer;
    TL_CHIN: integer;
    TL_EAR: integer;
    TL_EYELINER: integer;
    TL_EYESOCKET_LOWER: integer;
    TL_EYESOCKET_UPPER: integer;
    TL_FOREHEAD: integer;
    TL_LIP_COLOR: integer;
    TL_MASK: integer;
    TL_MISC: integer;
    TL_MUZZLE: integer;
    TL_NECK: integer;
    TL_NOSE: integer;
    TL_OLD: integer;
    TL_PAINT: integer;
    TL_SKIN_TONE: integer;

    // If any errors occurred during run.
    errCount: integer;
    logIndent: integer;

// =============================================================================

// Procedure Log(importance: integer; txt: string);
// var
//     i: integer;
//     s: string;
// begin
//     s := '';
// 	if importance <= LOGLEVEL then begin
//         if LeftStr(txt, 1) = '>' then dec(logIndent);
//         for i := 1 to logIndent do s := s + '|   ';
//         AddMessage(s + txt);
//         if LeftStr(txt, 1) = '<' then inc(logIndent);
//     end;
// end;

// procedure Err(txt: string);
// begin
//     AddMessage('ERROR: ' + txt);
//     inc(errCount);
// end;

function FormName(e: IwbMainRecord): string;
begin
    Result := EditorID(e) + ' [ ' + IntToHex(FormID(e),8) + ' ]';
end;

Function RaceIndex(theRace: IwbMainRecord): integer;
begin
    Result := masterRaceList.IndexOf(EditorID(theRace));
end;

Function RacenameIndex(racename: string): integer;
begin
    Result := masterRaceList.IndexOf(racename);
end;

//=======================================================
// Return the race of the NPC.
// NPCs based on templates don't have valid races in their own 
// record so we have to follow the chain of templates to find
// the race. 
Function GetNPCRace(npc: IwbMainRecord): IwbMainRecord;
var
    tpl, entry: IwbMainRecord;
    lle: IwbElement;
begin
    if (GetElementEditValues(npc, 'ACBS - Configuration\Use Template Actors\Traits') = '1') then begin
        tpl := LinksTo(ElementByPath(npc, 'TPLT'));
        if Signature(tpl) = 'LVLN' then begin
            lle := ElementByPath(tpl, 'Leveled List Entries');
            entry := LinksTo(ElementByPath(ElementByIndex(lle, 0), 'LVLO\Reference'));
            result := GetNPCRace(entry);
        end
        else 
            result := GetNPCRace(tpl);
    end
    else 
        result := LinksTo(ElementByPath(npc, 'RNAM'));
end;

//=====================================================
// Return the race index of the npc
Function GetNPCRaceID(npc: IwbMainRecord): integer;
begin
    Result := masterRaceList.IndexOf(EditorID(GetNPCRace(npc)));
end;

Function GetNPCSex(npc: IwbMainRecord): integer;
begin
    if GetElementNativeValues(npc, 'ACBS\Flags\female') then 
        Result := FEMALE
    else 
        Result := MALE;
end;


//-----------------------------------------------
Function GetClassName(classID: integer): string;
begin
    if classID = NONE then Result := 'NONE'
    else if classID = CLASS_RAIDER then Result := 'CLASS_RAIDER'
    else if classID = CLASS_BOS then Result := 'CLASS_BOS'
    else if classID = CLASS_RR then Result := 'CLASS_RR'
    else if classID = CLASS_MINUTEMEN then Result := 'CLASS_MINUTEMEN'
    else if classID = CLASS_INSTITUTE then Result := 'CLASS_INSTITUTE'
    else if classID = CLASS_FARHARBOR then Result := 'CLASS_FARHARBOR'
    else if classID = CLASS_CABOT then Result := 'CLASS_CABOT'
    else if classID = CLASS_OPERATOR then Result := 'CLASS_OPERATOR'
    else if classID = CLASS_PACK then Result := 'CLASS_PACK'
    else if classID = CLASS_DISCIPLES then Result := 'CLASS_DISCIPLES'
    else if classID = CLASS_TRAPPER then Result := 'CLASS_TRAPPER'
    else if classID = CLASS_ATOM then Result := 'CLASS_ATOM'
    else if classID = CLASS_GUNNER then Result := 'CLASS_GUNNER'
    else if classID = CLASS_KELLOGG then Result := 'CLASS_KELLOGG'
    else if classID = CLASS_KYLE then Result := 'CLASS_KYLE'
    else if classID = CLASS_DELUCA then Result := 'CLASS_DELUCA'
    else if classID = CLASS_BOBROV then Result := 'CLASS_BOBROV'
    else if classID = CLASS_PEMBROKE then Result := 'CLASS_PEMBROKE'
    else if classID = CLASS_CAIT then Result := 'CLASS_CAIT'
    else if classID = CLASS_DANSE then Result := 'CLASS_DANSE'
    else if classID = CLASS_DEACON then Result := 'CLASS_DEACON'
    else if classID = CLASS_MACCREADY then Result := 'CLASS_MACCREADY'
    else if classID = CLASS_PIPER then Result := 'CLASS_PIPER'
    else if classID = CLASS_X688 then Result := 'CLASS_X688'
    else if classID = CLASS_GAGE then Result := 'CLASS_GAGE'
    else if classID = CLASS_LONGFELLOW then Result := 'CLASS_LONGFELLOW'
    else if classID = CLASS_GARVEY then Result := 'CLASS_GARVEY'
    else if classID = CLASS_GHOUL then Result := 'CLASS_GHOUL'
    else Result := 'Unknown Class';
end;

//-----------------------------------------------
// Get a NPC's mother, if any
Function GetMother(theNPC: IwbMainRecord): integer;
var
  i: Integer;
  //loid: integer;
begin
    Log(3, '<GetMother checking for mother: ' + Name(theNPC));
    result := -1;

    for i := 0 to motherCount-1 do begin
        if GetLoadOrderFormID(children[i]) = GetLoadOrderFormID(theNPC) then begin
            result := i;
            Log(3, 'Found mother: ' + Name(mothers[i]) + ' for ' + Name(theNPC));
            break;
        end;
    end;
    Log(3, '>GetMother');
end;

// <<<<<<<<<<<<<<<<<<<<< MANAGE TINT LAYERS >>>>>>>>>>>>>>>>>>>>>

// procedure LoadTintLayer(r: integer; sex: integer; tli: integer; 
//     mt: string; thisLayer: IwbElement);
// begin
//     inc(logIndent);
//     Log(5, 'Loading tint layer ' + mt + ' race=' + IntToStr(r) +
//         ' sex=' + IntToStr(sex) + ' tint=' + IntToStr(tli));
//     raceInfo[r, sex].tints[tli].tini :=
//         GetElementNativeValues(thisLayer, 'Tint Layer\Texture\TINI');
//     raceInfo[r, sex].tints[tli].maskType := mt;
//     raceInfo[r, sex].tints[tli].element := thisLayer;
//     Log(5, 'Found tint mask ' + mt + ' TINI='
//         + IntToStr(raceInfo[r, sex].tints[tli].tini));
        
//     Log(5, 'Found ' + IntToStr(raceInfo[r, sex].tints[tli].presetsCount) +
//         ' presets starting at ' + IntToStr(raceInfo[r, sex].tints[tli].presetsStart));
//     dec(logIndent);
// end;

//===============================================================================
// Given the name used for a tint, return the tint layer it implements.
Function DetermineTintType(name: string): integer;
begin
    if SameText('Skin tone', name) then 
        Result := TL_SKIN_TONE
    else if SameText('Old', name) then 
        Result := TL_OLD
    else if StartsText('Ear', name) then
        Result := TL_EAR
    else if StartsText('Face Mask', name) then 
        Result := TL_MASK
    else if StartsText('Nose', name) then 
        Result := TL_NOSE
    else if StartsText('Muzzle', name) 
        or StartsText('Blaze', name) then 
        Result := TL_MUZZLE
    else if StartsText('Star', name) or StartsText('Forehead', name) then
        Result := TL_FOREHEAD
    else 
        Result := TL_PAINT
    ;
end;

//==================================================================
// Find and load info about all skin tints for the given race & sex.
// FO4 VERSION 
Procedure LoadTintLayerInfo(theRace: IwbMainRecord; sex: integer);
var
    i, j: integer;
    n: integer;
    raceID: integer; 
    rootElem: string;
    thisGroup: IwbElement; 
    tintGroups: IwbElement;
    tintLayer: IwbElement;
    tintName: string;
    tintType: integer;
    tintOptions: IwbElement; 
begin
    Log(11, Format('<LoadTintLayerInfo %s %s', [EditorID(theRace), IfThen(sex=MALE, 'M', 'F')]));
    raceID := RaceIndex(theRace);
    if sex = MALE then rootElem := 'Male Tint Layers' else rootElem := 'Female Tint Layers';
    tintGroups := ElementByPath(theRace, rootElem);

    Log(11, EditorID(theRace) + ' ' + rootElem + ' tint group count ' + IntToStr(ElementCount(tintGroups)));
    
    for i := 0 to ElementCount(tintGroups)-1 do begin
        thisGroup := ElementByIndex(tintGroups, i);
        Log(11, 'Found tint group ' + GetElementEditValues(thisGroup, 'TTGP'));

        tintOptions := ElementByPath(thisGroup, 'Options');
        Log(6, Format('Group has %d options', [integer(ElementCount(tintOptions))]));
        for j := 0 to ElementCount(tintOptions)-1 do begin
            tintLayer := ElementByIndex(tintOptions, j);
            tintName := GetElementEditValues(tintLayer, 'TTGP');
            tintType := DetermineTintType(tintName);

            n := raceInfo[raceID, sex].tintCount[tintType];

            // Log(6, Format('[%d] Found tint option "%s" -> %d', 
            //     [integer(j), tintname, integer(tintType)]));
            Log(6, Format('Found tint option [%d] "%s" -> [%d] %s', 
                [integer(j), tintname, integer(n), tintlayerName[tintType]]));

            if tintType < TINTLAYERS_COUNT then begin
                if n < MAX_TEXTURES then begin
                    raceInfo[raceID, sex].tints[tintType, n].name := tintName;
                    raceInfo[raceID, sex].tints[tintType, n].maskType := tintType;
                    raceInfo[raceID, sex].tints[tintType, n].element := tintLayer;
                    raceInfo[raceID, sex].tintCount[tintType] := n+1;
                end;
            end;
        end;
    end;

    Log(11, '>LoadTintLayerInfo');
end;

// //==================================================================
// // Find and load info about all skin tints for the given race & sex.
// // SKYRIM VERSION 
// procedure LoadTintsForSex(theRace: IwbMainRecord; sex: integer; tintlayers: IwbElement);
// var
//     i, r, tli: integer;
//     thisLayer: IwbElement;
//     mt: string;
//     fn: string;
// begin
//     Log(15, '<LoadTintsForSex ' + Name(theRace) + ' ' + IfThen(sex=MALE, 'M', 'F'));
//     r := masterRaceList.IndexOf(EditorID(theRace));
//     raceInfo[r, sex].mainRecord := theRace;
//     raceInfo[r, sex].muzzleCount := 0;
//     raceInfo[r, sex].maskCount := 0;

//     for i := 0 to ElementCount(tintlayers)-1 do begin
//         thisLayer := ElementByIndex(tintlayers, i);
//         mt := GetElementEditValues(thisLayer, 'Tint Layer\Texture\TINP');
//         Log(15, 'Found tint layer ' + mt);

//         tli := tintlayerName.IndexOf(mt);
//         if tli >= 0 then LoadTintLayer(r, sex, tli, mt, thisLayer);

//         fn := GetElementEditValues(thisLayer, 'Tint Layer\Texture\TINT');
//         // Log(15, 'Found ' + fn + ': ' 
//         //     + IfThen(EndsText('mask.dds', fn), 'MASK', ' ')
//         //     + IfThen(EndsText('muzzle.dds', fn), 'MUZZLE', ''));

//         if EndsText('old.dds', fn) then LoadTintLayer(r, sex, TL_OLD, 'Old', thisLayer);
//         if EndsText('ear.dds', fn) or EndsText('ears.dds', fn) then
//             LoadTintLayer(r, sex, TL_EAR, 'Ear', thisLayer);
//         if EndsText('mask.dds', fn) then begin
//             LoadTintLayer(r, sex, TL_MASK + raceInfo[r, sex].maskCount, 'Mask', thisLayer);
//             raceInfo[r, sex].maskCount := raceInfo[r, sex].maskCount + 1;
//         end;
//         if EndsText('muzzle.dds', fn) then begin
//             LoadTintLayer(r, sex, TL_MUZZLE + raceInfo[r, sex].muzzleCount, 'Muzzle', thisLayer);
//             raceInfo[r, sex].muzzleCount := raceInfo[r, sex].muzzleCount + 1;
//         end;

//     end;
//     Log(15, '>LoadTintsForSex');
// end;

//===============================================================
// Collect tint layer information.
//
// FO4 doesn't have standardized tint layers, except skin tone. We define layers we care
// about and have magic ways to match them up.
procedure CollectTintLayers(theRace: IwbMainRecord);
var
    i: integer;
begin
    Log(12, '<CollectTintLayers');

    LoadTintLayerInfo(theRace, MALE);
    LoadTintLayerInfo(theRace, FEMALE);

    Log(12, '>CollectTintLayers ');
end;

//=========================================================================
// Given a tint index from a NPC record, find the corresponding tint mask in the race record
// return the TINI index; -1 if not found
// returns found mask type in foundLayerMaskType
//
function FindRaceTintLayerByTINI(r: integer; sex: integer; targetTINI: integer): integer;
var
	skinStr: string;
	i, rli: integer;
	raceTINI: integer;
	layer: IInterface;
	layerFile, layerName: string;
	maskList, mask: IInterface;
	found: integer;
begin
	Log(5, '<FindRaceTintLayerByTINI: ' + IntToStr(targetTINI) + ' in ' + EditorID(raceInfo[r, sex].mainRecord) +
        IfThen(sex=0, ' M', ' F'));

    // Walk the race's tint layers until we find the one requested
    found := -1;
    for i := 0 to TINTLAYERS_COUNT-1 do begin
        Log(6, 'Checking tint ' + IntToStr(raceInfo[r, sex].tints[i].TINI));

        if raceInfo[r, sex].tints[i].TINI = targetTINI then
            found := i;
        if found >= 0 then break;
    end;

    Result := found;

    Log(5, '>FindRaceTintLayerByTINI ' + IntToStr(found));
end;

//===================================================
// Pick out a color from the presets by name of color
// Returns the preset itself
Function ChoosePresetByColor(raceIndex, sex: integer; colorName: string; tintLayer: integer): 
    IwbElement;
var
    presetlist: IwbElement;
	colorPreset: IwbElement;
	color: IwbMainRecord;
	i: integer;
begin
	Log(5, '<ChoosePresetByColor: ' +colorName);

    Result := nil;
    presetlist := ElementByPath(raceInfo[raceIndex, sex].tints[tintLayer].element, 'Presets');
    for i := 0 to ElementCount(presetlist) - 1 do begin
        colorPreset := ElementByIndex(presetlist, i);
        color := WinningOverride(LinksTo(ElementByPath(colorPreset, 'TINC')));
        if EditorID(color) = colorName then begin
            Result := colorPreset;
            break;
        end;
    end;

    Log(5, '>ChoosePresetByColor: ' + PathName(Result));
end;

//===================================================
// Pick out a color from the presets by name of color
// Returns the color form
Function ChooseNamedColor(raceIndex, sex: integer; colorName: string; tintLayer: integer): IwbMainRecord;
var
	colorPreset: IwbElement;
	color: IwbMainRecord;
	i: integer;
begin
	Log(5, 'ChooseNamedColor:  ' +colorName);
    Result := WinningOverride(LinksTo(
        ElementByPath(ChoosePresetByColor(raceIndex, sex, colorName, tintLayer),
                      'TINC')));
end;

//======================================================
// Find a tint layer by mask filename
// No magic caching, might be slow. But used only for a few NPCs.
// Returns index into the tint list
function FindTintLayerByFilename(raceIndex, sex: integer; filename: string): integer;
var
    i: integer;
    n: string;
begin
    Log(9, '<FindTintLayerByFilename: ' + filename);
    Result := -1;

    for i := 0 to TINTLAYERS_COUNT-1 do begin
        if Assigned(raceInfo[raceIndex, sex].tints[i].element) then begin
            n := GetElementEditValues(raceInfo[raceIndex, sex].tints[i].element, 'Tint Layer\Texture\TINT');
            Log(9, 'Checking ' + PathName(raceInfo[raceIndex, sex].tints[i].element));
            Log(9, 'Checking ' + n);
            if ContainsText(n, filename) then begin
                Result := i;
                break;
            end;
        end;
    end;
    Log(9, '>FindTintLayerByFilename: ' + IntToStr(Result));
end;

function GetTINIByTintIndex(raceIndex, sex, theTintIndex: integer): integer;
begin   
    Result := raceInfo[raceIndex, sex].tints[theTintIndex].TINI;
end;

//============================================================
// Pick a random preset from a tint layer
// Return the template color element.
// ind = 1 to skip the initial preset, which is often "no tint"
Function PickRandomTintPreset(hashstr: string; seed, theRace, sex, tintLayer, ind: integer): IwbElement;
var
    alt: integer;
    r: integer;
    colorList: IwbContainer;
Begin
    Log(10, Format('<PickRandomTintPreset %s %s %d', [hashstr, tintlayerName[tintlayer], integer(ind)]));
    alt := Hash(hashstr, seed, raceInfo[theRace, sex].tintCount[tintLayer]);
    colorList := ElementByPath(raceInfo[theRace, sex].tints[tintLayer, alt].element, 'TTEC');
    if ElementCount(colorList) = 0 then
        Result := nil
    else begin
        r := Hash(hashstr, seed, ElementCount(colorList)-ind) + ind;
        Result := ElementByIndex(colorList, r);
    end;
    Log(10, '>PickRandomTintPreset')
end;


// <<<<<<<<<<<<<<<<<<<<  MANAGE HEAD PARTS  >>>>>>>>>>>>>>>>>>>>

function HeadpartFacialType(hp: IwbMainRecord): integer;
// Return the facial type of the head part as an index into headpartsList
var
    s: string;
    i: integer;
begin
    s := GetElementEditValues(hp, 'PNAM');
    i := headpartsList.IndexOf(s);
    // Log(5, 'HeadpartFacialType of ' + Name(hp) + ' = ' + IntToStr(i));
    Result := i;
end;

function HeadpartSexIs(hp: IwbMainRecord; sex: integer): boolean;
// Determine whether the head part hp works for the given sex
begin
    // Log(5, 'HeadpartSexIs M:' + GetMRAssetStr(hp, 'DATA - Flags\Male')
    //     + 'F:' + GetMRAssetStr(hp, 'DATA - Flags\Female'));
    Result := ((sex = MALE) and (GetElementEditValues(hp, 'DATA - Flags\Female') = '0'))
        or
        ((sex = FEMALE) and (GetElementEditValues(hp, 'DATA - Flags\Male') = '0'));
end;

//------------------------------------------------------------
// Load the head part and add it to our races' head parts
procedure LoadHeadPart(hp: IwbMainRecord);
var 
    facialType: integer;
    formList: IwbElement;
    hpsex, sex: integer;
    i: integer;
    raceIndex: integer;
    raceName: string;
    raceRec: IwbMainElement;
    raceRef: IwbElement;
    validRaceList: IwbMainRecord;
begin
    Log(16, Format('<LoadHeadPart %s %s', [FormName(hp), GetElementEditValues(hp, 'PNAM')]));

    // if targetHeadparts.IndexOf(EditorID(hp)) >= 0 then 
    //     specialHeadparts.AddObject(EditorID(hp), hp);

    // Get the form list that has the races for this head part
    validRaceList := WinningOverride(LinksTo(ElementByPath(hp, 'RNAM - Valid Races')));
    Log(16, 'Found reference to form list ' + EditorID(validRaceList));

    facialType := HeadpartFacialType(hp);

    if facialType < 0 then 
        Log(15, 'Unknown facial type: ' + GetElementEditValues(hp, 'PNAM'))
    else begin
        Log(15, 'Headpart is for [' 
            + IfThen(HeadpartSexIs(hp, MALE), 'M', '') 
            + IfThen(HeadpartSexIs(hp, FEMALE), 'F', '') + ']');
        
        formList := ElementByPath(validRaceList, 'FormIDs');
        for i := 0 to ElementCount(formList)-1 do begin
            raceRef := ElementByIndex(formList, i);
            
            if not Assigned(raceRef) then break;

            raceRec := LinksTo(raceRef);
            raceName := EditorID(raceRec);
            Log(15, 'Found reference to race ' + FormName(raceRec));
            raceIndex := masterRaceList.IndexOf(racename);
            if raceIndex >= 0 then begin
                for sex := MALE to FEMALE do begin
                    if HeadpartSexIs(hp, sex) then 
                    begin
                        if not Assigned(raceInfo[raceIndex, sex].headparts[facialType]) then 
                            raceInfo[raceIndex, sex].headParts[facialType] := TStringList.Create;
                        raceInfo[raceIndex, sex].headParts[facialType]
                            .AddObject(EditorId(hp), hp);
                        Log(14, 'Race ' + racename + ' has HP ' + EditorID(hp));
                    end;
                end;
            end;
        end;
    end;

    Log(16, '>LoadHeadPart');
end;

//-----------------------------------------------------------
// Find all headparts for our races.
procedure CollectRaceHeadparts;
var
    hpDone: TStringList;
    i, j: integer;
    g: IwbContainer;
    f: IwbFile;
    hp: IwbMainRecord;
    hpname: string;
begin
    Log(2, '<CollectRaceHeadparts');
    
    hpDone := TStringList.Create;
    hpDone.Duplicates := dupIgnore;
    hpDone.Sorted := true;

	for i := 0 to FileCount()-1 do begin
		f := FileByLoadOrder(i);

        g := GroupBySignature(f, 'HDPT');
        for j := 0 to ElementCount(g)-1 do begin
            hp := WinningOverride(ElementByIndex(g, j));
            hpname := EditorID(hp);

            if hpDone.IndexOf(hpname) < 0 then 
                LoadHeadpart(hp);
            hpDone.Add(hpname);

            if hpDone.Count > LIMIT then break;
        end;
        //if SameText(GetFileName(f), yaFileName) then break; // Stop when we hit YA
    end;

    hpDone.Free;
    Log(2, '>CollectRaceHeadparts');
end;

// <<<<<<<<<<<<<<<<<<<<<< MANAGE RACES >>>>>>>>>>>>>>>>>>>>>>

// -----------------------------------------
// Add the given race editorID to the master list of races.
function AddRace(racename: string): integer;
var
    n: integer;
    i: integer;
    id: Cardinal;
    r: IwbMainRecord;
begin
    Log(16, '<AddRace: ' + racename);
    n := masterRaceList.IndexOf(racename);
    if n >= 0 then 
        Result := n
    else begin
        for i := 0 to FileCount-1 do begin
            r := FindAsset(FileByIndex(i), 'RACE', racename);
            id := RealFormID(r);
            if id <> 0 then break;
        end;
        if id = 0 then begin
            Err('Could not find race ' + racename);
            Result := -1;
        end
        else begin
            Log(16, EditorID(r) + ' has formID ' + IntToHex(id, 8) + ' in ' + GetFileName(FileByIndex(i)));
            if masterRaceList.Count >= MAX_RACES then begin
                Err('Too many races, stopped at ' + racename);
                Result := -1;
            end
            else begin
                Result := masterRaceList.Count;
                masterRaceList.AddObject(racename, TObject(r));
                raceInfo[Result, MALE].mainRecord := r;
                raceInfo[Result, FEMALE].mainRecord := r;
            end;
        end;
    end;
    Log(16, '>AddRace: ' + racename);
end;


procedure CollectRaceTintLayers;
var
    i: integer;
    race: IwbMainRecord;
begin
    Log(11, '<CollectRaces');

    tintlayerName.Add('Ear');
    tintlayerName.Add('Forehead');
    tintlayerName.Add('Lip Color');
    tintlayerName.Add('Mask');
    tintlayerName.Add('Muzzle');
    tintlayerName.Add('Neck');
    tintlayerName.Add('Nose');
    tintlayerName.Add('Old');
    tintlayerName.Add('Paint');
    tintlayerName.Add('Skin Tone');
    TINTLAYERS_COUNT := tintlayerName.Count;

    TL_EAR := tintlayerName.IndexOf('Ear');
    TL_FOREHEAD := tintlayerName.IndexOf('Forehead');
    TL_LIP_COLOR := tintlayerName.IndexOf('Lip Color');
    TL_MASK := tintlayerName.IndexOf('Mask');
    TL_MUZZLE := tintlayerName.IndexOf('Muzzle');
    TL_NECK := tintlayerName.IndexOf('Neck');
    TL_NOSE := tintlayerName.IndexOf('Nose');
    TL_OLD := tintlayerName.IndexOf('Old');
    TL_PAINT := tintlayerName.IndexOf('Paint');
    TL_SKIN_TONE := tintlayerName.IndexOf('Skin Tone');

    for i := 0 to tintlayerName.Count-1 do 
        Log(12, Format('[%d] %s', [i, tintlayerName[i]]));

    for i := 0 to masterRaceList.Count-1 do begin
        race := ObjectToElement(masterRaceList.Objects[i]);
        Log(11, 'Found race ' + EditorID(race));
        CollectTintLayers(race);
    end;
    
    Log(11, '>CollectRaces');
end;


// <<<<<<<<<<<<<<<<<Access functions to hide the implementation>>>>>>>>>>>>>>>>>

function GetRaceTintTINI(theRace, sex, tintLayer: integer): integer;
begin
    Result := raceInfo[theRace, sex].tints[tintLayer].TINI;
end;

function GetRaceTintMaskType(theRace, sex, tintLayer: integer): string;
begin
    Log(6, 'GetRaceTintMaskType: tintLayer=' + IntToStr(tintLayer));
    Result := raceInfo[theRace, sex].tints[tintLayer].maskType;
end;

function GetRaceMaskCount(theRace, sex: integer): integer;
begin
    Result := raceInfo[theRace, sex].maskCount;
end;

function GetRaceMuzzleCount(theRace, sex: integer): integer;
begin
    Result := raceInfo[theRace, sex].muzzleCount;
end;

function GetRaceTintElement(theRace, sex, tintLayer: integer): IwbElement;
begin
    Result := raceInfo[theRace].tints[sex, tintLayer].element;
end;

//===================================================================
// Return count of headparts of the given type for the given race & sex.
Function GetRaceHeadpartCount(theRace, sex, hpType: integer): integer;
begin
    if (hpType < 0) or (hpType >= headpartsList.Count) then begin
        Err('GetRaceHeadpartCount: headpart type index too large: ' + IntToStr(hpType));
        Result := 0;
    end
    else if not Assigned(raceInfo[theRace, sex].headparts[hpType]) then
        Result := 0
    else
        Result := raceInfo[theRace, sex].headparts[hpType].Count;
end;

//===================================================================
// Return the record for the given headpart.
function GetRaceHeadpart(theRace, sex, hpType, hpIndex: integer): IwbMainRecord;
var 
    i: integer;
begin
    Log(10, Format('<GetRaceHeadpart: %s, %d, %d, %d', 
        [masterRaceList[theRace], sex, hpType, hpIndex]));
    // Log(10, Format('Number of headparts: %d', [headpartsList.Count]));
    // for i := 0 to headpartsList.Count-1 do
    //     Log(10, Format('Have headpart [%d] %s', [i, headpartsList[i]]));
    // Log(10, 'Headpart type initialized: ' + BoolToStr(Assigned(raceInfo[theRace, sex].headparts[hpType])));
    // Log(10, Format('Count of headparts available: %d', [raceInfo[theRace, sex].headparts[hpType].Count]));
    Result := ObjectToElement(
        raceInfo[theRace, sex].headparts[hpType].Objects[hpIndex]);
    Log(10, '>GetRaceHeadpart')
end;

//============================================================
// Determine whether a headpart can be assigned to a race.
function HeadpartValidForRace(theHP: IwbMainRecord; raceIndex, sex, hpType: integer): boolean;
begin
    Result := raceInfo[raceIndex, sex].headparts[hpType].IndexOf(EditorID(theHP)) >= 0;
end;

//=============================================================================
// Pick a random headpart of a given type.
Function PickRandomHeadpart(hashstr: string; seed, race, sex, hpType: integer): IwbMainRecord;
var
    n: integer;
    h: integer;
Begin
    n := GetRaceHeadpartCount(race, sex, hpType);
    h := Hash(hashstr, seed, n);
    Result := GetRaceHeadpart(race, sex, hpType, h);
end;


//============================================================
// Determine if NPC is in faction
Function IsInFaction(theNPC: IwbMainRecord; theFaction: string): boolean;
begin
	result := ElementListContains(theNPC, 'Factions', theFaction);
end;

Procedure GetNPCFactions(npc: IwbMainRecord; factions: TStringList);
var
	factionList: IInterface;
    i: integer;
begin
	factionList := ElementByPath(npc, 'Factions');
    for i := 0 to ElementCount(factionList)-1 do 
    begin
        factions.Add(EditorID(LinksTo(ElementByPath(ElementByIndex(factionList, i), 'Faction'))));
    end;
end;

//============================================================
// Determine the class of an NPC 
//
// Look at various characteristics of the NPC to determine the best class. 
// Order of the checks matters.
Function GetNPCClass(theNPC: IwbMainRecord): integer;
var
    npcEditorID: string;
    npcName: string;
    factionList: TStringList;
begin
    npcEditorID := EditorID(theNPC);
    npcName := GetElementEditValues(theNPC, 'FULL');
    factionList := TStringList.Create;
    GetNPCFactions(theNPC, factionList);

    Result := NONE;

    // Ghouls
    if (EditorID(GetNPCRace(theNPC)) = 'GhoulRace') or 
        (EditorID(GetNPCRace(theNPC)) = 'GhoulChildRace') then
        Result := CLASS_GHOUL
        
    // Followers
    else if SameText(npcEditorID, 'CompanionCait') then Result := CLASS_CAIT
    else if SameText(npcEditorID, 'BoSPaladinDanse') then Result := CLASS_DANSE
    else if ContainsText(npcEditorID, 'CompanionDeacon') then Result := CLASS_DEACON
    else if SameText(npcEditorID, 'CompanionMacCready') then Result := CLASS_MACCREADY
    else if SameText(npcEditorID, 'CompanionPiper') then Result := CLASS_PIPER
    else if SameText(npcEditorID, 'Natalie') then Result := CLASS_PIPER
    else if SameText(npcEditorID, 'CompanionX6-88') then Result := CLASS_X688
    else if SameText(npcEditorID, 'DLC04Gage') then Result := CLASS_GAGE
    else if SameText(npcEditorID, 'PrestonGarvey') then Result := CLASS_GARVEY
    else if SameText(npcEditorID, 'DLC03_CompanionOldLongfellow') then Result := CLASS_LONGFELLOW

    // Specific NPCs and NPC families where we want them all to have the same race.
    else if ContainsText(npcEditorID, 'Kellogg') then Result := CLASS_KELLOGG
    else if SameText(npcEditorID, 'MQ203MemoryA_Mom') then Result := CLASS_KELLOGG
    else if SameText(npcEditorID, 'FFDiamondCity12Kyle') then Result := CLASS_KYLE
    else if ContainsText(npcEditorID, 'DeLuca') then Result := CLASS_DELUCA
    else if ContainsText(npcEditorID, 'Bobrov') then Result := CLASS_BOBROV
    else if ContainsText(npcEditorID, 'Pembroke') then Result := CLASS_PEMBROKE
    else if ContainsText(npcName, 'Cabot') then Result := CLASS_CABOT

    // Groups of NPCs that can have different probabilities
    else if ContainsText(npcEditorID, 'Gunner') then Result := CLASS_GUNNER
    else if factionList.IndexOf('BrotherhoodofSteelFaction') >= 0 then Result := CLASS_BOS
    else if factionList.IndexOf('RailroadFaction') >= 0 then Result := CLASS_RR
    else if factionList.IndexOf('MinutemenFaction') >= 0 then Result := CLASS_MINUTEMEN
    else if factionList.IndexOf('InstituteFaction') >= 0 then Result := CLASS_INSTITUTE
    else if factionList.IndexOf('DLC03SettlementFarHarborFaction') >= 0 then Result := CLASS_FARHARBOR
    else if factionList.IndexOf('DLC04GangOperatorsFaction') >= 0 then Result := CLASS_OPERATOR
    else if factionList.IndexOf('DLC04GangPackFaction') >= 0 then Result := CLASS_PACK
    else if factionList.IndexOf('DLC04GangDisciplesFaction') >= 0 then Result := CLASS_DISCIPLES
    else if factionList.IndexOf('DLC03TrapperFaction') >= 0 then Result := CLASS_TRAPPER
    else if factionList.IndexOf('RaiderFaction') >= 0 then Result := CLASS_RAIDER
    else if factionList.IndexOf('TheForgedFaction') >= 0 then Result := CLASS_RAIDER
    else if factionList.IndexOf('ChildrenOfAtomFaction') >= 0 then Result := CLASS_ATOM
    else if ContainsText(npcEditorID, 'Minutemen') then Result := CLASS_MINUTEMEN
    else if ContainsText(npcEditorID, 'Institute') then Result := CLASS_INSTITUTE
    else if ContainsText(npcEditorID, 'FarHarbor') then Result := CLASS_FARHARBOR
    ;

    factionList.Free;
end;


//-------------------------------------------------------
// Force an NPC to a specfic race.
Procedure AssignNPCRace(npcEditorID: string; racename: string);
var
    npc: IwbMainRecord;
    race: IwbMainRecord;
begin
    Log(11, '<AssignNPCRace ' + npcEditorID + ' <- ' + racename);
    npc := FindAsset(Nil, 'NPC_', npcEditorID);
    race := FindAsset(Nil, 'RACE', racename);
    Log(11, 'Assigning ' + EditorID(npc) + ' race ' + EditorID(race));
    Log(11, 'Race is in file ' + GetFileName(GetFile(race)));
    npcRaceAssignments.AddObject(npcEditorID, TObject(race));
    Log(11, '>AssignNPCRace');
end;

//-------------------------------------------------------
// Set the probabilities for a single class/race pair
// Adds the race to the list of known furry races.
Procedure SetClassProb(npcclass: integer; race: string; points: integer);
var 
    r: integer;
begin
    Log(16, '<SetClassProb');
    r := AddRace(race);
    if r >= 0 then classProbs[npcclass, r] := points;
    Log(16, '>SetClassProb');
end;


//---------------------------------------------------
// For efficiency, calculate the total points for a class and also
// the breakpoints between races.
Procedure CalcClassTotals();
var
    c: integer;
    n: integer;
    r: integer;
begin
    Log(11, '<CalcClassTotals');
    for c := 0 to CLASS_COUNT-1 do begin
        n := 0;
        for r := 0 to masterRaceList.Count-1 do begin
            classProbsMin[c, r] := n;
            n := n + classProbs[c, r];
            classProbsMax[c, r] := n-1;
        end;
        classProbs[c, masterRaceList.Count] := n;
    end;
    if LOGLEVEL >= 20 then begin
        for c := 0 to CLASS_COUNT-1 do begin
            Log(11, GetClassName(c) + ' totals: ' + IntToStr(classProbs[c, masterRaceList.Count]));
            for r := 0 to masterRaceList.Count-1 do 
                Log(11, GetClassName(c) + ' ' + masterRaceList[r] 
                    + ' [' + IntToStr(classProbsMin[c, r]) + ', ' 
                    + IntToStr(classProbsMax[c, r]) + ']');
        end;
    end;
    Log(11, '>CalcClassTotals');
end;

procedure InitializeAssetLoader;
begin
    // gameAssetsStr := TStringList.Create;
    // gameAssetsStr.Duplicates := dupIgnore;
    // gameAssetsStr.Sorted := true;
    // gameAssetsElem := TStringList.Create;
    // gameAssetsElem.Duplicates := dupIgnore;
    // gameAssetsElem.Sorted := true;

    // The headparts we care about
    headpartsList := TStringList.Create;
    headpartsList.Duplicates := dupIgnore;
    headpartsList.Sorted := true;
    headpartsList.Add('Eyebrows');
    headpartsList.Add('Eyes');
    headpartsList.Add('Face');
    headpartsList.Add('Facial Hair');
    headpartsList.Add('Hair');
    headpartsList.Add('Misc');
    headpartsList.Add('Scar');
    HEADPART_EYEBROWS := headpartsList.IndexOf('Eyebrows');
    HEADPART_EYES := headpartsList.IndexOf('Eyes');
    HEADPART_FACE := headpartsList.IndexOf('Face');
    HEADPART_FACIAL_HAIR := headpartsList.IndexOf('Facial Hair');
    HEADPART_HAIR := headpartsList.IndexOf('Hair');
    HEADPART_MISC := headpartsList.IndexOf('Misc');
    HEADPART_SCAR := headpartsList.IndexOf('Scar');

    specialHeadparts := TStringList.Create;
    specialHeadparts.Duplicates := dupIgnore;
    specialHeadparts.Sorted := true;

    masterRaceList := TStringList.Create;
    masterRaceList.Sorted := false;
    masterRaceList.Duplicates := dupIgnore;
    
    tintlayerName := TStringList.Create;
    tintlayerName.Duplicates := dupIgnore;
    tintlayerName.Sorted := false; // Need these in the order we add them

    npcRaceAssignments := TStringList.Create;
    npcRaceAssignments.Duplicates := dupIgnore;
    npcRaceAssignments.Sorted := true;
end;

procedure LoadRaceAssets;
begin
    CollectRaceTintLayers;
    CollectRaceHeadparts;
end;

procedure ShutdownAssetLoader;
var
    i, j, k: integer;
begin
    for i := 0 to masterRaceList.Count-1 do begin
        for j := MALE to FEMALE do begin
            for k := 0 to headpartsList.count - 1 do begin
                if Assigned(raceInfo[i, j].headParts[k]) then  
                    raceInfo[i, j].headParts[k].Free;
            end;
        end;
    end;

    // gameAssetsElem.Free;
    // gameAssetsStr.Free;
    headpartsList.Free;
    specialHeadparts.Free;
    tintlayerName.Free;
    npcRaceAssignments.Free;
end;

end.