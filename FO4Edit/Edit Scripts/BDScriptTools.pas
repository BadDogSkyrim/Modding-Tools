unit BDScriptTools;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    LOGLEVEL = 1;

var 
    logIndent: integer;
    errCount: integer;
    
//================================================================
// Adds "masterFile" as a master to "aeFile", if not already there.
// Also adds any master files "masterFile" depends on.
function AddRecursiveMaster(aeFile, masterFile: IwbFile): Boolean;
var
	i : integer;
begin
    if GetLoadOrder(aeFile) = GetLoadOrder(masterFile) then
        Result := false
    else begin
        for i := 0 to Pred(MasterCount(masterFile)) do begin
            AddRecursiveMaster(aeFile,MasterByIndex(masterFile,i));
        end;
        AddMasterIfMissing(aeFile, GetFileName(masterFile));
        Result := true;
    end;
end;


//==========================================
// Get a FormID that can be used to retrieve a form across files.
Function RealFormID(e: IInterface): Cardinal;
begin
	result := FileFormIDtoLoadOrderFormID(GetFile(e), FixedFormID(e));
end;


//=======================================================================
// Assign the target element, which holds a reference to another
// main record, to the given record.
//
// Done this way to get around apparent problems with very
// large form IDs, such as ESLs have.
//
procedure AssignELementRef(theElement: IwbElement; theRef: IwbMainRecord);
var
    id: Cardinal;
    s: string;
begin
    AddRecursiveMaster(GetFile(theElement), GetFile(theRef));
    id := GetLoadOrderFormID(theRef);
    s := IntToHex(id shr 24, 2) + IntToHex((id and $ffffff),6);
    SetEditValue(theElement, s);
end;


//=======================================================================
// Assign a main record, given by editorID, to the given element.
//
// theElement = element to have its value assigned
// theFile = file to find the main record in
// sig = type of the main record
// val = editorID of the main record
//
procedure SetElementRefStr(theElement: IwbElement; theFile: IwbFile; sig: string; val: string);
begin
    SetElementRef(theElement, GetMainRecord(theFile, sig, val));
end;


//=======================================================================
// Determine whether an element list (e.g. list of keywords, list of races) 
// containts an element.
// mr = record containing the list
// p = path to the list
// v = editorID of the desired element in the list
function ElementListContains(mr: IwbMainRecord; p: string; v: string): boolean;
var
    i: integer;
    e: IwbElement;
begin
    Log(11, '<ElementListContains ' + EditorID(mr) + '/' + p + '=' + v);
    Result := false;
    for i := 0 to HighInteger do begin
        e := ElementByIndex(ElementByPath(mr, p), i);
        if not Assigned(e) then break;
        Log(11, 'Found in list: ' + EditorID(LinksTo(e)));
        Result := SameText(EditorID(LinksTo(e)), v);
        if Result then break;
    end;
    Log(11, '>ElementListContains: ' + IfThen(Result, 'T', 'F'));
end;


//=======================================================================
// Logging Tools.
Procedure Log(importance: integer; txt: string);
var
    i: integer;
    s: string;
begin
    s := '';
	if importance <= LOGLEVEL then begin
        if LeftStr(txt, 1) = '>' then dec(logIndent);
        for i := 1 to logIndent do s := s + '|   ';
        AddMessage(s + txt);
        if LeftStr(txt, 1) = '<' then inc(logIndent);
    end;
end;

procedure Err(txt: string);
begin
    AddMessage('ERROR: ' + txt);
    inc(errCount);
end;

procedure InitializeLogging;
begin
    logIndent := 0;
    errCount := 0;
end;

//=====================================================================
// Find and return the requested asset
// If f is Nil, search through all files for the asset.
// Returns Nil if asset not found.errCount
function FindAsset(f: IwbFile; recordType: string; name: string): IwbMainRecord;
var
    i: integer;
    r: IwbMainRecord;
begin
    Log(21, '<FindAsset: ' + GetFileName(f) + ', ' + recordType + ', ' + name);
    Result := Nil;

    if not Assigned(f) then begin
        for i := 0 to FileCount-1 do begin
            r := MainRecordByEditorID(GroupBySignature(FileByIndex(i), recordType), name);
            if Assigned(r) then begin
                Result := r;
                Log(21, 'Found in file index ' + IntToStr(i));
                break;
            end;
        end
    end
    else
        Result := MainRecordByEditorID(GroupBySignature(f, recordType), name);
    Log(21, '>FindAsset');
end;

//=======================================================================
// Get the last override (or base) *before* the given file
function GetPriorOverride(theElement: IwbMainRecord; fileIndex: integer): IwbMainRecord;
var
  i, n: Integer;
  base, e, thisOverride: IwbMainRecord;
begin
    base := MasterOrSelf(theElement);
    n := OverrideCount(base);
    thisOverride := base;

    for i := n-1 downto 0 do begin
        e := OverrideByIndex(base, i);
        if GetLoadOrder(GetFile(e)) < fileIndex then begin
            thisOverride := e;
            break;
        end;
    end;

    Result := thisOverride;
end;

//==================================================
// Hash given string with starting seed j and return result modulo m
// Seed can be anything. Providing different values from different calls means even if 
// two NPCs hash the same, not every aspect of them will be the same.
//
Function Hash(s: string; j: integer; m: integer): integer;
var i, r: integer;
	h: long;
	c: Char;
begin
    h := 0;
	for i := 1 to length(s) do begin
		c := Copy(s, i, 1);
		h := ((31 * h) + Ord(c)) mod 16000; 
	end;
	h := ((31 * h) + j) mod 16000; 
	if m = 0 then r := 0 else r := h mod m; 
	Log(20, 'Hash(' + s + ', ' + IntToStr(j) + ', ' + IntToStr(m) + ') -> ' + IntToStr(h) + '/' + IntToStr(r));
    result := r;
End;

//=====================================================================
// Create a semi-random number in the given interval (min to max-1), 
// based on the hash string
Function HashVal(s: string; seed: uint64; minVal: single; maxVal: single): single;
begin
    result := Hash(s, seed, (maxVal-minVal)*100)/100 + minVal;
end;

//=====================================================================
// Create a semi-random number in the given interval (min to max-1), 
// based on the hash string
Function HashInt(s: string; seed: uint64; minVal: integer; maxVal: integer): integer;
begin
    result := Hash(s, seed, maxVal-minVal) + minVal;
end;

//=================================================================
// Pick apart a color value
Function RedPart(rgbVal: UInt32): UInt32;
begin
    result := rgbVal and $FF;
end;

Function GreenPart(rgbVal: UInt32): UInt32;
begin
    result := (rgbVal shr 8) and $FF;
end;

Function BluePart(rgbVal: UInt32): UInt32;
begin
    result := (rgbVal shr 16) and $FF;
end;

Function AlphaPart(rgbVal: UInt32): single;
begin
    result := ((rgbVal shr 24) and $FF)/255.0;
end;



end.