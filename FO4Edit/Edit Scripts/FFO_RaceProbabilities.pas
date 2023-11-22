{
FFO Furrifier Race Probabilities.
Author: Bad Dog 
  
Define races and probabilities for the different NPC classes, also for some specific NPCs.
Must be called early because this routine defines the furry races. TARGET_RACE in
FFO_Furrifier overrides all these.

By default, all NPCs are changed to furry races, children included. Ghouls are changed to 
Nightstalkers. 

Script allows customization of race assignments and what NPCs to affect. Any races
mentioned below that are not in the load order will be ignored.

Documentation: https://github.com/BadDogSkyrim/Modding-Tools/wiki
}

unit FFO_RaceProbabilities;

interface

implementation

uses BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;

//======================================================


Procedure SetRaceProbabilities();
begin
    // Probabilities are relative to each other and need not add up to 100.
    // So if all the predator races add up to 180, setting the horse race
    // to 18 means 1 NPC in 10 will be a horse.

    // Player's race
    SetClassProb(CLASS_PLAYER, 'FFOCheetahRace', 100);

    // Good fighters

    SetClassProb(CLASS_MINUTEMEN, 'FFOLykaiosRace', 30);
    SetClassProb(CLASS_MINUTEMEN, 'FFOFoxRace', 20);
    SetClassProb(CLASS_MINUTEMEN, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_MINUTEMEN, 'FFOLionRace', 30);
    SetClassProb(CLASS_MINUTEMEN, 'FFOTigerRace', 40);
    SetClassProb(CLASS_MINUTEMEN, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_MINUTEMEN, 'FFOHorseRace', 40);
    SetClassProb(CLASS_MINUTEMEN, 'FFODeerRace', 20);
	SetClassProb(CLASS_MINUTEMEN, 'DN_DinosaurRace', 20);
	SetClassProb(CLASS_MINUTEMEN, 'DN_DinosaurHybridRace', 10);
	SetClassProb(CLASS_MINUTEMEN, 'DN_DinosaurTriRace', 20);
	SetClassProb(CLASS_MINUTEMEN, 'DN_DinosaurParaRace', 5);	
	SetClassProb(CLASS_MINUTEMEN, 'PA_ProtoArgonianRace', 15);
	SetClassProb(CLASS_MINUTEMEN, 'aaaSharkRace', 5);	
	SetClassProb(CLASS_MINUTEMEN, 'DCM_DeathclawMutantRace', 15);
	SetClassProb(CLASS_MINUTEMEN, 'K9_RaiderDogRace', 5);
	SetClassProb(CLASS_MINUTEMEN, 'K9_GShepRace', 20);
	SetClassProb(CLASS_MINUTEMEN, 'K9_WolfRace', 15);
	SetClassProb(CLASS_MINUTEMEN, 'K9_HellhoundRace', 0);
	
    SetClassProb(CLASS_BOS, 'FFOLykaiosRace', 40);
    SetClassProb(CLASS_BOS, 'FFOFoxRace', 20);
    SetClassProb(CLASS_BOS, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_BOS, 'FFOLionRace', 20);
    SetClassProb(CLASS_BOS, 'FFOTigerRace', 20);
    SetClassProb(CLASS_BOS, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_BOS, 'FFOHorseRace', 30);
    SetClassProb(CLASS_BOS, 'FFODeerRace', 10);
	SetClassProb(CLASS_BOS, 'DN_DinosaurRace', 15);
	SetClassProb(CLASS_BOS, 'DN_DinosaurHybridRace', 5);
	SetClassProb(CLASS_BOS, 'DN_DinosaurTriRace', 5);
	SetClassProb(CLASS_BOS, 'DN_DinosaurParaRace', 5);	
	SetClassProb(CLASS_BOS, 'PA_ProtoArgonianRace', 15);
	SetClassProb(CLASS_BOS, 'DCM_DeathclawMutantRace', 10);
	SetClassProb(CLASS_BOS, 'K9_RaiderDogRace', 0);
	SetClassProb(CLASS_BOS, 'K9_GShepRace', 5);
	SetClassProb(CLASS_BOS, 'K9_WolfRace', 5);
	SetClassProb(CLASS_BOS, 'K9_HellhoundRace', 0);

    SetClassProb(CLASS_RR, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_RR, 'FFOFoxRace', 20);
    SetClassProb(CLASS_RR, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_RR, 'FFOLionRace', 30);
    SetClassProb(CLASS_RR, 'FFOTigerRace', 20);
    SetClassProb(CLASS_RR, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_RR, 'FFOHorseRace', 60);
    SetClassProb(CLASS_RR, 'FFODeerRace', 30);
	SetClassProb(CLASS_RR, 'DN_DinosaurRace', 5);
	SetClassProb(CLASS_RR, 'DN_DinosaurHybridRace', 5);
	SetClassProb(CLASS_RR, 'DN_DinosaurTriRace', 30);
	SetClassProb(CLASS_RR, 'DN_DinosaurParaRace', 15);	
	SetClassProb(CLASS_RR, 'PA_ProtoArgonianRace', 10);
	SetClassProb(CLASS_RR, 'DCM_DeathclawMutantRace', 5); 	
	SetClassProb(CLASS_RR, 'K9_RaiderDogRace', 0);
	SetClassProb(CLASS_RR, 'K9_GShepRace', 0);
	SetClassProb(CLASS_RR, 'K9_WolfRace', 0);
	SetClassProb(CLASS_RR, 'K9_HellhoundRace', 0);

    // Enemies

    SetClassProb(CLASS_GUNNER, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOFoxRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOLionRace', 60);
    SetClassProb(CLASS_GUNNER, 'FFOTigerRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOHorseRace', 10);
    SetClassProb(CLASS_GUNNER, 'FFODeerRace', 5);
	SetClassProb(CLASS_GUNNER, 'DN_DinosaurRace', 30);
	SetClassProb(CLASS_GUNNER, 'DN_DinosaurHybridRace', 20);
	SetClassProb(CLASS_GUNNER, 'DN_DinosaurTriRace', 5);
	SetClassProb(CLASS_GUNNER, 'DN_DinosaurParaRace', 5);
	SetClassProb(CLASS_GUNNER, 'PA_ProtoArgonianRace', 10);
	SetClassProb(CLASS_GUNNER, 'DCM_DeathclawMutantRace', 10); 
	SetClassProb(CLASS_GUNNER, 'K9_RaiderDogRace', 5);
	SetClassProb(CLASS_GUNNER, 'K9_GShepRace', 20);
	SetClassProb(CLASS_GUNNER, 'K9_WolfRace', 20);
	SetClassProb(CLASS_GUNNER, 'K9_HellhoundRace', 0);
	
    SetClassProb(CLASS_DISCIPLES, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOFoxRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOHyenaRace', 100);
    SetClassProb(CLASS_DISCIPLES, 'FFOLionRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOTigerRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOHorseRace', 8);
    SetClassProb(CLASS_DISCIPLES, 'FFODeerRace', 4);
	SetClassProb(CLASS_DISCIPLES, 'DN_DinosaurRace', 20);
	SetClassProb(CLASS_DISCIPLES, 'DN_DinosaurHybridRace', 20);
	SetClassProb(CLASS_DISCIPLES, 'DN_DinosaurTriRace', 8);
	SetClassProb(CLASS_DISCIPLES, 'DN_DinosaurParaRace', 4);
	SetClassProb(CLASS_DISCIPLES, 'PA_ProtoArgonianRace', 20);
	SetClassProb(CLASS_DISCIPLES, 'DCM_DeathclawMutantRace', 40); 
	SetClassProb(CLASS_DISCIPLES, 'K9_RaiderDogRace', 10);
	SetClassProb(CLASS_DISCIPLES, 'K9_GShepRace', 0);
	SetClassProb(CLASS_DISCIPLES, 'K9_WolfRace', 15);
	SetClassProb(CLASS_DISCIPLES, 'K9_HellhoundRace', 5);
	
    SetClassProb(CLASS_OPERATOR, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_OPERATOR, 'FFOFoxRace', 100);
    SetClassProb(CLASS_OPERATOR, 'FFOHyenaRace', 30);
    SetClassProb(CLASS_OPERATOR, 'FFOLionRace', 10);
    SetClassProb(CLASS_OPERATOR, 'FFOTigerRace', 10);
    SetClassProb(CLASS_OPERATOR, 'FFOCheetahRace', 10);
    SetClassProb(CLASS_OPERATOR, 'FFOHorseRace', 5);
    SetClassProb(CLASS_OPERATOR, 'FFODeerRace', 5);
	SetClassProb(CLASS_OPERATOR, 'DN_DinosaurRace', 10);
	SetClassProb(CLASS_OPERATOR, 'DN_DinosaurHybridRace', 20);
	SetClassProb(CLASS_OPERATOR, 'DN_DinosaurTriRace', 5);
	SetClassProb(CLASS_OPERATOR, 'DN_DinosaurParaRace', 5);
	SetClassProb(CLASS_OPERATOR, 'PA_ProtoArgonianRace', 20);
	SetClassProb(CLASS_OPERATOR, 'DCM_DeathclawMutantRace', 10); 
	SetClassProb(CLASS_OPERATOR, 'K9_RaiderDogRace', 0);
	SetClassProb(CLASS_OPERATOR, 'K9_GShepRace', 5);
	SetClassProb(CLASS_OPERATOR, 'K9_WolfRace', 5);
	SetClassProb(CLASS_OPERATOR, 'K9_HellhoundRace', 0);
	
    SetClassProb(CLASS_PACK, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_PACK, 'FFOFoxRace', 20);
    SetClassProb(CLASS_PACK, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_PACK, 'FFOLionRace', 20);
    SetClassProb(CLASS_PACK, 'FFOTigerRace', 20);
    SetClassProb(CLASS_PACK, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_PACK, 'FFOHorseRace', 5);
    SetClassProb(CLASS_PACK, 'FFODeerRace', 0);
	SetClassProb(CLASS_PACK, 'DN_DinosaurRace', 10);
	SetClassProb(CLASS_PACK, 'DN_DinosaurHybridRace', 5);
	SetClassProb(CLASS_PACK, 'DN_DinosaurTriRace', 5);
	SetClassProb(CLASS_PACK, 'DN_DinosaurParaRace', 0);
	SetClassProb(CLASS_PACK, 'PA_ProtoArgonianRace', 5);
	SetClassProb(CLASS_PACK, 'DCM_DeathclawMutantRace', 10); 
	SetClassProb(CLASS_PACK, 'K9_RaiderDogRace', 0);
	SetClassProb(CLASS_PACK, 'K9_GShepRace', 0);
	SetClassProb(CLASS_PACK, 'K9_WolfRace', 0);
	SetClassProb(CLASS_PACK, 'K9_HellhoundRace', 0);
	
    SetClassProb(CLASS_RAIDER, 'FFOLykaiosRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOFoxRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOHyenaRace', 50);
    SetClassProb(CLASS_RAIDER, 'FFOLionRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOTigerRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOCheetahRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOHorseRace', 16);
    SetClassProb(CLASS_RAIDER, 'FFODeerRace', 8);
	SetClassProb(CLASS_RAIDER, 'DN_DinosaurRace', 40);
	SetClassProb(CLASS_RAIDER, 'DN_DinosaurHybridRace', 30);
	SetClassProb(CLASS_RAIDER, 'DN_DinosaurTriRace', 16);
	SetClassProb(CLASS_RAIDER, 'DN_DinosaurParaRace', 8);
	SetClassProb(CLASS_RAIDER, 'PA_ProtoArgonianRace', 20);
	SetClassProb(CLASS_RAIDER, 'DCM_DeathclawMutantRace', 40); 
	SetClassProb(CLASS_RAIDER, 'K9_RaiderDogRace', 25);
	SetClassProb(CLASS_RAIDER, 'K9_GShepRace', 5);
	SetClassProb(CLASS_RAIDER, 'K9_WolfRace', 15);
	SetClassProb(CLASS_RAIDER, 'K9_HellhoundRace', 0);
	
    // 10:1 otters to others as trappers
    SetClassProb(CLASS_TRAPPER, 'FFOOtterRace', 700);
    SetClassProb(CLASS_TRAPPER, 'FFOLykaiosRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOFoxRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOLionRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOTigerRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOCheetahRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOHorseRace', 5);
    SetClassProb(CLASS_TRAPPER, 'FFODeerRace', 5);
	SetClassProb(CLASS_TRAPPER, 'DN_DinosaurRace', 10);
	SetClassProb(CLASS_TRAPPER, 'DN_DinosaurHybridRace', 10);
	SetClassProb(CLASS_TRAPPER, 'DN_DinosaurTriRace', 5);
	SetClassProb(CLASS_TRAPPER, 'DN_DinosaurParaRace', 5);
	SetClassProb(CLASS_TRAPPER, 'PA_ProtoArgonianRace', 10);
    SetClassProb(CLASS_TRAPPER, 'aaaSharkRace', 700);
	SetClassProb(CLASS_TRAPPER, 'DCM_DeathclawMutantRace', 10); 
	SetClassProb(CLASS_TRAPPER, 'K9_RaiderDogRace', 5);
	SetClassProb(CLASS_TRAPPER, 'K9_GShepRace', 5);
	SetClassProb(CLASS_TRAPPER, 'K9_WolfRace', 15);
	SetClassProb(CLASS_TRAPPER, 'K9_HellhoundRace', 5);
	
    // Neutrals 
    SetClassProb(CLASS_INSTITUTE, 'FFOLykaiosRace', 30);
    SetClassProb(CLASS_INSTITUTE, 'FFOFoxRace', 20);
    SetClassProb(CLASS_INSTITUTE, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_INSTITUTE, 'FFOLionRace', 30);
    SetClassProb(CLASS_INSTITUTE, 'FFOTigerRace', 40);
    SetClassProb(CLASS_INSTITUTE, 'FFOCheetahRace', 40);
    SetClassProb(CLASS_INSTITUTE, 'FFOHorseRace', 50);
    SetClassProb(CLASS_INSTITUTE, 'FFODeerRace', 50);
	SetClassProb(CLASS_INSTITUTE, 'DN_DinosaurRace', 10);
	SetClassProb(CLASS_INSTITUTE, 'DN_DinosaurHybridRace', 20);
	SetClassProb(CLASS_INSTITUTE, 'DN_DinosaurTriRace', 25);
	SetClassProb(CLASS_INSTITUTE, 'DN_DinosaurParaRace', 25);
	SetClassProb(CLASS_INSTITUTE, 'PA_ProtoArgonianRace', 10);
	SetClassProb(CLASS_INSTITUTE, 'DCM_DeathclawMutantRace', 15); 
	SetClassProb(CLASS_INSTITUTE, 'K9_RaiderDogRace', 0);
	SetClassProb(CLASS_INSTITUTE, 'K9_GShepRace', 15);
	SetClassProb(CLASS_INSTITUTE, 'K9_WolfRace', 10);
	SetClassProb(CLASS_INSTITUTE, 'K9_HellhoundRace', 0);
	
    // 10:1 otters to others in FH
    SetClassProb(CLASS_FARHARBOR, 'FFOLykaiosRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOFoxRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOHyenaRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOLionRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOTigerRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOCheetahRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOHorseRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFODeerRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOOtterRace', 500);
	SetClassProb(CLASS_FARHARBOR, 'aaaSharkRace', 500);
	SetClassProb(CLASS_FARHARBOR, 'DN_DinosaurRace', 5);
	SetClassProb(CLASS_FARHARBOR, 'DN_DinosaurHybridRace', 5);
	SetClassProb(CLASS_FARHARBOR, 'DN_DinosaurTriRace', 5);
	SetClassProb(CLASS_FARHARBOR, 'DN_DinosaurParaRace', 5);
	SetClassProb(CLASS_FARHARBOR, 'PA_ProtoArgonianRace', 5);
	SetClassProb(CLASS_FARHARBOR, 'DCM_DeathclawMutantRace', 5);
	SetClassProb(CLASS_FARHARBOR, 'K9_RaiderDogRace', 0);
	SetClassProb(CLASS_FARHARBOR, 'K9_GShepRace', 5);
	SetClassProb(CLASS_FARHARBOR, 'K9_WolfRace', 15);
	SetClassProb(CLASS_FARHARBOR, 'K9_HellhoundRace', 2);
 	
    SetClassProb(CLASS_ATOM, 'FFOLykaiosRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOFoxRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOHyenaRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOLionRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOTigerRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOCheetahRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOHorseRace', 5);
    SetClassProb(CLASS_ATOM, 'FFODeerRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOSnekdogRace', 40);
	SetClassProb(CLASS_ATOM, 'DN_DinosaurRace', 5);
	SetClassProb(CLASS_ATOM, 'DN_DinosaurHybridRace', 5);
	SetClassProb(CLASS_ATOM, 'DN_DinosaurTriRace', 5);
	SetClassProb(CLASS_ATOM, 'DN_DinosaurParaRace', 5);
	SetClassProb(CLASS_ATOM, 'PA_ProtoArgonianRace', 5);
	SetClassProb(CLASS_ATOM, 'DCM_DeathclawMutantRace', 40); 
	SetClassProb(CLASS_ATOM, 'K9_RaiderDogRace', 5);
	SetClassProb(CLASS_ATOM, 'K9_GShepRace', 0);
	SetClassProb(CLASS_ATOM, 'K9_WolfRace', 0);
	SetClassProb(CLASS_ATOM, 'K9_HellhoundRace', 5);
	
    SetClassProb(CLASS_SETTLER, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_SETTLER, 'FFOFoxRace', 20);
    SetClassProb(CLASS_SETTLER, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_SETTLER, 'FFOLionRace', 20);
    SetClassProb(CLASS_SETTLER, 'FFOTigerRace', 20);
    SetClassProb(CLASS_SETTLER, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_SETTLER, 'FFOHorseRace', 30);
    SetClassProb(CLASS_SETTLER, 'FFODeerRace', 30);
    SetClassProb(CLASS_SETTLER, 'FFOOtterRace', 6);
	SetClassProb(CLASS_SETTLER, 'DN_DinosaurRace', 10);
	SetClassProb(CLASS_SETTLER, 'DN_DinosaurHybridRace', 3);
	SetClassProb(CLASS_SETTLER, 'DN_DinosaurTriRace', 15);
	SetClassProb(CLASS_SETTLER, 'DN_DinosaurParaRace', 15);
	SetClassProb(CLASS_SETTLER, 'PA_ProtoArgonianRace', 10);
    SetClassProb(CLASS_SETTLER, 'aaaSharkRace', 3);
	SetClassProb(CLASS_SETTLER, 'DCM_DeathclawMutantRace', 10); 
	SetClassProb(CLASS_SETTLER, 'K9_RaiderDogRace', 5);
	SetClassProb(CLASS_SETTLER, 'K9_GShepRace', 10);
	SetClassProb(CLASS_SETTLER, 'K9_WolfRace', 10);
	SetClassProb(CLASS_SETTLER, 'K9_HellhoundRace', 2);
	
    // Followers. There's at least one follower of each race.
    SetClassProb(CLASS_GARVEY, 'FFOLionRace', 100);
    SetClassProb(CLASS_CAIT, 'FFOFoxRace', 100);
    SetClassProb(CLASS_DANSE, 'FFOLykaiosRace', 100);
    SetClassProb(CLASS_DEACON, 'FFOHorseRace', 100);
    SetClassProb(CLASS_GAGE, 'FFOHyenaRace', 100);
    SetClassProb(CLASS_LONGFELLOW, 'FFOOtterRace', 100);
    SetClassProb(CLASS_MACCREADY, 'FFOCheetahRace', 100);
    SetClassProb(CLASS_PIPER, 'FFODeerRace', 100);
    SetClassProb(CLASS_X688, 'FFOTigerRace', 100);

    // Specific NPCs or families. Ensures relatives and older/younger
    // versions of the same NPC have the same race.
    SetClassProb(CLASS_BOBROV, 'FFODeerRace', 100);
    SetClassProb(CLASS_CABOT, 'FFOCheetahRace', 100);
    SetClassProb(CLASS_DALTON, 'FFOOtterRace', 100);
    SetClassProb(CLASS_DELUCA, 'FFODeerRace', 100);
    SetClassProb(CLASS_KELLOGG, 'FFOTigerRace', 100);
    SetClassProb(CLASS_KYLE, 'FFOFoxRace', 100);
    SetClassProb(CLASS_PEMBROKE, 'FFOHorseRace', 100);

    // Specific NPCs
    // These override TARGET_RACE.
    AssignNPCRace('MamaMurphy', 'FFOLionRace'); // Her hat is tailored to the lioness head
    AssignNPCRace('DLC04Mason', 'FFOHorseRace'); // I just like him this way
end;

//==================================================================================
// Do any special tailoring for specific races.
//
// SetHeadpartProb defines the probability of assigning a headpart for a NPC.
//
// SetMorphProbability provides a probability of using different morphs.If no
// probabilty is set for a morph group, it will be applied at 100% probability.
// Parameters are:
//      Race name
//      Sex (MALE/FEMALE)
//      Name of the morph group in the race record
//      Probability at which a morph from this group should be applied to a NPC
//      Min morph value when this morph is applied (0-100)
//      Max morph value when this morph is applied (0-100)
//      Morph distribution (EVEN, SKEW0,  SKEW1)
//
// ExcludeMorph tells the furrifier not to apply a particular morph ever.
//
// SetMorphProbability sets the probability and value range for 
// morphs (not facebones morphs).
//
// SetFaceMorph defines the facebones values to use.
// 
// AddChildRace specifies that a race is the child for another race.
//
// SetTintProbability sets the probability of using particular tint layer.
//
// SetTintColors limits the colors that can be used for a tint layer.
Procedure TailorRaces(); 
begin
    // ---------- Cheetahs ---------- 
    AddChildRace('FFOCheetahRace', 'FFOCheetahChildRace');

    ExcludeMorph('FFOCheetahRace', MALE, 'Child');

    // ---------- Deer ---------- 
    AddChildRace('FFODeerRace', 'FFODeerChildRace');
    SetHeadpartProb('FFODeerRace', MALE, HEADPART_MOUTH, 0); // Mouth in race record
    SetHeadpartProb('FFODeerRace', FEMALE, HEADPART_MOUTH, 0); // Mouth in race record
    
    // ---------- Foxes ---------- 
    AddChildRace('FFOFoxRace', 'FFOFoxChildRace');

    ExcludeMorph('FFOFoxRace', FEMALE, 'Child');
    ExcludeMorph('FFOFoxRace', FEMALE, 'Neck');
    ExcludeMorph('FFOFoxRace', MALE, 'Child');
    ExcludeMorph('FFOFoxRace', MALE, 'Neck');

    // Face morphs, using faceBones, are ignored unless provided in this list.
    // If provided, a random value between the min and max will be chosen.
    SetFaceMorph('FFOFoxRace', FEMALE, 'Ears - Full', 
        {loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
    SetFaceMorph('FFOFoxRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -0.7,  {rot min} 0, 0, 0, {scale min} -0.2,
        {loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale max} -0);
    SetFaceMorph('FFOFoxRace', MALE, 'Ears - Full', 
        {loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
    SetFaceMorph('FFOFoxRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -0.7,  {rot min} 0, 0, 0, {scale min} -0.2,
        {loc max} 0, 0, 0.2,  {rot max} 0, 0, 0, {scale max} -0);

    // ---------- Horses ---------- 
    AddChildRace('FFOHorseRace', 'FFOHorseChildRace');

    SetTintProbability('FFOHorseRace', MALE, TL_MUZZLE, 60);
    SetTintProbability('FFOHorseRace', FEMALE, TL_MUZZLE, 60);
    SetTintProbability('FFOHorseRace', MALE, TL_NOSE, 50);
    SetTintProbability('FFOHorseRace', FEMALE, TL_NOSE, 50);

    ExcludeMorph('FFOHorseRace', FEMALE, 'Child Neck');
    ExcludeMorph('FFOHorseRace', FEMALE, 'Horse - Neck');
    SetMorphProbability('FFOHorseRace', FEMALE, 'Horse - Ears', 80, 0, 100, SKEW0);
    SetMorphProbability('FFOHorseRace', MALE, 'Horse - Nose Size', 80, 0, 100, SKEW0);
    ExcludeMorph('FFOHorseRace', MALE, 'Horse - Neck');
    ExcludeMorph('FFOHorseRace', MALE, 'Jaws');
    ExcludeMorph('FFOHorseRace', MALE, 'Mouth');
    ExcludeMorph('FFOHorseRace', MALE, 'Neck');
    SetMorphProbability('FFOHorseRace', MALE, 'Horse - Ears', 80, 0, 100, SKEW0);
    SetMorphProbability('FFOHorseRace', MALE, 'Horse - Nose Size', 80, 0, 100, SKEW0);
    SetMorphProbability('FFOHorseRace', MALE, 'Horse - Nose Shape', 80, 0, 100, EVEN);

    SetFaceMorph('FFOHorseRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, 0,  {rot min} 0, 0, 0, {scale min} -0.2,
        {loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale max} -0);
    SetFaceMorph('FFOHorseRace', FEMALE, 'Nose - Bridge', 
        {loc min} 0, -0.3, 0,  {rot min} 0, 0, 0, {scale min} -0,
        {loc max} 0, 0.4, 0,  {rot max} 0, 0, 0, {scale max} -0);
    SetFaceMorph('FFOHorseRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, 0,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale max} -0);

    // ---------- Hyenas ---------- 
    AddChildRace('FFOHyenaRace', 'FFOHyenaChildRace');

    ExcludeMorph('FFOHyenaRace', FEMALE, 'Face');
    ExcludeMorph('FFOHyenaRace', MALE, 'Face');

    // Acceptable colors for tint layers. This is so specialty colors can 
    // be provided without being picked up by the furrifier. 
    SetTintColors('FFOHyenaRace', FEMALE, TL_EAR, '|FFOFurBlack|FFOFurBlueBlack|');
    SetTintColors('FFOHyenaRace', MALE, TL_EAR, '|FFOFurBlack|FFOFurBlueBlack|');

    SetFaceMorph('FFOHyenaRace', FEMALE, 'Brows', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0);
    SetFaceMorph('FFOHyenaRace', FEMALE, 'Cheeks Front', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 0.5,  {rot max} 0, 0, 0, {scale max} 0);
    SetFaceMorph('FFOHyenaRace', FEMALE, 'Ears - Full', 
        {loc min} 0, 0, 0,  {rot min} 0, 0, 0, {scale min} -1.0,
        {loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale max} 1.0);
    SetFaceMorph('FFOHyenaRace', FEMALE, 'Muzzle - Full', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} -0.5,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0.5);
    SetFaceMorph('FFOHyenaRace', MALE, 'Brows', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0);
    SetFaceMorph('FFOHyenaRace', MALE, 'Cheeks Front', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 0.5,  {rot max} 0, 0, 0, {scale max} 0);
    SetFaceMorph('FFOHyenaRace', MALE, 'Ears - Full', 
        {loc min} 0, 0, 0,  {rot min} 0, 0, 0, {scale min} -0.8,
        {loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale max} 1.0);
    SetFaceMorph('FFOHyenaRace', MALE, 'Muzzle - Full', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} -0.5,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0.5);

    // ---------- Lions ---------- 
    AddChildRace('FFOLionRace', 'FFOLionChildRace');

    ExcludeMorph('FFOLionRace', FEMALE, 'Child Neck');
    ExcludeMorph('FFOLionRace', MALE, 'Child Neck');
    SetMorphProbability('FFOLionRace', FEMALE, 'Mouth', 30, 50, 100, SKEW1); // Sabretooth
    SetMorphProbability('FFOLionRace', MALE, 'Mouth', 30, 50, 100, SKEW1); // Sabretooth

    SetFaceMorph('FFOLionRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -0.4,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 0.5,  {rot max} 0, 0, 0, {scale max} 0);
    SetFaceMorph('FFOLionRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -0.8,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0, 0, 0.7,  {rot max} 0, 0, 0, {scale max} 0.5);

    // ---------- Lykaios ---------- 
    AddChildRace('FFOLykaiosRace', 'FFOLykaiosChildRace');
    // Raccoon-style eye mask. Don't hand it out automatically.
    SetTintProbability('FFOLykaiosRace', FEMALE, TL_MASK, 0);
    SetTintProbability('FFOLykaiosRace', MALE, TL_MASK, 0);

    SetTintColors('FFOLykaiosRace', FEMALE, TL_MUZZLE, '|FFOFurBlack|FFOFurBrownD|');
    SetTintColors('FFOLykaiosRace', MALE, TL_MUZZLE, '|FFOFurBlack|FFOFurBrownD|');

    ExcludeMorph('FFOLykaiosRace', FEMALE, 'Child Neck');
    ExcludeMorph('FFOLykaiosRace', FEMALE, 'Neck');
    SetMorphProbability('FFOLykaiosRace', FEMALE, 'Nose', 80, 0, 75, SKEW0);
    ExcludeMorph('FFOLykaiosRace', MALE, 'Child Neck');
    SetMorphProbability('FFOLykaiosRace', MALE, 'Nose', 80, 0, 75, SKEW0);

    SetFaceMorph('FFOLykaiosRace', FEMALE, 'Ears - Full', 
        {loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
    SetFaceMorph('FFOLykaiosRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -0.7,  {rot min} 0, 0, 0, {scale min} -0.2,
        {loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale max} -0);
    SetFaceMorph('FFOLykaiosRace', MALE, 'Ears - Full', 
        {loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
    SetFaceMorph('FFOLykaiosRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -0.7,  {rot min} 0, 0, 0, {scale min} -0.2,
        {loc max} 0, 0, 0.2,  {rot max} 0, 0, 0, {scale max} -0);

    // ---------- Otters ---------- 
    AddChildRace('FFOOtterRace', 'FFOOtterChildRace');

    // ---------- Snekdogs ---------- 
    AddChildRace('FFOSnekdogRace', 'FFOSnekdogChildRace');
    ExcludeMorph('FFOSnekdogRace', MALE, 'Neck');

    SetFaceMorph('FFOSnekdogRace', FEMALE, 'Ears - Full', 
        {loc min} 0, -1, 0,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 1, 0,  {rot max} 0, 0, 0, {scale max} 0);
    SetFaceMorph('FFOSnekdogRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -0.8,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0);

    SetFaceMorph('FFOSnekdogRace', FEMALE, 'Ears - Full', 
        {loc min} 0, -1, 0,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 1, 0,  {rot max} 0, 0, 0, {scale max} 0);
    SetFaceMorph('FFOSnekdogRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -0.8,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0);
	
    // ---------- Tigers ---------- 
    AddChildRace('FFOTigerRace', 'FFOTigerChildRace');

    ExcludeMorph('FFOTigerRace', FEMALE, 'Child Neck');
    ExcludeMorph('FFOTigerRace', MALE, 'Child Neck');

    // ---------- Sharks ---------- 
    AddChildRace('aaaSharkRace', 'FFOOtterChildRace'); // Selachii are most common in Far Harbor, similar to Otters
    SetHeadpartProb('aaaSharkRace', MALE, HEADPART_FACIAL_HAIR, 40); // Double Teeth Row
    SetHeadpartProb('aaaSharkRace', FEMALE, HEADPART_FACIAL_HAIR, 40); // Double Teeth Row

    SetTintProbability('aaaSharkRace', MALE, TL_EYELINER, 10);
    SetTintProbability('aaaSharkRace', MALE, TL_PAINT, 0);
    SetTintProbability('aaaSharkRace', MALE, TL_MASK, 0);
    SetTintProbability('aaaSharkRace', MALE, TL_NOSE, 0);
    SetTintProbability('aaaSharkRace', MALE, TL_CHIN, 0);
    SetTintProbability('aaaSharkRace', MALE, TL_MUZZLE, 0);
    SetTintProbability('aaaSharkRace', MALE, TL_FOREHEAD, 0);
    SetTintProbability('aaaSharkRace', MALE, TL_MISC, 0);
    SetTintProbability('aaaSharkRace', MALE, TL_MUZZLE_STRIPE, 45);
    SetTintProbability('aaaSharkRace', MALE, TL_SCAR, 10);
    SetTintProbability('aaaSharkRace', FEMALE, TL_EYELINER, 15);
    SetTintProbability('aaaSharkRace', FEMALE, TL_PAINT, 0);
    SetTintProbability('aaaSharkRace', FEMALE, TL_MASK, 0);
    SetTintProbability('aaaSharkRace', FEMALE, TL_NOSE, 0);
    SetTintProbability('aaaSharkRace', FEMALE, TL_CHIN, 0);
    SetTintProbability('aaaSharkRace', FEMALE, TL_MUZZLE, 0);
    SetTintProbability('aaaSharkRace', FEMALE, TL_FOREHEAD, 0);
    SetTintProbability('aaaSharkRace', FEMALE, TL_MISC, 0);
    SetTintProbability('aaaSharkRace', FEMALE, TL_MUZZLE_STRIPE, 45);
    SetTintProbability('aaaSharkRace', FEMALE, TL_SCAR, 10);

    SetTintColors('aaaSharkRace', FEMALE, TL_EYELINER, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('aaaSharkRace', FEMALE, TL_PAINT, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('aaaSharkRace', FEMALE, TL_MASK, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('aaaSharkRace', FEMALE, TL_NOSE, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('aaaSharkRace', FEMALE, TL_CHIN, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('aaaSharkRace', FEMALE, TL_MUZZLE, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('aaaSharkRace', FEMALE, TL_FOREHEAD, '|black|');
    SetTintColors('aaaSharkRace', FEMALE, TL_MISC, '|black|');
    SetTintColors('aaaSharkRace', FEMALE, TL_MUZZLE_STRIPE, '|black|');
    SetTintColors('aaaSharkRace', MALE, TL_EYELINER, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('aaaSharkRace', MALE, TL_PAINT, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('aaaSharkRace', MALE, TL_MASK, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('aaaSharkRace', MALE, TL_NOSE, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('aaaSharkRace', MALE, TL_CHIN, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('aaaSharkRace', MALE, TL_MUZZLE, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('aaaSharkRace', MALE, TL_FOREHEAD, '|black|');
    SetTintColors('aaaSharkRace', MALE, TL_MISC, '|black|');
    SetTintColors('aaaSharkRace', MALE, TL_MUZZLE_STRIPE, '|black|');

    SetMorphProbability('aaaSharkRace', FEMALE, 'Eyes', 60, 20, 80, SKEW1);
    SetMorphProbability('aaaSharkRace', FEMALE, 'Nose', 70, 10, 100, SKEW1);
    ExcludeMorph('aaaSharkRace', FEMALE, 'Mouth');
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Brows Back/Forward', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Brows In/Out', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Brows Up/Down', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Nose Up/Down', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Cheeks Up/Down', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Cheeks In/Out', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Chin Up/Down', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Chin Thin/Wide', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Jaw Back/Forward', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Jaw Up/Down', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Jaw Narrow/Wide', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Lips Up/Down', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Lips In/Out', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Nose Long/Short', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', FEMALE, 'SLIDER - Overbite/Underbite', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'Eyes', 60, 20, 80, SKEW1);
    SetMorphProbability('aaaSharkRace', MALE, 'Nose', 70, 10, 100, SKEW1);
    ExcludeMorph('aaaSharkRace', MALE, 'Mouth');
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Brows Back/Forward', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Brows In/Out', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Brows Up/Down', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Nose Up/Down', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Cheeks Up/Down', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Cheeks In/Out', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Chin Up/Down', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Chin Thin/Wide', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Jaw Back/Forward', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Jaw Up/Down', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Jaw Narrow/Wide', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Lips Up/Down', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Lips In/Out', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Nose Long/Short', 35, 0, 100, SKEW0);
    SetMorphProbability('aaaSharkRace', MALE, 'SLIDER - Overbite/Underbite', 35, 0, 100, SKEW0);

    SetFaceMorph('aaaSharkRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -0.6,  {rot min} 0, 0, 0, {scale min} 0.25,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0.25);
    SetFaceMorph('aaaSharkRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -0.6,  {rot min} 0, 0, 0, {scale min} 0.25,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0.25);

	// ---------- K9 ----------

	AddChildRace('K9_RaiderDogRace', 'K9_RaiderDogChildRace');
	AddChildRace('K9_GShepRace', 'K9_GShepChildRace');
	AddChildRace('K9_WolfRace', 'K9_WolfChildRace');
	AddChildRace('K9_HellhoundRace', 'K9_WolfChildRace');
	AddChildRace('K9_DobermannRace', 'K9_DobermannChildRace');
	
	SetHeadpartProb('K9_GShepRace', MALE, HEADPART_FACIAL_HAIR, 70);
	SetHeadpartProb('K9_GShepRace', FEMALE, HEADPART_FACIAL_HAIR, 70);
	SetHeadpartProb('K9_GShepRace', MALE, HEADPART_MOUTH, 0); // Mouth in race record
	SetHeadpartProb('K9_GShepRace', FEMALE, HEADPART_MOUTH, 0); // Mouth in race record
	SetHeadpartProb('K9_HellhoundRace', MALE, HEADPART_MOUTH, 0); // Mouth in race record
	SetHeadpartProb('K9_HellhoundRace', FEMALE, HEADPART_MOUTH, 0); // Mouth in race record
	SetHeadpartProb('K9_RaiderDogRace', MALE, HEADPART_MOUTH, 0); // Mouth in race record
	SetHeadpartProb('K9_RaiderDogRace', FEMALE, HEADPART_MOUTH, 0); // Mouth in race record
	SetHeadpartProb('K9_WolfRace', MALE, HEADPART_MOUTH, 0); // Mouth in race record
	SetHeadpartProb('K9_WolfRace', FEMALE, HEADPART_MOUTH, 0); // Mouth in race record
	SetHeadpartProb('K9_DobermannRace', MALE, HEADPART_MOUTH, 0); // Mouth in race record
	SetHeadpartProb('K9_DobermannRace', FEMALE, HEADPART_MOUTH, 0); // Mouth in race record
	
	SetHeadpartProb('K9_GShepChildRace', MALE, HEADPART_FACIAL_HAIR, 50);
	SetHeadpartProb('K9_GShepChildRace', FEMALE, HEADPART_FACIAL_HAIR, 50);
	SetHeadpartProb('K9_GShepChildRace', MALE, HEADPART_MOUTH, 0); // Mouth in ChildRace record
	SetHeadpartProb('K9_GShepChildRace', FEMALE, HEADPART_MOUTH, 0); // Mouth in ChildRace record
	SetHeadpartProb('K9_HellhoundChildRace', MALE, HEADPART_MOUTH, 0); // Mouth in ChildRace record
	SetHeadpartProb('K9_HellhoundChildRace', FEMALE, HEADPART_MOUTH, 0); // Mouth in ChildRace record
	SetHeadpartProb('K9_RaiderDogChildRace', MALE, HEADPART_MOUTH, 0); // Mouth in ChildRace record
	SetHeadpartProb('K9_RaiderDogChildRace', FEMALE, HEADPART_MOUTH, 0); // Mouth in ChildRace record
	SetHeadpartProb('K9_WolfChildRace', MALE, HEADPART_MOUTH, 0); // Mouth in ChildRace record
	SetHeadpartProb('K9_WolfChildRace', FEMALE, HEADPART_MOUTH, 0); // Mouth in ChildRace record
	SetHeadpartProb('K9_DobermannChildRace', MALE, HEADPART_MOUTH, 0); // Mouth in ChildRace record
	SetHeadpartProb('K9_DobermannChildRace', FEMALE, HEADPART_MOUTH, 0); // Mouth in ChildRace record
	
	SetTintProbability('K9_GShepRace', MALE, TL_SCAR, 5);
	SetTintProbability('K9_GShepRace', FEMALE, TL_SCAR, 5);
	SetTintProbability('K9_WolfRace', MALE, TL_SCAR, 5);
	SetTintProbability('K9_WolfRace', FEMALE, TL_SCAR, 5);
	SetTintProbability('K9_RaiderDogRace', MALE, TL_SCAR, 5);
	SetTintProbability('K9_RaiderDogRace', FEMALE, TL_SCAR, 5);
	SetTintProbability('K9_DobermannRace', MALE, TL_SCAR, 5);
	SetTintProbability('K9_DobermannRace', FEMALE, TL_SCAR, 5);
	
	SetMorphProbability('K9_WolfRace', FEMALE, 'Head', 30, 20, 100, SKEW0);
	SetMorphProbability('K9_WolfRace', MALE, 'Head', 30, 20, 100, SKEW0);
	SetMorphProbability('K9_DobermannRace', FEMALE, 'Ears', 30, 70, 100, EVEN);
	SetMorphProbability('K9_DobermannRace', MALE, 'Ears', 30, 70, 100, EVEN);
	ExcludeMorph('K9_HellhoundRace', FEMALE, 'Head');
	ExcludeMorph('K9_HellhoundRace', MALE, 'Head');
	SetMorphProbability('K9_WolfChildRace', FEMALE, 'Head', 30, 20, 100, SKEW0);
	SetMorphProbability('K9_WolfChildRace', MALE, 'Head', 30, 20, 100, SKEW0);
	SetMorphProbability('K9_DobermannChildRace', FEMALE, 'Ears', 30, 70, 100, EVEN);
	SetMorphProbability('K9_DobermannChildRace', MALE, 'Ears', 30, 70, 100, EVEN);
	
	SetFaceMorph('K9_GShepRace', FEMALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_GShepRace', FEMALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_GShepRace', FEMALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_GShepRace', MALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_GShepRace', MALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_GShepRace', MALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
	
	SetFaceMorph('K9_HellhoundRace', FEMALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_HellhoundRace', FEMALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_HellhoundRace', FEMALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_HellhoundRace', MALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_HellhoundRace', MALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_HellhoundRace', MALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
		
	SetFaceMorph('K9_RaiderDogRace', FEMALE, 'Ears - Full', 
		{loc min} 0, 0, 0,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_RaiderDogRace', FEMALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_RaiderDogRace', FEMALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_RaiderDogRace', MALE, 'Ears - Full', 
		{loc min} 0, 0, 0,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_RaiderDogRace', MALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_RaiderDogRace', MALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
		
	SetFaceMorph('K9_WolfRace', FEMALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_WolfRace', FEMALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_WolfRace', FEMALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_WolfRace', MALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_WolfRace', MALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_WolfRace', MALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
		
	SetFaceMorph('K9_DobermannRace', FEMALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_DobermannRace', FEMALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_DobermannRace', FEMALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_DobermannRace', MALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_DobermannRace', MALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_DobermannRace', MALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
		
	SetFaceMorph('K9_GShepChildRace', FEMALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_GShepChildRace', FEMALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_GShepChildRace', FEMALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_GShepChildRace', MALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_GShepChildRace', MALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_GShepChildRace', MALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
	
	SetFaceMorph('K9_HellhoundChildRace', FEMALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_HellhoundChildRace', FEMALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_HellhoundChildRace', FEMALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_HellhoundChildRace', MALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_HellhoundChildRace', MALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_HellhoundChildRace', MALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
		
	SetFaceMorph('K9_RaiderDogChildRace', FEMALE, 'Ears - Full', 
		{loc min} 0, 0, 0,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_RaiderDogChildRace', FEMALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_RaiderDogChildRace', FEMALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_RaiderDogChildRace', MALE, 'Ears - Full', 
		{loc min} 0, 0, 0,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_RaiderDogChildRace', MALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_RaiderDogChildRace', MALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
		
	SetFaceMorph('K9_WolfChildRace', FEMALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_WolfChildRace', FEMALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_WolfChildRace', FEMALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_WolfChildRace', MALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_WolfChildRace', MALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_WolfChildRace', MALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
		
	SetFaceMorph('K9_DobermannChildRace', FEMALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_DobermannChildRace', FEMALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_DobermannChildRace', FEMALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_DobermannChildRace', MALE, 'Ears - Full', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
	SetFaceMorph('K9_DobermannChildRace', MALE, 'Cheeks', 
		{loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.3,
		{loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.3);
	SetFaceMorph('K9_DobermannChildRace', MALE, 'Nose - Full', 
		{loc min} 0, -0.05, -0.5,  {rot min} -0.25, 0, 0, {scale min} -0.4,
		{loc max} 0, 0.05, 0.5,  {rot max} 0.25, 0, 0, {scale max} 0.4);

    // ---------- Proto-Argonians ---------- 
    AddChildRace('PA_ProtoArgonianRace', 'FFOSnekdogChildRace'); // Reptilian
    SetHeadpartProb('PA_ProtoArgonianRace', MALE, HEADPART_FACIAL_HAIR, 90); // Horns (& fins)
    SetHeadpartProb('PA_ProtoArgonianRace', FEMALE, HEADPART_FACIAL_HAIR, 90); // Horns (& fins)

    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_CHEEK_COLOR, 0);
    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_EYEBROW, 0);
    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_EYELINER, 0);
    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_FOREHEAD, 0);
    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_LIP_COLOR, 0);
    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_MASK, 0);
    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_MISC, 0);
    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_MUZZLE, 0);
    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_MUZZLE_STRIPE, 0);
    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_NECK, 0);
    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_NOSE, 0);
    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_PAINT, 0);
    SetTintProbability('PA_ProtoArgonianRace', FEMALE, TL_SCAR, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_CHEEK_COLOR, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_EYEBROW, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_EYELINER, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_FOREHEAD, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_LIP_COLOR, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_MASK, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_MISC, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_MUZZLE, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_MUZZLE_STRIPE, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_NECK, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_NOSE, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_PAINT, 0);
    SetTintProbability('PA_ProtoArgonianRace', MALE, TL_SCAR, 0);

    SetTintColors('PA_ProtoArgonianRace', FEMALE, TL_CHEEK_COLOR, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', FEMALE, TL_EYEBROW, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', FEMALE, TL_EYELINER, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', FEMALE, TL_FOREHEAD, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', FEMALE, TL_LIP_COLOR, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', FEMALE, TL_MASK, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', FEMALE, TL_MISC, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', FEMALE, TL_MUZZLE, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', FEMALE, TL_MUZZLE_STRIPE, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', FEMALE, TL_NECK, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', FEMALE, TL_NOSE, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', FEMALE, TL_PAINT, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', MALE, TL_CHEEK_COLOR, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', MALE, TL_EYEBROW, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', MALE, TL_EYELINER, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', MALE, TL_FOREHEAD, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', MALE, TL_LIP_COLOR, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', MALE, TL_MASK, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', MALE, TL_MISC, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', MALE, TL_MUZZLE, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', MALE, TL_MUZZLE_STRIPE, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', MALE, TL_NECK, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', MALE, TL_NOSE, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');
    SetTintColors('PA_ProtoArgonianRace', MALE, TL_PAINT, '|black|WarpaintRed01|WarpaintRed02|WarpaintRed03|WarpaintBlue03|WarpaintBlue04|WarpaintGreen01|WarpaintGreen02|WarpaintGreen03|WarpaintOrange01|WarpaintOrange02|WarpaintYellow01|WarpaintYellow02|WarpaintYellow03|');

    SetMorphProbability('PA_ProtoArgonianRace', FEMALE, 'Eyes', 70, 0, 100, EVEN);
    SetMorphProbability('PA_ProtoArgonianRace', FEMALE, 'Tusks', 70, 50, 100, SKEW1);
    SetMorphProbability('PA_ProtoArgonianRace', FEMALE, 'Head', 70, 0, 100, EVEN);
    SetMorphProbability('PA_ProtoArgonianRace', MALE, 'Eyes', 70, 0, 100, EVEN);
    SetMorphProbability('PA_ProtoArgonianRace', MALE, 'Tusks', 70, 50, 100, SKEW1);
    SetMorphProbability('PA_ProtoArgonianRace', MALE, 'Head', 70, 0, 100, EVEN);

    SetFaceMorph('PA_ProtoArgonianRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0);
    SetFaceMorph('PA_ProtoArgonianRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0);

    // ---------- T-Rex Dinos ---------- 
    AddChildRace('DN_DinosaurRace', 'FFOSnekdogChildRace'); // Reptilian
    SetHeadpartProb('DN_DinosaurRace', MALE, HEADPART_FACIAL_HAIR, 30); // Piercings
    SetHeadpartProb('DN_DinosaurRace', FEMALE, HEADPART_FACIAL_HAIR, 30); // Piercings

    SetTintProbability('DN_DinosaurRace', FEMALE, TL_EYELINER, 0);
    SetTintProbability('DN_DinosaurRace', FEMALE, TL_MASK, 0);
    SetTintProbability('DN_DinosaurRace', FEMALE, TL_MUZZLE_STRIPE, 40);
    SetTintProbability('DN_DinosaurRace', FEMALE, TL_NOSE, 0);
    SetTintProbability('DN_DinosaurRace', MALE, TL_EYELINER, 0);
    SetTintProbability('DN_DinosaurRace', MALE, TL_MASK, 0);
    SetTintProbability('DN_DinosaurRace', MALE, TL_MUZZLE_STRIPE, 40);
    SetTintProbability('DN_DinosaurRace', MALE, TL_NOSE, 0);

    SetTintColors('DN_DinosaurRace', FEMALE, TL_EYELINER, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurRace', FEMALE, TL_MASK, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurRace', FEMALE, TL_MUZZLE_STRIPE, '|black||');
    SetTintColors('DN_DinosaurRace', FEMALE, TL_NOSE, '|black|');
    SetTintColors('DN_DinosaurRace', MALE, TL_EYELINER, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurRace', MALE, TL_MASK, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurRace', MALE, TL_MUZZLE_STRIPE, '|black||');
    SetTintColors('DN_DinosaurRace', MALE, TL_NOSE, '|black|');

    SetMorphProbability('DN_DinosaurRace', FEMALE, 'Mouth', 50, 100, 100, EVEN);
    SetMorphProbability('DN_DinosaurRace', MALE, 'Mouth', 50, 100, 100, EVEN);

    SetFaceMorph('DN_DinosaurRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0);
    SetFaceMorph('DN_DinosaurRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0);


    // ---------- Triceratops Dinos ---------- 
    AddChildRace('DN_DinosaurTriRace', 'FFOSnekdogChildRace'); // Reptilian
    SetHeadpartProb('DN_DinosaurTriRace', MALE, HEADPART_FACIAL_HAIR, 30); // Piercings
    SetHeadpartProb('DN_DinosaurTriRace', FEMALE, HEADPART_FACIAL_HAIR, 30); // Piercings

    SetTintProbability('DN_DinosaurTriRace', FEMALE, TL_EYELINER, 0);
    SetTintProbability('DN_DinosaurTriRace', FEMALE, TL_MASK, 0);
    SetTintProbability('DN_DinosaurTriRace', FEMALE, TL_MUZZLE_STRIPE, 40);
    SetTintProbability('DN_DinosaurTriRace', FEMALE, TL_NOSE, 0);
    SetTintProbability('DN_DinosaurTriRace', MALE, TL_EYELINER, 0);
    SetTintProbability('DN_DinosaurTriRace', MALE, TL_MASK, 0);
    SetTintProbability('DN_DinosaurTriRace', MALE, TL_MUZZLE_STRIPE, 40);
    SetTintProbability('DN_DinosaurTriRace', MALE, TL_NOSE, 0);

    SetTintColors('DN_DinosaurTriRace', FEMALE, TL_EYELINER, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurTriRace', FEMALE, TL_MASK, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurTriRace', FEMALE, TL_MUZZLE_STRIPE, '|black||');
    SetTintColors('DN_DinosaurTriRace', FEMALE, TL_NOSE, '|black|');
    SetTintColors('DN_DinosaurTriRace', MALE, TL_EYELINER, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurTriRace', MALE, TL_MASK, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurTriRace', MALE, TL_MUZZLE_STRIPE, '|black||');
    SetTintColors('DN_DinosaurTriRace', MALE, TL_NOSE, '|black|');

    // ---------- Parasaurolophus Dinos ---------- 
    AddChildRace('DN_DinosaurParaRace', 'FFOSnekdogChildRace'); // Reptilian

    SetTintProbability('DN_DinosaurParaRace', FEMALE, TL_EYELINER, 0);
    SetTintProbability('DN_DinosaurParaRace', FEMALE, TL_MASK, 0);
    SetTintProbability('DN_DinosaurParaRace', FEMALE, TL_MUZZLE_STRIPE, 40);
    SetTintProbability('DN_DinosaurParaRace', FEMALE, TL_NOSE, 0);
    SetTintProbability('DN_DinosaurParaRace', FEMALE, TL_NECK, 0);
    SetTintProbability('DN_DinosaurParaRace', MALE, TL_EYELINER, 0);
    SetTintProbability('DN_DinosaurParaRace', MALE, TL_MASK, 0);
    SetTintProbability('DN_DinosaurParaRace', MALE, TL_MUZZLE_STRIPE, 40);
    SetTintProbability('DN_DinosaurParaRace', MALE, TL_NOSE, 0);

    SetTintColors('DN_DinosaurParaRace', FEMALE, TL_EYELINER, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurParaRace', FEMALE, TL_MASK, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurParaRace', FEMALE, TL_MUZZLE, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurParaRace', FEMALE, TL_MUZZLE_STRIPE, '|black||');
    SetTintColors('DN_DinosaurParaRace', FEMALE, TL_NECK, '|black|');
    SetTintColors('DN_DinosaurParaRace', FEMALE, TL_NOSE, '|black|');
    SetTintColors('DN_DinosaurParaRace', MALE, TL_EYELINER, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurParaRace', MALE, TL_MASK, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurParaRace', MALE, TL_MUZZLE, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurParaRace', MALE, TL_MUZZLE_STRIPE, '|black||');
    SetTintColors('DN_DinosaurParaRace', MALE, TL_NOSE, '|black|');

    SetMorphProbability('DN_DinosaurParaRace', FEMALE, 'Eyes', 60, 0, 100, SKEW1);
    SetMorphProbability('DN_DinosaurParaRace', FEMALE, 'Nose - Full', 50, 0, 100, SKEW1);
    SetMorphProbability('DN_DinosaurParaRace', FEMALE, 'Crest', 100, 0, 100, SKEW0);
    SetMorphProbability('DN_DinosaurParaRace', FEMALE, 'Teeth', 30, 100, 100, EVEN);
    SetMorphProbability('DN_DinosaurParaRace', FEMALE, 'Crest Texture', 50, 20, 100, EVEN);
    SetMorphProbability('DN_DinosaurParaRace', FEMALE, 'Face Markings', 50, 100, 100, EVEN);
    SetMorphProbability('DN_DinosaurParaRace', MALE, 'Eyes', 60, 0, 100, SKEW1);
    SetMorphProbability('DN_DinosaurParaRace', MALE, 'Nose - Full', 50, 0, 100, SKEW1);
    SetMorphProbability('DN_DinosaurParaRace', MALE, 'Crest', 100, 0, 100, SKEW0);
    SetMorphProbability('DN_DinosaurParaRace', MALE, 'Teeth', 30, 100, 100, EVEN);
    SetMorphProbability('DN_DinosaurParaRace', MALE, 'Crest Texture', 50, 20, 100, EVEN);
    SetMorphProbability('DN_DinosaurParaRace', MALE, 'Face Markings', 50, 100, 100, EVEN);

    SetFaceMorph('DN_DinosaurParaRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0);
    SetFaceMorph('DN_DinosaurParaRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0);

	// ---------- T-Rex Gen1/Triceratops Hybrids ---------- 
    AddChildRace('DN_DinosaurHybridRace', 'FFOSnekdogChildRace'); // Reptilian
    SetHeadpartProb('DN_DinosaurHybridRace', MALE, HEADPART_FACIAL_HAIR, 100); // Triceratops Horns
    SetHeadpartProb('DN_DinosaurHybridRace', FEMALE, HEADPART_FACIAL_HAIR, 100); // Triceratops Horns

    SetTintProbability('DN_DinosaurHybridRace', FEMALE, TL_EYELINER, 0);
    SetTintProbability('DN_DinosaurHybridRace', FEMALE, TL_MASK, 0);
    SetTintProbability('DN_DinosaurHybridRace', FEMALE, TL_MUZZLE_STRIPE, 40);
    SetTintProbability('DN_DinosaurHybridRace', FEMALE, TL_NOSE, 0);
    SetTintProbability('DN_DinosaurHybridRace', MALE, TL_EYELINER, 0);
    SetTintProbability('DN_DinosaurHybridRace', MALE, TL_MASK, 0);
    SetTintProbability('DN_DinosaurHybridRace', MALE, TL_MUZZLE_STRIPE, 40);
    SetTintProbability('DN_DinosaurHybridRace', MALE, TL_NOSE, 0);

    SetTintColors('DN_DinosaurHybridRace', FEMALE, TL_EYELINER, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurHybridRace', FEMALE, TL_MASK, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurHybridRace', FEMALE, TL_MUZZLE_STRIPE, '|black||');
    SetTintColors('DN_DinosaurHybridRace', FEMALE, TL_NOSE, '|black|');
    SetTintColors('DN_DinosaurHybridRace', MALE, TL_EYELINER, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurHybridRace', MALE, TL_MASK, '|black|DarkBrown|MidBrown|LightBrown|MidGrey|LightGrey|DeepRed|MidRed|LightRed|Pink|LightPink|DeepBlue|MidBlue|LightBlue|Orange|yellow|DeepGreen|Green|NeonGreen|DeepTurquoise|Turquoise|DeepPurple|Purple|LightPurple|');
    SetTintColors('DN_DinosaurHybridRace', MALE, TL_MUZZLE_STRIPE, '|black||');
    SetTintColors('DN_DinosaurHybridRace', MALE, TL_NOSE, '|black|');

    SetMorphProbability('DN_DinosaurHybridRace', FEMALE, 'Mouth', 50, 100, 100, EVEN);
    SetMorphProbability('DN_DinosaurHybridRace', MALE, 'Mouth', 50, 100, 100, EVEN);

    SetFaceMorph('DN_DinosaurHybridRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0);
    SetFaceMorph('DN_DinosaurHybridRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -1,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale max} 0);
end;

end.