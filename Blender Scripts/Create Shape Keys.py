""" CREATE SHAPE KEYS 

    Creates all the shapes in one mesh in another mesh
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
last = "*"       # Last shapekey to copy

i = startIndex
j = startIndex
dstblocks = dstobj.data.shape_keys.key_blocks
jlimit = len(dstblocks)

for sp in srcobj.data.shape_keys.key_blocks[startIndex:]:
    if sp.name == last:
        print('DONE')
        break
    dp = dstblocks[j] if j < jlimit else None
    
    spname = sp.name.split('[')[0].strip()
    dpname = '' if dp is None else dp.name.split('[')[0].strip() 
    
    if dpname == spname:
        dp.name = sp.name # make sure name matches exactly
    else:
        if dp is None:
            print("Creating " + sp.name + " at end of list")
            dstblocks[-1].value = 1
        else:
            print("Creating " + sp.name + " before " + dp.name)
            dp.value = 1
        
        bpy.ops.object.shape_key_add(from_mix=False)
        np = dstblocks[-1]
        np.name = sp.name
        
        if not (dp is None):
            for k in range(len(dstblocks)-j-1):
                bpy.ops.object.shape_key_move(type='UP')
                
    i += 1
    j += 1
