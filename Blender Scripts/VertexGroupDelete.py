""" VertexGroupDeleteLR

Delete vertex groups with a given prefix or suffix.
"""

import bpy

target_prefix = None
target_suffix = '.L'

v_groups = bpy.context.active_object.vertex_groups

found = True
while found:
    found = False
    for g in v_groups.values():
        if (target_prefix and g.name.startswith(target_prefix)) \
            or (target_suffix and g.name.endswith(target_suffix)):
            
            v_groups.remove(g)
            found = True
            break

print('done')
