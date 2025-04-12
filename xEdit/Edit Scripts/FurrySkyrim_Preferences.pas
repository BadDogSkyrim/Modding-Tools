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
        SetRace('NordRace', 'BDLykaiosRace', 'DOG', 'KhajiitRace');
        SetRace('NordRaceVampire', 'BDLykaiosRaceVampire', 'DOG', 'KhajiitRace');
        SetRace('DLC1NordRace', 'BDLykaiosRace', 'DOG', 'KhajiitRace');
        SetRace('NordRaceAstrid', 'BDLykaiosRace', 'DOG', 'KhajiitRace');

        // Lykaios Hair
        LabelHeadpartList('BDCanMaleHairDreads001', 'DREADS,BOLD,FUNKY');
        // LabelHeadpart('BDLykMaleHairDreads002', 'DREADS'); // Dark version
        LabelHeadpartList('BDCanMaleHairDreads003', 'DREADS,NOBLE,BOLD,FUNKY');
        // LabelHeadpart('BDLykMaleHairDreads004', 'DREADS'); // Dark version
        LabelHeadpartList('BDCanMaleHairDreadsFringe', 'DREADS,NOBLE,BOLD,FUNKY,YOUNG');
        LabelHeadpartList('BDCanMaleHairDreadsHeadband', 'DREADS,NOBLE,BOLD,FUNKY,FEATHERS');
        LabelHeadpartList('BDCanMaleHairFringeFlip001', 'YOUNG,SHORT');
        LabelHeadpartList('BDCanMaleHairLionMane001', 'MANE,LONG');
        LabelHeadpartList('BDCanMaleHairLionMane002', 'MANE,LONG,YOUNG');
        LabelHeadpartList('BDCanMaleHairLionManebraids', 'MANE,LONG,NOBLE,BRAIDS');
        LabelHeadpartList('BDCanMaleHairLionManeFringeLeftBraid', 'MANE,LONG,NOBLE,BRAIDS');
        LabelHeadpartList('BDCanMaleHairLionManeHeadband', 'MANE,LONG,NOBLE,FEATHERS');
        LabelHeadpartList('BDCanMaleHairLongBraid001', 'BRAIDS,NEAT,TIEDBACK,BRAIDS,NEAT');
        LabelHeadpartList('BDCanMaleHairLongBraid002', 'TIEDBACK,BRAIDS,NOBLE');
        LabelHeadpartList('BDCanMaleHairLongBraidleft', 'NEAT,TIEDBACK,BRAIDS,NOBLE');
        LabelHeadpartList('BDCanMaleHairMohawk001', 'MOHAWK,BRAIDS,MILITARY,BOLD');
        LabelHeadpartList('BDCanMaleHairMohawk003', 'MOHAWK,FEATHERS,BOLD');
        LabelHeadpartList('BDCanMaleHairMohawkFringe', 'MOHAWK,YOUNG,BOLD');
        LabelHeadpartList('BDCanMaleHairShaggyHair002', 'LONG,MESSY');
        LabelHeadpartList('BDCanMaleHairShaggyHair003', 'LONG,MESSY,FEATHERS');
        LabelHeadpartList('BDCanMaleHairShorCrop001', 'SHORT,NEAT');
        LabelHeadpartList('BDCanMaleHairShorCrop002', 'SHORT,NEAT,YOUNG');
        LabelHeadpartList('BDCanMaleHairShorCrop003', 'SHORT,NEAT,NOBLE');
        LabelHeadpartList('BDCanMaleHairShorCrop004', 'SHORT,NEAT,NOBLE,FEATHERS');
        LabelHeadpartList('BDCanMaleHairTiedStyle001', 'LONG,NOBLE,NEAT');
        LabelHeadpartList('BDCanMaleHairTiedStyleFringe', 'LONG,NOBLE,NEAT,YOUNG');
        LabelHeadpartList('BDCanMaleHairTiedStyleHeadband', 'LONG,NOBLE,NEAT,YOUNG,FEATHERS');
        LabelHeadpartList('BDCanMaleHairVanillaBraid001', 'LONG,NEAT,TIEDBACK');
        LabelHeadpartList('BDCanMaleHairVanillaCrop001', 'SHORT,YOUNG,MILITARY');
        LabelHeadpartList('BDCanMaleHairVanillaHair001', 'MESSY,LONG');
        LabelHeadpartList('HairBeastSidehawk', 'MOHAWK,FUNKY,BOLD');

        LabelHeadpartList('BDCanFemHairBraid001', 'NEAT,TIEDBACK,LONG,BRAIDS');
        LabelHeadpartList('BDCanFemHairBraid002', 'NEAT,TIEDBACK,LONG,BRAIDS,NOBLE');
        LabelHeadpartList('BDCanFemHairDreads001', 'DREADS,BOLD,FUNKY');
        LabelHeadpartList('BDCanFemHairDreads002', 'DREADS,BOLD,FUNKY,NOBLE,ELABORATE');
        LabelHeadpartList('BDCanFemHairFringeFlip001', 'YOUNG,NEAT,SHORT');
        LabelHeadpartList('BDCanFemHairMane001', 'MANE,LONG,BOLD');
        LabelHeadpartList('BDCanFemHairMane002', 'MANE,LONG,BOLD');
        LabelHeadpartList('BDCanFemHairMane003', 'MANE,LONG,BOLD,NOBLE');
        LabelHeadpartList('BDCanFemHairMohawk001', 'MOHAWK,BOLD,FUNKY');
        LabelHeadpartList('BDCanFemHairMohawk002', 'MOHAWK,BOLD,FUNKY,FEATHERS');
        LabelHeadpartList('BDCanFemHairShaggy001', 'LONG,MESSY,LONG');
        LabelHeadpartList('BDCanFemHairShaggy002', 'MESSY,BRAIDS');
        LabelHeadpartList('BDCanFemHairShortCrop001', 'SHORT,NEAT,MILITARY');
        LabelHeadpartList('BDCanFemHairShortCrop002', 'SHORT,NEAT');
        LabelHeadpartList('BDCanFemHairShortCrop003', 'SHORT,NEAT,BRAIDS,NOBLE');
        LabelHeadpartList('BDCanFemHairTiedStyle001', 'LONG,NOBLE,ELABORATE');
        LabelHeadpartList('BDCanFemHairVanillaBraid001', 'TIEDBACK,BRAIDS');
        LabelHeadpartList('BDCanFemHairVanillaCrop001', 'SHORT,TIEDBACK');
        LabelHeadpartList('BDCanFemHairVanillaHair001', 'SHORT,BRAIDS,FUNKY');
        LabelHeadpartList('00LykaiosHairKhajiitFemale02', 'SHORT,TIEDBACK');
        LabelHeadpartList('00LykaiosHairKhajiitFemale03', 'SHORT,BRAIDS,FUNKY');

        // Lykaios Eyes

        AssignHeadpart('MaleEyesHumanAmber', 'BDCanMaleEyesAmber');
        AssignHeadpart('MaleEyesHumanAmberBlindRight', 'BDCanMaleEyesAlbino');
        AssignHeadpart('MaleEyesHumanBlind', 'BDCanMaleEyesAlbino');
        AssignHeadpart('MaleEyesHumanBrightGreen', 'BDCanMaleEyesGreen');
        AssignHeadpart('MaleEyesHumanBrightGreenBlindRight', 'BDCanMaleEyesGreen');
        AssignHeadpart('MaleEyesHumanBrown', 'BDCanMaleEyesBrown');
        AssignHeadpart('MaleEyesHumanBrownBlindLeft', 'BDCanMaleEyesAlbino');
        AssignHeadpart('MaleEyesHumanBrownBlindRight', 'BDCanMaleEyesAlbino');
        AssignHeadpart('MaleEyesHumanBrownBloodShot', 'BDCanMaleEyesBrown');
        AssignHeadpart('MaleEyesHumanDarkBlue', 'BDCanMaleEyesDarkBlue');
        AssignHeadpart('MaleEyesHumanDemon', 'BDCanMaleEyesRed');
        AssignHeadpart('MaleEyesHumanGreenHazelLeft', 'BDCanMaleEyesYellow');
        AssignHeadpart('MaleEyesHumanGrey', 'BDCanMaleEyesDarkGray');
        AssignHeadpart('MaleEyesHumanHazel', 'BDCanMaleEyesYellow');
        AssignHeadpart('MaleEyesHumanHazelBrown', 'BDCanMaleEyesYellow');
        AssignHeadpart('MaleEyesHumanIceBlue', 'BDCanMaleEyesBlue');
        AssignHeadpart('MaleEyesHumanLightBlue', 'BDCanMaleEyesSnow');
        AssignHeadpart('MaleEyesHumanLightBlueBlindLeft', 'BDCanMaleEyesAlbino');
        AssignHeadpart('MaleEyesHumanLightBlueBloodShot', 'BDCanMaleEyesSnow');
        AssignHeadpart('MaleEyesHumanLightGrey', 'BDCanMaleEyesGrey');
        AssignHeadpart('MaleEyesHumanLightIceGreyBlindLeft', 'BDCanMaleEyesLilac');
        AssignHeadpart('MaleEyesHumanVampire', 'BDCanMaleEyesVampire');

        // Lykaios tint layers
        SetTintLayerType('BDLykaiosRace', 'Lykaios\Male\Tints\Eyebrow.dds', TINT_BROW);
        SetTintLayerType('BDLykaiosRace', 'Lykaios\Male\Tints\EyebrowSpot.dds', TINT_BROW);
        SetTintLayerType('BDLykaiosRace', 'Lykaios\Male\Tints\Tintmasks\TintEar.dds', TINT_EAR);
        SetTintLayerType('BDLykaiosRace', 'Lykaios\Male\Tints\EyebrowSpot.dds', TINT_NOSE);
        SetTintLayerType('BDLykaiosRace', 'Lykaios_paint04.dds', TINT_NORD);
        SetTintLayerType('BDLykaiosRace', 'Lykaios_paint02.dds', TINT_NORD);
        SetTintLayerType('BDLykaiosRace', 'Lykaios_paint03.dds', TINT_NORD);
        SetTintLayerType('BDLykaiosRace', 'wolfpawprint.dds', TINT_HAND);
        SetTintLayerType('BDLykaiosRace', 'SkullPaint.dds', TINT_SKULL);
    END;


    { ================================== ELDER ================================== }
    BEGIN
        SetRace('ElderRace', 'BDLykaiosRace', 'DOG', 'KhajiitRace');
    end;

    { ================================== IMPERIAL ================================== }
    BEGIN
        // SetRace('ImperialRace', 'BDLykaiosRace', 'DOG', 'KhajiitRace');
        // SetRace('ImperialRaceVampire', 'BDLykaiosRaceVampire', 'DOG', 'KhajiitRace');
    end;

    { ================================== BRETON ================================== }
    BEGIN
        // SetRace('BretonRace', 'BDLykaiosRace', 'DOG', 'KhajiitRace');
        // SetRace('BretonRaceVampire', 'BDLykaiosRaceVampire', 'DOG', 'KhajiitRace');
    end;

    { ================================== REDGUARD ================================== }
    BEGIN
        // SetRace('RedguardRace', 'BDLykaiosRace', 'DOG', 'KhajiitRace');
        // SetRace('RedguardRaceVampire', 'BDLykaiosRaceVampire', 'DOG', 'KhajiitRace');
    end;

    { ================================== HIGH ELF ================================== }
    BEGIN
        SetRace('HighElfRace', 'BDSabrelionRace', 'CAT', 'KhajiitRace');
        SetRace('HighElfRaceVampire', 'BDSabrelionRaceVampire', 'CAT', 'KhajiitRaceVampire');
    end;

    { ================================== WOOD ELF ================================== }
    BEGIN

        SetRace('WoodElfRace', 'BDCheetahRace', 'CAT', 'KhajiitRace');
        SetRace('WoodElfRaceVampire', 'BDCheetahRaceVampire', 'CAT', 'KhajiitRaceVampire');
    end;

    { ================================== DARK ELF ================================== }
    BEGIN

        SetRace('DarkElfRace', 'BDPantherRace', 'CAT', 'KhajiitRace');
        SetRace('DarkElfRaceVampire', 'BDPantherRaceVampire', 'CAT', 'KhajiitRaceVampire');
    end;

    { ================================== ORC ================================== }
    BEGIN
        // SetRace('OrcRace', 'BDMinoRace', 'MINO', 'KhajiitRace');
        // SetRace('OrcRaceVampire', 'BDMinoRaceVampire', 'MINO', 'KhajiitRaceVampire');

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


    { ================================== ORC ================================== }
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
    NPCAlias('AmaundMotierre', 'AmaundMotierreEnd');
    NPCAlias('Astrid', 'AstridEnd');
    NPCAlias('Breya', 'BreyaCorpse');
    NPCAlias('Breya', 'BreyaCorpse');
    NPCAlias('Cicero', 'CiceroDawnstar');
    NPCAlias('Cicero', 'CiceroRoad');
    NPCAlias('Curwe', 'CurweDead');
    NPCAlias('DA01MalynVaren', 'DA01MalynVarenCorpse');
    NPCAlias('DA05Sinding', 'DA05SindingGhost');
    NPCAlias('DA05Sinding', 'DA05SindingHuman');
    NPCAlias('DBLis', 'DBLisDead');
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
    NPCAlias('Susanna', 'MS11SusannaDeadA');
    NPCAlias('Thorek', 'Thorek_Ambush');
    NPCAlias('Thorek', 'Thorek_Ambush');
    NPCAlias('TitusMedeII', 'TitusMedeIIDecoy');
    NPCAlias('Tova', 'TovaDead');
    NPCAlias('Ulfric', 'CWBattleUlfric');
    NPCAlias('Ulfric', 'MQ304Ulfric');
    NPCAlias('VantusLoreius', 'VantusLoreiusDead');
    NPCAlias('VantusLoreius', 'VantusLoreiusDead');
    NPCAlias('Veezara', 'VeezaraDead');
    NPCAlias('VerenDuleri', 'VerenDuleri_Ambush');
    NPCAlias('WatchesTheRoots', 'WatchesTheRootsCorpse');
    NPCAlias('WEDL04PlautisCarvain', 'WEDL03PlautisCarvain');
    NPCAlias('WEDL04SaloniaCarvain', 'WEDL03SaloniaCarvain');
    NPCAlias('DLC1Harkon', 'DLC1HarkonCombat');
    NPCAlias('DLC1LD_Katria', 'DLC1LD_KatriaCorpse');
    NPCAlias('DLC1Malkus', 'DLC1MalkusDead');
    NPCAlias('DLC1VigilantTolan', 'DLC1VQ01VigilantTolanCorpse');
    NPCAlias('DLC2Miraak', 'DLC2MiraakMQ01');
    NPCAlias('DLC2Miraak', 'DLC2MiraakMQ06');
    NPCAlias('DLC2RRLygrleidSolstheim', 'DLC2RRLygrleidWindhelm');
    NPCAlias('DLC2RRSogrlafSolstheim', 'DLC2RRSogrlafWindhelm');

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