import bpy

bpy.context.object.active_shape_key.name = "*" + bpy.context.object.active_shape_key.name
bpy.context.object.active_shape_key_index += 1