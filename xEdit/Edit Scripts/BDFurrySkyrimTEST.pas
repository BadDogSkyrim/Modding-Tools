{

  Hotkey: Ctrl+Alt+T

}
unit BDFurrySkyrimTEST;

interface
implementation
uses BDFurrySkyrim, BDFurrySkyrim_Preferences, BDFurryArmorFixup, BDFurrifySchlongs,
    BDFurrySkyrimTools, BDScriptTools, BDTestTools, xEditAPI, Classes, SysUtils, StrUtils;

const
    TEST_FILE_NAME = 'TEST.esp';
    TEST_NPCS = TRUE;
    TEST_ARMOR = True;
    TEST_SCHLONGS = True;


function NPCTintLayerCount(npc: IwbMainRecord; layerType: integer): integer;
var
    npcRace, npcFurryRace: IwbMainRecord;
    npcSex: integer;
    npcTintLayers, tintLayer, raceTintLayer: IwbElement;
    tintLayerTINI: string;
    maskType: integer;
    rti, i: integer;
begin
    if LOGGING then LogEntry2(15, 'NPCTintLayerCount', Name(npc), TintlayerToStr(layerType));
    result := 0;
    npcRace := LinksTo(ElementByPath(npc, 'RNAM'));
    npcFurryRace := ObjectToElement(raceAssignments.objects[raceAssignments.IndexOf(EditorID(npcRace))]);
    npcSex := IfThen(GetElementEditValues(npc, 'ACBS - Configuration\Flags\Female') = '1',
        SEX_FEMADULT, SEX_MALEADULT) 
        + IfThen(GetElementEditValues(npcRace, 'DATA - DATA\Flags\Child') = '1', 2, 0);

    npcTintLayers := ElementByPath(npc, 'Tint Layers');
    if Assigned(npcTintLayers) then begin
        for i := 0 to ElementCount(npcTintLayers) - 1 do begin
            tintLayer := ElementByIndex(npcTintLayers, i);
            tintLayerTINI := GetElementEditValues(tintLayer, 'TINI');
            rti := tintAssets[npcSex].IndexOf(EditorID(npcFurryRace));
            if rti >= 0 then begin
                if LOGGING then LogD(Format('Tint Asset Index for %s %s: %d', [EditorID(npcFurryRace), tintLayerTINI, tintAssets[npcSex].objects[rti].IndexOf(tintLayerTINI)]));
                raceTintLayer := ElementByIndex(
                    ElementByPath(npcFurryRace, tintMaskPaths[npcSex]),
                    tintAssets[npcSex].objects[rti].IndexOf(tintLayerTINI));
                maskType := GetLayerID(raceTintLayer);
                if LOGGING then LogD(Format('Have race tint layer %s: %s', [TintLayerToStr(maskType), PathName(raceTintLayer)]));
                if maskType = layerType then result := result + 1;
            end;
        end;
    end;
    if LOGGING then LogExitT1('NPCTintLayerCount', IntToStr(result));
end;

procedure TestSchlongs;
var 
    e: IwbMainRecord;
    flst: IwbMainRecord;
begin
    AddMessage(#13#10#13#10 + '============ CHECKING SCHLONGS ===============');
    
    FurrifyAllSchlongs;

    e := FindAsset(targetFile, 'GLOB', 'YASDogSheathMale_ProbLykaios_NordRace');
    Assert(Assigned(e), 'Have new global for Nord sheath probability');
    AssertFloat(GetElementNativeValues(e, 'FLTV'), 1.0, 'Nord sheath probability is 1.0');

    flst := FindAsset(targetFile, 'FLST', 'YASDogSheathMale_CompatibleRaces');
    Assert(Assigned(flst), 'Have override for YASDogSheathMale_CompatibleRaces');
    AssertGT(ElementListNameCount(ElementByPath(flst, 'FormIDs'), 'NordRace'), 
        0,
        'NordRace added to YASDogSheathMale_CompatibleRaces');
end;

procedure TestNPCs;
var 
    e, aa, old, r: IwbElement;
    i: integer;
begin
    AddMessage('============ CHECKING NPCS ===============');

    // REACHMEN
    // Konoi male skin tone layer index = 302
    r := FindAsset(Nil, 'RACE', 'YASReachmanRace');
    AssertValueListTest(r, 'Head Data\Male Head Data\Tint Masks', 
        'Tint Layer\TINP', 'Skin Tone', TRUE); 
    e := FindElementInCompoundList(r, 'Head Data\Male Head Data\Tint Masks', 
        'Tint Layer\TINP', 'Skin Tone');
    AddMessage('Found skin tone layer: ' + PathName(e));
    AssertStr(GetElementEditValues(e, 'Tint Layer\TINI'),
        '302', 
        'Konoi skin tone layer');
    AssertStr(GetElementEditValues(e, 'Tint Layer\TINT'),
        'YAS\Kygarra\Male\Tints\KygarraSkinTone.dds', 
        'Konoi skin tone file');

    // Reachmen are set to a new Reachmen race 
    old := FindAsset(FileByIndex(0), 'NPC_', 'EncVigilantOfStendarr05RedguardF');
    e := FurrifyNPC(old);

    old := FindAsset(FileByIndex(0), 'NPC_', 'EncForsworn01Melee1HBretonM01');
    e := FurrifyNPC(old);
    AssertStr(EditorID(LinksTo(ElementByPath(e, 'RNAM'))), 'YASReachmanRace', 
        'EncForsworn01Melee1HBretonM01 is now Reachman');
    AssertNpcTintLayersExist(e);

    old := FindAsset(FileByIndex(0), 'NPC_', 'Ainethach');
    e := FurrifyNPC(old);
    AssertStr(EditorID(LinksTo(ElementByPath(e, 'RNAM'))), 'YASReachmanRace', 
        'Ainethach is now Reachman');
    AssertNpcTintLayersExist(e);

    // BRETONS
    old := FindAsset(FileByIndex(0), 'NPC_', 'GiraudGemane');
    e := FurrifyNPC(old);
    // Breton Skin tone layer index = 2
    AssertInt(ActorHasTint(e, 'Actors\Character\Character Assets\TintMasks\SkinTone.dds'), 
        0, 'Original skin tone not found');
    AssertInt(ActorHasTint(e, 'YAS\Kettu\Male\tints\SkinTone.dds'), 1, 'Furry skin tone found');
    old := FindAsset(FileByIndex(0), 'NPC_', 'EncBandit01MagicBretonM');
    e := FurrifyNPC(old);
    old := FindAsset(FileByIndex(0), 'NPC_', 'EncBandit02MagicBretonM');
    e := FurrifyNPC(old);
    old := FindAsset(FileByIndex(0), 'NPC_', 'EncBandit03MagicBretonM');
    e := FurrifyNPC(old);

    // NORDS
    // Nord race should be lykaios race
    e := FindAsset(targetFile, 'RACE', 'NordRace');
    old := FindAsset(FileByIndex(0), 'RACE', 'NordRace');
    AssertStr(EditorID(LinksTo(ElementByPath(e, 'WNAM'))), 'YASLykaiosSkin',
        'Nord skin is now lykaios');
    AssertStr(EditorID(LinksTo(ElementByPath(e, 'RNAM'))), 'KhajiitRace',
        'Nord armor race is now Khajiit');
    AddMessage(GetFileName(GetFile(old)) + ' race has headpart 0: ' + GetElementEditValues(old, 'Head Data\Male Head Data\Head Parts\[0]\HEAD'));
    AddMessage(GetFileName(GetFile(e)) + ' race has headpart 0: ' + GetElementEditValues(e, 'Head Data\Male Head Data\Head Parts\[0]\HEAD'));
    AssertInCompoundList(ElementByPath(e, 'Head Data\Male Head Data\Head Parts'), 
        'HEAD',
        'YASLykaiosMaleHead');

    // Nord NPC is properly furrified
    // CorpsePrisoner doesn't have negative tint indices.
    old := FindAsset(FileByIndex(0), 'NPC_', 'EncBandit01Melee1HNordM');
    e := FurrifyNPC(old);
    old := FindAsset(FileByIndex(0), 'NPC_', 'CorpsePrisonerNordMale');
    e := FurrifyNPC(old);

    // New Angvid has Skin Tone layer, no null layers.
    old := FindAsset(FileByIndex(0), 'NPC_', 'Angvid');
    e := FurrifyNPC(old);
    AssertInt(ActorHasTint(e, 'dirt'), 0, 'Angvid has no dirt tint');
    AssertInt(ActorHasTint(e, 'paint'), 0, 'Angvid has no paint tint');

    old := FindAsset(FileByIndex(0), 'NPC_', 'BalgruuftheGreater');
    Assert(Assigned(old), 'Have BalgruuftheGreater');
    e := FurrifyNPC(old);
    Assert(GetFileName(GetFile(e)) = TEST_FILE_NAME, 'Override created');
    AssertNotInList(ElementByPath(e, 'Head Parts'), 'HumanBeard35');
    AssertNameInList(ElementByPath(e, 'Head Parts'), 'Hair');
    Assert(ElementCount(ElementByPath(e, 'Tint Layers')) > 1, 'At least two tint layers');
    AssertInt(ActorHasTint(e, 'paint'), 0, 'BalgruuftheGreater has no paint tint');

    old := FindAsset(FileByIndex(0), 'NPC_', 'BolgeirBearclaw');
    e := FurrifyNPC(old);
    AssertInList(ElementByPath(e, 'Head Parts'), 'YASDayPredMaleEyesBlue');
    AssertInt(ActorHasTint(e, 'SkinTone'), 1, 'BolgeirBearclaw has one skin tone tint');
    AssertInt(ActorHasTint(e, 'dirt'), 1, 'BolgeirBearclaw has dirt tint');

    old := FindAsset(FileByIndex(0), 'NPC_', 'AcolyteJenssen');
    e := FurrifyNPC(old);
    AssertInt(ElementListNameCount(ElementByPath(e, 'Head Parts'), 'YASDayPredMaleEyes'), 1,
        'AcolyteJenssen has one set of eyes');

    old := FindAsset(FileByIndex(0), 'NPC_', 'dunFellglow_TreasCorpseVampire01');
    e := FurrifyNPC(old);
    r := WinningOverride(LinksTo(ElementByPath(e, 'RNAM')));
    AssertInt(ElementListNameCount(ElementByPath(r, 'Head Data\Male Head Data\Head Parts'), 'Child'), 0,
        'Vampire has no child parts');

    //Aliases work
    AssertStr('Astrid', Unalias('AstridEnd'), 'Astrid alias works');
    AssertStr('AstridXXX', Unalias('AstridXXX'), 'Non-alias works');

    // FEMALES TBS
    // old := FindAsset(FileByIndex(0), 'NPC_', 'Ingun');
    // e := FurrifyNPC(old);
    // AssertNameInList(ElementByPath(e, 'Head Parts'), 'BDCanFemHairShortCrop003');

    // // This pit fan has invalid tint layers (looks like they changed her to a woman
    // // without fixing the tint layers). It just has to not crash.
    // old := FindAsset(FileByIndex(0), 'NPC_', 'WindhelmPitFan6');
    // e := FurrifyNPC(old);
    // AssertNameInList(ElementByPath(e, 'Head Parts'), 'BDCanFemHairShortCrop003');

end;


procedure TestRaces;
var
    kr, ch: integer;
begin
    AddMessage(#13#10#13#10 + '============ CHECKING RACES ===============');

    AddMessage(Format('Race 0: %s', [tintAssets[SEX_MALEADULT].strings[0]]));
    AddMessage(Format('--has %d classes', [tintAssets[SEX_MALEADULT].objects[0].Count]));
    AddMessage(Format('--class 0: %s', [tintAssets[SEX_MALEADULT].objects[0].strings[0]]));
    AddMessage(Format('--class 0 has %d tints', [tintAssets[SEX_MALEADULT].objects[0].objects[0].count]));
    AddMessage(Format('--class 0 tint 0 path: %s', [PathName(ObjectToElement(
        tintAssets[SEX_MALEADULT].objects[0].objects[0].objects[0]))]));

    kr := tintAssets[SEX_MALEADULT].IndexOf('YASKettuRace');
    Assert(kr > 0, 'Have kettu race tints');

    ch := tintAssets[SEX_MALEADULT].objects[kr].indexOf('KettuCheek');
    Assert(ch > 0, 'Have kettu cheek tint class');

    Assert(tintAssets[SEX_MALEADULT].objects[kr].objects[ch].count >= 3, 
        'Have at least three kettu cheek tint layers');
    
    AddMessage('Count = ' + IntToStr(tintAssets[SEX_MALEADULT].objects[kr].objects[ch].count));
    AddMessage('Key 0 = ' + tintAssets[SEX_MALEADULT].objects[kr].objects[ch].strings[0]);
    AddMessage('Value 0 = ' + PathName(ObjectToElement(tintAssets[SEX_MALEADULT].objects[kr].objects[ch].Objects[0])));
    Assert(ContainsText(PathName(ObjectToElement(tintAssets[SEX_MALEADULT].objects[kr].objects[ch].Objects[0])),
        'Tint Masks'),
        'Class tint path 0 contains Tint Masks');
end;


procedure TestArmor;
var 
    e, aa, old: IwbElement;
    addons: IwbContainer;
    i: integer;
begin
    AddMessage(#13#10#13#10 + '============ CHECKING ARMOR ===============');
    FurrifyArmorsInit;

    { Hoods just use the khajiit version, so make sure furrified races are removed from
    the human addons. } 
    AddMessage(#13#10#13#10 + '==Hood=='); 
    old := WinningOverride(FindAsset(FileByIndex(0), 'ARMO', 'ClothesCollegeHood'));
    e := FurrifyArmorRecord(old);
    aa := WinningOverride(FindAsset(FileByIndex(0), 'ARMA', 'MageApprenticeHoodAA'));

    { The stormcloak helmet has special variants for cats and dogs. Cat and Canine mods
    provide special versions keyed to their races. The furrifier has to merge them.} 
    AddMessage(#13#10#13#10 + '==Stormcloak helmet=='); 
    old := WinningOverride(FindAsset(FileByIndex(0), 'ARMO', 'ArmorStormcloakHelmetFull'));
    e := FurrifyArmorRecord(old);
    addons := ElementByPath(e, 'Armature');
    // All three addons are in the list
    AssertInt(ElementListNameCount(addons, 'YASStormcloakHelm_DOG'), 1, 'Dog addon present');
    AssertInt(ElementListNameCount(addons, 'BDStormcloakHelm_CAT'), 1, 'Cat addon present');
    AssertInt(ElementListNameCount(addons, 'YASStormcloakHelm'), 1, 'Vanilla addon present');
    // Dog (and cat) have to come before the vanilla.
    AssertGT(
        ElementListNameIndex(addons, 'StormcloakHelm'),
        ElementListNameIndex(addons, 'YASStormcloakHelm_DOG'),
        'Dog addon before vanilla');
    AssertGT(
        ElementListNameIndex(addons, 'StormcloakHelm'),
        ElementListNameIndex(addons, 'BDStormcloakHelm_CAT'),
        'Cat addon before vanilla');

    // Dog & cat addons have been extended with furrified races
    aa := FindAsset(FileByIndex(targetFileIndex), 'ARMA', 'YASStormcloakHelm_DOG');
    AssertInList(ElementByPath(aa, 'Additional Races'), 'NordRace');
    aa := FindAsset(FileByIndex(targetFileIndex), 'ARMA', 'BDStormcloakHelm_CAT');
    AssertInList(ElementByPath(aa, 'Additional Races'), 'WoodElfRace');
    // Furrified races removed from vanilla addon.
    aa := WinningOverride(FindAsset(Nil, 'ARMA', 'StormcloakHelm'));
    AssertEQ(ElementListNameCount(ElementByPath(aa, 'Additional Races'), 'NordRace'), 0, 
        'NordRace removed from vanilla StormcloakHelm ' + PathName(aa));

    { Daedric helmet gets an additional survival keyword. }
    AddMessage(#13#10#13#10 + '==Daedric helmet=='); 
    old := WinningOverride(FindAsset(nil, 'ARMO', 'ArmorDaedricHelmet'));
    FurrifyArmorRecord(old);
    e := WinningOverride(old);
    assertstr(GetFileName(targetFile), GetFileName(GetFile(e)), 'ArmorDaedricHelmet override file');
    AssertInList(ElementByName(e, 'Armature'), 'YASDaedricHelmetAA_DOG');
    AssertInList(ElementByPath(e, 'Keywords\KWDA'), 'Survival_ArmorWarm');
    aa := FindAsset(FileByIndex(targetFileIndex), 'ARMA', 'YASDaedricHelmetAA_DOG');
    AssertInList(ElementByPath(aa, 'Additional Races'), 'NordRace');

    { Archmage 'hood' covers body and head--body addon must not be lost. No special addon
    for dogs--depends on RDF to pick the khajiit addon. }
    AddMessage(#13#10#13#10 + '==Archmage hood=='); 
    old := WinningOverride(FindAsset(FileByIndex(0), 'ARMO', 'ClothesMGRobesArchmage1Hooded'));
    e := FurrifyArmorRecord(old);
    AssertLT(GetLoadOrder(GetFile(e)), GetLoadOrder(targetFile), 'ClothesMGRobesArchmage1Hooded not overridden');
    AssertInList(ElementByName(e, 'Armature'), 'ArchmageHood_KhaAA');
    aa := WinningOverride(FindAsset(nil, 'ARMA', 'ArchmageHood_KhaAA'));
    AssertLT(GetLoadOrder(GetFile(aa)), targetFileIndex, 'ArchmageHood_KhaAA not overridden');

    { Jarl clothes get 'warm' keyword from Update and 'SOS_Revealing' from Skimpy. Make
    sure both are on the winning override. }
    AddMessage(#13#10#13#10 + '==ClothesJarl=='); 
    old := WinningOverride(FindAsset(FileByIndex(0), 'ARMO', 'ClothesJarl'));
    e := FurrifyArmorRecord(old);
    aa := WinningOverride(LinksTo(ElementByIndex(ElementByPath(e, 'Armature'), 0)));
    AssertGT(ElementListNameIndex(ElementByPath(aa, 'Additional Races'), 'NordRace'), -1, 
        Format('NordRace still in in %s addon', [EditorID(aa)]));
    AssertInList(ElementByPath(e, 'Keywords\KWDA'), 'Survival_ArmorWarm');
    AssertInList(ElementByPath(e, 'Keywords\KWDA'), 'SOS_Revealing');
    AssertInList(ElementByPath(e, 'Keywords\KWDA'), 'ClothingRich');

    // *** not testing with USLEEP ***
    // { Bone crown has ArmorMaterialDaedric in Skyrim but ArmorMaterialDragonplate in
    // USSEEP. 
    // TODO: Figure out how remove the Daedric keyword, rather than just merging the list. }
    // AddMessage(#13#10#13#10 + '==ArmorBoneCrown=='); 
    // old := WinningOverride(FindAsset(FileByIndex(0), 'ARMO', 'ArmorBoneCrown'));
    // e := FurrifyArmorRecord(old);
    // AssertInList(ElementByPath(e, 'Keywords\KWDA'), 'ArmorMaterialDragonplate');
    // //AssertNotInList(ElementByPath(e, 'Keywords\KWDA'), 'ArmorMaterialDaedric');

    { Even clothes that don't get furrified should have their keywords merged. }
    AddMessage(#13#10#13#10 + '==ClothesEmperor=='); 
    old := WinningOverride(FindAsset(FileByIndex(0), 'ARMO', 'ClothesEmperor'));
    e := FurrifyArmorRecord(old);
    AssertInList(ElementByPath(e, 'Keywords\KWDA'), 'Survival_ArmorWarm');
    AssertInList(ElementByPath(e, 'Keywords\KWDA'), 'SOS_Revealing');
    AssertInList(ElementByPath(e, 'Keywords\KWDA'), 'ClothingRich');

    AddMessage(#13#10#13#10 + '==ArmorDraugrHelmet=='); 
    old := WinningOverride(FindAsset(FileByIndex(0), 'ARMO', 'ArmorDraugrHelmet'));
    e := FurrifyArmorRecord(old);
    aa := WinningOverride(FindAsset(Nil, 'ARMA', 'DraugrHelmetAA'));
    AssertEQ(ElementListNameCount(ElementByPath(aa, 'Additional Races'), 'NordRace'), 0, 
        Format('NordRace removed from %s addon', [EditorID(aa)]));

    FurrifyArmorsFinish;
end;


{ ======================================================================
Test system functions to demonstrate correct use.
}
Function TestByVar(var j: integer): integer;
begin
    j := 1;
end;

Procedure TestSystemFunc;
var
    a: string;
    a0, a1, a2, arma, armo, hr: IwbMainRecord;
    alpha: array[0..2] of string;
    b: string;
    dynlist: array of Integer;
    e: IwbMainRecord;
    ffo: IwbFile;
    fo4: IwbFile;
    i: integer;
    listofints: TStringList;
    sk: TSkinTintLayer;
    sl1, slsub, sl2: TStringList;
    t, t2: TDateTime;
    tend: float;
    teti: string;
    xf: TTransform;
    p: IwbElement;
    pc: IwbElement;
    tintAsset, tintAssetList: IwbElement;
    tintLayer: IwbElement;
    tintPresetlist: IwbElement;
    tintPreset: IwbElement;
    tintMaskList: IwbElement;
begin
    // // Cannot use dynamic lists--the following does not compile.
    // SetLength(dynlist, 5);
    // dynlist[4] := 4;
    // AssertInt(dynlist[4], 4, 'Can use dynamic list');
    e := FindAsset(FileByIndex(0), 'NPC_', 'AcolyteJenssen');

    // How to access the sex flag
    AddMessage('Sex: ' + IntToStr(GetElementNativeValues(e, 'ACBS\Flags') and 1));
    AddMessage('EditorID: ' + EditorID(LinksTo(ElementByPath(e, 'RNAM'))));
    
    // Can read the data size like any other field
    AddMessage('Data size: ' + IntToStr(GetElementEditValues(e, 'Record Header\Data Size')));

    // 
    AddMessage('--');
    RandomizeIndexList('alpha', 1234, 5);
    for i := 0 to indexList.Count-1 do AddMessage(Format('Index [%s] %s - %d', [
        IntToStr(i), indexList[i], Integer(indexList.objects[i])]));
    AddMessage('--');
    RandomizeIndexList('beta', 4567, 5);
    for i := 0 to indexList.Count-1 do AddMessage(Format('Index [%s] %s - %d', [
        IntToStr(i), indexList[i], Integer(indexList.objects[i])]));
    AddMessage('--');
    RandomizeIndexList('delta', 148, 5);
    for i := 0 to indexList.Count-1 do AddMessage(Format('Index [%s] %s - %d', [
        IntToStr(i), indexList[i], Integer(indexList.objects[i])]));
    AddMessage('--');
    RandomizeIndexList('gamma', 1148, 5);
    for i := 0 to indexList.Count-1 do AddMessage(Format('Index [%s] %s - %d', [
        IntToStr(i), indexList[i], Integer(indexList.objects[i])]));
    AddMessage('--');
    RandomizeIndexList('upsilon', 3333, 5);
    for i := 0 to indexList.Count-1 do AddMessage(Format('Index [%s] %s - %d', [
        IntToStr(i), indexList[i], Integer(indexList.objects[i])]));
    AddMessage('--');

    // can pass variables by var BUT NOT record by var.
    i := 0;
    TestByVar(i);
    AssertInt(i, 1, 'Can pass integer by reference');

    listofints := TStringList.Create;
    listofints.AddObject('a', 1);
    AssertInt(Integer(listofints.objects[0])+1, 2, 'TStringList holds ints');

    // DOES NOT COMPILE
    // TestRecByVar(xf);
    // AssertInt(xf.z, 3.0, 'Can pass record by reference');

    // Can write time values
    t := Now;
    AddMessage('Current time is ' + TimeToStr(Time));
    
    AddMessage(Format('Can format decimal values: %d', [10]));
    AddMessage(Format('Can format hex values: %.8x', [1023]));
    AddMessage(Format('Can format float values: %f', [10.23]));

    // MatchText throws an access violation
    // alpha[0] := 'A';
    // alpha[1] := 'B';
    // alpha[2] := 'C';
    // AddMessage(IfThen(MatchText('B', alpha), 'B Matches', 'B does not match'));
    // AddMessage(IfThen(MatchText('X', alpha), 'X Matches', 'X does not match'));

    // Can use StringLists of StringLists.
    AddMessage('Demo of stringlists');
    sl1 := TStringList.Create;

    slsub := TStringList.Create;
    slsub.Add('One');
    slsub.Add('Two');
    sl1.AddObject('Alpha', slsub);
    sl1.objects[0].Add('Three');
    slsub := TStringList.Create;

    slsub.Add('A');
    slsub.Add('B');
    sl1.AddObject('Beta', slsub);
    AddMessage(Format('Get SL strings: %s', [sl1.commatext]));
    AddMessage(Format('Index SL by text (Alpha): %d', [integer(sl1.values['Alpha'])])); // This does NOT work
    AddMessage(Format('Index SL by text (Beta): %d', [integer(sl1.values['Beta'])])); // This does NOT work

    sl2 := sl1.objects[0];
    AddMessage(Format('First list has sublist: %s', [sl2.commatext])); // This works
    AddMessage(Format('First subentry is %s', [sl2[0]]));
    AddMessage(Format('First entry in sl1: %s, size %d', [sl1[0], sl1.objects[0].count]));
    AddMessage(Format('First subentry in sl1: %s, "%s"', [sl1[0], TList(sl1.objects[0]).commatext])); // This works
    AddMessage(Format('First subentry in sl1: %s, "%s"', [sl1[0], TList(sl1.objects[0]).strings[0]])); // This works
    AddMessage(Format('First subentry in sl1[1]: %s, "%s"', [sl1[1], TList(sl1.objects[1]).strings[0]])); // This works

    // DOESNT WORK: No way I can find to put records in a TStringList
    // sl1 := TStringList.Create;
    // sk.name := 'TEST';
    // sl1.AddObject('test', sk);
    // sk.name := 'FOO';
    // AddMessage(sk.name);
    // AddMessage(sl1[0]);
    // AddMessage(sl1.objects[0].name);

    // DOESNT WORK: AddPair is not implemented.
    // sl1 := TStringList.Create;
    // sl1.AddPair('foo', 1);
    // sl1.AddPair('bar', 2);
    // AddMessage(Format('First pair: %s / %s', [sl1[0], sl1.values[0]]));
    // AddMessage(Format('Second pair: %s / %s', [sl1[1], sl1.values[1]]));

    // Can associate strings with values.
    sl1 := TStringList.Create;
    sl1.AddObject('foo', 1);
    sl1.AddObject('bar', 2);
    for i := 0 to sl1.Count-1 do begin
        AddMessage(Format('Integer value [%d]: %s / %s', [
            i, sl1[i], IntToStr(sl1.objects[i])]));
    end;

    // HighestOverrideOrSelf index use
    // Check behavior when there are overrides.
    armo := FindAsset(FileByIndex(0), 'ARMO', 'ArmorFalmerBoots');
    // HighestOverrideOrSelf returns the indexed override.
    a0 := HighestOverrideOrSelf(armo, 0);
    Assert(GetFileName(GetFile(a0)) = 'Skyrim.esm', 'Base record in Skyrim.esm');
    a1 := HighestOverrideOrSelf(armo, 1);
    Assert(GetFileName(GetFile(a1)) = 'Update.esm', 'First override in Update.esm');
    a2 := HighestOverrideOrSelf(armo, 100);
    AssertStr(GetFileName(GetFile(a2)), 'unofficial skyrim special edition patch.esp', 
        'HighestOverrideOrSelf will return winning override with a large integer');
    AssertStr(GetFileName(GetFile(WinningOverride(armo))), 'unofficial skyrim special edition patch.esp', 
        'WinningOverride returns highest override');
    Assert(not IsWinningOverride(armo), 'Skrim.esm/ArmorFalmerBoots is not winning override');
    Assert(not HasNoOverride(armo), 'ArmorFalmerBoots has an override');
    AssertGT(OverrideCount(armo), 1, Format('%s has correct overrides', [PathName(armo)]));
    AssertInt(OverrideCount(a1), 0, Format(
        'OverrideCount does NOT work correctly when given an overriding record. %s has one override, but returns 0', 
        [PathName(a1)]));
    AssertInt(OverrideCount(a2), 0, Format('%s has no overrides', [PathName(a2)]));

    // Check behavior when no override
    hr := FindAsset(FileByIndex(0), 'RACE', 'ChaurusRace');
    // HighestOverrideOrSelf returns the record itself if no override exists, no matter what the index.
    Assert(GetFileName(GetFile(HighestOverrideOrSelf(hr, 0))) = 'Skyrim.esm', 'ChaurusRace highest override is Skyrim.esm');
    Assert(GetFileName(GetFile(HighestOverrideOrSelf(hr, 100))) = 'Skyrim.esm', 'ChaurusRace highest override is Skyrim.esm');
    // WinningOverride returns the record itself if no override exists.
    Assert(GetFileName(GetFile(WinningOverride(hr))) = 'Skyrim.esm', 'ChaurusRace winning override is Skyrim.esm');
    // IsWinningOverride returns TRUE if there are no overrides.
    Assert(IsWinningOverride(hr), 'IsWinningOverride shows that Skyrim.esm/ChaurusRace is winning override');
    // Our own HasNoOverride function correctly returns TRUE if there are no overrides.
    Assert(HasNoOverride(hr), 'ChaurusRace has no override');

    AddMessage('Version number checking');
    AddMessage(Format('xEdit Version %s.%s.%s.%s', [
        IntToStr(xEditMajor), IntToStr(xEditMinor), IntToStr(xEditUpdate), xEditUpdate2]));
    AddMessage(Format('4.0.7a <> xEdit: %s', [IntToStr(XEditVersionCompare(4, 0, 7, 'a'))]));
    AddMessage(Format('4.1.5t <> xEdit: %s', [IntToStr(XEditVersionCompare(4, 1, 5, 't'))]));
    AddMessage(Format('4.1.5m <> xEdit: %s', [IntToStr(XEditVersionCompare(4, 1, 5, 'm'))]));

    // How Hash operates
    AddMessage('Hash(EncBandit03Melee1HTankRedguardF) = ' + IntToStr(Hash('EncBandit03Melee1HTankRedguardF', 1234, 10)));
    AddMessage('Hash(EncBandit03Melee1HTankRedguardM) = ' + IntToStr(Hash('EncBandit03Melee1HTankRedguardM', 1234, 10)));
    AddMessage('Hash(EncBandit04Melee1HTankRedguardF) = ' + IntToStr(Hash('EncBandit04Melee1HTankRedguardF', 1234, 10)));
    AddMessage('Hash(EncBandit04Melee1HTankRedguardM) = ' + IntToStr(Hash('EncBandit04Melee1HTankRedguardM', 1234, 10)));
    AddMessage('Hash(EncBandit03) = ' + IntToStr(Hash('EncBandit03', 1234, 10)));
    AddMessage('Hash(EncBandit04) = ' + IntToStr(Hash('EncBandit04', 1234, 10)));
    AddMessage('Hash(EncBandit05) = ' + IntToStr(Hash('EncBandit05', 1234, 10)));

    // How to read bodypart flags. They have to be read DIFFERENTLY depending on form version.
    AddMessage('---Reading bodypart flags---');
    arma := FindAsset(FileByIndex(0), 'ARMA', 'DraugrGlovesAA');
    i := GetElementNativeValues(arma, 'Record Header\Form Version');
    AssertInt(i, 40, 'Form version');
    AddMessage(Format('%s bodypart flags: $%s', [
        Name(arma), IntToHex(GetElementNativeValues(arma, 'BODT\First Person Flags'), 8)]));
    Assert(GetElementNativeValues(arma, 'BODT\First Person Flags\31 - Hair') = 0, 
        Format('%s has hair bit clear', [EditorID(arma)]));
    Assert(GetElementNativeValues(arma, 'BODT\First Person Flags\33 - Hands') <> 0, 
        Format('%s has hands bit set', [EditorID(arma)]));
    Assert((GetBodypartFlags(arma) and BP_HANDS) <> 0, 
        Format('%s has hands bit set', [EditorID(arma)]));
    Assert((GetBodypartFlags(arma) and BP_HAIR) = 0, 
        Format('%s has hair bit clear', [EditorID(arma)]));
        
    arma := FindAsset(FileByIndex(0), 'ARMA', 'MythicDawnHoodAA');
    AddMessage(Format('%s bodypart flags: $%s', [
        Name(arma), IntToHex(GetElementNativeValues(arma, 'BODT\First Person Flags'), 8)]));
    Assert(GetElementNativeValues(arma, 'BODT\First Person Flags\31 - Hair') <> 0, 
        Format('%s has hair bit clear', [EditorID(arma)]));
    Assert(GetElementNativeValues(arma, 'BODT\First Person Flags\33 - Hands') = 0, 
        Format('%s has hands bit set', [EditorID(arma)]));
        
    // Thieves guild hood in Update.esm has form version 44. Make sure we can read it.
    arma := FindAsset(FileByIndex(2), 'ARMA', 'ThievesGuildHelmetAA');
    i := Integer(GetElementNativeValues(arma, 'Record Header\Form Version'));
    AssertInt(i, 44, 'Form version');
    AddMessage(Format('%s bodypart flags: $%s', [
        Name(arma), IntToHex(GetElementNativeValues(arma, 'BOD2\First Person Flags'), 8)]));
    Assert(GetElementNativeValues(arma, 'BOD2\First Person Flags\31 - Hair') <> 0, 
        Format('%s has hair bit set', [EditorID(arma)]));
    Assert(GetElementNativeValues(arma, 'BOD2\First Person Flags\33 - Hands') = 0, 
        Format('%s has hands bit clear', [EditorID(arma)]));
    Assert((GetBodypartFlags(arma) and BP_HAIR) <> 0, 
        Format('%s has hair bit set', [EditorID(arma)]));
    Assert((GetBodypartFlags(arma) and BP_HANDS) = 0, 
        Format('%s has hair bit clear', [EditorID(arma)]));

    arma := WinningOverride(FindAsset(nil, 'ARMA', 'DragonplateGauntletsAA'));
    i := Integer(GetElementNativeValues(arma, 'Record Header\Form Version'));
    AssertInt(i, 43, 'Form version');
    AddMessage(Format('%s bodypart flags: $%s', [
        Name(arma), IntToHex(GetElementNativeValues(arma, 'BODT\First Person Flags'), 8)]));
    AssertInt(GetElementNativeValues(arma, 'BODT\First Person Flags\31 - Hair'), 0, 
        'hair bit clear');
    AssertInt(GetElementNativeValues(arma, 'BODT\First Person Flags\33 - Hands') and 1, 1, 
        'hands bit set');
    AssertInt((GetBodypartFlags(arma) and BP_HAIR), 0, 'hair bit clear');
    AssertInt((GetBodypartFlags(arma) and BP_HANDS), BP_HANDS, 'hands bit set');

    arma := FindAsset(nil, 'ARMA', 'ElderScrollHandAttachAA3rdP');
    i := Integer(GetElementNativeValues(arma, 'Record Header\Form Version'));
    AssertInt(i, 43, 'Form version');
    AddMessage(Format('%s bodypart flags: $%s', [
        Name(arma), IntToHex(GetElementNativeValues(arma, 'BODT\First Person Flags'), 8)]));
    AssertInt(GetElementNativeValues(arma, 'BODT\First Person Flags\31 - Hair'), 0, 
        'hair bit clear');
    AssertInt(GetElementNativeValues(arma, 'BODT\First Person Flags\33 - Hands'), 0, 
        'hands bit clear');
    i := Integer(GetBodypartFlags(arma));
    AddMessage('assignment worked');
    AssertInt((GetBodypartFlags(arma) and BP_HAIR), 0, 'hair bit clear');
    AssertInt((GetBodypartFlags(arma) and BP_HANDS), 0, 'hands bit clear');

    // xEdit keeps fucking with paths. Testing to see we can still read them.
    AddMessage('Pathname tests');
    e := FindAsset(FileByIndex(0), 'RACE', 'NordRace');
    tintMaskList := ElementByPath(e, 'Head Data\Male Head Data\Tint Masks');
    Assert(Assigned(tintMaskList), 'Can find tint mask list: ' + PathName(tintMaskList));
    AddMessage('Tint mask [0]: ' + PathName(ElementByIndex(tintMaskList, 0)));
    AddMessage('Tint mask [1]: ' + PathName(ElementByIndex(tintMaskList, 1)));

    tintAsset := ElementByIndex(tintMaskList, 1);

    tintLayer := ElementByPath(tintAsset, 'Tint Layer');
    Assert(Assigned(tintLayer), 'Can find tint asset 0: ' + PathName(tintLayer));
    AssertEQ(GetNativeValue(ELementByPath(tintLayer, 'TINI')), 2, 'Can read TINI');
    AssertStr(GetEditValue(ELementByPath(tintLayer, 'TINT')), 
        'Actors\Character\Character Assets\TintMasks\MaleUpperEyeSocket.dds', 
        'Can read TINT');

    tintPresetList := ElementByPath(tintAsset, 'Presets');
    Assert(Assigned(tintPresetList), 'Can read tint asset preset list' + PathName(tintPresetList));

    tintPreset := ELementByIndex(tintPresetList, 2);
    AssertStr(GetELementEditValues(tintPreset, 'TINC'), 'RedTintAverage*',
        'Preset color');
end;


//==================================================================
//==================================================================
//
function Initialize: integer;
var 
    i: integer;
    rec: IwbMainRecord;
    g: IwbGroupRecord;
begin
    AddMessage(' ');
    AddMessage(' ');
    AddMessage('====================================');
    AddMessage('============ TESTING ===============');
    AddMessage('====================================');
    AddMessage(' ');
    testErrorCount := 0;

    InitializeLogging;
    LOGGING := True;
    LOGLEVEL := 20;
    PreferencesInit;
    result := 0;

    AddMessage('Clearing out old records from ' + TEST_FILE_NAME);
    targetFileIndex := FindFile(TEST_FILE_NAME);
    if targetFileIndex >= 0 then begin
        targetFile := FileByIndex(targetFileIndex);
        for i := RecordCount(targetFile) - 1 downto 0 do begin
            rec := RecordByIndex(targetFile, i);
            if (Signature(rec) = 'FLST') 
                or (Signature(rec) = 'NPC_') 
                or (Signature(rec) = 'RACE')  
                or (Signature(rec) = 'GLOB') 
                or (Signature(rec) = 'ARMA') 
                or (Signature(rec) = 'ARMO') 
            then  
                Remove(rec);
        end;
    end;

    clearmessages;
end;

function Process(entity: IwbMainRecord): integer;
begin
    result := 0;
end;


function Finalize: integer;
begin
    targetFileIndex := FindFile(TEST_FILE_NAME);
    if targetFileIndex < 0 then begin
        targetFile := AddNewFileName(TEST_FILE_NAME);
        targetFileIndex := GetLoadOrder(targetFile);
        LogT('Creating file ' + GetFileName(targetFile));
    end
    else 
        targetFile := FileByIndex(targetFileIndex);
    LogD(Format('Found target file at %d', [targetFileIndex]));

    TestSystemFunc;

    LOGGING := TRUE;
    SetPreferences;
    // ShowRaceAssignments;
    FurrifyAllRaces;
    ShowRaceTints;
    TestRaces;

    FurrifyHeadpartLists;
    // ShowHeadparts;
    // CollectArmor;
    // ShowArmor;

    LOGGING := True;
    if TEST_NPCS then TestNPCs;
    if TEST_ARMOR then TestArmor;
    if TEST_SCHLONGS then TestSchlongs;

    AddMessage(Format('============ TESTS COMPLETED %s ===============',
        [IfThen((testErrorCount > 0), 
            'WITH ' + IntToStr(testErrorCount) + ' ERRORS',
            'SUCCESSFULLY')]));

    PreferencesFree;
    result := 0;
end;

end.
