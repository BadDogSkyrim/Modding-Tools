unit BDFurrySkyrimOptions;

interface
implementation

uses
    BDScriptTools, Windows, SysUtils, Classes;

const
    PATCH_FILE_NAME = 'YASNPCPatch.esp'; // Set to whatever
    USE_SELECTION = FALSE;           // FALSE or TRUE
    FURRIFY_ARMOR = TRUE;         
    FURRIFY_NPCS_MALE = TRUE;
    FURRIFY_NPCS_FEM = TRUE;
    SHOW_HAIR_ASSIGNMENT = TRUE;
    MAX_TINT_LAYERS = 200; // Max tint layers to apply to a NPC
    LOG_ARMOR = 0;
    LOG_NPCS = 0;
    LOG_SCHLONGS = 0;
    CLEAR_MESSAGE_WINDOW = TRUE;
    CLEAN_TARGET_FILE = TRUE;

var
    settingPatchFileName: string;
    settingUseSelection: Boolean;
    settingShowHairAssignment: boolean;
    settingCleanTargetFile: Boolean;
    settingGhoulRace: string;
    settingGhoulChildRace: string;
    settingLogLevel: Integer;

//=========================================================
// Create options form
function SetOptions(showForm: Boolean): Boolean;
var
    bannerPic: TPicture;
    banner: TImage;
    pluginName: TEdit;
    rname: TEdit;
    cb1, cb2, cb3, cb4, cb5, terseDebugBtn, verboseDebugBtn: TCheckBox;
    ghoulRace, ghoulChildRace: TEdit;
    races, childraces: string;
begin
    if not showForm then begin
        // Use defaults
        settingPatchFileName := PATCH_FILE_NAME;
        settingUseSelection := USE_SELECTION;
        settingShowHairAssignment := SHOW_HAIR_ASSIGNMENT;
        settingCleanTargetFile := CLEAN_TARGET_FILE;
        Result := TRUE;
        Exit;
    end;

    MakeForm('YAS Furrifier', 800, 600);
    bannerPic := TPicture.Create;
    bannerPic.LoadFromFile(wbScriptsPath + 'Images\YASBanner.png');

    banner := MakeFormImage(bannerPic);

    pluginName := MakeFormEdit('New plugin name', PATCH_FILE_NAME);

    MakeFormSectionLabel('Patch');
    cb1 := MakeFormCheckBox('Entire load order', (not USE_SELECTION));
    cb2 := MakeFormCheckBox('Selected NPCs', USE_SELECTION);

    MakeFormSectionLabel('Debugging');
    terseDebugBtn := MakeFormCheckBox('Terse', FALSE);
    verboseDebugBtn := MakeFormCheckBox('Verbose', FALSE);

    MakeFormOKCancel;

    if bdstForm.ShowModal = mrOK then begin
        AddMessage('OK');
        if EndsText('.esp', pluginName.text) then
            settingPatchFileName := pluginName.text
        else
            settingPatchFileName := pluginName.text + '.esp';
        settingUseSelection := cb2.checked;

        LOGLEVEL := 0;
        if terseDebugBtn.checked then LOGLEVEL := 5;
        if verboseDebugBtn.checked then LOGLEVEL := 15;
        LOGGING := (LOGLEVEL > 0);

        Result := TRUE;
    end
    else begin
        Result := FALSE;
    end;
end;


end.