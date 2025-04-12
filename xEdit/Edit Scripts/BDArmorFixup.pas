{
Fixes all armor in the load order.

Adds furry armor addons to armors for races that have been furrified.

Merges keyword lists across an armor's overrides.
}
unit BDArmorFixup;
interface
implementation
uses BDFurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

{===================================================================
Determine whether the given armor addon needs to be furrified: It's a furrifiable bodypart
and is valid for races that are being furrified. Returns the furrified races on this addon
in addonFurrifiedRaces (which the caller must initialze).
}
function AAIsFurrifiable(addon: IwbMainRecord): boolean;
var
    i: integer;
    addlRaces: IwbElement;
    raceName: string;
begin
    if LOGGING then LogEntry1(15, 'AAIsFurrifiable', EditorID(addon));
    result := false;

    // Is it a furrifiable bodypart?
    bipedFlags := ElementByPath(addon, 'BOD2 - Biped Body Template\First Person Flags');
    if Assigned(bipedFlags) then begin
        result := (GetElementNativeValues(bipedFlags, 'Hair') <> 0)
            or (GetElementNativeValues(bipedFlags, 'LongHair') <> 0)
            or (GetElementNativeValues(bipedFlags, 'Hands') <> 0);
    end;

    // If it is, does it cover a furrified race?
    addlRaces := ElementByPath(addon, 'Additional Races');
    for i := -1 to ElementCount(addlRaces)-1 do begin
        if i < 0 then raceName := EditorID(LinksTo(ElementByPath(addon, 'RNAM')))
        else raceName := EditorID(LinksTo(ElementByIndex(addlRaces, i)));
        if raceAssignments.IndexOf(raceName) >= 0 then begin
            addonFurrifiedRaces.AddObject(raceName, vanillaRaces.objects[vanillaRaces.IndexOf(raceName)]);
            result := True;
        end;
    end;

    if LOGGING then LogExitT1('AAIsFurrifiable', BoolToStr(result));
end;


{===================================================================
Determine whether the given addon is valid for the given race.
}
function AARacesMatch(addon: IwbMainRecord; race: IwbMainRecord): boolean;
var
    addList: IwbElement;
    i: integer;
    rn: string;
begin
    if LOGGING then LogEntry2(15, 'AARacesMatch', EditorID(addon), EditorID(race));
    result := false;
    rn := EditorID(LinksTo(ElementByPath(addon, 'RNAM')));
    if LOGGING then LogD(Format('Comparing %s =? %s', [rn, EditorID(race)]));
    if rn = EditorID(race) then result := true;
    if not result then begin
        addList := ElementByPath(addon, 'Additional Races');
        for i := 0 to ElementCount(addList)-1 do begin
            rn := EditorID(LinksTo(ElementByIndex(addList, i)));
            result := (rn = EditorID(race));
            if result then break;
        end;
    end;
    if LOGGING then LogExitT1('AARacesMatch', BoolToStr(result));
end;


// {===================================================================
// Compare bodypart flags and return true if any flags match.
// }
// function AABodypartsMatch(addon1, addon2: IwbMainRecord): boolean;
// var
//     addonBodyparts1, addonBodyparts2: IwbMainRecord;
// begin
//     if LOGGING then LogEntry2(15, 'AABodypartsMatch', PathName(addon1), PathName(addon2));
//     // result := true;
//     // addonBodyparts1 := ElementByPath(addon1, '[2]\[0]');
//     // addonBodyparts2 := ElementByPath(addon2, '[2]\[0]');
//     // result := ((GetNativeValue(addonBodyparts1) and GetNativeValue(addonBodyparts2)) <> 0);
//     result := ((GetBodypartFags(addon1) and GetBodypartFags(addon2)) <> 0);
//     if LOGGING then LogExitT1('AABodypartsMatch', BoolToStr(result));
// end;


{===================================================================
Find the armor addon listed in an armor record that matches a given race and covers the
given bodyparts.
}
function FindMatchingAddon(armor: IwbMainRecord; targetAddon: IwbMainRecord; race: IwbMainRecord): IwbMainRecord;
var
    aaList: IwbElement;
    i: integer;
    addon: IwbMainRecord;
begin
    if LOGGING then LogEntry3(10, 'FindMatchingAddon', EditorID(armor), EditorID(targetAddon), EditorID(race));
    result := nil;
    aaList := ElementByPath(armor, 'Armature');
    for i := 0 to ElementCount(aaList) - 1 do begin
        addon := WinningOverride(LinksTo(ElementByIndex(aaList, i)));
        if EditorID(addon) <> EditorID(targetAddon) then begin
            if AARacesMatch(addon, race) 
                and ((GetBodypartFags(addon) and GetBodypartFags(targetAddon)) <> 0)
            then begin
                result := addon;
                break;
            end;
        end;
    end;
    if LOGGING then LogExitT1('FindMatchingAddon', EditorID(result));
end;


{===================================================================
Find the armor addon with the shortest name for the given armor record. If multiple addons
have the same shortest name length, return the one that comes first alphabetically.
}
function AddonRootName(armor: IwbMainRecord): string;
var
    aaList: IwbElement;
    i: integer;
    addon: IwbMainRecord;
    shortestAddon: IwbMainRecord;
    shortestName: string;
begin
    if LOGGING then LogEntry1(5, 'AddonRootName', Name(armor));
    result := nil;
    shortestAddon := nil;
    shortestName := '';

    aaList := ElementByPath(armor, 'Armature');
    for i := 0 to ElementCount(aaList) - 1 do begin
        addon := WinningOverride(LinksTo(ElementByIndex(aaList, i)));
        if Assigned(addon) then begin
            if (not Assigned(shortestAddon)) or 
               (Length(EditorID(addon)) < Length(shortestName)) or 
               ((Length(EditorID(addon)) = Length(shortestName)) 
                    and (CompareText(EditorID(addon), shortestName) < 0)) 
            then begin
                shortestAddon := addon;
                shortestName := EditorID(addon);
            end;
        end;
    end;

    result := shortestName;
    if LOGGING then LogExitT1('AddonRootName', result);
end;


{===================================================================
Find the furry armor addon that works for the given race and is a valid replacement for
the given addon (same bodyparts).

    Return the furry version of the AA specific to this race
        or a furry version specific to the race class (DOG)
        or a khajiit addon already on the armor
}
function FindFurryAddon(race: IwbMainRecord; armor, addon: IwbMainRecord): IwbMainRecord;
var
    classIdx: integer;
    defIdx: Integer;
    furRace: IwbMainRecord;
    furRaceName: string;
    racei: integer;
    rootName: string;
    targetName: string;
    targIdx: integer;
begin
    if LOGGING then LogEntry3(5, 'FindFurryAddon', EditorID(race), EditorID(armor), EditorID(addon));
    result := nil;
    
    rootName := AddonRootName(armor);

    // Find an addon for this race specifically
    targetName := 'YA_' + rootname + '_' + EditorID(race);
    targIdx := allAddons.IndexOf(targetName);
    if LOGGING then LogD('Found specific addon: ' + targetName + ' at ' + IntToStr(targIdx));
    if targIdx >= 0 then begin
        result := ObjectToElement(allAddons.objects[targIdx]);
    end;
    if not Assigned(result) then begin
        // Find an addon for this race class
        racei := raceAssignments.IndexOf(EditorID(race));
        furRace := ObjectToElement(raceAssignments.objects[racei]);
        furRaceName := EditorID(furRace);
        if LOGGING then LogD(Format('Associated furry race: [%d] %s', [racei, furRaceName]));
        classIdx := furryRaceClass.IndexOfName(furRaceName);
        if classIdx >= 0 then begin
            targetName := 'YA_' + rootname + '_' + furryRaceClass.ValueFromIndex[classIdx];
            targIdx := allAddons.IndexOf(targetName);
            if LOGGING then LogD('Found class addon: ' + targetName + ' at ' + IntToStr(targIdx));
            if targIdx >= 0 then begin
                result := ObjectToElement(allAddons.objects[targIdx]);
            end;
        end;
    end;
    if not Assigned(result) then begin
        defIdx := furryRaces.IndexOf(armorRaces.values[furRaceName]);
        if LOGGING then LogD(Format('Found armor race: [%d] %s', [defIdx, armorRaces.values[furRaceName]]));
        if defIdx >= 0 then begin
            result := FindMatchingAddon(armor, addon, ObjectToElement(furryRaces.objects[defIdx]));
        end;
    end;

    if LOGGING then LogExitT1('FindFurryAddon', EditorID(result));
end;


{===================================================================
Remove a race from an armor addon. Returns the addon as modified (may be an override).
}
function RemoveAddonRace(addon: IwbMainRecord; race: IwbMainRecord): IwbMainRecord;
var
    addList: IwbElement;
    r: IwbMainRecord;
    i: integer;
    j: integer;
begin
    if LOGGING then LogEntry2(10, 'RemoveAddonRace', EditorID(addon), EditorID(race));
    addList := ElementByPath(addon, 'Additional Races');
    
    if GetLoadOrder(GetFile(addon)) < targetFileIndex then begin
        for i := ElementCount(addList)-1 downto -1 do begin
            if i < 0 then r := LinksTo(ElementByPath(addon, 'RNAM'))
            else r := LinksTo(ElementByIndex(addList, i));
            if LOGGING then LogD(Format('[%d] Checking addon race %s %s', [
                i, EditorID(r), IfThen(EditorID(r) = EditorID(race), '(remove)', '')]));

            if EditorID(r) = EditorID(race) then begin
                // Need to override 
                addon := MakeOverride(addon, targetFile);
                j := allAddons.IndexOf(EditorID(addon));
                if j < 0 then begin
                    Err(Format('Addon %s not found in addon list', [Name(addon)]));
                    allAddons.AddObject(EditorID(addon), addon);
                end
                else
                    allAddons.objects[j] := addon;
                addlist := ElementByPath(addon, 'Additional Races');

                if i < 0 then AssignElementRef(ElementByPath(addon, 'RNAM'), defaultRace)
                else RemoveByIndex(addList, i, false);
            end;
        end;
    end;

    result := addon;
    if LOGGING then LogExitT1('RemoveAddonRace', FullPath(result));
end;


{===================================================================
Add a race to an armor addon if it's not already there.
}
function AddAddonRace(addon: IwbMainRecord; race: IwbMainRecord): IwbMainRecord;
    var
        addList, newEle: IwbElement;
        i: integer;
begin
    if LOGGING then LogEntry2(10, 'AddAddonRace', EditorID(addon), EditorID(race));

    addon := AddToList(addon, 'Additional Races', race, targetFile);
    i := allAddons.IndexOf(EditorID(addon));
    if i < 0 then begin
        Err(Format('Addon %s not found in addon list', [Name(addon)]));
        allAddons.AddObject(EditorID(addon), addon);
    end
    else
        allAddons.objects[i] := addon;

    result := addon;
    if LOGGING then LogExitT1('AddAddonRace', FullPath(result));
end;


{===================================================================
Add an armor addon to an armor record if it's not already there.
}
function AddArmorAddon(armor: IwbMainRecord; addon: IwbMainRecord): IwbMainRecord;
var
    aaList: IwbElement;
    i: integer;
    exists: boolean;
begin
    if LOGGING then LogEntry2(5, 'AddArmorAddon', Name(armor), Name(addon));
    begin
        exists := false;
        aaList := ElementByPath(armor, 'Armature');
        for i := 0 to ElementCount(aaList)-1 do begin
            if EditorID(LinksTo(ElementByIndex(aaList, i))) = EditorID(addon) then begin
                exists := true;
                break;
            end;
        end;

        if not exists then begin
            if GetLoadOrder(GetFile(armor)) < targetFileIndex then begin
                armor := MakeOverride(armor, targetFile);
                furrifiableArmors.objects[furrifiableArmors.IndexOf(EditorID(armor))] := armor;
                aaList := ElementByPath(armor, 'Armature');
            end;
            ElementAssign(aaList, HighInteger, nil, false);
            // SetEditValue(ElementByIndex(aaList, ElementCount(aaList)-1), Name(addon));
            AssignElementRef(ElementByIndex(aaList, ElementCount(aaList)-1), addon);
        end;
        result := armor;
    end;
    if LOGGING then LogExitT1('AddArmorAddon', Name(addon));
end;


{===================================================================
Furrify a single armor record.
}
procedure FurrifyArmorRecord(armorIdx: cardinal);
var
    aaIdx: cardinal;
    aaList: IwbContainer;
    addlRaces: IwbElement;
    altAA: IwbMainRecord;
    faIdx: cardinal;
    i: integer;
    raceIdx: cardinal;
    raceName: string;
    thisAA: IwbMainRecord;
    thisArmor: IwbMainRecord;
    thisRace: IwbMainRecord;
begin
    if LOGGING then LogEntry2(5, 'FurrifyArmorRecord', IntToStr(armorIdx), furrifiableArmors[armorIdx]);
    thisArmor := ObjectToElement(furrifiableArmors.objects[armorIdx]);

    // Walk through the armor's addons looking for furrifiable addons.
    aaList := ElementByPath(thisArmor, 'Armature');
    for aaIdx := ElementCount(aaList)-1 downto 0 do begin
        thisAA := WinningOverride(LinksTo(ElementByIndex(aaList, aaIdx)));
        if LOGGING then LogD('Checking addon ' + EditorID(thisAA));

        faIdx := addonRaces.IndexOf(EditorID(thisAA));
        if Assigned(thisAA) and (faIdx >= 0) then begin

            for raceIdx := 0 to addonRaces.objects[faIdx].count-1 do begin
                thisRace := ObjectToElement(addonRaces.objects[faIdx].objects[raceIdx]);

                if raceAssignments.IndexOf(EditorID(thisRace)) >= 0 then begin
                    // Furry races are in the list too, so ignore them.
                    if LOGGING then LogD(Format('[%d] %s has race %s', [
                        raceIdx, EditorID(thisAA), EditorID(thisRace)]));

                    altAA := FindFurryAddon(thisRace, thisArmor, thisAA);
                    if Assigned(altAA) then begin
                        if LOGGING then LogD(Format('Substituting AA %s with %s for race %s', 
                            [EditorID(thisAA), EditorID(altAA), EditorID(thisRace)]));
                        thisAA := RemoveAddonRace(thisAA, thisRace);
                        altAA := AddAddonRace(altAA, thisRace);
                        thisArmor := AddArmorAddon(thisArmor, altAA);
                    end;
                end;
            end;
        end;
    end;
    if LOGGING then LogExitT('FurrifyArmorRecord');
end;


{===================================================================
Add the winning override of the given armor addon to allAddons if not already present.
}
procedure RecordAddon(addon: IwbMainRecord);
var
    e: string;
begin
    if LOGGING then LogEntry1(20, 'RecordAddon', Name(addon));

    addon := WinningOverride(addon);
    e := EditorID(addon);

    if allAddons.IndexOf(e) < 0 then begin
        allAddons.AddObject(e, addon);
        if LOGGING then LogD(Format('Added addon %s to allAddons', [e]));
    end
    else 
        if LOGGING then LogD(Format('Addon %s already exists in allAddons', [e]));

    if LOGGING then LogExitT1('RecordAddon', IntToStr(allAddons.count));
end;


{===================================================================
Determine whether the given addon is furrifiable or furry. Furrifiable if it is valid for
a race being furrified; furry if it is valid for a furry race.
}
function IsFurryAddon(addon: IwbMainRecord): integer;
var
    racesList: IwbElement;
    raceIdx: integer;
    race: IwbMainRecord;
begin
    if LOGGING then LogEntry1(20, 'IsFurryAddon', Name(addon));

    addon := WinningOverride(addon);

    if allAddons.IndexOf(EditorID(addon)) < 0 then begin
        if LOGGING then LogD('Not checked already');
        result := IS_NONE;

        // if LOGGING then LogD(Format('%s is hair: %d', [EditorID(addon), Integer(GetElementNativeValues(addon, 'BODT\First Person Flags\31 - Hair'))]));
        // if LOGGING then LogD(Format('%s is hands: %d', [EditorID(addon), Integer(GetElementNativeValues(addon, 'BODT\First Person Flags\33 - Hands'))]));
        
        if ((GetBodypartFlags(addon) and BP_HAIR) <> 0) 
            or ((GetBodypartFlags(addon) and BP_HANDS) <> 0) 
        then begin
            // Hands and hair are furrifiable bodyparts.
            if LOGGING then LogD('Is hands or hair');
            allAddons.AddObject(EditorID(addon), addon);

            racesList := ElementByPath(addon, 'Additional Races');
            for raceIdx := -1 to ElementCount(racesList)-1 do begin
                if raceIdx < 0 then race := WinningOverride(LinksTo(ElementByPath(addon, 'RNAM')))
                else race := WinningOverride(LinksTo(ElementByIndex(racesList, raceIdx)));

                if raceAssignments.IndexOf(EditorID(race)) >= 0 then begin
                    // Is a furried race, so is furrifiable addon.
                    if LOGGING then LogD('Is furrifiable: ' + EditorID(race));
                    result := result or IS_FURRIFIABLE;
                end;

                if furryRaces.IndexOf(EditorID(race)) >= 0 then begin
                    if LOGGING then LogD('Is furry: ' + EditorID(race));
                    result := result or IS_FURRY;
                end;

                if (result and (IS_FURRY or IS_FURRIFIABLE)) = (IS_FURRY or IS_FURRIFIABLE) then
                    // Once we've set both bits no need to look farther.
                    break;
            end;
        end;
    end
    else
        result := IS_ALREADY_TESTED;
        
    if LOGGING then LogExitT1('IsFurryAddon', IntToStr(result));
end;


{===================================================================
Check the addon for furrified races; if it has any then add it to the list of
furrifiable addons, along with the furrified races it's good for.
}
function RecordFurryAddon(addon: IwbMainRecord): boolean;
var
    racesList: IwbElement;
    raceIdx: integer;
    race: IwbMainRecord;
    isf: integer;
begin
    if LOGGING then LogEntry1(20, 'RecordFurryAddon', Name(addon));
    addon := WinningOverride(addon);

    isf := IsFurryAddon(addon);
    if (isf and (IS_FURRIFIABLE or IS_FURRY)) <> 0 then begin
        // Record addon and all races it is valid for.
        racesList := ElementByPath(addon, 'Additional Races');
        for raceIdx := -1 to ElementCount(racesList)-1 do begin
            if raceIdx < 0 then race := WinningOverride(LinksTo(ElementByPath(addon, 'RNAM')))
            else race := WinningOverride(LinksTo(ElementByIndex(racesList, raceIdx)));
            if LOGGING then LogD(Format('Found race %s', [EditorID(race)]));

            if Assigned(race) then begin
                // Only add the race if it's relevant to furrification
                if (raceAssignments.IndexOf(EditorID(race)) >= 0)
                    or (furryRaces.IndexOf(EditorID(race)) >= 0)
                then begin
                    if addonRaces.IndexOf(EditorID(addon)) < 0 then begin
                        addonRaces.AddObject(EditorID(addon), TStringList.Create);
                    end;
                    addonRaces.objects[addonRaces.IndexOf(EditorID(addon))].AddObject(EditorID(race), race);
                end;
            end;
        end;
    end;

    if (isf and (IS_FURRIFIABLE or IS_FURRY)) <> 0 then result := true
    else if addonRaces.IndexOf(EditorID(addon)) >= 0 then result := true
    else result := false;

    if LOGGING then LogExitT('RecordFurryAddon');
end;


{===================================================================
Collect all armor addons good for furry races.
}
procedure CollectFurryAddons;
var
    f, n, i: integer;
    addonList: IwbElement;
    addon: IwbMainRecord;
    racesList: IwbElement;
    race: IwbMainRecord;
    raceName: string;
    isFurryRace: boolean;
begin
    if LOGGING then LogEntry1(15, 'CollectFurryAddonRaces', Format('0 - %d', [targetFileIndex-1]));

    // Walk through all files
    for f := 0 to targetFileIndex - 1 do begin
        if LOGGING then LogD('Processing file: ' + GetFileName(FileByIndex(f)));

        // Walk through all armor addons in the file
        addonList := GroupBySignature(FileByIndex(f), 'ARMA');
        for n := 0 to ElementCount(addonList) - 1 do begin
            addon := ElementByIndex(addonList, n);
            if IsWinningOverride(addon) then 
                RecordFurryAddon(addon);
        end;
    end;

    if LOGGING then LogExitT('CollectFurryAddonRaces');
end;


{===================================================================
Collect all armor and armor addon records in the current load order and store them in
furrifiableArmors and addonRaces.
}
procedure CollectArmor;
var
    f: integer;
    n: integer;
    armorList: IwbElement;
    armor: IwbMainRecord;
    isFurrifiable: boolean;
    aaList: IwbElement;
    aaIdx: integer;
    addon: IwbMainRecord;
    racesList: IwbElement;
    raceIdx: integer;
    race: IwbMainRecord;
    sl: TStringList;
begin
    if LOGGING then LogEntry1(15, 'CollectArmor', Format('0 - %d', [targetFileIndex-1]));

    // Walk through all files
    for f := 0 to targetFileIndex - 1 do begin
        if LOGGING Then LogD(Format('File %s with %s armors, %s addons', 
            [GetFileName(FileByIndex(f)), IntToStr(furrifiableArmors.Count), IntToStr(addonRaces.count)]));

        // Walk through all armors in the file
        armorList := GroupBySignature(FileByIndex(f), 'ARMO');
        for n := 0 to ElementCount(armorList) - 1 do begin

            // Only process the winning override of the armor record
            armor := ElementByIndex(armorList, n);
            if IsWinningOverride(armor) then begin
                // Furrifiable armors are those that have a hair or hand bodypart flag set.
                isFurrifiable := false;
                if LOGGING then LogD(Format('Armor %s hair: %s hands %s:', 
                    [Name(armor),
                        GetElementEditValues(armor, 'BOD2\First Person Flags\31 - Hair'),
                        GetElementEditValues(armor, 'BOD2\First Person Flags\33 - Hands')]));
                if (GetElementNativeValues(armor, 'BOD2\First Person Flags\31 - Hair') <> 0) 
                    or (GetElementNativeValues(armor, 'BOD2\First Person Flags\33 - Hands') <> 0) 
                then begin
                    // Furrifiable armors must have an addon that is good for a furrified race.
                    aaList := ElementByPath(armor, 'Armature');
                    for aaIdx := 0 to ElementCount(aaList)-1 do begin
                        isFurrifiable := isFurrifiable or RecordFurryAddon(LinksTo(ElementByIndex(aaList, aaIdx)));
                    end;
                end;

                if LOGGING and isFurrifiable then LogD('Have furrifiable armor: ' + Name(armor));
                if isFurrifiable then furrifiableArmors.AddObject(EditorID(armor), armor);
            end;
        end;
    end;
    CollectFurryAddons;
    if LOGGING then LogExitT('CollectArmor');
end;


procedure ShowArmor;
var i, j: integer;
begin
    AddMessage('++++ Addon Races ++++');
    for i := 0 to addonRaces.Count-1 do begin
        if Assigned(addonRaces.objects[i]) then begin
            for j := 0 to addonRaces.objects[i].Count-1 do 
                AddMessage(Format('%s == %s', [addonRaces.strings[i], addonRaces.objects[i].strings[j]]));
        end
        else
            AddMessage(Format('%s == %s', [addonRaces.strings[i], '<NONE>']));
    end;
    AddMessage('---- Addon Races ----');
end;
