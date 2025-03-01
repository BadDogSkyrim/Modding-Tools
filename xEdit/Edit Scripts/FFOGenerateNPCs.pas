{
    Generate additional NPCs for NPC classes that don't have enough variety.
    Make additional fixes so the new NPCs are used.

}
unit FFOGenerateNPCs;

interface
implementation
uses BDAssetLoaderFO4, xEditAPI, Classes, SysUtils, StrUtils, Windows;

var 
    leveledList: TStringList;
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
    if LOGGING then LogEntry3(5, 'GenerateRandomNPC', 
        GetFileName(targetFile), RecordName(npc), SexToStr(targetSex));
    
    AddRecursiveMaster(targetFile, GetFile(npc));
    newNPC := wbCopyElementToFile(npc, targetFile, True, True);
    if LOGGING then LogT(Format('Created NPC %.8x', [integer(FormID(newNPC))]));
    
    // Generate a unique, unused name.
    repeat begin
        name := EditorID(npc) + '_' + IntToHex(Random(32768), 4);
        if targetSex = FEMALE then name := name + '_F';
        if targetSex = MALE then name := name + '_M';
        if not StartsText('FFO_', name) then name := 'FFO_' + name;
        if length(name) > 40 then name := leftstr(name, 25) + rightstr(name, 6);
        end;
    until not Assigned(FindAsset(targetFile, 'NPC_', name));

    if targetSex = FEMALE then begin
        SetElementEditValues(newNPC, 'ACBS\Flags\female', '1');
    end
    else if targetSex = MALE then begin
        SetElementEditValues(newNPC, 'ACBS\Flags\female', '0');
    end;
    SetEditorID(newNPC, name);
    if LOGGING then LogD(Format('NPC %s created as %s', [
        RecordName(newNPC), SexToStr(GetNPCSex(newNPC))]));

    // Don't get traits from template, even if original did.
    SetElementNativeValues(newNPC, 'ACBS - Configuration\Use Template Actors\Traits', 0);

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
    SetNativeValue(
        LeveledListEntryRef(entry), 
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
// Generate 'num' new NPCs copied from the template NPC and add them to any lists the
// original NPC is on.
// Returns one of the generated NPCs.
Function GenerateNPCs(targetFile: IwbFile; 
    templateNPCname: string; num: integer; targetSex: integer):
    IwbMainRecord;
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
    result := newNPC;
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
// Force the NPC's traits template to the appropriate leveled list.
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

//============================================================================
// Create a new leveled list filled with NPCs based on the given template NPC.
// Remember the LL and if the same request is made again, reuse it.
function CreateLL(targetFile: IwbFile; name: string; templateNPC: IwbMainRecord): IwbMainRecord;
var
    i: integer;
    llList: IwbElement;
    lvln: IwbElement;
    newLL: IwbMainRecord;
    npc: IwbMainRecord;
begin
    if LOGGING then LogEntry3(5, 'CreateLL', GetFileName(targetFile), name, RecordName(templateNPC));

    i := leveledList.IndexOf(EditorID(templateNPC));
    if i >= 0 then
        result := leveledList.objects(i)
    else begin
        lvln := GroupBySignature(targetFile, 'LVLN');
        if not Assigned(lvln) then lvln := Add(targetFile, 'LVLN', true);
        newLL := Add(lvln, 'LVLN', true);
        SetEditorID(newLL, name);
        Add(newll, 'Leveled List Entries', true);
        for i := 1 to 5 do begin
            npc := GenerateRandomNPC(targetFile, templateNPC, GetNPCSex(templateNPC));
            AddNPCtoLevelList(npc, newLL);
        end;
        leveledList.AddObject(EditorID(templateNPC), TObject(newLL));

        result := newLL;
    end;

    if LOGGING then LogExit1(5, 'CreateLL', RecordName(result));
end;

//============================================================================
// Create a new leveled list filled with NPCs based on the named template NPC.
function CreateLLByName(targetFile: IwbFile; name: string; templateNPCName: string): IwbMainRecord;
var
    i: integer;
    llList: IwbElement;
    lvln: IwbElement;
    newLL: IwbMainRecord;
    npc: IwbMainRecord;
    templateNPC: IwbMainRecord;
begin
    if LOGGING then LogEntry3(5, 'CreateLLByName', GetFileName(targetFile), name, templateNPCName);

    templateNPC := FindAsset(nil, 'NPC_', templateNPCName);
    if Assigned(templateNPC) then 
        result := CreateLL(targetFile, name, templateNPC);

    if LOGGING then LogExit1(5, RecordName(result));
end;

{
===============================================================================
If an NPC gets its traits from a template 
AND is not a child 
AND the chain of templates to the base contains no leveled lists, 
AND the NPC is not included in any leveled lists, 
AND the name is generic
AND it's not one of the player spouse corpses, 
THEN replace the original NPC's traits with a leveled list of the appropriate sex.
}
function SetGenericTraits(targetFile: IwbFile; npc: IwbMainRecord): IwbMainRecord;
var
    cl: integer;
    curTpl, tpl: IwbMainRecord;
    i: integer;
    name: string;
    newNPC: IwbMainRecord;
    noTpl: boolean;
    sex: integer;
begin
    if LOGGING then LogEntry3(5, 'SetGenericTraits', GetFileName(targetFile), RecordName(npc), SexToStr(GetNPCSex(npc)));
    
    noTpl := false;
    cl := GetNPCClass(npc);
    sex := GetNPCSex(npc);
    newNPC := npc;

    if NPCInheritsTraits(npc) 
        and (EditorID(npc) <> 'MQ102PlayerSpouseCorpseFemale')
        and (EditorID(npc) <> 'MQ102PlayerSpouseCorpseMale') 
    then begin
        curTpl := NPCTraitsTemplate(npc);

        if LOGGING then LogT(Format('Current template: %s', [RecordName(curTpl)]));
        if LOGGING then LogT(Format('Based on LL: %s', [BoolToStr(BasedOnLeveledList(npc))]));
        if LOGGING then LogT(Format('Is child: %s', [BoolToStr(NPCIsChild(npc))]));
        if LOGGING then LogT(Format('Is generic: %s', [BoolToStr(NPCisGeneric(npc))]));
        if Assigned(curTpl)
            and (not BasedOnLeveledList(npc))
            and (not UsedByLeveledList(npc))
            and (not NPCisChild(npc)) 
            and NPCisGeneric(npc)
        then begin
            if LOGGING then LogT('NPC based on single template');
            i := leveledList.IndexOf(EditorID(npc));
            if i >= 0 then
                tpl := leveledList.objects(i)
            else 
                tpl := CreateLL(targetFile, EditorID(npc) + '_LVL', npc);
            if Assigned(tpl) then begin
                newNPC := ForceLLTemplate(targetFile, npc, tpl);
            end;
        end;
    end;
    result := newNPC;

    if LOGGING then LogExitT('SetGenericTraits');
end;

//=====================================================================
// Expand a leveled list with additional entries based on the entries already there.
procedure ExpandLL(plugin: IwbFile; list: IwbMainRecord);
var
    addc: integer;
    i: integer;
    le: IwbElement;
    llc: integer;
    llist: IwbElement;
    npc: IwbMainRecord;
    refr: IwbElement;
    tpl: IwbMainRecord;
    newlist: IwbMainRecord;
begin
    if LOGGING then LogEntry1(1, 'ExpandLL', RecordName(list));
    llist := ElementByPath(list, 'Leveled List Entries');
    llc := ElementCount(llist);
    addc := 5 - llc;
    if addc > 0 then begin
        newlist := CreateOverrideInFile(list, plugin);
        for i := 0 to addc do begin
            le := ElementByIndex(llist, i mod llc);
            if LOGGING then LogD(Format('Found list entry %s', [PathName(le)]));
            refr := LeveledListEntryRef(le);
            if LOGGING then LogD(Format('Found template %s', [RecordName(LinksTo(refr))]));
            tpl := WinningOverride(LinksTo(refr));
            npc := GenerateRandomNPC(plugin, tpl, -1);
            AddNPCtoLevelList(npc, newlist);
        end;
    end;
    if LOGGING then LogExit(1, 'ExpandLL');
end;

{====================================================================
Check whether a leveled list has actors we care about.
Does this by checking the first entry only.
}
function ContainsFurryActors(leveledlist: IwbMainRecord): boolean;
var
    lle: IwbElement;
    llefirst: IwbElement;
    targfirst: IwbMainRecord;
    targNPCref: IwbMainRecord;
    basefirst: IwbMainRecord;
begin
    if LOGGING then LogEntry1(5, 'ContainsFurryActors', Name(leveledlist));
    result := FALSE;
    lle := ElementByPath(leveledlist, 'Leveled List Entries');
    if ElementCount(lle) > 0 then begin
        llefirst := ElementByIndex(lle, 0); 
        targNPCref := LeveledListEntryRef(llefirst);
        targfirst := WinningOverride(LinksTo(targNPCref));
        if LOGGING then LogD(Format('targfirst = %s', [RecordName(targfirst)]));
        basefirst := WinningOverride(NPCTraitsSource(targfirst));
        if LOGGING then LogD(Format('Target actor base = %s', [RecordName(basefirst)]));
        if GetNPCRaceID(basefirst) >= 0 then result := TRUE;
    end;    
    if LOGGING then LogExit1(5, 'ContainsFurryActors', BoolToStr(result));
end;

//====================================================================
// Check whether a leveled list has less than 5 items and the entries are generic
// furrifiable NPCs.
function IsTooLimited(leveledlist: IwbMainRecord): boolean;
var
    lle: IwbElement;
    llefirst: IwbElement;
    targ: IwbMainRecord;
    targfirst: IwbElement;
begin
    if LOGGING then LogEntry1(5, 'IsTooLimited', RecordName(leveledlist));
    result := FALSE;
    lle := ElementByPath(leveledlist, 'Leveled List Entries');
    if LOGGING then LogD(Format('List: %s', [PathName(lle)]));
    if ElementCount(lle) < 5 then begin
        llefirst := ElementByIndex(lle, 0); 
        if LOGGING then LogD(Format('List entry: %s', [PathName(llefirst)]));
        targfirst := LeveledListEntryRef(llefirst);
        if LOGGING then LogD(Format('Reference path: %s', [PathName(targfirst)]));
        targ := WinningOverride(LinksTo(targfirst));
        if LOGGING then LogD(Format('Name: %s', [RecordName(targ)]));
        if LOGGING then LogD(Format('Signature: %s', [Signature(targ)]));
        if LOGGING then LogD(Format('Is generic: %s', [BoolToStr(NPCIsGeneric(targ))]));
        if LOGGING then LogD(Format('Race: %s', [EditorID(GetNPCRace(targ))]));
        if LOGGING then LogD(Format('Race ID: %s', [RaceIDToStr(GetNPCRaceID(targ))]));
        if (Signature(targ) = 'NPC_')
            and NPCIsGeneric(targ)
            and (GetNPCRaceID(targ) >= 0)
        then 
            result := TRUE;
    end;
    if LOGGING then LogExit1(5, 'IsTooLimited', BoolToStr(result));
end;

{====================================================================
Ensure a leveled list's NPCs all have unique traits.
}
Procedure FixLimitedVariety(plugin: IwbFile; leveledlist: IwbMainRecord);
var
    baseNPCs: TStringList;
    i: integer;
    lle: IwbContainer;
    lleovr: IwbElement;
    llovr: IwbMainRecord;
    newnpc: IwbMainRecord;
    refr: IwbElement;
    targ, basetraits: IwbMainRecord;
begin
    if LOGGING then LogEntry1(5, 'FixLimitedVariety', RecordName(leveledlist));
    baseNPCs := TStringList.Create;
    baseNPCs.Duplicates := dupIgnore;
    lle := ElementByPath(leveledlist, 'Leveled List Entries');
    for i := 0 to ElementCount(lle)-1 do begin
        refr := LeveledListEntryRef(ElementByIndex(lle, i));
        targ := WinningOverride(LinksTo(refr));
        basetraits := NPCBaseTraitsTemplate(targ);
        if LOGGING then LogD(Format('Found targ=%s, base=%s', [RecordName(targ), RecordName(basetraits)]));
        if Assigned(basetraits) then begin
            if baseNPCs.IndexOf(EditorID(basetraits)) < 0 then begin
                // New base template
                baseNPCs.add(EditorID(basetraits));
                if LOGGING then LogD(Format('Found base template %s', [EditorID(basetraits)]));
            end
            else begin
                if LOGGING then LogT(Format('Found duplicate base: %s', [RecordName(basetraits)]));
                if not Assigned(llovr) then begin
                    llovr := CreateOverrideInFile(leveledlist, plugin);
                    lleovr := ElementByPath(llovr, 'Leveled List Entries');
                end;
                newnpc := GenerateRandomNPC(plugin, targ, -1);
                SetNativeValue(LeveledListEntryRef(ElementByIndex(lleovr, i)), 
                    LoadOrderFormIDtoFileFormID(plugin, GetLoadOrderFormID(newnpc)));
            end;
        end;
    end;

    baseNPCs.Free;

    if LOGGING then LogExit(5, 'FixLimitedVariety');
end;

//=============================================================================
// Walk the load order, expanding all leveled lists that contain generic furrifiable NPCs
// and are too short.
procedure ExpandAllLeveledLists(plugin: IwbFile);
var
    i, j, n: integer;
    f: IwbFile;
    levelednpcs: IwbContainer;
    ll: IwbMainRecord;
begin
    if LOGGING then LogEntry(1, 'ExpandAllLeveledLists');
    for i := FileCount-1 downto 0 do begin
        f := FileByIndex(i);
        if LOGGING then LogD(Format('Checking file %s', [GetFileName(f)]));
        levelednpcs := GroupBySignature(f, 'LVLN');
        if Assigned(levelednpcs) then begin
            if LOGGING then LogD(Format('Checking container %s', [PathName(levelednpcs)]));
            n := ElementCount(levelednpcs);
            for j := 0 to n-1 do begin
                ll := ElementByIndex(levelednpcs, j);
                if HasNoOverride(ll) and ContainsFurryActors(ll) then begin
                    if LOGGING then LogD(Format('Checking LL %s', [PathName(ll)]));
                    FixLimitedVariety(plugin, ll);
                    if IsTooLimited(ll) then 
                        ExpandLL(plugin, ll);
                end;
            end;
        end;
    end;
    if LOGGING then LogExit(1, 'ExpandAllLeveledLists');
end;

procedure InitializeNPCGenerator(targetFile: IwbFile);
begin
    leveledList := TStringList.Create;
end;

procedure ShutdownNPCGenerator;
begin
    leveledList.Free;
    // badTemplates.Free;
end;

Procedure GenerateFurryNPCs(patchFile: IwbFile);
var
    i: integer;
    allNPCs: IwbContainer;
    npc: IwbMainRecord;
begin
    InitializeNPCGenerator(patchFile);

    // Generate NPC variants of these and put them in any leveled lists referencing these
    GenerateNPCs(patchFile, 'DLC03EncTrapper01Template', 10, -1);
    GenerateNPCs(patchFile, 'DLC03encTrapperFaceM01', 10, -1);
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
    GenerateNPCs(patchFile, 'EncSecurityDiamondCityM01', 10, -);
    GenerateNPCs(patchFile, 'EncTriggermanFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'EncWorkshopNPCFemaleFarmer01', 20, -1);
    GenerateNPCs(patchFile, 'EncWorkshopNPCFemaleGuard01', 20, -1);
    GenerateNPCs(patchFile, 'EncWorkshopNPCMaleFarmer02', 20, -1);
    GenerateNPCs(patchFile, 'EncWorkshopNPCMaleGuard01b', 20, -1);
    GenerateNPCs(patchFile, 'FaceRaiderA', 20, -1);
    GenerateNPCs(patchFile, 'InstituteScientistFemale', 20, -1);
    GenerateNPCs(patchFile, 'InstituteScientistMale', 20, -1);

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
    InitializeNPCGenerator(newMod);
end;

function Process(e: IInterface): integer;
var
    rnam: string;
    ovr: IwbMainRecord;
begin
    if Signature(e) = 'NPC_' then begin 
        ovr := WinningOverride(e);
        rnam := EditorID(WinningOverride(LinksTo(ElementByPath(ovr, 'RNAM'))));
        if (rnam = 'HumanRace') or StartsText('FFO', rnam) then begin
            Log(5, Format('+++Processing %s', [RecordName(ovr)]));
            SetGenericTraits(newMod, ovr);
        end;
    end;
end;

function Finalize: integer;
begin
    ShutdownNPCGenerator;
end;
end.