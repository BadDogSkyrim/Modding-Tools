{
    Generate additional NPCs for NPC classes that don't have enough variety.
    Make additional fixes so the new NPCs are used.

}
unit FFOGenerateNPCs;

interface
implementation
uses FFO_Furrifier, BDAssetLoaderFO4, xEditAPI, Classes, SysUtils, StrUtils, Windows;

var 
    leveledList: array [0..50, 0..50] of IwbMainRecord;
    badTemplates:  TStringList;
    newMod: IwbFile;
    targetFile: IwbFile;

//=====================================================================================
// Generate a random furry NPC in the target file based on the given npc
Function GenerateRandomNPC(targetFile: IwbFile; npc: IwbMainRecord; targetSex: integer): IwbMainRecord;
var
    newNPC: IwbMainRecord;
    name: string;
begin
    if LOGGING then LogEntry2(5, 'GenerateRandomNPC', GetFileName(targetFile), Name(npc));
    AddRecursiveMaster(targetFile, GetFile(npc));
    newNPC := wbCopyElementToFile(npc, targetFile, True, True);
    if LOGGING then LogT(Format('Created NPC %.8x', [integer(FormID(newNPC))]));
    name := 'FFO_' + EditorID(npc) + '_' + IntToHex(Random(32768), 4);
    if targetSex = FEMALE then begin
        name := name + '_F';
        SetElementNativeValues(newNPC, 'ACBS\Flags\female', 1);
    end;
    SetEditorID(newNPC, name);
    if LOGGING then LogT('Created ' + EditorID(newNPC));
    FurrifyNPC(newNPC, targetFile);

    result := newNPC;
    if LOGGING then LogExitT('GenerateRandomNPC');
end;

//================================================================================
// Find or create an override of the given record in the target file.
Function CreateOverrideInFile(elem: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
var
    found: boolean;
    i: integer;
    ovr: IwbMainRecord;
    ovrLoadIndex: integer;
    targetLoadIndex: integer;
begin
    if LOGGING then Log(5, Format('<CreateOverrideInFile: %s -> %s', [EditorID(elem), GetFileName(targetFile)]));
    found := false;
    ovrLoadIndex := -1;
    for i := OverrideCount(elem)-1 downto 0 do begin
        ovr := OverrideByIndex(elem, i);
        ovrLoadIndex := GetLoadOrder(GetFile(ovr));
        targetLoadIndex := GetLoadOrder(targetFile);
        if ovrLoadIndex = targetLoadIndex then begin
            // Found an existing override, return that.
            result := ovr;
            found := true;
            break;
        end
        else if ovrLoadIndex < targetLoadIndex then
            break;
    end;
    if not found then begin
        // Override doesn't exist--create it.
        if ovrLoadIndex = -1 then ovr := elem;
        AddRecursiveMaster(targetFile, GetFile(ovr));
        result := wbCopyElementToFile(ovr, targetFile, False, True);
    end;
    if LOGGING then Log(5, '>CreateOverrideInFile');
end;

//===================================================================
// Add the NPC to the given leveled list.
Procedure AddNPCtoLevelList(npc: IwbMainRecord; ll: IwbMainRecord);
var
    el: IwbElement;
    entry: IwbElement;
    lle: IwbContainer;
    lvlo: IwbElement;
    newLL: IwbMainRecord;
begin
    if LOGGING then LogEntry2(5, 'AddNPCtoLevelList', EditorID(npc), EditorID(ll));
    newLL := CreateOverrideInFile(ll, GetFile(npc));
    lle := ElementByPath(newll, 'Leveled List Entries');
    lvlo := ElementByIndex(lle, 0);
    entry := ElementAssign(lle, HighInteger, lvlo, false);
    el := ElementByPath(entry, 'LVLO');
    SetNativeValue(
        ElementByPath(el, 'Reference'), 
        LoadOrderFormIDtoFileFormID(GetFile(npc), GetLoadOrderFormID(npc)));
    SetNativeValue(ElementByPath(el, 'Level'), 1);
    SetNativeValue(ElementByPath(el, 'Count'), 1);
    if LOGGING then LogExitT('AddNPCtoLevelList');
end;

//=========================================================
// Add newNPC to any lists oldNPC is on.
Procedure AddNPCtoLists(newNPC, oldNPC: IwbMainRecord);
var
    i: integer;
    ref: IwbMainRecord;
    referencers: TStringList;
begin
    // Collect all the referencers first, because we will extend this list
    referencers := TStringList.Create;
    referencers.Duplicates := dupIgnore;
    for i := 0 to ReferencedByCount(oldNPC)-1 do begin
        ref := ReferencedByIndex(oldNPC, i);
        if IsWinningOverride(ref) and (Signature(ref) = 'LVLN') then 
            referencers.AddObject(EditorID(ref), TObject(ref));
    end;

    // Walk the referencers we found and add to each.
    for i := 0 to referencers.Count-1 do begin
        ref := ObjectToElement(referencers.Objects[i]);
        AddNPCtoLevelList(newNPC, ref);
    end;
end;

//==========================================================
// 

//==========================================================
// Generate 'num' new NPCs copied from the template NPC.
Procedure GenerateNPCs(targetFile: IwbFile; 
    templateNPCname: string; num: integer; targetSex: integer);
var
    i: integer;
    newNPC: IwbMainRecord;
    tpl: IwbMainRecord;
begin
    for i := 0 to num-1 do begin
        tpl := FindAsset(Nil, 'NPC_', templateNPCname);
        if Assigned(tpl) then begin
            newNPC := GenerateRandomNPC(targetFile, tpl, targetSex);
            AddNPCtoLists(newNPC, tpl);
        end
        else if not StartsText('DLC', templateNPCname) then
            AddMessage('ERROR: Could not find NPC ' + templateNPCname);
    end;
end;

//=========================================================================
// Determine whether the NPC appears in the given leveled list.
Function NPCinLeveledList(npc, levellist: IwbMainRecord): boolean;
var
    i: integer;
    elem: IwbMainRecord;
begin
    result := false;
    for i := 0 to ReferencedByCount(npc)-1 do begin
        elem := ReferencedByIndex(npc, i);
        if FormID(elem) = FormID(levellist) then begin
            result := true;
            break;
        end;
    end;
end;

//===============================================================================
// Force the NPC's traits template to the approparite leveled list.
function ForceLLTemplate(targetFile: IwbFile; npc: IwbMainRecord; tpl: IwbMainRecord): IwbMainRecord;
var
    newNPC: IwbMainRecord;
    traits: IwbElement;
begin
    if LOGGING then Log(5, Format('<ForceLLTemplate(%s, %s, %s)', [GetFileName(targetFile), Name(npc), Name(tpl)]));
    AddRecursiveMaster(targetFile, GetFile(npc));
    newNPC := wbCopyElementToFile(npc, targetFile, False, True);
    AddRecursiveMaster(targetFile, GetFile(tpl));
    traits := ElementByPath(newNPC, 'TPTA\Traits');
    SetNativeValue(traits, 
        LoadOrderFormIDtoFileFormID(targetFile, 
            GetLoadOrderFormID(tpl)));
    result := newNPC;
    if LOGGING then Log(5, '>ForceLLTemplate');
end;

//===============================================================================
// If an NPC gets its traits from a template 
// AND is not a child 
// AND the chain of templates to the base contains no leveled lists, 
// AND the NPC is not included in any leveled lists, 
// AND the name is generic
// AND it's not one of the player spouse corpses, 
// THEN replace the original NPC's traits with a
// leveled list of the appropriate sex.
function SetGenericTraits(targetFile: IwbFile; npc: IwbMainRecord): IwbMainRecord;
var
    cl: integer;
    curTpl, tpl: IwbMainRecord;
    name: string;
    newNPC: IwbMainRecord;
    noTpl: boolean;
    sex: integer;
begin
    if LOGGING then LogEntry3(5, 'SetGenericTraits', GetFileName(targetFile), Name(npc), SexToStr(GetNPCSex(npc)));
    
    noTpl := false;
    cl := GetNPCClass(npc);
    sex := GetNPCSex(npc);
    newNPC := npc;
    if NPCInheritsTraits(npc) and (EditorID(npc) <> 'MQ102PlayerSpouseCorpseFemale')
        and (EditorID(npc) <> 'MQ102PlayerSpouseCorpseMale') 
    then begin
        curTpl := NPCTraitsTemplate(npc);
        tpl := leveledList[cl, sex];
        if LOGGING then LogT(Format('Have template %s for %s/%s', [
            Name(tpl), GetNPCClassName(cl), SexToStr(sex)]));
        if LOGGING then LogT(Format('Replacing template %s <- %s', [Name(curTpl), Name(tpl)]));
        if badTemplates.IndexOf(EditorID(curTpl)) >= 0 then begin
            if Assigned(tpl) then
                newNPC := ForceLLTemplate(targetFile, npc, tpl)
            else 
                noTpl := true;
        end
        else if (not BasedOnLeveledList(npc))
            and (not NPCisChild(npc)) 
            and NPCisGeneric(npc)
        then begin
            if Assigned(tpl) then begin
                if (not NPCinLeveledList(npc, tpl)) then begin
                    newNPC := ForceLLTemplate(targetFile, npc, tpl);
                end;
            end
            else 
                noTpl := true;
        end;
    end;
    if noTpl then
        Warn(Format('Have no template LL for %s, class %s, class %s', [
            Name(npc),
            GetNPCClassName(GetNPCClass(npc)),
            SexToStr(GetNPCSex(npc))
        ]));
    result := newNPC;
    if LOGGING then LogExitT('SetGenericTraits');
end;

//============================================================================
// Create a new leveled list filled with NPCs based on the given template NPC.
function CreateLL(targetFile: IwbFile; name: string; templateNPCName: string): IwbMainRecord;
var
    i: integer;
    llList: IwbElement;
    lvln: IwbElement;
    newLL: IwbElement;
    npc: IwbMainRecord;
    templateNPC: IwbMainRecord;
begin
    if LOGGING then Log(5, Format('<CreateLL(%s, %s, %s)', [GetFileName(targetFile), name, templateNPCName]));
    templateNPC := FindAsset(nil, 'NPC_', templateNPCName);
    if Assigned(templateNPC) then begin
        lvln := GroupBySignature(targetFile, 'LVLN');
        if not Assigned(lvln) then lvln := Add(targetFile, 'LVLN', true);
        newLL := Add(lvln, 'LVLN', true);
        // newLL := ElementAssign(lvln, HighInteger, nil, false);

        // newLL := wbCopyElementToFile(leveledList[CLASS_RAIDER, MALE], targetFile, True, True);
        SetEditorID(newLL, name);
        Add(newll, 'Leveled List Entries', true);
        // llList := ElementByPath(newLL, 'Leveled List Entries');
        // SetNativeValue(ElementByPath(newLL, 'LLCT', 0));
        // Remove(llList);
        // Add(llList, 'Leveled List Entries', true);
        // for i := 0 to ElementCount(llList)-1 do 
        //     Remove(ElementByIndex(llList, i));

        for i := 1 to 10 do begin
            npc := GenerateRandomNPC(targetFile, templateNPC, GetNPCSex(templateNPC));
            AddNPCtoLevelList(npc, newLL);
        end;

        result := newLL;
    end;
    if LOGGING then Log(5, '>');
end;

procedure InitializeNPCGenerator(targetFile: IwbFile);
begin
    leveledList[CLASS_ATOM, FEMALE] := FindAsset(Nil, 'LVLN', 'LCharChildrenofAtomFemale');
    leveledList[CLASS_ATOM, MALE] := FindAsset(Nil, 'LVLN', 'LCharChildrenofAtomMale');
    leveledList[CLASS_BOS, FEMALE] := Nil;
    leveledList[CLASS_BOS, MALE] := FindAsset(Nil, 'LVLN', 'LCharBoSTraitsSoldier');
    leveledList[CLASS_DISCIPLES, FEMALE] := FindAsset(Nil, 'LVLN', 'DLC04_LCharRaiderDiscipleFaceF');
    leveledList[CLASS_DISCIPLES, MALE] := FindAsset(Nil, 'LVLN', 'DLC04_LCharRaiderDiscipleFaceM');
    leveledList[CLASS_GUNNER, FEMALE] := FindAsset(Nil, 'LVLN', 'LCharGunner_GunnersFemale01');
    leveledList[CLASS_GUNNER, MALE] := FindAsset(Nil, 'LVLN', 'LCharGunner_GunnersMale02');
    leveledList[CLASS_INSTITUTE, FEMALE] := CreateLL(targetFile, 'FFO_LCharInstituteScientist_Fem', 'InstituteScientistFemale');
    leveledList[CLASS_INSTITUTE, MALE] := CreateLL(targetFile, 'FFO_LCharInstituteScientist_Male', 'InstituteScientistMale');
    leveledList[CLASS_MINUTEMEN, FEMALE] := FindAsset(Nil, 'LVLN', 'LCharMinutemenFacesFemale');
    leveledList[CLASS_MINUTEMEN, MALE] := FindAsset(Nil, 'LVLN', 'LCharMinutemenFacesMale');
    leveledList[CLASS_OPERATOR, FEMALE] := CreateLL(targetFile, 'FFO_LCharOperator_Fem', 'DLC04_encGangOperatorFaceF01');
    leveledList[CLASS_OPERATOR, MALE] := CreateLL(targetFile, 'FFO_LCharOperator_Male', 'DLC04_encGangOperatorFaceM01');
    leveledList[CLASS_PACK, FEMALE] := CreateLL(targetFile, 'FFO_LCharPack_Fem', 'DLC04_encGangPackFaceF01');
    leveledList[CLASS_PACK, MALE] := FindAsset(Nil, 'LVLN', 'DLC04_LCharRaiderPackFace_Male');
    leveledList[CLASS_RAIDER, FEMALE] := FindAsset(Nil, 'LVLN', 'LCharRaiderFemale');
    leveledList[CLASS_RAIDER, MALE] := FindAsset(Nil, 'LVLN', 'LCharRaiderMale');
    leveledList[CLASS_SETTLER, FEMALE] := FindAsset(Nil, 'LVLN', 'LCharWorkshopNPCFemale');
    leveledList[CLASS_SETTLER, MALE] := FindAsset(Nil, 'LVLN', 'LCharWorkshopNPCMale');
    leveledList[CLASS_TRAPPER, FEMALE] := Nil;
    leveledList[CLASS_TRAPPER, MALE] := FindAsset(Nil, 'LVLN', 'DLC03_LCharTrapperFace');

    // A NPC that gets its traits from these templates should get them from a leveled list instead.
    badTemplates := TStringList.Create;
    badTemplates.Add('BunkerHillWorkerF01');
    badTemplates.Add('DLC03EncTrapper01Template');
    badTemplates.Add('EncGunner01Template');
    badTemplates.Add('EncMinutemen01Template');
    badTemplates.Add('EncRaider01Template');
    badTemplates.Add('EncSynthCourser01Template');
    badTemplates.Add('EncTriggermanTemplate00');
    badTemplates.Add('Loot_CorpseBase');
    badTemplates.Add('EncChildrenOfAtom01Template');
end;

procedure ShutdownNPCGenerator;
begin
    badTemplates.Free;
end;

Procedure GenerateFurryNPCs(patchFile: IwbFile);
var
    i: integer;
    allNPCs: IwbContainer;
    npc: IwbMainRecord;
begin
    InitializeNPCGenerator(patchFile);

    // Generate NPC variants of these and put them in any leveled lists referencing these
    GenerateNPCs(patchFile, 'DLC03EncTrapper01Template', 10, MALE);
    GenerateNPCs(patchFile, 'DLC03encTrapperFaceM01', 10, MALE);
    GenerateNPCs(patchFile, 'DLC04_encGangDiscipleFaceF01', 10, -1);
    GenerateNPCs(patchFile, 'DLC04_encGangDiscipleFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'DLC04_encGangOperatorFaceF01', 10, -1);
    GenerateNPCs(patchFile, 'DLC04_encGangOperatorFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'DLC04_encGangPackFaceF01', 10, -1);
    GenerateNPCs(patchFile, 'DLC04_encGangPackFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'EncBoSTraitsSoldierFemale01', 10, -1);
    GenerateNPCs(patchFile, 'EncBoSTraitsSoldierMale01', 20, -1);
    GenerateNPCs(patchFile, 'EncChildrenOfAtomFaceF01', 20, -1);
    GenerateNPCs(patchFile, 'EncChildrenOfAtomM01', 20, -1);
    GenerateNPCs(patchFile, 'encGunnerFaceF01', 10, -1);
    GenerateNPCs(patchFile, 'encGunnerFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'encGunnerFaceM02', 20, -1);
    GenerateNPCs(patchFile, 'EncMinutemenFaceF01', 20, -1);
    GenerateNPCs(patchFile, 'EncMinutemenFaceF02', 20, -1);
    GenerateNPCs(patchFile, 'EncMinutemenFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'EncMinutemenFaceM02', 20, -1);
    GenerateNPCs(patchFile, 'encRaiderFaceF01', 10, -1);
    GenerateNPCs(patchFile, 'encRaiderFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'encRRAgentFaceF01', 10, -1);
    GenerateNPCs(patchFile, 'encRRAgentFaceF01', 10, -1);
    GenerateNPCs(patchFile, 'encRRAgentFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'EncSecurityDiamondCityM01', 10, MALE);
    GenerateNPCs(patchFile, 'EncTriggermanFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'EncWorkshopNPCFemaleFarmer01', 20, FEMALE);
    GenerateNPCs(patchFile, 'EncWorkshopNPCFemaleGuard01', 20, -1);
    GenerateNPCs(patchFile, 'EncWorkshopNPCMaleFarmer02', 20, MALE);
    GenerateNPCs(patchFile, 'EncWorkshopNPCMaleGuard01b', 20, -1);
    GenerateNPCs(patchFile, 'FaceRaiderA', 20, -1);
    GenerateNPCs(patchFile, 'InstituteScientistFemale', 20, FEMALE);
    GenerateNPCs(patchFile, 'InstituteScientistMale', 20, MALE);

    // Fix Operator, Disciple, and Pack
    // If an NPC gets its traits from a template AND is not a child AND the chain of
    // templates to the base contains no leveled lists, AND the name is generic, then
    // replace the original NPC's traits with a leveled list of the appropriate sex.
    allNPCs := GroupBySignature(patchFile, 'NPC_');
    for i := 0 to ElementCount(allNPCs)-1 do begin
        npc := ElementByIndex(allNPCs, i);
        if EditorID(npc) = 'Loot_CorpseSettlerMale' then
            ForceLLTemplate(targetFile, npc, leveledList[CLASS_SETTLER, MALE])
        else if EditorID(npc) = 'Loot_CorpseSettlerFemale' then
            ForceLLTemplate(targetFile, npc, leveledList[CLASS_SETTLER, FEMALE])
        else
            SetGenericTraits(patchFile, npc);
    end;

    ShutdownNPCGenerator;
end;

function Initialize: integer;
begin
    LOGLEVEL := 0;
    newMod := CreateOverrideMod('FFOGGeneratedNPCs.esp');
    AddMessage('Created ' + GetFileName(newMod));
    InitializeFurrifier(newMod);
    LOGLEVEL := 5;
    InitializeNPCGenerator(newMod);
end;

function Process(e: IInterface): integer;
begin
    if Signature(e) = 'NPC_' then begin 
        SetGenericTraits(newMod, WinningOverride(e));
    end;
end;

function Finalize: integer;
begin
    ShutdownNPCGenerator;
end;
end.