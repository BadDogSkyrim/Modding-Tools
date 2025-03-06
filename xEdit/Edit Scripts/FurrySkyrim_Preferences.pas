{
}
unit FurrySkyrim_Preferences;

interface
implementation
uses FurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;


Procedure SetPreferences;
begin
    SetRace('NordRace', 'LykaiosRace');

    AssignHeadpart('HairMaleNord01', '00HairLykaiosMaleVanillaHair001_');
    AssignHeadpart('HairMaleNord03', '00HairLykaiosMaleTiedStyle001_');
    AssignHeadpart('HairMaleNord03', '00HairLykaiosMaleLionMane001');
    AssignHeadpart('HairMaleNord03', '00HairLykaiosMaleLionMane002');
    AssignHeadpart('HairMaleNord04', '00HairLykaiosMaleLionManeFringeLeftBraid_');
    AssignHeadpart('HairMaleNord04', '00HairLykaiosMaleLionManeHeadband');
    AssignHeadpart('HairMaleNord04', '00HairLykaiosMaleLionManeBraids');
    AssignHeadpart('HairMaleNord05', '00HairLykaiosMaleDreads001_');
    AssignHeadpart('HairMaleNord05', '00HairLykaiosMaleDreads002_');
    AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleDreads003_');
    AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleDreads004_');
    AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleDreadsHeadband_');
    AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleLionManeFringeLeftBraid_');
    AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleLionManeBraids');
    AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleTiedStyle001_');
    AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleTiedStyleFringe_');
    AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleTiedStyleHeadband_');
    AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleVanillaBraid001_');

    AssignHeadpart('HairMaleElder5', '00HairLykaiosMaleShorCrop001_');

    // Fallback to vanilla Khajiit hair
    AssignHeadpart('HairMaleNord01', 'HairKhajiitMale02');
    AssignHeadpart('HairMaleNord02', 'HairKhajiitMale01');
    AssignHeadpart('HairMaleNord02', 'HairKhajiitMale04');
    AssignHeadpart('HairMaleNord03', 'HairKhajiitMale05');
    AssignHeadpart('HairMaleNord04', 'HairKhajiitMale04');
    AssignHeadpart('HairMaleNord04', 'HairKhajiitMale09');
    AssignHeadpart('HairMaleNord05', 'HairKhajiitMale02');
    AssignHeadpart('HairMaleNord05', 'HairKhajiitMale03');
    AssignHeadpart('HairMaleNord06', 'HairKhajiitMale05');

    // Vanilla NPC equivalents
    NPCEquivalent('AstridEnd', 'Astrid');
end;

end.