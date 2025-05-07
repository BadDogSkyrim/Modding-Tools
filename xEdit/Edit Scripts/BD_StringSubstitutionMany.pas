{
  * DESCRIPTION *
  This script can be used to rename the EDID of items in bulk.
  For string replace, use "oldstring/newstring"

}

unit BD_StringSubstitutionMany;

interface
implementation
uses xEditAPI, Classes, StrUtils;

const
    doIt = TRUE;

var
    targetPath, secondPath: string;
    srcPath, dstPath: TStringList;
    targetElem, targetElem2: TStringList;
    oldString, newString: string;
    isChanged: boolean;


//=========================================================================
// initialize stuff
function Initialize: integer;
begin
    AddMessage(#13#10);
    AddMessage('----------------------------------------------------------');
    AddMessage('--------------------BD String Substitution----------------');
    AddMessage('----------------------------------------------------------');
    AddMessage('');  

    if not doIt then begin
        //ReplaceText doesn't exist// AddMessage(Format('ReplaceText: %s -> %s', ['foobar', ReplaceText('foobar', 'ba', 'ZZ')]));
        //AnsiReplaceText doesn't exist// AddMessage(Format('AnsiReplaceText: %s -> %s', ['foobar', AnsiReplaceText('foobar', 'ba', 'ZZ')]));
        //ReplaceStr doesn't exist// AddMessage(Format('ReplaceStr: %s -> %s', ['foobar', ReplaceStr('foobar', 'ba', 'ZZ')]));
        AddMessage(Format('Uppercase: %s -> %s', ['foobar', UpperCase('foobar')]));
    end;


    srcPath := TStringList.Create;
    dstPath := TStringList.Create;
    targetElem := TStringList.Create;
    targetElem2 := TStringList.Create;

    DoSubst('Female 1st Person\MOD5', '', 'actors\character\BDBeastModels\1stpersonfemalebeasthands_1.nif', 'YAS\Feline\Hands\CatFemHands_1.nif');

    DoSubst('Female Biped Model\MOD3', '', 'actors\character\BDBeastModels\felinefemalefeet_1.nif', 'YAS\Feline\Feet\CatFemFeet_1.nif');
    DoSubst('Female Biped Model\MOD3', '', 'actors\character\BDBeastModels\femalehandsbeast_1.nif', 'YAS\Feline\Hands\CatFemHands_1.nif');
    DoSubst('Female Biped Model\MOD3', '', 'actors\character\BDBeastModels\Tail\FemaleTailKhajiit.nif', 'YAS\Feline\Tail\FemaleTailKhajiit.nif');
    DoSubst('Female Biped Model\MOD3', '', 'actors\character\BDBeastModels\caninefemalefeet_1.nif', 'YAS\Canine\Feet\CanFemFeet_1.nif');
    DoSubst('Female Biped Model\MOD3', '', 'actors\character\BDBeastModels\Tail\BrushFemaleTail.nif', 'YAS\Canine\Tail\BrushFemTail.nif');

    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadDarkElfWarPaint_01.dds', 'YAS\Beast\Fem\Tints\FemaleHeadDarkElfWarPaint_01.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadDarkElfWarPaint_02.dds', 'YAS\Beast\Fem\Tints\FemaleHeadDarkElfWarPaint_02.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadDarkElfWarPaint_03.dds', 'YAS\Beast\Fem\Tints\FemaleHeadDarkElfWarPaint_03.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadDarkElfWarPaint_04.dds', 'YAS\Beast\Fem\Tints\FemaleHeadDarkElfWarPaint_04.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadDarkElfWarPaint_05.dds', 'YAS\Beast\Fem\Tints\FemaleHeadDarkElfWarPaint_05.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadDarkElfWarPaint_06.dds', 'YAS\Beast\Fem\Tints\FemaleHeadDarkElfWarPaint_06.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadWarPaint_01.dds', 'YAS\Beast\Fem\Tints\femaleheadwarpaint_01.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadWarPaint_02.dds', 'YAS\Beast\Fem\Tints\femaleheadwarpaint_02.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadWarPaint_03.dds', 'YAS\Beast\Fem\Tints\femaleheadwarpaint_03.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadWarPaint_04.dds', 'YAS\Beast\Fem\Tints\femaleheadwarpaint_04.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadWarPaint_05.dds', 'YAS\Beast\Fem\Tints\femaleheadwarpaint_05.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadWarPaint_06.dds', 'YAS\Beast\Fem\Tints\femaleheadwarpaint_06.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadWarPaint_07.dds', 'YAS\Beast\Fem\Tints\femaleheadwarpaint_07.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadWarPaint_08.dds', 'YAS\Beast\Fem\Tints\femaleheadwarpaint_08.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadWarPaint_09.dds', 'YAS\Beast\Fem\Tints\femaleheadwarpaint_09.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadWarPaint_10.dds', 'YAS\Beast\Fem\Tints\femaleheadwarpaint_10.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadWoodElfWarPaint', 'YAS\Beast\Fem\Tints\FemaleHeadDarkElfWarPaint');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\khajiitchinshade.dds', 'YAS\Beast\Male\Tints\khajiitchinshade.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\KhajiitEyeliner.dds', 'YAS\Beast\Male\Tints\KhajiitEyeliner.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\KhajiitEyeSocketLower.dds', 'YAS\Beast\Male\Tints\KhajiitEyeSocketLower.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\KhajiitForehead.dds', 'YAS\Beast\Male\Tints\KhajiitForehead.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\KhajiitLipColor.dds', 'YAS\Beast\Male\Tints\KhajiitLipColor.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\khajiitneckshade.dds', 'YAS\Beast\Male\Tints\khajiitneckshade.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'Actors\Character\Character Assets\TintMasks\FemaleHeadBothiahTattoo_01.dds', 'YAS\Beast\Fem\Tints\FemaleHeadBothiahTattoo_01.dds');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FemaleHeadOrcWarPaint_', 'YAS\Beast\Fem\Tints\FemaleHeadOrcWarPaint_');
    DoSubst('Head Data\Female Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FullMask.dds', 'YAS\Beast\Male\Tints\FullMask.dds');

    DoSubst('Head Data\Male Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\KhajiitEyeSocketLower.dds', 'YAS\Beast\Male\Tints\KhajiitEyeSocketLower.dds');
    DoSubst('Head Data\Male Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\MaleHeadBothiahTattoo_01.dds', 'YAS\Beast\Male\Tints\maleheadbothiahtattoo_01.dds');
    DoSubst('Head Data\Male Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\FullMask.dds', 'YAS\Beast\Male\Tints\FullMask.dds');
    DoSubst('Head Data\Male Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\StripedMuzzle.dds', 'YAS\Beast\Male\Tints\StripedMuzzle.dds');
    DoSubst('Head Data\Male Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\Muzzle.dds', 'YAS\Beast\Male\Tints\Muzzle.dds');
    DoSubst('Head Data\Male Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\NoseStripeMuzzle.dds', 'YAS\Beast\Male\Tints\NoseStripeMuzzle.dds');
    DoSubst('Head Data\Male Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\NoseStripeLargeMuzzle.dds', 'YAS\Beast\Male\Tints\NoseStripeLargeMuzzle.dds');
    DoSubst('Head Data\Male Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\NoseDot2Muzzle.dds', 'YAS\Beast\Male\Tints\NoseDot2Muzzle.dds');
    DoSubst('Head Data\Male Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\maleheadlykaiosskull.dds', 'YAS\Beast\Male\Tints\maleheadlykaiosskull.dds');
    DoSubst('Head Data\Male Head Data\Tint Masks', 'Tint Layer\Texture\TINT - File Name', 'actors\character\BDBeastTextures\tintmasks\MaleHeadImperialWarPaint_', 'YAS\Beast\Male\Tints\MaleHeadImperialWarPaint_');

    DoSubst('Male 1st Person\MOD4', '', 'actors\character\BDBeastModels\1stpersonmalebeasthands_1.nif', 'YAS\Feline\Hands\CatMaleHands_1.nif');

    DoSubst('Male Biped Model\MOD2', '', 'actors\character\BDBeastModels\felinemalefeet_1.nif', 'YAS\Feline\Feet\CatMaleFeet_1.nif');
    DoSubst('Male Biped Model\MOD2', '', 'actors\character\BDBeastModels\malehandsbeast_1.nif', 'YAS\Feline\Hands\CatMaleHands_1.nif');
    DoSubst('Male Biped Model\MOD2', '', 'actors\character\BDBeastModels\Tail\MaleTailKhajiit.nif', 'YAS\Feline\Tail\MaleTailKhajiit.nif');
    DoSubst('Male Biped Model\MOD2', '', 'actors\character\BDBeastModels\caninemalefeet_1.nif', 'YAS\Canine\Feet\CanMaleFeet_1.nif');
    DoSubst('Male Biped Model\MOD2', '', 'actors\character\BDBeastModels\Tail\BrushMaleTail.nif', 'YAS\Canine\Tail\BrushMaleTail.nif');

    DoSubst('Model\MODL - Model FileName', '', 'actors\character\BDHeadParts\eye\EyesFemaleBichromBlindL.nif', 'YAS\Beast\EyesFemaleBichromBlindL.nif');
    DoSubst('Model\MODL - Model FileName', '', 'actors\character\BDHeadParts\eye\EyesFemaleBichromBlindR.nif', 'YAS\Beast\EyesFemaleBichromBlindR.nif');
    DoSubst('Model\MODL - Model FileName', '', 'actors\character\BDHeadParts\eye\eyeskhajiitfemaleblind.nif', 'YAS\Beast\eyeskhajiitfemaleblind.nif');
    DoSubst('Model\MODL - Model FileName', '', 'actors\character\BDHeadParts\eye\eyeskhajiitfemaleglow.nif', 'YAS\Beast\eyeskhajiitfemaleglow.nif');
    DoSubst('Model\MODL - Model FileName', '', 'actors\character\BDHeadParts\eye\eyeskhajiitglow.nif', 'YAS\Beast\eyeskhajiitglow.nif');
    DoSubst('Model\MODL - Model FileName', '', 'actors\character\BDHeadParts\hair\Khajiit\Female\', 'YAS\Beast\HairFem\Khajiit');
    DoSubst('Model\MODL - Model FileName', '', 'actors\character\BDHeadParts\hair\HairShortHumanM.nif', 'YAS\Beast\HairMale\HairShortHumanM.nif');

    DoSubst('Parts', 'NAM1 - FileName', 'actors\character\BDHeadParts\head\CitrusFemaleHeadChargen.tri', 'YAS\Citrus\CitrusFemHeadChargen.tri');
    DoSubst('Parts', 'NAM1 - FileName', 'actors\character\BDHeadParts\head\CitrusFemaleHeadRoundEar.tri', 'YAS\Citrus\CitrusFemHeadRoundEar.tri');

    DoSubst('Textures (RGB/A)\TX01', '', 'actors\character\BDBeastTextures\SmoothFemaleBody_msn.dds', 'YAS\Feline\Body\CatFemBodySmooth_msn.dds');
    DoSubst('Textures (RGB/A)\TX01', '', 'actors\character\BDBeastTextures\SmoothFemaleHands_msn.dds', 'YAS\Feline\Hands\CatFemHandsSmooth_msn.dds');
    DoSubst('Textures (RGB/A)\TX01', '', 'actors\character\BDBeastTextures\SmoothMaleBody_msn.dds', 'YAS\Feline\Body\CatMaleBodySmooth_msn.dds');
    DoSubst('Textures (RGB/A)\TX01', '', 'actors\character\BDBeastTextures\smoothmalehands_msn.dds', 'YAS\Feline\Hands\CatMaleHandsSmooth_msn.dds');

    DoSubst('Textures (RGB/A)\TX07', '', 'actors\character\BDBeastTextures\FelineFemaleFeet_s.dds', 'YAS\Feline\Feet\CatFemFeet_s.dds');
    DoSubst('Textures (RGB/A)\TX07', '', 'actors\character\BDBeastTextures\FelineMaleFeet_s.dds', 'YAS\Feline\Feet\CatMaleFeet_s.dds');
    DoSubst('Textures (RGB/A)\TX07', '', 'actors\character\BDBeastTextures\SmoothFemaleHands_s.dds', 'YAS\Feline\Hands\CatFemHands_s.dds');
end;


procedure DoSubst(const e1, e2, s1, s2: string);
begin
    targetElem.Add(e1);
    targetElem2.Add(e2);
    srcPath.Add(s1);
    dstPath.Add(s2);
end;


function ReplaceSubstring(const Source, OldSub, NewSub: string): string;
var
    PosStart: integer;
    a, b: string;
begin
    Result := Source;
    isChanged := FALSE;
    a := Uppercase(OldSub);
    b := Uppercase(Source);
    PosStart := Pos(a, b);
    // AddMessage(Format('Found string %s at %d', [OldSub, PosStart]));
    // AddMessage(Format('Strings are identical: "%s" = "%s": %s', [
    //     a, b, IfThen(SameText(a, b), 'TRUE', 'FALSE')]));
    if (PosStart > 0) then begin
        isChanged := TRUE;
        Result := Copy(Source, 1, PosStart - 1) + NewSub + Copy(Source, PosStart + Length(OldSub), MaxInt);
    end;
end;


procedure ProcessOne(e: IwbMainRecord; tp: IwbElement);
var t1, t2: string;
    i: integer;
begin
    t1 := GetEditValue(tp);
    t2 := ReplaceSubstring(t1, oldString, newString);
    if not doIt then AddMessage(Format('Processing %s (%s) (%s): %s -> %s', [PathName(tp), oldstring, newstring, t1, t2]));
    if isChanged then begin
        AddMessage(Format('Substituting %s: %s -> %s', [PathName(tp), t1, t2]));
        if doIt then SetEditValue(tp, t2);
    end;
end;


//=========================================================================
// process selected records
function Process(e: IwbMainRecord): integer;
var t1, t2: string;
    tp, tp2: IwbElement;
    i, j: integer;
begin
    for j := 0 to srcPath.Count - 1 do begin
        targetpath := targetElem[j];
        secondPath := targetElem2[j];
        oldString := srcPath[j];
        newString := dstPath[j];

        tp := ElementByPath(e, targetPath);
        if not doIt then AddMessage(Format('Processing %s/%s/%s "%s" -> "%s"', [EditorID(e), targetPath, secondPath, oldString, newString]));

        // AddMessage(Format('Substitution: %s[%s] "%s" -> "%s"', [EditorID(e), targetPath, oldString, newString]));
        if ElementCount(tp) = 0 then 
            ProcessOne(e, tp)
        else begin
            for i := 0 to ElementCount(tp) - 1 do begin
                tp2 := ElementByPath(ElementByIndex(tp, i), secondPath);
                ProcessOne(e, tp2);
            end;
        end;
    end;
end;

//=========================================================================
// finalize: where all the stuff happens
function Finalize: integer;
begin
    srcPath.Free;
    dstPath.Free;
    targetElem.Free;
    targetElem2.Free;
end;
end.
