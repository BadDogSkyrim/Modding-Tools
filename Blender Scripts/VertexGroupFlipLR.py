""" VertexGroupFlipLR

Change names of vertex groups ending in ".L" to ".R" and vice vesa
"""

import bpy

v_groups = bpy.context.active_object.vertex_groups

for name in v_groups.keys():
    if name[-2:] == '.L':
        v_groups[name].name = name[:-2] + ".R"
    elif name[-2:] == '.R':
        v_groups[name].name = name[:-2] + ".L"
print('done')
