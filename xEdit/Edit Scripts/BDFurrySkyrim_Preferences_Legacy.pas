{
    Define furrification from vanilla to furry races. Edit this file to change how 
    furry races are assigned to NPCs.

    [SetRace] defines a furry race and sets it as the replace for a vanilla race.
    Parameters:
        * Vanilla race editor ID
        * Furry race editor ID
        * Furry race class. Not currently used. In the future may allow for assets that 
            are shared among similar races.

    [SetSubrace] defines a new race so that some NPCs can be assigned a separate race, 
    regardless of their vanilla race. This allows Skaal and Reachmen to be treated
    as separate races.
    Parameters:
        * Subrace editor ID
        * Subrace name
        * Vanilla race editor ID to be used as the template for the subrace
        * Furry race editor ID to be used to furrify the subrace
        * Furry race class.

    [SetFactionRace] assigns all members of a faction to a subrace.
    Parameters:
        * Faction editor ID
        * Subrace editor ID'ForswornFaction', 'YASReachmanRace');
    
    Not yet implemented. [SetTattooRace] assigns any NPC with a particular tattoo to a subrace.
    Parameters:
        * Tattoo string. NPC must have a tint layer containing this string in the filename.
        * Subrace editor ID

}
unit BDFurrySkyrim_Preferences_Legacy;

interface
implementation
uses BDFurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;


Procedure SetRacePreferences_Legacy;
begin
    BEGIN // ============ NORD ============
        SetRace('NordRace', 'YASLykaiosRace', 'DOG');
        SetRace('NordRaceVampire', 'YASLykaiosRaceVampire', 'DOG');
        SetRace('NordRaceChild', 'YASLykaiosRaceChild', 'DOG');
        SetRace('DLC1NordRace', 'YASLykaiosRace', 'DOG');
        SetRace('NordRaceAstrid', 'YASLykaiosRace', 'DOG');
    END;

    BEGIN // =========== ELDER  ===========
        SetRace('ElderRace', 'YASLykaiosRace', 'DOG');
        SetRace('ElderRaceVampire', 'YASLykaiosRaceVampire', 'DOG');
    end;

    BEGIN // =========== IMPERIAL ============
        SetRace('ImperialRace', 'YASVaalsarkRace', 'DOG');
        SetRace('ImperialRaceChild', 'YASVaalsarkRaceChild', 'DOG');
        SetRace('ImperialRaceVampire', 'YASVaalsarkRaceVampire', 'DOG');
    end;

    BEGIN // =========== BRETON  ===========
        SetRace('BretonRace', 'YASKettuRace', 'DOG');
        SetRace('BretonRaceChild', 'YASKettuRaceChild', 'DOG');
        SetRace('BretonRaceVampire', 'YASKettuRaceVampire', 'DOG');
        SetRace('BretonRaceChildVampire', 'YASKettuRaceChildVampire', 'DOG');
    end;

    BEGIN // =========== REDGUARD ============
        SetRace('RedguardRace', 'YASKygarraRace', 'DOG');
        SetRace('RedguardRaceChild', 'YASKygarraRaceChild', 'DOG');
        SetRace('RedguardRaceVampire', 'YASKygarraRaceVampire', 'DOG');
    end;

    BEGIN // =========== REACHMAN ============
        SetSubrace('YASReachmanRace', 'Reachmen', 'BretonRace', 'YASKonoiRace', 'DOG');
        SetSubrace('YASReachmanRaceVampire', 'Reachmen', 'BretonRaceVampire', 'YASKonoiRaceVampire', 'DOG');
        SetSubrace('YASReachmanRaceChild', 'Reachmen', 'BretonRaceChild', 'YASKonoiRaceChild', 'DOG');
        SetFactionRace('ForswornFaction', 'YASReachmanRace');
        SetFactionRace('MS01TreasuryHouseForsworn', 'YASReachmanRace');
        SetFactionRace('DruadachRedoubtFaction', 'YASReachmanRace');
        SetTattooRace('ForswornTattoo', 'YASReachmanRace');
    end;

    BEGIN // ========== SKAAL ============
        SetSubrace('YASSkaalRace', 'Skaal', 'NordRace', 'YASXebaRace', 'DOG');
        SetSubrace('YASSkaalRaceChild', 'Skaal', 'NordRaceChild', 'YASXebaRaceChild', 'DOG');
        SetSubrace('YASSkaalRaceVampire', 'Skaal', 'NordRaceVampire', 'YASXebaRaceVampire', 'DOG');
        SetFactionRace('DLC2SkaalVillageCitizenFaction', 'YASSkaalRace');
    end;

    { ================================== ARGONIAN ================================ }

    { ================================== HIGH ELF ================================== }
    BEGIN
        SetRace('HighElfRace', 'YASDumaRace', 'CAT');
        SetRace('HighElfRaceVampire', 'YASDumaRaceVampire', 'CAT');
    end;

    { ================================== WOOD ELF ================================== }
    BEGIN
        SetRace('WoodElfRace', 'YASBaghaRace', 'CAT');
        SetRace('WoodElfRaceVampire', 'YASBaghaRaceVampire', 'CAT');
    end;

    { ================================== DARK ELF ================================== }
    BEGIN
        SetRace('DarkElfRace', 'YASKaloRace', 'CAT');
        SetRace('DarkElfRaceVampire', 'YASKaloRaceVampire', 'CAT');
    end;

    { ================================== ORC (Sabrelion) ============================= }
    BEGIN
        SetRace('OrcRace', 'YASMahaRace', 'CAT');
        SetRace('OrcRaceVampire', 'YASMahaRaceVampire', 'CAT');
    end;

    BEGIN // ========== SNOW ELF ============
        SetRace('SnowElfRace', 'YASShanRace', 'CAT');
        // SetRace('SnowElfRaceVampire', 'YASShanRaceVampire', 'CAT');
    end;

end;

end.