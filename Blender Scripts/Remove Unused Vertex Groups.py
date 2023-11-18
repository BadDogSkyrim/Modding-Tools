""" Remove unused vertex groups from shape """

import bpy
import bmesh

obj = bpy.context.object

bm = bmesh.new()
bm.from_mesh(obj.data)

deform_layer = bm.verts.layers.deform.active
used_groups = set()
if deform_layer:
    #log.debug("Have deform layer")
    for v_index, v in enumerate(bm.verts):
        for g_index, w in v[deform_layer].items():
            #if v_index==2945: log.debug(f"Vert 2945 in group {obj.vertex_groups[g].name} with weight {w}")
            if w > 0.0001:
                used_groups.add(obj.vertex_groups[g_index].name)

all_groups = set([g.name for g in obj.vertex_groups])
unused_groups = all_groups.difference(used_groups)

for g in unused_groups:
    if not g.startswith("FO4") and not g.startswith("SBP"):
        print(f"Deleting group '{g}'")
        obj.vertex_groups.remove(obj.vertex_groups[g])
