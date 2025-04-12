{
  * DESCRIPTION *
  This script can be used to rename the EDID of items in bulk.
  For string replace, use "oldstring/newstring"

}

unit BD_Renamer;

interface
implementation
uses xEditAPI, Classes, StrUtils;

const
    oldString = 'BDLyk';
    newString = 'BDCan';
    targetPath = 'EDID';
    doIt = True;


//=========================================================================
// initialize stuff
function Initialize: integer;
begin
    AddMessage(#13#10);
    AddMessage('----------------------------------------------------------');
    AddMessage('------------------------BD Renamer------------------------');
    AddMessage('----------------------------------------------------------');
    AddMessage('');  
end;

function ReplaceSubstring(const Source, OldSub, NewSub: string): string;
var
    PosStart: integer;
begin
    Result := Source;
    PosStart := Pos(OldSub, Source);
    if PosStart > 0 then
        Result := Copy(Source, 1, PosStart - 1) + NewSub + Copy(Source, PosStart + Length(OldSub), MaxInt);
end;

//=========================================================================
// process selected records
function Process(e: IwbMainRecord): integer;
var t1, t2: string;
    i: integer;
begin
    t1 := GetElementEditValues(e, targetpath);
    i := Pos(oldString, t1);
    if i > 0 then begin
        t2 := ReplaceSubstring(t1, oldString, newString);
        AddMessage(t1 + '  ->  ' + t2);
        if doIt then SetElementEditValues(e, targetPath, t2);
    end;
end;

//=========================================================================
// finalize: where all the stuff happens
function Finalize: integer;
begin
end;

end.
