{
}
unit FurrySkyrim_Preferences;

interface
implementation
uses FurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;


Procedure SetPreferences;
begin
    { ================================== LYKAIOS ================================== }

    BEGIN
        SetRace('NordRace', 'LykaiosRace', 'DOG', 'KhajiitRace');
        SetRace('NordRaceVampire', 'LykaiosRaceVampire', 'DOG', 'KhajiitRaceVampire');
        SetRace('DLC1NordRace', 'LykaiosRace', 'DOG', 'KhajiitRace');

        // Lykaios Hair
        LabelHeadpartList('00HairLykaiosMaleDreads001_', 'DREADS,BOLD,FUNKY');
        // LabelHeadpart('00HairLykaiosMaleDreads002_', 'DREADS'); // Dark version
        LabelHeadpartList('00HairLykaiosMaleDreads003_', 'DREADS,NOBLE,BOLD,FUNKY');
        // LabelHeadpart('00HairLykaiosMaleDreads004_', 'DREADS'); // Dark version
        LabelHeadpartList('00HairLykaiosMaleDreadsFringe_', 'DREADS,NOBLE,BOLD,FUNKY,YOUNG');
        LabelHeadpartList('00HairLykaiosMaleDreadsHeadband_', 'DREADS,NOBLE,BOLD,FUNKY,FEATHERS');
        LabelHeadpartList('00HairLykaiosMaleFringeFlip001_', 'YOUNG,SHORT');
        LabelHeadpartList('00HairLykaiosMaleLionMane001', 'MANE,LONG');
        LabelHeadpartList('00HairLykaiosMaleLionMane002', 'MANE,LONG,YOUNG');
        LabelHeadpartList('00HairLykaiosMaleLionManebraids', 'MANE,LONG,NOBLE,BRAIDS');
        LabelHeadpartList('00HairLykaiosMaleLionManeFringeLeftBraid_', 'MANE,LONG,NOBLE,BRAIDS');
        LabelHeadpartList('00HairLykaiosMaleLionManeHeadband', 'MANE,LONG,NOBLE,FEATHERS');
        LabelHeadpartList('00HairLykaiosMaleLongBraid001_', 'BRAIDS,NEAT,TIEDBACK,BRAIDS,NEAT');
        LabelHeadpartList('00HairLykaiosMaleLongBraid002_', 'TIEDBACK,BRAIDS,NOBLE');
        LabelHeadpartList('00HairLykaiosMaleLongBraidLeft_', 'NEAT,TIEDBACK,BRAIDS,NOBLE');
        LabelHeadpartList('00HairLykaiosMaleMohawk001_', 'MOHAWK,BRAIDS,MILITARY,BOLD');
        LabelHeadpartList('00HairLykaiosMaleMohawk003_', 'MOHAWK,FEATHERS,BOLD');
        LabelHeadpartList('00HairLykaiosMaleMohawkFringe_', 'MOHAWK,YOUNG,BOLD');
        LabelHeadpartList('00HairLykaiosMaleShaggyHair002_', 'LONG,MESSY');
        LabelHeadpartList('00HairLykaiosMaleShaggyHair003_', 'LONG,MESSY,FEATHERS');
        LabelHeadpartList('00HairLykaiosMaleShorCrop001_', 'SHORT,NEAT');
        LabelHeadpartList('00HairLykaiosMaleShorCrop002_', 'SHORT,NEAT,YOUNG');
        LabelHeadpartList('00HairLykaiosMaleShorCrop003_', 'SHORT,NEAT,NOBLE');
        LabelHeadpartList('00HairLykaiosMaleShorCrop004_', 'SHORT,NEAT,NOBLE,FEATHERS');
        LabelHeadpartList('00HairLykaiosMaleTiedStyle001_', 'LONG,NOBLE,NEAT');
        LabelHeadpartList('00HairLykaiosMaleTiedStyleFringe_', 'LONG,NOBLE,NEAT,YOUNG');
        LabelHeadpartList('00HairLykaiosMaleTiedStyleHeadband_', 'LONG,NOBLE,NEAT,YOUNG,FEATHERS');
        LabelHeadpartList('00HairLykaiosMaleVanillaBraid001_', 'LONG,NEAT,TIEDBACK');
        LabelHeadpartList('00HairLykaiosMaleVanillaCrop001_', 'SHORT,YOUNG,MILITARY');
        LabelHeadpartList('00HairLykaiosMaleVanillaHair001_', 'MESSY,LONG');
        LabelHeadpartList('HairBeastSidehawk', 'MOHAWK,FUNKY,BOLD');

        LabelHeadpartList('00HairLykaiosFemaleBraid001_', 'NEAT,TIEDBACK,LONG,BRAIDS');
        LabelHeadpartList('00HairLykaiosFemaleBraid002_', 'NEAT,TIEDBACK,LONG,BRAIDS,NOBLE');
        LabelHeadpartList('00HairLykaiosFemaleDreads001_', 'DREADS,BOLD,FUNKY');
        LabelHeadpartList('00HairLykaiosFemaleDreads002_', 'DREADS,BOLD,FUNKY,NOBLE,ELABORATE');
        LabelHeadpartList('00HairLykaiosFemaleFringeFlip001_', 'YOUNG,NEAT,SHORT');
        LabelHeadpartList('00HairLykaiosFemaleMane001_', 'MANE,LONG,BOLD');
        LabelHeadpartList('00HairLykaiosFemaleMane002_', 'MANE,LONG,BOLD');
        LabelHeadpartList('00HairLykaiosFemaleMane003', 'MANE,LONG,BOLD,NOBLE');
        LabelHeadpartList('00HairLykaiosFemaleMohawk001_', 'MOHAWK,BOLD,FUNKY');
        LabelHeadpartList('00HairLykaiosFemaleMohawk002_', 'MOHAWK,BOLD,FUNKY,FEATHERS');
        LabelHeadpartList('00HairLykaiosFemaleShaggy001_', 'LONG,MESSY,LONG');
        LabelHeadpartList('00HairLykaiosFemaleShaggy002_', 'MESSY,BRAIDS');
        LabelHeadpartList('00HairLykaiosFemaleShortCrop001_', 'SHORT,NEAT,MILITARY');
        LabelHeadpartList('00HairLykaiosFemaleShortCrop002_', 'SHORT,NEAT');
        LabelHeadpartList('00HairLykaiosFemaleShortCrop003_', 'SHORT,NEAT,BRAIDS,NOBLE');
        LabelHeadpartList('00HairLykaiosFemaleTiedStyle001_', 'LONG,NOBLE,ELABORATE');
        LabelHeadpartList('00HairLykaiosFemaleVanillaBraid001_', 'TIEDBACK,BRAIDS');
        LabelHeadpartList('00HairLykaiosFemaleVanillaCrop001_', 'SHORT,TIEDBACK');
        LabelHeadpartList('00HairLykaiosFemaleVanillaHair001_', 'SHORT,BRAIDS,FUNKY');
        LabelHeadpartList('00LykaiosHairKhajiitFemale02', 'SHORT,TIEDBACK');
        LabelHeadpartList('00LykaiosHairKhajiitFemale03', 'SHORT,BRAIDS,FUNKY');

        // Lykaios Eyes

        AssignHeadpart('MaleEyesHumanAmber', '00LykaiosMaleEyesAmber');
        AssignHeadpart('MaleEyesHumanAmberBlindRight', '00LykaiosMaleEyesAlbino');
        AssignHeadpart('MaleEyesHumanBlind', '00LykaiosMaleEyesAlbino');
        AssignHeadpart('MaleEyesHumanBrightGreen', '00LykaiosMaleEyesGreen');
        AssignHeadpart('MaleEyesHumanBrightGreenBlindRight', '00LykaiosMaleEyesGreen');
        AssignHeadpart('MaleEyesHumanBrown', '00LykaiosMaleEyesBrown');
        AssignHeadpart('MaleEyesHumanBrownBlindLeft', '00LykaiosMaleEyesAlbino');
        AssignHeadpart('MaleEyesHumanBrownBlindRight', '00LykaiosMaleEyesAlbino');
        AssignHeadpart('MaleEyesHumanBrownBloodShot', '00LykaiosMaleEyesBrown');
        AssignHeadpart('MaleEyesHumanDarkBlue', '00LykaiosMaleEyesDarkBlue');
        AssignHeadpart('MaleEyesHumanDemon', '00LykaiosMaleEyesRed');
        AssignHeadpart('MaleEyesHumanGreenHazelLeft', '00LykaiosMaleEyesYellow');
        AssignHeadpart('MaleEyesHumanGrey', '00LykaiosMaleEyesBase');
        AssignHeadpart('MaleEyesHumanHazel', '00LykaiosMaleEyesYellow');
        AssignHeadpart('MaleEyesHumanHazelBrown', '00LykaiosMaleEyesYellow');
        AssignHeadpart('MaleEyesHumanIceBlue', '00LykaiosMaleEyesBlue');
        AssignHeadpart('MaleEyesHumanLightBlue', '00LykaiosMaleEyesSnow1');
        AssignHeadpart('MaleEyesHumanLightBlueBlindLeft', '00LykaiosMaleEyesAlbino');
        AssignHeadpart('MaleEyesHumanLightBlueBloodShot', '00LykaiosMaleEyesSnow1');
        AssignHeadpart('MaleEyesHumanLightGrey', '00LykaiosMaleEyesGrey');
        AssignHeadpart('MaleEyesHumanLightIceGreyBlindLeft', '00LykaiosMaleEyesLilac');
        AssignHeadpart('MaleEyesHumanVampire', '00LykaiosMaleEyesVampire');
    END;


    { ================================== HORSES ================================== }
    BEGIN

        SetRace('OrcRace', 'BDMinoRace', 'MINO', 'KhajiitRace');
        SetRace('OrcRaceVampire', 'BDMinoRaceVampire', 'MINO', 'KhajiitRaceVampire');

        // Male hair
        LabelHeadpartList('BDMinoHairFringe', 'NEAT,SHORT,YOUNG');
        LabelHeadpartList('BDMinoHairNone', 'NEAT,BUZZ,MILITARY');
        LabelHeadpartList('BDMinoHairMaleDreads01', 'DREADS,LONG,BOLD');
        LabelHeadpartList('BDMinoHairMaleDreadsBeads', 'DREADS,LONG,BOLD,NOBLE');
        LabelHeadpartList('BDMinoHairMaleMohawk', 'MOHAWK,BOLD');
        LabelHeadpartList('BDMinoHairMaleMohawkDark', 'MOHAWK,BOLD');
        LabelHeadpartList('BDMinoHairMaleMohawkFeathers', 'MOHAWK,BOLD,FUNKY,FEATHERS');
        LabelHeadpartList('BDMinoHairMaleMane', 'MANE,LONG,BOLD');
        LabelHeadpartList('BDMinoHairMaleShaggy', 'LONG,MESSY');
        LabelHeadpartList('BDMinoHairMale01', 'BRAIDS,LONG,TIEDBACK');
        LabelHeadpartList('BDMinoHairMale02', 'LONG,TIEDBACK');
        LabelHeadpartList('BDMinoHairMale04', 'SHORT,NEAT');
        LabelHeadpartList('BDMinoHairMale03', 'MESSY,LONG,BOLD');
        LabelHeadpartList('BDMinoHairMale05', 'NEAT,BRAID,ELABORATE');
        LabelHeadpartList('BDMinoHairMale06', 'NEAT,TIEDBACK');
        LabelHeadpartList('BDMinoHairMale07', 'MOHAWK,NEAT,MILITARY');
        LabelHeadpartList('BDMinoHairMale08', 'LONG,MESSY');
        LabelHeadpartList('BDMinoHairMale09', 'NEAT,BRAIDS,FUNKY');
        LabelHeadpartList('BDMinoHairMaleLong', 'LONG,ELABORATE');
        LabelHeadpartList('BDMinoHairMaleManeHeadband', 'MANE,LONG,NOBLE');
        LabelHeadpartList('BDMinoHairMaleManeFeather', 'MANE,LONG,FEATHERS');
        LabelHeadpartList('BDMinoHairMaleManeCurly', 'MANE,LONG,BOLD');
        LabelHeadpartList('BDMinoHairMinoManeRough', 'MANE,LONG,MESSY');

        // Female Hair
        LabelHeadpartList('BDMinoHairFemTiedStyle001', 'LONG,ELABORATE,NOBLE');
        LabelHeadpartList('BDMinoHairFem10', 'SHORT,TIEDBACK');
        LabelHeadpartList('BDMinoHairFem09', 'SHORT,BRAIDS,TIEDBACK');
        LabelHeadpartList('BDMinoHairFem03', 'SHORT,TIEDBACK');
        LabelHeadpartList('BDMinoHairFem04', 'BRAIDS,NEAT');
        LabelHeadpartList('BDMinoHairFem05', 'TIEDBACK,FUNKY');
        LabelHeadpartList('BDMinoHairFem06', 'SHORT,TIEDBACK,NEAT,FUNKY');
        LabelHeadpartList('BDMinoHairFemFringe', 'SHORT,YOUNG');
        LabelHeadpartList('BDMinoHairFemDreads01', 'DREADS,LONG');
        LabelHeadpartList('BDMinoHairFemDreadsBeads', 'DREADS,LONG,NOBLE');
        LabelHeadpartList('BDMinoHairFemMane', 'MANE,LONG,BOLD');
        LabelHeadpartList('BDMinoHairFemShaggy', 'LONG,MESSY');
        LabelHeadpartList('BDMinoHairFemManeHeadband', 'MANE,LONG,BOLD,NOBLE');
        LabelHeadpartList('BDMinoHairFemManeFeather', 'MANE,LONG,FEATHERS');
        LabelHeadpartList('BDMinoHairFemManeCurly', 'MANE,LONG,BOLD');
        LabelHeadpartList('BDMinoHairFemManeRough', 'MANE,LONG,BOLD');
        LabelHeadpartList('BDMinoHairFemLongBraid', 'LONG,BRAID');
        LabelHeadpartList('BDMinoHairFemApachii01', 'SHORT,YOUNG');
        LabelHeadpartList('BDMinoHairFemApachii02', 'DREADS,LONG,ELABORATE');
        LabelHeadpartList('BDMinoHairFemApachii03', 'SHORT,YOUNG,MESSY');
        LabelHeadpartList('BDMinoHairFemApachii04', 'LONG,MESSY');
        LabelHeadpartList('BDMinoHairFemApachii05', 'LONG,MESSY');
    END;


    { ================================== MINOTAURS ================================== }
    BEGIN

        SetRace('OrcRace', 'BDHorseRace', 'UNG', '');
        SetRace('OrcRaceVampire', 'BDHorseRaceVampire', 'UNG', '');

        // Male hair
        LabelHeadpartList('BDHorseMaleHairFringe', 'SHORT,NEAT,YOUNG');
        LabelHeadpartList('BDHorseMaleManeMohawk', 'MOHAWK,NEAT,BOLD');
        LabelHeadpartList('BDHorseMaleHairMohawkFringe', 'MOHAWK,NEAT,YOUNG,BOLD');
        LabelHeadpartList('BDHorseMaleHairSideMane', 'LONG,MESSY');
        LabelHeadpartList('BDHorseMaleHairSideManeFringe', 'LONG,MESSY,YOUNG');
        LabelHeadpartList('BDHorseMaleHairRoached', 'MOHAWK,NEAT,MILITARY,BOLD');
        LabelHeadpartList('BDHorseMaleHairManeShort', 'LONG,NEAT');
        LabelHeadpartList('BDHorseMaleManeSimple', 'LONG,MESSY');
        LabelHeadpartList('BDHorseMaleHairTied', 'SHORT,NEAT,MILITARY,BRAIDS');
        LabelHeadpartList('BDHorseMaleManeFree', 'LONG,TIEDBACK,BOLD');
        LabelHeadpartList('BDHorseMaleManeSide02', 'LONG,TIEDBACK,MESSY');
        LabelHeadpartList('BDHorseMaleManeSide03', 'LONG,TIEDBACK,MESSY');  
        LabelHeadpartList('BDHairHorseMaleNord20', 'LONG,TIEDBACK,MESSY');
        LabelHeadpartList('BDHairHorseMaleNord17', 'MOHAWK,MESSY,BOLD');
        LabelHeadpartList('BDHairMaleOrc27', 'MOHAWK,MESSY,BOLD,FUNKY');
        LabelHeadpartList('BDHairHorseMaleOrc13', 'NEAT,TIEDBACK');

        // Female Hair
        //LabelHeadpartList('BDHairHorseFemNord04', ''); // Omitted--full head of hair
        //LabelHeadpartList('BDHairHorseFemOrc03', ''); // Omitted--full head of hair
        //LabelHeadpartList('BDHairHorseFemOrc08', ''); // Omitted--full head of hair
        LabelHeadpartList('BDHairHorseFemOrc14', 'SHORT,TIEDBACK,NEAT');
        LabelHeadpartList('BDHairHoseFemOrc17', 'SHORT,FUNKY,MOHAWK');
        LabelHeadpartList('BDHorseFemManeLong', 'LONG,TIEDBACK,ELABORATE');
        LabelHeadpartList('BDHorseFemManeShort', 'LONG,MESSY');
        LabelHeadpartList('BDHorseFemManeRoached', 'SHORT,NEAT,MILITARY');
        LabelHeadpartList('BDHorseFemManeSide01Fringe', 'LONG,MESSY');
        LabelHeadpartList('BDHorseFemManeSide01', 'LONG,MESSY');
        LabelHeadpartList('BDHorseFemManeMohawkFlip', 'MOHAWK,BOLD,FUNKY,YOUNG');
        LabelHeadpartList('BDHorseFemManeFringe', 'SHORT,YOUNG');
        LabelHeadpartList('BDHorseFemManeMohawk', 'MOHAWK,BOLD,FUNKY');
        LabelHeadpartList('BDHorseFemManeSide03', 'LONG,NEAT');
        LabelHeadpartList('BDHorseFemManeSide02', 'LONG,NEAT');
        LabelHeadpartList('BDHorseFemManeFree', 'LONG,BOLD');
        LabelHeadpartList('BDHorseFemManeSimple', 'LONG,MESSY,TIEDBACK');
        //LabelHeadpartList('BDHorseFemManeBase', ''); // Omitted--should have been a hairline
        LabelHeadpartList('BDHorseFemManeTied', 'NEAT,SHORT,BRAIDS,MILITARY,BOLD');

        // Horse Eyes
        // These are horse-style pupils. There are human-style pupils available.
        AssignHeadpart('MaleEyesHumanAmber', 'BDHorse0MaleEyesYellow');
        AssignHeadpart('MaleEyesHumanAmberBlindRight', 'BDHorse0MaleEyesYellow');
        AssignHeadpart('MaleEyesHumanBlind', 'BDHorseMaleEyesOrcBlind');
        AssignHeadpart('MaleEyesHumanBrightGreen', 'BDHorse0MaleEyesGreen');
        AssignHeadpart('MaleEyesHumanBrightGreenBlindRight', 'BDHorse0MaleEyesGreen');
        AssignHeadpart('MaleEyesHumanBrown', 'BDHorse0MaleEyesBrown');
        AssignHeadpart('MaleEyesHumanBrownBlindLeft', 'BDHorse0MaleEyesBrown');
        AssignHeadpart('MaleEyesHumanBrownBlindRight', 'BDHorse0MaleEyesBrown');
        AssignHeadpart('MaleEyesHumanBrownBloodShot', 'BDHorse0MaleEyesBrown');
        AssignHeadpart('MaleEyesHumanDarkBlue', 'BDHorse0MaleEyesBlue');
        AssignHeadpart('MaleEyesHumanDemon', 'BDHorseMaleEyesHumanDemon');
        AssignHeadpart('MaleEyesHumanGreenHazelLeft', 'BDHorse0MaleEyesGreen');
        AssignHeadpart('MaleEyesHumanGrey', 'BDHorse0MaleEyesBlue');
        AssignHeadpart('MaleEyesHumanHazel', 'BDHorse0MaleEyesRed');
        AssignHeadpart('MaleEyesHumanHazelBrown', 'BDHorse0MaleEyesYellow');
        AssignHeadpart('MaleEyesHumanIceBlue', 'BDHorse0MaleEyesIceBlue');
        AssignHeadpart('MaleEyesHumanLightBlue', 'BDHorse0MaleEyesIceBlue');
        AssignHeadpart('MaleEyesHumanLightBlueBlindLeft', 'BDHorse0MaleEyesRed');
        AssignHeadpart('MaleEyesHumanLightBlueBloodShot', 'BDHorse0MaleEyesRed');
        AssignHeadpart('MaleEyesHumanLightGrey', 'BDHorse0MaleEyesIceBlue');
        AssignHeadpart('MaleEyesHumanLightIceGreyBlindLeft', 'BDHorse0MaleEyesIceBlue');
        AssignHeadpart('MaleEyesHumanVampire', 'BDHorseMaleEyesVamp');

        AssignHeadpart('FemaleEyesHumanAmber', 'BDHorse0FemEyesYellow');
        AssignHeadpart('FemaleEyesHumanAmberBlindLeft', 'BDHorse0FemEyesYellow');
        AssignHeadpart('FemaleEyesHumanBlind', 'BDHorse0FemEyesRed');
        AssignHeadpart('FemaleEyesHumanBrightGreen', 'BDHorse0FemEyesGreen');
        AssignHeadpart('FemaleEyesHumanBrown', 'BDHorse0FemEyesBrown');
        AssignHeadpart('FemaleEyesHumanBrownBlindRight', 'BDHorse0FemEyesBrown');
        AssignHeadpart('FemaleEyesHumanBrownBloodShot', 'BDHorse0FemEyesRed');
        AssignHeadpart('FemaleEyesHumanDarkBlue', 'BDHorse0FemEyesBlue');
        AssignHeadpart('FemaleEyesHumanDarkBlueBlindRight', 'BDHorse0FemEyesBlue');
        AssignHeadpart('FemaleEyesHumanGreenHazel', 'BDHorse0FemEyesGreen');
        AssignHeadpart('FemaleEyesHumanGrey', 'BDHorse0FemEyesIceBlue');
        AssignHeadpart('FemaleEyesHumanGreyBlindLeft', 'BDHorse0FemEyesIceBlue');
        AssignHeadpart('FemaleEyesHumanHazel', 'BDHorse0FemEyesYellow');
        AssignHeadpart('FemaleEyesHumanHazelBrown', 'BDHorse0FemEyesRed');
        AssignHeadpart('FemaleEyesHumanIceBlue', 'BDHorse0FemEyesIceBlue');
        AssignHeadpart('FemaleEyesHumanLightBlue', 'BDHorse0FemEyesIceBlue');
        AssignHeadpart('FemaleEyesHumanLightBlueBloodShot', 'BDHorse0FemEyesBlue');
        AssignHeadpart('FemaleEyesHumanLightGrey', 'BDHorse0FemEyesIceBlue');
        AssignHeadpart('FemaleEyesHumanYellow', 'BDHorse0FemEyesYellow');
    END;


    { ================================== VANILLA ================================== }

    // Vanilla NPC equivalents
    NPCEquivalent('AstridEnd', 'Astrid');
    NPCEquivalent('BreyaCorpse', 'Breya');
    NPCEquivalent('C04DeadKodlak', 'Kodlak');
    NPCEquivalent('C06DeadKodlak', 'Kodlak');
    NPCEquivalent('MQ304Kodlak', 'Kodlak');
    NPCEquivalent('DA05SindingGhost', 'DA05Sinding');
    NPCEquivalent('DA05SindingHuman', 'DA05Sinding');
    NPCEquivalent('Thorek_Ambush', 'Thorek');
    NPCEquivalent('TovaDead', 'Tova');
    NPCEquivalent('MS11SusannaDeadA', 'Susanna');
    NPCEquivalent('MS11SusannaDeadA', 'Susanna');
    NPCEquivalent('CurweDead', 'Curwe');
    NPCEquivalent('DLC1MalkusDead', 'DLC1Malkus');
    NPCEquivalent('EltrysDead', 'Eltrys');
    NPCEquivalent('FestusKrexDead', 'FestusKrex');
    NPCEquivalent('GabriellaDead', 'Gabriella');
    NPCEquivalent('VantusLoreiusDead', 'VantusLoreius');
    NPCEquivalent('VeezaraDead', 'Veezara');
    NPCEquivalent('BreyaCorpse', 'Breya');
    NPCEquivalent('DLC1LD_KatriaCorpse', 'DLC1LD_Katria');
    NPCEquivalent('DLC1VQ01VigilantTolanCorpse', 'DLC1VigilantTolan');
    NPCEquivalent('DrennenCorpse', 'Drennen');
    NPCEquivalent('WatchesTheRootsCorpse', 'WatchesTheRoots');

    LabelVanillaHeadparts;
    InitLabelConflicts;
end;


procedure LabelVanillaHeadparts;
begin
    // Elder
    LabelHeadpartList('HairMaleElder1', 'SHORT,NEAT,BALDING,MATURE,MILITARY');
    LabelHeadpartList('HairMaleElder2', 'SHORT,NEAT,BALDING,MATURE,MILITARY');
    LabelHeadpartList('HairMaleElder3', 'SHORT,NEAT,BALDING,MATURE,MILITARY');
    LabelHeadpartList('HairMaleElder4', 'SHORT,BALDING,MATURE');
    LabelHeadpartList('HairMaleElder5', 'SHORT,NEAT,BALDING,MATURE,MILITARY');
    LabelHeadpartList('HairMaleElder6', 'LONG,NEAT,BALDING,MATURE,TIEDBACK');


    // IMPERIAL
    LabelHeadpartList('HairMaleImperial1', 'SHORT,NEAT,MILITARY');


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
    LabelHeadpartList('HairMaleRedguard8', 'MOHAWK,DREADS,  MESSY');

    LabelHeadpartList('HairFemaleRedguard01', 'TIEDBACK,NEAT');
    LabelHeadpartList('HairFemaleRedguard02', 'SHORT');
    LabelHeadpartList('HairFemaleRedguard03', 'BUZZ,MILITARY,SHORT,BOLD');
    LabelHeadpartList('HairFemaleRedguard04', 'BUZZ,MILITARY,SHORT,BOLD');
end;


{==================================================================
Set up label conflicts
}
procedure InitLabelConflicts;
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

end.