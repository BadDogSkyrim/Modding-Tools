""" COPY SHAPE KEYS BETWEEN SHAPES 

    Copies shape keys from selected to active shape.
    Starts with the active key in the selected shape.
    Copies all keys or until it reaches "last" named below.
 """

import bpy

dst = bpy.context.selected_objects[1] # Active object is destination
src = bpy.context.selected_objects[0]

print (src.name + " -> " + dst.name)

startIndex = src.active_shape_key_index # Copy from active key to end

### EDITABLE VARIABLES ###
last = "*"       # Last shapekey to save

i = startIndex
for sp in src.data.shape_keys.key_blocks[startIndex:]:
    if sp.name == last:
        break
    
    sp.value = 1  # enable this shape key
    src.active_shape_key_index = i
    print("Copying " + src.active_shape_key.name + " to " + dst.name)
    bpy.ops.object.shape_key_transfer()
    sp.value = 0
    
    i += 1
