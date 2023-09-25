{
    Generate additional NPCs for NPC classes that don't have enough variety.

	Hotkey: Ctrl+Alt+G
}
unit FFOGenerateNPCs;

interface
implementation
uses FFO_Furrifier, BDAssetLoaderFO4, xEditAPI, Classes, SysUtils, StrUtils, Windows;

var 
    targetFile: IwbFile;

Function GenerateRandomNPC(targetFile: IwbFile; npc: IwbMainRecord; targetSex: integer): IwbMainRecord;
var
    newNPC: IwbMainRecord;
    name: string;
begin
    Log(5, '<GenerateRandomNPC: ' + EditorID(npc));
    AddRecursiveMaster(targetFile, GetFile(npc));
    newNPC := wbCopyElementToFile(npc, targetFile, True, True);
    name := 'FFO_' + EditorID(npc) + '_' + IntToHex(Random(32768), 4);
    if targetSex = FEMALE then begin
        name := name + '_F';
        SetElementNativeValues(newNPC, 'ACBS\Flags\female', 1);
    end;
    SetEditorID(newNPC, name);
    Log(5, 'Created ' + EditorID(newNPC));
    CleanNPC(newNPC);
    FurrifyNPC(newNPC, targetFile);

    result := newNPC;
    Log(5, '>GenerateRandomNPC');
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
    Log(5, Format('<CreateOverrideInFile: %s -> %s', [EditorID(elem), GetFileName(targetFile)]));
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
    Log(5, '>CreateOverrideInFile');
end;

//===================================================================
// Add the NPC to the given leveled list.
Procedure AddNPCtoLevelList(npc: IwbMainRecord; ll: IwbMainRecord);
var
    entry: IwbElement;
    lle: IwbContainer;
    lvlo: IwbElement;
    newLL: IwbMainRecord;
begin
    Log(5, Format('<AddNPCtoLevelList: %s to %s from file %s', [EditorID(npc), EditorID(ll), GetFileName(GetFile(ll))]));
    newLL := CreateOverrideInFile(ll, GetFile(npc));
    lle := ElementByPath(newll, 'Leveled List Entries');
    lvlo := ElementByIndex(lle, 0);
    entry := ElementAssign(lle, HighInteger, lvlo, false);
        SetNativeValue(ElementByPath(entry, 'LVLO\Reference'), 
        LoadOrderFormIDtoFileFormID(GetFile(npc), GetLoadOrderFormID(npc)));
    Log(5, '>AddNPCtoLevelList in file ' + GetFileName(GetFile(newLL)));
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

function Initialize: integer;
begin
  
end;

function Process(e: IInterface): integer;
begin
  
end;

Procedure GenerateFurryNPCs(patchFile: IwbFile);
begin
    GenerateNPCs(patchFile, 'EncBoSTraitsSoldierMale01', 20, -1);
    GenerateNPCs(patchFile, 'EncBoSTraitsSoldierFemale01', 20, -1);
    GenerateNPCs(patchFile, 'EncWorkshopNPCFemaleFarmer01', 20, -1);
    GenerateNPCs(patchFile, 'EncWorkshopNPCFemaleGuard01', 20, -1);
    GenerateNPCs(patchFile, 'EncWorkshopNPCMaleFarmer01b', 20, -1);
    GenerateNPCs(patchFile, 'EncWorkshopNPCMaleGuard01b', 20, -1);
    GenerateNPCs(patchFile, 'encGunnerFaceF01', 20, -1);
    GenerateNPCs(patchFile, 'encGunnerFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'EncMinutemenFaceF01', 20, -1);
    GenerateNPCs(patchFile, 'EncMinutemenFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'encRaiderFaceF01', 20, -1);
    GenerateNPCs(patchFile, 'encRaiderFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'encRRAgentFaceF01', 20, -1);
    GenerateNPCs(patchFile, 'EncTriggermanFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'EncSecurityDiamondCityM01', 10, -1);
    GenerateNPCs(patchFile, 'EncSecurityDiamondCityM01', 10, FEMALE);
    GenerateNPCs(patchFile, 'EncMinutemenFaceF01', 20, -1);
    GenerateNPCs(patchFile, 'EncMinutemenFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'FaceRaiderA', 20, -1);
    GenerateNPCs(patchFile, 'DLC03EncTrapper01Template', 20, -1);
    GenerateNPCs(patchFile, 'DLC03EncTrapper01Template', 20, FEMALE);
    GenerateNPCs(patchFile, 'DLC04_encGangPackFaceF01', 20, -1);
    GenerateNPCs(patchFile, 'DLC04_encGangPackFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'DLC04_encGangDiscipleFaceF01', 20, -1);
    GenerateNPCs(patchFile, 'DLC04_encGangDiscipleFaceM01', 20, -1);
    GenerateNPCs(patchFile, 'DLC04_encGangOperatorFaceF01', 20, -1);
    GenerateNPCs(patchFile, 'DLC04_encGangOperatorFaceM01', 20, -1);
end;

function Finalize: integer;
begin
    LOGLEVEL := 0;
    InitializeFurrifier;

    LOGLEVEL := 5;
    patchFile := CreateOverrideMod(patchfileName);

    GenerateFurryNPCs(patchFile);

end;
end.