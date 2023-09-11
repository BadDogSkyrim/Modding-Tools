{
  Output external assets (meshes and textures) used in selected records
  List is sorted without dups.
}
unit UserScript;

var
  slResources, slNifs, slElements, slFalsePositives, slGameFiles: TStringList;
  currentName: string;
  outpath: string;
  recursionLevel: integer; 

function Initialize: integer;
begin
    AddMessage('+++++++ List Used Assets ++++++');

    slResources := TStringList.Create;
    slResources.Sorted := True;
    slResources.Duplicates := dupIgnore;

    slNifs := TStringList.Create;
    slNifs.Duplicates := dupIgnore;
    
    slElements := TStringList.Create;
    
    currentName := '';
    outpath := '';
    
    recursionLevel := 0;
    
    slGameFiles := TStringList.Create;
    slGameFiles.Add('Skyrim.esm');
    slGameFiles.Add('Hearthfires.esm');
    slGameFiles.Add('Dragonborn.esm');
    slGameFiles.Add('Dawnguard.esm');
    slGameFiles.Add('Update.esm');
    slGameFiles.Add('Unofficial Skyrim Legendary Edition Patch.esp');
	slGameFiles.Add('Alternate Start - Live Another Life.esp');
	
    // Ignore missing files in Skyrim's own Nifs
    slFalsePositives := TStringList.Create;
    slFalsePositives.Add('actors\character\female\FemaleBody_1_sk.dds');
    slFalsePositives.Add('actors\character\female\femalebody_0_msn.dds');
    slFalsePositives.Add('actors\character\female\femalebody_1.dds');
    slFalsePositives.Add('actors\character\female\femalebody_1_msn.dds');
    slFalsePositives.Add('actors\character\female\femalebody_1_s.dds');
    slFalsePositives.Add('actors\character\female\femalehands_1.dds');
    slFalsePositives.Add('actors\character\female\femalehands_1_msn.dds');
    slFalsePositives.Add('actors\character\female\femalehands_1_s.dds');
    slFalsePositives.Add('actors\character\female\femalehands_1_sk.dds');
    slFalsePositives.Add('armor\dragonbone\armor_b.dds');
    slFalsePositives.Add('armor\dragonbone\dragonbonearmorf.dds');
    slFalsePositives.Add('armor\dragonbone\dragonbonearmorf_n.dds');
    slFalsePositives.Add('armor\imperial\m\GauntletsLight.dds');
    slFalsePositives.Add('armor\imperial\m\GauntletsLight_n.dds');
    slFalsePositives.Add('dlc01\build\pc\data\textures\dlc01\armor\dawnguard\DG_cubemap.dds');
    slFalsePositives.Add('dlc01\build\pc\data\textures\dlc01\armor\dawnguard\DawnguardBody1_d.dds');
    slFalsePositives.Add('dlc01\build\pc\data\textures\dlc01\armor\dawnguard\DawnguardBody1_n.dds');
    slFalsePositives.Add('dlc01\build\pc\data\textures\dlc01\armor\dawnguard\DawnguardBody_m.dds');
    slFalsePositives.Add('textures\actors\character\female\femalebody_0_msn.dds');
    slFalsePositives.Add('textures\dlc01\armor\falmer\FalmerHeavyHelmet_m.dds');
end;

function RecordFile(path: string; parentRecord: string; parentNif: string; reportError: boolean): boolean;
var exists: boolean;
begin
    if (path = Null) or (Length(path) = 0) then exit;
    // AddMessage('RecordFile ' + path);
    
    exists := FileExists(DataPath + path);
    if not exists and (slResources.IndexOf(path) < 0) and (slFalsePositives.IndexOf(path) < 0) and reportError then begin
        if Length(parentNif) > 0 then
            AddMessage('ERR: Missing file [[ ' + path + ' ]] in nif [[ ' + parentNif + ' ]] in record [[ ' + currentName + ' ]]')
        else
            AddMessage('ERR: Missing file [[ ' + path + ' ]] in record [[ ' + currentName + ' ]]')
    end
    else
        // Only put in resources list if file exists; means every reference to missing file will be reported
        slResources.Add(path);
    result := exists;
end;

procedure AddNifTextures(nifpath: string);
var 
    fullNifPath: string;
    nif: TwbNifFile;
    b: TwbNifBlock;
    el: TdfElement;
    i, j: integer;
    thisTexture: TdfElement;
begin
    nif := TwbNifFile.Create;
    fullNifPath := DataPath + 'meshes\' + nifpath;
    
    { try }
        if slNifs.IndexOf(fullNifPath) < 0 then begin
            slNifs.Add(fullNifPath);
            nif.LoadFromFile(fullNifPath);
            // AddMessage(' . Opened Nif ' + fullNifPath);
       
            for i := 0 to Pred(nif.BlocksCount) do begin
                b := nif.Blocks[i];
                
                if b.BlockType = 'BSShaderTextureSet' then begin
                    // AddMessage(' . . Found BSShaderTextureSet');
                    el := b.Elements['Textures'];
                    for j := 0 to Pred(el.Count) do begin
                        thisTexture := TdfElement(el[j]);
                        // AddMessage(' . . Found texture: ' + thisTexture.EditValue) ;
                        RecordFile(thisTexture.EditValue, currentName, nifpath, true);
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
end;

function Process(e: IInterface): integer;
var
  s, s1, s0, strExt: string;
  i, j: integer;
  processThis: boolean;
  e1, e2: IwbElement;
  fn: string;
begin
    Result := 0;

    if length(outpath) = 0 then begin
        s := DataPath + GetFileName(GetFile(e));
        s1 := copy(s, 1, Length(s)-4);
        outpath := s1 + '-assets.txt';
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
        
        if slElements.IndexOf(s) < 0 then begin
            // // AddMessage(' . [' + IntToStr(recursionLevel) + '] Process ' + IntToHex(FormID(e), 8) + ' ' + s);
            currentName := s;
            slElements.Add(s);
        end
        else begin
            // // AddMessage(' . ' + s + ' already processed');
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
                RecordFile('textures\' + s, currentName, '', true);
            end
            
            else if SameText(strExt, '.tri') then
                RecordFile('meshes\'+s, currentName, '', true) 
                
            else if SameText(strExt, '.nif') then begin
                if RecordFile('meshes\'+s, currentName, '', true) then // Only add textures if file exists
                    AddNifTextures(s);
                if SameText(LowerCase(RightStr(s, 6)), '_1.nif') then begin
					s0 := LeftStr(s, Length(s)-6) + '_0.nif';
                    if RecordFile('meshes\' + s0, currentName, '', false) then
						AddNifTextures(s0);
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
                    // // AddMessage(' . . Processing sublist ' + IntToStr(j) + ' ' + GetEditValue(ElementByIndex(e1,j)));
                    e2 := WinningOverride(LinksTo(ElementByIndex(e1, j)));
                    if (slGameFiles.IndexOf(GetFileName(GetFile(e2))) < 0) and (FormID(e2) <> FormID(e)) then begin
                        // // AddMessage(' . . Recursing on ' + GetElementEditValues(e2, 'EDID') + ' in file ' + GetFileName(GetFile(e2)));
                        Process(e2);
                    end;
                end;
            end;
        end;
        recursionLevel := recursionLevel - 1;
    end;
end;

function Finalize: integer;
begin
  AddMessage('Writing to ' + outpath);
  slResources.SaveToFile(outpath);
  slResources.Free;
  slNifs.Free;
  slElements.Free;
  slFalsePositives.Free;
  slGameFiles.Free;
  AddMessage('------ List Used Assets ------');
end;

end.
