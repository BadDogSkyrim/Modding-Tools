""" COPY SHAPE KEYS BETWEEN SHAPES 

    Copies shape keys from selected to active shape.
    Starts with the active key in the selected shape.
    Copies all keys or until it reaches "last" named below.
 """

import bpy

dstobj = bpy.context.active_object # Active object is destination
srcobj = None
for o in bpy.context.selected_objects:
    if o != dstobj:
        srcobj = o

print (srcobj.name + " -> " + dstobj.name)

startIndex = srcobj.active_shape_key_index # Copy from active key to end

### EDITABLE VARIABLES ###
last = "*"       # Last shapekey to save

i = startIndex
for sp in srcobj.data.shape_keys.key_blocks[startIndex:]:
    if sp.name == last:
        break
    
    sp.value = 1  # enable this shape key
    srcobj.active_shape_key_index = i
    print("Copying " + srcobj.active_shape_key.name + " to " + dstobj.name)
    bpy.ops.object.shape_key_transfer()
    sp.value = 0
    
    i += 1
