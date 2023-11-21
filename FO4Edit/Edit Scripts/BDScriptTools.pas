unit BDScriptTools;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    LOGGING = FALSE;

var 
    LOGLEVEL: integer;
    logIndent: integer;
    callIndex: intger;
    errCount: integer;
    warnCount: integer;
    curLogLevel: array [0..100] of integer;


Function BoolToStr(b: boolean): string;
begin
    if b then result := 'T' else result := 'F';
end;
    
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
    if LOGGING then LogEntry3(15, 'ElementListContains', EditorID(mr), p, v);
    Result := false;
    for i := 0 to HighInteger do begin
        e := ElementByIndex(ElementByPath(mr, p), i);
        if not Assigned(e) then break;
        if LOGGING then LogD('Found in list: ' + EditorID(LinksTo(e)));
        Result := SameText(EditorID(LinksTo(e)), v);
        if Result then break;
    end;
    if LOGGING then LogExitT1('ElementListContains', BoolToStr(Result));
end;


//=======================================================================
// Logging Tools.

Function LogToStr: string;
begin
    result := Format('callIndex=%d, logIndent=%d, curLogLevel=%d', [
        callIndex, logIndent, curLogLevel[callIndex]]);
end;

Procedure Log(importance: integer; txt: string);
var
    i: integer;
    s: string;
begin
    s := '';
    if LeftStr(txt, 1) = '>' then dec(callIndex);
    if LeftStr(txt, 1) = '<' then inc(callIndex);
	if importance <= LOGLEVEL then begin
        if LeftStr(txt, 1) = '>' then dec(logIndent);
        for i := 1 to logIndent do s := s + '|   ';
        if LeftStr(txt, 1) = '>' then
            s := s + '\' + RightStr(txt, length(txt)-1)
        else if LeftStr(txt, 1) = '<' then
            s := s + '/' + RightStr(txt, length(txt)-1)
        else 
            s := s + txt;

        AddMessage(s);
        if LeftStr(txt, 1) = '<' then inc(logIndent);
    end;
end;

//===========================================================
// Log a text string at the current importance level.
Procedure LogT(txt: string);
begin
    if (callIndex < 0) or (callIndex >= length(curLogLevel)) then 
        AddMessage('ERROR: callIndex = ' + IntToStr(callIndex))
    else 
        Log(curLogLevel[callIndex], txt);
end;

//===========================================================
// Log details about the current function (current importance + 5).
Procedure LogD(txt: string);
begin
    if (callIndex < 0) or (callIndex >= length(curLogLevel)) then 
        AddMessage('ERROR: callIndex = ' + IntToStr(callIndex))
    else 
        Log(curLogLevel[callIndex]+5, txt);
end;

Procedure LogEntry(importance: integer; routineName: string);
var
    i: integer;
    s: string;
begin
    inc(callIndex);
    s := '';
	if importance <= LOGLEVEL then begin
        for i := 1 to logIndent do s := s + '|   ';
        s := s + '/' + routineName;
        AddMessage(s);
        inc(logIndent);
    end;
    if callIndex < length(curLogLevel) then curLogLevel[callIndex] := importance;
end;

Procedure LogEntry1(importance: integer; routineName: string; details: string);
var
    i: integer;
    s: string;
begin
    inc(callIndex);
    s := '';
	if importance <= LOGLEVEL then begin
        for i := 1 to logIndent do s := s + '|   ';
        s := s + '/' + routineName + '(' + details + ')';
        AddMessage(s);
        inc(logIndent);
    end;
    if callIndex < length(curLogLevel) then curLogLevel[callIndex] := importance;
end;

Procedure LogEntry2(importance: integer; routineName: string; d1, d2: string);
begin
    LogEntry1(importance, routineName, d1 + ', ' + d2);
end;

Procedure LogEntry3(importance: integer; routineName: string; d1, d2, d3: string);
begin
    LogEntry1(importance, routineName, d1 + ', ' + d2 + ', ' + d3);
end;

Procedure LogEntry4(importance: integer; routineName: string; d1, d2, d3, d4: string);
begin
    LogEntry1(importance, routineName, d1 + ', ' + d2 + ', ' + d3 + ', ' + d4);
end;

Procedure LogExit(importance: integer; routineName: string);
var
    i: integer;
    s: string;
begin
    s := '';
	if importance <= LOGLEVEL then begin
        dec(logIndent);
        for i := 1 to logIndent do s := s + '|   ';
        s := s + '\' + routineName;
        AddMessage(s);
    end;
    dec(callIndex);
end;

Procedure LogExitT(routineName: string);
begin
    if (callIndex < 0) or (callIndex >= length(curLogLevel)) then
        AddMessage(Format('LOG ERROR: Call index %d out of range in routine %s', [callIndex, routineName]))
    else
        LogExit(curLogLevel[callIndex], routineName);
end;

Procedure LogExit1(importance: integer; routineName: string; details: string);
var
    i: integer;
    s: string;
begin
    s := '';
	if importance <= LOGLEVEL then begin
        dec(logIndent);
        for i := 1 to logIndent do s := s + '|   ';
        s := s + '\' + routineName + ' -> ' + details;
        AddMessage(s);
    end;
    dec(callIndex);
end;

Procedure LogExitT1(routineName: string; details: string);
begin
    LogExit1(curLogLevel[callIndex], routineName, details);
end;


procedure Err(txt: string);
begin
    AddMessage('ERROR: ' + txt);
    inc(errCount);
end;

procedure Warn(txt: string);
begin
    AddMessage('WARNING: ' + txt);
    inc(warnCount);
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
    LogEntry3(21, 'FindAsset', GetFileName(f), recordType, name);
    // Addmessage(format('Entered FindAsset: %s', [LogToStr]));
    Result := Nil;

    if not Assigned(f) then begin
        for i := 0 to FileCount-1 do begin
            r := MainRecordByEditorID(GroupBySignature(FileByIndex(i), recordType), name);
            if Assigned(r) then begin
                Result := r;
                LogT('Found in file index ' + IntToStr(i));
                break;
            end;
        end
    end
    else
        Result := MainRecordByEditorID(GroupBySignature(f, recordType), name);
    // addmessage(Format('Leaving FindAsset: %s', [LogToStr]));
    LogExitT1('FindAsset', EditorID(result));
    // addmessage(Format('After exiting FindAsset: %s', [LogToStr]));
end;

//=======================================================================
// Return the record referenced by the field of the element at the given index
Function RecordAtIndex(e: IwbElement; idx: integer; field: string): IwbElement;
begin
    if idx < ElementCount(e) then
        result := LinksTo(ElementByPath(ElementByIndex(e, idx), field))
    else
        result := nil;
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
	If LOGGING then Log(20, 'Hash(' + s + ', ' + IntToStr(j) + ', ' + IntToStr(m) + ') -> ' + IntToStr(h) + '/' + IntToStr(r));
    result := r;
End;

//=====================================================================
// Create a semi-random number in the given interval (min to max), 
// based on the hash string
Function HashVal(s: string; seed: uint64; minVal: single; maxVal: single): single;
begin
    result := Hash(s, seed, (maxVal-minVal)*100+1)/100 + minVal;
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