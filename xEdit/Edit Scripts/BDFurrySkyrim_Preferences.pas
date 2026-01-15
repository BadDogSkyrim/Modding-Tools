{
}
unit BDFurrySkyrim_Preferences;

interface
implementation
uses BDFurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;


Procedure SetPreferences;
begin
    DefineFurryRaces;

    BEGIN // ============ NORD ============
        SetRace('NordRace', 'YASLykaiosRace', 'DOG', 'KhajiitRace');
        SetRace('NordRaceVampire', 'YASLykaiosRaceVampire', 'DOG', 'KhajiitRace');
        SetRace('NordRaceChild', 'YASLykaiosRaceChild', 'DOG', 'KhajiitRace');
        SetRace('DLC1NordRace', 'YASLykaiosRace', 'DOG', 'KhajiitRace');
        SetRace('NordRaceAstrid', 'YASLykaiosRace', 'DOG', 'KhajiitRace');
    END;

    BEGIN // =========== ELDER  ===========
        SetRace('ElderRace', 'YASLykaiosRace', 'DOG', 'KhajiitRace');
        SetRace('ElderRaceVampire', 'YASLykaiosRaceVampire', 'DOG', 'KhajiitRace');
    end;

    BEGIN // =========== IMPERIAL ============
        SetRace('ImperialRace', 'YASVaalsarkRace', 'DOG', 'KhajiitRace');
        SetRace('ImperialRaceChild', 'YASVaalsarkRaceChild', 'DOG', 'KhajiitRace');
        SetRace('ImperialRaceVampire', 'YASVaalsarkRaceVampire', 'DOG', 'KhajiitRace');
    end;

    BEGIN // =========== BRETON  ===========
        SetRace('BretonRace', 'YASKettuRace', 'DOG', 'KhajiitRace');
        SetRace('BretonRaceChild', 'YASKettuRaceChild', 'DOG', 'KhajiitRace');
        SetRace('BretonRaceVampire', 'YASKettuRaceVampire', 'DOG', 'KhajiitRace');
        SetRace('BretonRaceChildVampire', 'YASKettuRaceChildVampire', 'DOG', 'KhajiitRace');
    end;

    BEGIN // =========== REDGUARD ============
        SetRace('RedguardRace', 'YASKygarraRace', 'DOG', 'KhajiitRace');
        SetRace('RedguardRaceChild', 'YASKygarraRaceChild', 'DOG', 'KhajiitRace');
        SetRace('RedguardRaceVampire', 'YASKygarraRaceVampire', 'DOG', 'KhajiitRace');
    end;

    BEGIN // =========== REACHMAN ============
        SetSubrace('YASReachmanRace', 'Reachmen', 'BretonRace', 'YASKonoiRace', 'DOG', 'KhajiitRace');
        SetSubrace('YASReachmanRaceVampire', 'Reachmen', 'BretonRaceVampire', 'YASKonoiRaceVampire', 'DOG', 'KhajiitRace');
        SetSubrace('YASReachmanRaceChild', 'Reachmen', 'BretonRaceChild', 'YASKonoiRaceChild', 'DOG', 'KhajiitRace');
        SetFactionRace('ForswornFaction', 'YASReachmanRace');
        SetFactionRace('MS01TreasuryHouseForsworn', 'YASReachmanRace');
        SetFactionRace('DruadachRedoubtFaction', 'YASReachmanRace');
        SetTattooRace('ForswornTattoo', 'YASReachmanRace');
    end;

    BEGIN // ========== SKAAL ============
        SetSubrace('YASSkaalRace', 'Skaal', 'NordRace', 'YASXebaRace', 'DOG', 'KhajiitRace');
        SetSubrace('YASSkaalRaceChild', 'Skaal', 'NordRaceChild', 'YASXebaRaceChild', 'DOG', 'KhajiitRace');
        SetSubrace('YASSkaalRaceVampire', 'Skaal', 'NordRaceVampire', 'YASXebaRaceVampire', 'DOG', 'KhajiitRace');
        SetFactionRace('DLC2SkaalVillageCitizenFaction', 'YASSkaalRace');
    end;

    { ================================== ARGONIAN ================================ }

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

    { ================================== ORC (Sabrelion) ============================= }
    BEGIN
        SetRace('OrcRace', 'BDTigerRace', 'CAT', 'KhajiitRace');
        SetRace('OrcRaceVampire', 'BDTigerRaceVampire', 'CAT', 'KhajiitRaceVampire');
    end;

    BEGIN // ========== WINTERHOLD ============
        SetSubrace('YASWinterholdRace', 'Winterhold', 'NordRace', 'BDSnowLeopardRace', 'CAT', 'KhajiitRace');
        SetFactionRace('TownWinterholdFaction', 'YASWinterholdRace');
    end;

    { ================================== ORC (MINO) ============================= }
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

    VanillaSettings;
    AssignNPCRaces;
end;


procedure DefineFurryRaces;
begin
    begin // LYKAIOS
        // Lykaios tint layers
        SetTintLayerClass('YASLykaiosRace', 'Lykaios_paint02.dds', 'WarpaintNord');
        SetTintLayerClass('YASLykaiosRace', 'Lykaios_paint03.dds', 'WarpaintNord');
        SetTintLayerClass('YASLykaiosRace', 'Lykaios_paint04.dds', 'WarpaintNord');
        SetTintLayerClass('YASLykaiosRace', 'YAS\Lykaios\Male\Tints\Eyebrow.dds', 'Brow');
        SetTintLayerClass('YASLykaiosRace', 'YAS\Lykaios\Male\Tints\EyebrowSpot.dds', 'Brow');
        SetTintLayerClass('YASLykaiosRace', 'YAS\Lykaios\Male\Tints\EyebrowSpot.dds', 'Brow');
        SetTintLayerClass('YASLykaiosRace', 'YAS\Lykaios\Male\Tints\Tintmasks\TintEar.dds', 'Ear');
        SetTintLayerClass('YASLykaiosRace', 'SkullPaint.dds', 'WarpaintSkull');
        SetTintLayerClass('YASLykaiosRace', 'wolfpawprint.dds', 'WarpaintHand');
    end;

    begin // KETTU
        SetTintLayerRequired('KettuCheek', TRUE);
        SetTintLayerClass('YASKettuRace', 'YAS\Dog\Tints\FemFoxMask01Tint.dds', 'KettuCheek');
        SetTintLayerClass('YASKettuRace', 'YAS\Dog\Tints\FemFoxMask02Tint.dds', 'KettuCheek');
        SetTintLayerClass('YASKettuRace', 'YAS\Dog\Tints\FemFoxMask03Tint.dds', 'KettuCheek');
        SetTintLayerClass('YASKettuRace', 'YAS\Dog\Tints\FemFoxMask04Tint.dds', 'KettuCheek');
        SetTintLayerClass('YASKettuRace', 'YAS\Kettu\Male\tints\FoxMask00.dds', 'KettuCheek');
        SetTintLayerClass('YASKettuRace', 'YAS\Kettu\Male\tints\FoxMask01.dds', 'KettuCheek');
        SetTintLayerClass('YASKettuRace', 'YAS\Kettu\Male\tints\FoxMask02.dds', 'KettuCheek');
    end;

    begin // KONOI
        SetTintLayerRequired('KonoiMuzzle', TRUE);
        SetTintLayerRequired('KonoiStripes', TRUE);
        SetTintLayerClass('YASKonoiRace', 'YAS\Konoi\Male\Tints\Stripes01.dds', 'KonoiStripes');
        SetTintLayerClass('YASKonoiRace', 'YAS\Konoi\Male\Tints\Stripes02.dds', 'KonoiStripes');
        SetTintLayerClass('YASKonoiRace', 'YAS\Konoi\Male\Tints\Stripes03.dds', 'KonoiStripes');
        SetTintLayerClass('YASKonoiRace', 'YAS\Konoi\Male\Tints\Stripes04.dds', 'KonoiStripes');
        SetTintLayerClass('YASKonoiRace', 'YAS\Kygarra\Male\Tints\Muzzle01.dds', 'KonoiMuzzle');
        SetTintLayerClass('YASKonoiRace', 'YAS\Kygarra\Male\Tints\Muzzle02.dds', 'KonoiMuzzle');
        SetTintLayerClass('YASKonoiRace', 'YAS\Kygarra\Male\Tints\Muzzle03.dds', 'KonoiMuzzle');
    end;

    begin // KYGARRA
        SetTintLayerRequired('KygarraSpots', TRUE);
        SetTintLayerClass('YASKygarraRace', 'YAS\Kygarra\Male\Tints\Spots01.dds', 'KygarraSpots');
        SetTintLayerClass('YASKygarraRace', 'YAS\Kygarra\Male\Tints\Spots02.dds', 'KygarraSpots');
        SetTintLayerClass('YASKygarraRace', 'YAS\Kygarra\Male\Tints\Spots03.dds', 'KygarraSpots');
        SetTintLayerClass('YASKygarraRace', 'YAS\Kygarra\Male\Tints\Spots04.dds', 'KygarraSpots');
    end;
end;


procedure VanillaSettings;
begin
    begin // Descriptions of furry hair styles
        LabelHeadpartList('YASDogMaleHairDreads001', 'DREADS,BOLD,FUNKY,LONG');
        // LabelHeadpart('BDLykMaleHairDreads002', 'DREADS'); // Dark version
        LabelHeadpartList('YASDogMaleHairDreads003', 'DREADS,NOBLE,BOLD,FUNKY,LONG');
        // LabelHeadpart('BDLykMaleHairDreads004', 'DREADS'); // Dark version
        LabelHeadpartList('YASDogMaleHairDreadsFringe', 'DREADS,NOBLE,BOLD,FUNKY,YOUNG,LONG');
        LabelHeadpartList('YASDogMaleHairDreadsHeadband', 'DREADS,NOBLE,BOLD,FUNKY,FEATHERS,LONG');
        LabelHeadpartList('YASDogMaleHairFringeFlip001', 'YOUNG,SHORT');
        LabelHeadpartList('YASDogMaleHairLionMane001', 'MANE,LONG');
        LabelHeadpartList('YASDogMaleHairLionMane002', 'MANE,LONG,YOUNG');
        LabelHeadpartList('YASDogMaleHairLionManebraids', 'MANE,LONG,NOBLE,BRAIDS');
        LabelHeadpartList('YASDogMaleHairLionManeFringeLeftBraid', 'MANE,LONG,NOBLE,BRAIDS');
        LabelHeadpartList('YASDogMaleHairLionManeHeadband', 'MANE,LONG,NOBLE,FEATHERS');
        LabelHeadpartList('YASDogMaleHairLongBraid001', 'BRAIDS,NEAT,TIEDBACK');
        LabelHeadpartList('YASDogMaleHairLongBraid002', 'TIEDBACK,BRAIDS,NOBLE');
        LabelHeadpartList('YASDogMaleHairLongBraidleft', 'NEAT,TIEDBACK,BRAIDS,NOBLE');
        LabelHeadpartList('YASDogMaleHairMohawk001', 'MOHAWK,BRAIDS,MILITARY,BOLD,FANCY');
        LabelHeadpartList('YASDogMaleHairMohawk003', 'MOHAWK,FEATHERS,BOLD');
        LabelHeadpartList('YASDogMaleHairMohawkFringe', 'MOHAWK,YOUNG,BOLD');
        LabelHeadpartList('YASDogMaleHairShaggyHair002', 'LONG,MESSY');
        LabelHeadpartList('YASDogMaleHairShaggyHair003', 'LONG,MESSY,FEATHERS');
        LabelHeadpartList('YASDogMaleHairShorCrop001', 'SHORT,NEAT');
        LabelHeadpartList('YASDogMaleHairShorCrop002', 'SHORT,NEAT,YOUNG');
        LabelHeadpartList('YASDogMaleHairShorCrop003', 'SHORT,NEAT,NOBLE');
        LabelHeadpartList('YASDogMaleHairShorCrop004', 'SHORT,NEAT,NOBLE,FEATHERS');
        LabelHeadpartList('YASDogMaleHairTiedStyle001', 'LONG,NOBLE,NEAT');
        LabelHeadpartList('YASDogMaleHairTiedStyleFringe', 'LONG,NOBLE,NEAT,YOUNG');
        LabelHeadpartList('YASDogMaleHairTiedStyleHeadband', 'LONG,NOBLE,NEAT,YOUNG,FEATHERS');
        LabelHeadpartList('YASDogMaleHairVanillaBraid001', 'LONG,NEAT,TIEDBACK');
        LabelHeadpartList('YASDogMaleHairVanillaHair001', 'MESSY,LONG');
        LabelHeadpartList('YASDogMaleHairSidehawk', 'MOHAWK,FUNKY,BOLD');

        LabelHeadpartList('YASDogFemHair01', 'NEAT,TIEDBACK,SHORT,BRAIDS');
        LabelHeadpartList('YASDogFemHair02', 'NEAT,TIEDBACK');
        LabelHeadpartList('YASDogFemHair03', 'NEAT,SHORT');
        LabelHeadpartList('YASDogFemHair04', 'NEAT,LONG,TIEDBACK,BRAIDS');
        LabelHeadpartList('YASDogFemHair05', 'SHORT,TIEDBACK,FUNKY');
        LabelHeadpartList('YASDogFemHair06', 'SHORT,TIEDBACK,FUNKY');
        LabelHeadpartList('YASDogFemHair07', 'SHORT,TIEDBACK,FUNKY,BRAIDS');
        LabelHeadpartList('YASDogFemHair08', 'NEAT,LONG,TIEDBACK,BRAIDS,FUNKY');
        LabelHeadpartList('YASDogFemHair09', 'NEAT,TIEDBACK,SHORT,BRAIDS');
        LabelHeadpartList('YASDogFemHair10', 'NEAT,TIEDBACK');
        LabelHeadpartList('YASDogFemHairBraid001', 'NEAT,TIEDBACK,LONG,BRAIDS');
        LabelHeadpartList('YASDogFemHairBraid002', 'NEAT,TIEDBACK,LONG,BRAIDS,NOBLE');
        LabelHeadpartList('YASDogFemHairDreads001', 'DREADS,BOLD,FUNKY,LONG');
        LabelHeadpartList('YASDogFemHairDreads002', 'DREADS,BOLD,FUNKY,NOBLE,ELABORATE,LONG');
        LabelHeadpartList('YASDogFemHairDreads003', 'DREADS,BOLD,FUNKY,LONG');
        LabelHeadpartList('YASDogFemHairDreads004', 'DREADS,BOLD,FUNKY,NOBLE,ELABORATE,LONG');
        LabelHeadpartList('YASDogFemHairFringeFlip001', 'YOUNG,NEAT,SHORT');
        LabelHeadpartList('YASDogFemHairMane001', 'MANE,LONG,BOLD');
        LabelHeadpartList('YASDogFemHairMane002', 'MANE,LONG,BOLD');
        LabelHeadpartList('YASDogFemHairMane003', 'MANE,LONG,BOLD,NOBLE');
        LabelHeadpartList('YASDogFemHairMohawk001', 'MOHAWK,BOLD,FUNKY');
        LabelHeadpartList('YASDogFemHairMohawk002', 'MOHAWK,BOLD,FUNKY,FEATHERS');
        LabelHeadpartList('YASDogFemHairShaggy001', 'LONG,MESSY,LONG');
        LabelHeadpartList('YASDogFemHairShaggy002', 'MESSY,BRAIDS');
        LabelHeadpartList('YASDogFemHairShortCrop001', 'SHORT,NEAT,MILITARY');
        LabelHeadpartList('YASDogFemHairShortCrop002', 'SHORT,NEAT');
        LabelHeadpartList('YASDogFemHairShortCrop003', 'SHORT,NEAT,BRAIDS,NOBLE');
        LabelHeadpartList('YASDogFemHairTiedStyle001', 'LONG,NOBLE,ELABORATE');
        LabelHeadpartList('YASDogFemHairVanillaBraid001', 'TIEDBACK,BRAIDS');
        LabelHeadpartList('YASDogFemHairVanillaCrop001', 'SHORT,TIEDBACK');
        LabelHeadpartList('YASDogFemHairVanillaHair001', 'SHORT,BRAIDS,FUNKY');
        LabelHeadpartList('YASFemHairApachii01', 'NEAT,YOUNG,BRAIDS');
        LabelHeadpartList('YASFemHairApachii02', 'DREADS,LONG,BOLD,FUNKY');
        LabelHeadpartList('YASFemHairApachii03', 'NEAT,SHORT');
        LabelHeadpartList('YASFemHairApachii04', 'MESSY,LONG');
        LabelHeadpartList('YASFemHairApachii05', 'MESSY,LONG');
    end;

    begin // Descriptions of vanilla hair styles
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

    begin // Common eye correspondences human <-> furry
        AssignHeadpart('MaleEyesHumanAmber', 'YASDayPredMaleEyesAmber');
        AssignHeadpart('MaleEyesHumanAmberBlindRight', 'YASDayPredMaleEyesAlbino');
        AssignHeadpart('MaleEyesHumanBlind', 'YASDayPredMaleEyesBlind');
        AssignHeadpart('MaleEyesHumanBrightGreen', 'YASDayPredMaleEyesGreen');
        AssignHeadpart('MaleEyesHumanBrightGreenBlindRight', 'YASDayPredMaleEyesGreen');
        AssignHeadpart('MaleEyesHumanBrown', 'YASDayPredMaleEyesBrownDark');
        AssignHeadpart('MaleEyesHumanBrownBlindLeft', 'YASDayPredMaleEyesAmberBlindL');
        AssignHeadpart('MaleEyesHumanBrownBlindRight', 'YASDayPredMaleEyesAmberBlindR');
        AssignHeadpart('MaleEyesHumanBrownBloodShot', 'YASDayPredMaleEyesBrownDark');
        AssignHeadpart('MaleEyesHumanDarkBlue', 'YASDayPredMaleEyesBlueDark');
        AssignHeadpart('MaleEyesHumanDemon', 'YASDayPredMaleEyesRed');
        AssignHeadpart('MaleEyesHumanGreenHazelLeft', 'YASDayPredMaleEyesMixBlueBrown');
        AssignHeadpart('MaleEyesHumanGrey', 'YASDayPredMaleEyesGrey');
        AssignHeadpart('MaleEyesHumanHazel', 'YASDayPredMaleEyesYellow');
        AssignHeadpart('MaleEyesHumanHazelBrown', 'YASDayPredMaleEyesMixYellowGreen');
        AssignHeadpart('MaleEyesHumanIceBlue', 'YASDayPredMaleEyesBlue');
        AssignHeadpart('MaleEyesHumanLightBlue', 'YASDayPredMaleEyesSnow');
        AssignHeadpart('MaleEyesHumanLightBlueBlindLeft', 'YASDayPredMaleEyesBlueGreyBlindL');
        AssignHeadpart('MaleEyesHumanLightBlueBloodShot', 'YASDayPredMaleEyesSnow');
        AssignHeadpart('MaleEyesHumanLightGrey', 'YASDayPredMaleEyesGrey');
        AssignHeadpart('MaleEyesHumanLightIceGreyBlindLeft', 'YASDayPredMaleEyesGreenBlindL');
        AssignHeadpart('MaleEyesHumanVampire', 'YASDayPredMaleEyesVampire');

        AssignHeadPart('FemaleEyesDarkElfBlind', 'YASDayPredFemEyesBlind');
        AssignHeadPart('FemaleEyesDarkElfDeepRed', 'YASNightPredFemEyesRed');
        AssignHeadPart('FemaleEyesDarkElfDeepRed2', 'YASNightPredFemEyesGreen');
        AssignHeadPart('FemaleEyesDarkElfDeepRed2BlindRight', 'YASNightPredFemEyesAmberBlindR');
        AssignHeadPart('FemaleEyesDarkElfDeepRedBlindLeft', 'YASDayPredFemEyesAmberBlindL');
        AssignHeadPart('FemaleEyesDarkElfRed', 'YASNightPredFemEyesRed');
        AssignHeadPart('FemaleEyesDarkElfUnique', 'YASNightPredFemEyesGreen');
        AssignHeadPart('FemaleEyesDremora', 'YASNIghtPredFemEyesOrangeNarrow');
        AssignHeadPart('FemaleEyesElfBlind', 'YASDayPredFemEyesBlind');
        AssignHeadPart('FemaleEyesHighElfDarkYellow', 'YASDayPredFemEyesGold');
        AssignHeadPart('FemaleEyesHighElfOrange', 'YASDayPredFemEyesGold');
        AssignHeadPart('FemaleEyesHighElfOrangeBlindRight', 'YASDayPredFemEyesGreenBlindR');
        AssignHeadPart('FemaleEyesHighElfYellow', 'YASDayPredFemEyesYellow');
        AssignHeadPart('FemaleEyesHighElfYellowBlindLeft', 'YASDayPredFemEyesAmberBlindL');
        AssignHeadPart('FemaleEyesHumanAmber', 'YASDayPredFemEyesAmber');
        AssignHeadPart('FemaleEyesHumanAmberBlindLeft', 'YASDayPredFemEyesBlueBlindL');
        AssignHeadPart('FemaleEyesHumanBlind', 'YASDayPredFemEyesBlind');
        AssignHeadPart('FemaleEyesHumanBrightGreen', 'YASDayPredFemEyesGreen');
        AssignHeadPart('FemaleEyesHumanBrown', 'YASDayPredFemEyesBrownDark');
        AssignHeadPart('FemaleEyesHumanBrownBlindRight', 'YASDayPredMaleEyesAmberBlindR');
        AssignHeadPart('FemaleEyesHumanBrownBloodShot', 'YASDayPredFemEyesRed');
        AssignHeadPart('FemaleEyesHumanDarkBlue', 'YASDayPredFemEyesBlue');
        AssignHeadPart('FemaleEyesHumanDarkBlueBlindRight', 'YASDayPredFemEyesGreenBlindR');
        AssignHeadPart('FemaleEyesHumanDemon', 'YASNightPredFemEyesRedNarrow');
        AssignHeadPart('FemaleEyesHumanGreenHazel', 'YASDayPredFemEyesGreen');
        AssignHeadPart('FemaleEyesHumanGrey', 'YASDayPredFemEyesLilac');
        AssignHeadPart('FemaleEyesHumanGreyBlindLeft', 'YASDayPredFemEyesGreenBlindL');
        AssignHeadPart('FemaleEyesHumanHazel', 'YASDayPredFemEyesAmber');
        AssignHeadPart('FemaleEyesHumanHazelBrown', 'YASDayPredFemEyesAmber');
        AssignHeadPart('FemaleEyesHumanIceBlue', 'YASDayPredFemEyesAlbino');
        AssignHeadPart('FemaleEyesHumanLightBlue', 'YASDayPredFemEyesBlueDark');
        AssignHeadPart('FemaleEyesHumanLightBlueBloodShot', 'YASDayPredFemEyesRed');
        AssignHeadPart('FemaleEyesHumanLightGrey', 'YASDayPredFemEyesAlbino');
        AssignHeadPart('FemaleEyesHumanVampire', 'YASDayPredFemEyesVampire');
        AssignHeadPart('FemaleEyesHumanYellow', 'YASDayPredFemEyesYellow');
        AssignHeadPart('FemaleEyesOrcBlind', 'YASDayPredFemEyesBlind');
        AssignHeadPart('FemaleEyesOrcDarkGrey', 'YASDayPredFemEyesAlbino');
        AssignHeadPart('FemaleEyesOrcIceBlue', 'YASDayPredFemEyesBlueDark');
        AssignHeadPart('FemaleEyesOrcIceBlueBlindRight', 'YASDayPredFemEyesGreenBlindR');
        AssignHeadPart('FemaleEyesOrcRed', 'YASDayPredFemEyesBlind');
        AssignHeadPart('FemaleEyesOrcRedBlindRight', 'YASDayPredFemEyesRedBlindR');
        AssignHeadPart('FemaleEyesOrcVampire', 'YASDayPredFemEyesVampire');
        AssignHeadPart('FemaleEyesOrcYellow', 'YASDayPredFemEyesYellow');
        AssignHeadPart('FemaleEyesOrcYellowBlindLeft', 'YASNightPredFemEyesYellowBlindLeft');
        AssignHeadPart('FemaleEyesWoodElfBlind', 'YASDayPredFemEyesBlind');
        AssignHeadPart('FemaleEyesWoodElfBrown', 'YASNightPredFemEyesBrown');
        AssignHeadPart('FemaleEyesWoodElfDeepBrown', 'YASNightPredFemEyesBrownDark');
        AssignHeadPart('FemaleEyesWoodElfDeepBrownBlindLeft', 'YASNightPredFemEyesYellowBlindLeft');
        AssignHeadPart('FemaleEyesWoodElfDeepViolet', 'YASNIghtPredFemEyesIce');
        AssignHeadPart('FemaleEyesWoodElfDeepVioletBlindRight', 'YASNightPredFemEyesYellowBlindR');
        AssignHeadPart('FemaleEyesWoodElfLightBrown', 'YASNIghtPredFemEyesAmberNarrow');

    end;

    begin // Scars and facial markings
        AssignHeadPart('MarksFemaleHumanoid01LeftGash', 'YASKettuFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid01LeftGash', 'YASKonoiFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid01LeftGash', 'YASKygarraFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid01LeftGash', 'YASLykaiosFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid01LeftGash', 'YASVaalsarkFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid01LeftGash', 'YASXebaFemScarL01');

        AssignHeadPart('MarksFemaleHumanoid02LeftGash', 'YASKettuFemScarL02');
        AssignHeadPart('MarksFemaleHumanoid02LeftGash', 'YASKonoiFemScarL02');
        AssignHeadPart('MarksFemaleHumanoid02LeftGash', 'YASKygarraFemScarL02');
        AssignHeadPart('MarksFemaleHumanoid02LeftGash', 'YASLykaiosFemScarL02');
        AssignHeadPart('MarksFemaleHumanoid02LeftGash', 'YASVaalsarkFemScarL02');
        AssignHeadPart('MarksFemaleHumanoid02LeftGash', 'YASXebaFemScarL02');

        AssignHeadPart('MarksFemaleHumanoid03LeftGash', 'YASKettuFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid03LeftGash', 'YASKonoiFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid03LeftGash', 'YASKygarraFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid03LeftGash', 'YASLykaiosFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid03LeftGash', 'YASVaalsarkFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid03LeftGash', 'YASXebaFemScarL03');

        AssignHeadPart('MarksFemaleHumanoid04LeftGash', 'YASKettuFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid04LeftGash', 'YASKonoiFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid04LeftGash', 'YASKygarraFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid04LeftGash', 'YASLykaiosFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid04LeftGash', 'YASVaalsarkFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid04LeftGash', 'YASXebaFemScarL04');

        AssignHeadPart('MarksFemaleHumanoid05LeftGash', 'YASKettuFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid05LeftGash', 'YASKonoiFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid05LeftGash', 'YASKygarraFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid05LeftGash', 'YASLykaiosFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid05LeftGash', 'YASVaalsarkFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid05LeftGash', 'YASXebaFemScarC01');

        AssignHeadPart('MarksFemaleHumanoid06LeftGash', 'YASKettuFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid06LeftGash', 'YASKonoiFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid06LeftGash', 'YASKygarraFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid06LeftGash', 'YASLykaiosFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid06LeftGash', 'YASVaalsarkFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid06LeftGash', 'YASXebaFemScarC02');

        AssignHeadPart('MarksFemaleHumanoid07RightGash', 'YASKettuFemScarR01');
        AssignHeadPart('MarksFemaleHumanoid07RightGash', 'YASKonoiFemScarR01');
        AssignHeadPart('MarksFemaleHumanoid07RightGash', 'YASKygarraFemScarR01');
        AssignHeadPart('MarksFemaleHumanoid07RightGash', 'YASLykaiosFemScarR01');
        AssignHeadPart('MarksFemaleHumanoid07RightGash', 'YASVaalsarkFemScarR01');
        AssignHeadPart('MarksFemaleHumanoid07RightGash', 'YASXebaFemScarR01');

        AssignHeadPart('MarksFemaleHumanoid08RightGash', 'YASKettuFemScarR02');
        AssignHeadPart('MarksFemaleHumanoid08RightGash', 'YASKonoiFemScarR02');
        AssignHeadPart('MarksFemaleHumanoid08RightGash', 'YASKygarraFemScarR02');
        AssignHeadPart('MarksFemaleHumanoid08RightGash', 'YASLykaiosFemScarR02');
        AssignHeadPart('MarksFemaleHumanoid08RightGash', 'YASVaalsarkFemScarR02');
        AssignHeadPart('MarksFemaleHumanoid08RightGash', 'YASXebaFemScarR02');

        AssignHeadPart('MarksFemaleHumanoid09RightGash', 'YASKettuFemScarR03');
        AssignHeadPart('MarksFemaleHumanoid09RightGash', 'YASKonoiFemScarR03');
        AssignHeadPart('MarksFemaleHumanoid09RightGash', 'YASKygarraFemScarR03');
        AssignHeadPart('MarksFemaleHumanoid09RightGash', 'YASLykaiosFemScarR03');
        AssignHeadPart('MarksFemaleHumanoid09RightGash', 'YASVaalsarkFemScarR03');
        AssignHeadPart('MarksFemaleHumanoid09RightGash', 'YASXebaFemScarR03');

        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASKettuFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASKonoiFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASKygarraFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASLykaiosFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASVaalsarkFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASXebaFemScarL03');

        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASKettuFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASKonoiFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASKygarraFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASLykaiosFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASVaalsarkFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASXebaFemScarL04');

        AssignHeadPart('MarksFemaleHumanoid10RightGashR', 'YASKettuFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid10RightGashR', 'YASKonoiFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid10RightGashR', 'YASKygarraFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid10RightGashR', 'YASLykaiosFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid10RightGashR', 'YASVaalsarkFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid10RightGashR', 'YASXebaFemScarC01');

        AssignHeadPart('MarksFemaleHumanoid11LeftGash', 'YASKettuFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGash', 'YASKonoiFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGash', 'YASKygarraFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGash', 'YASLykaiosFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGash', 'YASVaalsarkFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGash', 'YASXebaFemScarL01');

        AssignHeadPart('MarksFemaleHumanoid11LeftGashR', 'YASKettuFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid11LeftGashR', 'YASKonoiFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid11LeftGashR', 'YASKygarraFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid11LeftGashR', 'YASLykaiosFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid11LeftGashR', 'YASVaalsarkFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid11LeftGashR', 'YASXebaFemScarC02');

        AssignHeadPart('MarksFemaleHumanoid12LeftGash', 'YASKettuFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid12LeftGash', 'YASKonoiFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid12LeftGash', 'YASKygarraFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid12LeftGash', 'YASLykaiosFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid12LeftGash', 'YASVaalsarkFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid12LeftGash', 'YASXebaFemScarL03');

        AssignHeadPart('MarksFemaleHumanoid12LeftGashR', 'YASKettuFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid12LeftGashR', 'YASKonoiFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid12LeftGashR', 'YASKygarraFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid12LeftGashR', 'YASLykaiosFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid12LeftGashR', 'YASVaalsarkFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid12LeftGashR', 'YASXebaFemScarC02');

        AssignHeadPart('MarksMaleHumanoid01LeftGash', 'YASKettuMaleScarL01');
        AssignHeadPart('MarksMaleHumanoid01LeftGash', 'YASKygarraMaleScarL01');
        AssignHeadPart('MarksMaleHumanoid01LeftGash', 'YASLykMaleScarL06');
        AssignHeadPart('MarksMaleHumanoid01LeftGash', 'YASVaalsarkMaleScarL01');

        AssignHeadPart('MarksMaleHumanoid02LeftGash', 'YASKettuMaleScarL02');
        AssignHeadPart('MarksMaleHumanoid02LeftGash', 'YASKygarraMaleScarL02');
        AssignHeadPart('MarksMaleHumanoid02LeftGash', 'YASLykMaleScarL07');
        AssignHeadPart('MarksMaleHumanoid02LeftGash', 'YASVaalsarkMaleScarL02');

        AssignHeadPart('MarksMaleHumanoid03LeftGash', 'YASKettuMaleScarL03BlindL');
        AssignHeadPart('MarksMaleHumanoid03LeftGash', 'YASKygarraMaleScarL03');
        AssignHeadPart('MarksMaleHumanoid03LeftGash', 'YASLykMaleScarL05LBlindL');
        AssignHeadPart('MarksMaleHumanoid03LeftGash', 'YASVaalsarkMaleScarL03BlindL');

        AssignHeadPart('MarksMaleHumanoid04LeftGash', 'YASKettuMaleScarL04');
        AssignHeadPart('MarksMaleHumanoid04LeftGash', 'YASKygarraMaleScarL04');
        AssignHeadPart('MarksMaleHumanoid04LeftGash', 'YASLykMaleScarL08');
        AssignHeadPart('MarksMaleHumanoid04LeftGash', 'YASVaalsarkMaleScarL04');

        AssignHeadPart('MarksMaleHumanoid05LeftGash', 'YASKettuMaleScarL01');
        AssignHeadPart('MarksMaleHumanoid05LeftGash', 'YASKygarraMaleScarL01');
        AssignHeadPart('MarksMaleHumanoid05LeftGash', 'YASLykMaleScarL06');
        AssignHeadPart('MarksMaleHumanoid05LeftGash', 'YASVaalsarkMaleScarL01');

        AssignHeadPart('MarksMaleHumanoid06LeftGash', 'YASKettuMaleScarL02');
        AssignHeadPart('MarksMaleHumanoid06LeftGash', 'YASKygarraMaleScarL02');
        AssignHeadPart('MarksMaleHumanoid06LeftGash', 'YASLykMaleScarL08');
        AssignHeadPart('MarksMaleHumanoid06LeftGash', 'YASVaalsarkMaleScarL02');

        AssignHeadPart('MarksMaleHumanoid10LeftGash', 'YASKettuMaleScarL03BlindL');
        AssignHeadPart('MarksMaleHumanoid10LeftGash', 'YASKygarraMaleScarL03');
        AssignHeadPart('MarksMaleHumanoid10LeftGash', 'YASLykMaleScarL05LBlindL');
        AssignHeadPart('MarksMaleHumanoid10LeftGash', 'YASVaalsarkMaleScarL03BlindL');

        AssignHeadPart('MarksMaleHumanoid11LeftGash', 'YASKettuMaleScarL04');
        AssignHeadPart('MarksMaleHumanoid11LeftGash', 'YASKygarraMaleScarL04');
        AssignHeadPart('MarksMaleHumanoid11LeftGash', 'YASLykMaleScarL08');
        AssignHeadPart('MarksMaleHumanoid11LeftGash', 'YASVaalsarkMaleScarL04');

        AssignHeadPart('MarksMaleHumanoid12LeftGash', 'YASKettuMaleScarC02');
        AssignHeadPart('MarksMaleHumanoid12LeftGash', 'YASKygarraMaleScarC01');
        AssignHeadPart('MarksMaleHumanoid12LeftGash', 'YASLykMaleScarC09');
        AssignHeadPart('MarksMaleHumanoid12LeftGash', 'YASVaalsarkMaleScarC01');

        AssignHeadPart('MarksMaleHumanoid04RightGashR', 'YASKettuMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid04RightGashR', 'YASKygarraMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid04RightGashR', 'YASLykMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid04RightGashR', 'YASVaalsarkMaleScarR01');

        AssignHeadPart('MarksMaleHumanoid06RightGashR', 'YASKettuMaleScarR02BlindR');
        AssignHeadPart('MarksMaleHumanoid06RightGashR', 'YASKygarraMaleScarR02');
        AssignHeadPart('MarksMaleHumanoid06RightGashR', 'YASLykMaleScarR03BlindR');
        AssignHeadPart('MarksMaleHumanoid06RightGashR', 'YASVaalsarkMaleScarR02');
        
        AssignHeadPart('MarksMaleHumanoid07RightGash', 'YASKettuMaleScarR03');
        AssignHeadPart('MarksMaleHumanoid07RightGash', 'YASKygarraMaleScarR03');
        AssignHeadPart('MarksMaleHumanoid07RightGash', 'YASLykMaleScarR04');
        AssignHeadPart('MarksMaleHumanoid07RightGash', 'YASVaalsarkMaleScarR03');

        AssignHeadPart('MarksMaleHumanoid08RightGash', 'YASKettuMaleScarR04');
        AssignHeadPart('MarksMaleHumanoid08RightGash', 'YASKygarraMaleScarR04');
        AssignHeadPart('MarksMaleHumanoid08RightGash', 'YASLykMaleScarR04');
        AssignHeadPart('MarksMaleHumanoid08RightGash', 'YASVaalsarkMaleScarR04');
        AssignHeadPart('MarksMaleHumanoid08RightGash', 'YASVaalsarkMaleScarR05BlindR');

        AssignHeadPart('MarksMaleHumanoid09RightGash', 'YASKettuMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid09RightGash', 'YASKygarraMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid09RightGash', 'YASLykMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid09RightGash', 'YASVaalsarkMaleScarR01');

        AssignHeadPart('MarksMaleHumanoid10RightGashR', 'YASKettuMaleScarR03');
        AssignHeadPart('MarksMaleHumanoid10RightGashR', 'YASKygarraMaleScarR03');
        AssignHeadPart('MarksMaleHumanoid10RightGashR', 'YASLykMaleScarR04');
        AssignHeadPart('MarksMaleHumanoid10RightGashR', 'YASVaalsarkMaleScarR03');
        
        AssignHeadPart('MarksMaleHumanoid11RightGashR', 'YASKettuMaleScarC02');
        AssignHeadPart('MarksMaleHumanoid11RightGashR', 'YASKygarraMaleScarC01');
        AssignHeadPart('MarksMaleHumanoid11RightGashR', 'YASLykMaleScarC09');
        AssignHeadPart('MarksMaleHumanoid11RightGashR', 'YASVaalsarkMaleScarC01');

        AssignHeadPart('MarksMaleHumanoid12RightGashR', 'YASKygarraMaleScarC02');
        AssignHeadPart('MarksMaleHumanoid12RightGashR', 'YASLykMaleScarC10');
        AssignHeadPart('MarksMaleHumanoid12RightGashR', 'YASVaalsarkMaleScarC02');
        AssignHeadPart('MarksMaleHumanoid12RightGashR', 'YASLykMaleScarC10');
    end;

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
Set up label conflicts.
When choosing hair we pick one that does not have a label that conflicts with one of the
NPC's labels.
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
end;

end.