{
FFO Furrifier Race Probabilities.
Author: Bad Dog 
  
Define race probabilities for the different NPC classes, also for some specific NPCs. Must
be called early because this routine defines the furry races. TARGET_RACE in FFO_Furrifier
overrides all these.

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
	
    SetClassProb(CLASS_TRAPPER, 'FFOOtterRace', 100);
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
    SetClassProb(CLASS_TRAPPER, 'aaaSharkRace', 100);
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
	
    SetClassProb(CLASS_FARHARBOR, 'FFOLykaiosRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOFoxRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOHyenaRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOLionRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOTigerRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOCheetahRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOHorseRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFODeerRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOOtterRace', 90);
	SetClassProb(CLASS_FARHARBOR, 'aaaSharkRace', 90);
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

