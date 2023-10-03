{
  Output external assets (meshes and textures) used in selected records
  List is sorted without dups.

	Hotkey: Ctrl+Alt+P
}
unit UserScript;

interface
implementation

uses BDScriptTools, xEditApi, StrUtils;

const
    showUnused = FALSE;

var
  slResources, slNifs, slProcessed, slFalsePositives, slGameFiles: TStringList;
  currentName: string;
  outpath: string;
  recursionLevel: integer; 

function Initialize: integer;
begin
    AddMessage('+++++++ List Used Assets ++++++');
    LOGLEVEL := 0;

    slResources := TStringList.Create;
    slResources.Sorted := True;
    slResources.Duplicates := dupIgnore;

    slNifs := TStringList.Create;
    slNifs.Duplicates := dupIgnore;
    
    slProcessed := TStringList.Create;
    
    currentName := '';
    outpath := '';
    
    recursionLevel := 0;
    
    slGameFiles := TStringList.Create;
    slGameFiles.Add('Fallout4.esm');
    slGameFiles.Add('Fallout4.exe');
    slGameFiles.Add('DLCCoast.esm');
    slGameFiles.Add('DLCNukaWorld.esm');
    slGameFiles.Add('DLCRobot.esm');
    slGameFiles.Add('DLCWorkshop01.esm');
    slGameFiles.Add('DLCWorkshop02.esm');
    slGameFiles.Add('DLCWorkshop03.esm');
	
    // Ignore missing files in Skyrim's own Nifs
    slFalsePositives := TStringList.Create;
    // slFalsePositives.Add('actors\character\female\FemaleBody_1_sk.dds');
    // slFalsePositives.Add('actors\character\female\femalebody_0_msn.dds');
    // slFalsePositives.Add('actors\character\female\femalebody_1.dds');
    // slFalsePositives.Add('actors\character\female\femalebody_1_msn.dds');
    // slFalsePositives.Add('actors\character\female\femalebody_1_s.dds');
    // slFalsePositives.Add('actors\character\female\femalehands_1.dds');
    // slFalsePositives.Add('actors\character\female\femalehands_1_msn.dds');
    // slFalsePositives.Add('actors\character\female\femalehands_1_s.dds');
    // slFalsePositives.Add('actors\character\female\femalehands_1_sk.dds');
    // slFalsePositives.Add('armor\dragonbone\armor_b.dds');
    // slFalsePositives.Add('armor\dragonbone\dragonbonearmorf.dds');
    // slFalsePositives.Add('armor\dragonbone\dragonbonearmorf_n.dds');
    // slFalsePositives.Add('armor\imperial\m\GauntletsLight.dds');
    // slFalsePositives.Add('armor\imperial\m\GauntletsLight_n.dds');
    // slFalsePositives.Add('dlc01\build\pc\data\textures\dlc01\armor\dawnguard\DG_cubemap.dds');
    // slFalsePositives.Add('dlc01\build\pc\data\textures\dlc01\armor\dawnguard\DawnguardBody1_d.dds');
    // slFalsePositives.Add('dlc01\build\pc\data\textures\dlc01\armor\dawnguard\DawnguardBody1_n.dds');
    // slFalsePositives.Add('dlc01\build\pc\data\textures\dlc01\armor\dawnguard\DawnguardBody_m.dds');
    // slFalsePositives.Add('textures\actors\character\female\femalebody_0_msn.dds');
    // slFalsePositives.Add('textures\dlc01\armor\falmer\FalmerHeavyHelmet_m.dds');
end;

//=============================================================
// Add a file to the output
// path = relative filepath of external file
// parentRecord = name of record in the plugin containing the reference
// parentNif = filepath of nif contining the reference
// reportError = whether or not to report an error
function RecordFile(path: string; parentRecord: IwbMainRecord; parentNif: string; reportError: boolean): boolean;
var exists: boolean;
    refc: integer;
begin
    if (path = Null) or (Length(path) = 0) then exit;
    // AddMessage('RecordFile ' + path);
    
    exists := FileExists(DataPath + path);
    if not exists 
        and (slResources.IndexOf(path) < 0) 
        and (slFalsePositives.IndexOf(path) < 0) 
        and reportError 
    then begin
        refc := ReferencedByCount(parentRecord);
        if (refc > 0) or showUnused then begin
            if Length(parentNif) > 0 then
                AddMessage(Format('ERR: Missing file (%d) || %s || %s || %s', [refc, Name(parentRecord), parentNif, path]))
            else
                AddMessage(Format('ERR: Missing file (%d) || %s || %s', [refc, Name(parentRecord), path]));
        end;
    end
    else
        // Only put in resources list if file exists; means every reference to missing file will be reported
        slResources.Add(path);
    result := exists;
end;

procedure AddNifReferences(elem: IwbElement; nifpath: string);
var 
    fullNifPath: string;
    nif: TwbNifFile;
    b: TwbNifBlock;
    el: TdfElement;
    i, j: integer;
    thisTexture: string;
begin
    LogEntry1(5, 'AddNifReferences', nifpath);
    nif := TwbNifFile.Create;
    fullNifPath := DataPath + 'meshes\' + nifpath;
    
    { try }
        if slNifs.IndexOf(fullNifPath) < 0 then begin
            slNifs.Add(fullNifPath);
            nif.LoadFromFile(fullNifPath);
       
            for i := 0 to Pred(nif.BlocksCount) do begin
                b := nif.Blocks[i];
                
                if b.BlockType = 'BSShaderTextureSet' then begin
                    // NOPE texture paths in the nif don't matter for FO4.
                    // el := b.Elements['Textures'];
                    // for j := 0 to Pred(el.Count) do begin
                    //     thisTexture := TdfElement(el[j]).EditValue;
                    //     if length(thisTexture) > 0 then begin
                    //         if not StartsText('textures', thisTexture) then
                    //             thisTexture := 'textures\' + thisTexture;
                    //         RecordFile(thisTexture, Name(ContainingMainRecord(elem)), nifpath, true);
                    //     end;
                    // end;
                end
                else if (b.BlockType = 'BSLightingShaderProperty') then begin
                    if (b.Elements['Name'].EditValue <> '') then begin
                        Log(6, 'Checking materials file ' + b.Elements['Name'].EditValue);
                        RecordFile(b.Elements['Name'].EditValue, 
                            ContainingMainRecord(elem), 
                            nifpath, 
                            true);
                    end;
                end;
            end;
        end;
    { except }
        { on E: Exception do  }
            { AddMessage('ERR: Could not open NIF file ' + fullNifPath + ' in ' + currentName + ' message ' + E.Message); }
    { end; }
    
    nif.Free;
    
    { if NifTextureList(nif, textureList) then  }
        { for i := 0 to Pred(textureList.Count) do }
            { slResources.Add(textureList[i]); }
    { else }
        { AddMessage('ERR: Error accessing textures in ' + fullNifPath);     }
    LogExit(5, 'AddNifReferences');
end;

function Process(e: IInterface): integer;
var
  s, s1, s0, strExt: string;
  i, j: integer;
  processThis: boolean;
  e1, e2: IwbElement;
  fn: string;
begin
    LogEntry1(5, 'Process', PathName(e));
    Result := 0;

    if length(outpath) = 0 then begin
        s := DataPath + GetFileName(GetFile(e));
        s1 := copy(s, 1, Length(s)-4);
        outpath := s1 + '-assets.txt';
        AddMessage('Writing to ' + outpath);
    end;

    // Only process if not already processed or hasn't got a name
    processThis := true;
    
    // If element is in one of the base game files ignore it
	fn := GetFileName(GetFile(e));
	// // AddMessage(' . . Element [' + GetElementEditValues(e, 'EDID') + '] in file ' + fn);
    if slGameFiles.IndexOf(fn) >= 0 then begin
        // // AddMessage(' . ' + GetElementEditValues(e, 'EDID') + ' form in base game');
        processThis := false;
    end;
	if Length(fn) = 0 then processThis := false;
    
    s := GetElementEditValues(e, 'EDID');
    if processThis and (Length(s) > 0) then begin
        if slProcessed.IndexOf(s) < 0 then begin
            currentName := s;
            slProcessed.Add(s);
        end
        else begin
            processThis := false;
        end;
    end
    else
        if processThis and (FormID(e) <> 0) then begin
            // // AddMessage(' . [' + IntToStr(recursionLevel) + '] Process ' + IntToHex(FormID(e), 8));
        end;

    if processThis then begin
        // only string fields can contain filenames
        i := DefType(e);
        if (i = dtString) or (i = dtLenString) then begin
            s := GetEditValue(e);
            strExt := LowerCase(RightStr(s, 4));
        
            if SameText(strExt, '.dds') or SameText(strExt, '.png') then begin
                RecordFile('textures\' + s, ContainingMainRecord(e), '', true);
            end
            
            else if SameText(strExt, '.tri') then
                RecordFile('meshes\'+s, ContainingMainRecord(e), '', true) 
                
            else if SameText(strExt, '.nif') then begin
                if RecordFile('meshes\'+s, ContainingMainRecord(e), '', true) then // Only add textures if file exists
                    AddNifReferences(e, s);
                if SameText(LowerCase(RightStr(s, 6)), '_1.nif') then begin
					s0 := LeftStr(s, Length(s)-6) + '_0.nif';
                    if RecordFile('meshes\' + s0, ContainingMainRecord(e), '', false) then
						AddNifReferences(e, s0);
				end;
            end; 
        end;
        
        // recursively process all child elements
        recursionLevel := recursionLevel + 1;
        for i := 0 to Pred(ElementCount(e)) do begin
            // // AddMessage(' . . walking child list element [' + IntToStr(recursionLevel) + ', ' + IntToStr(i) + ']');
            e1 := ElementByIndex(e, i);
            Process(e1);
            
            // Might be a list
            if ElementCount(e1) > 0 then begin
                for j := 0 to Pred(ElementCount(e1)) do begin
                    e2 := WinningOverride(LinksTo(ElementByIndex(e1, j)));
                    if (slGameFiles.IndexOf(GetFileName(GetFile(e2))) < 0) and (FormID(e2) <> FormID(e)) then begin
                        Process(e2);
                    end;
                end;
            end;
        end;
        recursionLevel := recursionLevel - 1;
    end;
    LogExit(5, 'Process');
end;

function Finalize: integer;
begin
  AddMessage('Writing to ' + outpath);
  slResources.SaveToFile(outpath);
  slResources.Free;
  slNifs.Free;
  slProcessed.Free;
  slFalsePositives.Free;
  slGameFiles.Free;
  AddMessage('------ List Used Assets ------');
end;

end.
