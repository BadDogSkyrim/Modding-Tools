{
  Apply custom scripted filter for headgear
}
unit ApplyCustomScriptedFilter;

Const
  mask = 3 + 65536;

function Filter(e: IInterface): Boolean;
var
  v: Cardinal;
begin
  if (Signature(e) <> 'ARMA') and (Signature(e) <> 'ARMO') then
    Exit;
  
  v := GetElementNativeValues(e, 'BOD2\First Person Flags');
  // AddMessage(Format('%s body template = %s', [Name(e), IntToHex(v,8)]));
  Result := (v and mask) <> 0;
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