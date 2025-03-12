{
}
unit FurrySkyrim_Preferences;

interface
implementation
uses FurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;


Procedure SetPreferences;
begin
    SetRace('NordRace', 'LykaiosRace');

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
    LabelHeadpartList('00HairLykaiosMaleShorCrop001_', 'SHORT,NEAT,MILITARY');
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

    // AssignHeadpart('HairMaleNord01', '00HairLykaiosMaleVanillaHair001_');
    // AssignHeadpart('HairMaleNord02', '00HairLykaiosMaleDreads001_');
    // AssignHeadpart('HairMaleNord02', '00HairLykaiosMaleDreads002_');
    // AssignHeadpart('HairMaleNord02', '00HairLykaiosMaleDreads003_');
    // AssignHeadpart('HairMaleNord02', '00HairLykaiosMaleDreads004_');
    // AssignHeadpart('HairMaleNord03', '00HairLykaiosMaleTiedStyle001_');
    // AssignHeadpart('HairMaleNord03', '00HairLykaiosMaleLionMane001');
    // AssignHeadpart('HairMaleNord03', '00HairLykaiosMaleLionMane002');
    // AssignHeadpart('HairMaleNord04', '00HairLykaiosMaleLionManeFringeLeftBraid_');
    // AssignHeadpart('HairMaleNord04', '00HairLykaiosMaleLionManeHeadband');
    // AssignHeadpart('HairMaleNord04', '00HairLykaiosMaleLionManeBraids');
    // AssignHeadpart('HairMaleNord05', '00HairLykaiosMaleDreads001_');
    // AssignHeadpart('HairMaleNord05', '00HairLykaiosMaleDreads002_');
    // AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleDreads003_');
    // AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleDreads004_');
    // AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleDreadsHeadband_');
    // AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleLionManeFringeLeftBraid_');
    // AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleLionManeBraids');
    // AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleTiedStyle001_');
    // AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleTiedStyleFringe_');
    // AssignHeadpart('HairMaleNord06', '00HairLykaiosMaleTiedStyleHeadband_');
    // AssignHeadpart('HairMaleNord07', '00HairLykaiosMaleLongBraid001_');
    // AssignHeadpart('HairMaleNord07', '00HairLykaiosMaleShorCrop001_');
    // AssignHeadpart('HairMaleNord07', '00HairLykaiosMaleShorCrop002_');
    // AssignHeadpart('HairMaleNord07', '00HairLykaiosMaleVanillaCrop001_');
    // AssignHeadpart('HairMaleNord08', '00HairLykaiosMaleShorCrop003_');
    // AssignHeadpart('HairMaleNord09', '00HairLykaiosMaleShorCrop003_');
    // AssignHeadpart('HairMaleNord09', '00HairLykaiosMaleDreds001_');
    // AssignHeadpart('HairMaleNord09', '00HairLykaiosMaleDreds002_');
    // AssignHeadpart('HairMaleNord09', '00HairLykaiosMaleShorCrop004_');
    // AssignHeadpart('HairMaleNord09', '00HairLykaiosMaleVanillaCrop001_');
    // AssignHeadpart('HairMaleNord10', '00HairLykaiosMaleLongBraid001_');
    // AssignHeadpart('HairMaleNord10', '00HairLykaiosMaleBeastSidehawk');
    // AssignHeadpart('HairMaleNord10', '00HairLykaiosMaleVanillaBraid001_');
    // AssignHeadpart('HairMaleNord10', '00HairLykaiosMaleShorCrop003_');
    // AssignHeadpart('HairMaleNord10', '00HairLykaiosMaleShorCrop004_');
    // AssignHeadpart('HairMaleNord11', '00HairLykaiosMaleShorCrop003_');
    // AssignHeadpart('HairMaleNord11', '00HairLykaiosMaleShorCrop004_');
    // AssignHeadpart('HairMaleNord11', '00HairLykaiosMaleFringeFlip001_');
    // AssignHeadpart('HairMaleNord11', '00HairLykaiosMaleDreadsHeadband_');
    // AssignHeadpart('HairMaleNord12', '00HairLykaiosMaleVanillaBraid001_');
    // AssignHeadpart('HairMaleNord13', '00HairLykaiosMaleTiedStyle001_');
    // AssignHeadpart('HairMaleNord13', '00HairLykaiosMaleTiedStyle002_');
    // AssignHeadpart('HairMaleNord14', '00HairLykaiosMaleShorCrop001_');
    // AssignHeadpart('HairMaleNord14', '00HairLykaiosMaleShorCrop002_');
    // AssignHeadpart('HairMaleNord14', '00HairLykaiosMaleShorCrop004_');
    // AssignHeadpart('HairMaleNord15', '00HairLykaiosMaleShorCrop001_');
    // AssignHeadpart('HairMaleNord15', '00HairLykaiosMaleShorCrop002_');
    // AssignHeadpart('HairMaleNord15', '00HairLykaiosMaleShorCrop004_');
    // AssignHeadpart('HairMaleNord16', '00HairLykaiosMaleMohawk001_');
    // AssignHeadpart('HairMaleNord16', '00HairLykaiosMaleMohawk002_');
    // AssignHeadpart('HairMaleNord16', '00HairLykaiosMaleMohawk003_');
    // AssignHeadpart('HairMaleNord16', '00HairLykaiosMaleMohawkFringe_');
    // AssignHeadpart('HairMaleNord17', '00HairLykaiosMaleMohawk001_');
    // AssignHeadpart('HairMaleNord17', '00HairLykaiosMaleMohawk002_');
    // AssignHeadpart('HairMaleNord17', '00HairLykaiosMaleMohawk003_');
    // AssignHeadpart('HairMaleNord17', '00HairLykaiosMaleMohawkFringe_');
    // AssignHeadpart('HairMaleNord18', '00HairLykaiosMaleShaggyHair001_');
    // AssignHeadpart('HairMaleNord18', '00HairLykaiosMaleShaggyHair002_');
    // AssignHeadpart('HairMaleNord18', '00HairLykaiosMaleShaggyHair003_');
    // AssignHeadpart('HairMaleNord19', '00HairLykaiosMaleShaggyHair001_');
    // AssignHeadpart('HairMaleNord19', '00HairLykaiosMaleShaggyHair002_');
    // AssignHeadpart('HairMaleNord19', '00HairLykaiosMaleShaggyHair003_');
    // AssignHeadpart('HairMaleNord20', '00HairLykaiosMaleBeastSidehawk');

    // AssignHeadpart('HairMaleElder5', '00HairLykaiosMaleDreads001_');

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
    AssignHeadpart('MaleEyesHumanLeftBlindSingle', '00LykaiosMaleEyesAlbino');
    AssignHeadpart('MaleEyesHumanLightBlue', '00LykaiosMaleEyesSnow1');
    AssignHeadpart('MaleEyesHumanLightBlueBlindLeft', '00LykaiosMaleEyesAlbino');
    AssignHeadpart('MaleEyesHumanLightBlueBloodShot', '00LykaiosMaleEyesSnow1');
    AssignHeadpart('MaleEyesHumanLightGrey', '00LykaiosMaleEyesGrey');
    AssignHeadpart('MaleEyesHumanLightIceGreyBlindLeft', '00LykaiosMaleEyesLilac');
    AssignHeadpart('MaleEyesHumanRightBlindSingle', '00LykaiosMaleEyesAlbino');
    AssignHeadpart('MaleEyesHumanRightHazleBrownRight', '00LykaiosMaleEyesBrown');
    AssignHeadpart('MaleEyesHumanVampire', '00LykaiosMaleEyesVampire');


    // Vanilla equivalents

    // Khajiit hair
    // AssignHeadpart('HairMaleNord01', 'HairKhajiitMale02');
    // AssignHeadpart('HairMaleNord02', 'HairKhajiitMale01');
    // AssignHeadpart('HairMaleNord02', 'HairKhajiitMale04');
    // AssignHeadpart('HairMaleNord03', 'HairKhajiitMale05');
    // AssignHeadpart('HairMaleNord04', 'HairKhajiitMale04');
    // AssignHeadpart('HairMaleNord04', 'HairKhajiitMale09');
    // AssignHeadpart('HairMaleNord05', 'HairKhajiitMale02');
    // AssignHeadpart('HairMaleNord05', 'HairKhajiitMale03');
    // AssignHeadpart('HairMaleNord06', 'HairKhajiitMale05');
    // AssignHeadpart('HairMaleNord07', 'HairKhajiitMale02');
    // AssignHeadpart('HairMaleNord07', 'HairKhajiitMale03');
    // AssignHeadpart('HairMaleNord08', 'HairKhajiitMale04');
    // AssignHeadpart('HairMaleNord08', 'HairKhajiitMale09');
    // AssignHeadpart('HairMaleNord08', 'HairKhajiitMale10');
    // AssignHeadpart('HairMaleNord09', 'HairKhajiitMale06');
    // AssignHeadpart('HairMaleNord10', 'HairKhajiitMale09');
    // AssignHeadpart('HairMaleNord11', 'HairKhajiitMale06');
    // AssignHeadpart('HairMaleNord11', 'HairKhajiitMale01');
    // AssignHeadpart('HairMaleNord12', 'HairKhajiitMale06');
    // AssignHeadpart('HairMaleNord13', 'HairKhajiitMale06');
    // AssignHeadpart('HairMaleNord14', 'HairKhajiitMale03');
    // AssignHeadpart('HairMaleNord14', 'HairKhajiitMale06');
    // AssignHeadpart('HairMaleNord15', 'HairKhajiitMale03');
    // AssignHeadpart('HairMaleNord15', 'HairKhajiitMale06');
    // AssignHeadpart('HairMaleNord16', 'HairKhajiitMale07');
    // AssignHeadpart('HairMaleNord17', 'HairKhajiitMale07');
    // AssignHeadpart('HairMaleNord18', 'HairKhajiitMale08');
    // AssignHeadpart('HairMaleNord19', 'HairKhajiitMale08');
    // AssignHeadpart('HairMaleNord20', 'HairKhajiitMale09');
    
    // Khajiit eyes
    // AssignHeadpart('MaleEyesHumanAmber', 'MaleEyesKhajiitBase');
    // AssignHeadpart('MaleEyesHumanAmberBlindRight', '');
    // AssignHeadpart('MaleEyesHumanBlind', 'MaleEyesKhajiitBlind');
    // AssignHeadpart('MaleEyesHumanBrightGreen', 'MaleEyesKhajiitOrange');
    // AssignHeadpart('MaleEyesHumanBrightGreenBlindRight', 'MaleEyesKhajiitOrangeNarrow');
    // AssignHeadpart('MaleEyesHumanBrown', 'MaleEyesKhajiitBase');
    // AssignHeadpart('MaleEyesHumanBrownBlindLeft', 'MaleEyesKhajiitBaseNarrow');
    // AssignHeadpart('MaleEyesHumanBrownBlindRight', 'MaleEyesKhajiitBaseNarrow');
    // AssignHeadpart('MaleEyesHumanBrownBloodShot', 'MaleEyesKhajiitBase');
    // AssignHeadpart('MaleEyesHumanDarkBlue', 'MaleEyesKhajiitBlue');
    // AssignHeadpart('MaleEyesHumanDemon', 'MaleEyesKhajiitYellowNarrow');
    // AssignHeadpart('MaleEyesHumanGreenHazelLeft', 'MaleEyesKhajiitOrangeNarrow');
    // AssignHeadpart('MaleEyesHumanGrey', 'MaleEyesKhajiitYellow');
    // AssignHeadpart('MaleEyesHumanHazel', 'MaleEyesKhajiitOrange');
    // AssignHeadpart('MaleEyesHumanHazelBrown', 'MaleEyesKhajiitOrangeNarrow');
    // AssignHeadpart('MaleEyesHumanIceBlue', 'MaleEyesKhajiitIce');
    // AssignHeadpart('MaleEyesHumanLeftBlindSingle', 'MaleEyesKhajiitBaseNarrow');
    // AssignHeadpart('MaleEyesHumanLightBlue', 'MaleEyesKhajiitIceNarrow');
    // AssignHeadpart('MaleEyesHumanLightBlueBlindLeft', 'MaleEyesKhajiitIceNarrow');
    // AssignHeadpart('MaleEyesHumanLightBlueBloodShot', 'MaleEyesKhajiitIceNarrow');
    // AssignHeadpart('MaleEyesHumanLightGrey', 'MaleEyesKhajiitIce');
    // AssignHeadpart('MaleEyesHumanLightIceGreyBlindLeft', 'MaleEyesKhajiitIceNarrow');
    // AssignHeadpart('MaleEyesHumanRightBlindSingle', 'MaleEyesKhajiitYellowNarrow');
    // AssignHeadpart('MaleEyesHumanRightHazleBrownRight', 'MaleEyesKhajiitBaseNarrow');
    // AssignHeadpart('MaleEyesHumanVampire', 'MaleEyesKhajiitVampire');

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
    LabelHeadpartList('DLC1HairFemaleValerica', 'TIEDBACK,ELABORATE,MATURE');
    LabelHeadpartList('HairFemaleImperial1', 'SHORT,NEAT,MILITARY');
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
    LabelHeadpartList('HairFemaleRedguard01', 'TIEDBACK,NEAT');
    LabelHeadpartList('HairFemaleRedguard02', 'SHORT');
    LabelHeadpartList('HairFemaleRedguard03', 'BUZZ,MILITARY,SHORT,BOLD');
    LabelHeadpartList('HairFemaleRedguard04', 'BUZZ,MILITARY,SHORT,BOLD');
    LabelHeadpartList('HairLineFemaleNord21', 'DREADS,FUNKY,BOLD,MOHAWK');
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
end;

end.