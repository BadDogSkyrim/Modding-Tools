import os
import struct
import collections
from pathlib import Path

targetFolder = r"C:\Modding\Fallout4\mods\Furry Fallout\Materials"

targetPaths = [r"C:\Modding\Fallout4\mods\Furry Fallout",
               r"C:\Modding\Fallout4\mods\00 FO4 Assets"]

class BGSMaterial:
    def __init__(self):
        self.fields1 = ""
        self.fields2 = ""
        self.fields3 = ""
        self.fields4 = ""
        self.fields5 = ""
        self.header = []
        self.data1 = []
        self.data2 = []
        self.data3 = []
        self.data4 = []
        self.data5 = []
        self.texturefiles = {}

    def __str__(self):
        s = "Header = " + str(self.header)
        s += '\n' + "Data1 = " + str(self.data1)
        s += '\n' + "Data2 = " + str(self.data2)
        s += '\n' + "Data3 = " + str(self.data3)
        s += '\n' + "Data4 = " + str(self.data4)
        s += '\n' + "Data5 = " + str(self.data5)
        for t, f in self.texturefiles.items():
            s += '\n' + f"{t} = {f}"
        return s

    def read(self, fn):
        """Read BGSM info from a materials file."""
        headerStruct = struct.Struct("<4sI")
        BGSMHeader = collections.namedtuple(
            'BGSMHeader', 
            ['signature', 'version'])

        bgsmpattern1 = "<I2f2f fBIIB? ?? ?? ???? ??f"
        self.fields1 = [
            'tileFlags', 'uOffset', 'vOffset', 'uScale', 'vScale', 
            'alpha', 'alphblend0', 'alphblend1', 'alphblend2', 'alphatestref', 'alphatest',
            'zbufferwrite', 'zbuffertest',
            'screenSpaceReflections', 'wetnessControlScreenSpaceReflections',
            'decal', 'twoSided', 'decalNoFade', 'nonOccluder',
            'refraction', 'refractionFalloff', 'refractionPower',]

        with open(fn, 'rb') as f:
            print(f"Reading '{fn}'")
            buf = f.read(headerStruct.size)
            v = headerStruct.unpack(buf)
            self.header = BGSMHeader._make(v)

            if self.header.version < 10:
                bgsmpattern1 += " ?f" # envMap, envMapMaskScale
                self.fields1 += [
                    'environmentMapping', 'environmentMappingMaskScale',
                ]

            else:
                bgsmpattern1 += " ?" # depthBias
                self.fields1 += ['depthBias',]

            bgsmpattern1 += " ?"
            self.fields1 += ['grayscaleToPaletteColor']

            if self.header.version > 6:
                bgsmpattern1 += " B"
                self.fields1 += ['maskWrites']

            generalStruct = struct.Struct(bgsmpattern1)
            BGSMGeneral = collections.namedtuple('BGSMGeneral', self.fields1)

            buf = f.read(generalStruct.size)
            v2 = generalStruct.unpack(buf)
            self.data1 = BGSMGeneral._make(v2)

            #---------

            textureFileList = [
            'Diffuse', 'Normal', 'SmoothSpec', 'Greyscale'
            ]

            if self.header.version > 2:
                textureFileList += ['Glow', 'Wrinkles', 'Specular', 'Lighting', 'Flow',]
            
                if self.header.version > 17:
                    textureFileList += ['DistanceFieldAlpha',]

            else:
                textureFileList += ['Envmap', 'Glow', 'InnerLayer', 'Wrinkles', 
                                    'Displacement']
            
            for tf in textureFileList:
                n = struct.unpack('<I', f.read(4))[0]
                t = f.read(n).decode().rstrip('\x00')
                self.texturefiles[tf] = t

            #---------

            bgsmpattern2 = "<?"
            self.fields2 = ["enableEditorAlphaRef", ]

            if self.header.version >= 8:
                bgsmpattern2 += " ???IIIff"
                self.fields2 += [
                    "translucency", "translucencyThickObject", 
                    "translucencyMixAlbedoWithSubsurfaceColor", 
                    "translucencySubsurfaceColorR", "translucencySubsurfaceColorG", "translucencySubsurfaceColorB", 
                    "translucencyTransmissiveScale", "translucencyTurbulence"]
            else:
                bgsmpattern2 += " ?ff?f"
                self.fields2 += [
                    "rimLighting", "rimPower", "backLightPower", "subsurfaceLighting",
                    "subsurfaceLightingRolloff"]
                
            bgsmpattern2 += " ?IIIffffff"
            self.fields2 += [
                "specularEnabled", "specularColorR", "specularColorG", "specularColorB", "specularMult", 
                "smoothness", "fresnelPower", 
                "wetnessControlSpecScale", "wetnessControlSpecPowerScale", "wetnessControlSpecMinvar"]

            if self.header.version < 10:
                bgsmpattern2 += " f"
                self.fields2 += ["wetnessControlEnvMapScale", ]

            bgsmpattern2 += " ff"
            self.fields2 += ["wetnessControlFresnelPower", "wetnessControlMetalness"]

            if self.header.version > 2:
                bgsmpattern2 += " ?"
                self.fields2 += ["pbr", ]

                if self.header.version >= 9:
                    bgsmpattern2 += " ?f"
                    self.fields2 += ["customPorosity", "porosityValue"]

            generalStruct2 = struct.Struct(bgsmpattern2)
            BGSMGeneral2 = collections.namedtuple('BGSMGeneral', self.fields2)

            buf = f.read(generalStruct2.size)
            v2 = generalStruct2.unpack(buf)
            self.data2 = BGSMGeneral2._make(v2)

            #---------

            n = struct.unpack('<I', f.read(4))[0]
            t = f.read(n).decode().rstrip('\x00')
            self.texturefiles["RootMaterialPath"] = t

            #---------

            bgsmpattern3 = "<??"
            self.fields3 = ["anisoLighting", "emitEnabled"]

            BGSMstruct3 = struct.Struct(bgsmpattern3)
            BGSMGeneral3 = collections.namedtuple('BGSMGeneral', self.fields3)

            buf = f.read(BGSMstruct3.size)
            v3 = BGSMstruct3.unpack(buf)
            self.data3 = BGSMGeneral3._make(v3)

            #----------

            if self.data3.emitEnabled:
                bgsmpattern4 = "<I"
                self.fields4 = ["emittanceColor"]
            else:
                bgsmpattern4 = "<"
                self.fields4 = []

            bgsmpattern4 += " f??"
            self.fields4 += ["emittanceMult", "modelSpaceNormals", "externalEmittance",]

            if self.header.version >= 12:
                bgsmpattern4 += " f"
                self.fields4 += ["lumEmittance",]

            if self.header.version >= 13:
                bgsmpattern4 += " ?fff"
                self.fields4 += ["useAdaptativeEmissive", "adaptativeEmissive_ExposureOffset",
                                "adaptativeEmissive_FinalExposureMin", "adaptativeEmissive_FinalExposureMax"]
            
            if self.header.version < 8:
                bgsmpattern4 += " ?"
                self.fields4 += ["backLighting"]

            bgsmpattern4 += " ??????"
            self.fields4 += ["receiveShadows", "hideSecret", "castShadows", "dissolveFade",
                            "assumeShadowmask", "glowmap"]
            
            if self.header.version < 7:
                bgsmpattern4 += " ??"
                self.fields4 += ["environmentMappingWindow", "environmentMappingEye"]

            bgsmpattern4 += " ?I????"
            self.fields4 += ["hair", "hairTintColor", "tree", "facegen", "skinTint", "tessellate"] 

            if self.header.version < 3:
                bgsmpattern4 += " fffff"
                self.fields4 += ["displacementTextureBias", "displacementTextureScale",
                                "tessellationPnScale", "tessellationBaseFactor", "tessellationFadeDistance"]
                
            bgsmpattern4 += " f"
            self.fields4 += ["grayscaleToPaletteScale"]

            if self.header.version >= 1:
                bgsmpattern4 += " ?"
                self.fields4 += ["skewSpecularAlpha"]

            if self.header.version >= 3:
                bgsmpattern4 += " ?"
                self.fields4 += ["terrain"]

            BGSMstruct4 = struct.Struct(bgsmpattern4)
            BGSMGeneral4 = collections.namedtuple('BGSMGeneral', self.fields4)

            buf = f.read(BGSMstruct4.size)
            v4 = BGSMstruct4.unpack(buf)
            self.data4 = BGSMGeneral4._make(v4)

            #----------

            if self.header.version >= 3:
                if self.data4.terrain:
                    bgsmpattern5 = "<"
                    self.fields5 = []

                    if self.header.version == 3:
                        bgsmpattern5 += "I"
                        self.fields5 += ["unkInt1"]

                    bgsmpattern5 += " fff"
                    self.fields5 += ["terrainThresholdFalloff", "terrainTilingDistance", "terrainRotationAngle"]

                    BGSMstruct5 = struct.Struct(bgsmpattern5)
                    BGSMGeneral5 = collections.namedtuple('BGSMGeneral', self.fields5)

                    buf = f.read(BGSMstruct5.size)
                    v5 = BGSMstruct5.unpack(buf)
                    self.data5 = BGSMGeneral4._make(v5)


def WalkTree(folder_path):
    """Return all files in a directory tree, recursively. Skip folders starting with 'XXX'."""
    for root, directories, files in os.walk(folder_path):
        if (not 'xxx' in root) and (not 'XXX' in root):
            for filename in files:
                file_path = os.path.join(root, filename)
                yield file_path

def FileExistsInPaths(fn, rootlist):
    """Determine whether the given file exists in any of the given mod roots."""
    ext = os.path.splitext(fn)[1].upper()
    found = False
    if ext == '.BGSM':
        folder = 'materials'
    elif ext == '.DDS':
        folder = 'textures'
    else: 
        found = True

    if not found:
        for r in rootlist:
            fp = os.path.join(r, folder, fn)
            if os.path.exists(fp):
                found = True
                break

    return found


def VerifyFolder(fp):
    """Verify texture paths in all BGSM files in the given folder."""
    targ = Path(targetFolder)
    for f in WalkTree(fp):
        if os.path.splitext(f)[1].upper() == '.BGSM':
            # print(f"Checking{f}")
            m = BGSMaterial()
            m.read(f)
            for tt, tp in m.texturefiles.items():
                if tp != '':
                    if not FileExistsInPaths(tp, targetPaths):
                        print(f"ERROR: Does not exist: {tp}")

VerifyFolder(targetFolder)

print("Done")