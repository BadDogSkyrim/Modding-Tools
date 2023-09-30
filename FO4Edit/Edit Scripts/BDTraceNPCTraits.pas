{ 
  Walk traits templates backwards from NPCs to the template they are based on.
  Print the tree.
}
unit BDTraceNPCTraits;

interface
implementation

uses BDAssetLoaderFO4, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

Procedure ShowTemplate(npc: IwbMainRecord);
var
  entry: IwbElement;
  i: integer;
  llentries: IwbElement;
  tpl: IwbMainRecord;
begin
  if Signature(npc) = 'NPC_' then begin
    if GetElementEditValues(npc, 
        'ACBS - Configuration\Use Template Actors\Traits') 
      = '1' then 
    begin
      tpl := WinningOverride(LinksTo(ElementByPath(npc, 'TPTA\Traits')));
      if Assigned(tpl) then begin
        Log(0, Name(npc) + ' T');
      end
      else begin
        Log(0, Name(npc) + ' A');
        tpl := WinningOverride(LinksTo(ElementByPath(npc, 'TPLT'))); // default template
      end;
      inc(logIndent);
      ShowTemplate(tpl);
      dec(logIndent);
    end
    else
        log(0, Name(npc));
  end
  else if Signature(npc) = 'LVLN' then begin
    log(0, Name(npc));
    llentries := ElementByPath(npc, 'Leveled List Entries');
    for i := 0 to ElementCount(llentries)-1 do begin
      entry := ElementByIndex(llentries, i);
      tpl := WinningOverride(LinksTo(ElementByPath(entry, 'LVLO\Reference')));
      inc(logIndent);
      ShowTemplate(tpl);
      dec(logIndent);
    end;
  end;
end;

//====================================================
// Determines whether the NPC is only used as a template.
Function NPCisTemplate(npc: IwbMainRecord): boolean;
var 
  i: integer;
  referer: IwbMainRecord;
begin
  result := true;
  for i := 0 to ReferencedByCount(npc)-1 do begin
    referer := ReferencedByIndex(npc, i);
    if (Signature(referer) <> 'NPC_') and (Signature(referer) <> 'LVLN') then begin
      result := false;
      break;
    end;
  end;
end;

Function Initialize: integer;
begin
  LOGLEVEL := 0;
  InitializeAssetLoader;
end;

Function Process(npc: IwbMainRecord): integer;
begin
  if {tracing all inheritance} TRUE then begin
    if EditorID(LinksTo(ElementByPath(npc, 'RNAM'))) = 'HumanRace' then
      if (Signature(npc) = 'NPC_') or (Signature(npc) = 'LVLN') then 
        ShowTemplate(npc);
  end
  else begin
    if NPCisGeneric(npc) 
        and (not BasedOnLeveledList(npc)) 
        and (not NPCisTemplate(npc))
    then begin
      Err('Generic NPC not based on leveled list: ' + Name(npc));
    end;
  end;
end;

function Finalize: integer;
begin
  ShutdownAssetLoader;
end;

end.