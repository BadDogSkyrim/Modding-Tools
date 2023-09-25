unit BDTraceNPCTraits;

interface
implementation

uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

Procedure ShowTemplate(npc: IwbMainRecord);
var
  entry: IwbElement;
  i: integer;
  llentries: IwbElement;
  tpl: IwbMainRecord;
begin
  Log(0, EditorID(npc));
  inc(logIndent);
  if Signature(npc) = 'NPC_' then begin
    if GetElementEditValues(npc, 
        'ACBS - Configuration\Use Template Actors\Traits') 
      = '1' then 
    begin
      tpl := LinksTo(ElementByPath(npc, 'TPTA\Traits'));
      ShowTemplate(tpl);
    end;
  end
  else if Signature(npc) = 'LVLN' then begin
    llentries := ElementByPath(npc, 'Leveled List Entries');
    for i := 0 to ElementCount(llentries)-1 do begin
      entry := ElementByIndex(llentries, i);
      tpl := LinksTo(ElementByPath(entry, 'LVLO\Reference'));
      ShowTemplate(tpl);
    end;
  end;
  dec(logIndent);
end;

Function Process(elem: IwbMainRecord): integer;
begin
    if EditorID(LinksTo(ElementByPath(elem, 'RNAM'))) = 'HumanRace' then
      if (Signature(elem) = 'NPC_') or (Signature(elem) = 'LVLN') then 
        ShowTemplate(elem);

end;

end.