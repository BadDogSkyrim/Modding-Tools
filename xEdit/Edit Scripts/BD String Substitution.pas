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
    oldString = 'BDNakedTiger';
    newString = 'YASTiger';
    targetPath = 'EDID';
    secondPath = '';
    doIt = TRUE;


//=========================================================================
// initialize stuff
function Initialize: integer;
begin
    AddMessage(#13#10);
    AddMessage('----------------------------------------------------------');
    AddMessage('--------------------BD String Substitution----------------');
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
    tp, tp2: IwbElement;
    i: integer;
begin
    tp := ElementByPath(e, targetPath);
    //AddMessage(Format('Processing %s count [%s]', [PathName(tp), IntToStr(ElementCount(tp))]));
    if ElementCount(tp) = 0 then begin
        t1 := GetEditValue(tp);
        i := Pos(oldString, t1);
        if i > 0 then begin
            t2 := ReplaceSubstring(t1, oldString, newString);
            AddMessage(t1 + '  ->  ' + t2);
            if doIt then SetElementEditValues(e, targetPath, t2);
        end;
    end
    else begin
        for i := 0 to ElementCount(tp) - 1 do begin
            tp2 := ElementByPath(ElementByIndex(tp, i), secondPath);
            //AddMessage(Format('Processing %s', [PathName(tp2)]));
            t1 := GetEditValue(tp2);
            if Pos(oldString, t1) > 0 then begin
                t2 := ReplaceSubstring(t1, oldString, newString);
                AddMessage(t1 + '  ->  ' + t2);
                if doIt then SetEditValue(tp2, t2);
            end;
        end;
    end;
end;

//=========================================================================
// finalize: where all the stuff happens
function Finalize: integer;
begin
end;

end.
