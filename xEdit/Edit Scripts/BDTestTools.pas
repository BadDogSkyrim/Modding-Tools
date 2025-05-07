{
    Tools to help with testing.
}
unit BDTestTools;

interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows;

var testErrorCount: integer;


procedure Assert(v: Boolean; msg: string);
begin
    if v then 
        AddMessage('OK: ' + msg)
    else
    begin
        // AddMessage('XXXXXX Error: ' + msg);
        testErrorCount := testErrorCount + 1;
        Raise Exception.Create('XXXXXX Assert fail: ' + msg);
    end;
end;


procedure AssertInt(actual, expected: integer; msg: string);
begin
    Assert(actual = expected, Format(msg + ': %d = %d', 
        [integer(actual), integer(expected)]));
end;


procedure AssertLT(actual, expected: integer; msg: string);
begin
    Assert(actual < expected, Format(msg + ': %d < %d', 
        [integer(actual), integer(expected)]));
end;


procedure AssertGT(actual, expected: integer; msg: string);
begin
    Assert(actual > expected, Format(msg + ': %d > %d', 
        [integer(actual), integer(expected)]));
end;


procedure AssertFloat(actual, expected: float; msg: string);
begin
    Assert(abs(actual - expected) < 0.01, 
        Format(msg + ': %s ~ %s', [FloatToStr(actual), FloatToStr(expected)]));
end;


procedure AssertStr(actual, expected: string; msg: string);
var matchStr: string;
begin
    if EndsText('*', expected) then begin
        matchStr := LeftStr(expected, length(expected)-1);
        Assert(StartsStr(matchStr, actual), Format(msg + ': "%s" ~ "%s"', [actual, expected]));
    end 
    else begin
        Assert(actual = expected, Format(msg + ': "%s" = "%s"', [actual, expected]));
    end;
end;


//=======================================================================
// Check to ensure the given IwbContainer contains the record referenced by editor ID.
// Also ensures all elements of the list are valid.
Procedure AssertInList(elist: IwbContainer; target: string);
var
    i: integer;
    ref: IwbMainRecord;
    found: boolean;
    npcref: IwbMainRecord;
begin
    found := false;
    for i := 0 to ElementCount(elist)-1 do begin
        npcref := ElementByIndex(elist, i);
        Assert(Assigned(npcref), Format('List element %s at [%d] assigned', 
            [FullPath(elist), i]));
        ref := LinksTo(npcref);
        Assert(Assigned(ref), Format('List element target %s at [%d] assigned', 
            [FullPath(elist), i]));
        if (target <> '') and (EditorID(ref) = target) then found := true;
    end;
    if target <> '' then
        Assert(found, Format('Found target element %s in %s', [target, FullPath(elist)]));
end;


{======================================================================= 
Check to ensure the given IwbContainer contains an entry containing an element with the
given name and value. 
} 
Procedure AssertInCompoundList(elist: IwbContainer; ename: string; target: string); var
    i: integer;
    ref: IwbMainRecord;
    found: boolean;
    listentry: IwbElement;
    namedentry: IwbElement;
begin
    found := false;
    for i := 0 to ElementCount(elist)-1 do begin
        listentry := ElementByIndex(elist, i);
        namedentry := ElementByPath(listentry, ename);
        Assert(Assigned(listentry), Format('List element at [%d] assigned', [i]));
        ref := LinksTo(namedentry);
        
        AddMessage(Format('Checking "%s" and "%s"', [GetEditValue(namedentry), EditorID(ref)]));
        if (target <> '') and ((GetEditValue(namedentry) = target) or (EditorID(ref) = target)) 
        then found := true;
        if found then break;
    end;
    if target <> '' then
        Assert(found, Format('Found target element %s in %s \ [*] %s', [target, FullPath(elist), ename]));
end;


{ =======================================================================
Check to ensure the given IwbContainer contains a record referenced with editor ID
containing the given string. Also ensures all elements of the list are valid.
}
Procedure AssertNameInList(elist: IwbContainer; target: string);
var
    i: integer;
    ref: IwbMainRecord;
    found: boolean;
    npcref: IwbMainRecord;
begin
    found := false;
    for i := 0 to ElementCount(elist)-1 do begin
        npcref := ElementByIndex(elist, i);
        ref := LinksTo(npcref);
        Assert(Assigned(ref), Format('List element at [%d] is assigned', [i]));
        AddMessage('AssertNameInList checking ' + EditorID(ref));
        found := found or ContainsText(EditorID(ref), target);
    end;
    Assert(found, Format('Found target element %s in %s', [target, FullPath(elist)]));
end;


//=======================================================================
// Check to ensure the given LL  contains the record referenced by editor ID.
// Also ensures all elements of the list are valid.
Procedure AssertNPCInLL(ll: IwbMainRecord; target: string);
var
    i: integer;
    elist: IwbContainer;
    ref: IwbMainRecord;
    found: boolean;
    npcref: IwbMainRecord;
begin
    found := false;
    elist := ElementByPath(ll, 'Leveled List Entries');
    for i := 0 to ElementCount(elist)-1 do begin
        npcref := LeveledListEntryRef(ElementByIndex(elist, i));
        Assert(Assigned(npcref), Format('List element at [%d] assigned', [i]));
        AddMessage(Format('Have reference %s', [FullPath(npcref)]));
        ref := LinksTo(npcref);
        AddMessage(Format('Comparing %s to %s', [RecordName(ref), target]));
        if (target <> '') and (EditorID(ref) = target) then found := true;
    end;
    if target <> '' then
        Assert(found, Format('Found target element %s in %s', [target, FullPath(elist)]));
end;


//=======================================================================
// Check to ensure the given IwbContainer does not contain the record referenced by editor ID.
// Also ensures all elements of the list are valid.
Procedure AssertNotInList(elist: IwbContainer; target: string);
var
    i: integer;
    ref: IwbMainRecord;
    found: boolean;
begin
    found := false;
    for i := 0 to ElementCount(elist)-1 do begin
        Assert(Assigned(ElementByIndex(elist, i)), Format('List element at [%d] assigned', [i]));
        ref := LinksTo(ElementByIndex(elist, i));
        if (target <> '') and (EditorID(ref) = target) then found := true;
    end;
    if target <> '' then
        Assert(not found, Format('Did not find target element %s in %s', [target, PathName(elist)]));
end;


//=======================================================================
// Check for errors in a NPC's headparts.
// If provided, must have a headpart of the given type and name.
Procedure AssertNoZeroTints(npc: IwbMainRecord);
var
    e: IwbElement;
    elist: IwbElement;
    i: integer;
    v: float;
begin
    elist := ElementByPath(npc, 'Face Tinting Layers');
    for i := 0 to ElementCount(elist)-1 do begin
        e := ElementByIndex(elist, i);
        v := GetNativeValue(ElementByPath(e, 'TEND\Value'));
        Assert(v > 0.0001, Format('Have non-zero alpha for [%s]: %s', [FullPath(e), FloatToStr(v)]));
    end;
end;


//=======================================================================
// Check for errors in a NPC's headparts.
// If provided, must have a headpart of the given type and name.
Procedure AssertGoodHeadparts(npc: IwbMainRecord; targetType: string; targetHeadpart: string);
var
    elist: IwbElement;
    headpart: IwbMainRecord;
    hp: IwbMainRecord;
    i: integer;
begin
    hp := Nil;
    elist := ElementByPath(npc, 'Head Parts');
    for i := 0 to ElementCount(elist)-1 do begin
        Assert(Assigned(ElementByIndex(elist, i)), Format('Headpart at [%d] assigned', [i]));
        headpart := LinksTo(ElementByIndex(elist, i));
        if targetType <> '' then begin
            if GetElementEditValues(headpart, 'PNAM') = targetType then
                hp := headpart;
        end;
    end;
    Assert(Assigned(hp), Format('Assert have %s as %s', [targetHeadpart, targetType]));
    if targetHeadpart <> '' then
        AssertStr(EditorID(hp), targetHeadpart, 'Have correct headpart for ' + targetType);
end;


//=======================================================================
// Check for errors in a NPC's morphs.
// If provided, must have a morph of the given name.
Procedure AssertMorph(npc: IwbMainRecord; targetMorph: integer);
var
    elist: IwbElement;
    val: integer;
    found: boolean;
    i: integer;
begin
    found := false;
    elist := ElementByPath(npc, 'MSDK');
    for i := 0 to ElementCount(elist)-1 do begin
        Assert(Assigned(ElementByIndex(elist, i)), Format('Morph at [%d] assigned', [i]));
        val := GetNativeValue(ElementByIndex(elist, i));
        if val = targetMorph then found := true;
    end;
    Assert(found, Format('Found target value %.8x', [targetMorph]));
    // Assert(Assigned(hp), Format('Assert have %s as %s', [targetHeadpart, targetType]));
    // if targetHeadpart <> '' then
    //     AssertStr(EditorID(hp), targetHeadpart, 'Have correct headpart for ' + targetType);
end;


// =========================================================================
// Check to make sure an NPC's QNAM alpha matches its skin tint alpha.
Procedure AssertCorrectAlpha(npc: IwbMainRecord);
var
    ftl: IwbElement;
    tintLayer: IwbElement;
    tintLayerAlpha: string;
    qnamAlpha: string;
    qnamAlphaVal: float;
begin
    ftl := ElementByPath(npc, 'Face Tinting Layers');
    tintLayer := ElementByIndex(ftl, 0); // Assume skin tint is first layer
    tintLayerAlpha := GetElementEditValues(tintLayer, 'TEND\Value');
    AddMessage('AssertCorrectAlpha found TEND\Value = ' + tintLayerAlpha);
    //AddMessage('AssertCorrectAlpha found TEND\Value edit value = ' + GetElementEditValues(tintLayer, 'TEND\Value'));
    qnamAlpha := GetElementEditValues(npc, 'QNAM - Texture lighting\Alpha');
    AddMessage('AssertCorrectAlpha found QNAM\Alpha = ' + qnamAlpha);
    if xEditVersionCompare(4, 1, 5, 'm') >= 0 then
        qnamAlphaVal := StrToFloat(qnamAlpha)/255
    else
        qnamAlphaVal := StrToFloat(qnamAlpha);
    AssertFloat(StrToFloat(tintLayerAlpha), qnamAlphaVal, 'Skin Tint Alpha == QNAM alpha');
end;


// =========================================================================
// Check for errors in a NPC's tint layers.
// If non-zero, targetLayerIndex must be in the list.
Procedure AssertGoodTintLayers(npc: IwbMainRecord; targetLayerIndex: integer);
var
    ftl: IwbElement;
    i: integer;
    ele: IwbElement;
    tetiIndex: integer;
    tetiStr: string;
    foundTarget: boolean;
begin
    ftl := ElementByPath(npc, 'Face Tinting Layers');
    foundTarget := (targetLayerIndex = 0);
    Assert(ElementCount(ftl) > 0, 'Have tints for ' + EditorID(npc));
    for i := 0 to ElementCount(ftl)-1 do begin
        ele := ElementByIndex(ftl, i);
        tetiIndex := GetElementNativeValues(ele, 'TETI\Index');
        tetiStr := GetElementEditValues(ele, 'TETI\Index');
        Assert(tetiIndex <> 0, Format('%s`s TETI Index [%d] (%s) not 0: %d', [EditorID(npc), i, tetiStr, tetiIndex]));
        foundTarget := foundTarget or (tetiIndex = targetLayerIndex);
    end;
    if targetLayerIndex <> 0 then 
        Assert(foundTarget, Format('Found target tint layer %d', [targetLayerIndex]));
end;


// =========================================================================
// Check for errors in a NPC's tint layers.
// One of tli1 or tli2 must be in the list.
Procedure AssertGoodTintLayers2(npc: IwbMainRecord; tli1, tli2: integer);
var
    ftl: IwbElement;
    i: integer;
    ele: IwbElement;
    tetiIndex: integer;
    tetiStr: string;
    foundTarget: boolean;
begin
    ftl := ElementByPath(npc, 'Face Tinting Layers');
    foundTarget := FALSE;
    Assert(ElementCount(ftl) > 0, 'Have tints for ' + EditorID(npc));
    for i := 0 to ElementCount(ftl)-1 do begin
        ele := ElementByIndex(ftl, i);
        tetiIndex := GetElementNativeValues(ele, 'TETI\Index');
        tetiStr := GetElementEditValues(ele, 'TETI\Index');
        Assert(tetiIndex <> 0, Format('%s`s TETI Index [%d] (%s) not 0: %d', [EditorID(npc), i, tetiStr, tetiIndex]));
        foundTarget := foundTarget or (tetiIndex = tli1) or (tetiIndex = tli2);
    end;
    Assert(foundTarget, Format('Found target tint layer %d or %d', [tli1, tli2]));
end;


// =========================================================================
// Check for errors in a NPC's tint layers.
// One of tli1 or tli2 or tli3 must be in the list.
Procedure AssertGoodTintLayers3(npc: IwbMainRecord; tli1, tli2, tli3: integer);
var
    ftl: IwbElement;
    i: integer;
    ele: IwbElement;
    tetiIndex: integer;
    tetiStr: string;
    foundTarget: boolean;
begin
    ftl := ElementByPath(npc, 'Face Tinting Layers');
    foundTarget := FALSE;
    Assert(ElementCount(ftl) > 0, 'Have tints for ' + EditorID(npc));
    for i := 0 to ElementCount(ftl)-1 do begin
        ele := ElementByIndex(ftl, i);
        tetiIndex := GetElementNativeValues(ele, 'TETI\Index');
        tetiStr := GetElementEditValues(ele, 'TETI\Index');
        Assert(tetiIndex <> 0, Format('%s`s TETI Index [%d] (%s) not 0: %d', [EditorID(npc), i, tetiStr, tetiIndex]));
        foundTarget := foundTarget or (tetiIndex = tli1) or (tetiIndex = tli2) or (tetiIndex = tli3);
    end;
    Assert(foundTarget, Format('Found target tint layer %d or %d or %d', [tli1, tli2, tli3]));
end;


// =========================================================================
// Check for errors in a NPC's tint layers.
// If non-zero, targetLayerIndex must NOT be in the list.
Procedure AssertGoodTintLayersNeg(npc: IwbMainRecord; targetLayerIndex: integer);
var
    ftl: IwbElement;
    i: integer;
    ele: IwbElement;
    tetiIndex: integer;
    tetiStr: string;
    foundTarget: boolean;
begin
    ftl := ElementByPath(npc, 'Face Tinting Layers');
    foundTarget := false;
    Assert(ElementCount(ftl) > 0, 'Have tints for ' + EditorID(npc));
    for i := 0 to ElementCount(ftl)-1 do begin
        ele := ElementByIndex(ftl, i);
        tetiIndex := GetElementNativeValues(ele, 'TETI\Index');
        tetiStr := GetElementEditValues(ele, 'TETI\Index');
        Assert(tetiIndex <> 0, Format('%s`s TETI Index [%d] (%s) not 0: %d', [EditorID(npc), i, tetiStr, tetiIndex]));
        if (targetLayerIndex <> 0) and (targetLayerIndex = tetiIndex) then foundTarget := true;
    end;
    if targetLayerIndex <> 0 then 
        Assert(not foundTarget, Format('Did not find target tint layer %d', [targetLayerIndex]));
end;

end.