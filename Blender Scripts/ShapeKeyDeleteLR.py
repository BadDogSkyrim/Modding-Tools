""" ShapeKeyDeleteLR

Delete all shape keys ending in a particular suffix or beginning with a prefix.
"""

import bpy

target_suffix = ".L"
target_prefix = "*"

obj = bpy.context.object
curSK = obj.active_shape_key.name

keyblocks = obj.data.shape_keys.key_blocks

found = True
while found:
    found = False
    # Changing keys while we walk them, so delete one at a time.
    for i, k in enumerate(keyblocks.values()):
        if (target_suffix and k.name.endswith(target_suffix)) \
            or (target_prefix and k.name.startswith(target_prefix)):
            
            if k.name == curSK: curSK = None
            
            obj.active_shape_key_index = i
            bpy.ops.object.shape_key_remove()
            found = True
    
        if found: break
            
if curSK: 
    i = keyblocks.find(curSK)
    obj.active_shape_key_index = i
    
print('done')