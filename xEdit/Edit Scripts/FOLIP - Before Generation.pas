{
    Collect LOD Assets for Fallout 4.

    TODO:
    * Check if object is in a settlement and scrappable. Test to see if LOD Respects Enable State flag works on scrapped items like they do for Enable Markers. It may require persistence, and only would work in Fallout4.esm
    * Handle existing Enable Parents that are Opposite the Enable Marker as regards LOD Respects Enable State Flag, as the game isn't able to interpret the opposite method for lod.
    * Automatic handling of missing LOD materials
        * Create Missing Material
        * Create TexGen Rule
}
unit FOLIP;

// ----------------------------------------------------
//Create variables that will need to be used accross multiple functions/procedures.
// ----------------------------------------------------
var
    tlStats, tlActiFurnMstt, tlMswp, tlMasterCells, tlPluginCells, tlEnableParents, tlStolenForms, tlTxst: TList;
    slNifFiles, slUsedLODNifFiles, slMatFiles, slCheckedModels, slMeshCheckMissingMaterials, slMeshCheckNonLODMaterials,
    slMeshCheckNoMaterialSpecified, slMismatchedFullModelToLODMaterials, slTopLevelModPatternPaths, slMessages, slMissingLODMessages,
    slMissingColorRemaps, slFullLODMessages, slPluginFiles, slHasLOD, slFOLIPTexgen_noalpha, slFOLIPTexgen_copy, slFOLIPTexgen_alpha,
    slTexgen_copy, slTexgen_alpha, slTexgen_noalpha, slOutsideUVRange, slContainers: TStringList;
    flOverrides, flMultiRefLOD, flParents, flNeverfades, flDecals, flFakeStatics, flRemoveIsFullLOD: IInterface;
    iFolipMasterFile, iFolipPluginFile, iCurrentPlugin: IwbFile;
    uiScale: integer;
    sFolipPluginFileName, sFolipAfterGenerationPluginFileName, sEnableParentFormidExclusions, sIgnoredWorldspaces, FOLIPTempPath: string;
    bFakeStatics, bForceLOD8, bReportMissingLOD, bReportUVs, bReportNonLODMaterials, bSaveUserRules, bUserRulesChanged, bRespectEnableMarkers,
    bIgnoreNoLOD, bLightPlugin, bRemoveVWD, bLimitedHasDistantLODRemoval, bAddVWD, bSkipPrecombined, bRemoveBeforeGeneration, bMakeMissingMaterials,
    bPreviousBeforeGenerationPresent: Boolean;
    joRules, joMswpMap, joUserRules, joMultiRefLOD, joUserSettings: TJsonObject;

    lvRules: TListView;
    btnRuleOk, btnRuleCancel: TButton;

const
    sFolipMasterFileName = 'FOLIP - Master.esm';
    sFolipFileName = 'FOLIP - New LODs.esp';
    sFO4LODGenFileName = 'FO4LODGen.esp';
    sUserSettingsFileName = 'FOLIP\UserSettings.json';

// ----------------------------------------------------
// Main functions and procedures go up immediately below.
// ----------------------------------------------------

function Initialize:integer;
{
    This function is called at the beginning.
}
var
    bLoadDefaults: Boolean;
begin
    CreateObjects;
    bLoadDefaults := True;
    bPreviousBeforeGenerationPresent := False;
    if ResourceExists(sUserSettingsFileName) then begin
        AddMessage('Loading user settings from ' + sUserSettingsFileName);
        joUserSettings.LoadFromResource(sUserSettingsFileName);
        try
            bFakeStatics := StrToBool(Fallback(joUserSettings.S['FakeStatics'], 'True'));
            bForceLOD8 := StrToBool(joUserSettings.S['ForceLOD8']);
            bIgnoreNoLOD := StrToBool(joUserSettings.S['IgnoreNoLOD']);
            bMakeMissingMaterials := StrToBool(Fallback(joUserSettings.S['MakeMissingMaterials'], 'True'));
            bReportNonLODMaterials := StrToBool(joUserSettings.S['ReportNonLODMaterials']);
            bReportUVs := StrToBool(joUserSettings.S['ReportUVs']);
            bReportMissingLOD := StrToBool(joUserSettings.S['ReportMissingLOD']);
            bRespectEnableMarkers := StrToBool(Fallback(joUserSettings.S['RespectEnableMarkers'], 'True'));
            sFolipPluginFileName := Fallback(joUserSettings.S['BeforeGenerationPluginName'], 'FOLIP - Before Generation');

            sFolipAfterGenerationPluginFileName := Fallback(joUserSettings.S['AfterGenerationPluginName'], 'FOLIP - After Generation');
            bLightPlugin := StrToBool(Fallback(joUserSettings.S['LightPlugin'], 'True'));
            bRemoveVWD := StrToBool(Fallback(joUserSettings.S['RemoveVWD'], 'True'));
            bLimitedHasDistantLODRemoval := StrToBool(joUserSettings.S['LimitedHasDistantLODRemoval']);
            bAddVWD := StrToBool(joUserSettings.S['AddVWD']);
            bSkipPrecombined := StrToBool(Fallback(joUserSettings.S['SkipPrecombined'], 'True'));
            bRemoveBeforeGeneration := StrToBool(joUserSettings.S['RemoveBeforeGeneration']);
            bLoadDefaults := False;
        except
            AddMessage('User settings are incomplete. Loading defaults.');
        end;
    end;
    if bLoadDefaults then begin
        //Set default options.
        bFakeStatics := True;
        bForceLOD8 := False;
        bIgnoreNoLOD := False;

        bMakeMissingMaterials := True;

        // This is used to report if a LOD material appears to be using a non-LOD texture.
        bReportNonLODMaterials := False;
        // This is used to report if a LOD mesh appears to have UVs outside of range.
        bReportUVs := False;
        // This is used to inform a LOD author of models that are missing LOD that are of a certain object bounds size or more.
        bReportMissingLOD := False;
        // This is used to ensure enable parented objects use LOD Respects Enable State
        bRespectEnableMarkers := True;

        //Default plugin name.
        sFolipPluginFileName := 'FOLIP - Before Generation';
        sFolipAfterGenerationPluginFileName := 'FOLIP - After Generation';

        bLightPlugin := True;
        bRemoveVWD := True;
        bSkipPrecombined := True;
        bRemoveBeforeGeneration := False;
    end;

    //Used to tell the Rule Editor whether or not to save changes.
    bSaveUserRules := False;
    bUserRulesChanged := False;

    //Get scaling
    uiScale := Screen.PixelsPerInch * 100 / 96;
    AddMessage('UI scale: ' + IntToStr(uiScale));

    sIgnoredWorldspaces := '';
    sEnableParentFormidExclusions := '';


    FetchRules;
    slTopLevelModPatternPaths.Add('');

    if wbSimpleRecords then begin
        MessageDlg('Simple records must be unchecked in xEdit options', mtInformation, [mbOk], 0);
        Result := 1;
        Exit;
    end;

    //Display the main menu. If the user presses the cancel button, exit.
    if MainMenuForm then BeforeGeneration;

    Result := 0;
end;

procedure BeforeGeneration;
var
    bSkip: Boolean;
    sFolipPluginFileNameSanitized, cmdline: string;
    fs: TFileStream;
begin
    bSkip := False;
    //Create FOLIP plugins
    if not CreatePlugins then Exit;

    SpecificRecordEdits;
    if bSkip then Exit;

    //Clear output directory
    DeleteDirectory(wbScriptsPath + 'FOLIP\output');
    FOLIPTempPath := wbScriptsPath + 'FOLIP\Temp';
    DeleteDirectory(FOLIPTempPath);

    AddMessage('Collecting assets...');
    //Scan archives and loose files.
    slContainers := TStringList.Create;
    ResourceContainerList(slContainers);
    FilesInContainers(slContainers);
    slContainers.Free;
    AddMessage('Found ' + IntToStr(slNifFiles.Count) + ' lod models.');
    AddMessage('Found ' + IntToStr(slMatFiles.Count) + ' lod materials.');

    if bSkip then Exit;

    AddMessage('Collecting records...');
    CollectRecords;

    //Assign lod models to STAT records.
    AddMessage('Assigning LOD models to STAT records...');
    AssignLODModelsList;

    //Add fake statics for MSTT, FURN, and ACTI that have lod.
    if bFakeStatics then ProcessActiFurnMstt;

    CheckUsedLODModels;

    //Add Messages
    ListStringsInStringList(slMessages);
    ListStringsInStringList(slMissingLODMessages);
    ListStringsInStringList(slFullLODMessages);
    ListStringsInStringList(slMissingColorRemaps);

    //Apply lod material swaps.
    AddMessage('Assigning LOD materials to ' + IntToStr(tlMswp.Count) + ' material swaps.');
    AssignLODMaterialsList;
    AddMessage('=======================================================================================');

    if bRespectEnableMarkers then ProcessEnableParents;
    AddMessage('=======================================================================================');

    MultiRefLOD;

    DeleteDirectory(FOLIPTempPath);

    //Save the plugin.
    EnsureDirectoryExists(wbScriptsPath + 'FOLIP\output\');
    fs := TFileStream.Create(wbScriptsPath + 'FOLIP\output\' + sFolipPluginFileName + '.esp', fmCreate);
    try
        FileWriteToStream(iFolipPluginFile, fs, 0);
    finally
        fs.Free;
    end;

    //Save Texgen files
    if bMakeMissingMaterials then begin
        if slTexgen_alpha.Count + slTexgen_copy.Count + slTexgen_noalpha.Count > 0 then AddMessage('Saving TexGen files to ' + wbScriptsPath + 'FOLIP\output\' + 'DynDOLOD');
        sFolipPluginFileNameSanitized := StripNonAlphanumeric(sFolipPluginFileName) + 'esp';
        EnsureDirectoryExists(wbScriptsPath + 'FOLIP\output\' + 'DynDOLOD\');
        if slTexgen_alpha.Count > 0 then slTexgen_alpha.SaveToFile(wbScriptsPath + 'FOLIP\output\' + 'DynDOLOD\DynDOLOD_FO4_TexGen_alpha_' + sFolipPluginFileNameSanitized + '.txt');
        if slTexgen_copy.Count > 0 then slTexgen_copy.SaveToFile(wbScriptsPath + 'FOLIP\output\' + 'DynDOLOD\DynDOLOD_FO4_TexGen_copy_' + sFolipPluginFileNameSanitized + '.txt');
        if slTexgen_noalpha.Count > 0 then slTexgen_noalpha.SaveToFile(wbScriptsPath + 'FOLIP\output\' + 'DynDOLOD\DynDOLOD_FO4_TexGen_noalpha_' + sFolipPluginFileNameSanitized + '.txt');
    end;

    //Zip up output for easy installation
    AddMessage('Zipping up output for easy installation...');
    cmdline := '-Command "Compress-Archive -Path (Get-ChildItem ''' + wbScriptsPath + 'FOLIP\output'').FullName -DestinationPath ''' + wbScriptsPath + 'FOLIP\output\FOLIP Before Generation Output.zip''"';
    AddMessage(cmdline);
    AddMessage('Exit Code: ' + IntToStr(ShellExecuteWait(0, 'open', 'Powershell', cmdline, '', SW_SHOWNORMAL)));

    //Open the output folder in Explorer
    cmdline := '"'+ wbScriptsPath + 'FOLIP\output"';
    ShellExecute(0, 'open', 'explorer', cmdline, '', SW_SHOWNORMAL);

    MessageDlg('Patch generated successfully!' + #13#10#13#10 + 'Install the FOLIP Before Generation Output.zip file in your mod manager.', mtInformation, [mbOk], 0);
end;

function Finalize: integer;
{
    This function is called at the end.
}
begin
    tlStats.Free;
    tlActiFurnMstt.Free;
    tlMswp.Free;
    tlMasterCells.Free;
    tlPluginCells.Free;
    tlEnableParents.Free;
    tlStolenForms.Free;
    tlTxst.Free;

    slPluginFiles.Free;
    slNifFiles.Free;
    slUsedLODNifFiles.Free;
    slMatFiles.Free;
    slTopLevelModPatternPaths.Free;
    slMessages.Free;
    slMissingLODMessages.Free;
    slFullLODMessages.Free;
    slMissingColorRemaps.Free;
    slMeshCheckMissingMaterials.Free;
    slMeshCheckNonLODMaterials.Free;
    slMeshCheckNoMaterialSpecified.Free;
    slCheckedModels.Free;
    slMismatchedFullModelToLODMaterials.Free;
    slHasLOD.Free;
    slFOLIPTexgen_noalpha.Free;
    slFOLIPTexgen_copy.Free;
    slFOLIPTexgen_alpha.Free;
    slTexgen_copy.Free;
    slTexgen_noalpha.Free;
    slTexgen_alpha.Free;
    slOutsideUVRange.Free;

    joRules.Free;
    joMswpMap.Free;

    //Save user rules
    if bSaveUserRules and bUserRulesChanged then begin
        AddMessage('Saving ' + IntToStr(joUserRules.Count) + ' user rule(s) to ' + wbDataPath + 'FOLIP\UserRules.json');
        joUserRules.SaveToFile(wbDataPath + 'FOLIP\UserRules.json', False, TEncoding.UTF8, True);
    end;
    joUserRules.Free;

    //Save user settings
    AddMessage('Saving user settings to ' + wbDataPath + sUserSettingsFileName);
    joUserSettings.S['FakeStatics'] := BoolToStr(bFakeStatics);
    joUserSettings.S['ForceLOD8'] := BoolToStr(bForceLOD8);
    joUserSettings.S['IgnoreNoLOD'] := BoolToStr(bIgnoreNoLOD);
    joUserSettings.S['ReportNonLODMaterials'] := BoolToStr(bReportNonLODMaterials);
    joUserSettings.S['ReportUVs'] := BoolToStr(bReportUVs);
    joUserSettings.S['ReportMissingLOD'] := BoolToStr(bReportMissingLOD);
    joUserSettings.S['RespectEnableMarkers'] := BoolToStr(bRespectEnableMarkers);
    joUserSettings.S['BeforeGenerationPluginName'] := sFolipPluginFileName;
    joUserSettings.S['AfterGenerationPluginName'] := sFolipAfterGenerationPluginFileName;
    joUserSettings.S['LightPlugin'] := BoolToStr(bLightPlugin);
    joUserSettings.S['RemoveVWD'] := BoolToStr(bRemoveVWD);
    joUserSettings.S['LimitedHasDistantLODRemoval'] := BoolToStr(bLimitedHasDistantLODRemoval);
    joUserSettings.S['AddVWD'] := BoolToStr(bAddVWD);
    joUserSettings.S['SkipPrecombined'] := BoolToStr(bSkipPrecombined);
    joUserSettings.S['RemoveBeforeGeneration'] := BoolToStr(bRemoveBeforeGeneration);
    joUserSettings.S['MakeMissingMaterials'] := BoolToStr(bMakeMissingMaterials);

    joUserSettings.SaveToFile(wbDataPath + sUserSettingsFileName, False, TEncoding.UTF8, True);
    joUserSettings.Free;

    Result := 0;
end;

procedure CreateObjects;
{
    Create objects.
}
begin
    //TLists
    tlStats := TList.Create;
    tlActiFurnMstt := TList.Create;
    tlMswp := TList.Create;
    tlMasterCells := TList.Create;
    tlPluginCells := TList.Create;
    tlEnableParents := TList.Create;
    tlStolenForms := TList.Create;
    tlTxst := TList.Create;


    //TStringLists
    slPluginFiles := TStringList.Create;

    slMatFiles := TStringList.Create;
    slMatFiles.Sorted := True;
    slMatFiles.Duplicates := dupIgnore;

    slNifFiles := TStringList.Create;
    slNifFiles.Sorted := True;
    slNifFiles.Duplicates := dupIgnore;

    slUsedLODNifFiles := TStringList.Create;
    slUsedLODNifFiles.Sorted := True;
    slUsedLODNifFiles.Duplicates := dupIgnore;

    slMeshCheckMissingMaterials := TStringList.Create;
    slMeshCheckMissingMaterials.Sorted := True;
    slMeshCheckMissingMaterials.Duplicates := dupIgnore;

    slMeshCheckNonLODMaterials := TStringList.Create;
    slMeshCheckNonLODMaterials.Sorted := True;
    slMeshCheckNonLODMaterials.Duplicates := dupIgnore;

    slMeshCheckNoMaterialSpecified := TStringList.Create;
    slMeshCheckNoMaterialSpecified.Sorted := True;
    slMeshCheckNoMaterialSpecified.Duplicates := dupIgnore;

    slMismatchedFullModelToLODMaterials  := TStringList.Create;
    slMismatchedFullModelToLODMaterials.Sorted := True;
    slMismatchedFullModelToLODMaterials.Duplicates := dupIgnore;

    slCheckedModels := TStringList.Create;
    slHasLOD := TStringList.Create;

    slTopLevelModPatternPaths := TStringList.Create;
    slMessages := TStringList.Create;
    slMessages.Sorted := True;
    slMissingLODMessages := TStringList.Create;
    slMissingLODMessages.Sorted := True;

    slOutsideUVRange := TStringList.Create;
    slOutsideUVRange.Sorted := True;
    slOutsideUVRange.Duplicates := dupIgnore;

    slFullLODMessages := TStringList.Create;
    slFullLODMessages.Sorted := True;

    slMissingColorRemaps := TStringList.Create;
    slMissingColorRemaps.Sorted := True;

    slFOLIPTexgen_noalpha := TStringList.Create;
    if FileExists(wbDataPath + 'DynDOLOD\DynDOLOD_FO4_TexGen_noalpha_folipnewlodsesp.txt') then begin
        slFOLIPTexgen_noalpha.LoadFromFile(wbDataPath + 'DynDOLOD\DynDOLOD_FO4_TexGen_noalpha_folipnewlodsesp.txt');
        AddMessage('Loaded TexGen noalpha rules from ' + wbDataPath + 'DynDOLOD\DynDOLOD_FO4_TexGen_noalpha_folipnewlodsesp.txt');
    end;
    slFOLIPTexgen_copy := TStringList.Create;
    if FileExists(wbDataPath + 'DynDOLOD\DynDOLOD_FO4_TexGen_copy_folipnewlodsesp.txt') then begin
        slFOLIPTexgen_copy.LoadFromFile(wbDataPath + 'DynDOLOD\DynDOLOD_FO4_TexGen_copy_folipnewlodsesp.txt');
        AddMessage('Loaded TexGen copy rules from ' + wbDataPath + 'DynDOLOD\DynDOLOD_FO4_TexGen_copy_folipnewlodsesp.txt');
    end;
    slFOLIPTexgen_alpha := TStringList.Create;
    if FileExists(wbDataPath + 'DynDOLOD\DynDOLOD_FO4_TexGen_alpha_folipnewlodsesp.txt') then begin
        slFOLIPTexgen_alpha.LoadFromFile(wbDataPath + 'DynDOLOD\DynDOLOD_FO4_TexGen_alpha_folipnewlodsesp.txt');
        AddMessage('Loaded TexGen alpha rules from ' + wbDataPath + 'DynDOLOD\DynDOLOD_FO4_TexGen_alpha_folipnewlodsesp.txt');
    end;
    slTexgen_copy := TStringList.Create;
    slTexgen_alpha := TStringList.Create;
    slTexgen_noalpha := TStringList.Create;

    //TJsonObjects
    joRules := TJsonObject.Create;
    joMswpMap := TJsonObject.Create;
    joMultiRefLOD := TJsonObject.Create;
    joUserSettings := TJsonObject.Create;
end;

// ----------------------------------------------------
// UI functions and procedures go below.
// ----------------------------------------------------

function MainMenuForm: Boolean;
{
    Main menu form.
}
var
    frm: TForm;
    btnRuleEditor, btnStart, btnCancel: TButton;
    edPluginName: TEdit;
    pnl: TPanel;
    picFolip: TPicture;
    fImage: TImage;
    gbOptions: TGroupBox;
    chkFakeStatics, chkForceLOD8, chkIgnoreNoLOD, chkReportNonLODMaterials, chkReportUVs, chkMakeMissingMaterials, chkReportMissingLOD, chkRespectEnableMarkers: TCheckBox;
begin
    frm := TForm.Create(nil);
    try
        frm.Caption := 'FOLIP xEdit Patcher';
        frm.Width := 640;
        frm.Height := 540;
        frm.Position := poMainFormCenter;
        frm.BorderStyle := bsDialog;
        frm.KeyPreview := True;
        frm.OnClose := frmOptionsFormClose;
        frm.OnKeyDown := FormKeyDown;

        picFolip := TPicture.Create;
        picFolip.LoadFromFile(wbScriptsPath + 'FOLIP\FOLIP.jpg');

        fImage := TImage.Create(frm);
		fImage.Picture := picFolip;
		fImage.Parent := frm;
        fImage.Width := 576;
		fImage.Height := 278;
		fImage.Left := 26;
		fImage.Top := 12;
        fImage.Stretch := True;

        gbOptions := TGroupBox.Create(frm);
        gbOptions.Parent := frm;
        gbOptions.Left := 6;
        gbOptions.Top := fImage.Top + fImage.Height + 24;
        gbOptions.Width := frm.Width - 30;
        gbOptions.Caption := 'FOLIP - Before Generation';
        gbOptions.Height := 134;

        btnRuleEditor := TButton.Create(frm);
        btnRuleEditor.Parent := frm;
        btnRuleEditor.Caption := 'Rule Editor';
        btnRuleEditor.OnClick := RuleEditor;
        btnRuleEditor.Width := 100;
        btnRuleEditor.Left := 16;
        btnRuleEditor.Top := gbOptions.Top + gbOptions.Height + 24;

        edPluginName := TEdit.Create(gbOptions);
        edPluginName.Parent := gbOptions;
        edPluginName.Name := 'edPluginName';
        edPluginName.Left := 104;
        edPluginName.Top := 30;
        edPluginName.Width := 180;
        edPluginName.Hint := 'Sets the output plugin name for the patch.';
        edPluginName.ShowHint := True;
        CreateLabel(gbOptions, 16, edPluginName.Top + 4, 'Output Plugin:');

        chkFakeStatics := TCheckBox.Create(gbOptions);
        chkFakeStatics.Parent := gbOptions;
        chkFakeStatics.Left := edPluginName.Left + edPluginName.Width + 16;
        chkFakeStatics.Top := 32;
        chkFakeStatics.Width := 120;
        chkFakeStatics.Caption := 'Create Fake Statics';
        chkFakeStatics.Hint := 'Allows activator (ACTI), door (DOOR), furniture (FURN),'
            + #13#10 + 'and moveable static (MSTT) references to receive LOD by creating'
            + #13#10 + 'invisible static reference duplicates with LOD attached.';
        chkFakeStatics.ShowHint := True;

        chkForceLOD8 := TCheckBox.Create(gbOptions);
        chkForceLOD8.Parent := gbOptions;
        chkForceLOD8.Left := chkFakeStatics.Left + chkFakeStatics.Width + 32;
        chkForceLOD8.Top := chkFakeStatics.Top;
        chkForceLOD8.Width := 120;
        chkForceLOD8.Caption := 'Force LOD8';
        chkForceLOD8.Hint := 'If an object has a LOD4 model assigned but not a LOD8 model,'
            + #13#10 + 'this will use the LOD4 model in LOD8. Use this for increased'
            + #13#10 + 'LOD distance at the cost of some performance. This is better than'
            + #13#10 + 'increasing the fBlockLevel0Distance.';
        chkForceLOD8.ShowHint := True;



        chkReportNonLODMaterials := TCheckBox.Create(gbOptions);
        chkReportNonLODMaterials.Parent := gbOptions;
        chkReportNonLODMaterials.Left := 16;
        chkReportNonLODMaterials.Top := chkForceLOD8.Top + 30;
        chkReportNonLODMaterials.Width := 120;
        chkReportNonLODMaterials.Caption := 'Report Materials';
        chkReportNonLODMaterials.Hint := 'Adds various warnings for debugging LOD materials.';
        chkReportNonLODMaterials.ShowHint := True;

        chkReportUVs := TCheckBox.Create(gbOptions);
        chkReportUVs.Parent := gbOptions;
        chkReportUVs.Left := chkReportNonLODMaterials.Left + chkReportNonLODMaterials.Width + 16;
        chkReportUVs.Top := chkReportNonLODMaterials.Top;
        chkReportUVs.Width := 120;
        chkReportUVs.Caption := 'Report UVs';
        chkReportUVs.Hint := 'Adds warnings to LOD meshes that appear to be'
            + #13#10 + 'outside the 0 to 1 UV range. This is for information'
            + #13#10 + 'purposes only and has no visual benefit.';
        chkReportUVs.ShowHint := True;

        chkRespectEnableMarkers := TCheckBox.Create(gbOptions);
        chkRespectEnableMarkers.Parent := gbOptions;
        chkRespectEnableMarkers.Left := chkFakeStatics.Left;
        chkRespectEnableMarkers.Top := chkReportUVs.Top;
        chkRespectEnableMarkers.Width := 200;
        chkRespectEnableMarkers.Caption := 'Respect Enable Parents';
        chkRespectEnableMarkers.Hint := 'Adds LOD Respects State Flag to relevant'
            + #13#10 + 'enable parented references and works around'
            + #13#10 + 'engine bugs related to its usage.';
        chkRespectEnableMarkers.ShowHint := True;

        chkIgnoreNoLOD := TCheckBox.Create(gbOptions);
        chkIgnoreNoLOD.Parent := gbOptions;
        chkIgnoreNoLOD.Left := chkFakeStatics.Left + chkFakeStatics.Width + 32;
        chkIgnoreNoLOD.Top := chkRespectEnableMarkers.Top;
        chkIgnoreNoLOD.Width := 150;
        chkIgnoreNoLOD.Caption := 'Ignore NoLOD EditorIDs';
        chkIgnoreNoLOD.Hint := 'If the editor id ends in NoLOD, normal operation,'
            + #13#10 + 'would honor that and not attach LOD to it. Checking this'
            + #13#10 + 'will ignore it and use LOD if available.';
        chkIgnoreNoLOD.ShowHint := True;

        chkMakeMissingMaterials := TCheckBox.Create(gbOptions);
        chkMakeMissingMaterials.Parent := gbOptions;
        chkMakeMissingMaterials.Left := chkReportNonLODMaterials.Left;
        chkMakeMissingMaterials.Top := chkReportUVs.Top + 30;
        chkMakeMissingMaterials.Width := 200;
        chkMakeMissingMaterials.Caption := 'Auto Generate Missing Materials';
        chkMakeMissingMaterials.Hint := 'Missing LOD materials will be'
            + #13#10 + 'automatically generated.';
        chkMakeMissingMaterials.ShowHint := True;

        chkReportMissingLOD := TCheckBox.Create(gbOptions);
        chkReportMissingLOD.Parent := gbOptions;
        chkReportMissingLOD.Left := chkFakeStatics.Left;
        chkReportMissingLOD.Top := chkReportUVs.Top + 30;
        chkReportMissingLOD.Width := 200;
        chkReportMissingLOD.Caption := 'Report Large Objects without LOD';
        chkReportMissingLOD.Hint := 'Adds messages about large objects'
            + #13#10 + 'that do not have LOD. This is for information'
            + #13#10 + 'purposes only and has no visual benefit.';
        chkReportMissingLOD.ShowHint := True;

        btnStart := TButton.Create(frm);
        btnStart.Parent := frm;
        btnStart.Caption := 'Start';
        btnStart.ModalResult := mrOk;
        btnStart.Top := btnRuleEditor.Top;

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

        frm.ActiveControl := btnStart;
        frm.ScaleBy(uiScale, 100);
        frm.Font.Size := 8;
        frm.Height := btnStart.Top + btnStart.Height + btnStart.Height + 30;

        edPluginName.Text := sFolipPluginFileName;
        chkFakeStatics.Checked := bFakeStatics;
        chkForceLOD8.Checked := bForceLOD8;
        chkIgnoreNoLOD.Checked := bIgnoreNoLOD;
        chkReportNonLODMaterials.Checked := bReportNonLODMaterials;
        chkReportUVs.Checked := bReportUVs;
        chkReportMissingLOD.Checked := bReportMissingLOD;
        chkRespectEnableMarkers.Checked := bRespectEnableMarkers;
        chkMakeMissingMaterials.Checked := bMakeMissingMaterials;

        if frm.ShowModal <> mrOk then begin
            Result := False;
            Exit;
        end
        else Result := True;

        sFolipPluginFileName := edPluginName.Text;
        bFakeStatics := chkFakeStatics.Checked;
        bForceLOD8 := chkForceLOD8.Checked;
        bIgnoreNoLOD := chkIgnoreNoLOD.Checked;
        bReportNonLODMaterials := chkReportNonLODMaterials.Checked;
        bReportUVs := chkReportUVs.Checked;
        bReportMissingLOD := chkReportMissingLOD.Checked;
        bRespectEnableMarkers := chkRespectEnableMarkers.Checked;
        bMakeMissingMaterials := chkMakeMissingMaterials.Checked;

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
    else bSaveUserRules := True;
end;

// ----------------------------------------------------
// Rules menu

function RuleEditor: Boolean;
var
    i: integer;
    mnRules: TPopupMenu;
    MenuItem: TMenuItem;
    lbl: TLabel;
    frm: TForm;
begin
    frm := TForm.Create(nil);
    try
        frm.Caption := 'Rule Editor';
        frm.Width := 1200;
        frm.Height := 600;
        frm.Position := poMainFormCenter;
        frm.BorderStyle := bsSizeable;
        frm.KeyPreview := True;
        frm.OnClose := frmOptionsFormClose;
        frm.OnKeyDown := FormKeyDown;
        frm.OnResize := frmResize;

        lvRules := TListView.Create(frm);
        lvRules.Parent := frm;

        lvRules.Top := 24;
        lvRules.Width := frm.Width - 36;
        lvRules.Left := (frm.Width - lvRules.Width)/2;
        lvRules.Height := frm.Height - 110;
        lvRules.ReadOnly := True;
        lvRules.ViewStyle := vsReport;
        lvRules.RowSelect := True;
        lvRules.DoubleBuffered := True;
        lvRules.Columns.Add.Caption := 'Mesh / EditorID';
        lvRules.Columns[0].Width := 400;
        lvRules.Columns.Add.Caption := 'HasDistantLOD';
        lvRules.Columns[1].Width := 95;
        lvRules.Columns.Add.Caption := 'IsFullLOD';
        lvRules.Columns[2].Width := 95;
        lvRules.Columns.Add.Caption := 'LOD4';
        lvRules.Columns[3].Width := 400;
        lvRules.Columns.Add.Caption := 'LOD8';
        lvRules.Columns[4].Width := 90;
        lvRules.Columns.Add.Caption := 'LOD16';
        lvRules.Columns[5].Width := 60;
        lvRules.Columns.Add.Caption := 'LOD32';
        lvRules.Columns[6].Width := 60;
        lvRules.OwnerData := True;
        lvRules.OnData := lvRulesData;
        lvRules.OnDblClick := lvRulesDblClick;
        lvRules.Items.Count := joRules.Count;
        CreateLabel(frm, 16, lvRules.Top - 20, 'Mesh/EditorID Rule LOD Assignments');

        mnRules := TPopupMenu.Create(frm);
        lvRules.PopupMenu := mnRules;
        MenuItem := TMenuItem.Create(mnRules);
        MenuItem.Caption := 'Add';
        MenuItem.OnClick := RulesMenuAddClick;
        mnRules.Items.Add(MenuItem);
        MenuItem := TMenuItem.Create(mnRules);
        MenuItem.Caption := 'Delete';
        MenuItem.OnClick := RulesMenuDeleteClick;
        mnRules.Items.Add(MenuItem);
        MenuItem := TMenuItem.Create(mnRules);
        MenuItem.Caption := 'Edit';
        MenuItem.OnClick := RulesMenuEditClick;
        mnRules.Items.Add(MenuItem);

        btnRuleOk := TButton.Create(frm);
        btnRuleOk.Parent := frm;
        btnRuleOk.Caption := 'OK';
        btnRuleOk.ModalResult := mrOk;
        btnRuleOk.Top := lvRules.Height + lvRules.Top + 8;

        btnRuleCancel := TButton.Create(frm);
        btnRuleCancel.Parent := frm;
        btnRuleCancel.Caption := 'Cancel';
        btnRuleCancel.ModalResult := mrCancel;
        btnRuleCancel.Top := btnRuleOk.Top;

        btnRuleOk.Left := (frm.Width - btnRuleOk.Width - btnRuleCancel.Width - 8)/2;
        btnRuleCancel.Left := btnRuleOk.Left + btnRuleOk.Width + 8;

        frm.ScaleBy(uiScale, 100);
        frm.Font.Size := 8;

        if frm.ShowModal <> mrOk then begin
            Result := False;
            Exit;
        end
        else Result := True;

    finally
        frm.Free;
    end;
end;

function EditRuleForm(var key, lod4, lod8, lod16, lod32: string; var hasdistantlod, bIsFullLod: Boolean): Boolean;
var
    frmRule: TForm;
    pnl: TPanel;
    btnOk, btnCancel: TButton;
    edKey, edHasDistantLOD, edlod4, edlod8, edlod16, edlod32: TEdit;
    chkHasDistantLOD, chkIsFullLOD: TCheckBox;
begin
  frmRule := TForm.Create(nil);
  try
    frmRule.Caption := 'Mesh/EditorID Rule';
    frmRule.Width := 600;
    frmRule.Height := 300;
    frmRule.Position := poMainFormCenter;
    frmRule.BorderStyle := bsDialog;
    frmRule.KeyPreview := True;
    frmRule.OnKeyDown := FormKeyDown;
    frmRule.OnClose := frmRuleFormClose;

    edKey := TEdit.Create(frmRule);
    edKey.Parent := frmRule;
    edKey.Name := 'edKey';
    edKey.Left := 120;
    edKey.Top := 12;
    edKey.Width := frmRule.Width - 150;
    CreateLabel(frmRule, 16, edKey.Top + 4, 'Mesh or EditorID');

    chkHasDistantLOD := TCheckBox.Create(frmRule);
    chkHasDistantLOD.Parent := frmRule;
    chkHasDistantLOD.Left := 16;
    chkHasDistantLOD.Top := edKey.Top + 32;
    chkHasDistantLOD.Width := 200;
    chkHasDistantLOD.Caption := 'Has Distant LOD';

    chkIsFullLOD := TCheckBox.Create(frmRule);
    chkIsFullLOD.Parent := frmRule;
    chkIsFullLOD.Left := chkHasDistantLOD.Left + chkHasDistantLOD.Width + 16;
    chkIsFullLOD.Top := edKey.Top + 32;
    chkIsFullLOD.Width := 200;
    chkIsFullLOD.Caption := 'Is Full LOD';

    edlod4 := TEdit.Create(frmRule);
    edlod4.Parent := frmRule;
    edlod4.Name := 'edlod4';
    edlod4.Left := 120;
    edlod4.Top := chkHasDistantLOD.Top + 28;
    edlod4.Width := frmRule.Width - 150;
    CreateLabel(frmRule, 16, edlod4.Top + 4, 'LOD4');

    edlod8 := TEdit.Create(frmRule);
    edlod8.Parent := frmRule;
    edlod8.Name := 'edlod8';
    edlod8.Left := 120;
    edlod8.Top := edlod4.Top + 28;
    edlod8.Width := frmRule.Width - 150;
    CreateLabel(frmRule, 16, edlod8.Top + 4, 'LOD8');

    edlod16 := TEdit.Create(frmRule);
    edlod16.Parent := frmRule;
    edlod16.Name := 'edlod16';
    edlod16.Left := 120;
    edlod16.Top := edlod8.Top + 28;
    edlod16.Width := frmRule.Width - 150;
    CreateLabel(frmRule, 16, edlod16.Top + 4, 'LOD16');

    edlod32 := TEdit.Create(frmRule);
    edlod32.Parent := frmRule;
    edlod32.Name := 'edlod32';
    edlod32.Left := 120;
    edlod32.Top := edlod16.Top + 28;
    edlod32.Width := frmRule.Width - 150;
    CreateLabel(frmRule, 16, edlod32.Top + 4, 'LOD32');

    btnOk := TButton.Create(frmRule);
    btnOk.Parent := frmRule;
    btnOk.Caption := 'OK';
    btnOk.ModalResult := mrOk;
    btnOk.Top := edlod32.Top + (2*edlod32.Height);

    btnCancel := TButton.Create(frmRule);
    btnCancel.Parent := frmRule;
    btnCancel.Caption := 'Cancel';
    btnCancel.ModalResult := mrCancel;
    btnCancel.Top := btnOk.Top;

    btnOk.Left := frmRule.Width - btnOk.Width - btnCancel.Width - 32;
    btnCancel.Left := btnOk.Left + btnOk.Width + 8;

    pnl := TPanel.Create(frmRule);
    pnl.Parent := frmRule;
    pnl.Left := 10;
    pnl.Top := btnOk.Top - 12;
    pnl.Width := frmRule.Width - 32;
    pnl.Height := 2;

    frmRule.Height := btnOk.Top + (4*btnOk.Height);
    frmRule.ScaleBy(uiScale, 100);
    frmRule.Font.Size := 8;

    edKey.Text := key;
    chkHasDistantLOD.Checked := hasdistantlod;
    chkIsFullLOD.Checked := bIsFullLod;
    edlod4.Text := lod4;
    edlod8.Text := lod8;
    edlod16.Text := lod16;
    edlod32.Text := lod32;

    if frmRule.ShowModal <> mrOk then Exit;

    key := LowerCase(edKey.Text);
    hasdistantlod := chkHasDistantLOD.Checked;
    bIsFullLod := chkIsFullLOD.Checked;
    lod4 := edlod4.Text;
    lod8 := edlod8.Text;
    lod16 := edlod16.Text;
    lod32 := edlod32.Text;
    Result := True;
  finally
    frmRule.Free;
  end;
end;

procedure lvRulesData(Sender: TObject; Item: TListItem);
{
    Populate lvRules
}
var
    i: integer;
    key: string;
begin
    key := joRules.Names[Item.Index];
    Item.Caption := key;
    Item.SubItems.Add(Fallback(joRules.O[key].S['hasdistantlod'], 'false'));
    Item.SubItems.Add(Fallback(joRules.O[key].S['bisfulllod'], 'false'));
    Item.SubItems.Add(joRules.O[key].S['level0']);
    Item.SubItems.Add(joRules.O[key].S['level1']);
    Item.SubItems.Add(joRules.O[key].S['level2']);
    Item.SubItems.Add(joRules.O[key].S['level3']);
end;

procedure lvRulesDblClick(Sender: TObject);
{
    Double click to edit rule
}
begin
    RulesMenuEditClick(nil);
end;

procedure RulesMenuAddClick(Sender: TObject);
{
    Add rule
}
var
    idx: integer;
    key, lod4, lod8, lod16, lod32: string;
    hasdistantlod, bIsFullLod: Boolean;
begin
    key := '';
    hasdistantlod := True;
    bIsFullLod := False;
    lod4 := '';
    lod8 := '';
    lod16 := '';
    lod32 := '';

    if not EditRuleForm(key, lod4, lod8, lod16, lod32, hasdistantlod, bIsFullLod) then Exit;

    joRules.O[key].S['hasdistantlod'] := BoolToStr(hasdistantlod);
    joRules.O[key].S['bisfulllod'] := BoolToStr(bIsFullLod);
    joRules.O[key].S['level0'] := lod4;
    joRules.O[key].S['level1'] := lod8;
    joRules.O[key].S['level2'] := lod16;
    joRules.O[key].S['level3'] := lod32;

    joUserRules.O[key].Assign(joRules.O[key]);
    bUserRulesChanged := True;

    lvRules.Items.Count := joRules.Count;
    lvRules.Refresh;
end;

procedure RulesMenuEditClick(Sender: TObject);
{
    Edit rule
}
var
    idx: integer;
    key, lod4, lod8, lod16, lod32: string;
    hasdistantlod, bIsFullLod: Boolean;
begin
    if not Assigned(lvRules.Selected) then Exit;
    idx := lvRules.Selected.Index;

    key := joRules.Names[idx];
    hasdistantlod := StrToBool(joRules.O[key].S['hasdistantlod']);
    bIsFullLod := StrToBool(joRules.O[key].S['bisfulllod']);
    lod4 := joRules.O[key].S['level0'];
    lod8 := joRules.O[key].S['level1'];
    lod16 := joRules.O[key].S['level2'];
    lod32 := joRules.O[key].S['level3'];

    if not EditRuleForm(key, lod4, lod8, lod16, lod32, hasdistantlod, bIsFullLod) then Exit;

    joRules.O[key].S['hasdistantlod'] := BoolToStr(hasdistantlod);
    joRules.O[key].S['bisfulllod'] := BoolToStr(bIsFullLod);
    joRules.O[key].S['level0'] := lod4;
    joRules.O[key].S['level1'] := lod8;
    joRules.O[key].S['level2'] := lod16;
    joRules.O[key].S['level3'] := lod32;

    joUserRules.O[key].Assign(joRules.O[key]);
    bUserRulesChanged := True;

    lvRules.Items.Count := joRules.Count;
    lvRules.Refresh;
end;

procedure RulesMenuDeleteClick(Sender: TObject);
{
    Delete rule
}
var
    idx, uidx: integer;
    key: string;
begin
    if not Assigned(lvRules.Selected) then Exit;
    idx := lvRules.Selected.Index;
    key := joRules.Names[idx];
    joRules.Delete(idx);
    uidx := joUserRules.IndexOf(key);
    if uidx > -1 then begin
        joUserRules.Delete(uidx);
        bUserRulesChanged := True;
    end;
    lvRules.Items.Count := joRules.Count;
    lvRules.Refresh;
end;

procedure frmRuleFormClose(Sender: TObject; var Action: TCloseAction);
{
    Close rule edit menu handler.
}
begin
    if TForm(Sender).ModalResult <> mrOk then Exit;
    if TEdit(TForm(Sender).FindComponent('edKey')).Text = '' then begin
        MessageDlg('Mesh/EditorID must not be empty.', mtInformation, [mbOk], 0);
        Action := caNone;
    end;
end;

procedure frmResize(Sender: TObject);
{
    Handle resizing of elements in the rule menu.
}
var
    frm: TForm;
begin
    try
        frm := TForm(Sender);
        lvRules.Width := frm.Width - 36;
        lvRules.Left := (frm.Width - lvRules.Width)/2;
        lvRules.Height := frm.Height - btnRuleOk.Height - btnRuleOk.Height - btnRuleOk.Height - btnRuleOk.Height;

        btnRuleOk.Top := lvRules.Height + lvRules.Top + 8;
        btnRuleCancel.Top := btnRuleOk.Top;
        btnRuleOk.Left := (frm.Width - btnRuleOk.Width - btnRuleCancel.Width - 8)/2;
        btnRuleCancel.Left := btnRuleOk.Left + btnRuleOk.Width + 8;
    except
        frm := TForm(Sender);
    end;
end;

// ----------------------------------------------------
// Record processing Functions and Procedures go below.
// ----------------------------------------------------

procedure SpecificRecordEdits;
{
    Special record modifications to the target plugins
}
var
    flstGroup: IwbGroupRecord;
begin
    //Purge FOLIP - Before Generation.esp
    if HasGroup(iFolipPluginFile, 'STAT') then begin
        RemoveNode(GroupBySignature(iFolipPluginFile, 'STAT'));
    end;
    if HasGroup(iFolipPluginFile, 'MSWP') then begin
        RemoveNode(GroupBySignature(iFolipPluginFile, 'MSWP'));
    end;
    if HasGroup(iFolipPluginFile, 'CELL') then begin
        RemoveNode(GroupBySignature(iFolipPluginFile, 'CELL'));
    end;
    if HasGroup(iFolipPluginFile, 'WRLD') then begin
        RemoveNode(GroupBySignature(iFolipPluginFile, 'WRLD'));
    end;
    if HasGroup(iFolipPluginFile, 'FLST') then begin
        RemoveNode(GroupBySignature(iFolipPluginFile, 'FLST'));
    end;

    //Purge FOLIP - Master.esm
    {if HasGroup(iFolipMasterFile, 'STAT') then begin
        RemoveNode(GroupBySignature(iFolipMasterFile, 'STAT'));
    end;
    if HasGroup(iFolipMasterFile, 'MSWP') then begin
        RemoveNode(GroupBySignature(iFolipMasterFile, 'WRLD'));
    end;
    if HasGroup(iFolipMasterFile, 'CELL') then begin
        RemoveNode(GroupBySignature(iFolipMasterFile, 'CELL'));
    end;
    if HasGroup(iFolipMasterFile, 'WRLD') then begin
        RemoveNode(GroupBySignature(iFolipMasterFile, 'WRLD'));
    end;}


    flstGroup := Add(iFolipPluginFile, 'FLST', True);
    //Add FOLIP_Overrides formlist
    flOverrides := Add(flstGroup, 'FLST', True);
    SetEditorID(flOverrides, 'FOLIP_Overrides');

    flMultiRefLOD := Add(flstGroup, 'FLST', True);
    SetEditorID(flMultiRefLOD, 'FOLIP_MultiRefLOD');

    flParents := Add(flstGroup, 'FLST', True);
    SetEditorID(flParents, 'FOLIP_Parents');

    flNeverfades := Add(flstGroup, 'FLST', True);
    SetEditorID(flNeverfades, 'FOLIP_Neverfades');

    flDecals := Add(flstGroup, 'FLST', True);
    SetEditorID(flDecals, 'FOLIP_Decals');

    flFakeStatics := Add(flstGroup, 'FLST', True);
    SetEditorID(flFakeStatics, 'FOLIP_FakeStatics');

    flRemoveIsFullLOD := Add(flstGroup, 'FLST', True);
    SetEditorID(flRemoveIsFullLOD, 'FOLIP_RemoveIsFullLOD');
end;

procedure ProcessEnableParents;
{
    Apply LOD Respects Enable State flag to XESP - Enable Parent references.
}
var
    i, pi, oi: integer;
    p, m, r, n, base, rCell, rWrld, oppositeEnableParentReplacer, oreplacer, enableParentReplacer, ereplacer, xesp: IwbElement;
    parentFormid: string;
    bCanBeRespected, bHasOppositeEnableParent, bHasSuitableReplacer, bHasPersistentReplacer, bIsPersistent, bHasOppositeEnableRefs, bBaseHasLOD, bPlugin, bPluginHere, bPluginTemp, bIsFullLOD: boolean;
    tlOppositeEnableRefs, tlEnableRefs: TList;
begin
    for i := 0 to Pred(tlEnableParents.Count) do begin
        // This iterates over the actual Parents
        bPlugin := False;
        p := ObjectToElement(tlEnableParents[i]);
        bCanBeRespected := False;
        bHasSuitableReplacer := False;
        bHasPersistentReplacer := False;
        bHasOppositeEnableRefs := False;
        parentFormid := IntToHex(GetLoadOrderFormID(p), 8);
        if parentFormid = '00000014' then continue;
        if Pos(RecordFormIdFileId(p), sEnableParentFormidExclusions) <> 0 then continue;
        iCurrentPlugin := RefMastersDeterminePlugin(p, bPlugin);
        bPluginHere := bPlugin;
        AddMessage('Respect Enable Parents: Processing ' + Name(p));
        if ((LeftStr(IntToHex(GetLoadOrderFormID(p), 8), 2) = '00') and (not GetIsInitiallyDisabled(p))) then bCanBeRespected := True;
        if bCanBeRespected and (GetElementEditValues(p,'Record Header\Record Flags\LOD Respects Enable State') <> '1') then begin
            rCell := WinningOverride(LinksTo(ElementByIndex(p, 0)));
            rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
            iCurrentPlugin := RefMastersDeterminePlugin(rCell, bPlugin);
            iCurrentPlugin := RefMastersDeterminePlugin(rWrld, bPlugin);
            if not bPlugin and (tlMasterCells.IndexOf(rCell) = -1) then begin
                wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
                wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
            end;
            if bPlugin and (tlPluginCells.IndexOf(rCell) = -1) then begin
                wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
                wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
            end;
            if bPluginHere <> bPlugin then RefMastersDeterminePlugin(p, bPlugin);
            m := CopyElementToFileWithVC(p, iCurrentPlugin);
            SetElementNativeValues(m, 'Record Header\Record Flags\LOD Respects Enable State', 1);
            if not GetIsPersistent(p) then SetIsPersistent(m, True);
        end;

        {
            Iterate over all references to the parent. Two goals:
            * Find a suitable opposite enable parent replacer
            * Find all LOD references using opposite enable parent flag and store to a TList
        }
        tlOppositeEnableRefs := TList.Create;
        tlEnableRefs := TList.Create;
        for pi := Pred(ReferencedByCount(p)) downto 0 do begin
            r := ReferencedByIndex(p, pi);
            bBaseHasLOD := False;

            if Signature(r) <> 'REFR' then continue;
            if not IsWinningOverride(r) then continue;
            if GetIsDeleted(r) then continue;
            if GetIsCleanDeleted(r) then continue;

            base := WinningOverride(LinksTo(ElementByPath(r, 'NAME')));
            if (slHasLOD.IndexOf(RecordFormIdFileId(base)) <> -1) then bBaseHasLOD := True;

            //Split between refs with LOD and not having LOD
            if not bBaseHasLOD then begin
                if Pos(Signature(base), 'STAT,ACTI,TXST') = 0 then continue;
                if bHasPersistentReplacer then continue;
                if LeftStr(IntToHex(GetLoadOrderFormID(r), 8), 2) <> '00' then continue;
                bHasOppositeEnableParent := StrToBool(GetElementEditValues(r, 'XESP\Flags\Set Enable State to Opposite of Parent'));
                if not bHasOppositeEnableParent then continue;
                bIsPersistent := GetIsPersistent(r);
                if bHasSuitableReplacer and not bIsPersistent then continue;
                oppositeEnableParentReplacer := r;
                bHasSuitableReplacer := True;
                if not bIsPersistent then continue;
                bHasPersistentReplacer := True;
                continue;
            end;
            bHasOppositeEnableParent := StrToBool(GetElementEditValues(r, 'XESP\Flags\Set Enable State to Opposite of Parent'));
            if not bHasOppositeEnableParent then begin
                tlEnableRefs.Add(r);
                continue;
            end;
            tlOppositeEnableRefs.Add(r);
            bHasOppositeEnableRefs := True;

            if bHasPersistentReplacer then continue;
            if LeftStr(IntToHex(GetLoadOrderFormID(r), 8), 2) <> '00' then continue;
            bIsPersistent := GetIsPersistent(r);
            if bHasSuitableReplacer and not bIsPersistent then continue;
            oppositeEnableParentReplacer := r;
            bHasSuitableReplacer := True;
            if not bIsPersistent then continue;
            bHasPersistentReplacer := True;
        end;

        if bHasOppositeEnableRefs then begin
            if not bHasSuitableReplacer then oppositeEnableParentReplacer := GetSuitableReplacement;

            // Ensure cell is added to prevent failure to copy reference.
            rCell := WinningOverride(LinksTo(ElementByIndex(oppositeEnableParentReplacer, 0)));
            rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));

            iCurrentPlugin := RefMastersDeterminePlugin(rCell, bPlugin);
            iCurrentPlugin := RefMastersDeterminePlugin(rWrld, bPlugin);
            bPluginHere := bPlugin;
            if not bPluginHere and (tlMasterCells.IndexOf(rCell) = -1) then begin
                wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
                wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
            end;
            if bPluginHere and (tlPluginCells.IndexOf(rCell) = -1) then begin
                wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
                wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
            end;

            // Create replacer
            iCurrentPlugin := RefMastersDeterminePlugin(oppositeEnableParentReplacer, bPlugin);
            if bPlugin <> bPluginHere then begin
                iCurrentPlugin := RefMastersDeterminePlugin(rCell, bPlugin);
                if tlPluginCells.IndexOf(rCell) = -1 then begin
                    wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
                    wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
                end;
            end;
            oreplacer := CopyElementToFileWithVC(oppositeEnableParentReplacer, iCurrentPlugin);
            if not bHasPersistentReplacer then SetIsPersistent(oreplacer, True);
            SetElementEditValues(oreplacer, 'Record Header\Record Flags\LOD Respects Enable State', '1');
            if not bHasSuitableReplacer then begin
                Add(oreplacer,'XESP',True);
                SetElementEditValues(oreplacer, 'NAME', '000e4610'); //Enable Marker
                SetElementEditValues(oreplacer, 'XESP\Reference', parentFormid);
                SetElementNativeValues(oreplacer, 'XESP\Flags\Set Enable State to Opposite of Parent', 1);
            end;
            AddRefToMyFormlist(oreplacer, flParents);

            for oi := 0 to Pred(tlOppositeEnableRefs.Count) do begin
                r := ObjectToElement(tlOppositeEnableRefs[oi]);

                rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
                // Skip if in interior cell
                if GetElementEditValues(rCell, 'DATA - Flags\Is Interior Cell') = 1 then continue;
                rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
                // Check for ignored worldspace
                if Pos(RecordFormIdFileId(rWrld), sIgnoredWorldspaces) <> 0 then continue;
                // Check if WRLD inherits LOD from another worldspace
                if StrToBool(GetElementEditValues(rWrld,'Parent Worldspace\PNAM - Flags\Use LOD Data')) then continue;

                AddMessage(#9 + Name(r));

                bPluginTemp := False;
                iCurrentPlugin := RefMastersDeterminePlugin(rCell, bPluginTemp);
                iCurrentPlugin := RefMastersDeterminePlugin(rWrld, bPluginTemp);
                bPluginHere := bPluginTemp;
                if not bPluginHere and (tlMasterCells.IndexOf(rCell) = -1) then begin
                    wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
                    wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
                end;
                if bPluginHere and (tlPluginCells.IndexOf(rCell) = -1) then begin
                    wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
                    wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
                end;
                iCurrentPlugin := RefMastersDeterminePlugin(r, bPluginTemp);
                if bPluginTemp <> bPluginHere then begin
                    iCurrentPlugin := RefMastersDeterminePlugin(rCell, bPluginTemp);
                    iCurrentPlugin := RefMastersDeterminePlugin(rWrld, bPluginTemp);
                    if tlPluginCells.IndexOf(rCell) = -1 then begin
                        wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
                        wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
                    end;
                end;
                n := CopyElementToFileWithVC(r, iCurrentPlugin);
                SetElementEditValues(n, 'XESP\Reference', ShortName(oreplacer));

                SetElementNativeValues(n, 'XESP\Flags\Set Enable State to Opposite of Parent', 0);
                SetIsVisibleWhenDistant(n, True);
                if GetElementEditValues(n, 'Record Header\Record Flags\Is Full LOD') <> '0' then bIsFullLOD := true else bIsFullLOD := false;
                if bIsFullLOD then begin
                    SetElementNativeValues(n, 'Record Header\Record Flags\Is Full LOD', 0);
                    AddRefToMyFormlist(n, flRemoveIsFullLOD);
                end;
                AddRefToMyFormlist(n, flOverrides);
            end;
        end;
        if tlEnableRefs.Count > 0 then begin
            if not bCanBeRespected then begin
                enableParentReplacer := GetSuitableReplacement;
                iCurrentPlugin := RefMastersDeterminePlugin(enableParentReplacer, bPlugin);
                ereplacer := CopyElementToFileWithVC(enableParentReplacer, iCurrentPlugin);
                xesp := Add(ereplacer, 'XESP', True);
                ElementAssign(xesp, 0, nil, False);
                SetElementEditValues(ereplacer, 'XESP\Reference', parentFormid);
                SetElementEditValues(ereplacer, 'NAME', '000e4610');
                SetElementNativeValues(ereplacer, 'Record Header\Record Flags\LOD Respects Enable State', 1);
                AddRefToMyFormlist(ereplacer, flParents);
            end;
            for oi := 0 to Pred(tlEnableRefs.Count) do begin
                r := ObjectToElement(tlEnableRefs[oi]);
                if GetElementEditValues(r, 'Record Header\Record Flags\Is Full LOD') <> '0' then bIsFullLOD := true else bIsFullLOD := false;

                if (not bCanBeRespected) or (not GetIsVisibleWhenDistant(r)) or bIsFullLOD then begin
                    AddMessage(#9 + Name(r));
                    rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
                    // Skip if in interior cell
                    if GetElementEditValues(rCell, 'DATA - Flags\Is Interior Cell') = 1 then continue;
                    rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
                    // Check for ignored worldspace
                    if Pos(RecordFormIdFileId(rWrld), sIgnoredWorldspaces) <> 0 then continue;
                    // Check if WRLD inherits LOD from another worldspace
                    if StrToBool(GetElementEditValues(rWrld,'Parent Worldspace\PNAM - Flags\Use LOD Data')) then continue;
                    bPluginTemp := False;
                    iCurrentPlugin := RefMastersDeterminePlugin(rCell, bPluginTemp);
                    iCurrentPlugin := RefMastersDeterminePlugin(rWrld, bPluginTemp);
                    bPluginHere := bPluginTemp;
                    if not bPluginHere and (tlMasterCells.IndexOf(rCell) = -1) then begin
                        wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
                        wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
                    end;
                    if bPluginHere and (tlPluginCells.IndexOf(rCell) = -1) then begin
                        wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
                        wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
                    end;
                    iCurrentPlugin := RefMastersDeterminePlugin(r, bPluginTemp);
                    if bPluginTemp <> bPluginHere then begin
                        iCurrentPlugin := RefMastersDeterminePlugin(rCell, bPluginTemp);
                        iCurrentPlugin := RefMastersDeterminePlugin(rWrld, bPluginTemp);
                        if tlPluginCells.IndexOf(rCell) = -1 then begin
                            wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
                            wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
                        end;
                    end;

                    n := CopyElementToFileWithVC(r, iCurrentPlugin);
                    if not bCanBeRespected then begin
                        SetElementEditValues(n, 'XESP\Reference', ShortName(ereplacer));
                        SetElementNativeValues(n, 'XESP\Flags\Set Enable State to Opposite of Parent', 0);
                    end;

                    if bIsFullLOD then begin
                        SetElementNativeValues(n, 'Record Header\Record Flags\Is Full LOD', 0);
                        AddRefToMyFormlist(n, flRemoveIsFullLOD);
                    end;

                    SetIsVisibleWhenDistant(n, True);
                    AddRefToMyFormlist(n, flOverrides);
                end;
            end;
        end;

        tlOppositeEnableRefs.Free;
        tlEnableRefs.Free;
    end;
end;

procedure MultiRefLOD;
{
    Adds MultiRefLOD keyword to references specified in FOLIP MultiRefLOD.json rules.
}
var
    c, a, i: integer;
    MultiRefLODReference, ref, MultiRefLODFormidStr, editorid: string;
    r, MultiRefLODElement, n, rCell, rWrld: IwbElement;
    linkedrefs, lref: IInterface;
    bNeedsModified, bHadMultiRefLODCorrect: Boolean;
begin
    for c := 0 to Pred(joMultiRefLOD.Count) do begin
        editorid := joMultiRefLOD.Names[c];
        MultiRefLODReference := joMultiRefLOD.O[editorid].S['MultiRefLOD'];
        MultiRefLODElement := GetRecordFromFormIdFileId(MultiRefLODReference);
        MultiRefLODFormidStr := IntToHex(GetLoadOrderFormID(MultiRefLODElement), 8);
        if not Assigned(MultiRefLODElement) then begin
            AddMessage('MultiRefLOD: Could not find record for ' + MultiRefLODReference);
            Continue;
        end;

        AddMessage('MultiRefLOD: Processing ' + ShortName(MultiRefLODElement));

        for a := 0 to Pred(joMultiRefLOD.O[editorid].A['References to add MultiRefLOD'].Count) do begin
            ref := joMultiRefLOD.O[editorid].A['References to add MultiRefLOD'].S[a];
            r := WinningOverride(GetRecordFromFormIdFileId(ref));
            if not Assigned(r) then begin
                AddMessage('MultiRefLOD: Could not find reference ' + ref + ' for ' + MultiRefLODReference);
                Continue;
            end;

            //Check to see if we need to modify the ref.
            bNeedsModified := False;
            if GetIsDeleted(r) then begin
                AddMessage('MultiRefLOD: Skipping deleted reference ' + Name(r));
                Continue;
            end;
            if GetIsCleanDeleted(r) then begin
                AddMessage('MultiRefLOD: Skipping clean deleted reference ' + Name(r));
                Continue;
            end;

            if ElementExists(r, 'Linked References') then begin
                bHadMultiRefLODCorrect := False;
                linkedrefs := ElementByPath(r, 'Linked References');
                for i := 0 to Pred(ElementCount(linkedrefs)) do begin
                    lref := ElementByIndex(linkedrefs, i);
                    if IntToHex(GetLoadOrderFormID(LinksTo(ElementByPath(lref, 'Keyword/Ref'))), 8) = '00195411' then begin
                        // if the reference already has the MultiRefLOD keyword, but the formid does not match, we need to modify it.
                        if IntToHex(GetLoadOrderFormID(LinksTo(ElementByPath(lref, 'Ref'))), 8) <> MultiRefLODFormidStr then begin
                            bNeedsModified := True;
                            Break; // We can break since we know we need to modify this reference in order to remove this one.
                        end
                        else if (IntToHex(GetLoadOrderFormID(LinksTo(ElementByPath(lref, 'Ref'))), 8) = MultiRefLODFormidStr) then bHadMultiRefLODCorrect := True;
                    end;
                end;
                if not bHadMultiRefLODCorrect then bNeedsModified := True; // If we didn't find the MultiRefLOD, we need to add it.
            end
            else bNeedsModified := True;

            if bNeedsModified then begin
                AddMessage(#9 + Name(r));
                //AddRefToMyFormlist(r, flMultiRefLOD);
                rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
                rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
                iCurrentPlugin := RefMastersDeterminePlugin(rCell, True);
                iCurrentPlugin := RefMastersDeterminePlugin(rWrld, True);
                iCurrentPlugin := RefMastersDeterminePlugin(MultiRefLODElement, True);
                iCurrentPlugin := RefMastersDeterminePlugin(r, True);
                wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
                wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
                n := CopyElementToFileWithVC(r, iCurrentPlugin);
                RemoveLinkedReferenceByKeyword(n, '00195411'); // Remove any existing MultiRefLOD keyword linked references
                AddLinkedReference(n, '00195411', MultiRefLODFormidStr); // Add the MultiRefLOD keyword with the correct formid
            end;
        end;
    end;
end;

function AddLinkedReference(e: IInterface; keyword, ref: String): Integer;
{
  Add a linked reference.
}
var
    el, linkedrefs, lref: IInterface;
    i: Integer;
begin
    Result := 0;
    if not ElementExists(e, 'Linked References') then begin
        linkedrefs := Add(e, 'Linked References', True);
        lref := ElementByIndex(linkedrefs, 0);
        SetElementEditValues(lref, 'Keyword/Ref', keyword);
        SetElementEditValues(lref, 'Ref', ref);
    end
    else begin
        linkedrefs := ElementByPath(e, 'Linked References');
        lref := ElementAssign(linkedrefs, HighInteger, nil, False);
        SetElementEditValues(lref, 'Keyword/Ref', keyword);
        SetElementEditValues(lref, 'Ref', ref);
    end;
end;

function RemoveLinkedReferenceByKeyword(e: IwbElement; keyword: String): Integer;
{
  Remove a linked reference by keyword.
}
var
    linkedrefs, lref: IInterface;
    i: Integer;
begin
    Result := 0;
    if not ElementExists(e, 'Linked References') then Exit;
    linkedrefs := ElementByPath(e, 'Linked References');
    for i := Pred(ElementCount(linkedrefs)) downto 0 do begin
        lref := ElementByIndex(linkedrefs, i);
        if IntToHex(GetLoadOrderFormID(LinksTo(ElementByPath(lref, 'Keyword/Ref'))), 8) = keyword then begin
            Remove(lref);
            Result := 1; // Indicate that a reference was removed
        end;
    end;
end;

function GetSuitableReplacement: IwbElement;
var
    stolen, r, m, rCell, n: IwbElement;
    i, j: integer;
begin
    Result := nil;
    for j := 0 to Pred(tlTxst.Count) do begin
        stolen := ObjectToElement(tlTxst[j]);
        for i := Pred(ReferencedByCount(stolen)) downto 0 do begin
            r := ReferencedByIndex(stolen, i);
            if tlStolenForms.IndexOf(r) <> -1 then continue;
            if LeftStr(IntToHex(GetLoadOrderFormID(r), 8), 2) <> '00' then continue;
            if Signature(r) <> 'REFR' then continue;
            if not IsWinningOverride(r) then continue;
            m := MasterOrSelf(r);
            if not Equals(m, r) then continue;
            if not GetIsPersistent(r) then continue;
            rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
            if GetElementEditValues(rCell, 'DATA - Flags\Is Interior Cell') = 1 then continue;
            if ReferencedByCount(r) <> 0 then continue;
            if ElementExists(r, 'VMAD') then continue;
            if ElementExists(r, 'XMPO') then continue;
            if ElementExists(r, 'XPOD') then continue;
            if ElementExists(r, 'XPTL') then continue;
            if ElementExists(r, 'XORD') then continue;
            if ElementExists(r, 'XMBP') then continue;
            if ElementExists(r, 'XRGD') then continue;
            if ElementExists(r, 'XTEL') then continue;
            if ElementExists(r, 'XTNM') then continue;
            if ElementExists(r, 'XMBR') then continue;
            if ElementExists(r, 'XMCN') then continue;
            if ElementExists(r, 'XMCU') then continue;
            if ElementExists(r, 'XASP') then continue;
            if ElementExists(r, 'XATP') then continue;
            if ElementExists(r, 'XLKT') then continue;
            if ElementExists(r, 'XPDD') then continue;
            if ElementExists(r, 'XPRM') then continue;
            if ElementExists(r, 'XRFG') then continue;
            if ElementExists(r, 'XRDO') then continue;
            if ElementExists(r, 'XBSD') then continue;
            if ElementExists(r, 'XESP') then continue;
            Result := r;
            tlStolenForms.Add(r);
            iCurrentPlugin := RefMastersDeterminePlugin(r, True);
            n := wbCopyElementToFile(r, iCurrentPlugin, True, True);
            AddRefToMyFormlist(n, flDecals);
            Exit;
        end;
    end;
end;

procedure AddRefToMyFormlist(r, frmlst: IwbElement);
var
    formids, lnam: IwbElement;
begin
    if not ElementExists(frmlst, 'FormIDs') then begin
        formids := Add(frmlst, 'FormIDs', True);
        lnam := ElementByIndex(formids, 0);
    end
    else begin
        formids := ElementByName(frmlst, 'FormIDs');
        lnam := ElementAssign(formids, HighInteger, nil, False);
    end;
    try
        SetEditValue(lnam, ShortName(r));
    except
        AddRequiredElementMasters(r, iFolipPluginFile, False, True);
        SetEditValue(lnam, ShortName(r));
    end;
end;

function IsFullLOD(s: IInterface): Boolean;
var
    model, editorid: string;
    bIsFullLOD, bIsFullLODFlagged, bXESP, bRespect: Boolean;
    i: integer;
    r, n, rCell, rWrld, parentRef, xesp: IInterface;
begin
    Result := false;
    editorid := LowerCase(GetElementEditValues(s, 'EDID'));
    model := LowerCase(GetElementEditValues(s, 'Model\MODL - Model FileName'));
    if joRules.Contains(editorid) then begin
        bIsFullLOD := StrToBool(joRules.O[editorid].S['bisfulllod']);
    end
    else if joRules.Contains(model) then begin
        bIsFullLOD := StrToBool(joRules.O[model].S['bisfulllod']);
    end;
    if not bIsFullLOD then Exit;
    Result := true;
    for i := Pred(ReferencedByCount(s)) downto 0 do begin
        r := ReferencedByIndex(s, i);
        if Signature(r) <> 'REFR' then continue;
        if not IsWinningOverride(r) then continue;
        if GetIsDeleted(r) then continue;
        if GetIsCleanDeleted(r) then continue;
        rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
        if GetElementEditValues(rCell, 'DATA - Flags\Is Interior Cell') = 1 then continue;
        rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
        if Pos(RecordFormIdFileId(rWrld), sIgnoredWorldspaces) <> 0 then continue;

        bXESP := ElementExists(r, 'XESP');
        if bXESP then begin
            xesp := ElementByPath(r, 'XESP');
            parentRef := WinningOverride(LinksTo(ElementByIndex(xesp, 0)));
            bRespect := GetElementNativeValues(parentRef, 'Record Header\Record Flags\LOD Respects Enable State');
        end;
        if GetElementEditValues(r, 'Record Header\Record Flags\Is Full LOD') <> '0' then bIsFullLODFlagged := true else bIsFullLODFlagged := false;
        if bIsFullLODFlagged then begin
            if not bXESP then continue;
            if GetElementNativeValues(r, 'Record Header\Record Flags\LOD Respects Enable State') then continue;
            if bRespect then continue;
        end;


        iCurrentPlugin := RefMastersDeterminePlugin(rCell, True);
        iCurrentPlugin := RefMastersDeterminePlugin(rWrld, True);
        wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
        wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);

        iCurrentPlugin := RefMastersDeterminePlugin(r, True);
        n := CopyElementToFileWithVC(r, iCurrentPlugin);
        SetElementEditValues(n, 'Record Header\Record Flags\Is Full LOD', 1);
        SetIsPersistent(n, True);
        if bXESP and not bRespect then SetElementEditValues(n, 'Record Header\Record Flags\LOD Respects Enable State', 1);

        AddRefToMyFormlist(n, flNeverfades);
        slFullLODMessages.Add('IsFullLOD Reference:' + Name(n));
    end;
end;

procedure ProcessActiFurnMstt;
var
    si, i, cnt: integer;
    n, r, s, ms, rCell, rWrld, fakeStatic: IwbElement;
    HasLOD, bFullLOD: Boolean;
    joLOD: TJsonObject;
    fakeStaticFormID, sMissingLodMessage: string;
begin
    for i := 0 to Pred(tlActiFurnMstt.Count) do begin
        sMissingLodMessage := '';
        s := ObjectToElement(tlActiFurnMstt[i]);

        bFullLOD := IsFullLOD(s);
        if bFullLOD then continue;

        joLOD := TJsonObject.Create;
        HasLOD := AssignLODModels(s, joLOD, sMissingLodMessage);

        //Process references that have lod.
        if HasLOD then begin
            cnt := 0;

            for si := Pred(ReferencedByCount(s)) downto 0 do begin
                r := ReferencedByIndex(s, si);
                if Signature(r) <> 'REFR' then continue;
                if not IsWinningOverride(r) then continue;
                if GetIsDeleted(r) then continue;
                if GetIsCleanDeleted(r) then continue;
                rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
                if GetElementEditValues(rCell, 'DATA - Flags\Is Interior Cell') = 1 then continue;
                rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
                if Pos(RecordFormIdFileId(rWrld), sIgnoredWorldspaces) <> 0 then continue;

                // Check if WRLD inherits LOD from another worldspace
                if StrToBool(GetElementEditValues(rWrld,'Parent Worldspace\PNAM - Flags\Use LOD Data')) then continue;

                //This reference should get lod if it passes these checks.
                cnt := cnt + 1;
                //Perform these functions if this is the very first reference. We set up the base object as a Fake Static.
                if cnt = 1 then begin
                    //Create Fake Static
                    fakeStatic := AddFakeStatic(s);

                    //Add LOD models
                    AssignLODToStat(fakeStatic, joLOD, True);

                    slHasLOD.Add(RecordFormIdFileId(fakeStatic));

                    //Get formid
                    fakeStaticFormID := IntToHex(GetLoadOrderFormID(fakeStatic), 8);
                end;

                //Copy
                n := DuplicateRef(r, fakeStatic, fakeStaticFormID);

                //Add mat swap if it exists to list to check.
                if not ElementExists(r, 'XMSP - Material Swap') then continue;
                ms := LinksTo(ElementByPath(r, 'XMSP'));
                if tlMswp.IndexOf(ms) = -1 then tlMswp.Add(ms);
            end;
        end
        else if bReportMissingLOD and (sMissingLodMessage <> '') then begin
            if IsObjectUsedInExterior(s) then slMissingLODMessages.Add(sMissingLodMessage);
        end;

        joLOD.Free;
    end;
end;

function GetCellFromWorldspace(Worldspace: IInterface; GridX, GridY: integer): IInterface;
var
    blockidx, subblockidx, cellidx: integer;
    wrldgrup, block, subblock, cell: IInterface;
    Grid, GridBlock, GridSubBlock: TwbGridCell;
    LabelBlock, LabelSubBlock: Cardinal;
begin
    Grid := wbGridCell(GridX, GridY);
    GridSubBlock := wbSubBlockFromGridCell(Grid);
    LabelSubBlock := wbGridCellToGroupLabel(GridSubBlock);
    GridBlock := wbBlockFromSubBlock(GridSubBlock);
    LabelBlock := wbGridCellToGroupLabel(GridBlock);

    wrldgrup := ChildGroup(Worldspace);
    // iterate over Exterior Blocks
    for blockidx := 0 to Pred(ElementCount(wrldgrup)) do begin
        block := ElementByIndex(wrldgrup, blockidx);
        if GroupLabel(block) <> LabelBlock then Continue;
        // iterate over SubBlocks
        for subblockidx := 0 to Pred(ElementCount(block)) do begin
            subblock := ElementByIndex(block, subblockidx);
            if GroupLabel(subblock) <> LabelSubBlock then Continue;
            // iterate over Cells
            for cellidx := 0 to Pred(ElementCount(subblock)) do begin
                cell := ElementByIndex(subblock, cellidx);
                if (Signature(cell) <> 'CELL') or GetIsPersistent(cell) then Continue;
                if (GetElementNativeValues(cell, 'XCLC\X') = Grid.x) and (GetElementNativeValues(cell, 'XCLC\Y') = Grid.y) then begin
                    Result := cell;
                    Exit;
                end;
            end;
            Break;
        end;
        Break;
    end;
end;

function DuplicateRef(r, fakeStatic: IInterface; base: string): IInterface;
{
    Duplicates a placed reference and returns the duplicate.
}
var
    n, rCell, rWrld, wCell, nCell, ms, xesp, xespDup, parentRef: IInterface;
    bHasOppositeParent, bPlugin, bParent, bParentWasPlugin, bMswpWasPlugin, bFakeStaticWasPlugin: Boolean;
    c: TwbGridCell;
    parent: string;
begin
    Result := nil;
    bPlugin := False;
    bParent := False;
    bParentWasPlugin := False;
    bMswpWasPlugin := False;
    bFakeStaticWasPlugin := False;

    if ElementExists(r, 'XESP - Enable Parent') then begin
        bParent := True;
        xesp := ElementByPath(r, 'XESP');
        parentRef := WinningOverride(LinksTo(ElementByIndex(xesp, 0)));
        iCurrentPlugin := RefMastersDeterminePlugin(parentRef, bPlugin);
        if bPlugin then bParentWasPlugin := True;
    end
    else RefMastersDeterminePlugin(r, bPlugin);
    if ElementExists(r, 'XMSP - Material Swap') then begin
        ms := WinningOverride(LinksTo(ElementByPath(r, 'XMSP - Material Swap')));
        iCurrentPlugin := RefMastersDeterminePlugin(ms, bPlugin);
        if bPlugin then bMswpWasPlugin := True;
    end;

    iCurrentPlugin := RefMastersDeterminePlugin(fakeStatic, bPlugin);
    if bPlugin then bFakeStaticWasPlugin := True;

    //Copy cell to plugin
    rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
    rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));

    //Handle persistent worldspace cell
    if GetIsPersistent(rCell) then begin
        c := wbPositionToGridCell(GetPosition(r));
        wCell := WinningOverride(GetCellFromWorldspace(rWrld, c.X, c.Y));
        if Assigned(wCell) then rCell := wCell;
    end;


    iCurrentPlugin := RefMastersDeterminePlugin(rCell, bPlugin);
    iCurrentPlugin := RefMastersDeterminePlugin(rWrld, bPlugin);
    if bPlugin then begin
        if not bParentWasPlugin then RefMastersDeterminePlugin(parentRef, bPlugin);
        if not bMswpWasPlugin then RefMastersDeterminePlugin(ms, bPlugin);
        if not bFakeStaticWasPlugin then RefMastersDeterminePlugin(fakeStatic, bPlugin);
        if tlPluginCells.IndexOf(rCell) = -1 then tlPluginCells.Add(rCell);
    end
    else if tlMasterCells.IndexOf(rCell) = -1 then tlMasterCells.Add(rCell);


    nCell := wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
    wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);

    if not Assigned(nCell) then begin
        AddMessage(Name(rCell) + ' could not be copied as a cell.');
        AddMessage(Name(r) + ' failed to make a fake static version.');
        Exit;
    end;

    //Add new ref to cell
    n := Add(nCell, 'REFR', True);

    //Add required elements

    //  Set flags
    if GetIsInitiallyDisabled(r) then SetIsInitiallyDisabled(r, true);
    SetIsVisibleWhenDistant(n, True);

    //  Set base
    SetElementEditValues(n, 'Name', base);

    //  Set material swap
    if ElementExists(r, 'XMSP - Material Swap') then begin
        Add(n, 'XMSP', True);
        SetElementEditValues(n, 'XMSP - Material Swap', GetElementEditValues(r, 'XMSP - Material Swap'));
    end;

    //  Set scale
    if ElementExists(r, 'XSCL - Scale') then begin
        Add(n, 'XSCL', True);
        SetElementNativeValues(n, 'XSCL - Scale', GetElementNativeValues(r, 'XSCL - Scale'));
    end;


    //  Set position
    SetElementNativeValues(n, 'DATA\Position\X', GetElementNativeValues(r, 'DATA\Position\X'));
    SetElementNativeValues(n, 'DATA\Position\Y', GetElementNativeValues(r, 'DATA\Position\Y'));
    SetElementNativeValues(n, 'DATA\Position\Z', GetElementNativeValues(r, 'DATA\Position\Z'));
    SetElementNativeValues(n, 'DATA\Rotation\X', GetElementNativeValues(r, 'DATA\Rotation\X'));
    SetElementNativeValues(n, 'DATA\Rotation\Y', GetElementNativeValues(r, 'DATA\Rotation\Y'));
    SetElementNativeValues(n, 'DATA\Rotation\Z', GetElementNativeValues(r, 'DATA\Rotation\Z'));

    //  Set XESP
    xespDup := Add(n, 'XESP', True);
    if bParent then begin
        parent := GetElementEditValues(r, 'XESP\Reference');
        bHasOppositeParent := GetElementNativeValues(r, 'XESP\Flags\Set Enable State to Opposite of Parent');
        SetElementNativeValues(n, 'XESP\Flags\Set Enable State to Opposite of Parent', bHasOppositeParent);
        if tlEnableParents.IndexOf(parentRef) = -1 then tlEnableParents.Add(parentRef);
    end
    else begin
        parent := ShortName(r);
        if ContainsText(Name(r), 'repairable') then begin
            parentRef := r;
            if tlEnableParents.IndexOf(parentRef) = -1 then tlEnableParents.Add(parentRef);
        end;
    end;

    ElementAssign(xespDup, 0, nil, False);
    SetElementEditValues(n, 'XESP\Reference', parent);

    //AddRefToMyFormlist(n, flFakeStatics);
    Result := n;
end;

procedure CopyObjectBounds(copyFrom, copyTo: IwbElement);
{
    Copies the object bounds of the first reference to the second reference.
}
begin
    SetElementNativeValues(copyTo, 'OBND\X1', GetElementNativeValues(copyFrom, 'OBND\X1'));
    SetElementNativeValues(copyTo, 'OBND\X2', GetElementNativeValues(copyFrom, 'OBND\X2'));
    SetElementNativeValues(copyTo, 'OBND\Y1', GetElementNativeValues(copyFrom, 'OBND\Y1'));
    SetElementNativeValues(copyTo, 'OBND\Y2', GetElementNativeValues(copyFrom, 'OBND\Y2'));
    SetElementNativeValues(copyTo, 'OBND\Z1', GetElementNativeValues(copyFrom, 'OBND\Z1'));
    SetElementNativeValues(copyTo, 'OBND\Z2', GetElementNativeValues(copyFrom, 'OBND\Z2'));
end;

function AddFakeStatic(s: IwbElement): IwbElement;
{
    Adds a fake static version of the non-static input and returns is.
}
var
    ms, fakeStatic: IwbElement;
    patchStatGroup: IwbGroupRecord;
    HasMS: Boolean;
    fakeStaticEditorId: string;
begin
    HasMS := ElementExists(s, 'Model\MODS - Material Swap');
    if HasMS then begin
        ms := LinksTo(ElementByPath(s, 'Model\MODS'));
        if tlMswp.IndexOf(ms) = -1 then tlMswp.Add(ms);
        iCurrentPlugin := RefMastersDeterminePlugin(ms, False);
    end
    else iCurrentPlugin := iFolipPluginFile;

    patchStatGroup := GroupBySignature(iCurrentPlugin, 'STAT');
    if ElementCount(patchStatGroup) < 1 then begin
        patchStatGroup := Add(iCurrentPlugin, 'STAT', True);
    end;

    //Add Fake STAT
    fakeStatic := Add(patchStatGroup, 'STAT', True);
    fakeStaticEditorId := SetEditorID(fakeStatic, 'FOLIP_' + EditorID(s) + '_FakeStatic');

    //Set Object Bounds
    CopyObjectBounds(s, fakeStatic);

    //Add base material swap
    if HasMS then begin
        Add(Add(fakeStatic, 'Model', True), 'MODS', True);
        SetElementEditValues(fakeStatic, 'Model\MODS', IntToHex(GetLoadOrderFormID(ms), 8));
    end;

    //Add Is Marker Flag
    SetElementNativeValues(fakeStatic, 'Record Header\Record Flags\Is Marker', 1);

    Result := fakeStatic;
end;

procedure AssignLODMaterialsList;
{
    Assign lod materials to MSWP record.
}
var
    i, si, tp, sc, cnt, n, oms: integer;
    m, mn, substitutions, sub: IInterface;
    colorRemap, originalMat, originalLODMat, replacementMat, om, rm: string;
    slLODSubOriginal, slLODSubReplacement, slExistingSubstitutions, slMissingMaterials, slTopPaths, slLODOriginals, slLODReplacements, slDummy, slMismatchedMaterials: TStringList;
    hasLODOriginalMaterial, hasLODReplacementMaterial: Boolean;
begin
    slDummy := TStringList.Create;
    //store missing lod materials here
    slMissingMaterials := TStringList.Create;
    slMismatchedMaterials := TStringList.Create;
    slMismatchedMaterials.Sorted := True;
    slMismatchedMaterials.Duplicates := dupIgnore;
    try
        for i := 0 to Pred(tlMswp.Count) do begin
            m := WinningOverride(ObjectToElement(tlMswp[i]));

            slLODSubOriginal := TStringList.Create;
            slLODSubReplacement := TStringList.Create;

            //make a list of existing substitutions, which we will need to then check to make sure we don't add a duplicate substitution.
            slExistingSubstitutions := TStringList.Create;
            substitutions := ElementByName(m, 'Material Substitutions');
            //foreach substitution in substitutions
            for si := 0 to Pred(ElementCount(substitutions)) do begin
                //the substitution
                sub := ElementByIndex(substitutions, si);
                if not ElementExists(sub, 'BNAM - Original Material') then continue;
                originalMat := LowerCase(GetElementEditValues(sub, 'BNAM - Original Material'));
                if originalMat = '' then continue;
                if LeftStr(originalMat, 10) <> 'materials\' then originalMat := 'materials\' + originalMat;
                slExistingSubstitutions.Add(originalMat);
            end;

            //We need to loop through the substitutions again to actually do the work now that we know what the existing substitutions are.
            //foreach substitution in substitutions
            for si := 0 to Pred(ElementCount(substitutions)) do begin
                //the substitution
                sub := ElementByIndex(substitutions, si);
                if not ElementExists(sub, 'BNAM - Original Material') then continue;
                if not ElementExists(sub, 'SNAM - Replacement Material') then continue;
                originalMat := LowerCase(GetElementEditValues(sub, 'BNAM - Original Material'));
                if originalMat = '' then continue;
                if LeftStr(originalMat, 10) <> 'materials\' then originalMat := 'materials\' + originalMat;

                slTopPaths := TStringList.Create;
                for tp := 0 to Pred(slTopLevelModPatternPaths.Count) do begin
                    if ContainsText(originalMat, 'materials\' + slTopLevelModPatternPaths[tp]) then slTopPaths.Add(slTopLevelModPatternPaths[tp]);
                end;

                hasLODOriginalMaterial := False;
                slLODOriginals := TStringList.Create;
                om := LODMaterial(originalMat, '', slTopPaths, slExistingSubstitutions, slLODOriginals);
                slTopPaths.Free;
                if slLODOriginals.Count > 0 then hasLODOriginalMaterial := True;
                if not hasLODOriginalMaterial then continue;
                //ListStringsInStringList(slLODOriginals);

                replacementMat := LowerCase(GetElementEditValues(sub, 'SNAM - Replacement Material'));
                if replacementMat = '' then continue;
                if LeftStr(replacementMat, 10) <> 'materials\' then replacementMat := 'materials\' + replacementMat;

                colorRemap := FloatToStr(StrToFloatDef(GetElementEditValues(sub, 'CNAM - Color Remapping Index'),'9'));
                if ((originalMat = replacementMat) and (colorRemap = '9')) then begin
                    AddMessage(Name(m) + #9 + 'Ignoring this Material Swap Substitution due to the Original Material being the same as the Replacement Material: ' + #9 + originalMat + #9 + replacementMat);
                    continue;
                end;
                if colorRemap = '9' then colorRemap := '' else colorRemap := '_' + colorRemap;


                slTopPaths := TStringList.Create;
                for tp := 0 to Pred(slTopLevelModPatternPaths.Count) do begin
                    if ContainsText(replacementMat, 'materials\' + slTopLevelModPatternPaths[tp]) then slTopPaths.Add(slTopLevelModPatternPaths[tp]);
                end;

                hasLODReplacementMaterial := False;
                slLODReplacements := TStringList.Create;
                rm := LODMaterial(replacementMat, colorRemap, slTopPaths, slDummy, slLODReplacements);
                slTopPaths.Free;
                if slLODReplacements.Count > 0 then hasLODReplacementMaterial := True;
                if not hasLODReplacementMaterial then begin
                    if ResourceExists(replacementMat) then begin
                        if colorRemap = '' then begin
                            if bMakeMissingMaterials then AddMessage(Name(m) + #9 + 'Missing LOD replacement material: ' + rm + #9 + ' from ' + #9 + om);
                            if not CreateLODMaterialReplacement('materials\' + slLODOriginals[0], rm, replacementMat, False) then begin
                                slMissingMaterials.Add(Name(m) + #9 + 'Missing LOD replacement material: ' + rm + #9 + ' from ' + #9 + om);
                                continue;
                            end else begin
                                slLODReplacements.Add(rm);
                                slMatFiles.Add(rm);
                            end;
                        end
                        else begin
                            slMissingMaterials.Add(Name(m) + #9 + 'Missing LOD color remap replacement material: ' + rm + #9 + ' from ' + #9 + om);
                            continue;
                        end;
                    end
                    else begin
                        AddMessage(Name(m) + #9 + 'Ignoring this Material Swap Substitution due to the Replacement Material referencing a material that does not exist: ' + replacementMat);
                        continue;
                    end;
                end;
                //ListStringsInStringList(slLODReplacements);

                for oms := 0 to Pred(slLODOriginals.Count) do begin
                    om := slLODOriginals[oms];
                    if slLODSubOriginal.IndexOf(om) > -1 then continue;
                    if slExistingSubstitutions.IndexOf('materials\' + om) > -1 then continue;
                    rm := slLODReplacements[0];
                    if om = rm then continue;
                    slLODSubOriginal.Add(om);
                    slLODSubReplacement.Add(rm);
                    CompareMaterialSwaps(slMismatchedMaterials, om, rm);
                end;

                slLODReplacements.Free;
                slLODOriginals.Free;
            end;

            //continue if no changes are required.
            cnt := slLODSubOriginal.Count;
            if cnt < 1 then begin
                slLODSubOriginal.Free;
                slLODSubReplacement.Free;
                continue;
            end;

            //Changes required, so add material swap to patch
            iCurrentPlugin := RefMastersDeterminePlugin(m, True);
            mn := wbCopyElementToFile(m, iCurrentPlugin, False, True);
            for n := 0 to Pred(cnt) do begin
                //AddMessage(ShortName(m) + #9 + slLODSubOriginal[n] + #9 + slLODSubReplacement[n]);
                AddMaterialSwap(mn, slLODSubOriginal[n], slLODSubReplacement[n]);
            end;
            slLODSubOriginal.Free;
            slLODSubReplacement.Free;
        end;

        ListStringsInStringList(slMissingMaterials);
        ListStringsInStringList(slMismatchedMaterials);
    finally
        slMissingMaterials.Free;
        slMismatchedMaterials.Free;
        slDummy.Free;
    end;
end;

function CreateLODMaterialReplacement(om, rm, replacementMat: string; bForceTexGenRedo: Boolean): Boolean;
{
    Creates a LOD material replacement if it does not already exist.
    om is the path to the original lod material.
    rm is the path to the replacement lod material to be created.
    replacementMat is the path to the base material that the lod replacement is based on.
}
var
    ombgsm, rmbgsm, replacementMatbgsm: TwbBGSMFile;
    omDiffuse, omDiffuseNormalized, replacementDiffuse, replacementDiffuseNormalized, replacementNormal, replacementNormalNormalized, replacementSpecular, replacementSpecularNormalized, replacementLodDiffuse, lodDiffuse, lodNormal, lodSpecular, omAuto: string;
    specularMult: float;
    bLodTextureExists, bOmAutoGenerated: Boolean;
begin
    Result := False;
    if not bMakeMissingMaterials then Exit;
    if not bForceTexGenRedo then AddMessage('Attempting to create a missing LOD Material Replacement: ' + rm + #9 + 'from' + #9 + om);
    bOmAutoGenerated := False;

    if not ResourceExists(om) then begin
        if FileExists(wbScriptsPath + 'FOLIP\output\' + om) then begin
            omAuto := wbScriptsPath + 'FOLIP\output\' + om;
            bOmAutoGenerated := True;
        end else begin
            AddMessage(#9 + 'Error: ' + om + ' does not exist.');
            Exit;
        end;
    end;

    ombgsm := TwbBGSMFile.Create;
    replacementMatbgsm := TwbBGSMFile.Create;
    try
        if not bOmAutoGenerated then ombgsm.LoadFromResource(om) else ombgsm.LoadFromFile(omAuto);
        replacementMatbgsm.LoadFromResource(replacementMat);

        //Check if the replacement material is alterring the UV offsets or scales, and if so, exit without creating a replacement.
        if ombgsm.NativeValues['UOffset'] <> replacementMatbgsm.NativeValues['UOffset'] then begin
            AddMessage(#9 + 'Original material ' + om + ' has a different UOffset than the replacement material ' + replacementMat + '. Skipping creation of LOD material replacement.');
            Exit;
        end;
        if ombgsm.NativeValues['VOffset'] <> replacementMatbgsm.NativeValues['VOffset'] then begin
            AddMessage(#9 + 'Original material ' + om + ' has a different VOffset than the replacement material ' + replacementMat + '. Skipping creation of LOD material replacement.');
            Exit;
        end;
        if ombgsm.NativeValues['UScale'] <> replacementMatbgsm.NativeValues['UScale'] then begin
            AddMessage(#9 + 'Original material ' + om + ' has a different UScale than the replacement material ' + replacementMat + '. Skipping creation of LOD material replacement.');
            Exit;
        end;
        if ombgsm.NativeValues['VScale'] <> replacementMatbgsm.NativeValues['VScale'] then begin
            AddMessage(#9 + 'Original material ' + om + ' has a different VScale than the replacement material ' + replacementMat + '. Skipping creation of LOD material replacement.');
            Exit;
        end;

        //Check if the replacement material has the Hide Secret Flag set, and if so, exit without creating a replacement.
        if replacementMatbgsm.EditValues['Hide Secret'] = 'yes' then begin
            AddMessage(#9 + 'Replacement material ' + replacementMat + ' has the Hide Secret Flag set. Skipping creation of LOD material replacement.');
            Exit;
        end;

        //Get lod diffuse texture of the original material
        omDiffuse := ombgsm.EditValues['Textures\Diffuse'];
        omDiffuseNormalized := wbNormalizeResourceName(omDiffuse, resTexture);

        //Get the base replacement material's textures
        replacementDiffuse := replacementMatbgsm.EditValues['Textures\Diffuse'];
        replacementDiffuseNormalized:= wbNormalizeResourceName(replacementDiffuse, resTexture);
        if not ResourceExists(replacementDiffuseNormalized) then begin
            AddMessage(#9 + 'Replacement material ' + replacementMat + ' uses a diffuse texture that does not exist. Skipping creation of LOD material replacement.');
            Exit;
        end;
        replacementLodDiffuse := ChangeFullToLodDirectory(replacementDiffuseNormalized);

        //In case the diffuse texture doesn't follow proper naming conventions...
        if RightStr(LowerCase(replacementLodDiffuse), 6) <> '_d.dds' then replacementLodDiffuse := TrimLeftChars(replacementLodDiffuse, 4) + '_d.dds';

        replacementNormal := replacementMatbgsm.EditValues['Textures\Normal'];
        replacementNormalNormalized := wbNormalizeResourceName(replacementNormal, resTexture);
        if replacementNormalNormalized = '' then replacementNormalNormalized := 'textures\shared\flatflat_n.dds'
        else if not ResourceExists(replacementNormalNormalized) then replacementNormalNormalized := 'textures\shared\flatflat_n.dds';

        replacementSpecular := replacementMatbgsm.EditValues['Textures\SmoothSpec'];
        replacementSpecularNormalized := wbNormalizeResourceName(replacementSpecular, resTexture);
        if replacementSpecularNormalized = '' then replacementSpecularNormalized := 'textures\shared\black01_d.dds'
        else if not ResourceExists(replacementSpecularNormalized) then replacementSpecularNormalized := 'textures\shared\black01_d.dds';

        specularMult := replacementMatbgsm.NativeValues['SpecularMult'] * replacementMatbgsm.NativeValues['Smoothness'];
        //AddMessage(FloatToStr(specularMult));

        //Check if the replacementDiffuse already has a lod texture being created by TexGen.
        if not bForceTexGenRedo then bLodTextureExists := DoesTexGenAlreadyHaveTexture(replacementLodDiffuse) else bLodTextureExists := False;

        //Attempt to add texgen rules to create the new lod replacement textures.
        if not bLodTextureExists then begin
            if not bForceTexGenRedo then AddMessage(#9 + 'TexGen does not have a texture for ' + replacementLodDiffuse + ', creating TexGen rules.');
            if not AddTexgenRules(omDiffuseNormalized, replacementDiffuseNormalized, replacementNormalNormalized, replacementSpecularNormalized, specularMult) then Exit;
        end
        else AddMessage(#9 + 'TexGen already has a texture for ' + replacementLodDiffuse + ', skipping TexGen rules creation.');

        //If we got this far, we can create the new lod material.

        lodDiffuse := StringReplace(TrimRightChars(replacementLodDiffuse, 9), '\', '/', [rfReplaceAll]);
        lodNormal := TrimLeftChars(lodDiffuse, 6) + '_n.dds';
        lodSpecular := TrimLeftChars(lodDiffuse, 6) + '_s.dds';
        replacementMatbgsm.EditValues['Textures\Diffuse'] := lodDiffuse;
        replacementMatbgsm.EditValues['Textures\Normal'] := lodNormal;
        replacementMatbgsm.EditValues['Textures\SmoothSpec'] := lodSpecular;
        replacementMatbgsm.EditValues['SpecularEnabled'] := 'yes';

        replacementMatbgsm.EditValues['ScreenSpaceReflections'] := 'no';
        replacementMatbgsm.EditValues['WetnessControlScreenSpaceReflections'] := 'no';
        replacementMatbgsm.EditValues['Decal'] := 'no';
        replacementMatbgsm.EditValues['DecalNoFade'] := 'no';
        replacementMatbgsm.EditValues['Refraction'] := 'no';
        replacementMatbgsm.EditValues['EnvironmentMapping'] := 'no';

        replacementMatbgsm.EditValues['Textures\Envmap'] := '';
        replacementMatbgsm.EditValues['Textures\Glow'] := '';
        replacementMatbgsm.EditValues['Textures\InnerLayer'] := '';
        replacementMatbgsm.EditValues['Textures\Wrinkles'] := '';
        replacementMatbgsm.EditValues['Textures\Displacement'] := '';
        replacementMatbgsm.EditValues['RimLighting'] := 'no';
        replacementMatbgsm.EditValues['SubsurfaceLighting'] := 'no';
        replacementMatbgsm.EditValues['AnisoLighting'] := 'no';
        replacementMatbgsm.EditValues['EmitEnabled'] := 'no';
        replacementMatbgsm.EditValues['ModelSpaceNormals'] := 'no';
        replacementMatbgsm.EditValues['ExternalEmittance'] := 'no';
        replacementMatbgsm.EditValues['ReceiveShadows'] := 'no';
        replacementMatbgsm.EditValues['CastShadows'] := 'no';
        replacementMatbgsm.EditValues['DissolveFade'] := 'no';
        replacementMatbgsm.EditValues['AssumeShadowmask'] := 'no';
        replacementMatbgsm.EditValues['Glowmap'] := 'no';
        replacementMatbgsm.EditValues['EnvironmentMappingWindow'] := 'no';
        replacementMatbgsm.EditValues['EnvironmentMappingEye'] := 'no';
        replacementMatbgsm.EditValues['Hair'] := 'no';
        replacementMatbgsm.EditValues['Tree'] := 'no';
        replacementMatbgsm.EditValues['Facegen'] := 'no';
        replacementMatbgsm.EditValues['SkinTint'] := 'no';
        replacementMatbgsm.EditValues['Tessellate'] := 'no';
        replacementMatbgsm.EditValues['SkewSpecularAlpha'] := 'no';
        EnsureDirectoryExists(wbScriptsPath + 'FOLIP\output\' + ExtractFilePath(rm));
        replacementMatbgsm.SaveToFile(wbScriptsPath + 'FOLIP\output\' + rm);
        AddMessage(#9 + 'Successfully created LOD Material Replacement: ' + rm + #9 + 'from' + #9 + om);
        Result := True;
    finally
        ombgsm.Free;
        replacementMatbgsm.Free;
    end;
end;

function AddTexgenRules(omDiffuseNormalized, replacementDiffuseNormalized, replacementNormalNormalized, replacementSpecularNormalized: string; specularMult: float): Boolean;
{
    Adds texgen rules to create the new lod replacement textures.
    Returns true if successful, false otherwise.
}
var
    new_line, tempDiffuse: string;
    slNew_lines: TStringList;
    i: integer;
begin
    Result := False;
    slNew_lines := TStringList.Create;
    try
        if ProcessTexgenFile(slFOLIPTexgen_noalpha, omDiffuseNormalized, replacementDiffuseNormalized, slNew_lines) then begin
            TexGenCopy(replacementDiffuseNormalized, replacementNormalNormalized, replacementSpecularNormalized, False, specularMult, tempDiffuse);
            for i := 0 to Pred(slNew_lines.Count) do begin
                new_line := StringReplace(slNew_lines[i], replacementDiffuseNormalized, tempDiffuse, [rfIgnoreCase]);
                slTexgen_noalpha.Add(new_line);
            end;
            Result := True;
        end
        else if ProcessTexgenFile(slFOLIPTexgen_alpha, omDiffuseNormalized, replacementDiffuseNormalized, slNew_lines) then begin
            TexGenCopy(replacementDiffuseNormalized, replacementNormalNormalized, replacementSpecularNormalized, True, specularMult, tempDiffuse);
            for i := 0 to Pred(slNew_lines.Count) do begin
                new_line := StringReplace(slNew_lines[i], replacementDiffuseNormalized, tempDiffuse, [rfIgnoreCase]);
                slTexgen_alpha.Add(new_line);
            end;
            Result := True;
        end;
    finally
        slNew_lines.Free;
    end;
end;

function TexGenCopy(replacementDiffuseNormalized, replacementNormalNormalized, replacementSpecularNormalized: string; alpha: Boolean; specularMult: float; var tempDiffuse: string): Boolean;
{
    Adds texgen copy and adjustment rules to create the new lod replacement textures.
    Returns true if adjustments were needed, false otherwise.
}
var
    lodNormal, lodSpecular, tempNormal, tempSpecular, diffuseLine, normalLine, specularLine, replacementDiffuseNormalizedActual: string;
    specularMultInt: integer;
begin
    Result := False;
    // We always need to copy the diffuse map to the tempDiffuse in case we don't need to adjust the specular.
    tempDiffuse := replacementDiffuseNormalized;

    //In case the diffuse texture doesn't follow proper naming convention of ending in _d.dds
    replacementDiffuseNormalizedActual := replacementDiffuseNormalized;
    if RightStr(LowerCase(replacementDiffuseNormalized), 6) <> '_d.dds' then begin
        replacementDiffuseNormalized := TrimLeftChars(replacementDiffuseNormalized, 4) + '_d.dds';
    end;

    // If the diffuse and normal do not have the same base name, we need to add a copy rule for the normal map.
    lodNormal := TrimLeftChars(replacementDiffuseNormalized, 6) + '_n.dds';
    if TrimLeftChars(replacementDiffuseNormalized, 6) <> TrimLeftChars(replacementNormalNormalized, 6) then begin
        slTexgen_copy.Add(replacementNormalNormalized + ',' + lodNormal);
        AddMessage(#9 + 'Adding TexGen copy rule for normal map: ' + replacementNormalNormalized + ' to ' + lodNormal);
        Result := True;
    end;

    // If the diffuse and specular do not have the same base name, we need to add a copy rule for the specular map.
    lodSpecular := TrimLeftChars(replacementDiffuseNormalized, 6) + '_s.dds';
    if TrimLeftChars(replacementDiffuseNormalized, 6) <> TrimLeftChars(replacementSpecularNormalized, 6) then begin
        slTexgen_copy.Add(replacementSpecularNormalized + ',' + lodSpecular);
        AddMessage(#9 + 'Adding TexGen copy rule for specular map: ' + replacementSpecularNormalized + ' to ' + lodSpecular);
        Result := True;
    end;

    // If the specular multiplier is less than 1, we need to add a rule to adjust the specular map.
    if specularMult < 1 then begin
        Result := True;
        specularMultInt := Round(100 * (specularMult - 1));
        tempDiffuse := 'DynDOLOD-Temp\' + replacementDiffuseNormalized;
        tempNormal := 'DynDOLOD-Temp\' + lodNormal;
        tempSpecular := 'DynDOLOD-Temp\' + lodSpecular;

        diffuseLine := '0' + #9 + '1' + #9 + '1' + #9 + '1' + #9 +
                        replacementDiffuseNormalizedActual +
                        #9 + 'x' + #9 + '7' + #9 + '0' + #9 + '0' + #9 +
                        tempDiffuse + #9 + '0' + #9 + 'x';

        normalLine := '0' + #9 + '1' + #9 + '1' + #9 + '1' + #9 +
                        lodNormal +
                        #9 + 'x' + #9 + '7' + #9 + '0' + #9 + '0' + #9 +
                        tempNormal + #9 + '0' + #9 + 'x';

        specularLine := IntToStr(specularMultInt) + #9 + '-1' + #9 + '1' + #9 + '1' + #9 +
                        lodSpecular +
                        #9 + 'x' + #9 + '7' + #9 + '0' + #9 + '0' + #9 +
                        tempSpecular + #9 + '0' + #9 + 'x';

        if alpha then begin
            slTexgen_alpha.Add(diffuseLine);
            slTexgen_alpha.Add(normalLine);
            slTexgen_alpha.Add(specularLine);
            AddMessage(#9 + 'Adding TexGen alpha rules for diffuse: ' + replacementDiffuseNormalized + ', normal: ' + lodNormal + ', specular: ' + lodSpecular);
        end
        else begin
            slTexgen_noalpha.Add(diffuseLine);
            slTexgen_noalpha.Add(normalLine);
            slTexgen_noalpha.Add(specularLine);
            AddMessage(#9 + 'Adding TexGen noalpha rules for diffuse: ' + replacementDiffuseNormalized + ', normal: ' + lodNormal + ', specular: ' + lodSpecular);
        end;
    end
    else if replacementDiffuseNormalizedActual <> replacementDiffuseNormalized then begin //This is triggered if the diffuse texture didn't follow proper naming standard of _d.dds, and didn't already get handled because of needed specular changes.
        Result := True;
        tempDiffuse := 'DynDOLOD-Temp\' + replacementDiffuseNormalized;
        tempNormal := 'DynDOLOD-Temp\' + lodNormal;
        tempSpecular := 'DynDOLOD-Temp\' + lodSpecular;

        diffuseLine := '0' + #9 + '1' + #9 + '1' + #9 + '1' + #9 +
                        replacementDiffuseNormalizedActual +
                        #9 + 'x' + #9 + '7' + #9 + '0' + #9 + '0' + #9 +
                        tempDiffuse + #9 + '0' + #9 + 'x';

        normalLine := '0' + #9 + '1' + #9 + '1' + #9 + '1' + #9 +
                        lodNormal +
                        #9 + 'x' + #9 + '7' + #9 + '0' + #9 + '0' + #9 +
                        tempNormal + #9 + '0' + #9 + 'x';

        specularLine := '0' + #9 + '1' + #9 + '1' + #9 + '1' + #9 +
                        lodSpecular +
                        #9 + 'x' + #9 + '7' + #9 + '0' + #9 + '0' + #9 +
                        tempSpecular + #9 + '0' + #9 + 'x';

        if alpha then begin
            slTexgen_alpha.Add(diffuseLine);
            slTexgen_alpha.Add(normalLine);
            slTexgen_alpha.Add(specularLine);
            AddMessage(#9 + 'Adding TexGen alpha rules for diffuse: ' + replacementDiffuseNormalized + ', normal: ' + lodNormal + ', specular: ' + lodSpecular);
        end
        else begin
            slTexgen_noalpha.Add(diffuseLine);
            slTexgen_noalpha.Add(normalLine);
            slTexgen_noalpha.Add(specularLine);
            AddMessage(#9 + 'Adding TexGen noalpha rules for diffuse: ' + replacementDiffuseNormalized + ', normal: ' + lodNormal + ', specular: ' + lodSpecular);
        end;
    end;
end;

function ProcessTexgenFile(slTexGen_file: TStringList; omDiffuseNormalized, replacementDiffuseNormalized: string; var slNew_lines: TStringList;): Boolean;
{
    Adds texgen rules to create the new lod replacement textures.
    Returns true if successful, false otherwise.
}
var
    slTextureList, slLine: TStringList;
    i, c, t: integer;
    bTextureMatch: boolean;
    new_line, lodDiffuse: string;
begin
    Result := False;
    slTextureList := TStringList.Create;
    lodDiffuse := ChangeFullToLodDirectory(replacementDiffuseNormalized);
    try
        slTextureList.Add(omDiffuseNormalized);
        AddMessage(#9 + 'Checking TexGen file for texture: ' + omDiffuseNormalized);

        //Check noalpha
        for i := 0 to Pred(slTexGen_file.Count) do begin
            bTextureMatch := False;
            if slTexGen_file[i] = '' then continue; // Skip empty lines

            for t := 0 to Pred(slTextureList.Count) do begin
                if ContainsText(slTexGen_file[i], slTextureList[t]) then begin

                    bTextureMatch := True;
                    Break; // Exit the inner loop if a match is found
                end;
            end;

            if bTextureMatch then begin
                AddMessage(#9 + 'Match found: ' + slTexGen_file[i]);

                slLine := TStringList.Create;
                try
                    slLine.Delimiter := #9; // Set delimiter to tab character
                    slLine.DelimitedText := slTexGen_file[i];

                    if ContainsText(slLine[0], '//') then begin // skip comment lines
                        continue;
                    end else if slLine[5] = 'x' then begin // skip x lines (temporary texture setup for mipmaps, typically for adjusting specular, which we should do automatically)
                        slTextureList.Add(TrimLeftChars(slLine[9], 5)); // Add the texture to the match list, removing the d.dds suffix
                        continue;
                    end else if slLine[5] = 'r' then begin // skip r lines (rotation lines)
                        AddMessage(#9 + 'Original material requires rotation: ' + slLine[9]);
                        Exit; //If rotation is required, we want to manually handle this, so exit the function.
                        // slTextureList.Add(slLine[9]); // Add the texture to the match list
                        // continue;
                    end;

                    if ContainsText(slLine[9], 'DynDOLOD-Temp') then begin
                        AddMessage(#9#9 + 'Warning: Original LOD texture has a TexGen rule that uses a temporary texture. It is possible that auto-generating the texture based off this may not produce the expected appearance.');
                        slTextureList.Add(slLine[9]); // Add the texture to the match list
                        continue;
                    end;

                    if ContainsText(slLine[4], 'DynDOLOD-Temp') then begin
                        AddMessage(#9#9 + 'Warning: Original LOD texture has a TexGen rule that uses a temporary texture.  It is possible that auto-generating the texture based off this may not produce the expected appearance.');
                        //Don't skip this line, as this is likely the main rule.
                    end;

                    new_line := slLine[0] + #9 + slLine[1] + #9 + slLine[2] + #9 + slLine[3] + #9
                                + replacementDiffuseNormalized
                                + #9 + slLine[5] + #9 + slLine[6] + #9 + slLine[7] + #9 + slLine[8] + #9
                                + lodDiffuse
                                + #9 + slLine[10] + #9 + slLine[11];
                    AddMessage(#9 + 'Adding new TexGen line: ' + new_line);
                    slNew_lines.Add(new_line);
                    Result := True;

                finally
                    slLine.Free;
                end;
            end;
        end;
    finally
        slTextureList.Free;
    end;
end;

function DoesTexGenAlreadyHaveTexture(texture: string): Boolean;
{
    Checks if TexGen already creates the texture.
    Returns true if the texture is found, false otherwise.
}
begin
    Result := False;
    if CheckTexGenFileForTexture(slFOLIPTexgen_noalpha, texture) then Result := True
    else if CheckTexGenFileForTexture(slFOLIPTexgen_alpha, texture) then Result := True;
end;

function CheckTexGenFileForTexture(slTexGen_file: TStringList; texture: string): Boolean;
{
    Checks if the given TexGen file already has a rule for the given texture.
    Returns true if the texture is found, false otherwise.
}
var
    i: integer;
    slLine: TStringList;
begin
    Result := False;
    texture := LowerCase(texture);
    for i := 0 to Pred(slTexGen_file.Count) do begin
        if slTexGen_file[i] = '' then continue; // Skip empty lines
        slLine := TStringList.Create;
        try
            slLine.Delimiter := #9; // Set delimiter to tab character
            slLine.DelimitedText := slTexGen_file[i];

            if ContainsText(slLine[0], '//') then continue; // skip comment lines

            if ((slLine.Count > 9) and SameText(LowerCase(slLine[9]), texture)) then begin
                Result := True;
                Break; // Exit the loop if the texture is found
            end;
        finally
            slLine.Free;
        end;
    end;
end;

procedure AddMaterialSwap(e: IInterface; om, rm: String);
{
    Given a material swap record e, add a new swap with om as the original material and rm as the replacement material.
}
var
    substitutions, ms: IInterface;
begin
    substitutions := ElementByPath(e, 'Material Substitutions');
    ms := ElementAssign(substitutions, HighInteger, nil, False);
    SetElementNativeValues(ms, 'BNAM - Original Material', om);
    SetElementNativeValues(ms, 'SNAM - Replacement Material', rm);
end;

procedure CompareMaterialSwaps(slMismatchedMaterials: TStringList; om, rm: String);
{
    Compares two material swaps and adds mismatched materials to the provided list.
}
var
    bgsmOm, bgsmRm: TwbBGSMFile;
    bgemOm, bgemRm: TwbBGEMFile;
    omScriptsPath, rmScriptsPath: string;
    bOmAutoGenerated, bRmAutoGenerated: Boolean;
begin
    om := wbNormalizeResourceName(om, resMaterial);
    rm := wbNormalizeResourceName(rm, resMaterial);
    bOmAutoGenerated := False;
    bRmAutoGenerated := False;

    if not ResourceExists(om) then begin
        if FileExists(wbScriptsPath + 'FOLIP\output\' + om) then begin
            omScriptsPath := wbScriptsPath + 'FOLIP\output\' + om;
            bOmAutoGenerated := True;
        end else begin
            AddMessage('Error: ' + om + ' does not exist.');
            Exit;
        end;
    end;
    if not ResourceExists(rm) then begin
        if FileExists(wbScriptsPath + 'FOLIP\output\' + rm) then begin
            rmScriptsPath := wbScriptsPath + 'FOLIP\output\' + rm;
            bRmAutoGenerated := True;
        end else begin
            AddMessage('Error: ' + rm + ' does not exist.');
            Exit;
        end;
    end;
    bgsmOm := TwbBGSMFile.Create;
    bgsmRm := TwbBGSMFile.Create;
    bgemOm := TwbBGEMFile.Create;
    bgemRm := TwbBGEMFile.Create;
    try
        if RightStr(om, 5) = '.bgsm' then begin
            if not bOmAutoGenerated then bgsmOm.LoadFromResource(om) else bgsmOm.LoadFromFile(omScriptsPath);
            if not bRmAutoGenerated then bgsmRm.LoadFromResource(rm) else bgsmRm.LoadFromFile(rmScriptsPath);

            if bgsmOm.NativeValues['TwoSided'] <> bgsmRm.NativeValues['TwoSided'] then begin
                if bgsmOm.EditValues['TwoSided'] = 'yes' then begin
                    if not bMakeMissingMaterials then slMismatchedMaterials.Add('Warning: ' + om + #9 + ' is Two Sided' + #13#10 + #9 + rm + ' should also be Two Sided, but it is not.')
                    else begin
                        bgsmRm.NativeValues['TwoSided'] := bgsmOm.NativeValues['TwoSided'];
                        EnsureDirectoryExists(wbScriptsPath + 'FOLIP\output\' + ExtractFilePath(rm));
                        bgsmRm.SaveToFile(wbScriptsPath + 'FOLIP\output\' + rm);
                    end;
                end;
            end;
            if bgsmOm.NativeValues['UOffset'] <> bgsmRm.NativeValues['UOffset'] then begin
                if om <> 'materials\lod\setdressing\signage\billboardsmtall02.bgsm' then slMismatchedMaterials.Add('Warning: ' + om + #9 + ' has a different UOffset from ' + #13#10 + #9 + rm);
            end;
            if bgsmOm.NativeValues['VOffset'] <> bgsmRm.NativeValues['VOffset'] then begin
                slMismatchedMaterials.Add('Warning: ' + om + #9 + ' has a different VOffset from ' + #13#10 + #9 + rm);
            end;
            if bgsmOm.NativeValues['UScale'] <> bgsmRm.NativeValues['UScale'] then begin
                slMismatchedMaterials.Add('Warning: ' + om + #9 + ' has a different UScale from ' + #13#10 + #9 + rm);
            end;
            if bgsmOm.NativeValues['VScale'] <> bgsmRm.NativeValues['VScale'] then begin
                slMismatchedMaterials.Add('Warning: ' + om + #9 + ' has a different VScale from ' + #13#10 + #9 + rm);
            end;
        end
        else if RightStr(om, 5) = '.bgem' then begin
            bgemOm.LoadFromResource(om);
            bgemRm.LoadFromResource(rm);
            if bgemOm.NativeValues['TwoSided'] <> bgemRm.NativeValues['TwoSided'] then begin
                if bgsmOm.EditValues['TwoSided'] = 'yes' then slMismatchedMaterials.Add('Warning: ' + om + #9 + ' is Two Sided' + #13#10 + #9 + rm + ' should also be Two Sided, but it is not.');
            end;
            if bgemOm.NativeValues['UOffset'] <> bgemRm.NativeValues['UOffset'] then begin
                slMismatchedMaterials.Add('Warning: ' + om + #9 + ' has a different UOffset from ' + #13#10 + #9 + rm);
            end;
            if bgemOm.NativeValues['VOffset'] <> bgemRm.NativeValues['VOffset'] then begin
                slMismatchedMaterials.Add('Warning: ' + om + #9 + ' has a different VOffset from ' + #13#10 + #9 + rm);
            end;
            if bgemOm.NativeValues['UScale'] <> bgemRm.NativeValues['UScale'] then begin
                slMismatchedMaterials.Add('Warning: ' + om + #9 + ' has a different UScale from ' + #13#10 + #9 + rm);
            end;
            if bgemOm.NativeValues['VScale'] <> bgemRm.NativeValues['VScale'] then begin
                slMismatchedMaterials.Add('Warning: ' + om + #9 + ' has a different VScale from ' + #13#10 + #9 + rm);
            end;
        end;
    finally
        bgsmOm.Free;
        bgsmRm.Free;
        bgemOm.Free;
        bgemRm.Free;
    end;
end;

procedure AssignLODModelsList;
{
    Assign lod models to STAT records.
}
var
    i, cnt: integer;
    HasLOD, bHasEnableParent, bHasSCOLNeedingLOD: Boolean;
    ms, s: IwbElement;
    joLOD: TJsonObject;
    sMissingLodMessage: string;
begin
    for i := 0 to Pred(tlStats.Count) do begin
        bHasEnableParent := False;
        bHasSCOLNeedingLOD := False;
        sMissingLodMessage := '';
        s := ObjectToElement(tlStats[i]);
        joLOD := TJsonObject.Create;
        try
            HasLOD := AssignLODModels(s, joLOD, sMissingLodMessage);

            //Add lod change if we are removing lod from it.
            if ((joLOD.Count > 0) and (joLOD['hasdistantlod'] = 0)) then AssignLODToStat(s, joLOD, False);

            //List relevant material swaps
            if HasLOD then begin
                cnt := ProcessReferences(s, bHasEnableParent, bHasSCOLNeedingLOD);

                //check for base material swap
                if (cnt > 0) and (ElementExists(s, 'Model\MODS - Material Swap')) then begin
                    ms := LinksTo(ElementByPath(s, 'Model\MODS'));
                    if tlMswp.IndexOf(ms) = -1 then tlMswp.Add(ms);
                end;

                if ((cnt > 0) and (joLOD.Count > 0)) then begin
                    slHasLOD.Add(RecordFormIdFileId(s));
                    AssignLODToStat(s, joLOD, false);
                    // Stripping this idea, since it more than doubles the amount of time required to do this, defeating the purpose of this idea.
                    // if bHasEnableParent and (not bHasSCOLNeedingLOD) then begin
                    //     tlActiFurnMstt.Add(s);
                    //     joLOD.S['level0'] := '';
                    //     joLOD.S['level1'] := '';
                    //     joLOD.S['level2'] := '';
                    //     joLOD.S['level3'] := '';
                    //     joLOD.I['hasdistantlod'] := 0;
                    //     AssignLODToStat(s, joLOD, True);
                    // end
                    // else begin
                    //     slHasLOD.Add(RecordFormIdFileId(s));
                    //     AssignLODToStat(s, joLOD, false);
                    // end;
                end;
            end
            else if bReportMissingLOD and (sMissingLodMessage <> '') then begin
                if IsObjectUsedInExterior(s) then slMissingLODMessages.Add(sMissingLodMessage);
            end;
        finally
            joLOD.Free;
        end;
    end;
end;

function IsObjectUsedInExterior(s: IInterface): boolean;
var
    si, cnt: integer;
    r, rCell, rWrld: IInterface;
begin
    cnt := 0;

    for si := Pred(ReferencedByCount(s)) downto 0 do begin
        r := ReferencedByIndex(s, si);
        if Signature(r) = 'SCOL' then begin
            if not IsObjectUsedInExterior(r) then continue;
            cnt := cnt + 1;
            break;
        end;
        if Signature(r) <> 'REFR' then continue;
        if not IsWinningOverride(r) then continue;
        if GetIsDeleted(r) then continue;
        rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
        if GetElementEditValues(rCell, 'DATA - Flags\Is Interior Cell') = 1 then continue;
        rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
        if Pos(RecordFormIdFileId(rWrld), sIgnoredWorldspaces) <> 0 then continue;

        // Check if WRLD inherits LOD from another worldspace
        if StrToBool(GetElementEditValues(rWrld,'Parent Worldspace\PNAM - Flags\Use LOD Data')) then continue;

        //This reference should get lod if it passes these checks.
        cnt := cnt + 1;
        break;
    end;
    if cnt > 0 then Result := True else Result := False;
end;

function ProcessReferences(s: IwbElement; var bHasEnableParent: Boolean; var bHasSCOLNeedingLOD: Boolean): integer;
var
    si, cnt: integer;
    ms, r, rCell, rWrld, xesp, parentRef, n, base: IwbElement;
    parent: string;
begin
    cnt := 0;
    for si := Pred(ReferencedByCount(s)) downto 0 do begin
        //r is not automatically a REFR.
        r := ReferencedByIndex(s, si);

        //if a SCOL, process the references of it.
        if Signature(r) = 'SCOL' then begin
            if not IsWinningOverride(r) then continue;
            if GetIsDeleted(r) then continue;
            cnt := cnt + ProcessReferences(r, bHasEnableParent, bHasSCOLNeedingLOD);
            continue;
        end;
        // skip anything else that isn't a REFR
        if Signature(r) <> 'REFR' then continue;
        if not IsWinningOverride(r) then continue;
        if GetIsDeleted(r) then continue;
        if GetIsCleanDeleted(r) then continue;

        // Check if cell is in an interior cell
        rCell := WinningOverride(LinksTo(ElementByIndex(r, 0)));
        try
            if GetElementEditValues(rCell, 'DATA - Flags\Is Interior Cell') = 1 then continue;
        except
            AddMessage('Skipped problem record: '+ GetFileName(rCell) + #9 + Name(rCell));
            continue;
        end;

        // Check if WRLD is in the ignore list
        rWrld := WinningOverride(LinksTo(ElementByIndex(rCell, 0)));
        if Pos(RecordFormIdFileId(rWrld), sIgnoredWorldspaces) <> 0 then continue;

        // Check if WRLD inherits LOD from another worldspace
        if StrToBool(GetElementEditValues(rWrld,'Parent Worldspace\PNAM - Flags\Use LOD Data')) then continue;

        // Increment count if you made it this far.
        cnt := cnt + 1;

        // Add any material swap to list of used material swaps to check.
        if ElementExists(r, 'XMSP - Material Swap') then begin
            ms := LinksTo(ElementByPath(r, 'XMSP'));
            if tlMswp.IndexOf(ms) = -1 then tlMswp.Add(ms);
        end;

        // check for enable parent
        if ElementExists(r, 'XESP - Enable Parent') then begin
            parent := GetElementEditValues(r, 'XESP\Reference');
            xesp := ElementByPath(r, 'XESP');
            parentRef := WinningOverride(LinksTo(ElementByIndex(xesp, 0)));
            bHasEnableParent := True;
            if tlEnableParents.IndexOf(parentRef) = -1 then tlEnableParents.Add(parentRef);
        end;

        base := WinningOverride(LinksTo(ElementByPath(r, 'NAME')));

        if ((Signature(base) <> 'SCOL') and (GetElementEditValues(r, 'Record Header\Record Flags\Is Full LOD') <> '0')) then begin
            iCurrentPlugin := RefMastersDeterminePlugin(rCell, True);
            iCurrentPlugin := RefMastersDeterminePlugin(rWrld, True);
            iCurrentPlugin := RefMastersDeterminePlugin(r, True);
            wbCopyElementToFile(rWrld, iCurrentPlugin, False, True);
            wbCopyElementToFile(rCell, iCurrentPlugin, False, True);
            n := CopyElementToFileWithVC(r, iCurrentPlugin);
            AddRefToMyFormlist(n, flRemoveIsFullLOD);
            SetElementEditValues(n, 'Record Header\Record Flags\Is Full LOD', '0');
            SetIsVisibleWhenDistant(n, GetElementNativeValues(MasterOrSelf(s), 'Record Header\Record Flags\Has Distant LOD'));
        end;
    end;
    if (Signature(s) = 'SCOL') and (cnt > 0) then begin
        bHasSCOLNeedingLOD := true;
        if (slHasLOD.IndexOf(RecordFormIdFileId(s)) = -1) then slHasLOD.Add(RecordFormIdFileId(s));
        //check for base material swap on the SCOL record
        if ElementExists(r, 'Model\MODS - Material Swap') then begin
            ms := LinksTo(ElementByPath(r, 'Model\MODS'));
            if tlMswp.IndexOf(ms) = -1 then tlMswp.Add(ms);
        end;
    end;
    Result := cnt;
end;

procedure AssignLODToStat(s: IwbElement; joLOD: TJsonObject; bAddHasDistantLOD: Boolean;);
var
    n: IwbElement;
begin
    //AddMessage(ShortName(s) + #9 + joLOD.S['level0'] + #9 + joLOD.S['level1'] + #9 + joLOD.S['level2']);
    iCurrentPlugin := RefMastersDeterminePlugin(s, True);
    n := wbCopyElementToFile(s, iCurrentPlugin, False, True);

    if bAddHasDistantLOD then SetElementNativeValues(n, 'Record Header\Record Flags\Has Distant LOD', joLOD.I['hasdistantlod'])
    else SetElementNativeValues(n, 'Record Header\Record Flags\Has Distant LOD', GetElementNativeValues(MasterOrSelf(s), 'Record Header\Record Flags\Has Distant LOD'));
    Add(n, 'MNAM', True);
    SetElementNativeValues(n, 'MNAM\LOD #0 (Level 0)\Mesh', joLOD.S['level0']);
    SetElementNativeValues(n, 'MNAM\LOD #1 (Level 1)\Mesh', joLOD.S['level1']);
    SetElementNativeValues(n, 'MNAM\LOD #2 (Level 2)\Mesh', joLOD.S['level2']);
    SetElementNativeValues(n, 'MNAM\LOD #3 (Level 3)\Mesh', joLOD.S['level3']);

    // if Equals(GetFile(s), GetFile(n)) then Exit;
    // if GetElementEditValues(s, 'MNAM\LOD #0 (Level 0)\Mesh') <> GetElementEditValues(n, 'MNAM\LOD #0 (Level 0)\Mesh') then Exit;
    // if GetElementEditValues(s, 'MNAM\LOD #1 (Level 1)\Mesh') <> GetElementEditValues(n, 'MNAM\LOD #1 (Level 1)\Mesh') then Exit;
    // if GetElementEditValues(s, 'MNAM\LOD #2 (Level 2)\Mesh') <> GetElementEditValues(n, 'MNAM\LOD #2 (Level 2)\Mesh') then Exit;
    // if GetElementEditValues(s, 'MNAM\LOD #3 (Level 3)\Mesh') <> GetElementEditValues(n, 'MNAM\LOD #3 (Level 3)\Mesh') then Exit;
    // if GetElementEditValues(s, 'Record Header\Record Flags\Has Distant LOD') <> GetElementEditValues(n, 'Record Header\Record Flags\Has Distant LOD') then Exit;
    // AddMessage('Removing ITM: ' + ShortName(s));
    // Remove(n);
end;

procedure CollectRecords;
{
    Use this to collect all the record types you need to process over.
    It will iterate over all files in the load order regardless of what is selected in xEdit.

    This should be faster than iterating over all elements selected in the interface,
    since it only will process the specified record groups.
}
var
    i, j, idx: integer;
    recordId: string;
    r: IInterface;
    g: IwbElement;
    f: IwbFile;
begin
    //Iterate over all files.
    for i := 0 to Pred(FileCount) do begin
        f := FileByIndex(i);
        if i = 0 then begin
            g := GroupBySignature(f, 'TXST');
            for j := 0 to Pred(ElementCount(g)) do begin
                r := ElementByIndex(g, j);
                if ReferencedByCount(r) = 0 then continue;
                tlTxst.Add(r);
            end;
        end;

        //STAT
        g := GroupBySignature(f, 'STAT');
        for j := 0 to Pred(ElementCount(g)) do begin
            r := ElementByIndex(g, j);
            if not IsWinningOverride(r) then continue;
            if ReferencedByCount(r) = 0 then continue;
            tlStats.Add(r);
        end;

        //MSTT
        g := GroupBySignature(f, 'MSTT');
        for j := 0 to Pred(ElementCount(g)) do begin
            r := ElementByIndex(g, j);
            if not IsWinningOverride(r) then continue;
            if ReferencedByCount(r) = 0 then continue;
            tlActiFurnMstt.Add(r);
        end;

        //FURN
        g := GroupBySignature(f, 'FURN');
        for j := 0 to Pred(ElementCount(g)) do begin
            r := ElementByIndex(g, j);
            if not IsWinningOverride(r) then continue;
            if ReferencedByCount(r) = 0 then continue;
            tlActiFurnMstt.Add(r);
        end;

        //ACTI
        g := GroupBySignature(f, 'ACTI');
        for j := 0 to Pred(ElementCount(g)) do begin
            r := ElementByIndex(g, j);
            if not IsWinningOverride(r) then continue;
            if ReferencedByCount(r) = 0 then continue;
            tlActiFurnMstt.Add(r);
        end;

        //DOOR
        g := GroupBySignature(f, 'DOOR');
        for j := 0 to Pred(ElementCount(g)) do begin
            r := ElementByIndex(g, j);
            if not IsWinningOverride(r) then continue;
            if ReferencedByCount(r) = 0 then continue;
            tlActiFurnMstt.Add(r);
        end;

        {
        //CONT
        g := GroupBySignature(f, 'CONT');
        for j := 0 to Pred(ElementCount(g)) do begin
            r := ElementByIndex(g, j);
            if not IsWinningOverride(r) then continue;
            tlActiFurnMstt.Add(r);
        end;


        //FLOR
        g := GroupBySignature(f, 'FLOR');
        for j := 0 to Pred(ElementCount(g)) do begin
            r := ElementByIndex(g, j);
            if not IsWinningOverride(r) then continue;
            tlActiFurnMstt.Add(r);
        end;

        //MISC
        g := GroupBySignature(f, 'MISC');
        for j := 0 to Pred(ElementCount(g)) do begin
            r := ElementByIndex(g, j);
            if not IsWinningOverride(r) then continue;
            tlActiFurnMstt.Add(r);
        end;
        }

    end;
    AddMessage('Found ' + IntToStr(tlStats.Count) + ' STAT records.');
    AddMessage('Found ' + IntToStr(tlActiFurnMstt.Count) + ' ACTI, DOOR, FURN, and MSTT records.');
end;

procedure FilesInContainers(containers: TStringList);
{
    Retrieves the ba2 packed files.
}
var
    slArchivedFiles, slVanilla, slModded: TStringList;
    i, total: integer;
    f, fNoLod, archive, tp: string;
begin
    slArchivedFiles := TStringList.Create;
    slArchivedFiles.Sorted := True;
    slArchivedFiles.Duplicates := dupIgnore;
    slVanilla := TStringList.Create;
    slModded := TStringList.Create;
    try
        for i := 0 to Pred(containers.Count) do begin
            archive := TrimRightChars(containers[i], Length(wbDataPath));
            if ContainsText(archive, ' - Animations.ba2') then continue;
            if ContainsText(archive, ' - Interface.ba2') then continue;
            if ContainsText(archive, ' - MeshesExtra.ba2') then continue;
            if ContainsText(archive, ' - Nvflex.ba2') then continue;
            if ContainsText(archive, ' - Shaders.ba2') then continue;
            if ContainsText(archive, ' - Sounds.ba2') then continue;
            if ContainsText(archive, ' - Startup.ba2') then continue;
            if ContainsText(archive, ' - Textures.ba2') then continue;
            if ContainsText(archive, ' - Textures1.ba2') then continue;
            if ContainsText(archive, ' - Textures2.ba2') then continue;
            if ContainsText(archive, ' - Textures3.ba2') then continue;
            if ContainsText(archive, ' - Textures4.ba2') then continue;
            if ContainsText(archive, ' - Textures5.ba2') then continue;
            if ContainsText(archive, ' - Textures6.ba2') then continue;
            if ContainsText(archive, ' - Textures7.ba2') then continue;
            if ContainsText(archive, ' - Textures8.ba2') then continue;
            if ContainsText(archive, ' - Textures9.ba2') then continue;
            if ContainsText(archive, ' - Voices.ba2') then continue;
            if ContainsText(archive, ' - Voices_cn.ba2') then continue;
            if ContainsText(archive, ' - Voices_de.ba2') then continue;
            if ContainsText(archive, ' - Voices_en.ba2') then continue;
            if ContainsText(archive, ' - Voices_es.ba2') then continue;
            if ContainsText(archive, ' - Voices_esmx.ba2') then continue;
            if ContainsText(archive, ' - Voices_fr.ba2') then continue;
            if ContainsText(archive, ' - Voices_it.ba2') then continue;
            if ContainsText(archive, ' - Voices_ja.ba2') then continue;
            if ContainsText(archive, ' - Voices_pl.ba2') then continue;
            if ContainsText(archive, ' - Voices_ptbr.ba2') then continue;
            if ContainsText(archive, ' - Voices_ru.ba2') then continue;
            if archive <> '' then AddMessage('Loaded archive: ' + archive);

            //Check if the archive is a vanilla archive.
            if ContainsText(archive, 'DLCCoast - Main.ba2') or
            ContainsText(archive, 'DLCNukaWorld - Main.ba2') or
            ContainsText(archive, 'DLCworkshop01 - Main.ba2') or
            ContainsText(archive, 'DLCworkshop02 - Main.ba2') or
            ContainsText(archive, 'DLCworkshop03 - Main.ba2') or
            ContainsText(archive, 'Fallout4 - Materials.ba2') then ResourceList(containers[i], slVanilla)
            else ResourceList(containers[i], slModded);

            //Add all files in the archive to the list of archived files.
            ResourceList(containers[i], slArchivedFiles);
        end;
        for i := 0 to Pred(slVanilla.Count) do begin
            slVanilla[i] := LowerCase(slVanilla[i]);
        end;
        for i := 0 to Pred(slModded.Count) do begin
            slModded[i] := LowerCase(slModded[i]);
        end;

        AddMessage('Please wait while we detect all LOD assets...');

        total := slArchivedFiles.Count;
        for i := 0 to Pred(total) do begin
            f := LowerCase(slArchivedFiles[i]);
            try
                //materials or meshes
                if IsInLODDir(f, 'materials') then begin
                    slMatFiles.Add(f);

                    fNoLod := StringReplace(f, '\lod\', '\', [rfReplaceAll, rfIgnoreCase]);
                    if (slVanilla.IndexOf(fNoLod) > -1) and (slModded.IndexOf(fNoLod) > -1) then begin
                        if ((not ContainsText(fNoLod,'materials\architecture\shacks\shacklod01.bgsm')) and bMakeMissingMaterials) then CompareModdedMaterialToVanilla(fNoLod, f);
                    end;

                    if not bReportNonLODMaterials then continue;
                    if MatHasNonLodTexture(f, tp) then AddMessage('Warning: ' + f + ' appears to be using a non-LOD texture.' + #13#10 + #9 + tp);
                end
                else if IsInLODDir(f, 'meshes') and IsLODResourceModel(f) then begin
                    slNifFiles.Add(f);
                end;
            except on E: Exception do AddMessage(#9 + 'Error processing file ' + f + #9 + E.Message);
            end;

            if i mod 10000 = 0 then begin
                AddMessage('Processed ' + IntToStr(i) + ' of ' + IntToStr(total) + ' files.');
            end;
        end;
    finally
        slVanilla.Free;
        slModded.Free;
        slArchivedFiles.Free;
    end;
end;

function FetchVanillaContainer(f: string): string;
{
    Fetches the vanilla container for a given file.
}
var
    i: integer;
    slCurrentContainers, slVanillaContainers: TStringList;
    currentContainer: string;
begin
    Result := '';
    slCurrentContainers := TStringList.Create;
    slVanillaContainers := TStringList.Create;
    try
        slVanillaContainers.Add(wbDataPath + 'Fallout4 - Materials.ba2');
        slVanillaContainers.Add(wbDataPath + 'DLCworkshop01 - Main.ba2');
        slVanillaContainers.Add(wbDataPath + 'DLCworkshop02 - Main.ba2');
        slVanillaContainers.Add(wbDataPath + 'DLCworkshop03 - Main.ba2');
        slVanillaContainers.Add(wbDataPath + 'DLCCoast - Main.ba2');
        slVanillaContainers.Add(wbDataPath + 'DLCNukaWorld - Main.ba2');
        ResourceCount(f, slCurrentContainers);
        for i := Pred(slCurrentContainers.Count) downto 0 do begin
            currentContainer := slCurrentContainers[i];
            if slVanillaContainers.IndexOf(currentContainer) > -1 then begin
                Result := currentContainer;
                break;
            end;
        end;
    finally
        slCurrentContainers.Free;
        slVanillaContainers.Free;
    end;
end;

function FetchCurrentContainer(f: string): string;
{
    Fetches the current container for a given file.
}
var
    slCurrentContainers: TStringList;
begin
    slCurrentContainers := TStringList.Create;
    try
        ResourceCount(f, slCurrentContainers);
        Result := slCurrentContainers[Pred(slCurrentContainers.Count)];
    finally
        slCurrentContainers.Free;
    end;
end;

function ExtractResourceToTempDirectory(f: string): Boolean;
{
    Extracts the resource f to the FOLIPTempPath. Returns true if successful.
}
var
    container, folder, filename, outfile: string;
begin
    Result := False;
    try
        folder := ExtractFilePath(f);
        filename := ExtractFileName(f);
        outfile := FOLIPTempPath + '\' + folder + filename;
        container := FetchCurrentContainer(f);
        EnsureDirectoryExists(FOLIPTempPath + '\' + folder);
        ResourceCopy(container, f, outfile);
        Result := True;
    except on E: Exception do AddMessage(#9 + 'Error accessing resource ' + f + #9 + E.Message);
    end;
end;

function CompareModdedMaterialToVanilla(f, lodMaterial: string;): Boolean;
{
    Compares a modded material file to the vanilla material file.
    Returns True if the modded material is different from the vanilla material.
    f is the full material path.
    lodMaterial is the lod material path.
}
var
    i: integer;
    bgsmModded, bgsmVanilla, bgsmLod: TwbBGSMFile;
    vanillaContainer: string;
begin
    Result := False; //Assume no differences found.
    if not ResourceExists(f) then begin
        AddMessage(#9 + 'Warning: ' + f + ' does not exist.');
        Exit;
    end;
    //Fetch vanilla container
    vanillaContainer := FetchVanillaContainer(f);
    if vanillaContainer = '' then begin
        AddMessage(#9 + 'Warning: Could not find vanilla container for ' + f);
        Exit;
    end;
    bgsmModded := TwbBGSMFile.Create;
    bgsmVanilla := TwbBGSMFile.Create;
    try
        try
            bgsmModded.LoadFromResource(f);
        except on E: Exception do AddMessage(#9 + 'Error loading resource ' + f + #9 + E.Message);
        end;

        try
            bgsmVanilla.LoadFromResource(vanillaContainer, f);
        except on E: Exception do AddMessage(#9 + 'Error loading vanilla resource ' + f + #9 + E.Message);
        end;

        if bgsmVanilla.NativeValues['UOffset'] <> bgsmModded.NativeValues['UOffset'] then begin
            AddMessage(#9 + 'Warning: ' + f + ' has a modified UOffset value.');
            Result := True;
        end;
        if bgsmVanilla.NativeValues['VOffset'] <> bgsmModded.NativeValues['VOffset'] then begin
            AddMessage(#9 + 'Warning: ' + f + ' has a modified VOffset value.');
            Result := True;
        end;
        if bgsmVanilla.NativeValues['UScale'] <> bgsmModded.NativeValues['UScale'] then begin
            AddMessage(#9 + 'Warning: ' + f + ' has a modified UScale value.');
            Result := True;
        end;
        if bgsmVanilla.NativeValues['VScale'] <> bgsmModded.NativeValues['VScale'] then begin
            AddMessage(#9 + 'Warning: ' + f + ' has a modified VScale value.');
            Result := True;
        end;
        if bgsmVanilla.NativeValues['AlphaTest'] <> bgsmModded.NativeValues['AlphaTest'] then begin
            AddMessage(#9 + 'Warning: ' + f + ' has a modified AlphaTest value.');
            Result := True;
        end;
        if bgsmVanilla.NativeValues['TwoSided'] <> bgsmModded.NativeValues['TwoSided'] then begin
            AddMessage(#9 + 'Warning: ' + f + ' has a modified TwoSided value.');
            Result := True;
        end;
        if bgsmVanilla.EditValues['Textures\Diffuse'] <> bgsmModded.EditValues['Textures\Diffuse'] then begin
            AddMessage(#9 + 'Warning: ' + f + ' has a modified Diffuse texture.');
            Result := True;
        end;
        if bgsmVanilla.EditValues['Textures\Normal'] <> bgsmModded.EditValues['Textures\Normal'] then begin
            AddMessage(#9 + 'Warning: ' + f + ' has a modified Normal texture.');
            Result := True;
        end;
        if bgsmVanilla.EditValues['Textures\SmoothSpec'] <> bgsmModded.EditValues['Textures\SmoothSpec'] then begin
            AddMessage(#9 + 'Warning: ' + f + ' has a modified Specular texture.');
            Result := True;
        end;
        if bgsmVanilla.EditValues['Textures\Grayscale'] <> bgsmModded.EditValues['Textures\Grayscale'] then begin
            AddMessage(#9 + 'Warning: ' + f + ' has a modified Grayscale palette texture.');
            Result := True;
        end;
        if bgsmVanilla.NativeValues['GrayscaleToPaletteScale'] <> bgsmModded.NativeValues['GrayscaleToPaletteScale'] then begin
            AddMessage(#9 + 'Warning: ' + f + ' has a modified GrayscaleToPaletteScale value.');
            Result := True;
        end;
        if bgsmVanilla.NativeValues['GrayscaleToPaletteColor'] <> bgsmModded.NativeValues['GrayscaleToPaletteColor'] then begin
            AddMessage(#9 + 'Warning: ' + f + ' has a modified GrayscaleToPaletteColor value.');
            Result := True;
        end;
        if Result then begin
            bgsmLod := TwbBGSMFile.Create;
            try
                try
                    bgsmLod.LoadFromResource(lodMaterial);
                except on E: Exception do AddMessage(#9 + 'Error loading lod resource ' + lodMaterial + #9 + E.Message);
                end;
                if ((bgsmLod.EditValues['GrayscaleToPaletteColor'] = 'no') and (bgsmModded.EditValues['GrayscaleToPaletteColor'] = 'yes')) then begin
                    AddMessage(#9 + 'Warning: ' + f + ' cannot have an autogenerated matching LOD material created due to its use of Grayscale To Palette Color where its LOD requires a non Grayscale to Palette Color material. It would require manual handling to fix.');
                    Result := False;
                end
                else if bMakeMissingMaterials then CreateLODMaterialReplacement(lodMaterial, lodMaterial, f, True);
            finally
                bgsmLod.free;
            end;
        end;
    finally
        bgsmModded.free;
        bgsmVanilla.free;
    end;
end;

function MatHasNonLodTexture(const f: string; var tp: string): Boolean;
{
    Checks to see if a material file resource contains non-lod textures.
}
var
    bgsm: TwbBGSMFile;
begin
    Result := False;
    bgsm := TwbBGSMFile.Create;
    try
        bgsm.LoadFromResource(f);

        tp := bgsm.EditValues['Textures\Diffuse'];
        if not (ContainsText(tp, 'lod/') or ContainsText(tp, 'lod\')) then begin
            Result := True;
            Exit;
        end;

        tp := bgsm.EditValues['Textures\Normal'];
        if not (ContainsText(tp, 'lod/') or ContainsText(tp, 'lod\')) then begin
            Result := True;
            Exit;
        end;

        tp := bgsm.EditValues['Textures\SmoothSpec'];
        if not (ContainsText(tp, 'lod/') or ContainsText(tp, 'lod\')) then begin
            Result := True;
            Exit;
        end;
    finally
        bgsm.free;
    end;
end;

procedure LoadRules(f: string);
{
    Load LOD Rules and Material Swap Map JSON files
}
var
    sub: TJsonObject;
    c, a: integer;
    j, key: string;
begin
    //LOD Rules
    j := 'FOLIP\' + TrimLeftChars(f, 4) + ' - LODRules.json';
    if ResourceExists(j) then begin
        AddMessage('Loaded LOD Rule File: ' + j);
        sub := TJsonObject.Create;
        try
            sub.LoadFromResource(j);
            for c := 0 to Pred(sub.Count) do begin
                key := sub.Names[c];
                joRules.O[key].Assign(sub.O[key]);
            end;
        finally
            sub.Free;
        end;
    end;
    //Material Swap Maps
    j := 'FOLIP\' + TrimLeftChars(f, 4) + ' - MaterialSwapMap.json';
    if ResourceExists(j) then begin
        AddMessage('Loaded LOD Material Swap File: ' + j);
        sub := TJsonObject.Create;
        try
            sub.LoadFromResource(j);
            for c := 0 to Pred(sub.Count) do begin
                key := sub.Names[c];
                for a := 0 to Pred(sub.A[key].Count) do joMswpMap.A[key].Add(sub.A[key].S[a]);
            end;
        finally
            sub.Free;
        end;
    end;
    //MultiRefLOD
    j := 'FOLIP\' + TrimLeftChars(f, 4) + ' - MultiRefLOD.json';
    if ResourceExists(j) then begin
        try
            sub := TJsonObject.Create;
            sub.LoadFromResource(j);
            for c := 0 to Pred(sub.Count) do begin
                key := sub.Names[c];
                joMultiRefLOD.O[key].Assign(sub.O[key]);
            end;
        finally
            sub.Free;
        end;
    end;

    //Ignore Enable Parents
    j := 'FOLIP\' + TrimLeftChars(f, 4) + ' - Ignore Enable Parents.json';
    if ResourceExists(j) then begin
        AddMessage('Loaded Ignore Enable Parents File: ' + j);
        sub := TJsonObject.Create;
        try
            sub.LoadFromResource(j);
            key := 'Ignore Enable Parents';
            for a := 0 to Pred(sub.A[key].Count) do begin
                if sEnableParentFormidExclusions = '' then
                    sEnableParentFormidExclusions := sub.A[key].S[a]
                else
                    sEnableParentFormidExclusions := sEnableParentFormidExclusions + ',' + sub.A[key].S[a];
            end;
        finally
            sub.Free;
            AddMessage('Ignored Enable Parents: ' + sEnableParentFormidExclusions);
        end;
    end;

    //Ignore Worldspaces
    j := 'FOLIP\' + TrimLeftChars(f, 4) + ' - Ignore Worldspaces.json';
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

end;

function AssignLODModels(s: IInterface; joLOD: TJsonObject; var sMissingLodMessage: string): Boolean;
{
    Assigns LOD Models to Stat records.
}
var
    hasChanged, ruleOverride: Boolean;
    i, c, hasDistantLOD, xBnd, yBnd, zBnd: integer;
    n: IInterface;
    colorRemap, lod4, lod8, lod16, lod32, model, omodel, olod4, olod8, olod16, olod32, editorid: string;
    slTopPaths, slMaterialsFromFullModel: TStringList;
begin
    hasChanged := False;
    ruleOverride := False;
    olod4 := '';
    olod8 := '';
    olod16 := '';
    olod32 := '';
    hasDistantLOD := 0;

    omodel := LowerCase(GetElementEditValues(s, 'Model\MODL - Model FileName'));

    if LeftStr(omodel, 7) <> 'meshes\' then model := 'meshes\' + omodel else model := omodel;

    colorRemap := FloatToStr(StrToFloatDef(GetElementEditValues(s, 'Model\MODC - Color Remapping Index'),'9'));
    if colorRemap = '9' then colorRemap := '' else colorRemap := '_' + colorRemap;

    //Only STAT records have these. We use this function on other signatures that don't have these fields.
    if Signature(s) = 'STAT' then begin
        olod4 := LowerCase(GetElementNativeValues(s, 'MNAM\LOD #0 (Level 0)\Mesh'));
        olod8 := LowerCase(GetElementNativeValues(s, 'MNAM\LOD #1 (Level 1)\Mesh'));
        olod16 := LowerCase(GetElementNativeValues(s, 'MNAM\LOD #2 (Level 2)\Mesh'));
        olod32 := LowerCase(GetElementNativeValues(s, 'MNAM\LOD #3 (Level 3)\Mesh'));
        hasDistantLOD := GetElementNativeValues(s,'Record Header\Record Flags\Has Distant LOD');
    end;

    editorid := LowerCase(GetElementEditValues(s, 'EDID'));

    if joRules.Contains(editorid) then begin
        lod4 := joRules.O[editorid].S['level0'];
        lod8 := joRules.O[editorid].S['level1'];
        if bForceLOD8 and (lod8 = '') and (lod4 <> '') then lod8 := lod4;
        lod16 := joRules.O[editorid].S['level2'];
        lod32 := joRules.O[editorid].S['level3'];
        if joRules.O[editorid].S['hasdistantlod'] = 'false' then ruleOverride := True;
    end
    else if ((LowerCase(RightStr(editorid, 5)) = 'nolod') and (not bIgnoreNoLOD)) then begin
        slMessages.Add(ShortName(s) + ' - Editor ID ends in "nolod", so it will be skipped.');
        Result := False;
        Exit;
    end
    else if joRules.Contains(omodel) then begin
        lod4 := joRules.O[omodel].S['level0'];
        lod8 := joRules.O[omodel].S['level1'];
        if bForceLOD8 and (lod8 = '') and (lod4 <> '') then lod8 := lod4;
        lod16 := joRules.O[omodel].S['level2'];
        lod32 := joRules.O[omodel].S['level3'];
        if joRules.O[omodel].S['hasdistantlod'] = 'false' then ruleOverride := True;
    end
    else begin
        slTopPaths := TStringList.Create;
        for i := Pred(slTopLevelModPatternPaths.Count) downto 0 do begin
            if ContainsText(model, 'meshes\' + slTopLevelModPatternPaths[i]) then slTopPaths.Add(slTopLevelModPatternPaths[i]);
        end;
        lod4 := LODModelForLevel(s, model, colorRemap, '0', olod4, slTopPaths);
        lod8 := LODModelForLevel(s, model, colorRemap, '1', olod8, slTopPaths);
        if bForceLOD8 and (lod8 = '') and (lod4 <> '') then lod8 := lod4;
        lod16 := LODModelForLevel(s, model, colorRemap, '2', olod16, slTopPaths);
        lod32 := LODModelForLevel(s, model, colorRemap, '3', olod32, slTopPaths);
        slTopPaths.Free;

        //If no lod4 model has been specified, report a list of models that would possibly benefit from having lod.
        if bReportMissingLOD and (lod4 = '') and (LowerCase(RightStr(editorid, 3)) <> 'lod') then begin
            xBnd := Abs(GetElementNativeValues(s, 'OBND\X1')) + GetElementNativeValues(s, 'OBND\X2');
            yBnd := Abs(GetElementNativeValues(s, 'OBND\Y1')) + GetElementNativeValues(s, 'OBND\Y2');
            zBnd := Abs(GetElementNativeValues(s, 'OBND\Z1')) + GetElementNativeValues(s, 'OBND\Z2');
            if (xBnd > 1000) or (yBnd > 1000) or (zBnd > 1000) then begin
                sMissingLodMessage := ShortName(s) + ' with object bounds of ' + IntToStr(xBnd) + 'x' + IntToStr(yBnd) + 'x' + IntToStr(zBnd) + ' has no lod.'
            end;
        end;
    end;

    if lod4 <> olod4 then hasChanged := True
    else if lod8 <> olod8 then hasChanged := True
    else if lod16 <> olod16 then hasChanged := True
    else if lod32 <> olod32 then hasChanged := True;
    if hasDistantLOD = 0 then begin
        if lod4 <> '' then hasDistantLOD := 1
        else if lod8 <> '' then hasDistantLOD := 1
        else if lod16 <> '' then hasDistantLOD := 1
        else if lod32 <> '' then hasDistantLOD := 1;
        if hasDistantLOD = 1 then hasChanged := True;
    end;

    //ruleOverride means that the record should not have distant LOD.
    if ruleOverride then hasDistantLOD := 0;

    model := LowerCase(wbNormalizeResourceName(model, resMesh));
    if ((hasDistantLOD <> 0) and (slCheckedModels.IndexOf(model) = -1)) then begin
        slCheckedModels.Add(model);

        slMaterialsFromFullModel := TStringList.Create;
        slMaterialsFromFullModel.Sorted := True;
        slMaterialsFromFullModel.Duplicates := dupIgnore;
        try
            AddMessage(ShortName(s) + #9 + model + #9 + lod4 + #9 + lod8 + #9 + lod16 + #9 + lod32);
            if ((model <> '') and bReportNonLODMaterials) then AddMaterialsFromModel(model, slMaterialsFromFullModel);
            ProcessLODModel(model, lod4, colorRemap, slMaterialsFromFullModel);
            ProcessLODModel(model, lod8, colorRemap, slMaterialsFromFullModel);
            ProcessLODModel(model, lod16, colorRemap, slMaterialsFromFullModel);
            ProcessLODModel(model, lod32, colorRemap, slMaterialsFromFullModel);
        finally
            slMaterialsFromFullModel.Free;
        end;
    end;

    if hasChanged then begin
        //AddMessage(ShortName(s) + #9 + model + #9 + lod4 + #9 + lod8 + #9 + lod16 + #9 + lod32);
        joLOD.I['hasdistantlod'] := hasDistantLOD;
        joLOD.S['level0'] := lod4;
        joLOD.S['level1'] := lod8;
        joLOD.S['level2'] := lod16;
        joLOD.S['level3'] := lod32;
    end;
    if hasDistantLOD <> 0 then Result := True else Result := False;
end;

procedure ProcessLODModel(FullModel, LODModel, colorRemap: string; slMaterialsFromFullModel: TStringList);
{
    Processes a LOD model.
}
var
    c, tp: integer;
    slMaterialsFromLODModel, slTopPaths, slPossibleLODPaths, slExistingSubstitutions: TStringList;
    material: string;
begin
    if LODModel = '' then Exit;
    LODModel := wbNormalizeResourceName(LODModel, resMesh);

    slMaterialsFromLODModel := TStringList.Create;
    slMaterialsFromLODModel.Sorted := True;
    slMaterialsFromLODModel.Duplicates := dupIgnore;

    slPossibleLODPaths := TStringList.Create;
    try
        if (slUsedLODNifFiles.IndexOf(LODModel) = -1) then begin
            slUsedLODNifFiles.Add(LODModel);
            if bReportNonLODMaterials or bReportUVs then begin
                if MeshCheck(LODModel, slMaterialsFromLODModel) then slOutsideUVRange.Add('Warning: ' + LODModel + #9 + ' has UVs outside the 0 to 1 range.');
            end;
            if bReportNonLODMaterials then begin
                //Check the full models materials for Possible LOD materials and populate slPossibleLODPaths.
                for c := 0 to Pred(slMaterialsFromFullModel.Count) do begin
                    material := slMaterialsFromFullModel[c];
                    slTopPaths := TStringList.Create;
                    slExistingSubstitutions := TStringList.Create;
                    try
                        for tp := 0 to Pred(slTopLevelModPatternPaths.Count) do begin
                            if ContainsText(material, 'materials\' + slTopLevelModPatternPaths[tp]) then slTopPaths.Add(slTopLevelModPatternPaths[tp]);
                        end;
                        LODMaterial(material, colorRemap, slTopPaths, slExistingSubstitutions, slPossibleLODPaths);
                    finally
                        slTopPaths.Free;
                        slExistingSubstitutions.Free;
                    end;
                end;

                //Check the LOD materials for matches in slPossibleLODPaths and warn if any are not matches.
                for c := 0 to Pred(slMaterialsFromLODModel.Count) do begin
                    material := TrimRightChars(slMaterialsFromLODModel[c], 10);
                    if slPossibleLODPaths.IndexOf(material) = -1 then begin
                        slMismatchedFullModelToLODMaterials.Add('Warning: ' + LODModel + #9 + ' has a LOD material that does not match the known full model materials: ' + #9 + material);
                    end;
                end;
            end;
        end;
    finally
        slMaterialsFromLODModel.Free;
        slPossibleLODPaths.Free;
    end;
end;

procedure AddMaterialsFromModel(model: string; var slMaterialsFromModel: TStringList);
{
    Adds materials from a model to a string list of materials.
}
var
    i: integer;
    nif: TwbNifFile;
    block: TwbNifBlock;
    mat, modelAuto: string;
    bModelAutoGenerated: Boolean;
begin
    if model = '' then Exit;
    model := wbNormalizeResourceName(model, resMesh);
    bModelAutoGenerated := False;

    if not ResourceExists(model) then begin
        if FileExists(wbScriptsPath + 'FOLIP\output\' + model) then begin
            modelAuto := wbScriptsPath + 'FOLIP\output\' + model;
            bModelAutoGenerated := True;
        end else begin
            AddMessage(#9 + 'Error: ' + model + ' does not exist.');
            Exit;
        end;
    end;

    nif := TwbNifFile.Create;
    try
        if not bModelAutoGenerated then nif.LoadFromResource(model) else nif.LoadFromFile(modelAuto);
        for i := 0 to Pred(nif.BlocksCount) do begin
            block := nif.Blocks[i];
            if block.BlockType = 'BSLightingShaderProperty' then begin
                mat := wbNormalizeResourceName(block.EditValues['Name'], resMaterial);
                if not SameText(ExtractFileExt(mat), '.bgsm') then continue
                else slMaterialsFromModel.Add(LowerCase(mat));
            end;
        end;
    finally
        nif.Free;
    end;
end;

function MeshCheck(f: string; var slMaterialsFromModel: TStringList): Boolean;
{
    Various checks for LOD models.
    Returns True if the model has UV coordinates outside the range of 0.0 to 1.0.
}
var
    tsUV: TStrings;
    j, k, vertexCount, iTimesOutsideRange: integer;
    uv, u, v, mat, modelAuto: string;
    nif: TwbNifFile;
    arr, vertex: TdfElement;
    block, b: TwbNifBlock;
    bWasEverAbleToCheck, bIsTrishape, bModified, bModelAutoGenerated: boolean;
begin
    f := wbNormalizeResourceName(f, resMesh);
    bWasEverAbleToCheck := False;
    bModified := False;
    iTimesOutsideRange := 0;
    nif := TwbNifFile.Create;

    bModelAutoGenerated := False;
    if not ResourceExists(f) then begin
        if FileExists(wbScriptsPath + 'FOLIP\output\' + f) then begin
            modelAuto := wbScriptsPath + 'FOLIP\output\' + f;
            bModelAutoGenerated := True;
        end else begin
            AddMessage(#9 + 'Error: ' + f + ' does not exist.');
            Exit;
        end;
    end;

    Result := True;
    try
        if not bModelAutoGenerated then nif.LoadFromResource(f) else nif.LoadFromFile(modelAuto);
        // iterate over all nif blocks
        for j := 0 to Pred(nif.BlocksCount) do begin
            block := nif.Blocks[j];
            bIsTrishape := False;
            if block.BlockType = 'BSLightingShaderProperty' then begin
                mat := block.EditValues['Name'];
                if not SameText(ExtractFileExt(mat), '.bgsm') then begin
                    slMeshCheckNoMaterialSpecified.Add('Warning: ' + f + #9 + ' does not specify a material');
                end
                else begin
                    mat := wbNormalizeResourceName(mat, resMaterial);
                    if not (ResourceExists(mat) or FileExists(wbScriptsPath + 'FOLIP\output\' + mat)) then slMeshCheckMissingMaterials.Add('Error: ' + f + #9 + ' has a specified material that does not seem to exist: ' + #9 + mat);
                    if not ContainsText(ExtractFilePath(mat), 'lod') then slMeshCheckNonLODMaterials.Add('Warning: ' + f + #9 + ' has a specified material that is not in a LOD directory: ' + #9 + mat);
                    slMaterialsFromModel.Add(LowerCase(mat));
                end;
            end;
            if not bReportUVs then continue;
            if block.IsNiObject('BSTriShape', True) then bIsTrishape := True;
            if block.IsNiObject('BSMeshLODTriShape', True) then bIsTrishape := True;
            if not bIsTrishape then continue;
            vertexCount := block.NativeValues['Num Vertices'];
            if vertexCount < 1 then continue;
            arr := block.Elements['Vertex Data'];
            for k := 0 to Pred(vertexCount) do begin
                vertex := arr[k];
                uv := vertex.EditValues['UV'];
                if Length(uv) < 1 then break;
                bWasEverAbleToCheck := True;
                tsUV := SplitString(uv, ' ');
                u := tsUV[0];
                v := tsUV[1];
                if StrToFloatDef(u, 9) < -0.1 then iTimesOutsideRange := iTimesOutsideRange + 1;
                if StrToFloatDef(u, 9) > 1.1 then iTimesOutsideRange := iTimesOutsideRange + 1;
                if StrToFloatDef(v, 9) < -0.1 then iTimesOutsideRange := iTimesOutsideRange + 1;
                if StrToFloatDef(v, 9) > 1.1 then iTimesOutsideRange := iTimesOutsideRange + 1;
                if iTimesOutsideRange = 0 then Result := False else begin
                    Result := True;
                    Exit;
                end;
            end;
            // if block.IsNiObject('BSMeshLODTriShape', True) then begin
            //     Turn this on if you want to convert LOD meshes with BSMeshLODTriShape to BSTriShape.
            //     nif.ConvertBlock(j, 'BSTriShape');
            //     bModified := True;
            // end;
        end;
    finally
        if bModified then begin
            EnsureDirectoryExists(wbScriptsPath + 'FOLIP\output\' + ExtractFilePath(f));
            nif.SaveToFile(wbScriptsPath + 'FOLIP\output\' + f);
        end;
        nif.free;
    end;
    if not bWasEverAbleToCheck then Result := False;
end;

procedure CheckUsedLODModels;
{
    Checks all used LOD models for various issues.
    Reports missing LOD nif files, not in LOD directory, or does not follow LOD naming convention.
}
var
    i: integer;
    f: string;
    slMissingLODNifFiles, slNotInLODDirectory, slDoesNotFollowLODNamingConvention: TStringList;
begin
    slMissingLODNifFiles := TStringList.Create;
    slMissingLODNifFiles.Sorted := True;
    slMissingLODNifFiles.Duplicates := dupIgnore;

    slNotInLODDirectory := TStringList.Create;
    slNotInLODDirectory.Sorted := True;
    slNotInLODDirectory.Duplicates := dupIgnore;

    slDoesNotFollowLODNamingConvention := TStringList.Create;
    slDoesNotFollowLODNamingConvention.Sorted := True;
    slDoesNotFollowLODNamingConvention.Duplicates := dupIgnore;
    try
        for i := 0 to Pred(slUsedLODNifFiles.Count) do begin
            f := slUsedLODNifFiles[i];
            if not (ResourceExists(f) or FileExists(wbScriptsPath + 'FOLIP\output\' + f)) then begin
                slMissingLODNifFiles.Add('Error: ' + f + #9 + ' does not exist.');
                continue;
            end;
            if not IsInLODDir(f, 'meshes') then slNotInLODDirectory.Add('Warning: ' + f + #9 + ' is not in a LOD directory.');
            if (not IsLODResourceModel(f)) and (not SameText(RightStr(f, 7), 'lod.nif')) then slDoesNotFollowLODNamingConvention.Add('Warning: ' + f + #9 + ' does not follow LOD naming conventions.');
        end;
    finally
        AddMessage(IntToStr(i + 1) + ' of ' +  IntToStr(slUsedLODNifFiles.Count) + ' LOD models were checked.');
        ListStringsInStringList(slMismatchedFullModelToLODMaterials);
        if bReportUVs then begin
            ListStringsInStringList(slMeshCheckMissingMaterials);
            ListStringsInStringList(slMeshCheckNoMaterialSpecified);
            ListStringsInStringList(slMeshCheckNonLODMaterials);
            ListStringsInStringList(slOutsideUVRange);
        end;
        ListStringsInStringList(slMissingLODNifFiles);
        ListStringsInStringList(slNotInLODDirectory);
        ListStringsInStringList(slDoesNotFollowLODNamingConvention);

        slMissingLODNifFiles.Free;
        slNotInLODDirectory.Free;
        slDoesNotFollowLODNamingConvention.Free;
    end;
end;

function LODModelForLevel(e: IwbElement; model, colorRemap, level, original: string; slTopPaths: TStringList;): string;
{
    Given a model and level, checks to see if an LOD model exists and returns it.
}
var
    searchModel, p1, p2, p3: string;
    i: integer;
    bColorRemap: Boolean;
begin

    for i := 0 to Pred(slTopPaths.Count) do begin
        // meshes\dlc01\test.nif  to  meshes\dlc01\lod\test.nif
        searchModel := StringReplace(model, 'meshes\' + slTopPaths[i], 'meshes\' + slTopPaths[i] + 'lod\', [rfReplaceAll, rfIgnoreCase]);
        // meshes\dlc01\lod\test.nif  to  meshes\dlc01\lod\test_lod. Add colorRemap as _0.5 as well.
        searchModel := TrimLeftChars(searchModel, 4);

        bColorRemap := false;
        if Length(colorRemap) > 0 then bColorRemap := true;

        if bColorRemap then begin
            //p3 is for specific color remap level lod like 'model_0.5_lod_1.nif'
            p3 := searchModel + colorRemap + '_lod_' + level + '.nif';
            if slNifFiles.IndexOf(p3) > -1 then begin
                Result := TrimRightChars(p3, 7);
                Exit;
            end;
        end;

        //p1 is for specific level lod like 'model_lod_1.nif'
        p1 := searchModel + '_lod_' + level + '.nif';
        if slNifFiles.IndexOf(p1) > -1 then begin
            if bColorRemap then begin
                if bMakeMissingMaterials then begin
                    if not AttemptCreateColorRemapLODModel(p1, p3, colorRemap)
                    then slMissingColorRemaps.Add('Warning: Possible missing color remap of ' + colorRemap + ' for model: ' + #9 + model + #9 + ShortName(e))
                    else begin
                        Result := TrimRightChars(p3, 7);
                        slNifFiles.Add(p3); // Add the newly created color remapped LOD model to the list of NIF files.
                        AddMessage(#9 + 'Successfully created missing color remap of ' + colorRemap + ' for model: ' + #9 + model + #9 + ShortName(e));
                        Exit;
                    end;
                end
                else slMissingColorRemaps.Add('Warning: Possible missing color remap of ' + colorRemap + ' for model: ' + #9 + model + #9 + ShortName(e));
            end
            else begin
                Result := TrimRightChars(p1, 7);
                Exit;
            end;
        end;

        //p2 is for non-specific level lod like 'model_lod.nif'
        p2 := searchModel + '_lod.nif';
        if ((level = '0') and (slNifFiles.IndexOf(p2) > -1)) then begin
            Result := TrimRightChars(p2, 7);
            Exit;
        end;
    end;
    //If you made it this far, no lod models were found using the expected paths, so return the original specified lod model in the record, if any.
    Result := original;
end;

function AttemptCreateColorRemapLODModel(lodModelNoRemap, lodModelWithRemap, colorRemap: string): Boolean;
{
    Attempts to create a color remapped version of an existing LOD model.
}
var
    lodModelNoRemapNif: TwbNifFile;
    i: integer;
    block: TwbNifBlock;
    mat, matColorRemap, lodModelNoRemapAuto: string;
    bHadColorRemap, bModelAutoGenerated: Boolean;
begin
    Result := False;
    AddMessage('Attempting to create missing color remapped LOD Model: ' + #9 + lodModelWithRemap);
    bHadColorRemap := False;

    if not ResourceExists(lodModelNoRemap) then begin
        if FileExists(wbScriptsPath + 'FOLIP\output\' + lodModelNoRemap) then begin
            lodModelNoRemapAuto := wbScriptsPath + 'FOLIP\output\' + lodModelNoRemap;
            bModelAutoGenerated := True;
        end else begin
            AddMessage(#9 + 'Error: ' + lodModelNoRemap + ' does not exist. Color remapped LOD model creation aborted.');
            Exit;
        end;
    end;

    lodModelNoRemapNif := TwbNifFile.Create;
    try
        if not bModelAutoGenerated then lodModelNoRemapNif.LoadFromResource(lodModelNoRemap) else lodModelNoRemapNif.LoadFromFile(lodModelNoRemapAuto);
        for i := 0 to Pred(lodModelNoRemapNif.BlocksCount) do begin
            block := lodModelNoRemapNif.Blocks[i];
            if block.BlockType = 'BSLightingShaderProperty' then begin
                mat := wbNormalizeResourceName(block.EditValues['Name'], resMaterial);
                if not SameText(ExtractFileExt(mat), '.bgsm') then continue
                matColorRemap := CreateColorRemapBGSM(mat, colorRemap);
                if not SameText(matColorRemap, mat) then bHadColorRemap := True;
                block.EditValues['Name'] := matColorRemap;
            end;
        end;
        if not bHadColorRemap then begin
            AddMessage(#9 + 'Color remapped LOD model could not be created, as the base lod model does not use grayscale to palette scale for its materials.');
            Exit; //No color remap change was created, so exit without saving.
        end;
        //Save the color remapped version of the LOD model.
        EnsureDirectoryExists(wbScriptsPath + 'FOLIP\output\' + ExtractFilePath(lodModelWithRemap));
        lodModelNoRemapNif.SaveToFile(wbScriptsPath + 'FOLIP\output\' + lodModelWithRemap);
        Result := True;
    finally
        lodModelNoRemapNif.Free;
    end;
end;

function CreateColorRemapBGSM(material, colorRemap: string): string;
{
    Creates a color remapped version of a BGSM material.
    Color remap is the string to append to the material name, like '_0.5'.
    Returns the new material name.
}
var
    materialBGSM: TwbBGSMFile;
    renamedMaterial, materialAuto: string;
    bMaterialAutoGenerated: Boolean;
begin
    Result := material;

    if not ResourceExists(material) then begin
        if FileExists(wbScriptsPath + 'FOLIP\output\' + material) then begin
            materialAuto := wbScriptsPath + 'FOLIP\output\' + material;
            bMaterialAutoGenerated := True;
        end else begin
            AddMessage(#9 + 'Error: ' + material + ' does not exist.');
            Exit;
        end;
    end;

    materialBGSM := TwbBGSMFile.Create;
    try
        if not bMaterialAutoGenerated then materialBGSM.LoadFromResource(material) else materialBGSM.LoadFromFile(materialAuto);
        if materialBGSM.EditValues['GrayscaleToPaletteColor'] <> 'yes' then Exit;
        materialBGSM.EditValues['GrayscaleToPaletteScale'] := TrimRightChars(colorRemap, 1);
        renamedMaterial := TrimLeftChars(material, 5) + colorRemap + '.bgsm';
        EnsureDirectoryExists(wbScriptsPath + 'FOLIP\output\' + ExtractFilePath(renamedMaterial));
        materialBGSM.SaveToFile(wbScriptsPath + 'FOLIP\output\' + renamedMaterial);
        slMatFiles.Add(renamedMaterial); // Add the newly created color remapped material to the list of materials.
        Result := renamedMaterial;
    finally
        materialBGSM.Free;
    end;
end;

function LODMaterial(material, colorRemap: string; slTopPaths, slExistingSubstitutions, slPossibleLODPaths: TStringList): string;
{
    Checks to see if an LOD material exists and returns it.
}
var
    i, a: integer;
    searchMaterial, p1, p2, p3, p4: string;
begin
    // DLC04\Architecture\GalacticZone\MetalPanelTrimCR02.BGSM, _0.93
    Result := ChangeFullToLodDirectory(material);
    for i := 0 to Pred(slTopPaths.Count) do begin
        // materials\dlc01\test.bgsm to materials\dlc01\lod\test.bgsm
        searchMaterial := StringReplace(material, 'materials\' + slTopPaths[i], 'materials\' + slTopPaths[i] + 'lod\', [rfReplaceAll, rfIgnoreCase]);
        p1 := TrimLeftChars(searchMaterial, 5) + colorRemap + '.bgsm';
        //if Result = '' then Result := p1;
        if ((slMatFiles.IndexOf(p1) > -1) and (slExistingSubstitutions.IndexOf(p1) = -1)) then begin
            //sanity check
            //AddMessage(TrimRightChars(p1, 10));
            slPossibleLODPaths.Add(TrimRightChars(p1, 10));
        end;
        p2 := TrimLeftChars(searchMaterial, 5) + 'lod.bgsm';
        if ((slMatFiles.IndexOf(p2) > -1) and (slExistingSubstitutions.IndexOf(p2) = -1)) then slPossibleLODPaths.Add(TrimRightChars(p2, 10));
        p3 := TrimLeftChars(searchMaterial, 5) + '_lod.bgsm';
        if ((slMatFiles.IndexOf(p3) > -1) and (slExistingSubstitutions.IndexOf(p3) = -1)) then slPossibleLODPaths.Add(TrimRightChars(p3, 10));
    end;

    //Material Swap Map Rules
    searchMaterial := TrimRightChars(material,10);
    if joMswpMap.Contains(searchMaterial) then begin
        for a := 0 to Pred(joMswpMap.A[searchMaterial].Count) do begin
            p4 := joMswpMap.A[searchMaterial].S[a];
            if slExistingSubstitutions.IndexOf('materials\' + p4) = -1 then slPossibleLODPaths.Add(p4);
        end;
    end;
end;

function RefMastersDeterminePlugin(r: IInterface; var bPlugin: Boolean;): IInterface;
{
    Sets the output file to either the ESM file or the ESP file based on the required masters for the given reference.
}
begin
    AddRequiredElementMasters(r, iFolipPluginFile, False, True);
  	SortMasters(iFolipPluginFile);
    Result := iFolipPluginFile
    {if bPlugin then begin
        AddRequiredElementMasters(r, iFolipPluginFile, False, True);
        SortMasters(iFolipPluginFile);
        Result := iFolipPluginFile;
        bPlugin := True;
        Exit;
    end;
    try
        AddRequiredElementMasters(r, iFolipMasterFile, False, True);
        SortMasters(iFolipMasterFile);
        Result := iFolipMasterFile;
    except
        on E : Exception do begin
            AddRequiredElementMasters(r, iFolipPluginFile, False, True);
            SortMasters(iFolipPluginFile);
            Result := iFolipPluginFile;
            bPlugin := True;
        end;
    end;}
end;

procedure FetchRules;
{
    Loads the Rule JSON files.
}
var
    c, i: integer;
    f, j, key: string;
begin
    for i := 0 to Pred(FileCount) do begin
        f := GetFileName(FileByIndex(i));
        slPluginFiles.Add(f);
        LoadRules(f);
    end;
    j := 'FOLIP\UserRules.json';
    if ResourceExists(j) then begin
        AddMessage('Loaded LOD Rule File: ' + j);
        joUserRules := TJsonObject.Create;
        joUserRules.LoadFromResource(j);
        for c := 0 to Pred(joUserRules.Count) do begin
            key := joUserRules.Names[c];
            joRules.O[key].Assign(joUserRules.O[key]);
        end;
    end;
    SortJSONObjectKeys(joRules);
end;

function CreatePlugins: Boolean;
{
    Checks the plugins to ensure required mods are not missing.
    Checks to make sure an old patch generated from this script is not present.
    Creates the plugin files we need.
}
var
    bFO4LODGen, bFolip: Boolean;
    i: integer;
    f: string;
begin
    bFO4LODGen := False;
    bFolip := False;
    for i := 0 to Pred(FileCount) do begin
        f := GetFileName(FileByIndex(i));

        if SameText(f, sFolipMasterFileName) then
            iFolipMasterFile := FileByIndex(i)
        else if SameText(f, sFolipPluginFileName + '.esp') then begin
            iFolipPluginFile := FileByIndex(i);
            bPreviousBeforeGenerationPresent := True;
        end
        else if SameText(f, sFO4LODGenFileName) then
            bFO4LODGen := True
        else if SameText(f, sFolipFileName) then
            bFolip := True;
    end;
    if not bFO4LODGen then begin
        MessageDlg('Please install FO4LODGen Resources from https://www.nexusmods.com/fallout4/mods/80276 before continuing.', mtError, [mbOk], 0);
        Result := 0;
        Exit;
    end;
    if not bFolip then begin
        MessageDlg('Please install Far Object LOD Improvement Project from https://www.nexusmods.com/fallout4/mods/61884 before continuing.', mtError, [mbOk], 0);
        Result := 0;
        Exit;
    end;
    {if not Assigned(iFolipMasterFile) then begin
        MessageDlg(sFolipMasterFileName + ' not found! Please install if from https://www.nexusmods.com/fallout4/mods/61884 before continuing.', mtError, [mbOk], 0);
        Result := 0;
        Exit;
    end;}
    if Assigned(iFolipMasterFile) then begin
        MessageDlg(sFolipMasterFileName + ' found! This file is now deprecated and should no longer be used. Please remove.', mtError, [mbOk], 0);
        Result := 0;
        Exit;
    end;
    if not Assigned(iFolipPluginFile) then begin
        iFolipPluginFile := AddNewFileName(sFolipPluginFileName + '.esp', False);
        AddMasterIfMissing(iFolipPluginFile, 'Fallout4.esm');
        AddMasterIfMissing(iFolipPluginFile, 'sFolipMasterFileName');
    end;

    Result := 1;
end;

function IsLODResourceModel(f: string): Boolean;
{
    Given the filename, returns true if it follows the naming convention for an LOD resource model:
    _lod.nif
    _lod_0.nif
    _lod_1.nif
    _lod_2.nif
    _lod_3.nif
}
var
    rf: string;
begin
    Result := False;
    f := LowerCase(f);
    rf := RightStr(f, 10); //_lod_#.nif
    if rf = '_lod_0.nif' then Result := True
    else if rf = '_lod_1.nif' then Result := True
    else if rf = '_lod_2.nif' then Result := True
    else if rf = '_lod_3.nif' then Result := True
    else if RightStr(f, 8) = '_lod.nif' then Result := True;
end;

function IsInLODDir(f, m: string): Boolean;
{
    Checks the file path to see if it is in an LOD resource directory location.
    f is the file path.
    m is used to differentiate meshes vs materials top level directory.
}
var
    i: integer;
    parts: TStringDynArray;
    between: string;
begin
    Result := False;
    if LeftStr(f, Length(m)) <> m then Exit;
    parts := SplitString(f, '\');
    for i := 1 to 2 do begin
        try
            if parts[i] = 'lod' then begin
                Result := True;
                if i = 2 then begin
                    between := parts[1] + '\';
                    if slTopLevelModPatternPaths.IndexOf(between) = -1 then begin
                        AddMessage('Added sub path: ' + between);
                        slTopLevelModPatternPaths.Add(between);
                    end;
                end;
                Break;
            end;
        except
            Break;
        end;
    end;
end;

function ChangeFullToLodDirectory(f: string): string;
{
    Given a file path, changes the directory to the LOD directory.
    f is the file path.
}
var
    parts: TStringDynArray;
begin
    parts := SplitString(f, '\');
    if Length(parts) = 0 then begin
        //meshes\ to meshes\lod
        Result := StringReplace(f, parts[0], parts[0] + '\lod', [rfIgnoreCase]);
    end
    else if slTopLevelModPatternPaths.IndexOf(parts[1]) = -1 then begin
        //meshes\path\to\model.nif to meshes\lod\path\to\model.nif
        Result := StringReplace(f, parts[0], parts[0] + '\lod', [rfIgnoreCase]);
    end
    else begin
        //meshes\dlc03\path\to\model.nif to meshes\dlc03\lod\path\to\model.nif
        Result := StringReplace(f, parts[1], parts[1] + '\lod', [rfIgnoreCase]);
    end;
end;

function GetIsCleanDeleted(r: IInterface): Boolean;
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

// ----------------------------------------------------
// Generic Functions and Procedures go below.
// ----------------------------------------------------

function BoolToStr(b: boolean): string;
{
    Given a boolean, return a string.
}
begin
    if b then Result := 'true' else Result := 'false';
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

function StripNonAlphanumeric(Input: string): string;
var
  i: Integer;
  c: char;
begin
    Result := '';
    i := 1;
    while i <= Length(Input) do begin
        c := Copy(Input,i,1);
        if Pos(c,'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789') <> 0 then Result := Result + c;
        inc(i);
    end;
end;

procedure EnsureDirectoryExists(f: string);
{
    Create directories if they do not exist.
}
begin
    if not DirectoryExists(f) then
        if not ForceDirectories(f) then
            raise Exception.Create('Can not create destination directory ' + f);
end;

procedure ListStringsInStringList(sl: TStringList);
{
    Given a TStringList, add a message for all items in the list.
}
var
    i, count: integer;
begin
    count := sl.Count;
    if count < 1 then Exit;
    AddMessage('=======================================================================================');
    for i := 0 to Pred(count) do AddMessage(sl[i]);
    AddMessage('=======================================================================================');
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

procedure SortJSONObjectKeys(JSONObj: TJsonObject);
{
    Sorts JSON keys alphabetically.
}
var
    SortedKeys: TStringList;
    Key: string;
    NewJSONObj: TJsonObject;
    i: integer;
begin
    // Create a sorted list of keys
    SortedKeys := TStringList.Create;
    NewJSONObj := TJsonObject.Create;
    try
        for i := 0 to Pred(JSONObj.Count) do SortedKeys.Add(JSONObj.Names[i]);
        SortedKeys.Sort; // Sort the keys alphabetically

        for i := 0 to Pred(SortedKeys.Count) do begin
            Key := SortedKeys[i];
            NewJSONObj.O[Key].Assign(JSONObj.O[Key]);
        end;

        // Replace the original JSONObj with the sorted one
        JSONObj.Clear;
        JSONObj.Assign(NewJSONObj);
    finally
        SortedKeys.Free;
        NewJSONObj.Free;
    end;
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

function RecordFormIdFileId(e: IwbElement): string;
{
    Returns the record ID of an element.
}
begin
    Result := TrimRightChars(IntToHex(FixedFormID(e), 8), 2) + ':' + GetFileName(GetFile(MasterOrSelf(e)));
end;

function GetRecordFromFormIdFileId(recordId: string): IwbElement;
{
    Returns the record from the given formid:filename.
}
var
    colonPos, recordFormId, c: integer;
    f: IwbFile;
    fileMasterIndex: string;
begin
    colonPos := Pos(':', recordId);
    f := FileByIndex(slPluginFiles.IndexOf(Copy(recordId, Succ(colonPos), Length(recordId))));
    c := MasterCount(f);
    if c > 9 then fileMasterIndex := IntToStr(c) else fileMasterIndex := '0' + IntToStr(c);
    recordFormId := StrToInt('$' + fileMasterIndex + Copy(recordId, 1, Pred(colonPos)));
    Result := RecordByFormID(f, recordFormId, False);
end;

function DeleteDirectory(dir: string): boolean;
{
    Deletes a directory and all files and subdirectories in it. Returns true if successful.
}
var
    srFind : TSearchRec;
    f: string;
begin
    Result := True;
    if not DirectoryExists(dir) then Exit;

    if FindFirst(dir + '\*', faAnyFile, srFind) = 0 then begin
        repeat
            if ((srFind.Name <> '.') and (srFind.Name <> '..')) then begin
                f := dir + '\' + srFind.Name;

                if ((srFind.attr and faDirectory) = faDirectory) then begin
                    if (not DeleteDirectory(f)) then begin
                        Result := False;
                        Exit;
                    end;
                end
                else begin
                    if (not DeleteFile(f)) then begin
                        Result := False;
                        Exit;
                    end;
                end;
            end;
        until FindNext(srFind) <> 0;

        FindClose(srFind);
    end;

    if (not RemoveDir(dir)) then begin
        Result := False;
        Exit;
    end;
end;

end.