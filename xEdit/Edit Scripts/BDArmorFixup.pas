{
Fixes all armor in the load order.

Adds furry armor addons to armors for races that have been furrified.

Merges keyword lists across an armor's overrides.
}
unit BDArmorFixup;
interface
implementation
uses BDFurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    UNOFFICIAL_PATCH ='unofficial skyrim special edition patch.esp';

var
    // Global variables to handle creating a furrified armor that merges prior overrides.
    // MergeArmor* functions use these.
    maAddons: TStringList;
    processedAddons: TStringList;
    maKeywords: TStringList;
    maNewOverride: IwbMainRecord;
    maArmorNew: IwbMainRecord;
    maMaster: IwbMainRecord;
    maIndex: integer;
    maIter: integer;
    maOverride: IwbMainRecord;
    maChanged: boolean;
    maFurrySlots: integer;
    maAddonRaces: TStringList;


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
Remove any furrified races from the given armor addon. Furrified races are found in
maAddonRaces.
}
function AddonRemoveFurrifiedRaces(addon: IwbMainRecord): IwbMainRecord;
var
    raceList: IwbElement;
    raceRec: IwbMainRecord;
    i: integer;
    aaOverride: IwbMainRecord;
begin
    if LOGGING then LogEntry1(5, 'AddonRemoveFurrifiedRaces', PathName(addon));
    result := addon;
    aaOverride := nil;

    // Only process if not already in target file
    if GetLoadOrder(GetFile(addon)) < targetFileIndex then begin
        if LOGGING then LogD('Processing addon ' + EditorID(addon));
        raceList := ElementByPath(addon, 'Additional Races');
        for i := ElementCount(raceList)-1 downto -1 do begin
            if i < 0 then
                raceRec := LinksTo(ElementByPath(addon, 'RNAM'))
            else
                raceRec := LinksTo(ElementByIndex(raceList, i));
            if LOGGING then LogD(Format('Checking [%d] %s', [i, EditorID(raceRec)]));
            if raceAssignments.IndexOf(EditorID(raceRec)) >= 0 then begin
                if not Assigned(aaOverride) then begin
                    aaOverride := MakeOverride(addon, targetFile);
                    raceList := ElementByPath(aaOverride, 'Additional Races');
                end;
                if LOGGING then LogD(Format('Removing furrified race %s from addon %s', [EditorID(raceRec), EditorID(addon)]));
                if i < 0 then
                    AssignElementRef(ElementByPath(aaOverride, 'RNAM'), defaultRace)
                else begin
                    // Assign the element we are about to delete to ensure xEdit sees the change.
                    AssignElementRef(ElementByIndex(raceList, i), defaultRace);
                    RemoveByIndex(raceList, i, false);
                end;
            end;
        end;
        if Assigned(aaOverride) then
            result := aaOverride;
    end;

    if LOGGING then LogExitT1('AddonRemoveFurrifiedRaces', PathName(result));
end;


{=================================================================== 
Fix an addon to reflect furrification by adding furrified races. 

A furrified race is added if the armor is good for its furry race.

A furrified race is also added if the armor is good for the fallback of a furrified race
and there's no addon covering the same slots that references the furrified race directly.

Return TRUE if this is a furry addon and we added furrified races
    OR if this addon works for the armor fallback race of a furrified race.

Add the biped slots for this addon to maFurrySlots.
}
function AddonAddFurrifiedRaces(addon: IwbMainRecord): boolan;
var
    i, fidx: integer;
    raceList: IwbElement;
    raceName: string;
    vanillaRec: IwbMainRecord;
    e: IwbElement;
    aaOverride: IwbMainRecord;
    furryList: TStringList;
    fl: integer;
    curRaceList: TStringList;
begin
    if LOGGING then LogEntry1(5, 'AddonAddFurrifiedRaces', PathName(addon));

    result := false;

    // Only process once: if it's already in the targetFile or it's in the processedAddons
    // list, we've already done it.
    if (GetLoadOrder(GetFile(addon)) < targetFileIndex) 
        and (processedAddons.IndexOf(EditorID(addon)) < 0) 
    then begin
        raceList := ElementByPath(addon, 'Additional Races');
        
        // Don't dup races
        curRaceList := TStringList.Create;
        curRaceList.duplicates := dupIgnore;
        curRaceList.sorted := TRUE;
        for i := -1 to ElementCount(raceList)-1 do begin
            if i < 0 then raceName := EditorID(LinksTo(ElementByPath(addon, 'RNAM')))
            else raceName := EditorID(LinksTo(ElementByIndex(raceList, i)));
            curRaceList.Add(raceName);
            if LOGGING then LogD(Format('Found existing race %s', [raceName]));
        end;

        for i := -1 to ElementCount(racelist)-1 do begin
            if i < 0 then 
                raceName := EditorID(LinksTo(ElementByPath(addon, 'RNAM')))
            else 
                raceName := EditorID(LinksTo(ElementByIndex(raceList, i)));

            // Check whether the addon is good for a furry race
            furryList := nil;
            fidx := furryRaces.IndexOf(raceName);
            if fidx >= 0 then begin
                if LOGGING then LogD(Format('Works for %s', [raceName]));
                furryList := furryRaces.objects[fidx];
            end
            // No? Then see if it's good for a fallback armor race where the race isn't
            // referenced directly
            else if raceAssignments.indexOf(raceName) < 0 then  begin
                fidx := armorFallbacks.IndexOf(raceName);
                if fidx >= 0 then begin
                    if LOGGING then LogD(Format('Works for fallback %s', [raceName]));
                    furryList := armorFallbacks.objects[fidx];
                end;
            end;

            // If the addon is for a furry race, add the furrified vanilla race.
            if Assigned(furryList) then begin
                result := TRUE;
                if not Assigned(aaOverride) then begin
                    if GetLoadOrder(GetFile(addon)) < targetFileIndex then 
                        aaOverride := MakeOverride(addon, targetFile)
                    else
                        aaOverride := addon;
                end;

                for fl := 0 to furryList.Count-1 do begin
                    vanillaRec := ObjectToElement(furryList.objects[fl]);
                    if maAddonRaces.IndexOf(EditorID(vanillaRec)) >= 0 then begin
                        if LOGGING then LogD(Format('Skipping race %s, handled by another addon',
                            [EditorID(vanillaRec)]));
                        continue;
                    end
                    else if curRaceList.IndexOf(EditorID(vanillaRec)) >= 0 then begin
                        if LOGGING then LogD(Format('Skipping race %s, already present',
                            [EditorID(vanillaRec)]));
                        continue;
                    end;
                        
                    if LOGGING then LogD(Format('Adding race %s to %s', [EditorID(vanillaRec), PathName(aaOverride)]));
                    e := ElementAssign(ElementByPath(aaOverride, 'Additional Races'), 
                        HighInteger, nil, false);
                    AssignElementRef(e, vanillaRec);
                    if LOGGING then LogD(Format('Merging bodypart flags %d with %d', [
                        maFurrySlots, Integer(GetBodypartFlags(aaOverride))]));
                end;
                maFurrySlots := maFurrySlots or GetBodypartFlags(aaOverride);
            end;
        end;
        processedAddons.AddObject(EditorID(aaOverride), aaOverride);
        curRaceList.Free;

    end;
    if LOGGING then LogExitT1('AddonAddFurrifiedRaces', BoolToStr(result));
end;


{===================================================================
Set up the process of merging information from overrides to make a new 
furry armor record.
}
procedure MergeArmorStart(armor: IwbMainRecord);
var
    aaList: IwbElement;
    i: integer;
    addon: IwbMainRecord;
    kw: IwbMainRecord;
    kwList: IwbElement;
begin
    maAddons := TStringList.Create;
    maAddons.Duplicates := dupIgnore;
    maAddons.Sorted := true;

    // Any addons come for free when the override is created, so pre-load them.
    aaList := ElementByPath(WinningOverride(armor), 'Armature');
    for i := 0 to ElementCount(aaList) - 1 do begin
        addon := WinningOverride(LinksTo(ElementByIndex(aaList, i)));
        maAddons.AddObject(EditorID(addon), addon);
    end;

    maKeywords := TStringList.Create;
    maKeywords.Duplicates := dupIgnore;
    maKeywords.Sorted := true;

    // Any keywords come for free when the override is created, so pre-load them.
    kwList := ElementByPath(WinningOverride(armor), 'Keywords\KWDA');
    for i := 0 to ElementCount(kwList) - 1 do begin
        kw := WinningOverride(LinksTo(ElementByIndex(kwList, i)));
        maKeywords.AddObject(EditorID(kw), kw);
    end;

    maChanged := false;
    maFurrySlots := 0;

    maNewOverride := nil;
    maMaster := MasterOrSelf(armor);
    maOverride := nil;
    maIndex := OverrideCount(maMaster)-1;
    maIter := maIndex;
    if maIndex < 0 then maIndex := 0;
    
    if LOGGING then Log(25, Format('Iterating over %d overrides for %s', [
        Integer(OverrideCount(maMaster)), Name(maMaster)
    ]))
end;


{===================================================================
Free resources associated with furrifying an armor.
}
procedure MergeArmorFinish;
begin
    maAddons.Free;
    maKeywords.Free;
end;


{===================================================================
Iterate through the armor overrides, starting with the highest override.
}
function MergeArmorNextOverride: boolean;
begin
    if maIter < -1 then
        result := FALSE
    else if SameText(GetFileName(maOverride), UNOFFICIAL_PATCH) then begin
        // Assume the unofficial patch has properly dealt with everything below it.
        maIter := -2;
        maIndex := 0;
        result := TRUE;
        if LOGGING then LogD('Halting at override in unofficial patch');
    end
    else begin 
        // result := (maIter >= 0);

        if maIter < 0 then maOverride := maMaster
        else maOverride := OverrideByIndex(maMaster, maIter);

        if LOGGING then LogD(Format('Next override is [%d] %s', [maIter, PathName(maOverride)]));

        maIndex := maIter;
        maIter := maIter - 1;
        result := TRUE
    end;
end;


{===================================================================
Make an override for the current armor if we haven't already.
}
procedure MergeArmorMakeOverride;
begin
    if LOGGING then LogEntry1(15, 'MergeArmorMakeOverride', PathName(maOverride));
    if not Assigned(maNewOverride) then
        if GetLoadOrder(GetFile(maOverride)) < targetFileIndex then
            maNewOverride := MakeOverride(WinningOverride(maOverride), targetFile)
        else
            maNewOverride := maOverride;
    if LOGGING then LogExitT1('MergeArmorMakeOverride', PathName(maNewOverride));
end;


{===================================================================
Merge the keywords from the current armor override into the keyword list.
}
procedure MergeArmorKeywords;
var
    kwList: IwbElement;
    i: integer;
    keyword: IwbMainRecord;
    e: IwbElement;
begin
    if LOGGING then LogEntry1(15, 'MergeArmorKeywords', PathName(maOverride));

    kwList := ElementByPath(maOverride, 'Keywords\KWDA');
    if Assigned(kwList) then begin
        for i := 0 to ElementCount(kwList) - 1 do begin
            keyword := LinksTo(ElementByIndex(kwList, i));
            if Assigned(keyword) and (maKeywords.IndexOf(EditorID(keyword)) < 0) then begin
                MergeArmorMakeOverride;
                e := ElementAssign(ElementByPath(maNewOverride, 'Keywords\KWDA'), HighInteger, nil, false);
                AssignElementRef(e, keyword);
                maKeywords.AddObject(EditorID(keyword), keyword);
            end;
        end;
    end;

    if LOGGING then LogExitT('MergeArmorKeywords');
end;


{===================================================================
Return true if the given armor addon covers any bodyparts in the given slots. Covering any 
head part is assumed to cover all head parts.
}
function BodypartsOverlap(addon: IwbMainRecord; slots: cardinal): boolean;
var
    f: cardinal;
begin
    f := GetBodypartFlags(addon);
    if (f and (BP_HAIR or BP_LONGHAIR or BP_CIRCLET)) <> 0 then 
        f := f or BP_HEAD;
    if (slots and (BP_HAIR or BP_LONGHAIR or BP_CIRCLET)) <> 0 then 
        slots := slots or BP_HEAD;
    result := ((f and slots) <> 0);
end;


{===================================================================
Find other addons that cover the same bodyparts as the given addon and remove any 
furrified races from them.
}
procedure FixupOverlappingAddons(armor, addon: IwbMainRecord);
var
    aaList: IwbElement;
    i: integer;
    otherAddon: IwbMainRecord;
    thisRace: IwbMainRecord;
    furrifiedRace: IwbMainRecord;
    fi: integer;
    furryList: TStringList;
    fl: integer;
begin
    if LOGGING then LogEntry2(10, 'FixupOverlappingAddons', Name(armor), PathName(addon));

    // Collect the races covered by this addon. These are the ones to remove from other addons.
    for i := -1 to ElementCount(ElementByPath(addon, 'Additional Races')) - 1 do begin
        if i < 0 then 
            thisRace := LinksTo(ElementByPath(addon, 'RNAM'))
        else    
            thisRace := LinksTo(ElementByIndex(ElementByPath(addon, 'Additional Races'), i));
        fi := furryRaces.IndexOf(EditorID(thisRace));
        if fi >= 0 then begin
            furryList := furryRaces.objects[fi];
            for fl := 0 to furryList.Count-1 do begin
                furrifiedRace := ObjectToElement(furryList.objects[fl]);
                maAddonRaces.Add(EditorID(furrifiedRace));
                if LOGGING then LogD(Format('Addon %s covers race %s', [
                    EditorID(addon), EditorID(furrifiedRace)]));
            end;
        end;
    end;

    aaList := ElementByPath(armor, 'Armature');
    for i := 0 to ElementCount(aaList) - 1 do begin
        otherAddon := WinningOverride(LinksTo(ElementByIndex(aaList, i)));
        if (EditorID(otherAddon) <> EditorID(addon))
            and (processedAddons.IndexOf(EditorID(otherAddon)) < 0) 
        then begin
            if BodypartsOverlap(otherAddon, GetBodypartFlags(addon)) then begin
                if LOGGING then LogD(Format('Fixing overlapping addon %s', [EditorID(otherAddon)]));
                AddonRemoveFurrifiedRaces(otherAddon);
            end;
        end;
    end;

    if LOGGING then LogExitT('FixupOverlappingAddons');
end;


{===================================================================
Collect all furry races currently covered by maOverride's addons which cover the given
bodyparts in maAddonRaces. 
}
Procedure CollectArmorRaces(targetAddon: IwbMainRecord);
var
    addonList: IwbElement;
    i: integer;
    arma: IwbMainRecord;
    raceList: IwbElement;
    raceCount: integer;
    j: integer;
    thisRace: IwbMainRecord;
begin
    if LOGGING then LogEntry1(15, 'CollectArmorRaces', PathName(targetAddon));
    maAddonRaces := TStringList.Create;
    maAddonRaces.Duplicates := dupIgnore;
    maAddonRaces.Sorted := true;

    addonList := ElementByPath(WinningOverride(maMaster), 'Armature');
    for i := 0 to ElementCount(addonList)-1 do begin
        arma := WinningOverride(LinksTo(ElementByIndex(addonList, i)));
        if (EditorID(arma) <> EditorID(targetAddon))
            and ((GetBodypartFlags(arma) and GetBodypartFlags(targetAddon)) <> 0) 
        then begin
            if LOGGING then LogD(Format('Found overlapping addon %s:%s | %s:%s = %s', [
                EditorID(targetAddon), IntToHex(GetBodypartFlags(targetAddon), 8),
                EditorID(arma), IntToHex(GetBodypartFlags(arma), 8),
                IntToHex((GetBodypartFlags(arma) and GetBodypartFlags(targetAddon)), 8)
            ]));
            raceList := ElementByPath(arma, 'Additional Races');
            if Assigned(raceList) then raceCount := ElementCount(raceList)
            else raceCount := 0;
            for j := -1 to raceCount-1 do begin
                if j < 0 then 
                    thisRace := LinksTo(ElementByPath(arma, 'RNAM'))
                else 
                    thisRace := LinksTo(ElementByIndex(raceList, j));
                if furryRaces.IndexOf(EditorID(thisRace)) >= 0 then begin
                    maAddonRaces.Add(EditorID(thisRace));
                    if LOGGING then LogD(Format('Added race %s to addon list', [EditorID(thisRace)]));
                end;
            end;
        end;
    end;
    if LOGGING then LogExitT('CollectArmorRaces');
end;


{===================================================================
Merge any addons on this armor overide that are not already in the list of addons.
}
procedure MergeArmorAddons;
var
    aaList: IwbElement;
    i: integer;
    addon: IwbMainRecord;
    newAddon: IwbMainRecord;
    e: IwbElement;
begin
    if LOGGING then LogEntry1(15, 'MergeArmorAddons', PathName(maOverride));

    aaList := ElementByPath(maOverride, 'Armature');
    if Assigned(aaList) then begin
        // Walk through the addons and extend furry adddons to cover assigned furrified races.
        for i := 0 to ElementCount(aaList) - 1 do begin
            addon := WinningOverride(LinksTo(ElementByIndex(aaList, i)));
            if LOGGING then LogD(Format('addon %s load order = %d, target file = %d', [
                PathName(addon),
                Integer(GetLoadOrder(GetFile(addon))),
                Integer(GetLoadOrder(targetFile))]));
            if GetLoadOrder(GetFile(addon)) < GetLoadOrder(targetFile) then begin
                // Furrify the addon's races if needed.
                CollectArmorRaces(addon);
                if AddonAddFurrifiedRaces(addon) then 
                    FixupOverlappingAddons(maOverride, addon);

                // Make sure this addon is in the armor's list.
                if maAddons.IndexOf(EditorID(addon)) < 0 then begin
                    MergeArmorMakeOverride;
                    e := InsertAddonSlot(ElementByPath(maNewOverride, 'Armature'), addon);
                    AssignElementRef(e, addon);
                    maAddons.AddObject(EditorID(addon), addon);
                end;
                if Assigned(maAddonRaces) then maAddonRaces.Free;
            end;
        end;

    end;
    if LOGGING then LogExitT('MergeArmorAddons');
end;


{===================================================================
Insert a new armor addon into the armor's addon list, maintaining load order.
}
function InsertAddonSlot(addonList: IwbElement; newAddon: IwbMainRecord): IwbElement;
var
    i, insertIdx, newAddonLoadOrder, currAddonLoadOrder: integer;
    currAddon: IwbMainRecord;
begin
    if LOGGING then LogEntry2(10, 'InsertAddonSlot', PathName(addonList), EditorID(newAddon));

    newAddonLoadOrder := GetLoadOrder(GetFile(MasterOrSelf(newAddon)));
    insertIdx := ElementCount(addonList); // Default to end

    for i := 0 to ElementCount(addonList) - 1 do
    begin
        currAddon := MasterOrSelf(LinksTo(ElementByIndex(addonList, i)));
        currAddonLoadOrder := GetLoadOrder(GetFile(currAddon));
        if LOGGING then LogD(Format('Comparing new addon load order %d to current addon %d/%s load order %d', [
            newAddonLoadOrder, i, EditorID(currAddon), currAddonLoadOrder]));
        if currAddonLoadOrder < newAddonLoadOrder then
        begin
            insertIdx := i;
            break;
        end;
    end;

    // ElementAssign at insertIdx appears not to work. So just append at the end and move
    // things around.
    ElementAssign(addonList, HighInteger, nil, false);
    for i := ElementCount(addonList) - 2 downto insertIdx do begin
        SetNativeValue(ElementByIndex(addonList, i+1), GetNativeValue(ElementByIndex(addonList, i)));
        if LOGGING then LogD(Format('Shifting addon %s at index %d to %d', [
            EditorID(LinksTo(ElementByIndex(addonList, i))), i, i+1]));
    end;
    Result := ElementByIndex(addonList, insertIdx);

    if LOGGING then LogExitT1('InsertAddonSlot', PathName(Result));
end;


{===================================================================
Furrify a single armor record. Every addon which references a furrified race has the
furrified race removed and the armor is augmented with the furry version of the addon. 
}
function FurrifyArmorRecord(armor: IwbMainRecord): IwbMainRecord;
var
    myAddons, myKeywords: TStringList;
    armorMaster: IwbMainRecord;
    overrideIndex: integer;
    changed: boolean;
begin
    if LOGGING then LogEntry1(5, 'FurrifyArmorRecord', PathName(armor));
    result := armor;

    // Only process the highest override; don't process if we did it already.
    if HasNoOverride(armor) and (GetLoadOrder(GetFile(armor)) < targetFileIndex) then begin
        if LOGGING then LogD('Processing armor: ' + PathName(armor));
        MergeArmorStart(armor);

        // for thisOverride := highest to lowest override do begin
        While MergeArmorNextOverride do begin 
            if LOGGING then LogD(Format('Processing override [%d] %s', [maIndex, PathName(maOverride)]));
            MergeArmorKeywords;
            MergeArmorAddons;
        end;

        if Assigned(maNewOverride) then result := maNewOverride;
        MergeArmorFinish;
    end;

    if LOGGING then LogExitT1('FurrifyArmorRecord', PathName(result));
end;


procedure FurrifyArmorsInit;
begin
    processedAddons := TStringList.Create;
    processedAddons.Duplicates := dupIgnore;
    processedAddons.Sorted := true;
end;


procedure FurrifyArmorsFinish;
begin
    processedAddons.Free;
end;

{===================================================================
Furrify all armor records in the load order.
}
procedure FurrifyAllArmors;
var
    armorList: IwbElement;
    armor: IwbMainRecord;
    f, a: integer;
begin
    if LOGGING then LogEntry(1, 'FurrifyAllArmors');
    FurrifyArmorsInit;

    for f := targetFileIndex - 1 downto 0 do begin
        armorList := GroupBySignature(FileByIndex(f), 'ARMO');
        for a := 0 to ElementCount(armorList) do begin
            armor := ElementByIndex(armorList, a);
            FurrifyArmorRecord(armor);
        end;
    end;

    FurrifyArmorsFinish;
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
    for f := firstModIndex to targetFileIndex - 1 do begin
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

end.