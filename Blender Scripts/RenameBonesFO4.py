""" Convert from game expression morph name to blender name and back """

import bpy
from niflytools import fo4Dict, fo4FaceDict

for b in bpy.context.object.data.bones:
    if b.name in fo4Dict.byPynifly:
        b.name = fo4Dict.byPynifly[b.name].nif
    elif b.name in fo4Dict.byNif:
        b.name = fo4Dict.byNif[b.name].blender
    elif b.name in fo4FaceDict.byPynifly:
        b.name = fo4FaceDict.byPynifly[b.name].nif
    elif b.name in fo4FaceDict.byNif:
        b.name = fo4FaceDict.byNif[b.name].blender
print('done')