{
    Defines additional races specific to the user.

    Add any special setup for your own furry races here. Assign them to vanilla races
    in BDFurrySkyrim_Preferences.pas.

    See BDFurrySkyrimRaceDefs.pas for examples of use.

    SetTintLayerClass(racename, filename, classname: string)
        Defines the class of a furry tint layer. The furrifier will assign one tint of
        each class to an NPC. Define a tint layer preset with no color (value of 0) if the
        tint layer should not always be assigned. If the tint layer is a warpaint, it will
        only assign it if the NPC has warpaint.

        - racename: The EditorID of the furry race
        - filename: A substring of the tint layer filepath to match.
        - classname: The class of the tint layer.

    AssignHeadpart(vanillaHPName, furryHPName: string)
        Assigns a furry headpart to a vanilla headpart. Any NPC with the vanilla headpart
        will be assigned the furry headpart.
        - vanillaHPName: The EditorID of the vanilla headpart
        - furryHPName: The EditorID of the furry headpart

    LabelHeadpartList(headpartName, labelNames: string)
        Assigns descriptive labels to a headpart. When choosing a headpart (especially
        hair) the furrifier defines labels for the NPC based on hair, voice, dress,
        factions, and other characteristics. It then chooses the headpart that matches the
        most labels. 

        - headpartName: The EditorID of the headpart
        - labelNames: A comma-separated list of labels to assign

    SetTintLayerRequired -- Not currently used.
}
unit BDFurrySkyrimUserRaceDefs;

interface
implementation
uses BDFurrySkyrimTools, BDScriptTools, xEditAPI, Classes, SysUtils, StrUtils, Windows;


{ ================================================================================
    Put any special setup for a furry race here. Anything not defined will use defaults.
  ================================================================================ }
procedure DefineFurryRacesUser;
begin

end;

end.