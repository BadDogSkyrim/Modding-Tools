""" Convert from game expression morph name to blender name and back """

import bpy
from niflytools import fo4Dict, fo4FaceDict

vgroups = bpy.context.object.vertex_groups
for v in vgroups:
    if v.name in fo4Dict.byPynifly:
        v.name = fo4Dict.byPynifly[v.name].nif
    elif v.name in fo4Dict.byNif:
        v.name = fo4Dict.byNif[v.name].blender
    elif v.name in fo4FaceDict.byPynifly:
        v.name = fo4FaceDict.byPynifly[v.name].nif
    elif v.name in fo4FaceDict.byNif:
        v.name = fo4FaceDict.byNif[v.name].blender
print('done')