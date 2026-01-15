""" VertexGroupFlipLR

Change names of vertex groups ending in ".L" to ".R" and vice vesa
"""

import bpy

v_groups = bpy.context.active_object.vertex_groups

dup_names = []

for name in v_groups.keys():
    if name[-2:] == '.L':
        g = v_groups[name]
        g.name = name[:-2] + ".R"
        if g.name[-2:] != ".R":
            dup_names.append(g)
    elif name[-2:] == '.R':
        g = v_groups[name]
        g.name = name[:-2] + ".L"
        if g.name[-2:] != ".L":
            dup_names.append(g)
            
for g in dup_names:
    g.name = ".".join(g.name.split(".")[0:-1])

print('done')
