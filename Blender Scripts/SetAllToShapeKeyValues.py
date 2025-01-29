import bpy

targ = bpy.context.object

for sk in targ.data.shape_keys.key_blocks:
    for obj in bpy.context.scene.objects:
        if not obj.hide_get() and obj.type == 'MESH':
            if obj.data and obj.data.shape_keys and sk.name in obj.data.shape_keys.key_blocks:
                obj.data.shape_keys.key_blocks[sk.name].value = sk.value
