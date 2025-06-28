""" Convert the active object to a mesh, preserving shape keys."""
import bpy


def ObjectSelect(objlist, deselect=True, active=True):
    """Select all the objects in the list"""
    try:
        bpy.ops.object.mode_set(mode = 'OBJECT')
    except:
        pass
    if deselect:
        bpy.ops.object.select_all(action='DESELECT')
    for o in objlist:
        o.select_set(True)
    if active and objlist:
        bpy.context.view_layer.objects.active = objlist[0]


# Accumulate all shape keys into the original object.
obj = bpy.context.object
try:
    objbase = obj.data.surface
except:
    objbase = None


# Make a copy of the original object as source of copies.
ObjectSelect([obj])
bpy.ops.object.duplicate()
objsource = bpy.context.object

assert objsource.data != obj.data, "Copy is cleanly separate"

# Now original object can be converted to a mesh and given shapekeys, if needed.
ObjectSelect([obj])
bpy.ops.object.convert(target='MESH') # This loses the shape key association.

# Find the base object's shape keys.
try:
    allkeys = objbase.data.shape_keys.key_blocks.keys()
except:
    allkeys = []

print(f"Found {len(allkeys)} shape keys in the base object.")

for i, skn in enumerate(allkeys):
    # Set the shape key on the base object.
    ObjectSelect([objbase])
    bpy.ops.object.shape_key_clear()
    objbase.data.shape_keys.key_blocks[skn].value = 1.0

    # Dup the source object and convert to mesh with the current shape key. 
    ObjectSelect([objsource])   
    bpy.ops.object.duplicate()
    objcopy = bpy.context.object
    bpy.ops.object.convert(target='MESH') # This loses the shape key association.
    objcopy.name = 'TMPCOPY/' + skn

    # Join the new copy into the destination object as a shape key.
    ObjectSelect([obj, objcopy])
    bpy.ops.object.join_shapes()

    # And delete the copy
    ObjectSelect([objcopy])
    bpy.ops.object.delete()

# Return everything to a friendly state.
ObjectSelect([objbase])
bpy.ops.object.shape_key_clear()
ObjectSelect([objsource])
bpy.ops.object.delete()
ObjectSelect([obj])

# Rename all new shape keys to the correct names.
for sk in obj.data.shape_keys.key_blocks:
    if sk.name.startswith('TMPCOPY/'):
        sk.name = sk.name[8:]
