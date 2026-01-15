unit BDTintsMaleToFemale;

interface
implementation


procedure RemoveAllElements(e: IInterface);
var
    i: Integer;
begin
    // Remove elements in reverse order to avoid index shifting
    for i := ElementCount(e) - 1 downto 0 do
        Remove(ElementByIndex(e, i));
end;

function Initialize: integer;
begin
    Result := 0;
end;

function Process(e: IInterface): integer;
var
    maleTints, femaleTints, tintLayer: IInterface;
    i: integer;
    srcAsset, dstAsset: IInterface;
    j: integer;
    srcPresetList, dstPresetList: IInterface;
    p: IInterface;
    srcPreset, dstPreset: IInterface;
    k: integer;
begin
    Result := 0;

    // Only process RACE records
    if Signature(e) <> 'RACE' then Exit;

    // Get male tint layers
    maleTints := ElementByPath(e, 'Head Data\Male Head Data\Tint Masks');
    if not Assigned(maleTints) then begin
        AddMessage('No male tint layers found in: ' + Name(e));
        Exit;
    end;

    // Get or create female tint layers
    femaleTints := ElementByPath(e, 'Head Data\Female Head Data\Tint Masks');
    if not Assigned(femaleTints) then begin
        femaleTints := Add(e, 'Head Data\Female Head Data\Tint Masks', True);
        if not Assigned(femaleTints) then begin
            AddMessage('Failed to create female tint layers in: ' + Name(e));
            Exit;
        end;
    end;

    Add(ElementByPath(e, 'Head Data\Female Head Data'), 'Tint Masks', True);

    // Copy each male tint layer to female
    // Presets are not working as expected. Can't create new preset entries properly.
    // Just reuse the ones that are there and live with it.
    for i := 0 to ElementCount(maleTints) - 1 do begin
        AddMessage('***');
        srcAsset := ElementByIndex(maleTints, i);
        if ElementCount(femaleTints) > i then begin
            dstAsset := ElementByIndex(femaleTints, i);
            addmessage(Format('Using existing tint layer [%d]: %s', [i, PathName(dstAsset)]));
        end
        else begin
            dstAsset := ElementAssign(femaleTints, HighInteger, srcAsset, False);
            dstAsset := ElementByIndex(femaleTints, i);
            addmessage(Format('Created tint layer [%d]: %s', [i, PathName(dstAsset)]));
        end;

        AddMessage(Format('Copying tint layer [%d] from %s to %s', [i, PathName(srcAsset), PathName(dstAsset)]));
        
        SetElementEditValues(dstAsset, 'Tint Layer\TINI', GetElementEditValues(srcAsset, 'Tint Layer\TINI'));
        SetElementEditValues(dstAsset, 'Tint Layer\TINT', GetElementEditValues(srcAsset, 'Tint Layer\TINT'));
        SetElementEditValues(dstAsset, 'Tint Layer\TINP', GetElementEditValues(srcAsset, 'Tint Layer\TINP'));
        if Assigned(GetElementEditValues(srcAsset, 'Tint Layer\TIND')) then
            SetElementEditValues(dstAsset, 'Tint Layer\TIND', GetElementEditValues(srcAsset, 'Tint Layer\TIND'));

        // Handle Presets
        srcPresetList := Elementbypath(srcAsset, 'Presets');
        dstPresetList := ElementByPath(dstAsset, 'Presets');
        for j := 0 to ElementCount(srcPresetList)-1 do begin
            srcPreset := ElementByIndex(srcPresetList, j);
            if ElementCount(dstPresetList) > j then begin
                dstPreset := ElementByIndex(dstPresetList, j);
            end
            else begin
                dstPreset := ElementAssign(dstPresetList, HighInteger, srcPreset, False);
                addmessage(Format('Created preset [%d]: %s', [j, PathName(dstPreset)]));
            end;
            AddMessage(Format('Copying preset [%d] from %s to %s', [j, PathName(srcPreset), PathName(dstPreset)]));
            SetElementEditValues(dstPreset, 'TINC', GetElementEditValues(srcPreset, 'TINC'));
            SetElementEditValues(dstPreset, 'TINV', GetElementEditValues(srcPreset, 'TINV'));
            SetElementEditValues(dstPreset, 'TIRS', GetElementEditValues(srcPreset, 'TIRS'));
        end;

        if ElementCount(dstPresetList) > ElementCount(srcPresetList) then begin
            // Remove extra presets in dst
            for k := ElementCount(dstPresetList)-1 downto ElementCount(srcPresetList) do begin
                Remove(ElementByIndex(dstPresetList, k));
                addmessage(Format('Removed extra preset [%d] from dst: %s', [k, PathName(dstPresetList)]));
            end;
        end;

    end;

    if i < ElementCount(femaleTints) then begin
        // Remove extra tint layers in female
        for k := ElementCount(femaleTints)-1 downto i do begin
            Remove(ElementByIndex(femaleTints, k));
            addmessage(Format('Removed extra tint layer [%d] from female: %s', [k, PathName(femaleTints)]));
        end;
    end;

    AddMessage('Copied ' + IntToStr(ElementCount(maleTints)) + ' tint layers from male to female in: ' + Name(e));
end;

function Finalize: integer;
begin
    Result := 0;
end;

end.