import bpy

for b in bpy.context.object.data.edit_bones:
    b.roll -= 90 * ((2*pi)/360)
