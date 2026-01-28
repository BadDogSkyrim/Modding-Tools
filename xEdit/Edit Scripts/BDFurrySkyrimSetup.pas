{
    Definitions of vanilla forms.
}
unit BDFurrySkyrimSetup;

interface
implementation
uses BDFurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;


procedure SetupVanilla;
begin
    DefineLabelConflicts;
    DefineScars;
    VanillaSettings;
    SetNPCAliases;
end;


procedure VanillaSettings;
begin

    begin // Descriptions of vanilla hair styles
        // Elder
        LabelHeadpartList('HairMaleElder1', 'SHORT,NEAT,BALDING,MATURE,MILITARY');
        LabelHeadpartList('HairMaleElder2', 'SHORT,NEAT,BALDING,MATURE,MILITARY');
        LabelHeadpartList('HairMaleElder3', 'SHORT,NEAT,BALDING,MATURE,MILITARY');
        LabelHeadpartList('HairMaleElder4', 'SHORT,BALDING,MATURE');
        LabelHeadpartList('HairMaleElder5', 'SHORT,NEAT,BALDING,MATURE,MILITARY');
        LabelHeadpartList('HairMaleElder6', 'LONG,NEAT,BALDING,MATURE,TIEDBACK');

        // IMPERIAL
        LabelHeadpartList('HairMaleImperial1', 'SHORT,NEAT,MILITARY,IMPERIAL');
        LabelHeadpartList('HairFemaleImperial1', 'SHORT,NEAT,MILITARY,IMPERIAL');

        // NORD
        LabelHeadpartList('HairMaleNord01', 'LONG');
        LabelHeadpartList('HairMaleNord02', 'LONG,BRAIDS');
        LabelHeadpartList('HairMaleNord03', 'NOBLE,LONG,BRAIDS');
        LabelHeadpartList('HairMaleNord04', 'MESSY,LONG,BRAIDS');
        LabelHeadpartList('HairMaleNord05', 'NEAT,LONG,TIEDBACK');
        LabelHeadpartList('HairMaleNord06', 'BOLD,BRAIDS');
        LabelHeadpartList('HairMaleNord07', 'SHORT,NEAT');
        LabelHeadpartList('HairMaleNord08', 'FUNKY,BRAIDS,SHORT');
        LabelHeadpartList('HairMaleNord09', 'NEAT,SHORT,MILITARY');
        LabelHeadpartList('HairMaleNord10', 'NEAT,SHORT,BRAIDS');
        LabelHeadpartList('HairMaleNord11', 'NEAT,SHORT,TIEDBACK,BRAIDS');
        LabelHeadpartList('HairMaleNord12', 'NEAT,LONG,TIEDBACK');
        LabelHeadpartList('HairMaleNord13', 'LONG,BOLD,YOUNG,TIEDBACK');
        LabelHeadpartList('HairMaleNord14', 'SHORT,NEAT,MILITARY');
        LabelHeadpartList('HairMaleNord15', 'SHORT,MESSY');
        LabelHeadpartList('HairMaleNord16', 'MOHAWK,BRAIDS,BOLD,FUNKY');
        LabelHeadpartList('HairMaleNord17', 'MOHAWK,BOLD,BRAIDS,FUNKY');
        LabelHeadpartList('HairMaleNord18', 'LONG,MESSY');
        LabelHeadpartList('HairMaleNord19', 'LONG,MESSY,MATURE');
        LabelHeadpartList('HairMaleNord20', 'MOHAWK,LONG,BOLD,FUNKY');

        LabelHeadpartList('DLC1HairFemaleSerana', 'TIEDBACK,ELABORATE');
        LabelHeadpartList('DLC1HairFemaleSeranaHuman', 'TIEDBACK,ELABORATE');
        LabelHeadpartList('DLC1HairFemaleValerica', 'BUN,TIEDBACK,ELABORATE,MATURE');
        LabelHeadpartList('HairFemaleNord01', 'SHORT,MESSY');
        LabelHeadpartList('HairFemaleNord02', 'SHORT,BRAIDS');
        LabelHeadpartList('HairFemaleNord03', 'LONG,BRAIDS,TIEDBACK,BOLD');
        LabelHeadpartList('HairFemaleNord04', 'MESSY,BRAIDS');
        LabelHeadpartList('HairFemaleNord05', 'TIEDBACK,MESSY');
        LabelHeadpartList('HairFemaleNord06', 'BRAIDS');
        LabelHeadpartList('HairFemaleNord07', 'SHORT');
        LabelHeadpartList('HairFemaleNord08', 'SHORT,BRAIDS,FUNKY');
        LabelHeadpartList('HairFemaleNord09', 'TIEDBACK,BRAIDS');
        LabelHeadpartList('HairFemaleNord10', 'BRAIDS,TIEDBACK,ELABORATE');
        LabelHeadpartList('HairFemaleNord11', 'TIEDBACK,BRAIDS,YOUNG,TIEDBACK');
        LabelHeadpartList('HairFemaleNord13', 'SHORT,BRAIDS');
        LabelHeadpartList('HairFemaleNord14', 'LONG,TIEDBACK');
        LabelHeadpartList('HairFemaleNord15', 'SHORT,NEAT');
        LabelHeadpartList('HairFemaleNord16', 'MOHAWK,BRAIDS,BOLD,FUNKY');
        LabelHeadpartList('HairFemaleNord17', 'SHORT,TIEDBACK,BRAIDS,ELABORATE');
        LabelHeadpartList('HairFemaleNord18', 'LONG,MESSY');
        LabelHeadpartList('HairFemaleNord19', 'SHORT,TIEDBACK,BRAIDS');
        LabelHeadpartList('HairFemaleNord20', 'SHORT,TIEDBACK');
        LabelHeadpartList('HairFemaleNord21', 'DREADS,FUNKY,BOLD,MOHAWK');

        // ORC
        LabelHeadpartList('HairMaleOrc01', 'TIEDBACK,LONG');
        LabelHeadpartList('HairMaleOrc02', 'TIEDBACK,NEAT,SHORT');
        LabelHeadpartList('HairMaleOrc03', 'TIEDBACK,NEAT,SHORT');
        LabelHeadpartList('HairMaleOrc04', 'TIEDBACK,NEAT,SHORT');
        LabelHeadpartList('HairMaleOrc05', 'TIEDBACK,NEAT,LONG');
        LabelHeadpartList('HairMaleOrc06', 'TIEDBACK,NEAT,LONG,BRAIDS');
        LabelHeadpartList('HairMaleOrc07', 'TIEDBACK,NEAT,LONG');
        LabelHeadpartList('HairMaleOrc09', 'NEAT,MATURE,TIEDBACK');
        LabelHeadpartList('HairMaleOrc10', 'NEAT,MATURE,TIEDBACK');
        LabelHeadpartList('HairMaleOrc11', 'NEAT,MATURE,TIEDBACK');
        LabelHeadpartList('HairMaleOrc12', 'NEAT,MILITARY,TIEDBACK');
        LabelHeadpartList('HairMaleOrc13', 'NEAT,MILITARY,TIEDBACK');
        LabelHeadpartList('HairMaleOrc14', 'NEAT,MILITARY,TIEDBACK');
        LabelHeadpartList('HairMaleOrc15', 'MOHAWK,NEAT,MILITARY,TIEDBACK');
        LabelHeadpartList('HairMaleOrc16', 'MOHAWK,NEAT,MILITARY,TIEDBACK');
        LabelHeadpartList('HairMaleOrc17', 'MOHAWK,NEAT,MILITARY,TIEDBACK');
        LabelHeadpartList('HairMaleOrc18', 'SHORT,TIEDBACK,NEAT,MILITARY');
        LabelHeadpartList('HairMaleOrc19', 'SHORT,TIEDBACK,NEAT,MILITARY');
        LabelHeadpartList('HairMaleOrc20', 'SHORT,TIEDBACK,NEAT,MILITARY');
        LabelHeadpartList('HairMaleOrc21', 'SHORT,TIEDBACK,NEAT,MILITARY');
        LabelHeadpartList('HairMaleOrc22', 'SHORT,TIEDBACK,NEAT,MILITARY');
        LabelHeadpartList('HairMaleOrc23', 'SHORT,TIEDBACK,NEAT,MILITARY');
        LabelHeadpartList('HairMaleOrc24', 'SHORT,TIEDBACK,NEAT');
        LabelHeadpartList('HairMaleOrc25', 'BUZZ,NEAT,MILITARY');
        LabelHeadpartList('HairMaleOrc27', 'MOHAWK,FUNKY,BOLD');

        LabelHeadpartList('HairFemaleOrc01', 'SHORT,TIEDBACK,NEAT');
        LabelHeadpartList('HairFemaleOrc02', 'SHORT,TIEDBACK,NEAT');
        LabelHeadpartList('HairFemaleOrc03', 'SHORT,NEAT,TIEDBACK');
        LabelHeadpartList('HairFemaleOrc04', 'SHORT,NEAT,TIEDBACK');
        LabelHeadpartList('HairFemaleOrc05', 'BUN,MATURE,TIEDBACK,ELABORATE');
        LabelHeadpartList('HairFemaleOrc06', 'BUN,MATURE,TIEDBACK,ELABORATE');
        LabelHeadpartList('HairFemaleOrc07', 'BUN,BOLD,MATURE,TIEDBACK,ELABORATE');
        LabelHeadpartList('HairFemaleOrc08', 'BUN,BOLD,MATURE,TIEDBACK,ELABORATE');
        LabelHeadpartList('HairFemaleOrc09', 'BUZZ,NEAT,MILITARY,BOLD');
        LabelHeadpartList('HairFemaleOrc10', 'BUZZ,NEAT,FUNKY,BOLD');
        LabelHeadpartList('HairFemaleOrc11', 'BUZZ,NEAT,FUNKY,BOLD');
        LabelHeadpartList('HairFemaleOrc12', 'BUZZ,NEAT,FUNKY,BOLD');
        LabelHeadpartList('HairFemaleOrc13', 'BUZZ,NEAT,MILITARY,BOLD');
        LabelHeadpartList('HairFemaleOrc14', 'SHORT,BOLD,MOHAWK,TIEDBACK');
        LabelHeadpartList('HairFemaleOrc15', 'SHORT,BOLD,MOHAWK,TIEDBACK');
        LabelHeadpartList('HairFemaleOrc17', 'DREADS,FUNKY,BOLD,MOHAWK');

        // REDGUARD
        LabelHeadpartList('HairMaleRedguard8', 'DREADS,FUNKY,BOLD,MOHAWK');
        LabelHeadpartList('HairMaleRedguard1', 'BUZZ,NEAT,MILITARY');
        LabelHeadpartList('HairMaleRedguard2', 'BUZZ,NEAT,MILITARY');
        LabelHeadpartList('HairMaleRedguard3', 'SHORT,NEAT,MILITARY');
        LabelHeadpartList('HairMaleRedguard4', 'SHORT,NEAT,MILITARY,BOLD');
        LabelHeadpartList('HairMaleRedguard5', 'LONG,DREADS,MESSY');
        LabelHeadpartList('HairMaleRedguard6', 'SHORT,BRAIDS,NEAT,MILITARY');
        LabelHeadpartList('HairMaleRedguard7', 'SHORT,BRAIDS,MOHAWK,NEAT,MILITARY');
        LabelHeadpartList('HairMaleRedguard8', 'MOHAWK,DREADS,MESSY');

        LabelHeadpartList('HairFemaleRedguard01', 'TIEDBACK,NEAT');
        LabelHeadpartList('HairFemaleRedguard02', 'SHORT');
        LabelHeadpartList('HairFemaleRedguard03', 'BUZZ,MILITARY,SHORT,BOLD');
        LabelHeadpartList('HairFemaleRedguard04', 'BUZZ,MILITARY,SHORT,BOLD');

        // ELF
        LabelHeadpartList('HairFemaleElf01', 'MESSY');
        LabelHeadpartList('HairFemaleElf02', 'MESSY,BRAIDS');
        LabelHeadpartList('HairFemaleElf03', 'NEAT,TIEDBACK,BRAIDS,BOLD');
        LabelHeadpartList('HairFemaleElf04', 'NEAT,TIEDBACK');
        LabelHeadpartList('HairFemaleElf05', 'BRAIDS,NEAT,BOLD');
        LabelHeadpartList('HairFemaleElf06', 'SHORT,NEAT');
        LabelHeadpartList('HairFemaleElf07', 'TIEDBACK,BRAIDS,ELABORATE');
        LabelHeadpartList('HairFemaleElf08', 'LONG,MESSY');
        LabelHeadpartList('HairFemaleElf09', 'TIEDBACK,BRAIDS,ELABORATE');
        LabelHeadpartList('HairFemaleElf10', 'SHORT,NEAT');

        LabelHeadpartList('HairMaleElf01', 'NEAT,TIEDBACK');
        LabelHeadpartList('HairMaleElf02', 'MESSY,BRAIDS');
        LabelHeadpartList('HairMaleElf03', 'NEAT,TIEDBACK');
        LabelHeadpartList('HairMaleElf04', 'SHORT,NEAT');
        LabelHeadpartList('HairMaleElf05', 'BRAIDS,FUNKY,SHORT');
        LabelHeadpartList('HairMaleElf06', 'LONG,NEAT,TIEDBACK');
        LabelHeadpartList('HairMaleElf07', 'SHORT,MESSY');
        LabelHeadpartList('HairMaleElf08', 'LONG,MESSY');
        LabelHeadpartList('HairMaleElf09', 'LONG,MESSY');

        LabelHeadpartList('HairFemaleDarkElf01', 'LONG');
        LabelHeadpartList('HairFemaleDarkElf02', 'SHORT,NEAT,MILITARY');
        LabelHeadpartList('HairFemaleDarkElf03', 'LONG,TIEDBACK,FUNKY');
        LabelHeadpartList('HairFemaleDarkElf04', 'LONG,TIEDBACK,FUNKY');
        LabelHeadpartList('HairFemaleDarkElf05', 'SHORT');
        LabelHeadpartList('HairFemaleDarkElf06', 'MOHAWK,NEAT,MILITARY');
        LabelHeadpartList('HairFemaleDarkElf07', 'BUZZ,BOLD,MILITARY');
        LabelHeadpartList('HairFemaleDarkElf08', 'MOHAWK,BOLD');

        LabelHeadpartList('HairMaleDarkElf01', 'LONG,NEAT,TIEDBACK');
        LabelHeadpartList('HairMaleDarkElf02', 'SHORT,NEAT,TIEDBACK');
        LabelHeadpartList('HairMaleDarkElf03', 'LONG,TIEDBACK,FUNKY');
        LabelHeadpartList('HairMaleDarkElf04', 'SHORT,MOHAWK,FUNKY,BOLD');
        LabelHeadpartList('HairMaleDarkElf05', 'MOHAWK,BOLD');
        LabelHeadpartList('HairMaleDarkElf06', 'SHORT,FUNKY');
        LabelHeadpartList('HairMaleDarkElf07', 'BUZZ,MILITARY');
        LabelHeadpartList('HairMaleDarkElf08', 'SHORT,NEAT');
        LabelHeadpartList('HairMaleDarkElf09', 'LONG,TIEDBACK,FUNKY,BOLD');
    end;

    begin // Headparts that mean "no headpart here"
        SetEmptyHeadPart('BrowsFemaleArgonian00');
        SetEmptyHeadPart('BrowsMaleArgonian00');
        SetEmptyHeadPart('BrowsMaleHumanoid12NoBrow');
        SetEmptyHeadPart('FemaleBrowsHuman12NoBrow');
        SetEmptyHeadPart('HairArgonianFemale00');
        SetEmptyHeadPart('HairArgonianMale00');
        SetEmptyHeadPart('HairKhajiit00');
        SetEmptyHeadPart('HumanBeard00NoBeard');
        SetEmptyHeadPart('KhajiitNoBeard');
        SetEmptyHeadPart('MarksFemaleArgonianScar00');
        SetEmptyHeadPart('MarksFemaleHumanoid00NoGash');
        SetEmptyHeadPart('MarksFemaleKhajiitScar00');
        SetEmptyHeadPart('MarksMaleArgonianScar00');
        SetEmptyHeadPart('MarksMaleHumanoid00NoScar');
        SetEmptyHeadPart('MarksMaleKhajiitScar00');
    end;

    DefineLabelConflicts;
end;


{==================================================================
    Set up hair label conflicts.

    When choosing hair we pick one that does not have a label that conflicts with one of
    the NPC's labels, e.g. a "MILITARY" NPC cannot have "MESSY" hair.
}
procedure DefineLabelConflicts;
begin
    LabelConflict('FUNKY', 'NOBLE');
    LabelConflict('MESSY', 'NEAT');
    LabelConflict('MESSY', 'NOBLE');
    LabelConflict('MILITARY', 'ELABORATE');
    LabelConflict('MILITARY', 'FEATHERS');
    LabelConflict('MILITARY', 'FUNKY');
    LabelConflict('MILITARY', 'MESSY');
    LabelConflict('YOUNG', 'OLD');
    LabelConflict('YOUNG', 'MATURE');
    LabelConflict('SHORT', 'LONG');
end;

procedure DefineScars;
begin
    LabelHeadpartList('MarksFemaleHumanoid01LeftGash', 'LEFT,EYE');
    LabelHeadpartList('MarksFemaleHumanoid02LeftGash', 'LEFT');
    LabelHeadpartList('MarksFemaleHumanoid03LeftGash', 'LEFT,CHEEK');
    LabelHeadpartList('MarksFemaleHumanoid04LeftGash', 'LEFT,CHEEK,NOSE');
    LabelHeadpartList('MarksFemaleHumanoid05LeftGash', 'LEFT,CHEEK');
    LabelHeadpartList('MarksFemaleHumanoid06LeftGash', 'LEFT,EYE,NOSE');
    LabelHeadpartList('MarksFemaleHumanoid07RightGash', 'RIGHT,EYE');
    LabelHeadpartList('MarksFemaleHumanoid08RightGash', 'RIGHT,CHEEK');
    LabelHeadpartList('MarksFemaleHumanoid09RightGash', 'RIGHT,CHEEK');
    LabelHeadpartList('MarksFemaleHumanoid10LeftGash', 'LEFT,NOSE,MOUTH');
    LabelHeadpartList('MarksFemaleHumanoid10RightGashR', 'LEFT,NOSE,MOUTH');
    LabelHeadpartList('MarksFemaleHumanoid11LeftGash', 'LEFT,NOSE,CHEEK');
    LabelHeadpartList('MarksFemaleHumanoid11LeftGashR', 'LEFT,NOSE,CHEEK,MOUTH');
    LabelHeadpartList('MarksFemaleHumanoid12LeftGash', 'CHIN,LEFT');
    LabelHeadpartList('MarksFemaleHumanoid12LeftGashR', 'CHIN,CHEEK');
    LabelHeadpartList('MarksMaleHumanoid01LeftGash', 'LEFT,CHEEK,EYE');
    LabelHeadpartList('MarksMaleHumanoid02LeftGash', 'LEFT,CHEEK,CHIN');
    LabelHeadpartList('MarksMaleHumanoid03LeftGash', 'LEFT,CHEEK');
    LabelHeadpartList('MarksMaleHumanoid04LeftGash', 'LEFT,CHEEK,NOSE');
    LabelHeadpartList('MarksMaleHumanoid04RightGashR', 'LEFT,CHEEK,NOSE');
    LabelHeadpartList('MarksMaleHumanoid05LeftGash', 'LEFT,CHEEK,MOUTH');
    LabelHeadpartList('MarksMaleHumanoid06LeftGash', 'LEFT,NOSE');
    LabelHeadpartList('MarksMaleHumanoid06RightGashR', 'RIGHT,LEFT,NOSE');
    LabelHeadpartList('MarksMaleHumanoid07RightGash', 'RIGHT,EYE');
    LabelHeadpartList('MarksMaleHumanoid08RightGash', 'RIGHT,CHEEK');
    LabelHeadpartList('MarksMaleHumanoid09RightGash', 'RIGHT,CHEEK,MOUTH');
    LabelHeadpartList('MarksMaleHumanoid10LeftGash', 'LEFT,NOSE,MOUTH,CHIN');
    LabelHeadpartList('MarksMaleHumanoid10RightGashR', 'NOSE,MOUTH,CHIN');
    LabelHeadpartList('MarksMaleHumanoid11LeftGash', 'LEFT,CHEEK,MOUTH,NOSE');
    LabelHeadpartList('MarksMaleHumanoid11RightGashR', 'CHEEK,MOUTH,NOSE');
    LabelHeadpartList('MarksMaleHumanoid12LeftGash', 'LEFT');
    LabelHeadpartList('MarksMaleHumanoid12RightGashR', 'RIGHT,CHIN');
end;


{==================================================================
    Specific NPC race assignments.
}
procedure SetNPCAliases;
begin
    BEGIN // Aliases for NPCs that have multiple NPC records
        NPCAlias('AmaundMotierre', 'AmaundMotierreEnd');
        NPCAlias('Astrid', 'AstridEnd');
        NPCAlias('Breya', 'BreyaCorpse');
        NPCAlias('Cicero', 'CiceroDawnstar');
        NPCAlias('Cicero', 'CiceroRoad');
        NPCAlias('Curwe', 'CurweDead');
        NPCAlias('DA01MalynVaren', 'DA01MalynVarenCorpse');
        NPCAlias('DA05Sinding', 'DA05SindingGhost');
        NPCAlias('DA05Sinding', 'DA05SindingHuman');
        NPCAlias('DBLis', 'DBLisDead');
        NPCAlias('Delphine', 'Delphine3DNPC');
        NPCAlias('DLC1Harkon', 'DLC1HarkonCombat');
        NPCAlias('DLC1LD_Katria', 'DLC1LD_KatriaCorpse');
        NPCAlias('DLC1Malkus', 'DLC1MalkusDead');
        NPCAlias('DLC1VigilantTolan', 'DLC1VQ01VigilantTolanCorpse');
        NPCAlias('DLC2Miraak', 'DLC2MiraakMQ01');
        NPCAlias('DLC2Miraak', 'DLC2MiraakMQ06');
        NPCAlias('DLC2RRLygrleidSolstheim', 'DLC2RRLygrleidWindhelm');
        NPCAlias('DLC2RRSogrlafSolstheim', 'DLC2RRSogrlafWindhelm');
        NPCAlias('Dravynea', 'DravyneaDUPLICATE001');
        NPCAlias('Drennen', 'DrennenCorpse');
        NPCAlias('dunAnsilvundFemaleGhost', 'DunAnsilvundDraugrWarlordFemale');
        NPCAlias('dunAnsilvundMaleGhost', 'DunAnsilvundDraugrWarlord');
        NPCAlias('dunGeirmundSigdis', 'dunGeirmundSigdisDuplicate');
        NPCAlias('dunGeirmundSigdis', 'dunReachwaterRockSigdisDuplicate');
        NPCAlias('Eltrys', 'EltrysDead');
        NPCAlias('FelldirTheOld', 'MQ206Felldir');
        NPCAlias('FelldirTheOld', 'SummonFelldir');
        NPCAlias('FestusKrex', 'FestusKrexDead');
        NPCAlias('Gabriella', 'GabriellaDead');
        NPCAlias('Galmar', 'CWBattleGalmar');
        NPCAlias('GeneralTullius', 'CWBattleTullius');
        NPCAlias('GormlaithGoldenHilt', 'MQ206Gormlaith');
        NPCAlias('GormlaithGoldenHilt', 'SummonGormlaith');
        NPCAlias('Haming', 'dunHunterChild');
        NPCAlias('Kodlak', 'C04DeadKodlak');
        NPCAlias('Kodlak', 'C06DeadKodlak');
        NPCAlias('Kodlak', 'MQ304Kodlak');
        NPCAlias('Malborn', 'MQ201FakeMalborn');
        NPCAlias('MQ206Hakon', 'HakonOneEye');
        NPCAlias('MQ206Hakon', 'SummonHakon');
        NPCAlias('MS13Arvel', 'e3DemoArvel');
        NPCAlias('Nazir', 'NazirSancAttack');
        NPCAlias('Nerien', 'MG02Nerien');
        NPCAlias('Rikke', 'CWBattleRikke');
        NPCAlias('SavosAren', 'SavosArenGhost');
        NPCAlias('Susanna', 'MS11SusannaDeadA');
        NPCAlias('Thorek', 'Thorek_Ambush');
        NPCAlias('TitusMedeII', 'TitusMedeIIDecoy');
        NPCAlias('Tova', 'TovaDead');
        NPCAlias('Ulfric', 'CWBattleUlfric');
        NPCAlias('Ulfric', 'MQ304Ulfric');
        NPCAlias('VantusLoreius', 'VantusLoreiusDead');
        NPCAlias('Veezara', 'VeezaraDead');
        NPCAlias('VerenDuleri', 'VerenDuleri_Ambush');
        NPCAlias('WatchesTheRoots', 'WatchesTheRootsCorpse');
        NPCAlias('WEDL04PlautisCarvain', 'WEDL03PlautisCarvain');
        NPCAlias('WEDL04SaloniaCarvain', 'WEDL03SaloniaCarvain');
    END;
end;

{==================================================================
    Specific NPC race assignments.
}
procedure AssignNPCRaces;
begin
    SetNPCRace('Ainethach', 'YASReachmanRace');
    SetNPCRace('Belchimac', 'YASReachmanRace');
    SetNPCRace('Cosnach', 'YASReachmanRace');
    SetNPCRace('Duach', 'YASReachmanRace');
    SetNPCRace('Enmon', 'YASReachmanRace');
    SetNPCRace('Gralnach', 'YASReachmanRaceChild');
    SetNPCRace('Mena', 'YASReachmanRace');
    SetNPCRace('Rondach', 'YASReachmanRace');
    SetNPCRace('MS01Weylin', 'YASReachmanRace');
    SetNPCRace('Anton', 'YASReachmanRace'); // "Anton sure looks like he's from the Reach"
    SetNPCRace('Hathrasil', 'YASReachmanRace');
    SetNPCRace('Omluag', 'YASReachmanRace');
    SetNPCRace('Madanach', 'YASReachmanRace');
    SetNPCRace('NeposTheNose', 'YASReachmanRace');
    SetNPCRace('DLC2RRCresciusCaerellius', 'NordRace');
    SetNPCRace('SeptimusSignus', 'ImperialRace');
    SetNPCRace('BrotherVerulus', 'ImperialRace');
    SetNPCRace('KeeperCarcette', 'BretonRace');
    SetNPCRace('EncOrcWarriorOld', 'OrcRace');
end;

end.