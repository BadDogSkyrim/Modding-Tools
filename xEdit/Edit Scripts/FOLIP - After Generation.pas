{
    Remove HasDistantLOD flag from STAT records.
}
unit HasDistantLOD;

var
    iPluginFile, iBeforeGeneration: IwbFile;
    formLists: IwbGroupRecord;
    sFolipPluginFileName, sFolipBeforeGeneration, sIgnoredWorldspaces: string;
    slStatsWithOverrides, slOverrides: TStringList;
    bLightPlugin, bLimitedHasDistantLODRemoval, bRemoveVWD, bAddVWD, bSkipPrecombined, bRemoveBeforeGeneration: Boolean;
    uiScale: integer;
    joUserSettings: TJsonObject;

const
    sFolipFileName = 'FOLIP - New LODs.esp';
    sUserSettingsFileName = 'FOLIP\UserSettings.json';

function Initialize: integer;
{
    This function is called at the beginning.
}
var
    i, a: integer;
    f, iFolip: IwbFile;
    filename, j, key: string;
    sub: TJsonObject;
    bLoadDefaults: Boolean;
begin
    slStatsWithOverrides := TStringList.Create;
    slOverrides := TStringList.Create;
    joUserSettings := TJsonObject.Create;
    sIgnoredWorldspaces := '';
    bLoadDefaults := True;

    //Load User Settings
    if ResourceExists(sUserSettingsFileName) then begin
        AddMessage('Loading user settings from ' + sUserSettingsFileName);
        joUserSettings.LoadFromResource(sUserSettingsFileName);
        try
            sFolipBeforeGeneration := Fallback(joUserSettings.S['BeforeGenerationPluginName'], 'FOLIP - Before Generation');
            sFolipPluginFileName := Fallback(joUserSettings.S['AfterGenerationPluginName'], 'FOLIP - After Generation');
            bLightPlugin := StrToBool(Fallback(joUserSettings.S['LightPlugin'], 'true'));
            bRemoveVWD := StrToBool(Fallback(joUserSettings.S['RemoveVWD'], 'true'));
            bLimitedHasDistantLODRemoval := StrToBool(Fallback(joUserSettings.S['LimitedHasDistantLODRemoval'], 'true'));
            bAddVWD := StrToBool(Fallback(joUserSettings.S['AddVWD'], 'true'));
            bSkipPrecombined := StrToBool(Fallback(joUserSettings.S['SkipPrecombined'], 'true'));
            bRemoveBeforeGeneration := StrToBool(Fallback(joUserSettings.S['RemoveBeforeGeneration'], 'false'));
            bLoadDefaults := False;
        except
            AddMessage('User settings are incomplete. Loading defaults.');
        end;
    end;
    if bLoadDefaults then begin
        sFolipBeforeGeneration := 'FOLIP - Before Generation';
        sFolipPluginFileName := 'FOLIP - After Generation';
        bLightPlugin := True;
        bRemoveVWD := True;
        bLimitedHasDistantLODRemoval := False;
        bAddVWD := False;
        bSkipPrecombined := True;
        bRemoveBeforeGeneration := False;
    end;

    //Get scaling
    uiScale := Screen.PixelsPerInch * 100 / 96;
    AddMessage('UI scale: ' + IntToStr(uiScale));

    //Warn users if Simple records are unchecked
    if wbSimpleRecords then begin
        MessageDlg('Simple records must be unchecked in xEdit options', mtInformation, [mbOk], 0);
        Result := 1;
        Exit;
    end;

    //Display Menu
    if not MainMenuForm then begin
        Result := 1;
        Exit;
    end;

    for i := 0 to Pred(FileCount) do begin
        f := FileByIndex(i);
        filename := GetFileName(f);

        // Load Ignore Worldspaces rules
        j := 'FOLIP\' + TrimLeftChars(filename, 4) + ' - Ignore Worldspaces.json';
        if ResourceExists(j) then begin
            AddMessage('Loaded Ignore Worldspaces File: ' + j);
            sub := TJsonObject.Create;
            try
                sub.LoadFromResource(j);
                key := 'Ignore Worldspaces';
                for a := 0 to Pred(sub.A[key].Count) do begin
                    if sIgnoredWorldspaces = '' then
                        sIgnoredWorldspaces := sub.A[key].S[a]
                    else
                        sIgnoredWorldspaces := sIgnoredWorldspaces + ',' + sub.A[key].S[a];
                end;
            finally
                sub.Free;
                AddMessage('Ignored Worldspaces: ' + sIgnoredWorldspaces);
            end;
        end;

        if SameText(filename, sFolipFileName) then
            //FOLIP - New LODs.esp
            iFolip := f
        else if SameText(filename, sFolipPluginFileName + '.esp') then begin
            //FOLIP - After Generation.esp
            iPluginFile := f;

            //Clear out any previous edits to the file.
            if HasGroup(iPluginFile, 'STAT') then begin
                RemoveNode(GroupBySignature(iPluginFile, 'STAT'));
            end;
            if HasGroup(iPluginFile, 'CELL') then begin
                RemoveNode(GroupBySignature(iPluginFile, 'CELL'));
            end;
            if HasGroup(iPluginFile, 'WRLD') then begin
                RemoveNode(GroupBySignature(iPluginFile, 'WRLD'));
            end;
        end
        else if SameText(filename, sFolipBeforeGeneration + '.esp') then begin
            //FOLIP - Before Generation.esp
            iBeforeGeneration := f;
            // Get form lists from Before Generation plugin
            formLists := GroupBySignature(iBeforeGeneration, 'FLST');
        end;
    end;

    if not Assigned(iFolip) then begin
        MessageDlg('Please enable ' + sFolipFileName + ' before continuing.', mtError, [mbOk], 0);
        Result := 0;
        Exit;
    end;
    if not Assigned(iPluginFile) then begin
        iPluginFile := AddNewFileName(sFolipPluginFileName + '.esp', bLightPlugin);
        AddMasterIfMissing(iPluginFile, 'Fallout4.esm');
    end;

    SpecificRecordEdits;
    RemoveHasDistantLOD;

    MessageDlg('Patch generated successfully!' + #13#10#13#10 + 'Do not forget to save the plugin.', mtInformation, [mbOk], 0);
    Result := 0;
end;

procedure RemoveHasDistantLOD;
{
    Removes the Has Distant LOD flag from all STAT records.
}
var
    i, j, idx: integer;
    f, p: IwbFile;
    g: IwbGroupRecord;
    n, r: IwbElement;
    editorid, loadOrderFormId: string;
    tlStats, tlStatsWithVWD: TList;
begin
    tlStats := TList.Create;
    tlStatsWithVWD := TList.Create;
    try
        for i := 0 to Pred(FileCount) do begin
            f := FileByIndex(i);
            //STAT
            g := GroupBySignature(f, 'STAT');
            for j := 0 to Pred(ElementCount(g)) do begin
                r := ElementByIndex(g, j);
                if not IsWinningOverride(r) then continue;
                if GetElementEditValues(r, 'Record Header\Record Flags\Has Distant LOD') <> '1' then begin
                    if bRemoveVWD then SetVisibleWhenDistantFromReferencedBase(r, False);
                    continue;
                end;
                editorid := GetElementEditValues(r, 'EDID');
                if ContainsText(editorid, 'FOLIP_') then continue;

                if not bLimitedHasDistantLODRemoval then begin
                    tlStats.Add(r);
                    continue;
                end;
                loadOrderFormId := IntToHex(GetLoadOrderFormID(r), 8);
                idx := slStatsWithOverrides.IndexOf(loadOrderFormId);
                if idx > -1 then begin
                    tlStats.Add(r);
                    continue;
                end;
                if DoesStatHaveCobj(r) then begin
                    tlStats.Add(r);
                    continue;
                end;
                if GetElementEditValues(r, 'Record Header\Record Flags\Is Marker') = '1' then begin
                    tlStats.Add(r);
                    continue;
                end;
                tlStatsWithVWD.Add(r);
            end;
        end;

        for i := 0 to Pred(tlStats.Count) do begin
            r := ObjectToElement(tlStats[i]);
            if DoWeNeedToModifyStatHasDistantLOD(r, false) then begin
                p := RefMastersDeterminePlugin(r);
                n := wbCopyElementToFile(r, p, False, True);
                SetElementNativeValues(n, 'Record Header\Record Flags\Has Distant LOD', 0);
                AddMessage('Removed Has Distant LOD flag from ' + ShortName(n));
            end;
            if bRemoveVWD then SetVisibleWhenDistantFromReferencedBase(r, False);
        end;

        if bAddVWD then begin
            for i := 0 to Pred(tlStatsWithVWD.Count) do begin
                r := ObjectToElement(tlStatsWithVWD[i]);
                if DoWeNeedToModifyStatHasDistantLOD(r, true) then begin
                    p := RefMastersDeterminePlugin(r);
                    n := wbCopyElementToFile(r, p, False, True);
                    SetElementEditValues(n, 'Record Header\Record Flags\Has Distant LOD', '1');
                    AddMessage('Added Has Distant LOD flag to ' + ShortName(n));
                end;
                SetVisibleWhenDistantFromReferencedBase(r, True);
            end;
        end;
    finally
        tlStats.Free;
        tlStatsWithVWD.Free;
    end;
end;

function DoWeNeedToModifyStatHasDistantLOD(r: IwbElement; desiredHasDistantLOD: Boolean): Boolean;
{
    Checks if the STAT record needs to be modified based off its Has Distant LOD value.
}
var
    ovr: IwbElement;
    bHasDistantLOD: Boolean;
begin
    Result := False;
    if bRemoveBeforeGeneration then ovr := WinningOverrideIgnoringThisFile(r, sFolipBeforeGeneration + '.esp') else ovr := WinningOverride(r);
    if GetElementEditValues(ovr, 'Record Header\Record Flags\Has Distant LOD') <> '1' then bHasDistantLOD := False else bHasDistantLOD := True;
    if bHasDistantLOD <> desiredHasDistantLOD then Result := true;
end;

function WinningOverrideIgnoringThisFile(r: IwbElement; f: string): IwbElement;
{
    Given a record and filename, return the winning override ignoring the given filename if present.
}
var
    i: integer;
    m, previousOverride, ovr: IwbElement;
    filename: string;
begin
    m := MasterOrSelf(r);
    if OverrideCount(m) > 0 then begin
        for i := Pred(OverrideCount(m)) downto 0 do begin
            ovr := OverrideByIndex(m, i);
            filename := GetFileName(GetFile(ovr));
            if SameText(filename, f) then continue else break;
        end;
    end else begin
        ovr := r;
    end;
    Result := ovr;
end;

function DoesStatHaveCobj(r: IwbElement): Boolean;
{
    Checks if the STAT record has a COBJ.
}
var
    i, j: integer;
    e, f: IwbElement;
begin
    Result := False;
    for i := Pred(ReferencedByCount(r)) downto 0 do begin
        e := ReferencedByIndex(r, i);
        if Signature(e) = 'COBJ' then begin
            Result := True;
            Exit;
        end
        else if Signature(e) = 'FLST' then begin
            for j := Pred(ReferencedByCount(e)) downto 0 do begin
                f := ReferencedByIndex(e, j);
                if Signature(f) = 'COBJ' then begin
                    Result := True;
                    Exit;
                end;
            end;
        end;
    end;
end;

procedure SetVisibleWhenDistantFromReferencedBase(base: IwbElement; value: Boolean);
var
    i: integer;
    p: IwbFile;
    r, rCell, rWrld, n: IwbElement;
begin
    for i := Pred(ReferencedByCount(base)) downto 0 do begin
        r := ReferencedByIndex(base, i);
        if Signature(r) <> 'REFR' then continue;
        if GetIsDeleted(r) then continue;
        if GetIsCleanDeleted(r) then continue;
        if not IsWinningOverride(r) then continue;
        if (GetIsVisibleWhenDistant(r) = value) then continue;
        rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
        if GetElementEditValues(rCell, 'DATA - Flags\Is Interior Cell') = 1 then continue;
        rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
        if Pos(RecordFormIdFileId(rWrld), sIgnoredWorldspaces) <> 0 then continue;
        if IsRefPrecombined(r) then continue;
        if slOverrides.IndexOf(RecordFormIdFileId(r)) > -1 then continue; // Skip if already processed
        if GetElementEditValues(r, 'Record Header\Record Flags\LOD Respects Enable State') <> '0' then continue;
        p := RefMastersDeterminePlugin(rCell);
        p := RefMastersDeterminePlugin(rWrld);
        p := RefMastersDeterminePlugin(r);
        n := wbCopyElementToFile(rCell, p, False, True);
        n := wbCopyElementToFile(rWrld, p, False, True);
        n := CopyElementToFileWithVC(r, p);
        SetIsVisibleWhenDistant(n, value);
        if value then AddMessage(#9 + 'Added Visible When Distant to ' + Name(n))
        else AddMessage(#9 + 'Removed Visible When Distant from ' + Name(n));
    end;
end;

procedure SpecificRecordEdits;
{
    Carries out specific record changes.
}
var
    i: integer;
    f, p: IwbFile;
    r, rCell, rWrld, n: IwbElement;
    base: IwbMainRecord;
    editorid: string;
    tlOverrides, tlParents, tlNeverfades, tlDecals: TList;
begin
    //Fetch formlists
    tlOverrides := TList.Create;
    tlParents := TList.Create;
    tlNeverfades := TList.Create;
    tlDecals := TList.Create;
    for i := 0 to Pred(ElementCount(formLists)) do begin
        f := WinningOverride(ElementByIndex(formLists, i));
        AddMessage(ShortName(f));
        editorid := GetElementEditValues(f, 'EDID');
        if editorid = 'FOLIP_Overrides' then AddFormlistToTList(f, tlOverrides)
        else if editorid = 'FOLIP_Parents' then AddFormlistToTList(f, tlParents)
        else if editorid = 'FOLIP_Neverfades' then AddFormlistToTList(f, tlNeverfades)
        else if editorid = 'FOLIP_Decals' then AddFormlistToTList(f, tlDecals);
    end;

    //Add Enable Parents to plugin
    for i := 0 to Pred(tlParents.Count) do begin
        r := ObjectToElement(tlParents[i]);
        rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
        rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
        p := RefMastersDeterminePlugin(rCell);
        p := RefMastersDeterminePlugin(rWrld);
        p := RefMastersDeterminePlugin(r);
        n := wbCopyElementToFile(rCell, p, False, True);
        n := wbCopyElementToFile(rWrld, p, False, True);
        n := CopyElementToFileWithVC(r, p);
    end;
    tlParents.Free;

    //Add Neverfades to plugin
    for i := 0 to Pred(tlNeverfades.Count) do begin
        r := ObjectToElement(tlNeverfades[i]);
        rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
        rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
        p := RefMastersDeterminePlugin(rCell);
        p := RefMastersDeterminePlugin(rWrld);
        p := RefMastersDeterminePlugin(r);
        n := wbCopyElementToFile(rCell, p, False, True);
        n := wbCopyElementToFile(rWrld, p, False, True);
        n := CopyElementToFileWithVC(r, p);
    end;
    tlNeverfades.Free;

    //Add Decals to plugin
    for i := 0 to Pred(tlDecals.Count) do begin
        r := ObjectToElement(tlDecals[i]);
        rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
        rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
        p := RefMastersDeterminePlugin(rCell);
        p := RefMastersDeterminePlugin(rWrld);
        n := wbCopyElementToFile(rCell, p, False, True);
        n := wbCopyElementToFile(rWrld, p, False, True);
        n := wbCopyElementToFile(r, p, True, True);
    end;
    tlDecals.Free;

    //Remove Visible when distant from Overrides.
    for i := 0 to Pred(tlOverrides.Count) do begin
        r := ObjectToElement(tlOverrides[i]);
        base := WinningOverride(LinksTo(ElementByPath(r, 'NAME')));
        editorid := GetElementEditValues(base,'EDID');
        slStatsWithOverrides.Add(IntToHex(GetLoadOrderFormID(base), 8));
        if ContainsText(editorid, 'FOLIP_') then continue; //Skip FOLIP Fake Statics
        rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
        rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
        p := RefMastersDeterminePlugin(rCell);
        p := RefMastersDeterminePlugin(rWrld);
        p := RefMastersDeterminePlugin(r);
        n := wbCopyElementToFile(rCell, p, False, True);
        n := wbCopyElementToFile(rWrld, p, False, True);
        n := CopyElementToFileWithVC(r, p);
        SetIsVisibleWhenDistant(n, False);
        slOverrides.Add(RecordFormIdFileId(n));
    end;
    tlOverrides.Free;
end;

procedure AddFormlistToTList(flst: IwbElement; var list: TList);
{
    Adds all formids in a formlist to the input TList.
}
var
    formids, r: IwbElement;
    i: integer;
begin
    formids := ElementByName(flst, 'FormIDs');
    for i := 0 to Pred(ElementCount(formids)) do begin
        r := LinksTo(ElementByIndex(formids, i));
        list.Add(r);
    end;
end;

function Finalize: integer;
{
    This function is called at the end.
}
begin
    slStatsWithOverrides.Free;
    slOverrides.Free;

    //Save user settings
    AddMessage('Saving user settings to ' + wbDataPath + sUserSettingsFileName);
    joUserSettings.S['BeforeGenerationPluginName'] := sFolipBeforeGeneration;
    joUserSettings.S['AfterGenerationPluginName'] := sFolipPluginFileName;
    joUserSettings.S['LightPlugin'] := BoolToStr(bLightPlugin);
    joUserSettings.S['RemoveVWD'] := BoolToStr(bRemoveVWD);
    joUserSettings.S['LimitedHasDistantLODRemoval'] := BoolToStr(bLimitedHasDistantLODRemoval);
    joUserSettings.S['AddVWD'] := BoolToStr(bAddVWD);
    joUserSettings.S['SkipPrecombined'] := BoolToStr(bSkipPrecombined);
    joUserSettings.S['RemoveBeforeGeneration'] := BoolToStr(bRemoveBeforeGeneration);

    joUserSettings.SaveToFile(wbDataPath + sUserSettingsFileName, False, TEncoding.UTF8, True);

    joUserSettings.Free;

    Result := 0;
end;

function MainMenuForm: Boolean;
{
    Main menu form.
}
var
    frm: TForm;
    btnStart, btnCancel: TButton;
    edPluginName, edBeforeGen: TEdit;
    pnl: TPanel;
    picFolip: TPicture;
    fImage: TImage;
    gbOptions: TGroupBox;
    chkLightPlugin, chkLimited, chkRemoveVWD, chkAddVWD, chkSkipPrecombined, chkRemoveBeforeGeneration: TCheckBox;
begin
    frm := TForm.Create(nil);
    try
        frm.Caption := 'FOLIP - After Generation';
        frm.Width := 600;
        frm.Height := 510;
        frm.Position := poMainFormCenter;
        frm.BorderStyle := bsDialog;
        frm.KeyPreview := True;
        frm.OnClose := frmOptionsFormClose;
        frm.OnKeyDown := FormKeyDown;

        picFolip := TPicture.Create;
        picFolip.LoadFromFile(ScriptsPath() + 'FOLIP\FOLIP.jpg');

        fImage := TImage.Create(frm);
		fImage.Picture := picFolip;
		fImage.Parent := frm;
        fImage.Width := 576;
		fImage.Height := 278;
		fImage.Left := 6;
		fImage.Top := 12;
        fImage.Stretch := True;

        gbOptions := TGroupBox.Create(frm);
        gbOptions.Parent := frm;
        gbOptions.Left := 6;
        gbOptions.Top := fImage.Top + fImage.Height + 24;
        gbOptions.Width := frm.Width - 30;
        gbOptions.Caption := 'FOLIP - After Generation';
        gbOptions.Height := 254;

        edBeforeGen := TEdit.Create(gbOptions);
        edBeforeGen.Parent := gbOptions;
        edBeforeGen.Name := 'edBeforeGen';
        edBeforeGen.Left := 160;
        edBeforeGen.Top := 30;
        edBeforeGen.Width := 180;
        edBeforeGen.Hint := 'Specify the Before Generation plugin name you previously used.';
        edBeforeGen.ShowHint := True;
        CreateLabel(gbOptions, 16, edBeforeGen.Top + 4, 'Before Generation Plugin:');

        edPluginName := TEdit.Create(gbOptions);
        edPluginName.Parent := gbOptions;
        edPluginName.Name := 'edPluginName';
        edPluginName.Left := edBeforeGen.Left;
        edPluginName.Top := edBeforeGen.Top + 30;
        edPluginName.Width := 180;
        edPluginName.Hint := 'Sets the output plugin name for the patch.';
        edPluginName.ShowHint := True;
        CreateLabel(gbOptions, 73, edPluginName.Top + 4, 'Output Plugin:');

        chkLightPlugin := TCheckBox.Create(gbOptions);
        chkLightPlugin.Parent := gbOptions;
        chkLightPlugin.Left := edPluginName.Left + edPluginName.Width + 16;
        chkLightPlugin.Top := edPluginName.Top + 2;
        chkLightPlugin.Width := 120;
        chkLightPlugin.Caption := 'Flag as ESL';
        chkLightPlugin.Hint := 'Flags the output plugin as ESL.';
        chkLightPlugin.ShowHint := True;

        chkLimited := TCheckBox.Create(gbOptions);
        chkLimited.Parent := gbOptions;
        chkLimited.Left :=  edBeforeGen.Left;
        chkLimited.Top := edPluginName.Top + 30;
        chkLimited.Width := 240;
        chkLimited.Caption := 'Limited Has Distant LOD Flag Removal';
        chkLimited.Hint := 'Limits removal of Has Distant LOD flag to only STAT records that have either a constructable object record or an enable parented reference.';
        chkLimited.ShowHint := True;

        chkRemoveVWD := TCheckBox.Create(gbOptions);
        chkRemoveVWD.Parent := gbOptions;
        chkRemoveVWD.Left :=  edBeforeGen.Left;
        chkRemoveVWD.Top := chkLimited.Top + 30;
        chkRemoveVWD.Width := 240;
        chkRemoveVWD.Caption := 'Remove Visible When Distant';
        chkRemoveVWD.Hint := 'Any REFRs whose base STAT record is not flagged Has Distant LOD will also have their Visible When Distant removed.';
        chkRemoveVWD.ShowHint := True;

        chkAddVWD := TCheckBox.Create(gbOptions);
        chkAddVWD.Parent := gbOptions;
        chkAddVWD.Left :=  edBeforeGen.Left;
        chkAddVWD.Top := chkRemoveVWD.Top + 30;
        chkAddVWD.Width := 240;
        chkAddVWD.Caption := 'Add Visible When Distant';
        chkAddVWD.Hint := 'Any REFRs whose base STAT record is flagged Has Distant LOD will also be flagged Visible When Distant.';
        chkAddVWD.ShowHint := True;

        chkSkipPrecombined := TCheckBox.Create(gbOptions);
        chkSkipPrecombined.Parent := gbOptions;
        chkSkipPrecombined.Left :=  edBeforeGen.Left;
        chkSkipPrecombined.Top := chkAddVWD.Top + 30;
        chkSkipPrecombined.Width := 240;
        chkSkipPrecombined.Caption := 'Skip Precombined References';
        chkSkipPrecombined.Hint := 'Any REFRs that are precombined will be skipped.';
        chkSkipPrecombined.ShowHint := True;

        chkRemoveBeforeGeneration := TCheckBox.Create(gbOptions);
        chkRemoveBeforeGeneration.Parent := gbOptions;
        chkRemoveBeforeGeneration.Left :=  edBeforeGen.Left;
        chkRemoveBeforeGeneration.Top := chkSkipPrecombined.Top + 30;
        chkRemoveBeforeGeneration.Width := 300;
        chkRemoveBeforeGeneration.Caption := 'I will be removing the Before Generation plugin';
        chkRemoveBeforeGeneration.Hint := 'Check if you will be removing the Before Generation plugin once complete with the process.';
        chkRemoveBeforeGeneration.ShowHint := True;

        btnStart := TButton.Create(frm);
        btnStart.Parent := frm;
        btnStart.Caption := 'Start';
        btnStart.ModalResult := mrOk;
        btnStart.Top := gbOptions.Top + gbOptions.Height + 24;

        btnCancel := TButton.Create(frm);
        btnCancel.Parent := frm;
        btnCancel.Caption := 'Cancel';
        btnCancel.ModalResult := mrCancel;
        btnCancel.Top := btnStart.Top;

        btnStart.Left := gbOptions.Width - btnStart.Width - btnCancel.Width - 16;
        btnCancel.Left := btnStart.Left + btnStart.Width + 8;

        pnl := TPanel.Create(frm);
        pnl.Parent := frm;
        pnl.Left := gbOptions.Left;
        pnl.Top := btnStart.Top - 12;
        pnl.Width := gbOptions.Width;
        pnl.Height := 2;

        edPluginName.Text := sFolipPluginFileName;
        edBeforeGen.Text := sFolipBeforeGeneration;
        chkLightPlugin.Checked := bLightPlugin;
        chkLimited.Checked := bLimitedHasDistantLODRemoval;
        chkRemoveVWD.Checked := bRemoveVWD;
        chkAddVWD.Checked := bAddVWD;
        chkSkipPrecombined.Checked := bSkipPrecombined;
        chkRemoveBeforeGeneration.Checked := bRemoveBeforeGeneration;

        frm.ActiveControl := btnStart;
        frm.ScaleBy(uiScale, 100);
        frm.Font.Size := 8;
        frm.Height := btnStart.Top + btnStart.Height + btnStart.Height + 30;

        if frm.ShowModal <> mrOk then begin
            Result := False;
            Exit;
        end
        else Result := True;

        sFolipPluginFileName := edPluginName.Text;
        sFolipBeforeGeneration := edBeforeGen.Text;
        bLightPlugin := chkLightPlugin.Checked;
        bLimitedHasDistantLODRemoval := chkLimited.Checked;
        bRemoveVWD := chkRemoveVWD.Checked;
        bAddVWD := chkAddVWD.Checked;
        bSkipPrecombined := chkSkipPrecombined.Checked;
        bRemoveBeforeGeneration := chkRemoveBeforeGeneration.Checked;

    finally
        frm.Free;
    end;
end;

procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
{
    Cancel if Escape key is pressed.
}
begin
    if Key = VK_ESCAPE then TForm(Sender).ModalResult := mrCancel;
end;

procedure frmOptionsFormClose(Sender: TObject; var Action: TCloseAction);
{
    Close form handler.
}
begin
    if TForm(Sender).ModalResult <> mrOk then Exit
end;

function CreateLabel(aParent: TControl; x, y: Integer; aCaption: string): TLabel;
{
    Create a label.
}
begin
    Result := TLabel.Create(aParent);
    Result.Parent := aParent;
    Result.Left := x;
    Result.Top := y;
    Result.Caption := aCaption;
end;

function RefMastersDeterminePlugin(r: IwbElement): IwbFile;
{
    Adds masters required by the reference to the plugin and returns the plugin.
}
begin
    AddRequiredElementMasters(r, iPluginFile, False, True);
    SortMasters(iPluginFile);
    Result := iPluginFile;
end;

function CopyElementToFileWithVC(e: IwbElement; f: IwbFile): IwbElement;
{
    Copies an element (e) to a file (f), but also copies the version control data from the element being copied.
}
var
    n: IwbElement;
begin
    n := wbCopyElementToFile(e, f, False, True);
    SetFormVCS1(n, GetFormVCS1(e));
    SetFormVCS2(n, GetFormVCS2(e));
    Result := n;
end;

function IsRefPrecombined(r: IwbElement): Boolean;
{
    Checks if a reference is precombined.
}
var
    i, t, preCombinedRefsCount, rc: Integer;
    rCell, refs: IwbElement;
begin
    Result := false;
    t := ReferencedByCount(r) - 1;
    if t < 0 then Exit;
    for i := 0 to t do begin
        rCell := ReferencedByIndex(r, i);
        if Signature(rCell) <> 'CELL' then continue;
        if not IsWinningOverride(rCell) then continue;
        //AddMessage(ShortName(r) + ' is referenced in ' + Name(c));
        Result := true;
        Exit;
    end;
end;

function GetIsCleanDeleted(r: IwbElement): Boolean;
{
    Checks to see if a reference has an XESP set to opposite of the PlayerRef
}
begin
    Result := False;
    if not ElementExists(r, 'XESP') then Exit;
    if not GetElementEditValues(r, 'XESP\Flags\Set Enable State to Opposite of Parent') = '1' then Exit;
    if GetElementEditValues(r, 'XESP\Reference') <> 'PlayerRef [PLYR:00000014]' then Exit;
    Result := True;
end;

function BoolToStr(b: boolean): string;
{
    Given a boolean, return a string.
}
begin
    if b then Result := 'true' else Result := 'false';
end;

function TrimRightChars(s: string; chars: integer): string;
{
    Returns right string - chars
}
begin
    Result := RightStr(s, Length(s) - chars);
end;

function TrimLeftChars(s: string; chars: integer): string;
{
    Returns left string - chars
}
begin
    Result := LeftStr(s, Length(s) - chars);
end;

function RecordFormIdFileId(e: IwbElement): string;
{
    Returns the record ID of an element.
}
begin
    Result := TrimRightChars(IntToHex(FixedFormID(e), 8), 2) + ':' + GetFileName(GetFile(MasterOrSelf(e)));
end;

function StrToBool(str: string): boolean;
{
    Given a string, return a boolean.
}
begin
    if (LowerCase(str) = 'true') or (str = '1') then Result := True else Result := False;
end;

function Fallback(str, fallback: string): string;
{
    Set a fallback value if blank.
}
begin
    if str = '' then Result := fallback else Result := str;
end;

end.