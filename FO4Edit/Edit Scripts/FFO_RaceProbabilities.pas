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

    // Good fighters
    SetClassProb(CLASS_MINUTEMEN, 'FFOLykaiosRace', 30);
    SetClassProb(CLASS_MINUTEMEN, 'FFOFoxRace', 20);
    SetClassProb(CLASS_MINUTEMEN, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_MINUTEMEN, 'FFOLionRace', 30);
    SetClassProb(CLASS_MINUTEMEN, 'FFOTigerRace', 40);
    SetClassProb(CLASS_MINUTEMEN, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_MINUTEMEN, 'FFOHorseRace', 40);
    SetClassProb(CLASS_MINUTEMEN, 'FFODeerRace', 20);
	SetClassProb(CLASS_MINUTEMEN, 'DN_DinosaurRace', 40);
	SetClassProb(CLASS_MINUTEMEN, 'DN_DinosaurHybridRace', 20);
	SetClassProb(CLASS_MINUTEMEN, 'DN_DinosaurTriRace', 40);
	SetClassProb(CLASS_MINUTEMEN, 'DN_DinosaurParaRace', 10);	
	SetClassProb(CLASS_MINUTEMEN, 'PA_ProtoArgonianRace', 30);
	SetClassProb(CLASS_MINUTEMEN, 'aaaSharkRace', 10);	
	SetClassProb(CLASS_MINUTEMEN, 'DCM_DeathclawMutantRace', 30);
	
    SetClassProb(CLASS_BOS, 'FFOLykaiosRace', 40);
    SetClassProb(CLASS_BOS, 'FFOFoxRace', 20);
    SetClassProb(CLASS_BOS, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_BOS, 'FFOLionRace', 20);
    SetClassProb(CLASS_BOS, 'FFOTigerRace', 20);
    SetClassProb(CLASS_BOS, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_BOS, 'FFOHorseRace', 30);
    SetClassProb(CLASS_BOS, 'FFODeerRace', 10);
	SetClassProb(CLASS_BOS, 'DN_DinosaurRace', 30);
	SetClassProb(CLASS_BOS, 'DN_DinosaurHybridRace', 10);
	SetClassProb(CLASS_BOS, 'DN_DinosaurTriRace', 10);
	SetClassProb(CLASS_BOS, 'DN_DinosaurParaRace', 10);	
	SetClassProb(CLASS_BOS, 'PA_ProtoArgonianRace', 30);
	SetClassProb(CLASS_BOS, 'DCM_DeathclawMutantRace', 20);
	
    SetClassProb(CLASS_RR, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_RR, 'FFOFoxRace', 20);
    SetClassProb(CLASS_RR, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_RR, 'FFOLionRace', 30);
    SetClassProb(CLASS_RR, 'FFOTigerRace', 20);
    SetClassProb(CLASS_RR, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_RR, 'FFOHorseRace', 60);
    SetClassProb(CLASS_RR, 'FFODeerRace', 30);
	SetClassProb(CLASS_RR, 'DN_DinosaurRace', 10);
	SetClassProb(CLASS_RR, 'DN_DinosaurHybridRace', 10);
	SetClassProb(CLASS_RR, 'DN_DinosaurTriRace', 60);
	SetClassProb(CLASS_RR, 'DN_DinosaurParaRace', 30);	
	SetClassProb(CLASS_RR, 'PA_ProtoArgonianRace', 20);
	SetClassProb(CLASS_RR, 'DCM_DeathclawMutantRace', 10); 	
	
    // Enemies

    SetClassProb(CLASS_GUNNER, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOFoxRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOLionRace', 60);
    SetClassProb(CLASS_GUNNER, 'FFOTigerRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOHorseRace', 10);
    SetClassProb(CLASS_GUNNER, 'FFODeerRace', 5);
	SetClassProb(CLASS_GUNNER, 'DN_DinosaurRace', 60);
	SetClassProb(CLASS_GUNNER, 'DN_DinosaurHybridRace', 40);
	SetClassProb(CLASS_GUNNER, 'DN_DinosaurTriRace', 10);
	SetClassProb(CLASS_GUNNER, 'DN_DinosaurParaRace', 5);
	SetClassProb(CLASS_GUNNER, 'PA_ProtoArgonianRace', 20);
	SetClassProb(CLASS_GUNNER, 'DCM_DeathclawMutantRace', 20); 
	
    SetClassProb(CLASS_DISCIPLES, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOFoxRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOHyenaRace', 60);
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
	
    SetClassProb(CLASS_OPERATOR, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_OPERATOR, 'FFOFoxRace', 60);
    SetClassProb(CLASS_OPERATOR, 'FFOHyenaRace', 20);
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
	
    SetClassProb(CLASS_PACK, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_PACK, 'FFOFoxRace', 20);
    SetClassProb(CLASS_PACK, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_PACK, 'FFOLionRace', 20);
    SetClassProb(CLASS_PACK, 'FFOTigerRace', 20);
    SetClassProb(CLASS_PACK, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_PACK, 'FFOHorseRace', 5);
    SetClassProb(CLASS_PACK, 'FFODeerRace', 0);
	SetClassProb(CLASS_PACK, 'DN_DinosaurRace', 20);
	SetClassProb(CLASS_PACK, 'DN_DinosaurHybridRace', 10);
	SetClassProb(CLASS_PACK, 'DN_DinosaurTriRace', 5);
	SetClassProb(CLASS_PACK, 'DN_DinosaurParaRace', 0);
	SetClassProb(CLASS_PACK, 'PA_ProtoArgonianRace', 5);
	SetClassProb(CLASS_PACK, 'DCM_DeathclawMutantRace', 20); 
	
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
	
    // Neutrals 

    SetClassProb(CLASS_INSTITUTE, 'FFOLykaiosRace', 30);
    SetClassProb(CLASS_INSTITUTE, 'FFOFoxRace', 20);
    SetClassProb(CLASS_INSTITUTE, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_INSTITUTE, 'FFOLionRace', 30);
    SetClassProb(CLASS_INSTITUTE, 'FFOTigerRace', 40);
    SetClassProb(CLASS_INSTITUTE, 'FFOCheetahRace', 40);
    SetClassProb(CLASS_INSTITUTE, 'FFOHorseRace', 50);
    SetClassProb(CLASS_INSTITUTE, 'FFODeerRace', 50);
	SetClassProb(CLASS_INSTITUTE, 'DN_DinosaurRace', 20);
	SetClassProb(CLASS_INSTITUTE, 'DN_DinosaurHybridRace', 40);
	SetClassProb(CLASS_INSTITUTE, 'DN_DinosaurTriRace', 50);
	SetClassProb(CLASS_INSTITUTE, 'DN_DinosaurParaRace', 50);
	SetClassProb(CLASS_INSTITUTE, 'PA_ProtoArgonianRace', 20);
	SetClassProb(CLASS_INSTITUTE, 'DCM_DeathclawMutantRace', 30); 
	
    // 10:1 otters to others in FH
    SetClassProb(CLASS_FARHARBOR, 'FFOLykaiosRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOFoxRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOHyenaRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOLionRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOTigerRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOCheetahRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOHorseRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFODeerRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOOtterRace', 400);
	SetClassProb(CLASS_FARHARBOR, 'aaaSharkRace', 400);
	SetClassProb(CLASS_FARHARBOR, 'DN_DinosaurRace', 5);
	SetClassProb(CLASS_FARHARBOR, 'DN_DinosaurHybridRace', 5);
	SetClassProb(CLASS_FARHARBOR, 'DN_DinosaurTriRace', 5);
	SetClassProb(CLASS_FARHARBOR, 'DN_DinosaurParaRace', 5);
	SetClassProb(CLASS_FARHARBOR, 'PA_ProtoArgonianRace', 5);
	SetClassProb(CLASS_FARHARBOR, 'DCM_DeathclawMutantRace', 5);
 	
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
	
    SetClassProb(CLASS_SETTLER, 'FFOLykaiosRace', 10);
    SetClassProb(CLASS_SETTLER, 'FFOFoxRace', 10);
    SetClassProb(CLASS_SETTLER, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_SETTLER, 'FFOLionRace', 10);
    SetClassProb(CLASS_SETTLER, 'FFOTigerRace', 10);
    SetClassProb(CLASS_SETTLER, 'FFOCheetahRace', 10);
    SetClassProb(CLASS_SETTLER, 'FFOHorseRace', 15);
    SetClassProb(CLASS_SETTLER, 'FFODeerRace', 15);
    SetClassProb(CLASS_SETTLER, 'FFOOtterRace', 3);
	SetClassProb(CLASS_SETTLER, 'DN_DinosaurRace', 10);
	SetClassProb(CLASS_SETTLER, 'DN_DinosaurHybridRace', 3);
	SetClassProb(CLASS_SETTLER, 'DN_DinosaurTriRace', 15);
	SetClassProb(CLASS_SETTLER, 'DN_DinosaurParaRace', 15);
	SetClassProb(CLASS_SETTLER, 'PA_ProtoArgonianRace', 10);
    SetClassProb(CLASS_SETTLER, 'aaaSharkRace', 3);
	SetClassProb(CLASS_SETTLER, 'DCM_DeathclawMutantRace', 10); 
	
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
    SetClassProb(CLASS_LEE, 'FFOHyenaRace', 100);
    SetClassProb(CLASS_MATHIS, 'FFOFoxRace', 100);

    // Specific NPCs
    // These override TARGET_RACE.
    AssignNPCRace('MamaMurphy', 'FFOLionRace'); // Her hat is tailored to the lioness head
    AssignNPCRace('DLC04Mason', 'FFOHorseRace'); // I just like him this way
end;

//==================================================================================
// Do any special tailoring for specific races.
Procedure TailorRaces(); 
begin
    AddChildRace('FFOCheetahRace', 'FFOCheetahChildRace');
    AddChildRace('FFODeerRace', 'FFODeerChildRace');
    AddChildRace('FFOFoxRace', 'FFOFoxChildRace');
    AddChildRace('FFOHorseRace', 'FFOHorseChildRace');
    AddChildRace('FFOHyenaRace', 'FFOHyenaChildRace');
    AddChildRace('FFOLionRace', 'FFOLionChildRace');
    AddChildRace('FFOLykaiosRace', 'FFOLykaiosChildRace');
    AddChildRace('FFOOtterRace', 'FFOOtterChildRace');
    AddChildRace('FFOSnekdogRace', 'FFOSnekdogChildRace');
    AddChildRace('FFOTigerRace', 'FFOTigerChildRace');

    // Probability of using different tints
    SetTintProbability('FFOHorseRace', MALE, TL_MUZZLE, 60);
    SetTintProbability('FFOHorseRace', FEMALE, TL_MUZZLE, 60);
    SetTintProbability('FFOHorseRace', MALE, TL_NOSE, 50);
    SetTintProbability('FFOHorseRace', FEMALE, TL_NOSE, 50);
    
    // Raccoon-style eye mask. Don't hand it out automatically.
    SetTintProbability('FFOLykaiosRace', FEMALE, TL_MASK, 0);
    SetTintProbability('FFOLykaiosRace', MALE, TL_MASK, 0);

    // Acceptable colors for tint layers. This is so specialty colors can 
    // be provided without being picked up by the furrifier. 
    SetTintColors('FFOHyenaRace', FEMALE, TL_EAR, '|FFOFurBlack|FFOFurBlueBlack|');
    SetTintColors('FFOHyenaRace', MALE, TL_EAR, '|FFOFurBlack|FFOFurBlueBlack|');
    SetTintColors('FFOLykaiosRace', FEMALE, TL_MUZZLE, '|FFOFurBlack|FFOFurBrownD|');
    SetTintColors('FFOLykaiosRace', MALE, TL_MUZZLE, '|FFOFurBlack|FFOFurBrownD|');

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
    ExcludeMorph('FFOCheetahRace', MALE, 'Child');

    ExcludeMorph('FFOFoxRace', FEMALE, 'Child');
    ExcludeMorph('FFOFoxRace', FEMALE, 'Neck');
    ExcludeMorph('FFOFoxRace', MALE, 'Child');
    ExcludeMorph('FFOFoxRace', MALE, 'Neck');

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

    ExcludeMorph('FFOHyenaRace', FEMALE, 'Face');
    ExcludeMorph('FFOHyenaRace', MALE, 'Face');

    ExcludeMorph('FFOLionRace', FEMALE, 'Child Neck');
    ExcludeMorph('FFOLionRace', MALE, 'Child Neck');
    SetMorphProbability('FFOLionRace', FEMALE, 'Mouth', 30, 50, 100, SKEW1); // Sabretooth
    SetMorphProbability('FFOLionRace', MALE, 'Mouth', 30, 50, 100, SKEW1); // Sabretooth

    ExcludeMorph('FFOLykaiosRace', FEMALE, 'Child Neck');
    ExcludeMorph('FFOLykaiosRace', FEMALE, 'Neck');
    SetMorphProbability('FFOLykaiosRace', FEMALE, 'Nose', 80, 0, 75, SKEW0);
    ExcludeMorph('FFOLykaiosRace', MALE, 'Child Neck');
    SetMorphProbability('FFOLykaiosRace', MALE, 'Nose', 80, 0, 75, SKEW0);

    ExcludeMorph('FFOSnekdogRace', MALE, 'Neck');
  
    ExcludeMorph('FFOTigerRace', FEMALE, 'Child Neck');
    ExcludeMorph('FFOTigerRace', MALE, 'Child Neck');

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

    SetFaceMorph('FFOHorseRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, 0,  {rot min} 0, 0, 0, {scale min} -0.2,
        {loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale max} -0);
    SetFaceMorph('FFOHorseRace', FEMALE, 'Nose - Bridge', 
        {loc min} 0, -0.3, 0,  {rot min} 0, 0, 0, {scale min} -0,
        {loc max} 0, 0.4, 0,  {rot max} 0, 0, 0, {scale max} -0);
    SetFaceMorph('FFOHorseRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, 0,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale max} -0);

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

    SetFaceMorph('FFOLionRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -0.4,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 0.5,  {rot max} 0, 0, 0, {scale max} 0);
    SetFaceMorph('FFOLionRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -0.8,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0, 0, 0.7,  {rot max} 0, 0, 0, {scale max} 0.5);

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

end;

end.