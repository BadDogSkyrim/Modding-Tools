"""Print bone transforms for the selected skeleton"""
import bpy

arma = bpy.context.object
for b in arma.data.bones:
    print(b.name)
    print(b.matrix_local)
    print("")