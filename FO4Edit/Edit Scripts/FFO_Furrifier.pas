{
  NPC Furry Patch Builder
  Author: Bad Dog 
  
  Creates a NPC furry patch for a load order.

  By default, all NPCs are changed to furry races, children included. Ghouls are changed to 
  Nightstalkers. 

  Script allows customization of race assignments and what NPCs to affect.

	Hotkey: Ctrl+Alt+D

}

unit FFO_Furrifier;

interface

implementation

uses BDFurryArmorFixup, FFOGenerateNPCs, BDScriptTools, BDAssetLoaderFO4, xEditAPI, Classes, SysUtils, StrUtils, Windows;

const
    patchfileName = 'FFOPatch.esp'; // Set to whatever
    USE_SELECTION = FALSE;           // FALSE or TRUE
    TARGET_RACE = '';    // Use this race for everything

var
    patchFile: IwbFile;
    patchFileCreated: boolean;

    playerIDs: TStringList;
    furrifiedNPCs: TStringList;
    furryCount: integer;
    preFurryCount: integer;


//======================================================

// Define race probabilities for the different NPC classes, also for some specific NPCs.
// Must be called early because this routine defines the furry races. TARGET_RACE
// overrides all these.

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
    // SetClassProb(CLASS_BOS, 'FFOHumanRace', 10);

    SetClassProb(CLASS_BOS, 'FFOLykaiosRace', 40);
    SetClassProb(CLASS_BOS, 'FFOFoxRace', 20);
    SetClassProb(CLASS_BOS, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_BOS, 'FFOLionRace', 20);
    SetClassProb(CLASS_BOS, 'FFOTigerRace', 20);
    SetClassProb(CLASS_BOS, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_BOS, 'FFOHorseRace', 30);
    SetClassProb(CLASS_BOS, 'FFODeerRace', 10);

    SetClassProb(CLASS_RR, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_RR, 'FFOFoxRace', 20);
    SetClassProb(CLASS_RR, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_RR, 'FFOLionRace', 30);
    SetClassProb(CLASS_RR, 'FFOTigerRace', 20);
    SetClassProb(CLASS_RR, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_RR, 'FFOHorseRace', 60);
    SetClassProb(CLASS_RR, 'FFODeerRace', 30);

    // Enemies

    SetClassProb(CLASS_GUNNER, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOFoxRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOLionRace', 60);
    SetClassProb(CLASS_GUNNER, 'FFOTigerRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_GUNNER, 'FFOHorseRace', 10);
    SetClassProb(CLASS_GUNNER, 'FFODeerRace', 5);

    SetClassProb(CLASS_DISCIPLES, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOFoxRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOHyenaRace', 60);
    SetClassProb(CLASS_DISCIPLES, 'FFOLionRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOTigerRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_DISCIPLES, 'FFOHorseRace', 8);
    SetClassProb(CLASS_DISCIPLES, 'FFODeerRace', 4);

    SetClassProb(CLASS_OPERATOR, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_OPERATOR, 'FFOFoxRace', 60);
    SetClassProb(CLASS_OPERATOR, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_OPERATOR, 'FFOLionRace', 10);
    SetClassProb(CLASS_OPERATOR, 'FFOTigerRace', 10);
    SetClassProb(CLASS_OPERATOR, 'FFOCheetahRace', 10);
    SetClassProb(CLASS_OPERATOR, 'FFOHorseRace', 5);
    SetClassProb(CLASS_OPERATOR, 'FFODeerRace', 5);

    SetClassProb(CLASS_PACK, 'FFOLykaiosRace', 20);
    SetClassProb(CLASS_PACK, 'FFOFoxRace', 20);
    SetClassProb(CLASS_PACK, 'FFOHyenaRace', 20);
    SetClassProb(CLASS_PACK, 'FFOLionRace', 20);
    SetClassProb(CLASS_PACK, 'FFOTigerRace', 20);
    SetClassProb(CLASS_PACK, 'FFOCheetahRace', 20);
    SetClassProb(CLASS_PACK, 'FFOHorseRace', 5);
    SetClassProb(CLASS_PACK, 'FFODeerRace', 5);

    SetClassProb(CLASS_RAIDER, 'FFOLykaiosRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOFoxRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOHyenaRace', 50);
    SetClassProb(CLASS_RAIDER, 'FFOLionRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOTigerRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOCheetahRace', 30);
    SetClassProb(CLASS_RAIDER, 'FFOHorseRace', 16);
    SetClassProb(CLASS_RAIDER, 'FFODeerRace', 8);

    SetClassProb(CLASS_TRAPPER, 'FFOOtterRace', 100);
    SetClassProb(CLASS_TRAPPER, 'FFOLykaiosRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOFoxRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOLionRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOTigerRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOCheetahRace', 10);
    SetClassProb(CLASS_TRAPPER, 'FFOHorseRace', 5);
    SetClassProb(CLASS_TRAPPER, 'FFODeerRace', 5);

    // Neutrals 

    SetClassProb(CLASS_INSTITUTE, 'FFOLykaiosRace', 30);
    SetClassProb(CLASS_INSTITUTE, 'FFOFoxRace', 20);
    SetClassProb(CLASS_INSTITUTE, 'FFOHyenaRace', 10);
    SetClassProb(CLASS_INSTITUTE, 'FFOLionRace', 30);
    SetClassProb(CLASS_INSTITUTE, 'FFOTigerRace', 40);
    SetClassProb(CLASS_INSTITUTE, 'FFOCheetahRace', 40);
    SetClassProb(CLASS_INSTITUTE, 'FFOHorseRace', 50);
    SetClassProb(CLASS_INSTITUTE, 'FFODeerRace', 50);

    SetClassProb(CLASS_FARHARBOR, 'FFOLykaiosRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOFoxRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOHyenaRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOLionRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOTigerRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOCheetahRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOHorseRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFODeerRace', 5);
    SetClassProb(CLASS_FARHARBOR, 'FFOOtterRace', 90);

    SetClassProb(CLASS_ATOM, 'FFOLykaiosRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOFoxRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOHyenaRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOLionRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOTigerRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOCheetahRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOHorseRace', 5);
    SetClassProb(CLASS_ATOM, 'FFODeerRace', 5);
    SetClassProb(CLASS_ATOM, 'FFOSnekdogRace', 40);

    SetClassProb(NONE, 'FFOLykaiosRace', 10);
    SetClassProb(NONE, 'FFOFoxRace', 10);
    SetClassProb(NONE, 'FFOHyenaRace', 10);
    SetClassProb(NONE, 'FFOLionRace', 10);
    SetClassProb(NONE, 'FFOTigerRace', 10);
    SetClassProb(NONE, 'FFOCheetahRace', 10);
    SetClassProb(NONE, 'FFOHorseRace', 15);
    SetClassProb(NONE, 'FFODeerRace', 15);
    SetClassProb(NONE, 'FFOOtterRace', 3);

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

    // Ghouls. All ghouls have to be the same race (because headgear has to be altered to
    // fit them).
    SetClassProb(CLASS_GHOUL, 'FFOSnekdogRace', 100);

    // Specific NPCs
    // These override TARGET_RACE.
    AssignNPCRace('MamaMurphy', 'FFOLionRace'); // Her hat is tailored to the lioness head
    AssignNPCRace('DLC04Mason', 'FFOHorseRace'); // I just like him this way

    CalcClassTotals();
end;

//==================================================================================
// Do any special tailoring for specific races.
Procedure SetTintLayerTranslations(); 
begin
    InitializeTintLayers;

    // What the parts of the face are called in different races
    SkinLayerTranslation('Blaze Narrow', TL_MUZZLE);
    SkinLayerTranslation('Blaze Wide', TL_MUZZLE);
    SkinLayerTranslation('Cap', TL_FOREHEAD);
    SkinLayerTranslation('Cheek Color Lower', TL_CHEEK_COLOR_LOWER);
    SkinLayerTranslation('Cheek Color', TL_CHEEK_COLOR);
    SkinLayerTranslation('Cheeks', TL_CHEEK_COLOR);
    SkinLayerTranslation('Chin', TL_CHIN);
    SkinLayerTranslation('Ears', TL_EAR);
    SkinLayerTranslation('Eye Lower', TL_EYESOCKET_LOWER);
    SkinLayerTranslation('Eye Shadow', TL_EYELINER);
    SkinLayerTranslation('Eye Socket', TL_EYELINER);
    SkinLayerTranslation('Eye Socket Upper', TL_EYESOCKET_UPPER);
    SkinLayerTranslation('Eye Stripe', TL_Mask);
    SkinLayerTranslation('Eye Tear', TL_MASK); // Snekdogs
    SkinLayerTranslation('Eye Upper', TL_EYESOCKET_UPPER);
    SkinLayerTranslation('Eyebrow Spot', TL_EYEBROW);
    SkinLayerTranslation('Eyebrow', TL_EYEBROW);
    SkinLayerTranslation('Eyeliner', TL_EYELINER);
    SkinLayerTranslation('Face Mask 1', TL_MASK);
    SkinLayerTranslation('Face Mask 2', TL_MASK);
    SkinLayerTranslation('Face Mask 3', TL_MASK);
    SkinLayerTranslation('Face Mask 4', TL_MASK);
    SkinLayerTranslation('Face Plate', TL_MASK);
    SkinLayerTranslation('Forehead', TL_FOREHEAD);
    SkinLayerTranslation('Head Scales', TL_FOREHEAD);
    SkinLayerTranslation('Lips', TL_LIP_COLOR);
    SkinLayerTranslation('Lower Jaw', TL_CHIN);
    SkinLayerTranslation('Mask', TL_Mask);
    SkinLayerTranslation('Mouche', TL_CHIN);
    SkinLayerTranslation('Muzzle Stripe', TL_MUZZLE_STRIPE); 
    SkinLayerTranslation('Muzzle Upper', TL_MUZZLE); 
    SkinLayerTranslation('Muzzle', TL_MUZZLE);
    SkinLayerTranslation('Nose Stripe 1', TL_MUZZLE_STRIPE); // Fox
    SkinLayerTranslation('Nose Stripe 2', TL_MUZZLE_STRIPE); // Fox
    SkinLayerTranslation('Nose Stripe', TL_MUZZLE_STRIPE); 
    SkinLayerTranslation('Nose', TL_NOSE);
    SkinLayerTranslation('Old', TL_OLD);
    SkinLayerTranslation('Skin tone', TL_SKIN_TONE);
    SkinLayerTranslation('Star', TL_FOREHEAD);
    SkinLayerTranslation('Upper Head', TL_FOREHEAD);
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

    // SetMorphProbability provides a probability of using different morphs.If no
    // probabilty is set for a morph group, it will be applied at 100% probability.
    // Parameters are:
    //  Race name
    //  Sex (MALE/FEMALE)
    //  Name of the morph group in the race record
    //  Probability at which a morph from this group should be applied to a NPC
    //  Min morph value when this morph is applied (0-100)
    //  Max morph value when this morph is applied (0-100)
    //  Morph distribution (EVEN, SKEW0,  SKEW1)
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
    SetFaceMorph('FFOFoxRace', FEMALE, 'Ears - Full', 
        {loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
    SetFaceMorph('FFOFoxRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -0.7,  {rot min} 0, 0, 0, {scale min} -0.2,
        {loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale min} -0);

    SetFaceMorph('FFOFoxRace', MALE, 'Ears - Full', 
        {loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
    SetFaceMorph('FFOFoxRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -0.7,  {rot min} 0, 0, 0, {scale min} -0.2,
        {loc max} 0, 0, 0.2,  {rot max} 0, 0, 0, {scale min} -0);

    SetFaceMorph('FFOLykaiosRace', FEMALE, 'Ears - Full', 
        {loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
    SetFaceMorph('FFOLykaiosRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -0.7,  {rot min} 0, 0, 0, {scale min} -0.2,
        {loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale min} -0);

    SetFaceMorph('FFOLykaiosRace', MALE, 'Ears - Full', 
        {loc min} -0.25, -0.25, -0.25,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0.25, 0.25, 0.25,  {rot max} 0, 0, 0, {scale max} 0.4);
    SetFaceMorph('FFOLykaiosRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -0.7,  {rot min} 0, 0, 0, {scale min} -0.2,
        {loc max} 0, 0, 0.2,  {rot max} 0, 0, 0, {scale min} -0);

    SetFaceMorph('FFOHorseRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, 0,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale min} -0);
    SetFaceMorph('FFOHorseRace', FEMALE, 'Nose - Bridge', 
        {loc min} 0, -0.3, 0,  {rot min} 0, 0, 0, {scale min} -0,
        {loc max} 0, 0.4, 0,  {rot max} 0, 0, 0, {scale min} -0);
    SetFaceMorph('FFOHorseRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, 0,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0, 0, 0,  {rot max} 0, 0, 0, {scale min} -0);

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
        {loc max} 0, 0, 0.5,  {rot max} 0, 0, 0, {scale min} 0);
    SetFaceMorph('FFOLionRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -0.8,  {rot min} 0, 0, 0, {scale min} -0.4,
        {loc max} 0, 0, 0.7,  {rot max} 0, 0, 0, {scale min} 0.5);

    SetFaceMorph('FFOSnekdogRace', FEMALE, 'Ears - Full', 
        {loc min} 0, -1, 0,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 1, 0,  {rot max} 0, 0, 0, {scale min} 0);
    SetFaceMorph('FFOSnekdogRace', FEMALE, 'Nose - Full', 
        {loc min} 0, 0, -0.8,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale min} 0);

    SetFaceMorph('FFOSnekdogRace', FEMALE, 'Ears - Full', 
        {loc min} 0, -1, 0,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 1, 0,  {rot max} 0, 0, 0, {scale min} 0);
    SetFaceMorph('FFOSnekdogRace', MALE, 'Nose - Full', 
        {loc min} 0, 0, -0.8,  {rot min} 0, 0, 0, {scale min} 0,
        {loc max} 0, 0, 1,  {rot max} 0, 0, 0, {scale min} 0);

    CorrelateChildren;
end;

//=========================================================================
// By default, use all layers of all races. Why is it there if not to use?
// Except we may limit the number of layers per NPC so they don't get stupid.
Procedure SetRaceDefaults;
    var el, r: integer;
begin
    Log(10, '<SetRaceDefaults');
    for r := RACE_LO to RACE_HI do begin
        for el := 0 to tintlayerName.Count-1 do begin
            Log(10, Format('Setting race default for %s %s', [masterRaceList[r], tintlayerName[el]]));
            raceInfo[r, MALE].tintProbability[el] := 100;
            raceInfo[r, FEMALE].tintProbability[el] := 100;
            raceInfo[r, MALECHILD].tintProbability[el] := 100;
            raceInfo[r, FEMALECHILD].tintProbability[el] := 100;
        end;
    end;
    Log(10, '>SetRaceDefaults');
end;

//======================================================
// Choose a race for the NPC.
// NPC is not altered.
// Guaranteed that the NPC can and should be changed to the given race.
Function ChooseNPCRace(npc: IwbMainRecord): integer;
var
    assignIndex: integer;
    charClass: integer;
    h: integer;
    mother: IwbMainRecord;
    pointTotal: integer;
    r: integer;
    racename: string;
    sex: integer;
    theRace: IwbMainElement;
begin
    Log(5, '<ChooseNPCRace on ' + EditorID(npc));

    Result := -1;

    // Use the assigned race if any.
    assignIndex := npcRaceAssignments.IndexOf(EditorID(npc));
    if assignIndex >= 0 then begin
        theRace := ObjectToElement(npcRaceAssignments.Objects[assignIndex]);
        Log(5, EditorID(npc) + ' assigned to race ' + EditorID(theRace));
        Result := RaceIndex(theRace);
    end
    else begin
        // Use the target race, if specified.
        Result := masterRaceList.IndexOf(TARGET_RACE);
        if Result < 0 then begin
            // Use the mother's/parent's race if any.
            mother := GetMother(npc);
            if Assigned(mother) then begin
                Result := ChooseNPCRace(mother);
            end
            else begin
                // Pick a random race.
                charClass := GetNPCClass(npc);
                pointTotal := classProbs[charClass, masterRaceList.Count];
                h := Hash(EditorID(npc), 6795, pointTotal);
                Log(6, 'Range = ' + IntToStr(pointTotal) + ', hash = ' + IntToStr(h));
                for r := 0 to masterRaceList.Count-1 do begin
                    if (h >= classProbsMin[charClass, r]) and (h <= classProbsMax[charClass, r]) then begin
                        Result := r;
                        break;
                    end;
                end;
            end;
        end;
    end;

    // If we have a child, make sure there's a child race.
    if result >= 0 then begin
        sex := GetNPCSex(npc);
        if not Assigned(raceInfo[result, sex].mainRecord) then begin
            result := -1;
        end;
    end;

    Log(5, Format('>ChooseNPCRace on %s <- %s',  [EditorID(npc), IfThen(Result >= 0, masterRaceList[Result], 'NO RACE')]));
end;


//================================================================
// Remove any head morphs.
Procedure ZeroMorphs(npc: IwbMainRecord);
begin
    Remove(ElementByPath(npc, 'MSDK - Morph Keys'));
    Remove(ElementByPath(npc, 'MSDV - Morph Values'));
    Remove(ElementByPath(npc, 'Face Morphs'));  
end;

//=====================================================================
// Clean NPC of any of the elements we will furrify.
// Return the NPC's current hair. We will try to match it.
Function CleanNPC(npc: IwbMainRecord): IwbMainRecord;
var
    elemList: IwbContainer;
    hp: IwbMainRecord;
    i: integer;
begin
    result := Nil;
    ZeroMorphs(npc);

    Remove(ElementByPath(npc, 'FTST'));
    Remove(ElementByPath(npc, 'WNAM'));

    elemList := ElementByPath(npc, 'Head Parts');
    for i := ElementCount(elemList)-1 downto 0 do begin
            hp := LinksTo(ElementByIndex(elemList, i));
            if GetElementEditValues(hp, 'PNAM') = 'Hair' then 
                result := hp;
            RemoveByIndex(elemList, i, true);
    end;

    elemList := ElementByPath(npc, 'Face Tinting Layers');
    for i := ElementCount(elemList)-1 downto 0 do begin
            RemoveByIndex(elemList, i, true);
    end;

    // Set morph intensity to 1 for all furries
    SetNativeValue(ElementByPath(npc, 'FMIN - Facial Morph Intensity'), 1.0);
end;

//=============================================================================
// Set the NPC's race.
// furryNPC is the furry override record
// raceIndex is the index of the new race.
// If the NPC is a child, the actual race set will be the associated child race.
// Returns the hair record for the NPC, if any.
Function SetNPCRace(furryNPC: IwbMainRecord; raceIndex: integer): IwbMainRecord;
var
    race: IwbMainRecord;
    raceFormID: integer;
    sex: integer;
    skin: IwbMainRecord;
    targetFile: IwbFile;
begin
    Log(5, '<SetNPCRace: ' + EditorID(furryNPC));

    result := Nil;
    sex := GetNPCSex(furryNPC);
    race := raceInfo[raceIndex, sex].mainRecord;
    raceFormID := GetLoadOrderFormID(race);
    targetFile := GetFile(furryNPC);

    result := CleanNPC(furryNPC);
    
    Log(5, Format('Target race is %s %s / %.8x in file %s', [EditorID(race), SexToStr(sex), raceFormID, GetFileName(GetFile(race))]));

    SetNativeValue(ElementByPath(furryNPC, 'RNAM'), LoadOrderFormIDtoFileFormID(targetFile, raceFormID));

    skin := LinksTo(ElementByPath(race, 'WNAM'));
    Log(5, Format('Setting skin to %.8x/%.8x', [integer(GetLoadOrderFormID(skin)), integer(LoadOrderFormIDtoFileFormID(targetFile, GetLoadOrderFormID(skin)))]));
    Add(furryNPC, 'WNAM', true);
    SetNativeValue(ElementByPath(furryNPC, 'WNAM'),
        LoadOrderFormIDtoFileFormID(targetFile, GetLoadOrderFormID(skin)));

    Log(5, Format('Set race to %s', [GetElementEditValues(furryNPC, 'RNAM')]));

    Log(5, '>SetNPCRace ->' + EditorID(furryNPC));
end;


//================================================================
// Assign the given headpart to the character
Procedure AssignHeadpart(npc, hp: IwbMainRecord);
var
    headparts: IwbContainer;
    slot: IwbElement;
    targFile: IwbFile;
begin
    targFile := GetFile(npc);
    headparts := ElementByPath(npc, 'Head Parts');
    slot := ElementAssign(headparts, HighInteger, nil, false);
    SetNativeValue(slot, 
        LoadOrderFormIDtoFileFormID(targFile, GetLoadOrderFormID(hp)));
end;

//==============================================================
// Choose a random headpart of the given type. 
// Hair is handled separately.
Procedure ChooseHeadpart(npc: IwbMainRecord; hpType: integer);
var 
    hp: IwbMainRecord;
    headparts: IwbContainer;
    slot: IwbElement;
begin
    Log(4, Format('<ChooseHeadpart: %s - [%d] %s', [EditorID(npc), GetNPCRaceID(npc), EditorID(GetNPCRace(npc))]));

    hp := PickRandomHeadpart(EditorID(npc), 113, GetNPCRaceID(npc), GetNPCSex(npc), hpType);
    AssignHeadpart(npc, hp);

    Log(4, Format('>ChooseHeadpart: %s <- %s', [EditorID(npc), EditorID(hp)]));
end;

//==============================================================
// Choose a random headpart of the given type. 
// Hair is handled separately.
Procedure SetHeadpart(npc: IwbMainRecord; hpType: integer; hpName: string);
var 
    hp: IwbMainRecord;
    i: integer;
    raceID: integer;
    sex: integer;
    thisHP: IwbMainRecord;
begin
    Log(5, Format('<SetHeadpart(%s, %s, "%s")', [EditorID(npc), headpartsList[hpType], hpName]));
    raceID := GetNPCRaceID(npc);
    sex := GetNPCSex(npc);
    hp := Nil;
    for i := 0 to raceInfo[raceID, sex].headparts[hpType].Count-1 do begin
        thisHP := 
            ObjectToElement(
                raceInfo[GetNPCRaceID(npc), GetNPCSex(npc)]
                    .headparts[hpType]
                        .Objects[i]);
        Log(5, 'Checking ' + EditorID(thisHP));
        if EditorID(thisHP) = hpName then begin
            hp := thisHP;
            break;
        end;
    end;

    if Assigned(hp) then 
        AssignHeadpart(npc, hp)
    else
        Err(Format('Requested headpart %s not found for %s', [hpName, EditorID(npc)]));

    Log(5, Format('>SetHeadparts -> "%s"', [EditorID(hp)]));
end;

//==============================================================
// Look for the hair this NPC had before it was overridden.
Function FindPriorHair(npc: IwbMainRecord): IwbMainRecord;
var
    hp: IwbMainRecord;
    hplist: IwbElement;
    i: integer;
    npcFileIndex: integer;
    npcMaster: IwbMainRecord;
    priorOverride: IwbMainRecord;
    thisOverride: IwbMainRecord;
begin
    Log(5, Format('<FindPriorHair: %s in %s', [EditorID(npc), GetFileName(GetFile(npc))]));
    npcMaster := MasterOrSelf(npc);
    npcFileIndex := GetLoadOrder(GetFile(npc));
    Log(5, 'Found master for NPC in ' + GetFileName(GetFile(npcMaster)));

    priorOverride := Nil;
    Log(5, Format('Have %d overrides', [integer(OverrideCount(npcMaster))]));
    for i := OverrideCount(npcMaster)-1 downto 0 do begin
        thisOverride := OverrideByIndex(npcMaster, i);
        Log(5, 'Found override in file ' + GetFileName(GetFile(thisOverride)));
        Log(5, Format('Checking %d < %d', [GetLoadOrder(GetFile(thisOverride)), npcFileIndex]));
        if GetLoadOrder(GetFile(thisOverride)) < npcFileIndex then begin
            Log(5, 'Using override in file ' + GetFileName(GetFile(thisOverride)));
            priorOverride := thisOverride;
            break;
        end;
    end;

    if not Assigned(priorOverride) then priorOverride := npcMaster;
    Log(5, Format('Checking hair in override in file %s', [GetFileName(GetFile(priorOverride))]));

    result := Nil;
    hplist := ElementByPath(priorOverride, 'Head Parts');
    for i := 0 to ElementCount(hplist)-1 do begin
        hp := LinksTo(ElementByIndex(hplist, i));
        Log(5, Format('Checking for hair %s [%d] %s', [EditorID(hp), i, GetElementEditValues(hp, 'PNAM')]));
        if GetElementEditValues(hp, 'PNAM') = 'Hair' then begin
            result := hp;
            break;
        end;
    end;

    Log(5, '>FindPriorHair: ' + EditorID(result));
end;

//==============================================================
// Choose hair for a NPC. If possible, hair is matched to the NPC's current hair.
Procedure ChooseHair(npc, oldHair: IwbMainRecord);
var 
    hp: IwbMainRecord;
begin
    Log(5, Format('<ChooseHair(%s, %s)', [EditorID(npc), EditorID(oldHair)]));
    if (not Assigned(oldHair)) then begin
        Log(5, 'No old hair, leaving hair alone.');
    end
    else if StartsText('FFO', EditorID(oldHair)) then begin
        Log(5, 'Current hair is furry, using it');
        AssignHeadpart(npc, oldHair);
    end
    else begin
        hp := GetFurryHair(GetNPCRaceID(npc), EditorID(oldHair));
        // if not Assigned(hp) then
        //     hp := PickRandomHeadpart(EditorID(npc), 5269, 
        //         GetNPCRaceID(npc), GetNPCSex(npc), HEADPART_HAIR);

        // Since most vanilla hair has been furrified, if this one hasn't then
        // just leave it off.
        if Assigned(hp) then  AssignHeadpart(npc, hp);
    end;
    Log(5, Format('>ChooseHair -> %s, %s', [EditorID(npc), EditorID(hp)]));
end;

//============================================================
// Assign a tint for a NPC.
Procedure AssignTint(npc: IwbMainRecord; tintOption, tintColor: IwbElement);
var
    color: IwbMainRecord;
    colorval: UInt32;
    facetintLayers: IwbElement;
    layer: IwbElement;
    tend: IwbElement;
    teti: IwbElement;
begin
    Log(5, Format('<AssignTint: %s [%s] [%s]', [EditorID(npc), Path(tintOption), Path(tintColor)]));

    color := LinksTo(ElementByPath(tintColor, 'Color'));
    Log(5, 'Have color ' + EditorID(color));

    // Depending on circumstances 'Add' may or may not create an empty entry.
    facetintLayers := Add(npc, 'Face Tinting Layers', true); // Make sure face tinting layers exists
    if ElementCount(ElementByPath(npc, 'Face Tinting Layers')) = 0 then
        layer := ElementAssign(facetintLayers, HighInteger, Nil, false)
    else if GetElementNativeValues(ElementByIndex(facetintLayers, 0), 'TETI\Index') = 0 then
        layer := ElementByIndex(facetintLayers, 0)
    else
        layer := ElementAssign(facetintLayers, HighInteger, Nil, false);
    
    teti := Add(layer, 'TETI', True);
    SetElementEditValues(teti, 'Data Type', 'Value/Color');
    SetElementNativeValues(teti, 'Index', integer(GetElementNativeValues(tintOption, 'TETI\Index')));
        
    tend := Add(layer, 'TEND', true);
    SetElementEditValues(tend, 'Value', GetElementEditValues(tintColor, 'Alpha'));

    colorval := GetElementNativeValues(color, 'CNAM');
    SetElementNativeValues(tend, 'Color\Red', RedPart(colorval));
    SetElementNativeValues(tend, 'Color\Green', GreenPart(colorval));
    SetElementNativeValues(tend, 'Color\Blue', BluePart(colorval));
    SetElementNativeValues(tend, 'Template Color Index', GetElementNativeValues(tintColor, 'Template Index'));

    if GetElementEditValues(tintOption, 'TETI\Slot') = 'Skin Tone' then begin
        SetElementNativeValues(npc, 'QNAM - Texture lighting\Red', RedPart(colorval));
        SetElementNativeValues(npc, 'QNAM - Texture lighting\Green', GreenPart(colorval));
        SetElementNativeValues(npc, 'QNAM - Texture lighting\Blue', BluePart(colorval));
        SetElementNativeValues(npc, 'QNAM - Texture lighting\Alpha', 
            GetElementNativeValues(tintColor, 'Alpha'));
    end;
    
    Log(5, '>AssignTint');
end;

//============================================================
// Choose and assign a tint for a NPC.
Procedure ChooseTint(npc: IwbMainRecord; tintlayer: integer; seed: integer);
var
    color: IwbMainRecord;
    ind: integer;
    p: IwbElement;
    prob: integer;
    probCheck: integer;
    race: integer;
    sex: integer;
    t: IwbElement;
begin
    Log(5, Format('<ChooseTint: %s, %s', [EditorID(npc) , tintlayerName[tintlayer]]));

    race := GetNPCRaceID(npc);
    sex := GetNPCSex(npc);
    prob := raceInfo[race, sex].tintProbability[tintlayer];
    probCheck := Hash(EditorID(npc), seed, 101);
    ind := IfThen(tintlayer = TL_SKIN_TONE, 0, 1);

    if (probCheck <= prob) and (raceInfo[race, sex].tintCount[tintlayer] > 0) then begin

        t := PickRandomTintOption(EditorID(npc), seed, race, sex, tintlayer);
        p := PickRandomColorPreset(EditorID(npc), seed+7989, t, ind);
        Log(5, 'Selected tint preset ' + Path(p));
        AssignTint(npc, t, p);
    end
    else begin
        Log(5, Format('Probability check failed, no assignment: %d <= %d, layer count %d', [integer(probCheck), integer(prob), integer(raceInfo[race, sex].tintCount[tintlayer])]));
    end;
    
    Log(5, '>ChooseTint');
end;

//=============================================================================
// Select a random color from the color options.
// targetColor = '' if any color will do
// targetColor = color name if one color is wanted
// targetColor = list of color names separated by '|' if one of several colors is wanted.
//
// We might have the same color at different opacity levels, or multiple colors in
// the target list. So loop through the colors skipping the matching color some
// random number of times before selecting it.
Procedure SelectRandomColor(npc: IwbMainRecord; seed: integer; 
    layerOption: integer; tintLayer: integer; targetColor: string);
var 
    color: IwbMainRecord;
    colorList: IwbElement;
    colorPreset: IwbElement;
    i: integer;
    race: integer;
    sex: integer;
    tc: string;
    tintSkip: integer;
begin
    tintSkip := Hash(EditorID(npc), seed, ElementCount(colorList));
    race := GetNPCRaceID(npc);
    sex := GetNPCSex(npc);
    colorList := ElementByPath(
        raceInfo[race, sex].tints[tintLayer, layerOption].element, 'TTEC'
    );
    tc := '|' + targetColor + '|';
    i := 0;
    while true do begin
        colorPreset := ElementByIndex(colorList, i);
        color := LinksTo(ElementByPath(colorPreset, 'Color'));
        if ContainsText(tc, '|' + EditorID(color) + '|') 
                or (targetColor = '') then begin
            if tintSkip = 0 then begin
                AssignTint(npc, 
                    raceInfo[race, sex].tints[tintLayer, layerOption].element, colorPreset);
                break;
            end;
            tintSkip := tintSkip-1;
        end;
        i := i + 1;
        if i >= ElementCount(colorList) then 
            if tintSkip = 0 then
                break
            else
                i := 0;
    end;
end;

//=================================================================================
// Set the tint layer to the named color.
// If the tint layer has several options choose one at random.
// Color may be a single color or a list of colors separated by "|". 
Procedure SetTintlayerColor(npc: IwbMainRecord; seed: integer; 
    tintLayer: integer; targetColor: string);
var
    i: integer;
    layerOption: integer;
    race: integer;
    sex: integer;
begin
    Log(5, Format('<SetTintlayerColor: %s %s <- %s', [EditorID(npc), tintlayerName[tintLayer], targetColor]));
    
    race := GetNPCRaceID(npc);
    sex := GetNPCSex(npc);
    layerOption := Hash(EditorID(npc), seed, raceInfo[race, sex].tintCount[tintLayer]);
    SelectRandomColor(npc, seed, layerOption, tintLayer, targetColor);

    Log(5, '>SetTintlayerColor');
end;

//=================================================================================
// Set the tint layer to the named color, with a probability of prob out of 100.
Procedure SetTintlayerColorProb(probability: integer; npc: IwbMainRecord; seed: integer; 
    tintLayer: integer; targetColor: string);
var
    h: integer;
    i: integer;
    layerOption: integer;
    race: integer;
    sex: integer;
begin
    h := Hash(EditorID(npc), seed, 100);
    if h < probability then SetTintLayerColor(npc, seed, tintLayer, targetColor);
end;

//==============================================================================
// Set the tint layer to the named option.
// tintLayer = TL_ tint layer
// layerName = Name of the particular layer option wanted
// targetColor = Color to pick. May be '', one, or multiple colors.
Procedure PickTintColor(npc: IwbMainRecord; seed: integer; 
    tintLayer: integer; layerName: string; targetColor: string);
var
    i: integer;
    layerOption: integer;
    race: integer;
    sex: integer;
begin
    Log(5, Format('<PickTintColor: %s %s <- %s', [EditorID(npc), tintlayerName[tintLayer], targetColor]));
    
    race := GetNPCRaceID(npc);
    sex := GetNPCSex(npc);
    // layerOption := Hash(EditorID(npc), seed, raceInfo[race, sex].tintCount[tintLayer]);
    for layerOption := 0 to raceInfo[race, sex].tintCount[tintLayer]-1 do begin
        if GetElementEditValues(raceInfo[race, sex].tints[tintLayer, layerOption].element, 
                    'TTGP')
                = layerName then begin
            SelectRandomColor(npc, seed, layerOption, tintLayer, targetColor);
            break;
        end;
    end;

    Log(5, '>PickTintColor');
end;


//=========================================================================
// Set the given morph.
Procedure SetMorph(npc: IwbMainRecord; seed: integer; 
    morphGroup: string; presetName: string);
var
    r: integer;
    s: integer;
    preset: IwbElement;
begin
    Log(5, Format('<SetMorph(%s, %S)', [EditorID(npc), presetName]));
    r := GetNPCRaceID(npc);
    s := GetNPCSex(npc);
    if (s = MALE) or (s = FEMALE) then begin
        preset := GetMorphPreset(
            ObjectToElement(raceInfo[r, s].morphGroups.objects[
                raceInfo[r, s].morphGroups.IndexOf(morphGroup)
                ]),
            presetName);
        if Assigned(preset) then begin
            SetMorphValue(npc, 
                GetElementNativeValues(preset, 'MPPI'),
                HashVal(EditorID(npc), seed, 0.5, 1.0));
        end;
    end;
    Log(5, '>');
end;

//=========================================================================
// Choose a random value for the given morph.
Procedure SetRandomMorph(npc: IwbMainRecord; morphGroup: string; seed: integer);
var
    h: integer;
    hashstr: string;
    mg: integer;
    mhi: integer;
    mhiIndex: integer;
    mlo: integer;
    mloIndex: integer;
    mp: integer;
    mskewIndex: integer;
    mval: float;
    p: integer;
    preset: IwbElement;
    r: integer;
    s: integer;
begin
    Log(5, Format('<SetRandomMorph(%s, %s)', [EditorID(npc), morphGroup]));

    r := GetNPCRaceID(npc);
    s := GetNPCSex(npc);

    // Decide whether to apply a morph from this group.
    hashstr := EditorID(npc) + morphGroup;
    h := Hash(hashstr, seed, 100);
    p := 100;
    mp := raceInfo[r, s].morphProbability.IndexOf(morphGroup);
    if mp >= 0 then
        p := raceInfo[r, s].morphProbability.objects[mp];

    // If it's not a child and we passed the probability test then do it.
    if (h <= p) and ((s = MALE) or (s = FEMALE)) then begin
        mg := raceInfo[r, s].morphGroups.IndexOf(morphGroup);
        preset := GetMorphRandomPreset(
            ObjectToElement(raceInfo[r, s].morphGroups.objects[mg]),
            hashstr,
            seed+31);
        if Assigned(preset) then begin
            mlo := 0;
            mhi := 100;
            mloIndex := raceInfo[r, s].morphLo.IndexOf(morphGroup);
            mhiIndex := raceInfo[r, s].morphHi.IndexOf(morphGroup);
            if (mloIndex >= 0) and (mhiIndex >= 0) then begin
                mlo := raceInfo[r, s].morphLo.objects[mloIndex];
                mhi := raceInfo[r, s].morphHi.objects[mhiIndex];
            end;
            mval := HashVal(hashstr, seed + 29, mlo/100, mhi/100);

            mskewIndex := raceInfo[r, s].morphSkew.IndexOf(morphGroup);
            if mskewIndex >= 0 then 
                case integer(raceInfo[r, s].morphSkew.objects[mskewIndex]) of
                    SKEW0: mval := mval * mval;
                    SKEW1: mval := 1 - (1-mval) * (1-mval);
                end;
            
            SetMorphValue(npc, GetElementNativeValues(preset, 'MPPI'), mval);
        end;
    end;
    Log(5, '>');
end;

//=========================================================
// Set a morph bone given by FMRI to the given values.
Procedure SetMorphBone(npc: IwbMainRecord; morphBoneIndex: integer;
    x, y, z: float;
    pitch, roll, yaw: float;
    sc: float);
var
    fm, thisMorph, vals: IwbElement;
begin
    Log(5, Format('<SetMorphBone(%s, %d)', [EditorID(npc), morphBoneIndex]));
    fm := Add(npc, 'Face Morphs', true);
    thisMorph := nil;
    if (ElementCount(fm) > 0)
        and (GetElementNativeValues(ElementByIndex(fm, 0), 'FMRI') = 0) then
            thisMorph := ElementByIndex(fm, 0)
    else
        thisMorph := ElementAssign(fm, HighInteger, nil, false);

    SetElementNativeValues(thisMorph, 'FMRI', morphBoneIndex);
    vals := Add(thisMorph, 'FMRS', true);
    SetElementNativeValues(vals, 'Position - X', x);
    SetElementNativeValues(vals, 'Position - Y', y);
    SetElementNativeValues(vals, 'Position - Z', z);
    SetElementNativeValues(vals, 'Rotation - X', pitch);
    SetElementNativeValues(vals, 'Rotation - Y', roll);
    SetElementNativeValues(vals, 'Rotation - Z', yaw);
    SetElementNativeValues(vals, 'Scale', sc);
    Log(5, '>');
end;

//=========================================================
// Set a morph bone given by name to the given values.
Procedure SetMorphBoneName(npc: IwbMainRecord; morphBone: string;
    x, y, z: float;
    pitch, roll, yaw: float;
    sc: float);
var
    i: integer;
    r: integer;
    s: integer;
begin
    Log(5, Format('<SetMorphBoneName(%s, %s)', [
        EditorID(npc), morphBone
    ]));
    s := GetNPCSex(npc);
    if ((s = MALE) or (s = FEMALE)) and Assigned(raceInfo[r, s].faceBoneList) then begin
        r := GetNPCRaceID(npc);
        Log(5, Format('%s %s', [masterRaceList[r], sextostr(s)]));
        Log(5, Format('Have %d faceBones', [raceInfo[r, s].faceBoneList.Count]));
        i := raceInfo[r, s].faceBoneList.IndexOf(morphBone);
        if i < 0 then 
            Err(Format('Requested face morph not found for race %s/%s: %s', [
                masterRaceList[r], SexToStr(s), morphBone]))
        else begin
            Log(5, Format(' Calling SetMorphBone(%s, %s, [f, f, f], [f, f, f], f)', [
                EditorID(npc), IntToStr(raceInfo[r, s].faceBones[i].FMRI){, x, y, z, pitch, roll, yaw, sc}
            ]));
            SetMorphBone(npc, raceInfo[r, s].faceBones[i].FMRI, 
                x, y, z, pitch, roll, yaw, sc);
        end;
    end;
    Log(5, '>');
end;

//================================================================================
// Set all availble morphs on the target NPC, randomly.
procedure SetAllRandomMorphs(npc: IwbMainRecord);
var
    fm: TTransform;
    hstr: string;
    i: integer;
    mname: string;
    r: integer;
    s: integer;
begin
    r := GetNPCRaceID(npc);
    s := GetNPCSex(npc);
    if Assigned(raceInfo[r, s].morphGroups) then begin
        for i := 0 to raceInfo[r, s].morphGroups.Count-1 do begin
            mname := raceInfo[r, s].morphGroups[i];
            if raceInfo[r, s].morphExcludes.IndexOf(mname) < 0 then
                SetRandomMorph(npc, mname, 1781 + i*47);
        end;
    end;

    // Do the facebone morphs
    if Assigned(raceInfo[r, s].faceBoneList) then begin
        for i := 0 to raceInfo[r, s].faceBoneList.Count-1 do begin
            hstr := EditorID(npc) + raceInfo[r, s].faceBoneList[i];
            fm.x := HashVal(hstr, 9377, raceInfo[r, s].faceBones[i].min.x, raceInfo[r, s].faceBones[i].max.x);
            fm.y := HashVal(hstr, 9432, raceInfo[r, s].faceBones[i].min.y, raceInfo[r, s].faceBones[i].max.y);
            fm.z := HashVal(hstr, 2529, raceInfo[r, s].faceBones[i].min.z, raceInfo[r, s].faceBones[i].max.z);
            fm.xRot := HashVal(hstr, 9377, raceInfo[r, s].faceBones[i].min.xRot, raceInfo[r, s].faceBones[i].max.xRot);
            fm.yRot := HashVal(hstr, 9432, raceInfo[r, s].faceBones[i].min.yRot, raceInfo[r, s].faceBones[i].max.yRot);
            fm.zRot := HashVal(hstr, 2529, raceInfo[r, s].faceBones[i].min.zRot, raceInfo[r, s].faceBones[i].max.zRot);
            fm.scale := HashVal(hstr, 2529, raceInfo[r, s].faceBones[i].min.scale, raceInfo[r, s].faceBones[i].max.scale);
            SetMorphBone(npc, raceInfo[r, s].faceBones[i].FMRI,
                fm.x, fm.y, fm.z,
                fm.xRot, fm.yRot, fm.zRot,
                fm.scale);
        end;
    end;
end;

//============================================================================
// Create an override record for the NPC.
Function CreateNPCOverride(npc: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
begin
    AddRecursiveMaster(targetFile, GetFile(npc));
    result := wbCopyElementToFile(npc, targetFile, False, True);
end;

Function OverrideAndZeroMorphs(npc: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
var
    newNPC: IwbMainRecord;
begin
    newNPC := CreateNPCOverride(npc, targetFile);
    ZeroMorphs(newNPC);
    result := newNPC;
end;

//==============================================================
// Set an NPC's weight. Weight is the NPC's original weight modified by
// the weight passed in.
Procedure SetWeight(npc: IwbMainElement; thinFac, muscFac, fatFac: double);
Var
    thin, musc, fat, scaleFac: double;
    baseNPC: IwbMainRecord;
Begin
    baseNPC := MasterOrSelf(npc);
    thin := GetElementNativeValues(baseNPC, 'MWGT\Thin');
    musc := GetElementNativeValues(baseNPC, 'MWGT\Muscular');
    fat := GetElementNativeValues(baseNPC, 'MWGT\Fat');
    // Log(9, DisplayName(npc) + ' size = ' 
    //     + FloatToStr(thin) + '/' + FloatToStr(musc) + '/' + FloatToStr(fat));
        
    thin := (1 - 1/thinFac) + (thin/thinFac);
    musc := (1 - 1/muscFac) + (musc/muscFac);
    fat := (1 - 1/fatFac) + (fat/fatFac);
    scaleFac := thin + musc + fat;
    if scaleFac > 0.01 then begin
        SetElementNativeValues(npc, 'MWGT\Thin', thin / scaleFac); 
        SetElementNativeValues(npc, 'MWGT\Muscular', musc / scaleFac); 
        SetElementNativeValues(npc, 'MWGT\Fat', fat / scaleFac); 
    end;
End;

//============================================================================
// Give the NPC the given morph value
Procedure SetMorphValue(npc: IwbMainRecord; key: integer; value: float);
var
    keyval: IwbElement;
    morphval: IwbElement;
    msdk: IwbElement;
    msdv: IwbElement;
begin
    Log(5, Format('<SetMorphValue(%s, %s, %s) ', [EditorID(npc), IntToHex(key, 8), FloatToStr(value)]));
    msdk := Add(npc, 'MSDK', true);
    keyval := ElementAssign(msdk, HighInteger, nil, false);
    SetNativeValue(keyval, key);
    msdv := Add(npc, 'MSDV', true);
    morphval := ElementAssign(msdv, HighInteger, nil, false);
    SetNativeValue(morphval, value);
    Log(5, '>');
end;

//================================================================
// Set up the various types of deer.
Procedure MakeDeerWhitetail(npc: IwbMainRecord);
var
    h: integer;
begin
    SetWeight(npc, 2, 1, 1);
    if GetNPCSex(npc) = MALE then SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns01');

    SetTintLayerColor(npc, 7114, TL_SKIN_TONE,  
        '|FFOFurGingerL|FFOFurBrown|FFOFurTan|FFOFurGinger|FFOFurBrownL|FFOFurRusset|');

    // Muzzle is white around nose
    PickTintColor(npc, 2988, TL_MUZZLE, 'Muzzle', 'FFOFurWhite'); 

    // Big or little nose stripe
    SetTintLayerColor(npc, 510 ,TL_MUZZLE_STRIPE, 'FFOFurBlack');

    // Chin and throat
    SetTintLayerColor(npc, 1874, TL_CHIN, 'FFOFurWhite');

    // Eyes
    SetTintLayerColor(npc, 4151, TL_EYESOCKET_LOWER, 'FFOFurWhite');
    SetTintLayerColor(npc, 7095, TL_EYEBROW, 'FFOFurWhite');

    SetMorph(npc, 8578, 'Nose Shape', 'Dish Face');
end;

Procedure MakeDeerElk(npc: IwbMainRecord);
var
    h: integer;
begin
    SetWeight(npc, 1, 2, 2);
    if GetNPCSex(npc) = MALE then begin
        SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns02');
    end;

    SetTintLayerColor(npc, 2110, TL_SKIN_TONE,  
        'FFOFurBrown|FFOFurBrownD|FFOFurRussetD|FFOFurGingerD|FFOFurRedBrown');
    SetTintLayerColorProb(60, npc, 5794, TL_MUZZLE, 'FFOFurBlack');

    // Eyes
    SetTintLayerColor(npc, 2666, TL_EYESOCKET_LOWER, 'FFOFurWhite');
    SetMorphBoneName(npc, 'Jaw', 
        0, 0, 0.75,
        0, 0, 0,
        0);
    SetMorphBoneName(npc, 'Nose - Full', 
        0, 0.25, -0.5, 
        0, 0, 0,
        0.8);
    SetMorphBoneName(npc, 'Cheekbones', 
        1.0, 0, 0,
        0, 0, 0,
        0);
end;

Procedure MakeDeerReindeer(npc: IwbMainRecord);
var
    h: integer;
begin
    SetWeight(npc, 1, 2, 2);

    if GetNPCSex(npc) = MALE then begin
        SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns05');
        SetHeadpart(npc, HEADPART_FACIAL_HAIR, 'FFOBeard01');
    end;

    SetTintLayerColor(npc, 4480, TL_SKIN_TONE,  
        'FFOFurBrown|FFOFurBrownD|FFOFurRussetD|FFOFurGingerD|FFOFurRedBrown');

    SetMorph(npc, 4726, 'Nostrils', 'Broad');
    SetMorphBoneName(npc, 'Ears',
        0,    0,    0, 
        0,    0,    0,
        -0.2);
    SetMorphBoneName(npc, 'Nose - Full',
        0,  1.0, -1.0, 
        0,    0,    0,
        0.5);
end;

Procedure MakeDeerMoose(npc: IwbMainRecord);
var
    h: integer;
begin
    SetWeight(npc, 1, 2, 2);
    if GetNPCSex(npc) = MALE then begin
        SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns08');
        SetHeadpart(npc, HEADPART_FACIAL_HAIR, 'FFOBeard01');
    end;

    SetTintLayerColor(npc, 6032, TL_SKIN_TONE,  
        'FFOFurBrown|FFOFurBrownD|FFOFurRussetD|FFOFurGingerD|FFOFurRedBrown');
    
    SetMorph(npc, 4726, 'Nostrils', 'Broad');
    SetMorphBoneName(npc, 'Jaw', 
        0, 0, 0.75, 
        0, 0, 0, 
        0);
    SetMorphBoneName(npc, 'Nose - Full',
        0, -0.4, 0.24, 
        0, 0, 0, 
        0.8);
    SetMorphBoneName(npc, 'Cheekbones', 
        1, 0, 0,
        0, 0, 0,
        0);
end;

Procedure MakeDeerAntelope(npc: IwbMainRecord);
var
    h: integer;
begin
    SetWeight(npc, 2, 2, 1);
    h := Hash(EditorID(npc), 6728, 2);
    case h of
        0: SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns03'); // Gazelle
        1: SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns10'); // PRonghorn
    end;

    SetTintLayerColor(npc, 1740, TL_SKIN_TONE,  
        '|FFOFurGingerL|FFOFurBrown|FFOFurTan|FFOFurGinger|FFOFurBrownL|FFOFurTanD|');
    SetTintLayerColor(npc, 8514, TL_EYESOCKET_LOWER, 'FFOFurWhite');
    SetTintLayerColor(npc, 2412, TL_EYEBROW, 'FFOFurWhite');
    SetTintLayerColorProb(60, npc, 5794, TL_MUZZLE, '');
    SetTintLayerColorProb(60, npc, 5273, TL_MUZZLE_STRIPE, '');
    SetTintLayerColorProb(60, npc, 6305, TL_CHIN, '');
    SetTintLayerColorProb(60, npc, 8560, TL_CHEEK_COLOR, '');
    SetTintLayerColorProb(60, npc, 8631, TL_CHEEK_COLOR_LOWER, '');

    SetMorph(npc, 4726, 'Nostrils', 'Broad');
    SetMorphBoneName(npc, 'Ears', 
        0, 0, 0,
        0, 0, 0,
        0.86);
    SetMorphBoneName(npc, 'Nose - Full', 
        0, -0.24, -0.54,
        -0.27, 0, 0,
        0.51);
    SetMorphBoneName(npc, 'Eyes', 
        -0.45, -0.56, 0,
        0, 0, 0,
        0.55);
    SetMorphBoneName(npc, 'Nose - Bridge',
        0, 0.6, 0.6, 
        0, 0, 0,
        0);
end;

Procedure MakeDeerRam(npc: IwbMainRecord);
var
    h: integer;
begin
    SetWeight(npc, 1, 2, 2);
    if GetNPCSex(npc) = MALE then begin
        SetHeadpart(npc, HEADPART_EYEBROWS, 'FFODeerHorns07'); 
        SetHeadpart(npc, HEADPART_FACIAL_HAIR, 'FFOBeard01');
    end;

    SetTintLayerColor(npc, 8312, TL_SKIN_TONE,  
        '|FFOFurGingerL|FFOFurBrown|FFOFurTan|FFOFurGinger|FFOFurBrownL|');
    SetTintLayerColorProb(50, npc, 7698, TL_MUZZLE, 'FFOFurWhite');

    SetMorphBoneName(npc, 'Jaw', 
        0, 0, 0.6,
        0, 0, 0,
        0);
    SetMorphBoneName(npc, 'Nose - Full',
        0, 0, -0.6, 
        0, 0, 0,
        0.6);
    SetMorphBoneName(npc, 'Cheekbones', 
        1, 0, 0,
        0, 0, 0,
        0);
end;

//================================================================
// Set up a realistic deer.
Procedure FurrifyDeer(npc, hair: IwbMainRecord);
var
    deerType: integer;
begin
    ChooseHair(npc, hair);
    ChooseHeadpart(npc, HEADPART_EYES);
    ChooseHeadpart(npc, HEADPART_FACE);

    if GetNPCClass(npc) = CLASS_BOBROV then 
        deerType := 4
    else
        deerType := Hash(EditorID(npc), 9477, 6);
    
    case deerType of
        0: MakeDeerWhitetail(npc);
        1: MakeDeerElk(npc);
        2: MakeDeerReindeer(npc);
        3: MakeDeerMoose(npc);
        4: MakeDeerAntelope(npc);
        5: MakeDeerRam(npc);
    end;
end;
//================================================================
// Special tailoring for lions. 50% of the males get manes.
Procedure FurrifyLion(npc, hair: IwbMainRecord);
begin
    Log(4, '<FurrifyLion: ' + EditorID(npc));
    SetWeight(npc, 1, 2, 1);
    ChooseHeadpart(npc, HEADPART_FACE);
    ChooseHeadpart(npc, HEADPART_EYES);

    if GetNPCSex(npc) = MALE and 
            ((Hash(EditorID(npc), 9203, 100) > 50) 
                or ContainsText(EditorID(npc), 'PrestonGarvey')
            ) then begin
        SetHeadpart(npc, HEADPART_HAIR, 'FFO_HairMaleMane');
    end
    else
        ChooseHair(npc, hair);

    ChooseHeadpart(npc, HEADPART_EYEBROWS);
    ChooseTint(npc, TL_SKIN_TONE, 6351);
    ChooseTint(npc, TL_NOSE, 1140);
    Log(4, '>FurrifyLion');
end;

//==========================================================
// Furrify the NPC, if possible.
// Returns the furry NPC
Function FurrifyNPC(npc: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
var
    r: integer;
    furryNPC: IwbMainRecord;
    hair: IwbMainRecord;
begin
    Log(4, '<FurrifyNPC: ' + EditorID(npc));
    result := npc;
    r := ChooseNPCRace(npc);
    if r >= 0 then begin
        furryNPC := CreateNPCOverride(npc, targetFile);
        hair := SetNPCRace(furryNPC, r);
        case r of 
            RACE_DEER: FurrifyDeer(furryNPC, hair);
            RACE_LION: FurrifyLion(furryNPC, hair);
        else 
            begin
            ChooseHeadpart(furryNPC, HEADPART_FACE);
            ChooseHeadpart(furryNPC, HEADPART_EYES);
            ChooseHair(furryNPC, hair);
            ChooseHeadpart(furryNPC, HEADPART_EYEBROWS);
            ChooseTint(furryNPC, TL_SKIN_TONE, 9523);
            ChooseTint(furryNPC, TL_MASK, 2188);
            ChooseTint(furryNPC, TL_MUZZLE, 9487);
            ChooseTint(furryNPC, TL_EAR, 552);
            ChooseTint(furryNPC, TL_NOSE, 6529);
            SetAllRandomMorphs(furryNPC);
            end;
        end;
        result := furryNPC;
    end;
    Log(4, '>FurrifyNPC');
end;

//======================================================================
// Furrify a single NPC.
// npc is the winning override prior to FFO. 
// If the NPC already exists in the target mod, that definition will be overwritten.
// Returns the new furry npc.
Function MakeFurryNPC(npc: IwbMainRecord; targetFile: IwbFile): IwbMainRecord;
var
    furryNPC: IwbMainRecord;
    npcHair: IwbMainRecord;
begin
    Log(5, Format('<MakeFurryNPC %s -> %s', [EditorID(npc), GetFileName(targetFile)]));

    if furrifiedNPCs.IndexOf(EditorID(npc)) < 0 then begin
        furryNPC := FurrifyNPC(npc, targetFile);
        furrifiedNPCs.Add(EditorID(npc));
        Result := furryNPC;
    end
    else
        Result := WinningOverride(npc);

    Log(5, '>MakeFurryNPC');
end;


//=========================================================================
// Create the new patch mod if it doesn't exist alerady.
Function CreateOverrideMod(filename: string): IwbFile;
var
    f: integer;
    fn: string;
    i: integer;
begin
    Log(3, '<CreateOverrideMod ' + filename);
    f := -1;
    for i := 0 to FileCount-1 do begin
        if SameText(GetFileName(FileByIndex(i)), filename) then begin
            f := i;
            break;
        end;
    end;
    if f >= 0 then
        Result := FileByIndex(f)
    else begin
        Result := AddNewFileName(filename);
        patchFileCreated := true;
    end;

    if patchFileCreated then begin
        AddRecursiveMaster(Result, FileByIndex(0));

        for i := 0 to FileCount-1 do begin
            fn := GetFileName(FileByIndex(i));
            if StartsText('DLC', fn) then 
                AddRecursiveMaster(Result, FileByIndex(i))
            else if SameTExt(fn, 'FurryFallout.esp') then 
                AddRecursiveMaster(Result, FileByIndex(i))
            else if SameText(fn, 'FurryFalloutDLC.esp') then
                AddRecursiveMaster(Result, FileByIndex(i));
        end;
    end;
    Log(3, '>CreateOverrideMod');

end;

//=====================================================
// Determine if the NPC needs to be furrified.
// - Must be HumanRace or furry race (we redo any furry NPCs)
// - Must not get its race from a template
// - Must not be overridden (we'll do this NPC when we get to the last override).
// Returns
// 0 - No furrification required
// 1 - Furrify the sucker
// 2 - NPC is based on a template (need to zero its morphs)
Function IsValidNPC(npc: IwbMainRecord): integer;
var
    race: IwbMainRecord;
begin
    Log(5, '<IsValidNPC: ' + EditorID(npc));
    result := 1;
    // Must be an NPC
    Log(5, 'Signature: ' + Signature(npc));
    if Signature(npc) <> 'NPC_' then
        result := 0;

    if result > 0 then begin
        // Must not be overridden--we only work with the latest version
        Log(5, 'Overrides: ' + IntToStr(OverrideCount(npc)));
        if OverrideCount(npc) > 0 then 
            result := 0;
    end;

    if result > 0 then begin
        // Must be a furrifiable race
        race := GetNPCRace(npc);
        if (masterRaceList.IndexOf(EditorID(race)) < 0) 
            and (childRaceList.IndexOf(EditorID(race)) < 0)
            and (EditorID(race) <> 'HumanRace') 
            and (EditorID(race) <> 'HumanChildRace') 
            and (EditorID(race) <> 'GhoulRace') 
            and (EditorID(race) <> 'GhoulChildRace') 
        then
            result := 0;
    end;
    
    if result > 0 then begin
        // Must not be any of the player records, or Shaun--those are in the player race files
        Log(5, 'Is player: ' + IntToStr(playerIDs.IndexOf(EditorID(npc))));
        if playerIDs.IndexOf(EditorID(npc)) >= 0 then
            result := 0;
    end;

    if result > 0 then begin
        // Must not be a preset--furry races have their own
        if GetElementEditValues(npc, 'ACBS - Configuration\Flags\Is Chargen Face Preset') = '1' then
            result := 0;
    end;
    
    if result > 0 then begin
        // If it gets traits from a template, just zero out the morphs.
        if GetElementEditValues(npc, 'ACBS - Configuration\Use Template Actors\Traits') = '1' then
            result := 2;
    end;

    Log(5, '>IsValidNPC: ' + IntToStr(result));
end;

//========================================================
// Set everything up.
Procedure InitializeFurrifier;
begin
    InitializeAssetLoader;
    SetTintLayerTranslations;
    SetRaceProbabilities;

    LoadRaceAssets;
    SetRaceDefaults;
    TailorRaces;

    furrifiedNPCs := TStringList.Create();
    furrifiedNPCs.Duplicates := dupIgnore;
    furrifiedNPCs.Sorted := true;

    playerIDs := TStringList.Create();
    playerIDs.Duplicates := dupIgnore;
    playerIDs.Sorted := true;
    playerIDs.Add('Player');
    playerIDs.Add('MQ101PlayerSpouseMale');
    playerIDs.Add('MQ101PlayerSpouseFemale');
    playerIDs.Add('Shaun');
    playerIDs.Add('shaun');
    playerIDs.Add('ShaunChild');
    playerIDs.Add('MQ203MemoryH_Shaun');
    playerIDs.Add('ShaunChildHologram');

    RACE_CHEETAH := masterRaceList.IndexOf('FFOCheetahRace');
    RACE_DEER := masterRaceList.IndexOf('FFODeerRace');
    RACE_FOX := masterRaceList.IndexOf('FFOFoxRace');
    RACE_HORSE := masterRaceList.IndexOf('FFOHorseRace');
    RACE_HYENA := masterRaceList.IndexOf('FFOHyenaRace');
    RACE_LION := masterRaceList.IndexOf('FFOLionRace');
    RACE_LYKAIOS := masterRaceList.IndexOf('FFOLykaiosRace');
    RACE_OTTER := masterRaceList.IndexOf('FFOOtterRace');
    RACE_SNEKDOG := masterRaceList.IndexOf('FFOSnekdogRace');
    RACE_TIGER := masterRaceList.IndexOf('FFOTigerRace');

    AddMorphBone('FFODeerRace', MALE, 'Cheekbones');
    AddMorphBone('FFODeerRace', MALE, 'Ears');
    AddMorphBone('FFODeerRace', MALE, 'Eyes');
    AddMorphBone('FFODeerRace', MALE, 'Jaw');
    AddMorphBone('FFODeerRace', MALE, 'Nose - Bridge');
    AddMorphBone('FFODeerRace', MALE, 'Nose - Full');
    AddMorphBone('FFODeerRace', FEMALE, 'Cheekbones');
    AddMorphBone('FFODeerRace', FEMALE, 'Ears - Full');
    AddMorphBone('FFODeerRace', FEMALE, 'Eyes');
    AddMorphBone('FFODeerRace', FEMALE, 'Nose - Bridge');
    AddMorphBone('FFODeerRace', FEMALE, 'Nose - Full');

    patchFileCreated := false;
end;

//=========================================================
// Free up anything allocated in startup.
Procedure ShutdownFurrifier;
begin
    furrifiedNPCs.Free;
    playerIDs.Free;
    ShutdownAssetLoader;
end;

// initialize stuff
function Initialize: integer;
var
  i: Integer;
  j: Integer;
  coll: TCollection;
  s: string;
  f: IwbFile;
  haveTarget: boolean;
begin
	// welcome messages
	AddMessage(#13#10);
	AddMessage('==========================================================');
	AddMessage('Furry Fallout Furrifier');
    AddMessage('');
    AddMessage('Running on ' + wbAppName);
	AddMessage('----------------------------------------------------------');
	AddMessage('');

	AddMessage('----------------------------------------------------------');
    if USE_SELECTION then 
        AddMessage('Furrifying selected NPCs only')
    else 
        AddMessage('Furrifying selected NPCs only');
    
    if length(TARGET_RACE) > 0 then
        AddMessage('All affected NPCs will be changed to ' + TARGET_RACE);

    AddMessage('Patch file is ' + patchfileName);
	AddMessage('----------------------------------------------------------');

    LOGLEVEL := 1;
    errCount := 0;
    warnCount := 0;

    preFurryCount := FileCount;
    patchFile := CreateOverrideMod(patchfileName);
    furryCount := 0;
    convertingGhouls := false;

    InitializeFurrifier;
end;

// Process selected NPCs.
// If we are using the selection, they get furrified here.
function Process(entity: IwbMainRecord): integer;
var
    win: IwbMainRecord;
begin
    if not USE_SELECTION then exit;
    win := WinningOverride(entity);

    Log(2, Format('Furrifying %s in %s', [EditorID(win), GetFileName(GetFile(win))]));

    if (furryCount mod 100) = 0 then
        AddMessage(Format('Furrifying %s: %d', [
            GetFileName(GetFile(win)), integer(furryCount)]));
    
    case IsValidNPC(win) of
        1: MakeFurryNPC(win, patchFile);
        2: OverrideAndZeroMorphs(win, patchFile);
    end;

    furryCount := furryCount + 1;
end;

// If not using the selection, furrify everything here. 
function Finalize: integer;
var
    f, n: integer;
    npc: IwbMainRecord;
    npcList: IwbContainer;
begin
    if not USE_SELECTION then begin
        for f := 0 to preFurryCount-1 do begin
            // Don't check the NPCs in the patch file if we created it on this run.
            Log(2, 'File ' + GetFileName(FileByIndex(f)));
            furryCount := 0;
            npcList := GroupBySignature(FileByIndex(f), 'NPC_');
            for n := 0 to ElementCount(npcList)-1 do begin
                if (furryCount mod 100) = 0 then
                    AddMessage(Format('Furrifying %s: %d', 
                        [GetFileName(FileByIndex(f)), furryCount]));

                npc := ElementByIndex(npcList, n);
                Case IsValidNPC(npc) of
                    1: MakeFurryNPC(npc, patchFile);
                    // Creating the override will zero the morphs, which we need because human
                    // morphs won't work on furry races. 
                    2: OverrideAndZeroMorphs(npc, patchFile);
                end;
                furryCount := furryCount + 1;
            end;
        end;
    end;

    // If we furrified the ghouls, then any headgear added by FFO that supports Snekdogs (or
    // whatever race we are turning ghouls into) needs to be modified to add the ghoul race.
    if convertingGhouls then begin
        AddRaceToAllArmor(patchFile, 
            FindAsset(Nil, 'RACE', 'GhoulRace'), // this race must be added to
            ghoulRace); // ARMA records that allow this race
    end;

    if not USE_SELECTION then GenerateFurryNPCs(patchFile);

    ShutdownFurrifier;

	AddMessage('----------------------------------------------------------');
    if (errCount = 0) and (warnCount = 0) then
        AddMessage(Format('Furrification completed SUCCESSFULLY'))
    else
        AddMessage(Format('Furrification completed with %d ERROR%s and %d WARNING%s', [
            errCount, IfThen(errCount = 1, '', 'S'), 
            warnCount, IfThen(warnCount = 1, '', 'S')
        ]));
	AddMessage('==========================================================');
end;
end.