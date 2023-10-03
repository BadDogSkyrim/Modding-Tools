unit Filter_Unused;
interface
implementation
uses xEditAPI, Classes, SysUtils, StrUtils, Windows;

function Filter(e: IInterface): Boolean;
begin
    // AddMessage(Format('Element %s : %d', [Name(e), ReferencedByCount(e)]));
    Result := (ReferencedByCount(e) = 0);
end;

Function Process(entity: IwbMainRecord): integer;
begin
    if ReferencedByCount(entity) = 0 then AddMessage(Name(entity));
end;
end.
