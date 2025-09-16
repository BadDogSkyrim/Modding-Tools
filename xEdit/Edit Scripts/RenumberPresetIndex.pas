unit RenumberPresetIndex;
{
  Renumber all TIRS preset indices in the last-loaded plugin to be unique in the current
  load order.
}

interface
implementation
uses xEditAPI;
var
  maxTIRS, maxTINI: integer;

procedure TINIAddToMax(tini: IwbElement);
var
  idx: integer;
begin
  AddMessage(Format('Found TINI: %d at %s', [Integer(GetNativeValue(tini)), Path(tini)]));
  idx := GetNativeValue(tini);
  if idx > maxTINI then
    maxTINI := idx;
end;

procedure TIRSAddToMax(tirs: IwbElement);
var
  idx: integer;
begin
  idx := GetNativeValue(tirs);
  if idx > maxTIRS then
    maxTIRS := idx;
end;

procedure TIRSSetToMax(tirs: IwbElement);
begin
  Inc(maxTIRS);
  SetNativeValue(tirs, maxTIRS);
end;

procedure TINISetToMax(tini: IwbElement);
begin
  Inc(maxTINI);
  SetNativeValue(tini, maxTINI);
end;

procedure WalkTintAssets(theRace: IwbMainRecord; action: string);
var
  k, mi, pi: integer;
  masks, tintAsset, presets, preset, tirs: IInterface;
  tini: IwbElement;
begin
  for k := 1 to 2 do begin
    masks := ElementByPath(theRace, 'Head Data\'
      + IfThen(k=1, 'Male Head Data', 'Female Head Data') 
      + '\Tint Masks');
    if Assigned(masks) then begin
      for mi := 0 to ElementCount(masks) - 1 do begin
        tintAsset := ElementByIndex(masks, mi);

        tini := ElementByPath(tintAsset, 'Tint Layer\[0]\TINI');
        if action = 'FIND MAX' then
          TINIAddToMax(tini)
        else if action = 'RENUMBER' then
          TINISetToMax(tini);

        presets := ElementByPath(tintAsset, 'Presets');
        for pi := 0 to ElementCount(presets) - 1 do begin
          preset := ElementByIndex(presets, pi);
          tirs := ElementByPath(preset, 'TIRS - Index');
          if action = 'FIND MAX' then
            TIRSAddToMax(tirs)
          else if action = 'RENUMBER' then
            TIRSSetToMax(tirs);
        end;
      end;
    end;
  end;
end;

function Initialize: integer;
var
  i, j: integer;
  f: IwbFile;
  g: IwbGroupRecord;
  theRace: IInterface;
begin
  maxTINI := -1;
  maxTIRS := -1;

  // Scan all loaded RACE records to find the highest existing TIRS index
  for i := 0 to FileCount - 2 do begin
    f := FileByIndex(i);
    g := GroupBySignature(f, 'RACE');
    for j := 0 to RecordCount(g) - 1 do begin
      theRace := RecordByIndex(g, j);
      if Signature(theRace) = 'RACE' then begin
        AddMessage('Scanning ' + Name(theRace) + ' for max TIRS index...');
        WalkTintAssets(theRace, 'FIND MAX');
      end;
    end;
  end;

  AddMessage('Highest existing preset index found: ' + IntToStr(maxTIRS));
end;

function Process(e: IInterface): integer;
begin
  if Signature(e) = 'RACE' then begin
    AddMessage('Renumbering TIRS indices in ' + Name(e) + ' starting from ' + IntToStr(maxTIRS + 1) + '...');
    WalkTintAssets(e, 'RENUMBER');
  end;
end;

function Finalize: integer;
begin
  AddMessage('Preset index renumbering complete. Max index used: ' + IntToStr(maxTIRS));
end;

end.