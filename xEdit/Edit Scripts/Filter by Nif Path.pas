{
  Filter to a specific NIF path
}
unit ApplyCustomScriptedFilter;

interface
implementation

uses 
    xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
  targetPath = 'thievesguild';
  targetpath2 = 'thievesguild';


function Filter(e: IInterface): Boolean;
var
  v: String;
  v2: String;
begin
  if (Signature(e) <> 'ARMA') then Exit;
  
  v := GetElementEditValues(e, 'Biped Model\Male\MOD2');
  v2 := GetElementEditValues(e, 'Biped Model\Female\MOD3');
  // AddMessage(Format('%s body template = %s', [Name(e), IntToHex(v,8)]));
  Result := ContainsText(v, targetPath) or ContainsText(v2, targetpath2) ;
end;

function Initialize: Integer;
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

  ApplyFilter;

  Result := 1;
end;

end.
