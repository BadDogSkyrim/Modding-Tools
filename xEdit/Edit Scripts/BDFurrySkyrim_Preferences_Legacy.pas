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
unit BDFurrySkyrim_Preferences;

interface
implementation
uses BDFurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;


Procedure SetRacePreferences;
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
        SetRace('SnowElfRaceVampire', 'YASShanRaceVampire', 'CAT');
    end;

    { ================================== ORC (MINO) ============================= }
    BEGIN
        // SetRace('OrcRace', 'BDMinoRace', 'MINO');
        // SetRace('OrcRaceVampire', 'BDMinoRaceVampire', 'MINO');

        // // Male hair
        // LabelHeadpartList('BDMinoHairFringe', 'NEAT,SHORT,YOUNG');
        // LabelHeadpartList('BDMinoHairNone', 'NEAT,BUZZ,MILITARY');
        // LabelHeadpartList('BDMinoHairMaleDreads01', 'DREADS,LONG,BOLD');
        // LabelHeadpartList('BDMinoHairMaleDreadsBeads', 'DREADS,LONG,BOLD,NOBLE');
        // LabelHeadpartList('BDMinoHairMaleMohawk', 'MOHAWK,BOLD');
        // LabelHeadpartList('BDMinoHairMaleMohawkDark', 'MOHAWK,BOLD');
        // LabelHeadpartList('BDMinoHairMaleMohawkFeathers', 'MOHAWK,BOLD,FUNKY,FEATHERS');
        // LabelHeadpartList('BDMinoHairMaleMane', 'MANE,LONG,BOLD');
        // LabelHeadpartList('BDMinoHairMaleShaggy', 'LONG,MESSY');
        // LabelHeadpartList('BDMinoHairMale01', 'BRAIDS,LONG,TIEDBACK');
        // LabelHeadpartList('BDMinoHairMale02', 'LONG,TIEDBACK');
        // LabelHeadpartList('BDMinoHairMale04', 'SHORT,NEAT');
        // LabelHeadpartList('BDMinoHairMale03', 'MESSY,LONG,BOLD');
        // LabelHeadpartList('BDMinoHairMale05', 'NEAT,BRAID,ELABORATE');
        // LabelHeadpartList('BDMinoHairMale06', 'NEAT,TIEDBACK');
        // LabelHeadpartList('BDMinoHairMale07', 'MOHAWK,NEAT,MILITARY');
        // LabelHeadpartList('BDMinoHairMale08', 'LONG,MESSY');
        // LabelHeadpartList('BDMinoHairMale09', 'NEAT,BRAIDS,FUNKY');
        // LabelHeadpartList('BDMinoHairMaleLong', 'LONG,ELABORATE');
        // LabelHeadpartList('BDMinoHairMaleManeHeadband', 'MANE,LONG,NOBLE');
        // LabelHeadpartList('BDMinoHairMaleManeFeather', 'MANE,LONG,FEATHERS');
        // LabelHeadpartList('BDMinoHairMaleManeCurly', 'MANE,LONG,BOLD');
        // LabelHeadpartList('BDMinoHairMinoManeRough', 'MANE,LONG,MESSY');

        // // Female Hair
        // LabelHeadpartList('BDMinoHairFemTiedStyle001', 'LONG,ELABORATE,NOBLE');
        // LabelHeadpartList('BDMinoHairFem10', 'SHORT,TIEDBACK');
        // LabelHeadpartList('BDMinoHairFem09', 'SHORT,BRAIDS,TIEDBACK');
        // LabelHeadpartList('BDMinoHairFem03', 'SHORT,TIEDBACK');
        // LabelHeadpartList('BDMinoHairFem04', 'BRAIDS,NEAT');
        // LabelHeadpartList('BDMinoHairFem05', 'TIEDBACK,FUNKY');
        // LabelHeadpartList('BDMinoHairFem06', 'SHORT,TIEDBACK,NEAT,FUNKY');
        // LabelHeadpartList('BDMinoHairFemFringe', 'SHORT,YOUNG');
        // LabelHeadpartList('BDMinoHairFemDreads01', 'DREADS,LONG');
        // LabelHeadpartList('BDMinoHairFemDreadsBeads', 'DREADS,LONG,NOBLE');
        // LabelHeadpartList('BDMinoHairFemMane', 'MANE,LONG,BOLD');
        // LabelHeadpartList('BDMinoHairFemShaggy', 'LONG,MESSY');
        // LabelHeadpartList('BDMinoHairFemManeHeadband', 'MANE,LONG,BOLD,NOBLE');
        // LabelHeadpartList('BDMinoHairFemManeFeather', 'MANE,LONG,FEATHERS');
        // LabelHeadpartList('BDMinoHairFemManeCurly', 'MANE,LONG,BOLD');
        // LabelHeadpartList('BDMinoHairFemManeRough', 'MANE,LONG,BOLD');
        // LabelHeadpartList('BDMinoHairFemLongBraid', 'LONG,BRAID');
        // LabelHeadpartList('BDMinoHairFemApachii01', 'SHORT,YOUNG');
        // LabelHeadpartList('BDMinoHairFemApachii02', 'DREADS,LONG,ELABORATE');
        // LabelHeadpartList('BDMinoHairFemApachii03', 'SHORT,YOUNG,MESSY');
        // LabelHeadpartList('BDMinoHairFemApachii04', 'LONG,MESSY');
        // LabelHeadpartList('BDMinoHairFemApachii05', 'LONG,MESSY');
    END;


    { ================================== ORC (HORSE) ============================ }
    BEGIN

        // SetRace('OrcRace', 'BDHorseRace', 'UNG', '');
        // SetRace('OrcRaceVampire', 'BDHorseRaceVampire', 'UNG', '');

        // // Male hair
        // LabelHeadpartList('BDHorseMaleHairFringe', 'SHORT,NEAT,YOUNG');
        // LabelHeadpartList('BDHorseMaleManeMohawk', 'MOHAWK,NEAT,BOLD');
        // LabelHeadpartList('BDHorseMaleHairMohawkFringe', 'MOHAWK,NEAT,YOUNG,BOLD');
        // LabelHeadpartList('BDHorseMaleHairSideMane', 'LONG,MESSY');
        // LabelHeadpartList('BDHorseMaleHairSideManeFringe', 'LONG,MESSY,YOUNG');
        // LabelHeadpartList('BDHorseMaleHairRoached', 'MOHAWK,NEAT,MILITARY,BOLD');
        // LabelHeadpartList('BDHorseMaleHairManeShort', 'LONG,NEAT');
        // LabelHeadpartList('BDHorseMaleManeSimple', 'LONG,MESSY');
        // LabelHeadpartList('BDHorseMaleHairTied', 'SHORT,NEAT,MILITARY,BRAIDS');
        // LabelHeadpartList('BDHorseMaleManeFree', 'LONG,TIEDBACK,BOLD');
        // LabelHeadpartList('BDHorseMaleManeSide02', 'LONG,TIEDBACK,MESSY');
        // LabelHeadpartList('BDHorseMaleManeSide03', 'LONG,TIEDBACK,MESSY');  
        // LabelHeadpartList('BDHairHorseMaleNord20', 'LONG,TIEDBACK,MESSY');
        // LabelHeadpartList('BDHairHorseMaleNord17', 'MOHAWK,MESSY,BOLD');
        // LabelHeadpartList('BDHairMaleOrc27', 'MOHAWK,MESSY,BOLD,FUNKY');
        // LabelHeadpartList('BDHairHorseMaleOrc13', 'NEAT,TIEDBACK');

        // // Female Hair
        // //LabelHeadpartList('BDHairHorseFemNord04', ''); // Omitted--full head of hair
        // //LabelHeadpartList('BDHairHorseFemOrc03', ''); // Omitted--full head of hair
        // //LabelHeadpartList('BDHairHorseFemOrc08', ''); // Omitted--full head of hair
        // LabelHeadpartList('BDHairHorseFemOrc14', 'SHORT,TIEDBACK,NEAT');
        // LabelHeadpartList('BDHairHoseFemOrc17', 'SHORT,FUNKY,MOHAWK');
        // LabelHeadpartList('BDHorseFemManeLong', 'LONG,TIEDBACK,ELABORATE');
        // LabelHeadpartList('BDHorseFemManeShort', 'LONG,MESSY');
        // LabelHeadpartList('BDHorseFemManeRoached', 'SHORT,NEAT,MILITARY');
        // LabelHeadpartList('BDHorseFemManeSide01Fringe', 'LONG,MESSY');
        // LabelHeadpartList('BDHorseFemManeSide01', 'LONG,MESSY');
        // LabelHeadpartList('BDHorseFemManeMohawkFlip', 'MOHAWK,BOLD,FUNKY,YOUNG');
        // LabelHeadpartList('BDHorseFemManeFringe', 'SHORT,YOUNG');
        // LabelHeadpartList('BDHorseFemManeMohawk', 'MOHAWK,BOLD,FUNKY');
        // LabelHeadpartList('BDHorseFemManeSide03', 'LONG,NEAT');
        // LabelHeadpartList('BDHorseFemManeSide02', 'LONG,NEAT');
        // LabelHeadpartList('BDHorseFemManeFree', 'LONG,BOLD');
        // LabelHeadpartList('BDHorseFemManeSimple', 'LONG,MESSY,TIEDBACK');
        // //LabelHeadpartList('BDHorseFemManeBase', ''); // Omitted--should have been a hairline
        // LabelHeadpartList('BDHorseFemManeTied', 'NEAT,SHORT,BRAIDS,MILITARY,BOLD');

        // // Horse Eyes
        // // These are horse-style pupils. There are human-style pupils available.
        // AssignHeadpart('MaleEyesHumanAmber', 'BDHorse0MaleEyesYellow');
        // AssignHeadpart('MaleEyesHumanAmberBlindRight', 'BDHorse0MaleEyesYellow');
        // AssignHeadpart('MaleEyesHumanBlind', 'BDHorseMaleEyesOrcBlind');
        // AssignHeadpart('MaleEyesHumanBrightGreen', 'BDHorse0MaleEyesGreen');
        // AssignHeadpart('MaleEyesHumanBrightGreenBlindRight', 'BDHorse0MaleEyesGreen');
        // AssignHeadpart('MaleEyesHumanBrown', 'BDHorse0MaleEyesBrown');
        // AssignHeadpart('MaleEyesHumanBrownBlindLeft', 'BDHorse0MaleEyesBrown');
        // AssignHeadpart('MaleEyesHumanBrownBlindRight', 'BDHorse0MaleEyesBrown');
        // AssignHeadpart('MaleEyesHumanBrownBloodShot', 'BDHorse0MaleEyesBrown');
        // AssignHeadpart('MaleEyesHumanDarkBlue', 'BDHorse0MaleEyesBlue');
        // AssignHeadpart('MaleEyesHumanDemon', 'BDHorseMaleEyesHumanDemon');
        // AssignHeadpart('MaleEyesHumanGreenHazelLeft', 'BDHorse0MaleEyesGreen');
        // AssignHeadpart('MaleEyesHumanGrey', 'BDHorse0MaleEyesBlue');
        // AssignHeadpart('MaleEyesHumanHazel', 'BDHorse0MaleEyesRed');
        // AssignHeadpart('MaleEyesHumanHazelBrown', 'BDHorse0MaleEyesYellow');
        // AssignHeadpart('MaleEyesHumanIceBlue', 'BDHorse0MaleEyesIceBlue');
        // AssignHeadpart('MaleEyesHumanLightBlue', 'BDHorse0MaleEyesIceBlue');
        // AssignHeadpart('MaleEyesHumanLightBlueBlindLeft', 'BDHorse0MaleEyesRed');
        // AssignHeadpart('MaleEyesHumanLightBlueBloodShot', 'BDHorse0MaleEyesRed');
        // AssignHeadpart('MaleEyesHumanLightGrey', 'BDHorse0MaleEyesIceBlue');
        // AssignHeadpart('MaleEyesHumanLightIceGreyBlindLeft', 'BDHorse0MaleEyesIceBlue');
        // AssignHeadpart('MaleEyesHumanVampire', 'BDHorseMaleEyesVamp');

        // AssignHeadpart('FemaleEyesHumanAmber', 'BDHorse0FemEyesYellow');
        // AssignHeadpart('FemaleEyesHumanAmberBlindLeft', 'BDHorse0FemEyesYellow');
        // AssignHeadpart('FemaleEyesHumanBlind', 'BDHorse0FemEyesRed');
        // AssignHeadpart('FemaleEyesHumanBrightGreen', 'BDHorse0FemEyesGreen');
        // AssignHeadpart('FemaleEyesHumanBrown', 'BDHorse0FemEyesBrown');
        // AssignHeadpart('FemaleEyesHumanBrownBlindRight', 'BDHorse0FemEyesBrown');
        // AssignHeadpart('FemaleEyesHumanBrownBloodShot', 'BDHorse0FemEyesRed');
        // AssignHeadpart('FemaleEyesHumanDarkBlue', 'BDHorse0FemEyesBlue');
        // AssignHeadpart('FemaleEyesHumanDarkBlueBlindRight', 'BDHorse0FemEyesBlue');
        // AssignHeadpart('FemaleEyesHumanGreenHazel', 'BDHorse0FemEyesGreen');
        // AssignHeadpart('FemaleEyesHumanGrey', 'BDHorse0FemEyesIceBlue');
        // AssignHeadpart('FemaleEyesHumanGreyBlindLeft', 'BDHorse0FemEyesIceBlue');
        // AssignHeadpart('FemaleEyesHumanHazel', 'BDHorse0FemEyesYellow');
        // AssignHeadpart('FemaleEyesHumanHazelBrown', 'BDHorse0FemEyesRed');
        // AssignHeadpart('FemaleEyesHumanIceBlue', 'BDHorse0FemEyesIceBlue');
        // AssignHeadpart('FemaleEyesHumanLightBlue', 'BDHorse0FemEyesIceBlue');
        // AssignHeadpart('FemaleEyesHumanLightBlueBloodShot', 'BDHorse0FemEyesBlue');
        // AssignHeadpart('FemaleEyesHumanLightGrey', 'BDHorse0FemEyesIceBlue');
        // AssignHeadpart('FemaleEyesHumanYellow', 'BDHorse0FemEyesYellow');
    END;

end;

end.