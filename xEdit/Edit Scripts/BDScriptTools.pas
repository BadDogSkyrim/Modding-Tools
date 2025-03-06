unit BDScriptTools;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    LBL_MSPACE = 10;
    LBL_GAP = 10;
    LBL_VSPACE = 5;
    LBL_ADJ = 3;
    alphabet = 'abcdefghijklmnopqrstuvwxyz';
var 
    LOGGING: boolean;
    LOGLEVEL: integer;
    logIndent: integer;
    callIndex: intger;
    errCount: integer;
    warnCount: integer;
    curLogLevel: array [0..100] of integer;
    xEditMajor, xEditMinor, xEditUpdate: integer;
    xEditUpdate2: string;
    xEditVersionStr: string;

    // Context variables for building forms
    formPosLeft, formPosTop: integer;
    bdstForm: TForm;
    formParent: TForm;


Function GetXEditVersion(): string;
var v: string;
begin
    v := IntToHex(wbVersionNumber, 8);
    xEditMajor := StrToInt(MidStr(v, 1, 2));
    xEditMinor := StrToInt(MidStr(v, 3, 2));
    xEditUpdate := StrToInt(MidStr(v, 5, 2));
    xEditUpdate2 := MidStr(alphabet, IntToStr(wbVersionNumber and $FF), 1);
    xEditVersionStr := IntToStr(xEditMajor) + '.' + IntToStr(xEditMinor) + '.' 
        + IntToStr(xEditUpdate) + '.' + xEditUpdate2;
    result := xEditVersionStr;
end;


{================================================================
Compare the given version number with xEdit's. Return <0 if it's less,
0 if it's equal, >0 if it's greater. 
}
Function XEditVersionCompare(majv, minv, updv: integer; upd2v: string): integer;
begin
    if majv <> xEditMajor then result := majv - xEditMajor
    else if minv <> xEditMinor then result := minv - xEditMinor
    else if updv <> xEditUpdate then result := updv - xEditUpdate
    else if upd2v < xEditUpdate2 then result := -1
    else if upd2v > xEditUpdate2 then result := 1
    else result := 0;
end;


Function BoolToStr(b: boolean): string;
begin
    if b then result := 'T' else result := 'F';
end;

Function RecordName(r: IwbMainRecord): string;
begin
    if Assigned(r) then
        result := Name(r)
    else
        result := 'NONE';
end;


//================================================================
// Find a file in the current load order by name. Return the file index.
function FindFile(fn: string): integer;
var i: integer;
begin
    result := -1;
    for i := 0 to FileCount-1 do begin
        if SameText(GetFileName(FileByIndex(i)), fn) then begin
            result := i;
            break;
        end;
    end;
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


//==========================================
// Return an entry in a leveled list. Check paths for both older and new versions 
// of xEdit.
Function LeveledListEntryRef(e: IwbElement): IwbElement;
begin
    result := ElementByPath(e, 'LVLO\NPC');
    if not Assigned(result) 
    then result := ElementByPath(e, 'LVLO\Reference');
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
    curLogLevel[callIndex] := 0;
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
    exit;
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
    callIndex := 0;
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
// Determine whether a record has no override and is the effective record in the load order.
function HasNoOverride(theElement: IwbMainRecord): Boolean;
begin
    if IsWinningOverride(theElement) 
    then result := True
    else if GetLoadOrder(GetFile(WinningOverride(theElement))) = GetLoadOrder(GetFile(theElement)) 
    then result := True
    else result := False;
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


//=======================================================================
// Make an override of the given record.
function MakeOverride(theElement: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
begin
    AddRecursiveMaster(targetFile, GetFile(theElement));
    result := wbCopyElementToFile(theElement, targetFile, False, True);
end;


//==================================================
// Hash given string with starting seed seed and return result modulo m
// Seed can be anything. Providing different values from different calls means even if 
// two NPCs hash the same, not every aspect of them will be the same.
//
Function Hash(s: string; seed: integer; m: integer): integer;
var i, r: integer;
	h: long;
	c: Char;
begin
    h := seed;
    // h := 0;
	for i := 1 to length(s) do begin
		c := Copy(s, i, 1);
		h := ((31 * h) + Ord(c)) mod 16000; 
	end;
	h := (31 * h) mod 16000; 
	// h := ((31 * h) + seed) mod 16000; 
	if m = 0 then r := 0 else r := h mod m; 
	If LOGGING then Log(20, 'Hash(' + s + ', ' + IntToStr(seed) + ', ' + IntToStr(m) + ') -> ' + IntToStr(h) + '/' + IntToStr(r));
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

//=========================================================
// Create a form button
function FormButton(f: TForm; parent: TForm; lab: String; res: Cardinal; left, top: integer):
    TButton;
var
    b: TButton;
begin
    b := TButton.Create(f);
    b.parent := parent;
    b.caption := lab;
    b.ModalResult := res;
    b.Left := left;
    b.top := top;
    Result := b;
end;

//=========================================================
// Create a form label
function FormLabel(f: TForm; parent: TForm; caption: String; left, top, width: integer):
    TLabel;
var
    lbl: TLabel;
begin
    lbl := TLabel.Create(f);
    lbl.parent := parent;
    lbl.caption := caption;
    lbl.Left := left;
    lbl.top := top;
    if width > 0 then lbl.width := width;
    Result := lbl;
end;

//=========================================================
// Create a form check box
function FormCheckBox(f: TForm; parent: TForm; caption: String; left, top, width: integer):
    TCheckBox;
var
    cb: TCheckBox;
begin
    cb := TCheckBox.Create(f);
    cb.parent := parent;
    cb.caption := caption;
    cb.width := 100;
    cb.Left := left;
    cb.top := top;
    if width > 0 then cb.width := width;
    Result := cb;
end;

//=========================================================
// Create a form check box
function FormComboBox(f: TForm; parent: TForm; options: String; left, top, width: integer):
    TComboBox;
var
    cb: TComboBox;
begin
    cb := TComboBox.Create(f);
    cb.Parent := parent;
    cb.Left := left;
    cb.Top := top;
    cb.Width := width;
    cb.Style := csDropDownList;
    cb.Items.Text := options;
    cb.ItemIndex := 0;
    result := cb;
end;

//=========================================================
// Create a form panel
function FormPanel(f: TForm; parent: TForm; bevelOuter: Cardinal; alignment: Cardinal; height: integer):
    TPanel;
var
    p: TPanel;
begin
    p := TPanel.Create(f);
    p.parent := parent;
    p.BevelOuter := bevelOuter;
    p.align := alignment;
    p.height := height;
    Result := p
end;

//=========================================================
// Create a form edit text box
function FormEdit(f: TForm; parent: TForm; left, top, width: integer):
    TEdit;
var
    ed: TEdit;
begin
    ed := TEdit.Create(f);
    ed.parent := parent;
    ed.left := left;
    ed.top := top;
    ed.width := width;
    result := ed;
end;

//=========================================================
// Create a form and initialize context for form creation.
function MakeForm(caption: string; width, height: integer): TForm;
var
    f: TForm;
begin
    f := TForm.Create(nil);
    f.caption := caption;
    f.width := width;
    f.height := height;
    f.position := poScreenCenter;
    f.borderStyle := bsDialog;
    formPosLeft := 5;
    formPosTop := 5;
    bdstForm := f;
    formParent := f;
    result := f;
end;

function MakeFormEdit(caption: string; defaultvalue: string): TEdit;
var
    lbl: TLabel;
    ed: TEdit;
    l: integer;
begin
    lbl := TLabel.Create(bdstForm);
    lbl.parent := formParent;
    lbl.caption := caption;
    lbl.Left := formPosLeft;
    lbl.top := formPosTop+LBL_ADJ;

    ed := TEdit.Create(bdstForm);
    ed.parent := formParent;
    ed.top := formPosTop;
    l := lbl.left + lbl.width + LBL_MSPACE;
    ed.left := l;
    ed.width := formParent.width-l-LBL_MSPACE*2;
    ed.text := defaultvalue;

    formPosTop := formPosTop + ed.height + LBL_VSPACE;
    result := ed;
end;

//=========================================================
// Create a form check box
function MakeFormCheckBox(caption: String; defaultvalue: boolean): TCheckBox;
var
    cb: TCheckBox;
begin
    cb := TCheckBox.Create(bdstForm);
    cb.parent := formParent;
    cb.caption := caption;
    cb.top := formPosTop;
    cb.Left := formPosLeft;
    cb.width := formParent.width - formPosLeft - LBL_MSPACE*2;
    cb.checked := defaultvalue;

    formPosTop := formPosTop + cb.height + LBL_VSPACE;
    Result := cb;
end;

//=========================================================
// Create a form label
procedure MakeFormSectionLabel(caption: String);
var
    lbl: TLabel;
begin
    lbl := TLabel.Create(bdstForm);
    lbl.parent := formParent;
    lbl.caption := '= ' + caption + ' =';
    lbl.top := formPosTop + LBL_GAP;
    lbl.Left := formPosLeft;
    lbl.width := formParent.width - formPosLeft - LBL_MSPACE*2;
    formPosTop := lbl.top + lbl.height + LBL_GAP;
end;

//=========================================================
// Create a form combo box
function MakeFormComboBox(caption: string; options: String; defaultvalue: integer):
    TComboBox;
var
    lbl: TLabel;
    cb: TComboBox;
    y: integer;
begin
    lbl := TLabel.Create(bdstForm);
    lbl.parent := formParent;
    lbl.caption := caption;
    lbl.Left := formPosLeft;
    lbl.top := formPosTop+LBL_ADJ;

    cb := TComboBox.Create(bdstForm);
    cb.Parent := formParent;
    cb.Top := formPosTop;
    y := formPosLeft + lbl.width + LBL_MSPACE;
    cb.Left := y;
    cb.Width := formParent.width - y - LBL_MSPACE*2;
    cb.Style := csDropDownList;
    cb.items.text := options;
    cb.ItemIndex := defaultvalue;

    formPosTop := cb.top + cb.height + LBL_VSPACE;
    result := cb;
end;

//=========================================================
// Create a form button
procedure MakeFormOKCancel;
var
    b, c: TButton;
begin
    b := TButton.Create(bdstForm);
    b.parent := formParent;
    b.caption := 'OK';
    b.ModalResult := mrOK;
    b.top := formPosTop + LBL_GAP * 2;
    b.left := formParent.width/2 - b.width - LBL_MSPACE;
    
    c := TButton.Create(bdstForm);
    c.parent := formParent;
    c.caption := 'Cancel';
    c.ModalResult := mrCancel;
    c.top := b.top;
    c.left := formParent.width/2 + LBL_MSPACE;
    
    formParent.height := b.top + 80;
end;

end.