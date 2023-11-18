""" Select vertices affected by the current shape key """

import bpy
import math

bpy.ops.object.mode_set(mode = 'EDIT') 
bpy.ops.mesh.select_mode(type="VERT")
bpy.ops.mesh.select_all(action = 'DESELECT')
bpy.ops.object.mode_set(mode = 'OBJECT')

active_k = bpy.context.object.active_shape_key
kb = bpy.context.object.data.shape_keys.key_blocks[active_k.name]

for vb, vk in zip(bpy.context.object.data.vertices, active_k.data):
    if (vb.co-vk.co).length > 0.0001:
        vb.select = True

bpy.ops.object.mode_set(mode = 'EDIT') 
