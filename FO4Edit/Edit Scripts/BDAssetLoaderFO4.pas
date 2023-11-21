{
}
unit BDAssetLoaderFO4;

interface
implementation
uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    LIMIT = HighInteger;

    // Max actor races supported. All the arrays holding race info use this.
    RACES_MAX = 50; 
    TEXTURES_MAX = 5; // Maximum texture alternatives for a tint layer.

    SEX_LO = 0;
    MALE = 0;
    FEMALE = 1;
    MALECHILD = 2;
    FEMALECHILD = 3;
    SEX_HI = 3;

    // Known NPC classes
    CLASS_LO = 0;
    CLASS_SETTLER = 0;
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
    CLASS_DALTON = 29;
    CLASS_PLAYER = 30;
    CLASS_HI = 30;

    TINTLAYERS_MAX = 20;
    HAIR_MAX = 400;

    // Morphs
    EVEN = 0;
    SKEW0 = 1;
    SKEW1 = 2;

    HEADPART_NOTFOUND = -1;

type TNPCData = record
    handle: IwbMainRecord;
    id: string;
    sig: string;
    name: string;
    sex: integer;
    race: integer;
    furry_race: integer;
    npcclass: integer;
    old_hair: IwbMainRecord;
    plugin: IwbFile;
    is_old: Boolean;
    end;

type TTintPreset = record
    presetColor: IwbMainRecord;
    defaultValue: float;
    presetIndex: integer;
    end;

//type TIntPresetArray = array of TTintPreset;

type TTransform = Record
    x, y, z: float;
    xRot, yRot, zRot: float;
    scale: float;
end;

type TSkinTintLayer = Record
    name: string;
    maskType: string;
    element: IwbELement;
end;

type TFaceBone = Record
    FMRI: integer;
    min, max: TTransform;
end;

type TRaceInfo = Record
    mainRecord: IwbMainRecord;
    tintCount: array [0..100 {TINTLAYERS_MAX}] of integer;
    tintProbability: array [0..100 {TINTLAYERS_MAX}] of integer;
    tintColors: array [0..100 {TINTLAYERS_MAX}] of string;
    tints: array [0..100 {TINTLAYERS_MAX}, 0..5 {texture alternatives}] of TSkinTintLayer;
    headparts: array[{headpart count} 0..10] of TStringList;
    headpartProb: array[{headpart count} 0..10] of integer; // 0..100
    maskCount: integer;
    muzzleCount: integer;
    morphGroups: TStringList; 
    morphProbability: TStringList;
    morphLo: TStringList;
    morphHi: TStringList;
    morphSkew: TStringList;
    morphExcludes: TStringList;
    faceBones: array[0..10] of TFaceBone;
    faceBoneList: TStringList;
    end;

var
    // Number of skin layers
    TINTLAYERS_COUNT: integer;

    // For each class, for each furry race, record the probability points.
    // classProbs[class, furry_race_count+1] is the total for that class.
    npcRaceAssignments: TStringList;
    classProbs: array [0..50 {CLASS_HI}, 0..50 {furry race count}] of integer;
    classProbsMin: array [0..50 {CLASS_HI}, 0..50 {furry race count}] of integer;
    classProbsMax: array [0..50 {CLASS_HI}, 0..50 {furry race count}] of integer;
    convertingGhouls: boolean;

    // Store all race headparts. First index is 1:1 with the "races" stringlist.
    // There must not be more than RACES_MAX. Delphi won't let us make this a
    // dynamic array and won't let us use the Const in the array declaration, so
    // we're stuck with this. hp index is 1:1 with "headpartsList". 
    raceInfo: array[0..50 {RACES_MAX}, 0..4 {sex}] of TRaceInfo;

    // All actor races, collected from the load order.
    masterRaceList: TStringList;
    // Chlid races 1:1 with adult races
    childRaceList: TStringList;
    // Races referenced but not in load order
    racesNotFound: TStringList;

    RACE_LO, RACE_HI: integer;

    // Translates from CLASS as number to name
    classNames: TStringList;

    // All headpart types we can handle--translates between the headpart type string and 
    // an index.
    headpartsList: TStringList;

    // Separate list of regular hair, with corresponding furry hair
    vanillaHairRecords: TStringList;
    furryHair: array [0..400 {HAIR_MAX}, 0..50 {RACES_MAX}] of IwbMainRecord;
    lionMane: IwbMainRecord;
    hairExcludeList: TStringList;

    // Indexed by child, value is parent element ID.
    mothers: TStringList;
    fathers: TStringList;

    // Add headpart names to this list and the Object will be set to the headpart
    // element for quick reference
    specialHeadparts: TStringList;

    // Names used by generic NPCs
    genericNames: TStringList;

    // Known races of interest
    RACE_CHEETAH: integer;
    RACE_DEER: integer;
    RACE_FOX: integer;
    RACE_HORSE: integer;
    RACE_HYENA: integer;
    RACE_LION: integer;
    RACE_LYKAIOS: integer;
    RACE_OTTER: integer;
    RACE_SNEKDOG: integer;
    RACE_TIGER: integer;
    RACE_HUMAN: integer;
    RACE_GHOUL: integer;

    // Initialized to be indices into headpartsList for text-to-index translations
    HEADPART_EYEBROWS: integer;
    HEADPART_EYES: integer;
    HEADPART_FACE: integer;
    HEADPART_FACIAL_HAIR: integer;
    HEADPART_HAIR: integer;
    HEADPART_MISC: integer;
    HEADPART_SCAR: integer;
    HEADPART_MEATCAP: integer;
    HEADPART_MOUTH: integer;
    HEADPART_LO: integer;
    HEADPART_HI: integer;

    tintlayerName: TStringList;

    // Initialized to be indices into tintlayerName
    TL_CHEEK_COLOR_LOWER: integer;
    TL_CHEEK_COLOR: integer;
    TL_CHIN: integer;
    TL_EAR: integer;
    TL_EYEBROW: integer;
    TL_EYELINER: integer;
    TL_EYESOCKET_LOWER: integer;
    TL_EYESOCKET_UPPER: integer;
    TL_FOREHEAD: integer;
    TL_LIP_COLOR: integer;
    TL_MASK: integer;
    TL_MISC: integer;
    TL_MUZZLE: integer;
    TL_MUZZLE_STRIPE: integer;
    TL_NECK: integer;
    TL_NOSE: integer;
    TL_OLD: integer;
    TL_PAINT: integer;
    TL_SCAR: integer;
    TL_SKIN_TONE: integer;

    knownTTGP: TStringList;
    translateTTGP: array[0..200] of integer;

    // If any errors occurred during run.
    errCount: integer;
    logIndent: integer;

    // NPC currently being furrified. Functions using this varaible start with NPC_.
    curNPC: TNPCData;
    savedNPC: array [0..5] of TNPCData;
    savedNPCIndex: integer;

// =============================================================================

function FormName(e: IwbMainRecord): string;
begin
    Result := EditorID(e) + ' [ ' + IntToHex(FormID(e),8) + ' ]';
end;

//=======================================================
// Return the race index for the given race record.
Function RaceIndex(theRace: IwbMainRecord): integer;
begin
    Result := masterRaceList.IndexOf(EditorID(theRace));
    if Result < 0 then 
        Result := childRaceList.IndexOf(EditorID(theRace));
end;

Function RacenameIndex(racename: string): integer;
begin
    Result := masterRaceList.IndexOf(racename);
    if (Result < 0) and (racesNotFound.IndexOf(racename) < 0) then
        Err(Format('Race not defined with SetClassProb: %s', [racename]));
end;

Function RaceIDtoStr(id: integer): string;
begin
    result := '[' + IntToStr(id) + '] ';
    if id = RACE_GHOUL then 
        result := result + 'GhoulRace'
    else if (id >= 0) and (id < masterRaceList.Count) then 
        result := result + masterRaceList[id]
    else 
        result := result + 'NO RACE';
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
    tpl := NPCTraitsTemplate(npc);
    if Assigned(tpl) then begin
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
var 
    race: IwbMainRecord;
begin
    race := GetNPCRace(npc);
    result := masterRaceList.IndexOf(EditorID(race));
    if result < 0 then result := childRaceList.IndexOf(EditorID(race));
end;

//=========================================================
// Determine if the NPC is a child.
Function NPCisChild(npc: IwbMainRecord): boolean;
begin
    result := EndsText('ChildRace', EditorID(GetNPCRace(npc)));
end;

//=========================================================
// Determine if the NPC is female.
Function NPCisFemale(npc: IwbMainRecord): boolean;
begin
    result := (GetElementNativeValues(npc, 'ACBS\Flags\female') <> 0);
end;

//===============================================================================
// Determine whether this is a generic NPC.
Function NPCisGeneric(npc: IwbMainRecord): boolean;
begin
    if ContainsText(EditorID(npc), 'Deacon') then result := false
    else if ContainsText(EditorID(npc), 'Kellogg') then result := false
    else if genericNames.IndexOf(GetElementEditValues(npc, 'FULL')) >= 0 then result := true
    ;
end;

//===========================================================
// Return the form an NPC inherits its traits from.
Function NPCTraitsTemplate(npc: IwbMainRecord): IwbMainRecord;
begin
    result := nil;
    if GetElementEditValues(npc, 'ACBS - Configuration\Use Template Actors\Traits') = '1' then begin
        result := LinksTo(ElementByPath(npc, 'TPTA\Traits'));
        if not Assigned(result) then
            result := LinksTo(ElementByPath(npc, 'TPLT'));
    end;
end;

//=========================================================================
// Determine whether the NPC gets traits from a template that is based
// on a leveled list.
Function BasedOnLeveledList(npc: IwbMainRecord): boolean;
var
    tpl: IwbMainRecord;
begin
    If LOGGING then Log(5, Format('<BasedOnLeveledList(%s)', [Name(npc)]));
    tpl := NPCTraitsTemplate(npc);
    if Assigned(tpl) then begin
        if signature(tpl) = 'LVLN' then
            result := true
        else
            result := BasedOnLeveledList(tpl);
    end
    else
        result := false;
    If LOGGING then Log(5, '>BasedOnLeveledList -> ' + IfThen(result, 'T', 'F'));
end;

//===========================================================
// Determine whether the NPC inherits traits.
Function NPCInheritsTraits(npc: IwbMainRecord): boolean;
begin
    result := (
        Assigned(NPCTraitsTemplate(npc))
    );
end;

//============================================================
// Get the NPC's sex (which includes child value).
Function GetNPCSex(npc: IwbMainRecord): integer;
var
    fem, child: bolean;
begin
    fem := NPCisFemale(npc);
    child := NPCisChild(npc);
    if fem then 
        if child then
            Result := FEMALECHILD
        else
            Result := FEMALE
    else 
        if child then
            Result := MALECHILD
        else
            Result := MALE;
end;

//============================================================
// Get the NPC's sex (male/female).
Function GetNPCEffectiveSex(npc: IwbMainRecord): integer;
begin
    case GetNPCSex(npc) of
        MALE: result := MALE;
        MALECHILD: result := MALE;
        FEMALE: result := FEMALE;
        FEMALECHILD: result := FEMALE;
    end;
end;

Function SexToStr(sex: integer): string;
begin
    if sex = MALE then result := 'MALE'
    else if sex = FEMALE then result := 'FEMALE'
    else if sex = MALECHILD then result := 'MALECHILD'
    else if sex = FEMALECHILD then result := 'FEMALECHILD'
    else result := 'INVALID SEX [' + IntToStr(sex) + ']';
end;

Function HpToStr(hp: integer): string;
begin
    if (hp >= 0) and (hp < headpartsList.Count) then
        Result := headpartsList[hp]
    else 
        Result := 'INVALID HP ' + IntToStr(hp);
end;


//-----------------------------------------------
Function GetNPCClassName(classID: integer): string;
begin
    case classID of
        CLASS_SETTLER: Result := 'CLASS_SETTLER';
		CLASS_ATOM: Result := 'CLASS_ATOM';
		CLASS_BOBROV: Result := 'CLASS_BOBROV';
		CLASS_BOS: Result := 'CLASS_BOS';
		CLASS_CABOT: Result := 'CLASS_CABOT';
		CLASS_CAIT: Result := 'CLASS_CAIT';
		CLASS_DALTON: Result := 'CLASS_DALTON';
		CLASS_DANSE: Result := 'CLASS_DANSE';
		CLASS_DEACON: Result := 'CLASS_DEACON';
		CLASS_DELUCA: Result := 'CLASS_DELUCA';
		CLASS_DISCIPLES: Result := 'CLASS_DISCIPLES';
		CLASS_FARHARBOR: Result := 'CLASS_FARHARBOR';
		CLASS_GAGE: Result := 'CLASS_GAGE';
		CLASS_GARVEY: Result := 'CLASS_GARVEY';
		CLASS_GHOUL: Result := 'CLASS_GHOUL';
		CLASS_GUNNER: Result := 'CLASS_GUNNER';
		CLASS_INSTITUTE: Result := 'CLASS_INSTITUTE';
		CLASS_KELLOGG: Result := 'CLASS_KELLOGG';
		CLASS_KYLE: Result := 'CLASS_KYLE';
		CLASS_LONGFELLOW: Result := 'CLASS_LONGFELLOW';
		CLASS_MACCREADY: Result := 'CLASS_MACCREADY';
		CLASS_MINUTEMEN: Result := 'CLASS_MINUTEMEN';
		CLASS_OPERATOR: Result := 'CLASS_OPERATOR';
		CLASS_PACK: Result := 'CLASS_PACK';
		CLASS_PEMBROKE: Result := 'CLASS_PEMBROKE';
		CLASS_PIPER: Result := 'CLASS_PIPER';
		CLASS_RAIDER: Result := 'CLASS_RAIDER';
		CLASS_RR: Result := 'CLASS_RR';
		CLASS_PLAYER: Result := 'CLASS_PLAYER';
		CLASS_TRAPPER: Result := 'CLASS_TRAPPER';
		CLASS_X688: Result := 'CLASS_X688';
    else Result := Format('Unknown Class [%d]', [classID]);
    end;
end;

//================================================================
// Load an NPC's parents.
procedure LoadParents();
var
  allRlnshp: IwbGroupRecord;
  f: IwbFile;
  i: integer;
  j: Integer;
  theChild: IwbMainRecord;
  theParent: IwbMainRecord;
  thisRlnshp: IwbMainRecord;
begin
    // motherCount := 0;

    for j := 0 to FileCount - 1 do begin
        f := FileByIndex(j);

        allRlnshp := GroupBySignature(f, 'RELA');

        if allRlnshp <> nil then begin
            for i := 0 to ElementCount(allRlnshp)-1 do begin
                thisRlnshp := ElementByIndex(allRlnshp, i);
                if SameText(GetElementEditValues(thisRlnshp, 'DATA\Association Type'), 'ParentChild [ASTP:0001996B]') then begin
                    theParent := LinksTo(ElementByPath(thisRlnshp, 'DATA\Parent'));
                    theChild := LinksTo(ElementByPath(thisRlnshp, 'DATA\Child'));
                    case GetNPCSex(theParent) of 
                        FEMALE: mothers.AddObject(EditorID(theChild), TObject(theParent));
                        MALE: fathers.AddObject(EditorID(theChild), TObject(theParent));
                    end;
                    // else if 
                    //     mothers[motherCount] := theParent; //GetLoadOrderFormID(theParent);
                    //     children[motherCount] := LinksTo(ElementByPath(thisRlnshp, 'DATA\Child'));
                    //     if 6 <= LOG_LEVEL then If LOGGING then Log(6, ' . . Found mother ' + Name(mothers[motherCount]) + ', child ' + Name(children[motherCount]));
                    //     motherCount := motherCount + 1;
                    // end;
                end;
            end;
        end;
    end;
end;

//-----------------------------------------------
// Get a NPC's mother, if any. Return the father if no mother. Return Nil if no parent.
// If the parent is a ghoul act like there's no parent.
Function GetMother(theNPC: IwbMainRecord): IwbMainRecord;
var
  i: Integer;
  //loid: integer;
begin
    If LOGGING then LogEntry1(5, 'GetMother', Name(theNPC));
    result := Nil;

    i := mothers.IndexOf(EditorID(theNPC));
    if i >= 0 then 
        result := ObjectToElement(mothers.objects[i])
    else begin
        i := fathers.IndexOf(EditorID(theNPC));
        if i >= 0 then
            result := ObjectToElement(fathers.objects[i]);
    end;

    if EditorID(GetNPCRace(result)) = 'GhoulRace' then result := nil;

    If LOGGING then LogExit1(5, 'GetMother', Name(result));
end;

// <<<<<<<<<<<<<<<<<<<<< MANAGE TINT LAYERS >>>>>>>>>>>>>>>>>>>>>

// procedure LoadTintLayer(r: integer; sex: integer; tli: integer; 
//     mt: string; thisLayer: IwbElement);
// begin
//     inc(logIndent);
//     If LOGGING then Log(5, 'Loading tint layer ' + mt + ' race=' + IntToStr(r) +
//         ' sex=' + IntToStr(sex) + ' tint=' + IntToStr(tli));
//     raceInfo[r, sex].tints[tli].tini :=
//         GetElementNativeValues(thisLayer, 'Tint Layer\Texture\TINI');
//     raceInfo[r, sex].tints[tli].maskType := mt;
//     raceInfo[r, sex].tints[tli].element := thisLayer;
//     If LOGGING then Log(5, 'Found tint mask ' + mt + ' TINI='
//         + IntToStr(raceInfo[r, sex].tints[tli].tini));
        
//     If LOGGING then Log(5, 'Found ' + IntToStr(raceInfo[r, sex].tints[tli].presetsCount) +
//         ' presets starting at ' + IntToStr(raceInfo[r, sex].tints[tli].presetsStart));
//     dec(logIndent);
// end;

//===============================================================================
// Given the name used for a tint, return the tint layer it implements.
Function DetermineTintType(name: string): integer;
var
    n: integer;
begin
    If LOGGING then Log(11, '<DetermineTintType: ' + name);
    n := knownTTGP.IndexOf(name);
    if n < 0 then
        result := -1
    else result := translateTTGP[n];
    If LOGGING then Log(11, '>DetermineTintType -> ' + IntToStr(result));
end;

//===============================================================================
// Return a human-readable string for a tint layer.
Function TintLayerToStr(tintLayer: integer): string;
var
    i: integer;
begin
    if (tintLayer >= 0) and (tintLayer < tintLayerName.Count) then
        result := tintlayerName[tintLayer]
    else begin
        // Shouldn't ever happen.
        AddMessage('ERROR: Have unknown tint layer ' + IntToStr(tintlayer));
        AddMessage(Format('There are %d known tint layers:', [tintlayerName.Count]));
        for i := 0 to tintlayerName.Count-1 do begin
            AddMessage(Format('[%d] %s', [i, tintlayerName[i]]));
        end;
        result := Format('[%d UNKNOWN TL]', [tintLayer]);
    end;
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
    If LOGGING then LogEntry2(11, 'LoadTintLayerInfo', EditorID(theRace), SexToStr(sex));
    raceID := RaceIndex(theRace);
    if (sex = MALE) or (sex = MALECHILD) then 
        rootElem := 'Male Tint Layers' 
    else 
        rootElem := 'Female Tint Layers';
    tintGroups := ElementByPath(theRace, rootElem);

    If LOGGING then LogT(EditorID(theRace) + ' ' + rootElem + ' tint group count ' + IntToStr(ElementCount(tintGroups)));
    
    for i := 0 to ElementCount(tintGroups)-1 do begin
        thisGroup := ElementByIndex(tintGroups, i);
        If LOGGING then Log(11, 'Found tint group ' + GetElementEditValues(thisGroup, 'TTGP'));

        tintOptions := ElementByPath(thisGroup, 'Options');
        If LOGGING then LogT(Format('Group has %d options', [integer(ElementCount(tintOptions))]));
        for j := 0 to ElementCount(tintOptions)-1 do begin
            tintLayer := ElementByIndex(tintOptions, j);
            tintName := GetElementEditValues(tintLayer, 'TTGP');
            tintType := DetermineTintType(tintName);

            if tintType >= 0 then begin
                If LOGGING then LogT(Format('Finding tint count for [%d, %s], tintType %d', [
                    raceID, SexToStr(sex), tintType
                ]));
                n := raceInfo[raceID, sex].tintCount[tintType];

                // If LOGGING then Log(6, Format('[%d] Found tint option "%s" -> %d', 
                //     [integer(j), tintname, integer(tintType)]));
                If LOGGING then LogT(Format('Found tint option [%d] "%s" -> [%d] %s', [integer(j), tintname, integer(n), tintlayerName[tintType]]));

                if tintType < TINTLAYERS_COUNT then begin
                    if n < TEXTURES_MAX then begin
                        raceInfo[raceID, sex].tints[tintType, n].name := tintName;
                        raceInfo[raceID, sex].tints[tintType, n].maskType := tintType;
                        raceInfo[raceID, sex].tints[tintType, n].element := tintLayer;
                        raceInfo[raceID, sex].tintCount[tintType] := n+1;
                    end;
                end;
            end
            else begin
                Warn(Format('Unknown tint type for %s %s: %s', [
                    Name(theRace), SexToStr(sex), tintName]));
            end;
        end;
    end;

    If LOGGING then LogExitT('LoadTintLayerInfo');
end;

//===============================================================
// Collect tint layer information.
//
// FO4 doesn't have standardized tint layers, except skin tone. We define layers we care
// about and have magic ways to match them up.
procedure CollectTintLayers(theRace: IwbMainRecord);
var
    i: integer;
begin
    If LOGGING then Log(12, '<CollectTintLayers');

    for i := SEX_LO to SEX_HI do begin
        LoadTintLayerInfo(theRace, i);
    end;

    If LOGGING then Log(12, '> ');
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
	If LOGGING then Log(5, '<FindRaceTintLayerByTINI: ' + IntToStr(targetTINI) + ' in ' + EditorID(raceInfo[r, sex].mainRecord) + IntToStr(sex));

    // Walk the race's tint layers until we find the one requested
    found := -1;
    for i := 0 to TINTLAYERS_COUNT-1 do begin
        If LOGGING then Log(6, 'Checking tint ' + IntToStr(raceInfo[r, sex].tints[i].TINI));

        if raceInfo[r, sex].tints[i].TINI = targetTINI then
            found := i;
        if found >= 0 then break;
    end;

    Result := found;

    If LOGGING then Log(5, '>FindRaceTintLayerByTINI ' + IntToStr(found));
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
	If LOGGING then Log(5, '<ChoosePresetByColor: ' +colorName);

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

    If LOGGING then Log(5, '>ChoosePresetByColor: ' + PathName(Result));
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
	If LOGGING then Log(5, 'ChooseNamedColor:  ' +colorName);
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
    If LOGGING then LogEntry1(9, 'FindTintLayerByFilename', filename);
    Result := -1;

    for i := 0 to TINTLAYERS_COUNT-1 do begin
        if Assigned(raceInfo[raceIndex, sex].tints[i].element) then begin
            n := GetElementEditValues(raceInfo[raceIndex, sex].tints[i].element, 'Tint Layer\Texture\TINT');
            If LOGGING then LogD('Checking ' + PathName(raceInfo[raceIndex, sex].tints[i].element));
            If LOGGING then LogD('Checking ' + n);
            if ContainsText(n, filename) then begin
                Result := i;
                break;
            end;
        end;
    end;
    If LOGGING then LogExitT1('FindTintLayerByFilename', IntToStr(Result));
end;

function GetTINIByTintIndex(raceIndex, sex, theTintIndex: integer): integer;
begin   
    Result := raceInfo[raceIndex, sex].tints[theTintIndex].TINI;
end;

//============================================================
// Pick a random tint option of the given tintLayer type for this race.
// Return the tint option element.
Function PickRandomTintOption(hashstr: string; seed, theRace, sex, tintLayer: integer): IwbElement;
var
    alt: integer;
    r: integer;
    colorList: IwbContainer;
Begin
    If LOGGING then Log(10, Format('<PickRandomTintOption %s %s %s', [hashstr, SexToStr(sex), tintlayerName[tintlayer]]));
    alt := Hash(hashstr, seed, raceInfo[theRace, sex].tintCount[tintLayer]);
    result := raceInfo[theRace, sex].tints[tintLayer, alt].element;
    If LOGGING then Log(10, Format('>PickRandomTintOption -> %s \ %s', [EditorID(ContainingMainRecord(result)), Path(result)]));
end;


//============================================================
// Pick a random color preset from a tint option.
// Return the template color element.
// If ind=1, skips any colors with an alpha of 0. 
// Chooses from the acceptable colors for this layer.
Function PickRandomColorPreset(hashstr: string; seed: integer; tintOption: IwbElement;  
    ind: integer; colors: string): IwbElement;
var
    alpha: float;
    cform: IwbMainRecord;
    colorList: IwbContainer;
    goodPresetCount: integer;
    goodPresets: array [0..20] of IwbElement;
    i: integer;
    thisPreset: IwbElement;
Begin
    If LOGGING then Log(10, Format('<PickRandomColorPreset [%s] %d "%s"', [Path(tintOption), integer(ind), colors]));
    Result := nil;
    colorList := ElementByPath(tintOption, 'TTEC');
    goodPresetCount := 0;
    for i := 0 to ElementCount(colorList)-1 do begin
        thisPreset := ElementByIndex(colorList, i);
        alpha := GetElementNativeValues(thisPreset, 'Alpha');
        cform := LinksTo(ElementByPath(thisPreset, 'Color'));
        If LOGGING then Log(10, Format('Checking preset with color: %s -> %s', [Path(thisPreset), EditorID(cform)]));
        if ((alpha > 0.0001) or (ind = 0)) and 
            ((colors = '') or ContainsText(colors, '|' + EditorID(cform) + '|')) 
        then begin
            If LOGGING then Log(10, Format('Found good preset with color: %s', [EditorID(cform)]));
            goodPresets[goodPresetCount] := thisPreset;
            inc(goodPresetCount);
            if goodPresetCount >= length(goodPresets) then break;
        end;
    end;

    if goodPresetCount > 0 then 
        result := goodPresets[Hash(hashstr+colors, seed, goodPresetCount)];

    If LOGGING then Log(10, Format('>PickRandomColorPreset -> %s \ %s', [EditorID(ContainingMainRecord(result)), Path(result)]));
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
    // If LOGGING then Log(5, 'HeadpartFacialType of ' + Name(hp) + ' = ' + IntToStr(i));
    Result := i;
end;

function HeadpartSexIs(hp: IwbMainRecord; sex: integer): boolean;
// Determine whether the head part hp works for the given sex
begin
    // If LOGGING then Log(5, 'HeadpartSexIs M:' + GetMRAssetStr(hp, 'DATA - Flags\Male')
    //     + 'F:' + GetMRAssetStr(hp, 'DATA - Flags\Female'));
    Result := (((sex = MALE) or (sex = MALECHILD)) and (GetElementEditValues(hp, 'DATA - Flags\Female') = '0'))
        or
        (((sex = FEMALE) or (sex = FEMALECHILD)) and (GetElementEditValues(hp, 'DATA - Flags\Male') = '0'));
end;

//------------------------------------------------------------
// Record hair so that we can match furry hair to vanilla hair.
procedure RecordVanillaHair(hair: IwbMainRecord);
var
    i, j: integer;
    race: IwbMainRecord;
    raceID: integer;
    raceList: IwbElement;
    validRaces: IwbMainRecord;
begin
    If LOGGING then LogEntry1(11, 'RecordVanillaHair', EditorID(hair));
    if vanillaHairRecords.IndexOf(EditorID(hair)) < 0 then begin
        if not StartsText('FFO', EditorID(hair)) then 
            // This is non-furry, probably vanilla hair. Create an entry so we can 
            // add furry hair to it.
            vanillaHairRecords.Add(EditorID(hair));
    end;
    If LOGGING then LogExitT('RecordVanillaHair');
end;

//------------------------------------------------------------
// Record furry hair so that we can match furry hair to vanilla hair.
procedure RecordFurryHair(hair: IwbMainRecord);
var
    i, j: integer;
    race: IwbMainRecord;
    raceID: integer;
    raceList: IwbElement;
    validRaces: IwbMainRecord;
begin
    If LOGGING then Log(11, '<RecordFurryHair: ' + EditorID(hair));
    // If this is a lion mane, there's no vanilla hair, but save it for later.
    if EditorID(hair) = 'FFO_HairMaleMane' then
        lionMane := hair // TODO take this out we have a new way to do it
    else begin
        // Find and stash the associated vanilla hair, if any.
        for i := 0 to vanillaHairRecords.Count-1 do begin
            if ContainsStr(EditorID(hair), vanillaHairRecords[i]) then begin
                validRaces := LinksTo(ElementByPath(hair, 'RNAM'));
                raceList := ElementByPath(ValidRaces, 'FormIDs');
                for j := 0 to ElementCount(raceList)-1 do begin
                    race := LinksTo(ElementByIndex(raceList, j));
                    raceID := RaceIndex(race);
                    if raceID >= 0 then begin
                        If LOGGING then Log(11, Format('Furry hair %s race %s == vanilla %s', [EditorID(hair), EditorID(race), vanillaHairRecords[i]]));
                        if i >= HAIR_MAX then Err('Too many hair records: ' + IntToStr(i));
                        furryHair[i, raceID] := hair;
                    end;
                end;
            end;
        end;
    end;
    If LOGGING then Log(11, '>');
end;

//===================================================================
// Given a vanilla hair record and raceID, return corresponding furry hair. If there's no
// furry hair, choose a random furry hair that is not on the exclude list.
Function GetFurryHair(hashstr: string; seed: integer; 
    raceID: integer; targetSex: integer; oldHair: string): IwbMainRecord;
var
    i, j: integer;
    n: integer;
    skipCount: integer;
begin
    If LOGGING then LogEntry3(5, 'GetFurryHair', IntToStr(raceID), SexToStr(targetSex), oldHair);
    result := Nil;
    n := vanillaHairRecords.IndexOf(oldHair);
    if n >= 0 then begin
        If LOGGING then LogT('Have vanilla hair record');
        if n < HAIR_MAX then
            result := furryHair[n, raceid]
        else
            Err(Format('To much hair to handle--vanillaHairRecords index bigger than furry hair: %d >= %d', [n, HAIR_MAX]));
    end;

    if not Assigned(result) then begin
        If LOGGING then LogT('No matching hair--chose random hair');
        skipCount := Hash(hashstr, seed, 20);
        i := Hash(hashstr, seed, HAIR_MAX);
        for j := 0 to 10000 do begin // no infinite loops
            if Assigned(furryHair[i, raceID]) then begin
                if (hairExcludeList.IndexOf(EditorID(furryHair[i, raceID])) <= 0)
                    and HeadpartSexIs(furryHair[i,raceID], targetSex) 
                then begin
                    if skipCount = 0 then begin
                        result := furryHair[i, raceID];
                        break;
                    end;
                    dec(skipCount);
                end;
            end;
            inc(i);
            if i >= HAIR_MAX then i := 0;
        end;
    end;
    If LOGGING then LogExitT1('GetFurryHair', EditorID(result));
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
    If LOGGING then LogEntry1(15, 'LoadHeadPart', Name(hp));

    // if targetHeadparts.IndexOf(EditorID(hp)) >= 0 then 
    //     specialHeadparts.AddObject(EditorID(hp), hp);

    // Get the form list that has the races for this head part
    validRaceList := WinningOverride(LinksTo(ElementByPath(hp, 'RNAM - Valid Races')));
    If LOGGING then LogT('Found reference to form list ' + EditorID(validRaceList));

    facialType := HeadpartFacialType(hp);

    if facialType < 0 then 
        begin If LOGGING then LogT('Unknown facial type: ' + GetElementEditValues(hp, 'PNAM')); end
    else begin
        If LOGGING then LogT('Headpart is for [' + IfThen(HeadpartSexIs(hp, MALE), 'M', '') + IfThen(HeadpartSexIs(hp, FEMALE), 'F', '') + ']');
        
        if facialType = HEADPART_HAIR then RecordVanillaHair(hp);
        
        formList := ElementByPath(validRaceList, 'FormIDs');
        for i := 0 to ElementCount(formList)-1 do begin
            raceRef := ElementByIndex(formList, i);
            
            if not Assigned(raceRef) then break;

            raceRec := LinksTo(raceRef);
            raceName := EditorID(raceRec);
            If LOGGING then LogT('Found reference to race ' + FormName(raceRec));
            raceIndex := masterRaceList.IndexOf(racename);
            if raceIndex >= 0 then begin
                for sex := SEX_LO to SEX_HI do begin
                    if HeadpartSexIs(hp, sex) then 
                    begin
                        if not Assigned(raceInfo[raceIndex, sex].headparts[facialType]) then 
                            raceInfo[raceIndex, sex].headParts[facialType] := TStringList.Create;
                        raceInfo[raceIndex, sex].headParts[facialType]
                            .AddObject(EditorId(hp), hp);

                        if facialType = HEADPART_HAIR then RecordFurryHair(hp);

                        If LOGGING then LogT('Race ' + racename + ' has HP ' + EditorID(hp));
                    end;
                end;
            end;
        end;
    end;

    If LOGGING then LogExitT('LoadHeadPart');
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
    If LOGGING then Log(2, '<CollectRaceHeadparts');
    
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
    If LOGGING then Log(2, '>');
end;

// <<<<<<<<<<<<<<<<<<<<<< MANAGE RACES >>>>>>>>>>>>>>>>>>>>>>

// -----------------------------------------
// Add the given race editorID to the master list of races.
function AddRace(racename: string): integer;
var
    n: integer;
    i: integer;
    r: IwbMainRecord;
begin
    If LOGGING then LogEntry1(16, 'AddRace', racename);

    n := masterRaceList.IndexOf(racename);
    if n >= 0 then begin
        If LOGGING then LogT('Race defined already');
        Result := n
    end
    else begin
        // addmessage(Format('looking for race: %s', [LogToStr]));
        r := FindAsset(Nil, 'RACE', racename);
        // addmessage(Format('done looking: %s', [LogToStr]));
        if not Assigned(r) then begin
            If LOGGING then LogT('Race not in load order');
            racesNotFound.Add(racename);
            Result := -1;
        end
        else begin
            If LOGGING then LogT('Found race');
            if masterRaceList.Count >= RACES_MAX then begin
                Err('Too many races, stopped at ' + racename);
                Result := -1;
            end
            else begin
                // addmessage('adding race');
                If LOGGING then LogT('Adding race ' + racename);
                Result := masterRaceList.Count;
                masterRaceList.AddObject(racename, TObject(r));
                raceInfo[Result, MALE].mainRecord := r;
                raceInfo[Result, FEMALE].mainRecord := r;
                raceInfo[Result, MALE].morphGroups := TStringList.Create;
                raceInfo[Result, FEMALE].morphGroups := TStringList.Create;
                raceInfo[Result, MALE].morphProbability := TStringList.Create;
                raceInfo[Result, FEMALE].morphProbability := TStringList.Create;
                raceInfo[Result, MALE].morphLo := TStringList.Create;
                raceInfo[Result, FEMALE].morphLo := TStringList.Create;
                raceInfo[Result, MALE].morphHi := TStringList.Create;
                raceInfo[Result, FEMALE].morphHi := TStringList.Create;
                raceInfo[Result, MALE].morphSkew := TStringList.Create;
                raceInfo[Result, FEMALE].morphSkew := TStringList.Create;
                raceInfo[Result, MALE].morphExcludes := TStringList.Create;
                raceInfo[Result, FEMALE].morphExcludes := TStringList.Create;
                raceInfo[Result, MALE].faceBoneList := TStringList.Create;
                raceInfo[Result, FEMALE].faceBoneList := TStringList.Create;
                for i := HEADPART_LO to HEADPART_HI do begin
                    raceInfo[Result, FEMALE].headpartProb[i] := 100;
                    raceInfo[Result, MALE].headpartProb[i] := 100;
                end;
            end;
        end;
    end;
    RACE_HI := masterRaceList.Count-1;

    // addmessage(Format('exiting addrace, cur If LOGGING then Log level is %d', [curLogLevel[logIndent]]));
    If LOGGING then LogExitT1('AddRace', IntToStr(result));
end;


procedure InitializeTintLayers;
begin
    tintlayerName.Add('Cheek Color Lower');
    tintlayerName.Add('Cheek Color');
    tintlayerName.Add('Chin');
    tintlayerName.Add('Ear');
    tintlayerName.Add('Eyebrow');
    tintlayerName.Add('Eyeliner');
    tintlayerName.Add('Eyesocket Lower');
    tintlayerName.Add('Eyesocket Upper');
    tintlayerName.Add('Forehead');
    tintlayerName.Add('Lip Color');
    tintlayerName.Add('Mask');
    tintlayerName.Add('Muzzle');
    tintlayerName.Add('Neck');
    tintlayerName.Add('Nose');
    tintlayerName.Add('Old');
    tintlayerName.Add('Paint');
    tintlayerName.Add('Scar');
    tintlayerName.Add('Skin Tone');
    TINTLAYERS_COUNT := tintlayerName.Count;

    TL_CHEEK_COLOR := tintlayerName.IndexOf('Cheek Color');
    TL_CHEEK_COLOR_LOWER := tintlayerName.IndexOf('Cheek Color Lower');
    TL_CHIN := tintlayerName.IndexOf('Chin');
    TL_EAR := tintlayerName.IndexOf('Ear');
    TL_EYEBROW := tintlayerName.IndexOf('Eyebrow');
    TL_EYELINER := tintlayerName.IndexOf('Eyeliner');
    TL_EYESOCKET_LOWER := tintlayerName.IndexOf('Eyesocket Lower');
    TL_EYESOCKET_UPPER := tintlayerName.IndexOf('Eyesocket Upper');
    TL_FOREHEAD := tintlayerName.IndexOf('Forehead');
    TL_LIP_COLOR := tintlayerName.IndexOf('Lip Color');
    TL_MASK := tintlayerName.IndexOf('Mask');
    TL_MUZZLE := tintlayerName.IndexOf('Muzzle');
    TL_MUZZLE_STRIPE := tintlayerName.IndexOf('Muzzle');
    TL_NECK := tintlayerName.IndexOf('Neck');
    TL_NOSE := tintlayerName.IndexOf('Nose');
    TL_OLD := tintlayerName.IndexOf('Old');
    TL_PAINT := tintlayerName.IndexOf('Paint');
    TL_SCAR := tintlayerName.IndexOf('Scar');
    TL_SKIN_TONE := tintlayerName.IndexOf('Skin Tone');

    if TINTLAYERS_COUNT > TINTLAYERS_MAX then
        // Should never happen
        Err(Format('Too many tint layers: %d > %d', [
            integer(TINTLAYERS_COUNT), integer(TINTLAYERS_MAX)]));
end;

//=============================================================================
// Collect all morph groups from all races.
// Do not collect morphs for children.
procedure CollectRaceMorphs;
var 
    groupElementName: string;
    groupName: string;
    i, j, k: integer;
    morphGroup: IwbElement;
    morphGroupList: IwbElement;
begin
    for i := RACE_LO to RACE_HI do begin
        for j := MALE to FEMALE do begin
            if Assigned(raceInfo[i, j].mainRecord) then begin
                groupElementName := IfThen((j = FEMALE) or (j = FEMALECHILD), 
                    'Female Morph Groups', 'Male Morph Groups');
                morphGroupList := ElementByPath(raceInfo[i, j].mainRecord, groupElementName);
                // Create StringList to hold all morph groups.
                raceInfo[i, j].morphGroups := TStringList.Create;
                for k := 0 to ElementCount(morphGroupList)-1 do begin
                    morphGroup := ElementByIndex(morphGroupList, k);
                    groupName := GetElementEditValues(morphGroup, 'MPGN');
                    raceInfo[i, j].morphGroups.AddObject(groupName, TObject(morphGroup));
                end;
            end;
        end;
    end;
end;

//=============================================================================
// Exclude a morph group from furrfication.
procedure ExcludeMorph(racename: string; sex: integer; morphGroup: string);
var
    r: integer;
begin
    r := RacenameIndex(racename);
    if r >= 0 then 
        raceInfo[r, sex].morphExcludes.Add(morphGroup);
end;

//=============================================================================
// Define the probability at which one of a morph group will be selected.
procedure SetMorphProbability(racename: string; sex: integer; 
    morphGroup: string; probability, loMorph, hiMorph, skew: integer); 
var
    r: integer;
begin
    If LOGGING then LogEntry3(10, 'SetMorphProbability', racename, SexToStr(sex), morphGroup);
    r := RacenameIndex(racename);
    if r >= 0 then begin
        raceInfo[r, sex].morphProbability.AddObject(morphGroup, probability);
        raceInfo[r, sex].morphLo.AddObject(morphGroup, loMorph);
        raceInfo[r, sex].morphHi.AddObject(morphGroup, hiMorph);
        raceInfo[r, sex].morphSkew.AddObject(morphGroup, skew);
    end;
    If LOGGING then LogExitT('SetMorphProbability');
end;

//=======================================================================
// Find and return the preset with the given name in the given group.
Function GetMorphPreset(morphGroup: IwbElement; name: string): IwbElement;
var
    i: integer;
    n: string;
    p: IwbElement;
    presetList: IwbElement;
begin
    If LOGGING then Log(5, Format('<GetMorphPreset([%s], %s)', [Path(morphGroup), name]));
    p := Nil;
    presetList := ElementByPath(morphGroup, 'Morph Presets');
    If LOGGING then Log(5, Format('Found %d presets', [integer(ElementCount(presetList))]));
    for i := 0 to ElementCount(presetList)-1 do begin
        p := ElementByIndex(presetList, i);
        n := GetElementEditValues(p, 'MPPN');
        If LOGGING then Log(5, Format('Checking [%s] %s', [Path(p), n]));
        if n = name then break;
    end;
    result := p;
    If LOGGING then Log(5, Format('>GetMorphPreset -> %s', [Path(result)]));
end;

//=======================================================================
// Find and return a random preset from the given group.
// Do not choose a preset with a name containing 'Default'.
Function GetMorphRandomPreset(morphGroup: IwbElement; 
    hashval: string; seed: integer): IwbElement;
var
    foundAny: boolean;
    i, j: integer;
    p: IwbElement;
    pname: string;
    presetList: IwbElement;
    skipCount: integer;
begin
    If LOGGING then LogEntry1(5, 'GetMorphRandomPreset', Path(morphGroup));
    result := NIl;
    presetList := ElementByPath(morphGroup, 'Morph Presets');

    // Run through the list skipping a random number of good matches.
    skipCount := Hash(hashval, seed, ElementCount(presetList));
    foundAny := false;
    i := 0;

    for j := 0 to 10000 do begin // no infinite loops
        p := ElementByIndex(presetList, i);
        pname := GetElementEditValues(p, 'MPPN');
        if not ContainsText(pname, 'Default') then begin
            foundAny := true;
            Dec(skipCount);
            if skipCount <= 0 then begin
                result := p;
                break;
            end;
        end;
        Inc(i);
        if i >= ElementCount(presetList) then begin
            if not foundAny then 
                // Got through the whole list and nothing matched. Fail.
                break;
            i := 0;
        end;
    end;

    If LOGGING then LogExitT1('GetMorphRandomPreset', Path(result));
end;

//===============================================================================
// Define a morph bone we may use
procedure SetFaceMorph(racename: string; sex: integer; morph: string;
    xMin, yMin, zMin,  xRotMin, yRotMin, zRotMin,  scaleMin: float;
    xMax, yMax, zMax,  xRotMax, yRotMax, zRotMax,  scaleMax: float);
var
    found: boolean;
    i: integer;
    idx: integer;
    m: IwbElement;
    morphList: IwbElement;
    n: string;
    r: integer;
begin
    If LOGGING then LogEntry3(10, 'SetFaceMorph', racename, SexToStr(sex), morph);
    found := false;
    r := RacenameIndex(racename);
    if r >= 0 then begin
        if raceInfo[r, sex].faceBoneList.Count >= length(raceInfo[r, sex].faceBones) then
            Err(Format('Too many facebones for race %s: %d', [
                masterRaceList[r], raceInfo[r, sex].faceBoneList.Count]))
        else begin
            // Find the morph record
            morphList := ElementByPath(raceInfo[r, sex].mainRecord, 
                IfThen(sex = MALE, 'Male Face Morphs', 'Female Face Morphs'));
            for i := 0 to ElementCount(morphList)-1 do begin
                m := ElementByIndex(morphList, i);
                n := GetElementEditValues(m, 'FMRN');
                If LOGGING then LogT(Format('Checking %s = %s', [n, morph]));
                if n = morph then begin
                    idx := GetElementNativeValues(m, 'FMRI');
                    raceInfo[r, sex].faceBoneList.Add(morph);
                    i := raceInfo[r, sex].faceBoneList.IndexOf(morph);
                    raceInfo[r, sex].faceBones[i].FMRI := idx;
                    raceInfo[r, sex].faceBones[i].min.x := xMin;
                    raceInfo[r, sex].faceBones[i].min.y := yMin;
                    raceInfo[r, sex].faceBones[i].min.z := zMin;
                    raceInfo[r, sex].faceBones[i].min.scale := scaleMin;
                    raceInfo[r, sex].faceBones[i].max.x := xMax;
                    raceInfo[r, sex].faceBones[i].max.y := yMax;
                    raceInfo[r, sex].faceBones[i].max.z := zMax;
                    raceInfo[r, sex].faceBones[i].max.scale := scaleMax;
                    found := True;
                    break;
                end;
            end;
        end;
    end;
    if (not found) and (racesNotFound.IndexOf(racename) < 0) then 
        Err(Format('Could not find face morph %s on race %s %s', 
            [morph, racename, SexToStr(sex)]));
    If LOGGING then LogExitT('SetFaceMorph');
end;

//===================================================================
// Set a dummy face morph so that it can be set explicitly.
Procedure AddMorphBone(racename: string; sex: integer; morph: string); 
begin
    SetFaceMorph(racename, sex, morph, 
        0, 0, 0,  0, 0, 0, 0,
        0, 0, 0,  0, 0, 0, 0);
end;

//===================================================================
// Collect all race tint layers for all races.
procedure CollectRaceTintLayers;
var
    i, j: integer;
    race: IwbMainRecord;
begin
    If LOGGING then LogEntry(11, 'CollectRaceTintLayers');

    for i := RACE_LO to RACE_HI do begin
        If LOGGING then Log(11, 'Found race ' + EditorID(raceInfo[i, MALE].mainRecord));
        CollectTintLayers(raceInfo[i, MALE].mainRecord);
    end;
    
    If LOGGING then LogExit(11, 'CollectRaceTintLayers');
end;


// <<<<<<<<<<<<<<<<<Access functions to hide the implementation>>>>>>>>>>>>>>>>>

function GetRaceTintTINI(theRace, sex, tintLayer: integer): integer;
begin
    Result := raceInfo[theRace, sex].tints[tintLayer].TINI;
end;

function GetRaceTintMaskType(theRace, sex, tintLayer: integer): string;
begin
    If LOGGING then Log(6, 'GetRaceTintMaskType: tintLayer=' + IntToStr(tintLayer));
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
    If LOGGING then LogEntry3(10, 'GetRaceHeadpartCount', RaceIDtoStr(theRace), SexToStr(sex), IntToStr(hpType));
    if (hpType < 0) or (hpType >= headpartsList.Count) then begin
        Err('GetRaceHeadpartCount: headpart type index too large: ' + IntToStr(hpType));
        Result := 0;
    end
    else if not Assigned(raceInfo[theRace, sex].headparts[hpType]) then
        Result := 0
    else
        Result := raceInfo[theRace, sex].headparts[hpType].Count;
    If LOGGING then LogExit1(10, 'GetRaceHeadpartCount', IntTostr(Result));
end;

//===================================================================
// Return the record for the given headpart.
function GetRaceHeadpart(theRace, sex, hpType, hpIndex: integer): IwbMainRecord;
var 
    i: integer;
begin
    If LOGGING then LogEntry4(10, 'GetRaceHeadpart', IntToStr(theRace), IntToStr(sex), HpToStr(hpType), IntToStr(hpIndex));
    // If LOGGING then Log(10, Format('Number of headparts: %d', [headpartsList.Count]));
    // for i := 0 to headpartsList.Count-1 do
    //     If LOGGING then Log(10, Format('Have headpart [%d] %s', [i, headpartsList[i]]));
    // If LOGGING then Log(10, 'Headpart type initialized: ' + BoolToStr(Assigned(raceInfo[theRace, sex].headparts[hpType])));
    // If LOGGING then Log(10, Format('Count of headparts available: %d', [raceInfo[theRace, sex].headparts[hpType].Count]));
    Result := nil;
    if Assigned(raceInfo[theRace, sex].headparts[hpType]) then
        Result := ObjectToElement(
            raceInfo[theRace, sex].headparts[hpType].Objects[hpIndex]);
    If LOGGING then LogExit(10, 'GetRaceHeadpart')
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
    If LOGGING then LogEntry3(7, 'PickRandomHeadpart', RaceIDToStr(race), SexToStr(sex), HpToStr(hpType));
    n := GetRaceHeadpartCount(race, sex, hpType);
    h := Hash(hashstr, seed, n);
    Result := GetRaceHeadpart(race, sex, hpType, h);
    If LOGGING then LogExit(7, 'PickRandomHeadpart');
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

//===========================================================
// Determine if an NPC should be consdiered old. Only looks at hair color.
Function NPCisOld(npc: IwbMainRecord): Boolean;
var
    cform: IwbMainRecord;
begin
    cform := LinksTo(ElementByPath(npc, 'HCLF'));
    result := ContainsText(
        'HairColor04Silver|HairColor05Graying|HairColor07White|HairColor09Gray|HairColor10SteelGray',
        EditorID(cform));
end;

Procedure NPC_Print;
begin
    AddMessage('NPC ' + Name(curNPC.handle));
    AddMessage('   ' + curNPC.id);
    AddMessage('   ' + curNPC.sig);
    AddMessage('   ' + curNPC.name);
end;

Function NPC_ToStr: string;
begin
    Result := #13#10 
        + FullPath(curNPC.handle) + #13#10
        + '  Editor ID = '+ curNPC.id + #13#10
        + '  Signature = ' + curNPC.sig + #13#10
        + '  Name = ' + curNPC.name + #13#10
        + '  Class = ' + GetNPCClassName(curNPC.npcClass) + #13#10
        + '  Race = ' + RaceIDtoStr(curNPC.race) + #13#10
        + '  Furry Race = ' + RaceIDtoStr(curNPC.furry_race) + #13#10
        + '  Sex = ' + SexToStr(curNPC.sex) + #13#10
        + '  Plugin = ' + GetFileName(curNPC.plugin);
end;

//============================================================
// Setup the given NPC to be the current for furrification. 
Procedure NPC_Setup(npc: IwbMainRecord);
begin
    if LOGGING then LogEntry1(20, 'NPC_Setup', Name(npc));
    curNPC.handle := npc;
    curNPC.id := EditorID(npc);
    curNPC.sig := curNPC.id;
    curNPC.name := GetElementEditValues(npc, 'FULL');
    curNPC.plugin := GetFile(npc);
    curNPC.is_old := NPCisOld(npc);
    curNPC.sex := GetNPCSex(npc);
    if LOGGING then LogExitT('NPC_Setup');
end;

//============================================================
// Push the current NPC on a stack so as to work on another recursively. 
Procedure NPC_Push;
begin
    // savedNPC[savedNPCIndex] := curNPC;
    savedNPC[savedNPCIndex].handle := curNPC.handle;
    savedNPC[savedNPCIndex].id := curNPC.id;
    savedNPC[savedNPCIndex].sig := curNPC.sig;
    savedNPC[savedNPCIndex].name := curNPC.name;
    savedNPC[savedNPCIndex].sex := curNPC.sex;
    savedNPC[savedNPCIndex].race := curNPC.race;
    savedNPC[savedNPCIndex].furry_race := curNPC.furry_race;
    savedNPC[savedNPCIndex].npcclass := curNPC.npcclass;
    savedNPC[savedNPCIndex].old_hair := curNPC.old_hair;
    savedNPC[savedNPCIndex].plugin := curNPC.plugin;
    savedNPC[savedNPCIndex].is_old := curNPC.is_old;
    Inc(savedNPCIndex);
end;

Procedure NPC_Pop;
begin
    Dec(savedNPCIndex);
    // curNPC := savedNPC[savedNPCIndex];
    curNPC.handle := savedNPC[savedNPCIndex].handle;
    curNPC.id := savedNPC[savedNPCIndex].id;
    curNPC.sig := savedNPC[savedNPCIndex].sig;
    curNPC.name := savedNPC[savedNPCIndex].name;
    curNPC.sex := savedNPC[savedNPCIndex].sex;
    curNPC.race := savedNPC[savedNPCIndex].race;
    curNPC.furry_race := savedNPC[savedNPCIndex].furry_race;
    curNPC.npcclass := savedNPC[savedNPCIndex].npcclass;
    curNPC.old_hair := savedNPC[savedNPCIndex].old_hair;
    curNPC.plugin := savedNPC[savedNPCIndex].plugin;
    curNPC.is_old := savedNPC[savedNPCIndex].is_old;
end;

//============================================================
// Determine the class of an NPC 
//
// Look at various characteristics of the NPC to determine the best class. 
// Order of the checks matters.
Function GetNPCClass(npc: IwbMainRecord): integer;
var
    id: string;
    factionList: TStringList;
    name: string;
    rn: string;
begin
    If LOGGING then LogEntry1(10, 'GetNPCClass', Name(npc));

    factionList := TStringList.Create;
    GetNPCFactions(npc, factionList);
    name := GetElementEditValues(npc, 'FULL');
    id := EditorID(npc);

    Result := CLASS_SETTLER;

    // Ghouls
    rn := EditorID(GetNPCRace(npc));
    if (rn = 'GhoulRace') or (rn = 'GhoulChildRace') then
        Result := CLASS_GHOUL

    // Some settlers use Minutemen/Raider faces, so check them first
    else if name = 'Settler' then Result := CLASS_SETTLER
        
    // Followers
    else if SameText(id, 'CompanionCait') then Result := CLASS_CAIT
    else if SameText(id, 'BoSPaladinDanse') then Result := CLASS_DANSE
    else if ContainsText(id, 'CompanionDeacon') then Result := CLASS_DEACON
    else if SameText(id, 'CompanionMacCready') then Result := CLASS_MACCREADY
    else if SameText(id, 'CompanionPiper') then Result := CLASS_PIPER
    else if SameText(id, 'CompanionX6-88') then Result := CLASS_X688
    else if SameText(id, 'DLC04Gage') then Result := CLASS_GAGE
    else if ContainsText(id, 'PrestonGarvey') then Result := CLASS_GARVEY
    else if SameText(id, 'DLC03_CompanionOldLongfellow') then Result := CLASS_LONGFELLOW

    // Specific NPCs and NPC families where we want them all to have the same race.
    else if SameText(id, 'Natalie') then Result := CLASS_PIPER
    else if ContainsText(id, 'Kellogg') then Result := CLASS_KELLOGG
    else if SameText(id, 'MQ203MemoryA_Mom') then Result := CLASS_KELLOGG
    else if SameText(id, 'FFDiamondCity12Kyle') then Result := CLASS_KYLE
    else if SameText(id, 'FFDiamondCity12Riley') then Result := CLASS_KYLE
    else if ContainsText(id, 'DeLuca') then Result := CLASS_DELUCA
    else if ContainsText(id, 'Bobrov') then Result := CLASS_BOBROV
    else if ContainsText(id, 'Pembroke') then Result := CLASS_PEMBROKE
    else if ContainsText(name, 'Cabot') then Result := CLASS_CABOT
    else if ContainsText(id, 'Dalton') then Result := CLASS_DALTON
    else if ContainsText(id, 'Shaun') then Result := CLASS_PLAYER
    else if StartsText('MQ101PlayerSpouse', id) then Result := CLASS_PLAYER
    else if StartsText('MQ102PlayerSpouse', id) then Result := CLASS_PLAYER
    else if id = 'Player' then Result := CLASS_PLAYER

    // Groups of NPCs that can have different probabilities
    else if ContainsText(id, 'Gunner') then Result := CLASS_GUNNER
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
    else if ContainsText(id, 'Minutemen') then Result := CLASS_MINUTEMEN
    else if ContainsText(id, 'GangPack') then Result := CLASS_PACK
    else if ContainsText(id, 'GangDisciple') then Result := CLASS_DISCIPLES
    else if ContainsText(id, 'GangOperator') then Result := CLASS_OPERATOR
    else if ContainsText(id, 'Institute') then Result := CLASS_INSTITUTE
    else if ContainsText(id, 'FarHarbor') then Result := CLASS_FARHARBOR
    else if ContainsText(id, 'raider') then Result := CLASS_RAIDER
    ;

    If LOGGING then Log(15, Format('Is minuteman: %s', [IfThen(ContainsText(id, 'Minutemen'), 'T', 'F')]));
    If LOGGING then Log(15, Format('Is settler: %s', [IfThen(name = 'Settler', 'T', 'F')]));

    factionList.Free;
    If LOGGING then LogExitT1('GetNPCClass', GetNPCClassName(Result));
end;

Procedure NPC_GetClass;
begin
    curNPC.npcclass := GetNPCClass(curNPC.handle);
end;


//-------------------------------------------------------
// Force an NPC to a specfic race.
Procedure AssignNPCRace(npcEditorID: string; racename: string);
var
    npc: IwbMainRecord;
    race: IwbMainRecord;
begin
    If LOGGING then Log(11, '<AssignNPCRace ' + npcEditorID + ' <- ' + racename);
    npc := FindAsset(Nil, 'NPC_', npcEditorID);
    race := FindAsset(Nil, 'RACE', racename);
    If LOGGING then Log(11, 'Assigning ' + EditorID(npc) + ' race ' + EditorID(race));
    If LOGGING then Log(11, 'Race is in file ' + GetFileName(GetFile(race)));
    npcRaceAssignments.AddObject(npcEditorID, TObject(race));
    If LOGGING then Log(11, '>');
end;

//-------------------------------------------------------
// Set the probabilities for a single class/race pair
// Adds the race to the list of known furry races.
Procedure SetClassProb(npcclass: integer; race: string; points: integer);
var 
    r: integer;
begin
    If LOGGING then LogEntry1(15, 'SetClassProb', race);
    r := AddRace(race);
    if r >= 0 then classProbs[npcclass, r] := points;
    If LOGGING then LogExitT('SetClassProb');
end;


//---------------------------------------------------
// Set the probability of using a given type of headpart.
Procedure SetHeadpartProb(race: string; sex: integer; hp: integer; prob: integer);
var 
    r: integer;
begin
    If LOGGING then LogEntry4(15, 'SetHeadpartProb', race, SexToStr(sex), HpToStr(hp), IntToStr(prob));
    r := masterRaceList.IndexOf(race);
    // if r >= 0 then raceInfo[0, 0].headpartProb[0] := 10;
    if r >= 0 then raceInfo[r, sex].headpartProb[hp] := prob;
    If LOGGING then LogExitT('SetHeadpartProb');
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
    If LOGGING then Log(11, '<CalcClassTotals');
    for c := CLASS_LO to CLASS_HI do begin
        n := 0;
        for r := RACE_LO to RACE_HI do begin
            classProbsMin[c, r] := n;
            n := n + classProbs[c, r];
            classProbsMax[c, r] := n-1;
        end;
        classProbs[c, masterRaceList.Count] := n;
    end;
    if LOGLEVEL >= 15 then begin
        for c := CLASS_LO to CLASS_HI do begin
            If LOGGING then Log(11, GetNPCClassName(c) + ' totals: ' + IntToStr(classProbs[c, masterRaceList.Count]));
            for r := 0 to masterRaceList.Count-1 do begin
                If LOGGING then Log(11, GetNPCClassName(c) + ' ' + masterRaceList[r] + ' [' + IntToStr(classProbsMin[c, r]) + ', ' + IntToStr(classProbsMax[c, r]) + ']');
            end;
        end;
    end;
    If LOGGING then Log(11, '>');
end;

//===============================================================================
// Return the first furry substitute for the given class.
Function HaveClassTranslations(classID: integer): IwbMainRecord;
var
    i: integer;
begin
    result := Nil;
    for i := RACE_LO to RACE_HI do begin
        if classProbs[classID, i] > 0 then begin
            result := raceInfo[i, MALE].mainRecord;
            break;
        end;
    end
end;

//================================================================================
// Record that the given child race is the child version of the given adult race.
Procedure AddChildRace(adultRace, childRace: string);
var
    adultID: integer;
    childRecord: IwbMainRecord;
begin
    If LOGGING then LogEntry2(5, 'AddChildRace', adultRace, childRace);
    childRecord := FindAsset(Nil, 'RACE', childRace);
    adultID := masterRaceList.IndexOf(adultRace);
    if adultID >= 0 then begin
        raceInfo[adultID, MALECHILD].mainRecord := childRecord;
        raceInfo[adultID, FEMALECHILD].mainRecord := childRecord;
    end
    else 
        if racesNotFound.IndexOf(adultRace) < 0 then
            Err('AddChildRace could not find adult race ' + adultRace);
    If LOGGING then LogExit(5, 'AddChildRace');
end;

//================================================================================
// set up childRaceList to be 1:1 with masterRaceList
procedure CorrelateChildren;
var 
    i: integer;
begin
    for i := RACE_LO to RACE_HI do begin
        if Assigned(raceInfo[i, MALECHILD].mainRecord) then begin
            If LOGGING then Log(10, Format('Adding %s of %s', [EditorID(raceInfo[i, MALECHILD].mainRecord), masterRaceList[i]]));
            childRaceList.Add(EditorID(raceInfo[i, MALECHILD].mainRecord))
            end
        else begin
            // Store a bogus value to hold the place
            If LOGGING then Log(10, Format('Adding %s of %s', [masterRaceList[i] + '_NOCHILD', masterRaceList[i]]));
            childRaceList.Add(masterRaceList[i] + '_NOCHILD');
        end;
    end;
end;

//======================================================================
procedure ExcludeHair(hairName: string);
begin
    hairExcludeList.Add(hairName);
end;

//======================================================================
// Define translations between skin layer names in the race record and tint layers that
// the furrifier understands.
procedure SkinLayerTranslation(name: string; tintlayer: integer);
begin
    If LOGGING then LogEntry2(10, 'SkinLayerTranslation', name, IntToStr(tintlayer));
    if knownTTGP.IndexOf(name) < 0 then begin
        if knownTTGP.Count < length(translateTTGP) then begin
            translateTTGP[knownTTGP.Count] := tintlayer;
            knownTTGP.Add(name);
        end
        else
            // Should never happen
            Err(Format('Too many tint layers on %s, layer %d. Found %d, max is %d', 
                [name, tintLayer, knownTTGP.Count, length(translateTTGP)]));
    end;
    If LOGGING then LogExitT('SkinLayerTranslation');
end;

//=============================================================================
// Define the probability at which a tint layer will be selected.
procedure SetTintProbability(racename: string; sex: integer; 
    tintLayer: integer; probability: integer); 
var 
    r: integer;
begin
    If LOGGING then LogEntry3(5, 'SetTintProbability', racename, SexToStr(sex), IntToStr(tintLayer));
    r := RacenameIndex(racename);
    if r < 0 then r := AddRace(racename);
    if r >= 0 then begin
        if tintLayer < length(raceInfo[r, sex].tintProbability) then begin
            raceInfo[r, sex].tintProbability[tintLayer] := probability;
        end
        else
            Err(Format('Too many tint layers: have %d, max %d', 
                [tintLayer, length(raceInfo[RacenameIndex(racename), sex].tintProbability)]));
    end;
    If LOGGING then LogExitT('SetTintProbability');
end;

//=============================================================================
// Define the colors that a tint layer may have.
procedure SetTintColors(racename: string; sex: integer; 
    tintLayer: integer; colors: string); 
var 
    r: integer;
begin
    r := RacenameIndex(racename);
    if r >= 0 then begin
        if tintLayer < length(raceInfo[r, sex].tintColors) then
            raceInfo[r, sex].tintColors[tintLayer] := colors
        else
            Err(Format('Too many tint layers, have %d, max %d', 
                [tintLayer, length(raceInfo[r, sex].tintColors)]));
    end;
end;

//===================================================================
// Create the override mod
Function CreateOverrideMod(filename: string): IwbFile;
var
    f: integer;
    fn: string;
    i: integer;
begin
    If LOGGING then LogEntry1(3, 'CreateOverrideMod', filename);
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
    If LOGGING then LogExit(3, 'CreateOverrideMod');

end;

//======================================================================

procedure InitializeGenericNames;
begin
    genericNames := TStringList.Create;
	genericNames.Add('');
	genericNames.Add('Berserk Raider');
	genericNames.Add('Caravan Guard');
	genericNames.Add('Caravan Worker');
	genericNames.Add('Corpse');
	genericNames.Add('Disciple Butcher');
	genericNames.Add('Disciple Pillager');
	genericNames.Add('Disciple Scavver');
	genericNames.Add('Disciple Survivalist');
	genericNames.Add('Disciple Tormentor');
	genericNames.Add('Disciple Veteran');
	genericNames.Add('Disciple Waster');
	genericNames.Add('Disciple');
	genericNames.Add('Gunner Brigadier');
	genericNames.Add('Gunner Captain');
	genericNames.Add('Gunner Colonel');
	genericNames.Add('Gunner Commander');
	genericNames.Add('Gunner Conscript');
	genericNames.Add('Gunner Corporal');
	genericNames.Add('Gunner Lieutenant');
	genericNames.Add('Gunner Major');
	genericNames.Add('Gunner Mercenary');
	genericNames.Add('Gunner Private');
	genericNames.Add('Gunner Sergeant');
	genericNames.Add('Gunner');
	genericNames.Add('Legendary Disciple');
	genericNames.Add('Legendary Gunner');
	genericNames.Add('Legendary Operator');
	genericNames.Add('Legendary Pack');
	genericNames.Add('Legendary Raider');
	genericNames.Add('Operator Butcher');
	genericNames.Add('Operator Pillager');
	genericNames.Add('Operator Scavver');
	genericNames.Add('Operator Survivalist');
	genericNames.Add('Operator Tormentor');
	genericNames.Add('Operator Veteran');
	genericNames.Add('Operator Waster');
	genericNames.Add('Operator');
	genericNames.Add('Pack Butcher');
	genericNames.Add('Pack Member');
	genericNames.Add('Pack Pillager');
	genericNames.Add('Pack Scavver');
	genericNames.Add('Pack Survivalist');
	genericNames.Add('Pack Tormentor');
	genericNames.Add('Pack Veteran');
	genericNames.Add('Pack Waster');
	genericNames.Add('Raider Man');
	genericNames.Add('Raider Psycho');
	genericNames.Add('Raider Scavver');
	genericNames.Add('Raider Scum');
	genericNames.Add('Raider Survivalist');
	genericNames.Add('Raider Veteran');
	genericNames.Add('Raider Waster');
	genericNames.Add('Raider Woman');
	genericNames.Add('Raider');
	genericNames.Add('Settler');
	genericNames.Add('Sinners Raider');
end;

Procedure FreeGenericNames;
begin
    genericNames.Free;
end;

procedure InitializeAssetLoader;
var
    i: integer;
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
    headpartsList.Add('Meatcaps');
    headpartsList.Add('Misc');
    headpartsList.Add('Scar');
    headpartsList.Add('Teeth');
    HEADPART_EYEBROWS := headpartsList.IndexOf('Eyebrows');
    HEADPART_EYES := headpartsList.IndexOf('Eyes');
    HEADPART_FACE := headpartsList.IndexOf('Face');
    HEADPART_FACIAL_HAIR := headpartsList.IndexOf('Facial Hair');
    HEADPART_HAIR := headpartsList.IndexOf('Hair');
    HEADPART_MEATCAP := headpartsList.IndexOf('Meatcaps');
    HEADPART_MISC := headpartsList.IndexOf('Misc');
    HEADPART_MOUTH := headpartsList.IndexOf('Teeth');
    HEADPART_SCAR := headpartsList.IndexOf('Scar');
    HEADPART_LO := 0;
    HEADPART_HI := headpartsList.Count-1;

    specialHeadparts := TStringList.Create;
    specialHeadparts.Duplicates := dupIgnore;
    specialHeadparts.Sorted := true;

    masterRaceList := TStringList.Create;
    masterRaceList.Sorted := false;
    masterRaceList.Duplicates := dupIgnore;
    RACE_LO := 0;
    
    childRaceList := TStringList.Create;
    childRaceList.Sorted := false;
    childRaceList.Duplicates := dupIgnore;

    racesNotFound := TStringList.Create;
    racesNotFound.Sorted := true;
    racesNotFound.Duplicates := dupIgnore;
    
    mothers := TStringList.Create;
    mothers.Sorted := true;
    mothers.Duplicates := dupIgnore;
    
    fathers := TStringList.Create;
    fathers.Sorted := true;
    fathers.Duplicates := dupIgnore;
    
    tintlayerName := TStringList.Create;
    tintlayerName.Duplicates := dupIgnore;
    tintlayerName.Sorted := false; // Need these in the order we add them

    npcRaceAssignments := TStringList.Create;
    npcRaceAssignments.Duplicates := dupIgnore;
    npcRaceAssignments.Sorted := true;

    knownTTGP := TStringList.Create;
    knownTTGP.Duplicates := dupIgnore;
    knownTTGP.Sorted := false;

    vanillaHairRecords := TStringList.Create;
    vanillaHairRecords.Duplicates := dupIgnore;
    vanillaHairRecords.Sorted := false;

    hairExcludeList := TStringList.Create;
    hairExcludeList.Duplicates := dupIgnore;
    hairExcludeList.Sorted := false;

    InitializeGenericNames;

    savedNPCIndex := 0;
end;

procedure LoadRaceAssets;
begin
    CollectRaceMorphs;
    CollectRaceTintLayers;
    CollectRaceHeadparts;
    LoadParents;
end;

procedure ShutdownAssetLoader;
var
    i, j, k: integer;
begin
    for i := RACE_LO to RACE_HI do begin
        for j := SEX_LO to SEX_HI do begin
            if Assigned(raceInfo[i, j].morphGroups) then 
                raceInfo[i, j].morphGroups.Free;
            if Assigned(raceInfo[i, j].morphProbability) then 
                raceInfo[i, j].morphProbability.Free;
            if Assigned(raceInfo[i, j].morphLo) then 
                raceInfo[i, j].morphLo.Free;
            if Assigned(raceInfo[i, j].morphHi) then 
                raceInfo[i, j].morphHi.Free;
            if Assigned(raceInfo[i, j].morphSkew) then 
                raceInfo[i, j].morphSkew.Free;
            if Assigned(raceInfo[i, j].morphExcludes) then 
                raceInfo[i, j].morphExcludes.Free;
            if Assigned(raceInfo[i, j].faceBoneList) then 
                raceInfo[i, j].faceBoneList.Free;

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
    knownTTGP.Free;
    vanillaHairRecords.Free;
    hairExcludeList.Free;
    masterRaceList.Free;
    childRaceList.Free;
    racesNotFound.Free;
    mothers.Free;
    fathers.Free;
    FreeGenericNames;
end;

end.