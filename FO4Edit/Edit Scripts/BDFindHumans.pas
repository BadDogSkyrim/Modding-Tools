{
    Find all NPCs whose winning override is human.
}
unit BDFindHumans;

interface

implementation

uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

Function Finalize: integer;
var 
    i, j: integer;
    npclist: IwbElement;
    npc: IwbMainRecord;
    r: IwbMainRecord;
begin
    for i := 0 to FileCount-1 do begin
        AddMessage('Checking ' + GetFileName(FileByIndex(i)));
        npcList := GroupBySignature(FileByIndex(i), 'NPC_');
        for j := 0 to ElementCount(npcList)-1 do begin
            npc := ElementByIndex(npcList, j);
            if IsWinningOverride(npc) then begin
                r := LinksTo(ElementByPath(npc, 'RNAM'));
                if EditorID(r) = 'HumanRace' then AddMessage(FullPath(npc));
            end;
        end;
    end;

    result := 1;
end;
end.