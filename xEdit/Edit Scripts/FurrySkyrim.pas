
unit FurrySkyrim;

interface

uses
  xEditAPI;

procedure SetNPCTintLayer(const npc: IwbMainRecord; const skintonePreset: IwbElement);

implementation

uses FurrySkyrim_Preferences, FurrySkyrimTools, BDScriptTools, Classes, SysUtils, StrUtils, Windows;

const
    FURRIFIER_VERSION = '1.00';
    SHOW_OPTIONS_DIALOG = False;
    PATCH_FILE_NAME = 'YAPatch.esp'; // Set to whatever
    USE_SELECTION = FALSE;           // FALSE or TRUE

var
    targetFile: IwbFile;


{============================================================================
Copy an element from source to target if it exists in the source.
}
procedure CopyElementIf(dst, src: IwbElement; name: string);
begin
    if ElementExists(src, name) then begin
        Add(dst, name, True);
        ElementAssign(ElementByPath(dst, name), LowInteger, ElementByPath(src, name), false);
    end;
end;


{============================================================================
Make a vanilla race furry by copying over appearance data from the furry race.
Also pre-load race info.
}
procedure FurrifyRace(vanillaRaceName: string; furryRace: IwbMainRecord);
var
    furrifiedRace: IwbMainRecord;
    vanillaRace: IwbMainRecord;
begin
    if LOGGING then LogEntry2(1, 'FurrifyRace', vanillaRaceName, Name(furryRace));
    vanillaRace := WinningOverride(FindAsset(Nil, 'RACE', vanillaRaceName));
    LogD(Format('Found race %s in file %s', [Name(vanillaRace), GetFileName(GetFile(vanillaRace))]));
    LogD('Overriding in ' + GetFileName(targetFile));
    AddRecursiveMaster(targetFile, GetFile(vanillaRace));
    AddRecursiveMaster(targetFile, GetFile(furryRace));
    
    if LOGGING then LogD('Source RNAM value is ' + GetElementEditValues(furryRace, 'RNAM'));
    furrifiedRace := wbCopyElementToFile(vanillaRace, targetFile, False, True);

    CopyElementIf(furrifiedRace, furryRace, 'RNAM'); 
    CopyElementIf(furrifiedRace, furryRace, 'NAM8');
    CopyElementIf(furrifiedRace, furryRace, 'WNAM');
    CopyElementIf(furrifiedRace, furryRace, 'Head Data');

    // ElementAssign(ElementByPath(furrifiedRace, 'Head Data\Male Head Data'), LowInteger, Nil, false);
    // ElementAssign(ElementByPath(furrifiedRace, 'WNAM'), LowInteger, ElementByPath(furryRace, 'WNAM'), false);
    // SetElementEditValues(furrifiedRace, 'RNAM', GetElementEditValues(furryRace, 'RNAM'));
    ElementAssign(ElementByPath(furrifiedRace, 'Head Data\Male Head Data'), 
        LowInteger, 
        ElementByPath(furryRace, 'Head Data\Male Head Data'), 
        false);

    LoadRaceTints(furrifiedRace);

    if LOGGING then LogExitT('FurrifyRace');
end;


{==================================================================
Change all redefined races to their furry equivalent race.
}
procedure FurrifyAllRaces;
var i: integer;
begin
    for i := 0 to raceAssignments.Count-1 do begin
        FurrifyRace(raceAssignments[i], ObjectToElement(raceAssignments.objects[i]));
    end;
end;


{==================================================================
Choose an equivalent furry headpart for the given vanilla headpart.
}
function FindEquivalentHP(npc: IwbMainRecord; oldHeadpart: IwbMainRecord): IwbMainRecord;
var
    h: integer;
    i: integer;
begin
    if LOGGING then LogEntry2(1, 'FindEquivalentHP', Name(npc), Name(oldHeadpart));
    i := headpartEquivalents.IndexOf(EditorID(oldHeadpart));
    if i >= 0 then begin
        h := Hash(Unalias(EditorID(npc)), 2134, headpartEquivalents.objects[i].Count);
        result := ObjectToElement(headpartEquivalents.objects[i].objects[h]);
    end
    else
        result := nil;
    if LOGGING then LogExitT1('FindEquivalentHP', Name(result));
end;


{==================================================================
Furrify an NPC's headparts by choosing furry equivalents for vanilla headparts.
}
procedure FurrifyAllHeadparts(furryNPC, npc: IwbMainRecord);
var
    oldHeadparts: IwbContainer;
    newHeadparts: IwbContainer;
    i: integer;
    oldHP: IwbMainRecord;
    newHP: IwbMainRecord;
    targetIndex: integer;
begin
    if LOGGING then LogEntry1(1, 'FurrifyAllHeadparts', Name(npc));
    oldHeadparts := ElementByPath(npc, 'Head Parts');
    for i := 0 to ElementCount(oldHeadparts) do begin
        oldHP := LinksTo(ElementByIndex(oldHeadparts, i));
        newHP := FindEquivalentHP(npc, oldHP);
        if Assigned(newHP) then begin
            if LOGGING then LogD('Assigning new headpart ' + EditorID(newHP));

            if not ElementExists(furryNPC, 'Head Parts') then begin
                Add(furryNPC, 'Head Parts', true);
                targetIndex := 0;
                newHeadparts := ElementByPath(furryNPC, 'Head Parts');
            end
            else begin
                newHeadparts := ElementByPath(furryNPC, 'Head Parts');
                ElementAssign(newHeadparts, HighInteger, Nil, false);
                targetIndex := ElementCount(newHeadparts)-1;
            end;
            AssignElementRef(ElementByIndex(newHeadparts, targetIndex), newHP);
        end;
    end;
    if LOGGING then LogExitT('FurrifyAllHeadparts');
end;


{==================================================================
Create a skin tone layer from the given preset.
}
procedure SetNPCTintLayer(const npc: IwbMainRecord; const skintonePreset: IwbElement);
var
    color: IwbMainRecord;
    sktLayer: IwbElement;
    tintAsset: IwbContainer;
begin
    if LOGGING then LogEntry2(5, 'SetNPCTintLayer', Name(npc), PathName(skintonePreset));

    tintAsset := GetContainer(GetContainer(skintonePreset));
    if not ElementExists(npc, 'Tint Layers') then begin
        Add(npc, 'Tint Layers', True);
        sktLayer := ElementByIndex(ElementByPath(npc, 'Tint Layers'), 0);
    end
    else
        sktLayer := ElementAssign(ElementByPath(npc, 'Tint Layers'), HighInteger, Nil, false);

    LogD('Created skin tone layer ' + PathName(sktLayer));
    
    SetElementNativeValues(sktLayer, 'TINI', 
        GetElementNativeValues(tintAsset, 'Tint Layer\Texture\TINI'));
    SetElementNativeValues(sktLayer, 'TIAS', GetElementNativeValues(skintonePreset, 'TIRS'));
    SetElementNativeValues(sktLayer, 'TINV', GetElementNativeValues(skintonePreset, 'TINV'));
    LogD('Assigned TINI, TIAS, TINV ' + 
        GetElementEditValues(sktLayer, 'TINI') + ', ' + 
        GetElementEditValues(sktLayer, 'TIAS') + ', ' + 
        GetElementEditValues(sktLayer, 'TINV'));

    color := WinningOverride(LinksTo(ElementByPath(skintonePreset, 'TINC')));
    if Assigned(color) then begin
        Add(sktLayer, 'TINC', True);
        ElementAssign(ElementByPath(sktLayer, 'TINC'), LowInteger, 
            ElementByPath(color, 'CNAM'), false);
    end;

    if SameText(GetElementEditValues(tintAsset, 'Tint Layer\Texture\TINP'), 'Skin Tone') then begin
        Add(npc, 'QNAM', true);
        SetElementNativeValues(npc, 'QNAM\Red', GetElementNativeValues(color, 'CNAM\Red'));
        SetElementNativeValues(npc, 'QNAM\Green', GetElementNativeValues(color, 'CNAM\Green'));
        SetElementNativeValues(npc, 'QNAM\Blue', GetElementNativeValues(color, 'CNAM\Blue'));
    end;

    LogD('Tint layers: ' + IntToStr(ElementCount(ElementByPath(npc, 'Tint Layers'))));

    if LOGGING then LogExitT('SetNPCTintLayer');
end;


{==================================================================
Select a furry tint layer for the NPC from presets in curNPCTintLayerOptions.
}
Procedure ChooseFurryTintLayer(npc: IwbMainRecord; layerIndex: integer);
var 
    h: integer;
    presetList: IwbElement;
    skintonePreset: IwbElement;
begin
    if LOGGING then LogEntry2(1, 'ChooseFurryTintLayer', Name(npc), curNPCTintLayerOptions.strings[layerIndex]);
    
    presetList := ObjectToElement(curNPCTintLayerOptions.objects[layerIndex]);
    h := Hash(Unalias(EditorID(npc)), 1455, ElementCount(presetList));
    skintonePreset := ElementByIndex(presetList, h);
    SetNPCTintLayer(npc, skintonePreset);

    if LOGGING then LogExitT('ChooseFurryTintLayer');
end;


{==================================================================
Set all the furry tint layers on the npc, choosing presets randomly.
}
Procedure ChooseFurryTints(npc: IwbMainRecord);
var
    i: integer;
begin
    LoadNPCSkinTones(npc);
    for i := 0 to curNPCTintLayerOptions.Count-1 do begin
        if multivalueMasks.IndexOf(curNPCTintLayerOptions.strings[i]) < 0 then
            ChooseFurryTintLayer(npc, i);
    end;
end;


{==================================================================
Furrify an NPC by changing head parts, tints, and morphs to the furry race.
}
function FurrifyNPC(npc: IwbMainRecord): IwbMainRecord;
var
    furryNPC: IwbMainRecord;
begin
    if LOGGING then LogEntry1(1, 'FurrifyNPC', Name(npc));

    result := Nil;
    if raceAssignments.IndexOf(EditorID(LinksTo(ElementByPath(npc, 'RNAM')))) >= 0 then begin
        furryNPC := MakeOverride(npc, targetFile);
        Remove(ElementByPath(furryNPC, 'FTST - Head texture'));
        Remove(ElementByPath(furryNPC, 'QNAM - Texture lighting'));
        Remove(ElementByPath(furryNPC, 'NAM9 - Face morph'));
        Remove(ElementByPath(furryNPC, 'Tint Layers'));

        LoadNPC(furryNPC);

        // Clean out existing character customization
        Remove(ElementByPath(furryNPC, 'Head Parts'));
        FurrifyAllHeadparts(furryNPC, npc);
        ChooseFurryTints(furryNPC);

        result := furryNPC;
    end;

    if LOGGING then LogExitT('FurrifyNPC');
end;


//==================================================================
//==================================================================
//
function Initialize: integer;
begin
    InitializeLogging;
    LOGGING := True;
    LOGLEVEL := 20;
    if LOGGING then LogEntry(1, 'Initialize');
    PreferencesInit;
    result := 0;
    if LOGGING then LogExitT('Initialize');
end;

function Process(entity: IwbMainRecord): integer;
var
    win: IwbMainRecord;
begin
    result := 0;
end;

function Finalize: integer;
var
    targetFileIndex: integer;
begin
    if LOGGING then LogEntry(1, 'Finalize');
    SetPreferences;
    ShowRaceAssignments;

    targetFileIndex := FindFile(PATCH_FILE_NAME);
    LogD(Format('Found target file at %d', [targetFileIndex]));
    if targetFileIndex < 0 then begin
        targetFile := AddNewFileName(PATCH_FILE_NAME);
        LogT('Creating file ' + GetFileName(targetFile));
    end
    else 
        targetFile := FileByIndex(targetFileIndex);

    FurrifyAllRaces;

    PreferencesFree;
    result := 0;
    if LOGGING then LogExitT('Finalize');
end;

end.