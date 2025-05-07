{
  * DESCRIPTION *
  Identify missing assets.

}

unit BD_MissingAssets;

interface
implementation
uses xEditAPI, Classes, StrUtils, SysUtils;


var
    classList: TStringList;
    targetElem, targetElem2: TStringList;
    assetDirs: TStringList;
    missingAssets: TStringList;


procedure DefCheck(const e1, e2: string);
begin
    targetElem.Add(e1);
    targetElem2.Add(e2);
end;


procedure DefClass(const n: string);
begin
    classList.Add(n);
end;


//=========================================================================
// initialize stuff
function Initialize: integer;
begin
    AddMessage(#13#10);
    AddMessage('----------------------------------------------------------');
    AddMessage('---------------------Find Missing Assets------------------');
    AddMessage('----------------------------------------------------------');
    AddMessage('');  

    classList := TStringList.Create;
    targetElem := TStringList.Create;
    targetElem2 := TStringList.Create;
    assetDirs := TStringList.Create;
    missingAssets := TStringList.Create;
    missingAssets.Sorted := True;
    missingAssets.Duplicates := dupIgnore;

    DefCheck('Female 1st Person\MOD5', '');
    DefCheck('Female Biped Model\MOD3', '');
    DefCheck('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name');
    DefCheck('Head Data\Male Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name');
    DefCheck('Male 1st Person\MOD4', '');
    DefCheck('Male Biped Model\MOD2', '');
    DefCheck('Model\MODL - Model FileName', '');
    DefCheck('Parts', 'NAM1 - FileName');
    DefCheck('Textures (RGB/A)\TX00', '');
    DefCheck('Textures (RGB/A)\TX01', '');
    DefCheck('Textures (RGB/A)\TX02', '');
    DefCheck('Textures (RGB/A)\TX03', '');
    DefCheck('Textures (RGB/A)\TX04', '');
    DefCheck('Textures (RGB/A)\TX05', '');
    DefCheck('Textures (RGB/A)\TX06', '');
    DefCheck('Textures (RGB/A)\TX07', '');

    DefClass('ARMA');
    DefClass('ARMO');
    DefClass('HDPT');
    DefClass('TXST');

    assetDirs.Add('C:\Modding\SkyrimSEAssets\00 Vanilla Assets\');
end;


procedure CheckRef(e: IwbMainRecord; elem: IwbElement);
var d, n, t: string;
    i: integer;
    v: boolean;
begin
    t := GetEditValue(elem);
    // AddMessage(Format('EndsStr(".NIF", %s) = %s', [t, IfThen(EndsStr('.NIF', Uppercase(t)), 'True', 'False')]));
    d := IfThen(EndsStr('.DDS', Uppercase(t)), 'textures\', 'meshes\');
    n := DataPath + d + t;
    v := FileExists(n);
    if not v then begin
        for i := 0 to assetDirs.Count-1 do begin
            n := assetDirs[i] + d + t;
            v := FileExists(n);
            if v then break;
        end;
    end;
    if not v then missingAssets.Add(d + t + ' < ' + EditorID(e));
end;


//=========================================================================
// process selected records
function Process(e: IwbMainRecord): integer;
var t1, t2: string;
    tp, tp2: IwbElement;
    i, j: integer;
begin
    if classList.indexof(Signature(e)) >= 0 then begin
        for i := 0 to targetElem.Count-1 do begin
            tp := ElementByPath(e, targetElem[i]);
            if Assigned(tp) then begin
                if ElementCount(tp) = 0 then
                    CheckRef(e, tp)
                else begin
                    for j := 0 to ElementCount(tp)-1 do begin
                        tp2 := ElementByPath(ElementByIndex(tp, j), targetElem2[i]);
                        CheckRef(e, tp2);
                    end;
                end;
            end;
        end;
    end;
end;

//=========================================================================
// finalize: where all the stuff happens
function Finalize: integer;
var i: integer;
begin
    if missingAssets.Count = 0 then begin
        AddMessage('No missing assets.');
    end else begin
        AddMessage(Format('%d missing assets:', [missingAssets.Count]));
        AddMessage('----------------------------------------------------------');
        for i := 0 to missingAssets.Count-1 do begin
            AddMessage(missingAssets[i]);
        end;
    end;
    AddMessage('----------------------------------------------------------');
    
    classList.Free;
    targetElem.Free;
    targetElem2.Free;
    assetDirs.Free;
    missingAssets.Free;
end;
end.
