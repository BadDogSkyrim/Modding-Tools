{
  Apply custom scripted filter to show Armor that has bad race assignments: either
  a race appears in multiple AAs, or some races in the racelist are not in any AA.
}
unit ApplyCustomScriptedFilter;

interface

implementation

uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows, Forms;

Const
  mask = 3 + 65536;

Var
  allRaces: TStringList; // Races that should be covered by the addons
  myRaceCounts: array[0..20] of integer; // Count of references to races, 1:1 with allRaces
  startFile: integer;
  slots: TStringList;


Function UsesSlot(e: IwbMainRecord; slot: string): boolean;
var
  v: integer;
  s: string;
begin
  v := GetElementNativeValues(e, 'BOD2\First Person Flags\' + slot);
  s := GetElementEditValues(e, 'BOD2\First Person Flags\' + slot);
  //AddMessage(Format('-- %s uses slot %s: [%s]', [Name(e), slot, s]));
  Result := SameText(s, '1');
end;


procedure CollectRaces(addon: IwbMainRecord; slot: string);
var
  r: IwbMainRecord;
  racelist: IwbElement;
  i, ri: integer;
begin
  if not UsesSlot(addon, slot) then exit;

  r := LinksTo(ElementByPath(addon, 'RNAM'));
  ri := allRaces.IndexOf(EditorID(r));
  if ri >= 0 then myRaceCounts[ri] := myRaceCounts[ri] + 1;

  racelist := ElementByPath(addon, 'Additional Races');
  if Assigned(racelist) then
    for i := 0 to ElementCount(racelist)-1 do begin
      r := LinksTo(ElementByIndex(racelist, i));
      ri := allraces.IndexOf(EditorID(r));
      if ri >= 0 then myRaceCounts[ri] := myRaceCounts[ri] + 1;
    end;
end;


//===
// Check myRaces for coverage. Return True if there's a problem.
function CheckRaces(armor: IwbMainRecord; slot: string): Boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to allRaces.Count-1 do begin
    if myRaceCounts[i] = 0 then begin
      Result := true;
      AddMessage(Format('%s slot %s does not cover race %s', [Name(armor), slot, allRaces[i]]));
    end
    else if myRaceCounts[i] > 1 then begin
      Result := true;
      AddMessage(Format('%s slot %s has duplicate assignments for race %s', [Name(armor), slot, allRaces[i]]));
    end;
  end;
end;


Function CheckArmor(armor: IwbMainRecord; slot: string): boolean;
var
  i: integer;
  addonList: IwbElement;
  addon: IwbMainRecord;
  modelEntry: IwbElement;
begin
  Result := false;
  if not UsesSlot(armor, slot) then exit;

  for i := 0 to allRaces.Count-1 do
    myRaceCounts[i] := 0;

  addonList := ElementByPath(armor, 'Models');
  for i := 0 to ElementCount(addonList)-1 do begin
    modelEntry := ElementByIndex(addonList, i);
    addon := LinksTo(ElementByPath(modelEntry, 'MODL'));
    // if not Assigned(addon) then
    //   AddMessage(Format('--Addon %d not assigned', [i]))
    // else
    //   AddMessage(Format('--Checking "%s" addon [%d] %s', [Name(armor), i, Name(addon)]));
    CollectRaces(addon, slot);
  end;

  Result := CheckRaces(armor, slot);
end;


function Filter(e: IInterface): Boolean;
var
  i: integer;
  fn: string;
begin
  if Signature(e) <> 'ARMO' then
    Exit;

  fn := GetFileName(GetFile(e));
  if not IsWinningOverride(e) then exit;
  if EndsText('.esm', fn) then exit;
  if EndsText('.exe', fn) then exit;
  if EndsText('SkinNaked', EditorID(e)) then exit;

  Result := CheckArmor(e, '30 - Hair Top')
    or CheckArmor(e, '31 - Hair Long')
    or CheckArmor(e, '46 - Headband')
    or CheckArmor(e, '47 - Eyes')
    or CheckArmor(e, '48 - Beard')
    or CheckArmor(e, '49 - Mouth')
    or CheckArmor(e, '50 - Neck')
end;


function Initialize: Integer;
var i: integer;
begin
  FilterConflictAll := False;
  FilterConflictThis := False;
  FilterByInjectStatus := False;
  FilterInjectStatus := False;
  FilterByNotReachableStatus := False;
  FilterNotReachableStatus := False;
  FilterByReferencesInjectedStatus := False;
  FilterReferencesInjectedStatus := False;
  FilterByEditorID := False;
  FilterEditorID := '';
  FilterByName := False;
  FilterName := '';
  FilterByBaseEditorID := False;
  FilterBaseEditorID := '';
  FilterByBaseName := False;
  FilterBaseName := '';
  FilterScaledActors := False;
  FilterByPersistent := False;
  FilterPersistent := False;
  FilterUnnecessaryPersistent := False;
  FilterMasterIsTemporary := False;
  FilterIsMaster := False;
  FilterPersistentPosChanged := False;
  FilterDeleted := False;
  FilterByVWD := False;
  FilterVWD := False;
  FilterByHasVWDMesh := False;
  FilterHasVWDMesh := False;
  FilterBySignature := False;
  FilterSignatures := '';
  FilterByBaseSignature := False;
  FilterBaseSignatures := '';
  FlattenBlocks := False;
  FlattenCellChilds := False;
  AssignPersWrldChild := False;
  InheritConflictByParent := True; // color conflicts
  FilterScripted := True; // use custom Filter() function

  allRaces := TStringList.Create;
  allRaces.add('FFOCheetahRace');
  allRaces.add('FFODeerRace');
  allRaces.add('FFOFoxRace');
  allRaces.add('FFOHorseRace');
  allRaces.add('FFOHyenaRace');
  allRaces.add('FFOLionRace');
  allRaces.add('FFOLykaiosRace');
  allRaces.add('FFOOtterRace');
  allRaces.add('FFOSnekdogRace');
  allRaces.add('FFOTigerRace');

  slots := TStringList.Create;
  slots.add('30 - Hair Top');
  slots.add('31 - Hair Long');
  slots.add('46 - Headband');
  slots.add('47 - Eyes');
  slots.add('48 - Beard');
  slots.add('49 - Mouth');
  slots.add('50 - Neck');

  // Find first file which isn't a vanilla or DLC file
  // startFile := 0;
  // for i := 0 to FileCount-1 do begin
  //   fn := GetFileName(FileByIndex(i));
  //   if not EndsText('.esm', fn) then begin
  //     startFile := i;
  //     break;
  //   end;

  ApplyFilter;

  Result := 1;
end;


function Finalize: integer;
begin
  allRaces.Free;
end;
end.