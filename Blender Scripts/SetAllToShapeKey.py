"""
Set all visible object shape keys to the active shape key of the active object.
"""

import bpy

def is_object_visible(obj):
    # Check object-level visibility
    if obj.hide_viewport or obj.hide_get():
        return False

    # Get the active view layer
    view_layer = bpy.context.view_layer

    # Recursive function to check LayerCollection visibility
    def is_collection_visible(layer_coll):
        if not layer_coll.is_visible:
            return False
        for child in layer_coll.children:
            if child.collection == obj.users_collection[0]:  # assumes single collection
                return is_collection_visible(child)
        return True

    # Start from the top-level LayerCollection
    return is_collection_visible(view_layer.layer_collection)


targ = bpy.context.object
keyname = bpy.context.object.active_shape_key.name
print(f"Setting to key {keyname}")

for obj in bpy.context.scene.objects:
    if is_object_visible(obj):
        if obj.data and obj.type == 'MESH':
            print(f"Getting keys for {obj.name}") 
            if obj.data.shape_keys and obj.data.shape_keys.key_blocks and keyname in obj.data.shape_keys.key_blocks:
                obj.active_shape_key_index = obj.data.shape_keys.key_blocks.find(keyname)
            else:
                obj.active_shape_key_index = 0
