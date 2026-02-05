{
    Defines the races that ship with furry skyrim, along with equivalencies to vanilla assets.
}
unit BDFurrySkyrimRaceDefs;

interface
implementation
uses BDFurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;


{ ================================================================================
    Put any special setup for a furry race here. Anything not defined will use defaults.
  ================================================================================ }
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

        AssignHeadPart('MarksFemaleHumanoid10RightGashR', 'YASLykaiosFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid05LeftGash', 'YASLykaiosFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGashR', 'YASLykaiosFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid12LeftGashR', 'YASLykaiosFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid06LeftGash', 'YASLykaiosFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid01LeftGash', 'YASLykaiosFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGash', 'YASLykaiosFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid02LeftGash', 'YASLykaiosFemScarL02');
        AssignHeadPart('MarksFemaleHumanoid03LeftGash', 'YASLykaiosFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASLykaiosFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid12LeftGash', 'YASLykaiosFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid04LeftGash', 'YASLykaiosFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASLykaiosFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid07RightGash', 'YASLykaiosFemScarR01');
        AssignHeadPart('MarksFemaleHumanoid08RightGash', 'YASLykaiosFemScarR02');
        AssignHeadPart('MarksFemaleHumanoid09RightGash', 'YASLykaiosFemScarR03');
        AssignHeadPart('MarksMaleHumanoid12LeftGash', 'YASLykMaleScarC09');
        AssignHeadPart('MarksMaleHumanoid11RightGashR', 'YASLykMaleScarC09');
        AssignHeadPart('MarksMaleHumanoid12RightGashR', 'YASLykMaleScarC10');
        AssignHeadPart('MarksMaleHumanoid12RightGashR', 'YASLykMaleScarC10');
        AssignHeadPart('MarksMaleHumanoid03LeftGash', 'YASLykMaleScarL05LBlindL');
        AssignHeadPart('MarksMaleHumanoid10LeftGash', 'YASLykMaleScarL05LBlindL');
        AssignHeadPart('MarksMaleHumanoid01LeftGash', 'YASLykMaleScarL06');
        AssignHeadPart('MarksMaleHumanoid05LeftGash', 'YASLykMaleScarL06');
        AssignHeadPart('MarksMaleHumanoid02LeftGash', 'YASLykMaleScarL07');
        AssignHeadPart('MarksMaleHumanoid04LeftGash', 'YASLykMaleScarL08');
        AssignHeadPart('MarksMaleHumanoid06LeftGash', 'YASLykMaleScarL08');
        AssignHeadPart('MarksMaleHumanoid11LeftGash', 'YASLykMaleScarL08');
        AssignHeadPart('MarksMaleHumanoid09RightGash', 'YASLykMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid04RightGashR', 'YASLykMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid06RightGashR', 'YASLykMaleScarR03BlindR');
        AssignHeadPart('MarksMaleHumanoid07RightGash', 'YASLykMaleScarR04');
        AssignHeadPart('MarksMaleHumanoid08RightGash', 'YASLykMaleScarR04');
        AssignHeadPart('MarksMaleHumanoid10RightGashR', 'YASLykMaleScarR04');
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

        AssignHeadPart('MarksFemaleHumanoid10RightGashR', 'YASKettuFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid05LeftGash', 'YASKettuFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGashR', 'YASKettuFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid12LeftGashR', 'YASKettuFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid06LeftGash', 'YASKettuFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid01LeftGash', 'YASKettuFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGash', 'YASKettuFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid02LeftGash', 'YASKettuFemScarL02');
        AssignHeadPart('MarksFemaleHumanoid03LeftGash', 'YASKettuFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASKettuFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid12LeftGash', 'YASKettuFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid04LeftGash', 'YASKettuFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASKettuFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid07RightGash', 'YASKettuFemScarR01');
        AssignHeadPart('MarksFemaleHumanoid08RightGash', 'YASKettuFemScarR02');
        AssignHeadPart('MarksFemaleHumanoid09RightGash', 'YASKettuFemScarR03');
        AssignHeadPart('MarksMaleHumanoid12LeftGash', 'YASKettuMaleScarC02');
        AssignHeadPart('MarksMaleHumanoid11RightGashR', 'YASKettuMaleScarC02');
        AssignHeadPart('MarksMaleHumanoid01LeftGash', 'YASKettuMaleScarL01');
        AssignHeadPart('MarksMaleHumanoid05LeftGash', 'YASKettuMaleScarL01');
        AssignHeadPart('MarksMaleHumanoid02LeftGash', 'YASKettuMaleScarL02');
        AssignHeadPart('MarksMaleHumanoid06LeftGash', 'YASKettuMaleScarL02');
        AssignHeadPart('MarksMaleHumanoid03LeftGash', 'YASKettuMaleScarL03BlindL');
        AssignHeadPart('MarksMaleHumanoid10LeftGash', 'YASKettuMaleScarL03BlindL');
        AssignHeadPart('MarksMaleHumanoid04LeftGash', 'YASKettuMaleScarL04');
        AssignHeadPart('MarksMaleHumanoid11LeftGash', 'YASKettuMaleScarL04');
        AssignHeadPart('MarksMaleHumanoid09RightGash', 'YASKettuMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid04RightGashR', 'YASKettuMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid06RightGashR', 'YASKettuMaleScarR02BlindR');
        AssignHeadPart('MarksMaleHumanoid07RightGash', 'YASKettuMaleScarR03');
        AssignHeadPart('MarksMaleHumanoid10RightGashR', 'YASKettuMaleScarR03');
        AssignHeadPart('MarksMaleHumanoid08RightGash', 'YASKettuMaleScarR04');
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

        AssignHeadPart('MarksFemaleHumanoid10RightGashR', 'YASKonoiFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid05LeftGash', 'YASKonoiFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGashR', 'YASKonoiFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid12LeftGashR', 'YASKonoiFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid06LeftGash', 'YASKonoiFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid01LeftGash', 'YASKonoiFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGash', 'YASKonoiFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid02LeftGash', 'YASKonoiFemScarL02');
        AssignHeadPart('MarksFemaleHumanoid03LeftGash', 'YASKonoiFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASKonoiFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid12LeftGash', 'YASKonoiFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid04LeftGash', 'YASKonoiFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASKonoiFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid07RightGash', 'YASKonoiFemScarR01');
        AssignHeadPart('MarksFemaleHumanoid08RightGash', 'YASKonoiFemScarR02');
        AssignHeadPart('MarksFemaleHumanoid09RightGash', 'YASKonoiFemScarR03');
    end;

    begin // KYGARRA
        SetTintLayerRequired('KygarraSpots', TRUE);
        SetTintLayerClass('YASKygarraRace', 'YAS\Kygarra\Male\Tints\Spots01.dds', 'KygarraSpots');
        SetTintLayerClass('YASKygarraRace', 'YAS\Kygarra\Male\Tints\Spots02.dds', 'KygarraSpots');
        SetTintLayerClass('YASKygarraRace', 'YAS\Kygarra\Male\Tints\Spots03.dds', 'KygarraSpots');
        SetTintLayerClass('YASKygarraRace', 'YAS\Kygarra\Male\Tints\Spots04.dds', 'KygarraSpots');

        AssignHeadPart('MarksFemaleHumanoid10RightGashR', 'YASKygarraFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid05LeftGash', 'YASKygarraFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGashR', 'YASKygarraFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid12LeftGashR', 'YASKygarraFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid06LeftGash', 'YASKygarraFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid01LeftGash', 'YASKygarraFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGash', 'YASKygarraFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid02LeftGash', 'YASKygarraFemScarL02');
        AssignHeadPart('MarksFemaleHumanoid03LeftGash', 'YASKygarraFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASKygarraFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid12LeftGash', 'YASKygarraFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid04LeftGash', 'YASKygarraFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASKygarraFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid07RightGash', 'YASKygarraFemScarR01');
        AssignHeadPart('MarksFemaleHumanoid08RightGash', 'YASKygarraFemScarR02');
        AssignHeadPart('MarksFemaleHumanoid09RightGash', 'YASKygarraFemScarR03');
        AssignHeadPart('MarksMaleHumanoid12LeftGash', 'YASKygarraMaleScarC01');
        AssignHeadPart('MarksMaleHumanoid11RightGashR', 'YASKygarraMaleScarC01');
        AssignHeadPart('MarksMaleHumanoid12RightGashR', 'YASKygarraMaleScarC02');
        AssignHeadPart('MarksMaleHumanoid01LeftGash', 'YASKygarraMaleScarL01');
        AssignHeadPart('MarksMaleHumanoid05LeftGash', 'YASKygarraMaleScarL01');
        AssignHeadPart('MarksMaleHumanoid02LeftGash', 'YASKygarraMaleScarL02');
        AssignHeadPart('MarksMaleHumanoid06LeftGash', 'YASKygarraMaleScarL02');
        AssignHeadPart('MarksMaleHumanoid03LeftGash', 'YASKygarraMaleScarL03');
        AssignHeadPart('MarksMaleHumanoid10LeftGash', 'YASKygarraMaleScarL03');
        AssignHeadPart('MarksMaleHumanoid04LeftGash', 'YASKygarraMaleScarL04');
        AssignHeadPart('MarksMaleHumanoid11LeftGash', 'YASKygarraMaleScarL04');
        AssignHeadPart('MarksMaleHumanoid09RightGash', 'YASKygarraMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid04RightGashR', 'YASKygarraMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid06RightGashR', 'YASKygarraMaleScarR02');
        AssignHeadPart('MarksMaleHumanoid07RightGash', 'YASKygarraMaleScarR03');
        AssignHeadPart('MarksMaleHumanoid10RightGashR', 'YASKygarraMaleScarR03');
        AssignHeadPart('MarksMaleHumanoid08RightGash', 'YASKygarraMaleScarR04');
    end;

    begin // VAALSARK
        // TODO: Tints

        AssignHeadPart('MarksFemaleHumanoid10RightGashR', 'YASVaalsarkFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid05LeftGash', 'YASVaalsarkFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGashR', 'YASVaalsarkFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid12LeftGashR', 'YASVaalsarkFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid06LeftGash', 'YASVaalsarkFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid01LeftGash', 'YASVaalsarkFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGash', 'YASVaalsarkFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid02LeftGash', 'YASVaalsarkFemScarL02');
        AssignHeadPart('MarksFemaleHumanoid03LeftGash', 'YASVaalsarkFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASVaalsarkFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid12LeftGash', 'YASVaalsarkFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid04LeftGash', 'YASVaalsarkFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASVaalsarkFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid07RightGash', 'YASVaalsarkFemScarR01');
        AssignHeadPart('MarksFemaleHumanoid08RightGash', 'YASVaalsarkFemScarR02');
        AssignHeadPart('MarksFemaleHumanoid09RightGash', 'YASVaalsarkFemScarR03');
        AssignHeadPart('MarksMaleHumanoid12LeftGash', 'YASVaalsarkMaleScarC01');
        AssignHeadPart('MarksMaleHumanoid11RightGashR', 'YASVaalsarkMaleScarC01');
        AssignHeadPart('MarksMaleHumanoid12RightGashR', 'YASVaalsarkMaleScarC02');
        AssignHeadPart('MarksMaleHumanoid01LeftGash', 'YASVaalsarkMaleScarL01');
        AssignHeadPart('MarksMaleHumanoid05LeftGash', 'YASVaalsarkMaleScarL01');
        AssignHeadPart('MarksMaleHumanoid02LeftGash', 'YASVaalsarkMaleScarL02');
        AssignHeadPart('MarksMaleHumanoid06LeftGash', 'YASVaalsarkMaleScarL02');
        AssignHeadPart('MarksMaleHumanoid03LeftGash', 'YASVaalsarkMaleScarL03BlindL');
        AssignHeadPart('MarksMaleHumanoid10LeftGash', 'YASVaalsarkMaleScarL03BlindL');
        AssignHeadPart('MarksMaleHumanoid04LeftGash', 'YASVaalsarkMaleScarL04');
        AssignHeadPart('MarksMaleHumanoid11LeftGash', 'YASVaalsarkMaleScarL04');
        AssignHeadPart('MarksMaleHumanoid09RightGash', 'YASVaalsarkMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid04RightGashR', 'YASVaalsarkMaleScarR01');
        AssignHeadPart('MarksMaleHumanoid06RightGashR', 'YASVaalsarkMaleScarR02');
        AssignHeadPart('MarksMaleHumanoid07RightGash', 'YASVaalsarkMaleScarR03');
        AssignHeadPart('MarksMaleHumanoid10RightGashR', 'YASVaalsarkMaleScarR03');
        AssignHeadPart('MarksMaleHumanoid08RightGash', 'YASVaalsarkMaleScarR04');
        AssignHeadPart('MarksMaleHumanoid08RightGash', 'YASVaalsarkMaleScarR05BlindR');
    end;

    begin // XEBA
        // TODO: Tints

        AssignHeadPart('MarksFemaleHumanoid10RightGashR', 'YASXebaFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid05LeftGash', 'YASXebaFemScarC01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGashR', 'YASXebaFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid12LeftGashR', 'YASXebaFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid06LeftGash', 'YASXebaFemScarC02');
        AssignHeadPart('MarksFemaleHumanoid01LeftGash', 'YASXebaFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid11LeftGash', 'YASXebaFemScarL01');
        AssignHeadPart('MarksFemaleHumanoid02LeftGash', 'YASXebaFemScarL02');
        AssignHeadPart('MarksFemaleHumanoid03LeftGash', 'YASXebaFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASXebaFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid12LeftGash', 'YASXebaFemScarL03');
        AssignHeadPart('MarksFemaleHumanoid04LeftGash', 'YASXebaFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid10LeftGash', 'YASXebaFemScarL04');
        AssignHeadPart('MarksFemaleHumanoid07RightGash', 'YASXebaFemScarR01');
        AssignHeadPart('MarksFemaleHumanoid08RightGash', 'YASXebaFemScarR02');
        AssignHeadPart('MarksFemaleHumanoid09RightGash', 'YASXebaFemScarR03');
    end;

    begin // Descriptions of furry hair styles
        // Dogs
        LabelHeadpartList('YASDogMaleHairDreads001', 'HAIR,DREADS,BOLD,FUNKY,LONG');
        // LabelHeadpart('BDLykMaleHairDreads002', 'DREADS'); // Dark version
        LabelHeadpartList('YASDogMaleHairDreads003', 'HAIR,DREADS,NOBLE,BOLD,FUNKY,LONG');
        // LabelHeadpart('BDLykMaleHairDreads004', 'DREADS'); // Dark version
        LabelHeadpartList('YASDogMaleHairDreadsFringe', 'HAIR,DREADS,NOBLE,BOLD,FUNKY,YOUNG,LONG');
        LabelHeadpartList('YASDogMaleHairDreadsHeadband', 'HAIR,DREADS,NOBLE,BOLD,FUNKY,FEATHERS,LONG');
        LabelHeadpartList('YASDogMaleHairFringeFlip001', 'HAIR,YOUNG,SHORT');
        LabelHeadpartList('YASDogMaleHairLionMane001', 'HAIR,MANE,LONG');
        LabelHeadpartList('YASDogMaleHairLionMane002', 'HAIR,MANE,LONG,YOUNG');
        LabelHeadpartList('YASDogMaleHairLionManebraids', 'HAIR,MANE,LONG,NOBLE,BRAIDS');
        LabelHeadpartList('YASDogMaleHairLionManeFringeLeftBraid', 'HAIR,MANE,LONG,NOBLE,BRAIDS');
        LabelHeadpartList('YASDogMaleHairLionManeHeadband', 'HAIR,MANE,LONG,NOBLE,FEATHERS');
        LabelHeadpartList('YASDogMaleHairLongBraid001', 'HAIR,BRAIDS,NEAT,TIEDBACK');
        LabelHeadpartList('YASDogMaleHairLongBraid002', 'HAIR,TIEDBACK,BRAIDS,NOBLE');
        LabelHeadpartList('YASDogMaleHairLongBraidleft', 'HAIR,NEAT,TIEDBACK,BRAIDS,NOBLE');
        LabelHeadpartList('YASDogMaleHairMohawk001', 'HAIR,MOHAWK,BRAIDS,MILITARY,BOLD,FANCY');
        LabelHeadpartList('YASDogMaleHairMohawk003', 'HAIR,MOHAWK,FEATHERS,BOLD');
        LabelHeadpartList('YASDogMaleHairMohawkFringe', 'HAIR,MOHAWK,YOUNG,BOLD');
        LabelHeadpartList('YASDogMaleHairShaggyHair002', 'HAIR,LONG,MESSY');
        LabelHeadpartList('YASDogMaleHairShaggyHair003', 'HAIR,LONG,MESSY,FEATHERS');
        LabelHeadpartList('YASDogMaleHairShorCrop001', 'HAIR,SHORT,NEAT');
        LabelHeadpartList('YASDogMaleHairShorCrop002', 'HAIR,SHORT,NEAT,YOUNG');
        LabelHeadpartList('YASDogMaleHairShorCrop003', 'HAIR,SHORT,NEAT,NOBLE');
        LabelHeadpartList('YASDogMaleHairShorCrop004', 'HAIR,SHORT,NEAT,NOBLE,FEATHERS');
        LabelHeadpartList('YASDogMaleHairTiedStyle001', 'HAIR,LONG,NOBLE,NEAT');
        LabelHeadpartList('YASDogMaleHairTiedStyleFringe', 'HAIR,LONG,NOBLE,NEAT,YOUNG');
        LabelHeadpartList('YASDogMaleHairTiedStyleHeadband', 'HAIR,LONG,NOBLE,NEAT,YOUNG,FEATHERS');
        LabelHeadpartList('YASDogMaleHairVanillaBraid001', 'HAIR,LONG,NEAT,TIEDBACK');
        LabelHeadpartList('YASDogMaleHairVanillaHair001', 'HAIR,MESSY,LONG');
        LabelHeadpartList('YASDogMaleHairSidehawk', 'HAIR,MOHAWK,FUNKY,BOLD');
        LabelHeadpartList('YASDogMaleHairImperial01', 'SHORT,NEAT,MILITARY,IMPERIAL');

        LabelHeadpartList('YASDogFemHair01', 'HAIR,NEAT,TIEDBACK,SHORT,BRAIDS');
        LabelHeadpartList('YASDogFemHair02', 'HAIR,NEAT,TIEDBACK');
        LabelHeadpartList('YASDogFemHair03', 'HAIR,NEAT,SHORT');
        LabelHeadpartList('YASDogFemHair04', 'HAIR,NEAT,LONG,TIEDBACK,BRAIDS');
        LabelHeadpartList('YASDogFemHair05', 'HAIR,SHORT,TIEDBACK,FUNKY');
        LabelHeadpartList('YASDogFemHair06', 'HAIR,SHORT,TIEDBACK,FUNKY');
        LabelHeadpartList('YASDogFemHair07', 'HAIR,SHORT,TIEDBACK,FUNKY,BRAIDS');
        LabelHeadpartList('YASDogFemHair08', 'HAIR,NEAT,LONG,TIEDBACK,BRAIDS,FUNKY');
        LabelHeadpartList('YASDogFemHair09', 'HAIR,NEAT,TIEDBACK,SHORT,BRAIDS');
        LabelHeadpartList('YASDogFemHair10', 'HAIR,NEAT,TIEDBACK');
        LabelHeadpartList('YASDogFemHairBraid001', 'HAIR,NEAT,TIEDBACK,LONG,BRAIDS');
        LabelHeadpartList('YASDogFemHairBraid002', 'HAIR,NEAT,TIEDBACK,LONG,BRAIDS,NOBLE');
        LabelHeadpartList('YASDogFemHairDreads001', 'HAIR,DREADS,BOLD,FUNKY,LONG');
        LabelHeadpartList('YASDogFemHairDreads002', 'HAIR,DREADS,BOLD,FUNKY,NOBLE,ELABORATE,LONG');
        LabelHeadpartList('YASDogFemHairDreads003', 'HAIR,DREADS,BOLD,FUNKY,LONG');
        LabelHeadpartList('YASDogFemHairDreads004', 'HAIR,DREADS,BOLD,FUNKY,NOBLE,ELABORATE,LONG');
        LabelHeadpartList('YASDogFemHairFringeFlip001', 'HAIR,YOUNG,NEAT,SHORT');
        LabelHeadpartList('YASDogFemHairMane001', 'HAIR,MANE,LONG,BOLD');
        LabelHeadpartList('YASDogFemHairMane002', 'HAIR,MANE,LONG,BOLD');
        LabelHeadpartList('YASDogFemHairMane003', 'HAIR,MANE,LONG,BOLD,NOBLE');
        LabelHeadpartList('YASDogFemHairMohawk001', 'HAIR,MOHAWK,BOLD,FUNKY');
        LabelHeadpartList('YASDogFemHairMohawk002', 'HAIR,MOHAWK,BOLD,FUNKY,FEATHERS');
        LabelHeadpartList('YASDogFemHairShaggy001', 'HAIR,LONG,MESSY,LONG');
        LabelHeadpartList('YASDogFemHairShaggy002', 'HAIR,MESSY,BRAIDS');
        LabelHeadpartList('YASDogFemHairShortCrop001', 'HAIR,SHORT,NEAT,MILITARY');
        LabelHeadpartList('YASDogFemHairShortCrop002', 'HAIR,SHORT,NEAT');
        LabelHeadpartList('YASDogFemHairShortCrop003', 'HAIR,SHORT,NEAT,BRAIDS,NOBLE');
        LabelHeadpartList('YASDogFemHairTiedStyle001', 'HAIR,LONG,NOBLE,ELABORATE');
        LabelHeadpartList('YASDogFemHairVanillaBraid001', 'HAIR,TIEDBACK,BRAIDS');
        LabelHeadpartList('YASDogFemHairVanillaCrop001', 'HAIR,SHORT,TIEDBACK');
        LabelHeadpartList('YASDogFemHairVanillaHair001', 'HAIR,SHORT,BRAIDS,FUNKY');
        LabelHeadpartList('YASFemHairApachii01', 'HAIR,NEAT,YOUNG,BRAIDS');
        LabelHeadpartList('YASFemHairApachii02', 'HAIR,DREADS,LONG,BOLD,FUNKY');
        LabelHeadpartList('YASFemHairApachii03', 'HAIR,NEAT,SHORT');
        LabelHeadpartList('YASFemHairApachii04', 'HAIR,MESSY,LONG');
        LabelHeadpartList('YASFemHairApachii05', 'HAIR,MESSY,LONG');

        // Cats
        LabelHeadpartList('YASCatMaleHairDreads001', 'HAIR,DREADS,BOLD,FUNKY,LONG');
        // LabelHeadpart('BDLykMaleHairDreads002', 'DREADS'); // Dark version
        LabelHeadpartList('YASCatMaleHairDreads003', 'HAIR,DREADS,NOBLE,BOLD,FUNKY,LONG');
        // LabelHeadpart('BDLykMaleHairDreads004', 'DREADS'); // Dark version
        LabelHeadpartList('YASCatMaleHairDreadsFringe', 'HAIR,DREADS,NOBLE,BOLD,FUNKY,YOUNG,LONG');
        LabelHeadpartList('YASCatMaleHairDreadsHeadband', 'HAIR,DREADS,NOBLE,BOLD,FUNKY,FEATHERS,LONG');
        LabelHeadpartList('YASCatMaleHairFringeFlip001', 'HAIR,YOUNG,SHORT');
        LabelHeadpartList('YASCatMaleHairLionMane001', 'HAIR,MANE,LONG');
        LabelHeadpartList('YASCatMaleHairLionMane002', 'HAIR,MANE,LONG,YOUNG');
        LabelHeadpartList('YASCatMaleHairLionManebraids', 'HAIR,MANE,LONG,NOBLE,BRAIDS');
        LabelHeadpartList('YASCatMaleHairLionManeFringeLeftBraid', 'HAIR,MANE,LONG,NOBLE,BRAIDS');
        LabelHeadpartList('YASCatMaleHairLionManeHeadband', 'HAIR,MANE,LONG,NOBLE,FEATHERS');
        LabelHeadpartList('YASCatMaleHairLongBraid001', 'HAIR,BRAIDS,NEAT,TIEDBACK');
        LabelHeadpartList('YASCatMaleHairLongBraid002', 'HAIR,TIEDBACK,BRAIDS,NOBLE');
        LabelHeadpartList('YASCatMaleHairLongBraidleft', 'HAIR,NEAT,TIEDBACK,BRAIDS,NOBLE');
        LabelHeadpartList('YASCatMaleHairMohawk001', 'HAIR,MOHAWK,BRAIDS,MILITARY,BOLD,FANCY');
        LabelHeadpartList('YASCatMaleHairMohawk003', 'HAIR,MOHAWK,FEATHERS,BOLD');
        LabelHeadpartList('YASCatMaleHairMohawkFringe', 'HAIR,MOHAWK,YOUNG,BOLD');
        LabelHeadpartList('YASCatMaleHairShaggyHair002', 'HAIR,LONG,MESSY');
        LabelHeadpartList('YASCatMaleHairShaggyHair003', 'HAIR,LONG,MESSY,FEATHERS');
        LabelHeadpartList('YASCatMaleHairShorCrop001', 'HAIR,SHORT,NEAT');
        LabelHeadpartList('YASCatMaleHairShorCrop002', 'HAIR,SHORT,NEAT,YOUNG');
        LabelHeadpartList('YASCatMaleHairShorCrop003', 'HAIR,SHORT,NEAT,NOBLE');
        LabelHeadpartList('YASCatMaleHairShorCrop004', 'HAIR,SHORT,NEAT,NOBLE,FEATHERS');
        LabelHeadpartList('YASCatMaleHairTiedStyle001', 'HAIR,LONG,NOBLE,NEAT');
        LabelHeadpartList('YASCatMaleHairTiedStyleFringe', 'HAIR,LONG,NOBLE,NEAT,YOUNG');
        LabelHeadpartList('YASCatMaleHairTiedStyleHeadband', 'HAIR,LONG,NOBLE,NEAT,YOUNG,FEATHERS');
        LabelHeadpartList('YASCatMaleHairVanillaBraid001', 'HAIR,LONG,NEAT,TIEDBACK');
        LabelHeadpartList('YASCatMaleHairVanillaHair001', 'HAIR,MESSY,LONG');
        LabelHeadpartList('YASCatMaleHairSidehawk', 'HAIR,MOHAWK,FUNKY,BOLD');

        LabelHeadpartList('YASCatFemHairBraid001', 'HAIR,NEAT,TIEDBACK,LONG,BRAIDS');
        LabelHeadpartList('YASCatFemHairBraid002', 'HAIR,NEAT,TIEDBACK,LONG,BRAIDS,NOBLE');
        LabelHeadpartList('YASCatFemHairDreads001', 'HAIR,DREADS,BOLD,FUNKY,LONG');
        LabelHeadpartList('YASCatFemHairDreads002', 'HAIR,DREADS,BOLD,FUNKY,NOBLE,ELABORATE,LONG');
        LabelHeadpartList('YASCatFemHairDreads003', 'HAIR,DREADS,BOLD,FUNKY,LONG');
        LabelHeadpartList('YASCatFemHairDreads004', 'HAIR,DREADS,BOLD,FUNKY,NOBLE,ELABORATE,LONG');
        LabelHeadpartList('YASCatFemHairFringeFlip001', 'HAIR,YOUNG,NEAT,SHORT');
        LabelHeadpartList('YASCatFemHairMane001', 'HAIR,MANE,LONG,BOLD');
        LabelHeadpartList('YASCatFemHairMane002', 'HAIR,MANE,LONG,BOLD');
        LabelHeadpartList('YASCatFemHairMane003', 'HAIR,MANE,LONG,BOLD,NOBLE');
        LabelHeadpartList('YASCatFemHairMohawk001', 'HAIR,MOHAWK,BOLD,FUNKY');
        LabelHeadpartList('YASCatFemHairMohawk002', 'HAIR,MOHAWK,BOLD,FUNKY,FEATHERS');
        LabelHeadpartList('YASCatFemHairShaggy001', 'HAIR,LONG,MESSY,LONG');
        LabelHeadpartList('YASCatFemHairShaggy002', 'HAIR,MESSY,BRAIDS');
        LabelHeadpartList('YASCatFemHairShortCrop001', 'HAIR,SHORT,NEAT,MILITARY');
        LabelHeadpartList('YASCatFemHairShortCrop002', 'HAIR,SHORT,NEAT');
        LabelHeadpartList('YASCatFemHairShortCrop003', 'HAIR,SHORT,NEAT,BRAIDS,NOBLE');
        LabelHeadpartList('YASCatFemHairTiedStyle001', 'HAIR,LONG,NOBLE,ELABORATE');
        LabelHeadpartList('YASCatFemHairVanillaBraid001', 'HAIR,TIEDBACK,BRAIDS');
        LabelHeadpartList('YASCatFemHairVanillaCrop001', 'HAIR,SHORT,TIEDBACK');
        LabelHeadpartList('YASCatFemHairVanillaHair001', 'HAIR,SHORT,BRAIDS,FUNKY');
        LabelHeadpartList('YASCatFemHairApachii01', 'HAIR,NEAT,YOUNG,BRAIDS');
        LabelHeadpartList('YASCatFemHairApachii02', 'HAIR,DREADS,LONG,BOLD,FUNKY');
        LabelHeadpartList('YASCatFemHairApachii03', 'HAIR,NEAT,SHORT');
        LabelHeadpartList('YASCatFemHairApachii04', 'HAIR,MESSY,LONG');
        LabelHeadpartList('YASCatFemHairApachii05', 'HAIR,MESSY,LONG');
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
end;

end.