"""
Set all visible object shape keys to the active shape key of the active object.
"""

import bpy

targ = bpy.context.object
keyname = bpy.context.object.active_shape_key.name
print(f"Setting to key {keyname}")

for obj in bpy.context.scene.objects:
    if not obj.hide_get():
        if obj.data and obj.type == 'MESH': 
            if keyname in obj.data.shape_keys.key_blocks:
                obj.active_shape_key_index = obj.data.shape_keys.key_blocks.find(keyname)
            else:
                obj.active_shape_key_index = 0
